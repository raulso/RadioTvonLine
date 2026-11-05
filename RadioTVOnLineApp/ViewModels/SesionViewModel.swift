import Foundation
import Observation

/// Controla el login y la sesión de toda la app.
@MainActor
@Observable
final class SesionViewModel {
    // Campos del formulario (la vista los escribe con @Bindable).
    var usuario = ""
    var contrasena = ""

    private(set) var mensajeError: String?
    private(set) var usuarioActivo: String?
    private(set) var inicioSesion: Date?
    /// Cambia en cada intento fallido: la vista lo usa para "sacudir" el formulario.
    private(set) var intentosFallidos = 0

    var sesionIniciada: Bool { usuarioActivo != nil }

    var puedeEntrar: Bool {
        !usuario.trimmingCharacters(in: .whitespaces).isEmpty && !contrasena.isEmpty
    }

    /// Inicial del usuario para el avatar del perfil.
    var inicial: String {
        String(usuarioActivo?.first ?? "U").uppercased()
    }

    init() {
        // Si hay una sesión guardada en el Keychain, no se pide login otra vez.
        usuarioActivo = AuthManager.usuarioConSesion()
        inicioSesion = AuthManager.fechaInicioSesion()
    }

    func iniciarSesion() {
        if AuthManager.iniciarSesion(usuario: usuario, contrasena: contrasena) {
            usuarioActivo = AuthManager.usuarioConSesion()
            inicioSesion = AuthManager.fechaInicioSesion()
            mensajeError = nil
            contrasena = ""
        } else {
            mensajeError = "Usuario o contraseña incorrectos."
            intentosFallidos += 1
        }
    }

    func limpiarError() {
        mensajeError = nil
    }

    func cerrarSesion() {
        AuthManager.cerrarSesion()
        usuarioActivo = nil
        inicioSesion = nil
        usuario = ""
        contrasena = ""
    }
}
