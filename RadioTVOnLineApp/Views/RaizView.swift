import SwiftUI

/// Decide qué mostrar: login o la app principal, según la sesión guardada.
struct RaizView: View {
    let sesion: SesionViewModel

    var body: some View {
        Group {
            if sesion.sesionIniciada {
                PrincipalView(sesion: sesion)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            } else {
                LoginView(sesion: sesion)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: sesion.sesionIniciada)
        // Texto claro sobre el fondo rojo en toda la app.
        .preferredColorScheme(.dark)
    }
}

/// Pestañas principales: Radio, TV y perfil, con barra inferior roja oscura.
struct PrincipalView: View {
    let sesion: SesionViewModel

    var body: some View {
        TabView {
            RadioListaView()
                .barraPestanasRoja()
                .tabItem { Label("Radio", systemImage: "radio") }

            TVListaView()
                .barraPestanasRoja()
                .tabItem { Label("TV", systemImage: "tv") }

            PerfilView(sesion: sesion)
                .barraPestanasRoja()
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
        }
        .tint(.white)
    }
}

private extension View {
    func barraPestanasRoja() -> some View {
        self
            .toolbarBackground(Tema.oscuro, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
    }
}
