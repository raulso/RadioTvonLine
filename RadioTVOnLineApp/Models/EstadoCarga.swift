import Foundation

/// Estado de una lista que se descarga de internet.
/// Garantiza que la pantalla siempre muestre algo: cargando, datos, vacío o error.
enum EstadoCarga<Elemento> {
    case inactivo
    case cargando
    case cargado([Elemento])
    case vacio
    case error(String)
}

/// Estado de un reproductor de audio o video.
enum EstadoReproduccion: Equatable {
    case cargando
    case reproduciendo
    case pausado
    case noDisponible(String)
}
