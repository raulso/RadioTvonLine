import Foundation

/// Errores de red con mensajes listos para mostrarse al usuario.
enum ErrorServicio: LocalizedError {
    case sinClaveAPI
    case http(Int)
    case datosInvalidos
    case sinConexion(String)

    var errorDescription: String? {
        switch self {
        case .sinClaveAPI:
            return "Falta la API key de RapidAPI. Agrega tu clave en Secrets.plist."
        case .http(let codigo) where codigo == 401 || codigo == 403:
            return "La API rechazó la clave (HTTP \(codigo)). Revisa tu API key y tu suscripción."
        case .http(429):
            return "Se agotó el límite de peticiones del plan gratuito. Intenta más tarde."
        case .http(let codigo):
            return "El servidor respondió con un error (HTTP \(codigo))."
        case .datosInvalidos:
            return "La respuesta del servidor no tiene el formato esperado."
        case .sinConexion(let detalle):
            return "No se pudo conectar: \(detalle)"
        }
    }
}

/// Descarga estaciones de la API "50k Radio Stations" y las convierte en modelos propios.
struct RadioManager {
    func obtenerEstaciones(limite: Int = 20) async throws -> [EstacionRadio] {
        guard let clave = ConfiguracionAPI.rapidAPIKey else { throw ErrorServicio.sinClaveAPI }

        var componentes = URLComponents(string: "https://\(ConfiguracionAPI.rapidAPIHost)/radios/random")!
        componentes.queryItems = [URLQueryItem(name: "limit", value: String(limite))]

        var solicitud = URLRequest(url: componentes.url!)
        solicitud.timeoutInterval = 20
        solicitud.setValue(ConfiguracionAPI.rapidAPIHost, forHTTPHeaderField: "x-rapidapi-host")
        solicitud.setValue(clave, forHTTPHeaderField: "x-rapidapi-key")

        let datos: Data
        let respuesta: URLResponse
        do {
            (datos, respuesta) = try await URLSession.shared.data(for: solicitud)
        } catch {
            throw ErrorServicio.sinConexion(error.localizedDescription)
        }

        if let http = respuesta as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw ErrorServicio.http(http.statusCode)
        }

        // Las estaciones vienen dentro de "data".
        let decodificador = JSONDecoder()
        let estacionesAPI: [RadioAPIEstacion]
        if let envoltura = try? decodificador.decode(RadioAPIRespuesta.self, from: datos) {
            estacionesAPI = envoltura.data
        } else if let lista = try? decodificador.decode([RadioAPIEstacion].self, from: datos) {
            estacionesAPI = lista
        } else {
            throw ErrorServicio.datosInvalidos
        }

        // Se eliminan duplicados por id para que la lista no repita filas.
        var vistos = Set<String>()
        return estacionesAPI.compactMap(convertir).filter { vistos.insert($0.id).inserted }
    }

    // MARK: - Conversión API → modelo propio

    private func convertir(_ api: RadioAPIEstacion) -> EstacionRadio? {
        guard let nombre = api.name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !nombre.isEmpty else { return nil }

        return EstacionRadio(
            id: api.id ?? UUID().uuidString,
            nombre: nombre,
            genero: api.genre?.text,
            pais: api.location?.countryName,
            streamURL: elegirStream(api.streams),
            logoURL: api.logo.flatMap(URL.init(string:))
        )
    }

    /// La URL de audio está en `streams` (una lista). Se elige la mejor:
    /// 1) que funcione, 2) HTTPS, 3) códec que AVPlayer reproduce, 4) mayor bitrate.
    private func elegirStream(_ streams: [RadioAPIStream]) -> URL? {
        let codecsCompatibles = ["mp3", "aac", "aac+", "he-aac", "mpeg"]

        func puntaje(_ s: RadioAPIStream) -> Int {
            var p = 0
            if s.works == true { p += 1000 }
            if s.isHttps == true || s.url?.lowercased().hasPrefix("https") == true { p += 500 }
            if let codec = s.codec?.lowercased(), codecsCompatibles.contains(where: { codec.contains($0) }) { p += 250 }
            p += min(s.bitrate ?? 0, 249)
            return p
        }

        return streams
            .filter { $0.works != false } // Descarta los marcados como caídos.
            .compactMap { s -> (URL, Int)? in
                guard let texto = s.url, let url = URL(string: texto),
                      ["http", "https"].contains(url.scheme?.lowercased() ?? "") else { return nil }
                return (url, puntaje(s))
            }
            .max(by: { $0.1 < $1.1 })?.0
    }
}
