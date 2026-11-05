import SwiftUI

/// Pantalla de carga con mensaje (nunca se deja la pantalla en blanco).
struct CargandoView: View {
    let mensaje: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
                .tint(.white)
            Text(mensaje)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Aviso de contenido no disponible (lista vacía, error de red o stream caído),
/// con un botón opcional para reintentar.
struct AvisoContenidoView: View {
    let titulo: String
    let icono: String
    let mensaje: String
    var tituloAccion: String = "Reintentar"
    var accion: (@MainActor () -> Void)? = nil

    var body: some View {
        ContentUnavailableView {
            Label(titulo, systemImage: icono)
                .foregroundStyle(.white)
        } description: {
            Text(mensaje)
                .foregroundStyle(.white.opacity(0.85))
        } actions: {
            if let accion {
                Button(action: accion) {
                    Label(tituloAccion, systemImage: "arrow.clockwise")
                        .foregroundStyle(Tema.primario)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(.white)
            }
        }
    }
}

/// Logo descargado de internet con un ícono de respaldo si no existe o falla.
struct LogoRemotoView: View {
    let url: URL?
    let iconoRespaldo: String
    let color: Color
    var tamano: CGFloat = 44

    var body: some View {
        AsyncImage(url: url) { fase in
            if let imagen = fase.image {
                imagen
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            } else {
                Image(systemName: iconoRespaldo)
                    .font(.system(size: tamano * 0.45, weight: .semibold))
                    .foregroundStyle(color)
            }
        }
        .frame(width: tamano, height: tamano)
        .background(.black.opacity(0.2), in: RoundedRectangle(cornerRadius: tamano * 0.25))
        .clipShape(RoundedRectangle(cornerRadius: tamano * 0.25))
    }
}
