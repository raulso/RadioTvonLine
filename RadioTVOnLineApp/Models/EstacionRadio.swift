import Foundation

/// Estación de radio lista para mostrarse en la app (modelo propio, no el de la API).
struct EstacionRadio: Identifiable, Hashable {
    let id: String
    let nombre: String
    let genero: String?
    let pais: String?
    /// URL de audio elegida entre los `streams` de la API. Puede faltar.
    let streamURL: URL?
    var logoURL: URL? = nil

    /// Texto secundario de la fila: "Género · País".
    var detalle: String {
        let partes = [genero, pais].compactMap { $0 }.filter { !$0.isEmpty }
        return partes.isEmpty ? "Sin información" : partes.joined(separator: " · ")
    }
}
