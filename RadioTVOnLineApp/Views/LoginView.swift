import SwiftUI

/// Pantalla de inicio de sesión: usuario, contraseña y botón de entrar.
struct LoginView: View {
    @Bindable var sesion: SesionViewModel

    private enum Campo { case usuario, contrasena }
    @FocusState private var campoActivo: Campo?

    var body: some View {
        ZStack {
            FondoRojoView()

            ScrollView {
                VStack(spacing: 32) {
                    encabezado
                    formulario
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 56)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var encabezado: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 120, height: 120)
                Circle()
                    .stroke(.white.opacity(0.35), lineWidth: 2)
                    .frame(width: 150, height: 150)
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 56, weight: .semibold))
                    .symbolEffect(.variableColor.iterative.reversing)
            }
            Text("RadioTV OnLine")
                .font(.system(.largeTitle, design: .rounded, weight: .heavy))
            Text("Radio y televisión en vivo")
                .font(.subheadline)
                .opacity(0.85)
        }
        .foregroundStyle(.white)
    }

    private var formulario: some View {
        VStack(spacing: 16) {
            campo(icono: "person.fill") {
                TextField("Usuario", text: $sesion.usuario)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($campoActivo, equals: .usuario)
                    .submitLabel(.next)
                    .onSubmit { campoActivo = .contrasena }
            }

            campo(icono: "lock.fill") {
                SecureField("Contraseña", text: $sesion.contrasena)
                    .textContentType(.password)
                    .focused($campoActivo, equals: .contrasena)
                    .submitLabel(.go)
                    .onSubmit(entrar)
            }

            // Mensaje de error si las credenciales no coinciden.
            if let error = sesion.mensajeError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.yellow)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.opacity)
            }

            Button(action: entrar) {
                Text("Entrar")
                    .font(.headline)
                    .foregroundStyle(Tema.primario)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .tint(.white)
            .disabled(!sesion.puedeEntrar)
        }
        .padding(22)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 26))
        .overlay(RoundedRectangle(cornerRadius: 26).stroke(.white.opacity(0.25), lineWidth: 1))
        .animation(.default, value: sesion.mensajeError)
        // El formulario se "sacude" y vibra con cada intento fallido.
        .keyframeAnimator(initialValue: CGFloat(0), trigger: sesion.intentosFallidos) { contenido, desplazamiento in
            contenido.offset(x: desplazamiento)
        } keyframes: { _ in
            KeyframeTrack {
                LinearKeyframe(-14, duration: 0.07)
                LinearKeyframe(14, duration: 0.07)
                LinearKeyframe(-9, duration: 0.07)
                LinearKeyframe(9, duration: 0.07)
                LinearKeyframe(0, duration: 0.07)
            }
        }
        .sensoryFeedback(.error, trigger: sesion.intentosFallidos)
        // Al escribir de nuevo se oculta el error anterior.
        .onChange(of: sesion.usuario) { sesion.limpiarError() }
        .onChange(of: sesion.contrasena) { sesion.limpiarError() }
    }

    private func campo<Contenido: View>(icono: String, @ViewBuilder contenido: () -> Contenido) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icono)
                .foregroundStyle(Tema.rojoClaro)
                .frame(width: 20)
            contenido()
        }
        .padding(14)
        .background(.white.opacity(0.10), in: RoundedRectangle(cornerRadius: 14))
    }

    private func entrar() {
        guard sesion.puedeEntrar else { return }
        campoActivo = nil
        withAnimation { sesion.iniciarSesion() }
    }
}

#Preview {
    LoginView(sesion: SesionViewModel())
        .preferredColorScheme(.dark)
}
