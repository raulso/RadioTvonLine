import SwiftUI

/// Lista de estaciones de radio descargadas de RapidAPI.
struct RadioListaView: View {
    @State private var viewModel = RadioListaViewModel()

    var body: some View {
        NavigationStack {
            contenido
                .fondoPrincipal()
                .navigationTitle("Radio")
                .navigationDestination(for: EstacionRadio.self) { estacion in
                    ReproductorAudioView(estacion: estacion)
                }
        }
        // Se descarga una sola vez por pantalla (no en cada redibujado).
        .task { await viewModel.cargarSiHaceFalta() }
    }

    @ViewBuilder
    private var contenido: some View {
        switch viewModel.estado {
        case .inactivo, .cargando:
            CargandoView(mensaje: "Buscando estaciones…")
        case .vacio:
            AvisoContenidoView(
                titulo: "Sin estaciones",
                icono: "radio",
                mensaje: "La API no devolvió estaciones en este momento.",
                accion: recargar
            )
        case .error(let mensaje):
            AvisoContenidoView(
                titulo: "No se pudo cargar la radio",
                icono: "wifi.exclamationmark",
                mensaje: mensaje,
                accion: recargar
            )
        case .cargado:
            ListaEstaciones(viewModel: viewModel)
        }
    }

    private func recargar() {
        Task { await viewModel.cargar() }
    }
}

/// Lista con buscador. Usa @Bindable porque el buscador escribe en el ViewModel.
private struct ListaEstaciones: View {
    @Bindable var viewModel: RadioListaViewModel

    var body: some View {
        List(viewModel.estacionesFiltradas) { estacion in
            NavigationLink(value: estacion) {
                FilaEstacionView(estacion: estacion)
            }
            .filaTranslucida()
        }
        .overlay {
            if viewModel.estacionesFiltradas.isEmpty {
                ContentUnavailableView.search(text: viewModel.busqueda)
            }
        }
        .searchable(text: $viewModel.busqueda, prompt: "Buscar por nombre, género o país")
        .refreshable { await viewModel.cargar() } // Desliza hacia abajo para traer otras estaciones.
    }
}

#Preview {
    RadioListaView()
}
