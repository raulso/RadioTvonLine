import Foundation
import Observation

/// Descarga y filtra la lista de estaciones de radio.
@MainActor
@Observable
final class RadioListaViewModel {
    private(set) var estado: EstadoCarga<EstacionRadio> = .inactivo
    var busqueda = ""

    private let manager = RadioManager()

    /// Estaciones que coinciden con el buscador (por nombre, género o país).
    var estacionesFiltradas: [EstacionRadio] {
        guard case .cargado(let estaciones) = estado else { return [] }
        let texto = busqueda.trimmingCharacters(in: .whitespaces)
        guard !texto.isEmpty else { return estaciones }
        return estaciones.filter {
            $0.nombre.localizedCaseInsensitiveContains(texto)
                || ($0.genero ?? "").localizedCaseInsensitiveContains(texto)
                || ($0.pais ?? "").localizedCaseInsensitiveContains(texto)
        }
    }

    /// Descarga solo la primera vez: el plan gratuito limita las peticiones.
    func cargarSiHaceFalta() async {
        guard case .inactivo = estado else { return }
        await cargar()
    }

    /// Descarga nuevas estaciones (botón "Reintentar" o deslizar para actualizar).
    func cargar() async {
        if case .cargado = estado {} else { estado = .cargando }
        do {
            let estaciones = try await manager.obtenerEstaciones(limite: 20)
            estado = estaciones.isEmpty ? .vacio : .cargado(estaciones)
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
