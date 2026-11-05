import SwiftUI

/// Colores y estilos compartidos: identidad roja de la app.
enum Tema {
    static let rojoClaro = Color(red: 0.96, green: 0.26, blue: 0.24)
    static let primario = Color(red: 0.80, green: 0.07, blue: 0.16)
    static let oscuro = Color(red: 0.30, green: 0.02, blue: 0.06)

    static let radio = Color(red: 1.00, green: 0.62, blue: 0.58)   // Coral claro
    static let tv = Color(red: 1.00, green: 0.80, blue: 0.45)      // Ámbar

    static let degradado = LinearGradient(
        colors: [rojoClaro, primario, oscuro],
        startPoint: .top,
        endPoint: .bottom
    )
}

/// Fondo principal de todas las pantallas: degradado rojo con un brillo suave.
struct FondoRojoView: View {
    var body: some View {
        ZStack {
            Tema.degradado
            RadialGradient(
                colors: [.white.opacity(0.20), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 450
            )
        }
        .ignoresSafeArea()
    }
}

extension View {
    /// Aplica el fondo rojo y una barra de navegación a juego.
    func fondoPrincipal() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background { FondoRojoView() }
            .toolbarBackground(Tema.oscuro.opacity(0.92), for: .navigationBar)
    }

    /// Fondo translúcido para las filas de las listas.
    func filaTranslucida() -> some View {
        self
            .listRowBackground(Color.white.opacity(0.10))
            .listRowSeparatorTint(.white.opacity(0.15))
    }
}

/// Texto, ícono y color de cada estado del reproductor.
extension EstadoReproduccion {
    var texto: String {
        switch self {
        case .cargando: return "Conectando…"
        case .reproduciendo: return "En vivo"
        case .pausado: return "En pausa"
        case .noDisponible: return "No disponible"
        }
    }

    var icono: String {
        switch self {
        case .cargando: return "antenna.radiowaves.left.and.right"
        case .reproduciendo: return "waveform"
        case .pausado: return "pause.fill"
        case .noDisponible: return "exclamationmark.triangle.fill"
        }
    }

    var color: Color {
        switch self {
        case .cargando: return .yellow
        case .reproduciendo: return .mint
        case .pausado: return .white.opacity(0.8)
        case .noDisponible: return .white
        }
    }
}

/// Cápsula que indica el estado actual del reproductor.
struct EtiquetaEstado: View {
    let estado: EstadoReproduccion

    var body: some View {
        Label(estado.texto, systemImage: estado.icono)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(estado.color)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black.opacity(0.25), in: Capsule())
            .symbolEffect(.variableColor.iterative, isActive: estado == .reproduciendo)
            .accessibilityLabel("Estado: \(estado.texto)")
    }
}
