import Foundation
import AVFoundation
import Observation

/// Controla la reproducción de un canal de TV.
@MainActor
@Observable
final class ReproductorVideoViewModel {
    let canal: Canal
    private(set) var estado: EstadoReproduccion = .cargando

    private let manager = StreamPlayerManager()

    /// `VideoPlayer` necesita el AVPlayer; la vista lo obtiene a través del ViewModel.
    var player: AVPlayer { manager.player }

    init(canal: Canal) {
        self.canal = canal
        manager.alCambiarEstado = { [weak self] nuevo in self?.estado = nuevo }
    }

    func iniciar() {
        manager.reproducir(url: canal.url)
    }

    func alternarPausa() {
        switch estado {
        case .reproduciendo: manager.pausar()
        case .pausado: manager.reanudar()
        default: break
        }
    }

    func reintentar() {
        manager.reproducir(url: canal.url)
    }

    /// Se llama al salir de la pantalla para que el video se detenga.
    func detener() {
        manager.detener()
    }
}
