import Foundation
import Security

/// Guarda, lee y borra textos en el Llavero (Keychain) de iOS.
/// Se usa para la sesión: nada sensible se guarda en UserDefaults.
enum KeychainManager {
    private static let servicio = Bundle.main.bundleIdentifier ?? "RadioTVOnLineApp"

    @discardableResult
    static func guardar(_ valor: String, clave: String) -> Bool {
        let datos = Data(valor.utf8)
        borrar(clave: clave) // Evita el error "duplicate item".

        let consulta: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: clave,
            kSecValueData as String: datos,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        return SecItemAdd(consulta as CFDictionary, nil) == errSecSuccess
    }

    static func leer(clave: String) -> String? {
        let consulta: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: clave,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var resultado: AnyObject?
        guard SecItemCopyMatching(consulta as CFDictionary, &resultado) == errSecSuccess,
              let datos = resultado as? Data else { return nil }
        return String(data: datos, encoding: .utf8)
    }

    @discardableResult
    static func borrar(clave: String) -> Bool {
        let consulta: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: servicio,
            kSecAttrAccount as String: clave
        ]
        let estado = SecItemDelete(consulta as CFDictionary)
        return estado == errSecSuccess || estado == errSecItemNotFound
    }
}
