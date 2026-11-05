import SwiftUI

/// Reproductor de radio: nombre de la estación, estado y controles.
struct ReproductorAudioView: View {
    @State private var viewModel: ReproductorAudioViewModel

    init(estacion: EstacionRadio) {
        _viewModel = State(initialValue: ReproductorAudioViewModel(estacion: estacion))
    }

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            portada

            VStack(spacing: 8) {
                Text(viewModel.estacion.nombre)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                Text(viewModel.estacion.detalle)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
                EtiquetaEstado(estado: viewModel.estado)
                    .padding(.top, 4)
            }
            .padding(.horizontal)

            controles

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.white)
        .background { FondoRojoView() }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("Radio")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.iniciar() }          // Empieza a sonar al abrir.
        .onDisappear { viewModel.detener() }   // Se detiene al salir.
    }

    private var portada: some View {
        ZStack {
            // Disco translúcido con anillos, distinto a una portada cuadrada.
            Circle()
                .stroke(.white.opacity(0.18), lineWidth: 1)
                .frame(width: 270, height: 270)
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 230, height: 230)
                .overlay(Circle().stroke(.white.opacity(0.35), lineWidth: 2))
                .shadow(color: .black.opacity(0.35), radius: 24, y: 12)

            if let logo = viewModel.estacion.logoURL {
                LogoRemotoView(url: logo, iconoRespaldo: "radio", color: .white, tamano: 140)
            } else {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 80, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.variableColor.iterative, isActive: viewModel.estaSonando)
            }
        }
    }

    @ViewBuilder
    private var controles: some View {
        switch viewModel.estado {
        case .cargando:
            ProgressView("Conectando con la estación…")
                .tint(.white)
                .frame(height: 80)

        case .noDisponible(let mensaje):
            AvisoContenidoView(
                titulo: "Estación no disponible",
                icono: "speaker.slash.fill",
                mensaje: mensaje,
                accion: viewModel.reintentar
            )
            .frame(maxHeight: 260)

        case .reproduciendo, .pausado:
            Button(action: viewModel.alternarPausa) {
                Image(systemName: viewModel.estaSonando ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 84))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 6)
                    .contentTransition(.symbolEffect(.replace))
            }
            .accessibilityLabel(viewModel.estaSonando ? "Pausar" : "Reanudar")
        }
    }
}

#Preview {
    NavigationStack {
        ReproductorAudioView(
            estacion: EstacionRadio(
                id: "demo",
                nombre: "Radio Paradise",
                genero: "Rock",
                pais: "Estados Unidos",
                streamURL: URL(string: "https://stream.radioparadise.com/aac-320")
            )
        )
    }
}
