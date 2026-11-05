import Foundation

/// Convierte el texto de una lista M3U en canales.
/// Cada canal ocupa dos líneas:
///   #EXTINF:-1 tvg-logo="..." group-title="Noticias",Nombre del canal
///   https://servidor.com/stream.m3u8
enum M3UParser {
    static func parsear(_ contenido: String) -> [Canal] {
        var canales: [Canal] = []
        var extinfPendiente: String?

        for lineaCruda in contenido.components(separatedBy: .newlines) {
            let linea = lineaCruda.trimmingCharacters(in: .whitespacesAndNewlines)
            if linea.isEmpty { continue }

            if linea.hasPrefix("#EXTINF") {
                extinfPendiente = linea
                continue
            }
            // Otras directivas (#EXTM3U, #EXTVLCOPT, ...) se ignoran.
            if linea.hasPrefix("#") { continue }

            // Línea de URL: solo cuenta si viene después de un #EXTINF.
            defer { extinfPendiente = nil }
            guard let extinf = extinfPendiente,
                  let url = URL(string: linea),
                  ["http", "https"].contains(url.scheme?.lowercased() ?? "") else { continue }

            canales.append(
                Canal(
                    id: "\(canales.count)-\(linea)",
                    nombre: extraerNombre(extinf),
                    categoria: extraerAtributo("group-title", de: extinf) ?? "General",
                    url: url,
                    logoURL: extraerAtributo("tvg-logo", de: extinf).flatMap(URL.init(string:))
                )
            )
        }
        return canales
    }

    /// El nombre va después de la última coma de la línea #EXTINF.
    private static func extraerNombre(_ linea: String) -> String {
        guard let coma = linea.lastIndex(of: ",") else { return "Sin nombre" }
        let nombre = linea[linea.index(after: coma)...].trimmingCharacters(in: .whitespaces)
        return nombre.isEmpty ? "Sin nombre" : nombre
    }

    /// Lee un atributo del tipo clave="valor".
    private static func extraerAtributo(_ atributo: String, de linea: String) -> String? {
        guard let inicio = linea.range(of: "\(atributo)=\"") else { return nil }
        let resto = linea[inicio.upperBound...]
        guard let fin = resto.firstIndex(of: "\"") else { return nil }
        let valor = String(resto[..<fin]).trimmingCharacters(in: .whitespaces)
        return valor.isEmpty ? nil : valor
    }
}
