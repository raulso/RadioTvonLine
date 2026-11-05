# RadioTV OnLine — Proyecto final Módulo 9

App de iOS (SwiftUI, iOS 17+, sin librerías externas) que reproduce radio y TV por internet con inicio de sesión.

## Usuario de prueba
- Usuario: `raul`
- Contraseña: `radio2026`

(Se cambian en `Services/AuthManager.swift`.)

## Configurar la API key (obligatorio para la radio)
1. Copia `Secrets.example.plist` (raíz del proyecto) dentro de la carpeta `RadioTVOnLineApp/`.
2. Renómbralo a `Secrets.plist` y reemplaza `TU_CLAVE` por tu clave de RapidAPI.
3. `Secrets.plist` está en `.gitignore`: no se sube ni se entrega. Sin él, la pestaña Radio muestra un aviso en lugar de fallar.

## Arquitectura (MVVM)
- **Models**: `Canal`, `EstacionRadio`, `RadioAPIRespuesta` (JSON de la API), `EstadoCarga` / `EstadoReproduccion`.
- **Services**: `AuthManager` + `KeychainManager` (sesión en Keychain), `RadioManager` (RapidAPI), `TVManager` + `M3UParser` (lista M3U), `StreamPlayerManager` (AVPlayer + AVAudioSession `.playback`), `ConfiguracionAPI` (lee la clave).
- **ViewModels** (`@MainActor @Observable`): `SesionViewModel`, `RadioListaViewModel`, `TVListaViewModel`, `ReproductorAudioViewModel`, `ReproductorVideoViewModel`.
- **Views**: `LoginView`, `RaizView` (pestañas), `RadioListaView`, `TVListaView`, `ReproductorAudioView`, `ReproductorVideoView` (`VideoPlayer` de AVKit), `PerfilView` (cerrar sesión).

Flujo: View → ViewModel → Manager. Las vistas nunca llaman a un Manager.

## Requisitos cubiertos
1. Login con usuario fijo y mensaje de error.
2. Sesión guardada en Keychain (no se guarda contraseña); solo termina con "Cerrar sesión".
3. Lista de radio desde RapidAPI (nombre + género · país), descargada una vez por pantalla.
4. Lista de TV desde `https://iptv-org.github.io/iptv/countries/mx.m3u`.
5. Reproductor de audio con pausa / reanudar.
6. Reproductor de video con `VideoPlayer`.
7. Avisos de contenido no disponible: lista vacía, error de red y stream que falla (se detecta con `AVPlayerItem.status` y un límite de 20 s).
- Al salir de un reproductor (`.onDisappear`) se detiene y libera el stream.
- `Allow Arbitrary Loads for Media = YES` en `RadioTVOnLineApp-Info.plist` (ya configurado en el target).

## Identidad visual y detalles propios
- Fondo principal en degradado rojo en todas las pantallas (login, listas, reproductores y perfil); barra de pestañas roja oscura.
- Cerrar sesión con **"Mantén presionado para salir"**: una barra se llena durante 1.5 s y el teléfono vibra al confirmar (evita salir por accidente). Con VoiceOver se activa directamente.
- El perfil muestra una tarjeta con la inicial del usuario y cuánto tiempo lleva conectado (la hora de inicio también se guarda en el Keychain).
- Si la contraseña es incorrecta, el formulario se sacude y el teléfono vibra.
- Reproductor de radio con disco translúcido y ondas animadas.

## Extras
- Buscador en radio (nombre, género o país) y en TV (nombre o categoría) con `.searchable`.
- Pantallas de carga y error cuidadas, logos remotos y deslizar para actualizar.
