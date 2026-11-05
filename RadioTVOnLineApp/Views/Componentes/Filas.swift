import SwiftUI

/// Fila de la lista de radio: nombre y "género · país".
struct FilaEstacionView: View {
    let estacion: EstacionRadio

    var body: some View {
        HStack(spacing: 14) {
            LogoRemotoView(url: estacion.logoURL, iconoRespaldo: "radio", color: Tema.radio)

            VStack(alignment: .leading, spacing: 3) {
                Text(estacion.nombre)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text(estacion.detalle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            // Aviso visible si la API no trajo ninguna URL de audio.
            if estacion.streamURL == nil {
                Image(systemName: "speaker.slash")
                    .foregroundStyle(.white.opacity(0.75))
                    .accessibilityLabel("Sin audio disponible")
            }
        }
        .padding(.vertical, 4)
    }
}

/// Fila de la lista de TV: nombre y categoría.
struct FilaCanalView: View {
    let canal: Canal

    var body: some View {
        HStack(spacing: 14) {
            LogoRemotoView(url: canal.logoURL, iconoRespaldo: "tv", color: Tema.tv)

            VStack(alignment: .leading, spacing: 3) {
                Text(canal.nombre)
                    .font(.body.weight(.semibold))
                    .lineLimit(1)
                Text(canal.categoria)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}
