#  RadioTV OnLine

> App de iOS para escuchar radio y ver televisión en vivo por internet, con inicio de sesión.
> Proyecto final del **Módulo 9** del curso de Aplicaciones Móviles.

---

## 📑 Contenido

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Usuario de prueba](#-usuario-de-prueba)
- [Arquitectura](#-arquitectura)
- [Estructura del proyecto](#-estructura-del-proyecto)
- [Fuentes de datos](#-fuentes-de-datos)
- [Requisitos del proyecto cubiertos](#-requisitos-del-proyecto-cubiertos)
- [Problemas frecuentes](#-problemas-frecuentes)

---

##  Características

| | |
|---|---|
| **Login con usuario fijo** | Mensaje de error si los datos no coinciden; el formulario se sacude y el teléfono vibra. |
| **Sesión guardada** | Se almacena en el **Keychain**. Al reabrir la app no se pide login otra vez. |
| **Radio** | Estaciones desde la API *50k Radio Stations* (RapidAPI) con nombre, género y país. |
| **Televisión** | Canales de México leídos de una lista **M3U**. |
| **Reproductor de audio** | `AVPlayer` con pausa y reanudar; disco translúcido con ondas animadas. |
| **Reproductor de video** | `VideoPlayer` de AVKit. |
| **Contenido no disponible** | Avisos claros para lista vacía, error de red y stream caído, con botón *Reintentar*. |
| **Buscadores** | Filtra radio (nombre, género o país) y TV (nombre o categoría) mientras escribes. |
| **Diseño propio** | Fondo en degradado rojo en toda la app y barra de pestañas roja oscura. |
| **Cerrar sesión seguro** | Botón **"Mantén presionado para salir"**: una barra se llena en 1.5 s y vibra al confirmar. |
| **Perfil** | Tarjeta con la inicial del usuario, hora de inicio y tiempo conectado en vivo. |

---

##  Requisitos

- macOS con **Xcode 16** o superior
- **iOS 17.0** o superior (simulador o dispositivo; probado para iPhone 16)
- Cuenta gratuita en [RapidAPI](https://rapidapi.com) suscrita a **50k Radio Stations**
- Sin librerías externas: solo SwiftUI, AVFoundation, AVKit y Security

---

## Instalación

1. **Clona el repositorio**

   ```bash
   git clone https://github.com/TU_USUARIO/RadioTVOnLineApp.git
   cd RadioTVOnLineApp
   ```

2. **Configura tu API key** (necesaria para la pestaña Radio)

   ```bash
   cp Secrets.example.plist RadioTVOnLineApp/Secrets.plist
   ```

   Abre `RadioTVOnLineApp/Secrets.plist` y reemplaza `TU_CLAVE` por tu clave de RapidAPI:

   ```xml
   <key>RAPIDAPI_KEY</key>
   <string>TU_CLAVE</string>
   ```

   > `Secrets.plist` está en `.gitignore`: **nunca** se sube al repositorio.
   > Si falta, la app compila igual y la pestaña Radio muestra un aviso en lugar de fallar.

3. **Abre y ejecuta**

   ```bash
   open RadioTVOnLineApp.xcodeproj
   ```

---

##  Usuario de prueba

No hay registro: es el único usuario válido. Se cambia en `Services/AuthManager.swift`.

---

## Arquitectura

La app sigue **MVVM** con un flujo de una sola dirección:

```
View  ──►  ViewModel  ──►  Manager (Service)  ──►  Red / AVPlayer / Keychain
  ▲            │
  └── estado ──┘
```

- Las **vistas nunca llaman a un Manager** directamente.
- Los **ViewModels** usan `@MainActor` y `@Observable`, se guardan en la vista con `@State`, usan `@Bindable` para los campos que escriben (login y buscadores) y `private(set)` para el estado que solo ellos cambian.
- La **red** usa `URLSession` con `async/await` y la descarga se lanza con `.task`.
- El **audio** usa `AVPlayer` y `AVAudioSession` con la categoría `.playback`.
- Los fallos del stream se detectan con `AVPlayerItem.status`, la notificación `failedToPlayToEndTime` y un límite de 20 s, así que la app nunca se queda cargando para siempre.

---

## 🗂️ Estructura del proyecto

```
RadioTVOnLineApp/
├── RadioTVOnLineApp.xcodeproj
├── RadioTVOnLineApp-Info.plist       # ATS: Allow Arbitrary Loads for Media
├── Secrets.example.plist             # Plantilla de la API key
└── RadioTVOnLineApp/
    ├── RadioTVOnLineApp.swift        # Punto de entrada (@main)
    ├── Secrets.plist                 # Tu API key (ignorado por git)
    ├── Models/
    │   ├── Canal.swift
    │   ├── EstacionRadio.swift
    │   ├── RadioAPIRespuesta.swift   # JSON de RapidAPI
    │   └── EstadoCarga.swift         # EstadoCarga / EstadoReproduccion
    ├── Services/
    │   ├── AuthManager.swift         # Usuario fijo y sesión
    │   ├── KeychainManager.swift     # Guardado seguro
    │   ├── ConfiguracionAPI.swift    # Lee la API key
    │   ├── RadioManager.swift        # Petición a RapidAPI
    │   ├── TVManager.swift           # Descarga de la lista M3U
    │   ├── M3UParser.swift           # Texto M3U → [Canal]
    │   └── StreamPlayerManager.swift # AVPlayer + AVAudioSession
    ├── ViewModels/
    │   ├── SesionViewModel.swift
    │   ├── RadioListaViewModel.swift
    │   ├── TVListaViewModel.swift
    │   ├── ReproductorAudioViewModel.swift
    │   └── ReproductorVideoViewModel.swift
    └── Views/
        ├── LoginView.swift
        ├── RaizView.swift            # Login o pestañas según la sesión
        ├── RadioListaView.swift
        ├── TVListaView.swift
        ├── ReproductorAudioView.swift
        ├── ReproductorVideoView.swift
        ├── PerfilView.swift          # Cerrar sesión
        └── Componentes/
            ├── Tema.swift            # Colores y fondo rojo
            ├── BotonMantenerView.swift
            ├── EstadosVista.swift    # Carga y avisos
            └── Filas.swift
```

---

## Fuentes de datos

**Radio — 50k Radio Stations (RapidAPI)**

```http
GET https://50k-radio-stations.p.rapidapi.com/radios/random?limit=20
x-rapidapi-host: 50k-radio-stations.p.rapidapi.com
x-rapidapi-key: TU_CLAVE
```

Las estaciones vienen en `data`. La URL de audio se elige de la lista `streams`, priorizando las que funcionan, usan HTTPS, tienen un códec compatible y mayor bitrate. La lista se descarga una vez por pantalla para cuidar el límite del plan gratuito, y se puede actualizar deslizando hacia abajo.

**Televisión — iptv-org**

```
https://iptv-org.github.io/iptv/countries/mx.m3u
```

Cada canal ocupa dos líneas: `#EXTINF` (con el nombre después de la última coma) y la URL del stream. Algunos canales están caídos o restringidos; en ese caso la app muestra el aviso de contenido no disponible.

---

## 🛠️ Problemas frecuentes

| Síntoma | Qué revisar |
|---|---|
| La radio muestra "Falta la API key" | Que exista `RadioTVOnLineApp/Secrets.plist` con tu clave. |
| Error HTTP 401 / 403 | Clave incorrecta o suscripción inactiva en RapidAPI. |
| Error HTTP 429 | Se agotó el límite de peticiones del plan gratuito; espera un rato. |
| Una estación o canal no se reproduce | El stream está caído o restringido; es normal en estas fuentes. Prueba otro. |
| No se pide login al abrir la app | La sesión sigue activa en el Keychain; ciérrala desde **Perfil**. |

---
