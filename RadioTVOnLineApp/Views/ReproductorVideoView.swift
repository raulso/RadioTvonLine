import SwiftUI
import AVKit

/// Reproductor de TV: video, nombre del canal, estado y controles.
struct ReproductorVideoView: View {
    @State private var viewModel: ReproductorVideoViewModel

    init(canal: Canal) {
        _viewModel = State(initialValue: ReproductorVideoViewModel(canal: canal))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                pantalla

                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.canal.nombre)
                        .font(.title2.bold())
                    Text(viewModel.canal.categoria)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.75))
                    EtiquetaEstado(estado: viewModel.estado)
                        .padding(.top, 4)
                }
                .padding(.horizontal)

                controles
                    .padding(.horizontal)
            }
        }
        .foregroundStyle(.white)
        .background { FondoRojoView() }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle("Televisión")
        .navigationBarTitleDisplayMode(.inline)
        .task { viewModel.iniciar() }          // El canal empieza a verse al abrir.
        .onDisappear { viewModel.detener() }   // Se detiene al salir.
    }

    @ViewBuilder
    private var pantalla: some View {
        ZStack {
            Color.black

            if case .noDisponible(let mensaje) = viewModel.estado {
                // Aviso claro cuando el canal está caído o restringido.
                AvisoContenidoView(
                    titulo: "Canal no disponible",
                    icono: "tv.slash",
                    mensaje: mensaje,
                    accion: viewModel.reintentar
                )
                .environment(\.colorScheme, .dark)
            } else {
                VideoPlayer(player: viewModel.player)

                if viewModel.estado == .cargando {
                    ProgressView()
                        .controlSize(.large)
                        .tint(.white)
                }
            }
        }
        .aspectRatio(16 / 9, contentMode: .fit)
        .frame(minHeight: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.25), lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 18, y: 10)
        .padding([.horizontal, .top])
    }

    @ViewBuilder
    private var controles: some View {
        if viewModel.estado == .reproduciendo || viewModel.estado == .pausado {
            Button(action: viewModel.alternarPausa) {
                Label(
                    viewModel.estado == .reproduciendo ? "Pausar" : "Reanudar",
                    systemImage: viewModel.estado == .reproduciendo ? "pause.fill" : "play.fill"
                )
                .font(.headline)
                .foregroundStyle(Tema.primario)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
        }
    }
}

#Preview {
    NavigationStack {
        ReproductorVideoView(
            canal: Canal(
                id: "demo",
                nombre: "Canal de demostración",
                categoria: "Prueba HLS",
                url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
            )
        )
    }
}
