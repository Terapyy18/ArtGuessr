import Foundation

struct ArtWork: Identifiable, Codable {
    let id: Int
    let image: URL
    let name: String
    let year: Date
    let artist: String
    
    enum CodingKeys: String, CodingKey {
        case id = "objectID"
        case image = "primaryImage"
        case name = "title"
        case year = "objectBeginDate"
        case artist = "artistDisplayName"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        
        // On récupère l'URL de l'image (l'API renvoie une String)
        let imageString = try container.decode(String.self, forKey: .image)
        self.image = URL(string: imageString) ?? URL(string: "https://via.placeholder.com/150")!
        
        self.name = try container.decode(String.self, forKey: .name)
        self.year = try container.decode(Int.self, forKey: .year)
        self.artist = try container.decode(String.self, forKey: .artist)
    }
    
    // Pour satisfaire Encodable (si tu as besoin d'exporter l'objet en JSON)
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(image.absoluteString, forKey: .image)
        try container.encode(name, forKey: .name)
        try container.encode(year, forKey: .year)
        try container.encode(artist, forKey: .artist)
    }
}
