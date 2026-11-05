import SwiftUI

/// Lista de canales de TV leídos de la lista M3U.
struct TVListaView: View {
    @State private var viewModel = TVListaViewModel()

    var body: some View {
        NavigationStack {
            contenido
                .fondoPrincipal()
                .navigationTitle("Televisión")
                .navigationDestination(for: Canal.self) { canal in
                    ReproductorVideoView(canal: canal)
                }
        }
        .task { await viewModel.cargarSiHaceFalta() }
    }

    @ViewBuilder
    private var contenido: some View {
        switch viewModel.estado {
        case .inactivo, .cargando:
            CargandoView(mensaje: "Descargando canales…")
        case .vacio:
            AvisoContenidoView(
                titulo: "Sin canales",
                icono: "tv",
                mensaje: "La lista M3U no contiene canales disponibles.",
                accion: recargar
            )
        case .error(let mensaje):
            AvisoContenidoView(
                titulo: "No se pudo cargar la TV",
                icono: "wifi.exclamationmark",
                mensaje: mensaje,
                accion: recargar
            )
        case .cargado:
            ListaCanales(viewModel: viewModel)
        }
    }

    private func recargar() {
        Task { await viewModel.cargar() }
    }
}

private struct ListaCanales: View {
    @Bindable var viewModel: TVListaViewModel

    var body: some View {
        List(viewModel.canalesFiltrados) { canal in
            NavigationLink(value: canal) {
                FilaCanalView(canal: canal)
            }
            .filaTranslucida()
        }
        .overlay {
            if viewModel.canalesFiltrados.isEmpty {
                ContentUnavailableView.search(text: viewModel.busqueda)
            }
        }
        .searchable(text: $viewModel.busqueda, prompt: "Buscar canal o categoría")
        .refreshable { await viewModel.cargar() }
    }
}

#Preview {
    TVListaView()
}
