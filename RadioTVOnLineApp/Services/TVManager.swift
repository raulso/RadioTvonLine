import Foundation

/// Descarga la lista M3U de canales de México y la convierte en `[Canal]`.
struct TVManager {
    static let urlLista = URL(string: "https://iptv-org.github.io/iptv/countries/mx.m3u")!

    func obtenerCanales() async throws -> [Canal] {
        var solicitud = URLRequest(url: Self.urlLista)
        solicitud.timeoutInterval = 20

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

        guard let texto = String(data: datos, encoding: .utf8)
                ?? String(data: datos, encoding: .isoLatin1) else {
            throw ErrorServicio.datosInvalidos
        }

        return M3UParser.parsear(texto)
    }
}
