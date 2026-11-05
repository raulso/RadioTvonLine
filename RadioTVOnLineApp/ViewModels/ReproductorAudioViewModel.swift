import Foundation
import Observation

/// Controla la reproducción de una estación de radio.
@MainActor
@Observable
final class ReproductorAudioViewModel {
    let estacion: EstacionRadio
    private(set) var estado: EstadoReproduccion = .cargando

    private let manager = StreamPlayerManager()

    init(estacion: EstacionRadio) {
        self.estacion = estacion
        manager.alCambiarEstado = { [weak self] nuevo in self?.estado = nuevo }
    }

    var estaSonando: Bool { estado == .reproduciendo }

    var puedeControlar: Bool {
        estado == .reproduciendo || estado == .pausado
    }

    func iniciar() {
        guard let url = estacion.streamURL else {
            estado = .noDisponible("Esta estación no tiene una dirección de audio disponible.")
            return
        }
        manager.reproducir(url: url)
    }

    func alternarPausa() {
        switch estado {
        case .reproduciendo: manager.pausar()
        case .pausado: manager.reanudar()
        default: break
        }
    }

    func reintentar() {
        iniciar()
    }

    /// Se llama al salir de la pantalla para que el audio se detenga.
    func detener() {
        manager.detener()
    }
}
