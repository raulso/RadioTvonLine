import Foundation
import Observation

/// Descarga y filtra la lista de canales de TV (M3U).
@MainActor
@Observable
final class TVListaViewModel {
    private(set) var estado: EstadoCarga<Canal> = .inactivo
    var busqueda = ""

    private let manager = TVManager()

    var canalesFiltrados: [Canal] {
        guard case .cargado(let canales) = estado else { return [] }
        let texto = busqueda.trimmingCharacters(in: .whitespaces)
        guard !texto.isEmpty else { return canales }
        return canales.filter {
            $0.nombre.localizedCaseInsensitiveContains(texto)
                || $0.categoria.localizedCaseInsensitiveContains(texto)
        }
    }

    func cargarSiHaceFalta() async {
        guard case .inactivo = estado else { return }
        await cargar()
    }

    func cargar() async {
        if case .cargado = estado {} else { estado = .cargando }
        do {
            let canales = try await manager.obtenerCanales()
            estado = canales.isEmpty ? .vacio : .cargado(canales)
        } catch {
            // Si la vista se cerró a media descarga, se reintenta al volver a ella.
            if Task.isCancelled {
                if case .cargando = estado { estado = .inactivo }
                return
            }
            estado = .error(error.localizedDescription)
        }
    }
}
