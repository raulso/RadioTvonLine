import Foundation

// Modelos que reflejan el JSON de "50k Radio Stations" (RapidAPI).
// Todos los campos son opcionales y tolerantes: si la API omite o cambia
// un dato, la estación se sigue leyendo en lugar de fallar toda la lista.

struct RadioAPIRespuesta: Decodable {
    let data: [RadioAPIEstacion]
}

struct RadioAPIEstacion: Decodable {
    let id: String?
    let name: String?
    let genre: RadioAPITexto?
    let location: RadioAPIUbicacion?
    let streams: [RadioAPIStream]
    let logo: String?

    enum CodingKeys: String, CodingKey {
        case id, _id, name, genre, location, streams, logo, image
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = c.cadenaFlexible(.id) ?? c.cadenaFlexible(._id)
        name = try? c.decodeIfPresent(String.self, forKey: .name)
        genre = try? c.decodeIfPresent(RadioAPITexto.self, forKey: .genre)
        location = try? c.decodeIfPresent(RadioAPIUbicacion.self, forKey: .location)
        streams = (try? c.decodeIfPresent([RadioAPIStream].self, forKey: .streams)) ?? []
        logo = (try? c.decodeIfPresent(String.self, forKey: .logo))
            ?? (try? c.decodeIfPresent(String.self, forKey: .image))
    }
}

/// `genre` llega como objeto con `text`; si llegara como texto plano también se acepta.
struct RadioAPITexto: Decodable {
    let text: String?

    enum CodingKeys: String, CodingKey { case text }

    init(from decoder: Decoder) throws {
        if let valor = try? decoder.singleValueContainer().decode(String.self) {
            text = valor
        } else {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            text = try? c.decodeIfPresent(String.self, forKey: .text)
        }
    }
}

struct RadioAPIUbicacion: Decodable {
    let countryName: String?
}

struct RadioAPIStream: Decodable {
    let url: String?
    let isHttps: Bool?
    let codec: String?
    let bitrate: Int?
    let works: Bool?

    enum CodingKeys: String, CodingKey { case url, isHttps, codec, bitrate, works }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        url = try? c.decodeIfPresent(String.self, forKey: .url)
        isHttps = c.boolFlexible(.isHttps)
        codec = try? c.decodeIfPresent(String.self, forKey: .codec)
        bitrate = c.enteroFlexible(.bitrate)
        works = c.boolFlexible(.works)
    }
}

// MARK: - Ayudas de decodificación (números o textos según venga la API)

private extension KeyedDecodingContainer {
    func cadenaFlexible(_ key: Key) -> String? {
        if let s = try? decodeIfPresent(String.self, forKey: key) { return s }
        if let n = try? decodeIfPresent(Int.self, forKey: key) { return String(n) }
        return nil
    }

    func enteroFlexible(_ key: Key) -> Int? {
        if let n = try? decodeIfPresent(Int.self, forKey: key) { return n }
        if let s = try? decodeIfPresent(String.self, forKey: key) { return Int(s) }
        return nil
    }

    func boolFlexible(_ key: Key) -> Bool? {
        if let b = try? decodeIfPresent(Bool.self, forKey: key) { return b }
        if let n = try? decodeIfPresent(Int.self, forKey: key) { return n != 0 }
        if let s = try? decodeIfPresent(String.self, forKey: key) {
            return ["true", "1", "yes"].contains(s.lowercased())
        }
        return nil
    }
}
