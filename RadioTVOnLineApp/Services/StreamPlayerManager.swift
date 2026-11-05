import Foundation
import AVFoundation

/// Envuelve un `AVPlayer` para reproducir un stream (radio o TV) y avisa
/// de cada cambio de estado. Detecta cuando el stream falla para que la app
/// nunca se quede "cargando" para siempre.
@MainActor
final class StreamPlayerManager {
    let player = AVPlayer()

    /// El ViewModel se suscribe aquí para actualizar su estado.
    var alCambiarEstado: (@MainActor (EstadoReproduccion) -> Void)?

    /// Segundos máximos de espera antes de declarar el stream no disponible.
    private let tiempoLimite: Duration = .seconds(20)

    private var observadorEstadoItem: NSKeyValueObservation?
    private var observadorControlTiempo: NSKeyValueObservation?
    private var observadorFallo: NSObjectProtocol?
    private var tareaTiempoLimite: Task<Void, Never>?
    private var pausadoPorUsuario = false
    private var finalizado = false

    // MARK: - Acciones

    func reproducir(url: URL) {
        detener()
        finalizado = false
        pausadoPorUsuario = false
        configurarSesionAudio()
        notificar(.cargando)

        let item = AVPlayerItem(url: url)
        observar(item)
        player.replaceCurrentItem(with: item)
        player.play()
        iniciarTiempoLimite()
    }

    func pausar() {
        pausadoPorUsuario = true
        player.pause()
        notificar(.pausado)
    }

    func reanudar() {
        pausadoPorUsuario = false
        player.play()
    }

    /// Detiene y libera el stream. Se llama al salir de la pantalla.
    func detener() {
        tareaTiempoLimite?.cancel()
        tareaTiempoLimite = nil
        observadorEstadoItem?.invalidate()
        observadorControlTiempo?.invalidate()
        observadorEstadoItem = nil
        observadorControlTiempo = nil
        if let observadorFallo { NotificationCenter.default.removeObserver(observadorFallo) }
        observadorFallo = nil

        player.pause()
        player.replaceCurrentItem(with: nil)
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    // MARK: - Configuración

    /// Categoría .playback: el audio suena aunque el interruptor de silencio esté activo.
    private func configurarSesionAudio() {
        let sesion = AVAudioSession.sharedInstance()
        try? sesion.setCategory(.playback, mode: .default)
        try? sesion.setActive(true)
    }

    // MARK: - Observación del stream

    private func observar(_ item: AVPlayerItem) {
        // 1) Estado del item: .failed significa que el stream no se puede reproducir.
        observadorEstadoItem = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            let fallo = item.status == .failed
            let detalle = item.error?.localizedDescription
            Task { @MainActor [weak self] in
                if fallo { self?.marcarNoDisponible(detalle) }
            }
        }

        // 2) Si realmente está sonando / mostrando imagen.
        observadorControlTiempo = player.observe(\.timeControlStatus, options: [.new]) { [weak self] player, _ in
            let estado = player.timeControlStatus
            Task { @MainActor [weak self] in self?.procesar(estado) }
        }

        // 3) El stream se corta a media reproducción.
        observadorFallo = NotificationCenter.default.addObserver(
            forName: AVPlayerItem.failedToPlayToEndTimeNotification,
            object: item,
            queue: .main
        ) { [weak self] notificacion in
            let error = notificacion.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey] as? Error
            let detalle = error?.localizedDescription
            Task { @MainActor [weak self] in self?.marcarNoDisponible(detalle) }
        }
    }

    private func procesar(_ estado: AVPlayer.TimeControlStatus) {
        guard !finalizado else { return }
        switch estado {
        case .playing:
            tareaTiempoLimite?.cancel()
            notificar(.reproduciendo)
        case .waitingToPlayAtSpecifiedRate:
            notificar(.cargando)
        case .paused:
            if pausadoPorUsuario { notificar(.pausado) }
        @unknown default:
            break
        }
    }

    /// Si en `tiempoLimite` no empezó a sonar, se avisa que no está disponible.
    private func iniciarTiempoLimite() {
        tareaTiempoLimite?.cancel()
        tareaTiempoLimite = Task { [weak self, tiempoLimite] in
            try? await Task.sleep(for: tiempoLimite)
            guard !Task.isCancelled, let self else { return }
            if self.player.timeControlStatus != .playing, !self.pausadoPorUsuario {
                self.marcarNoDisponible("El servidor tardó demasiado en responder.")
            }
        }
    }

    private func marcarNoDisponible(_ detalle: String?) {
        guard !finalizado else { return }
        finalizado = true
        tareaTiempoLimite?.cancel()
        player.pause()
        let mensaje = detalle.map { "El stream no se puede reproducir. \($0)" }
            ?? "El stream no se puede reproducir en este momento."
        notificar(.noDisponible(mensaje))
    }

    private func notificar(_ estado: EstadoReproduccion) {
        alCambiarEstado?(estado)
    }
}
