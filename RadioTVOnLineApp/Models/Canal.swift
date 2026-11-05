import Foundation

/// Canal de TV obtenido de la lista M3U.
struct Canal: Identifiable, Hashable {
    let id: String
    let nombre: String
    let categoria: String
    let url: URL
    var logoURL: URL? = nil
}
