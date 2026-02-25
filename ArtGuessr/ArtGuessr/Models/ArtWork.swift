import Foundation

struct ArtWork: Identifiable, Decodable, Sendable {
    let id: Int
    let image: URL
    let name: String
    let year: Int
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
        
        // Ton mapping custom est justifié ici pour gérer la fallback URL
        let imageString = try container.decode(String.self, forKey: .image)
        self.image = URL(string: imageString) ?? URL(string: "https://via.placeholder.com/150")!
        
        self.name = try container.decode(String.self, forKey: .name)
        self.year = try container.decode(Int.self, forKey: .year)
        self.artist = try container.decode(String.self, forKey: .artist)
    }
}
