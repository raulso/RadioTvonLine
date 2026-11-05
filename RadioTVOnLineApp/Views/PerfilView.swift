import SwiftUI

/// Pantalla del usuario: tarjeta de sesión y botón "mantén presionado para salir".
struct PerfilView: View {
    let sesion: SesionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    tarjetaUsuario
                    tarjetaFuentes

                    VStack(spacing: 10) {
                        BotonMantenerView(
                            titulo: "Mantén presionado para salir",
                            icono: "power"
                        ) {
                            withAnimation { sesion.cerrarSesion() }
                        }
                        Text("Así evitamos cerrar tu sesión por accidente.")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.top, 8)
                }
                .padding(20)
            }
            .fondoPrincipal()
            .navigationTitle("Mi perfil")
        }
    }

    /// Tarjeta tipo credencial con la inicial, el usuario y el tiempo de sesión.
    private var tarjetaUsuario: some View {
        VStack(spacing: 14) {
            
            HStack(spacing: 14){
                Text ("Bienvenido:")
                  .font(.title2.bold())
                Text(sesion.usuarioActivo ?? "Usuario")
                  .font(.title2.bold())
            }
            

            if let inicio = sesion.inicioSesion {
                VStack(spacing: 2) {
                    Text("Conectado desde \(inicio.formatted(date: .abbreviated, time: .shortened))")
                    // Se actualiza solo: "hace 5 min".
                    Text(inicio, style: .relative) + Text(" en línea")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(.white.opacity(0.2), lineWidth: 1))
    }

    private var tarjetaFuentes: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("FUENTES DE CONTENIDO")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.7))
            Label("Radio · 50k Radio Stations (RapidAPI)", systemImage: "radio")
            Label("TV · iptv-org México (M3U)", systemImage: "tv")
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 20))
    }
}
