import Foundation

/// Lee la API key de RapidAPI desde `Secrets.plist`.
///
/// `Secrets.plist` es el ÚNICO archivo con la clave. Está en `.gitignore`
/// y no se entrega: para usar la app copia `Secrets.example.plist` (raíz del
/// proyecto) dentro de la carpeta `RadioTVOnLineApp/`, renómbralo a
/// `Secrets.plist` y pega tu clave en `RAPIDAPI_KEY`.
enum ConfiguracionAPI {
    static let rapidAPIHost = "50k-radio-stations.p.rapidapi.com"

    static var rapidAPIKey: String? {
        guard
            let ruta = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
            let datos = try? Data(contentsOf: ruta),
            let plist = try? PropertyListSerialization.propertyList(from: datos, format: nil) as? [String: Any],
            let clave = plist["RAPIDAPI_KEY"] as? String
        else { return nil }

        let limpia = clave.trimmingCharacters(in: .whitespacesAndNewlines)
        // Se ignora el texto de ejemplo para no hacer peticiones inútiles.
        return (limpia.isEmpty || limpia == "TU_CLAVE") ? nil : limpia
    }
}
