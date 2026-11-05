import SwiftUI

/// Botón que se activa solo si se mantiene presionado (evita cerrar sesión por accidente).
/// Una barra se llena mientras se presiona; si se suelta antes, vuelve a cero.
struct BotonMantenerView: View {
    let titulo: String
    let icono: String
    var duracion: Double = 1.5
    let accion: @MainActor () -> Void

    @State private var progreso: CGFloat = 0
    @State private var presionando = false
    @State private var completado = false

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(.white.opacity(0.12))

            // Barra de progreso que se llena al mantener presionado.
            GeometryReader { geo in
                Capsule()
                    .fill(.white.opacity(0.35))
                    .frame(width: geo.size.width * progreso)
            }

            HStack(spacing: 10) {
                Image(systemName: completado ? "checkmark.circle.fill" : icono)
                    .contentTransition(.symbolEffect(.replace))
                Text(presionando ? "Sigue presionando…" : titulo)
                    .contentTransition(.opacity)
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 58)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(.white.opacity(0.4), lineWidth: 1))
        .contentShape(Capsule())
        .onLongPressGesture(minimumDuration: duracion, maximumDistance: 40) {
            completado = true
            accion()
        } onPressingChanged: { activo in
            presionando = activo
            if activo {
                withAnimation(.linear(duration: duracion)) { progreso = 1 }
            } else if !completado {
                withAnimation(.spring(duration: 0.35)) { progreso = 0 }
            }
        }
        .sensoryFeedback(.impact(weight: .light), trigger: presionando)
        .sensoryFeedback(.success, trigger: completado)
        // VoiceOver: se puede activar directamente.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(titulo)
        .accessibilityHint("Mantén presionado para confirmar")
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { accion() }
    }
}
