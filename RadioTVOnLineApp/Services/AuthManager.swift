import Foundation

/// Valida el usuario fijo y administra la sesión guardada en el Keychain.
enum AuthManager {
    // Único usuario válido (no hay registro).
    static let usuarioValido = "raul"
    static let contrasenaValida = "123456"

    private static let claveSesion = "sesion.usuario"
    private static let claveFecha = "sesion.fecha"

    /// Devuelve `true` si las credenciales coinciden y deja la sesión guardada.
    static func iniciarSesion(usuario: String, contrasena: String) -> Bool {
        let usuarioLimpio = usuario.trimmingCharacters(in: .whitespacesAndNewlines)
        guard usuarioLimpio.lowercased() == usuarioValido,
              contrasena == contrasenaValida else { return false }

        // Solo se guardan el usuario y la hora de inicio, nunca la contraseña.
        KeychainManager.guardar(usuarioLimpio, clave: claveSesion)
        KeychainManager.guardar(String(Date().timeIntervalSince1970), clave: claveFecha)
        return true
    }

    /// Usuario con sesión activa, o `nil` si hay que mostrar el login.
    static func usuarioConSesion() -> String? {
        KeychainManager.leer(clave: claveSesion)
    }

    /// Momento en que se inició la sesión actual.
    static func fechaInicioSesion() -> Date? {
        guard let texto = KeychainManager.leer(clave: claveFecha),
              let segundos = Double(texto) else { return nil }
        return Date(timeIntervalSince1970: segundos)
    }

    static func cerrarSesion() {
        KeychainManager.borrar(clave: claveSesion)
        KeychainManager.borrar(clave: claveFecha)
    }
}
