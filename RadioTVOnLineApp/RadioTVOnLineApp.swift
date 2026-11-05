import SwiftUI

@main
struct RadioTVOnLineApp: App {
    // ViewModel de sesión compartido por toda la app.
    @State private var sesion = SesionViewModel()

    var body: some Scene {
        WindowGroup {
            RaizView(sesion: sesion)
        }
    }
}
