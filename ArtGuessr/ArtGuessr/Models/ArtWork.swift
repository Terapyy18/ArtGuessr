import Foundation

struct ArtWork: Identifiable, Decodable, Sendable {
    let id: Int
    let image: URL
    let name: String
    let year: Int // CHANGEMENT : Date -> Int pour correspondre à l'API
    let artist: String
    
    enum CodingKeys: String, CodingKey {
        case id = "objectID"
        case image = "primaryImageSmall" // "Small" est plus rapide à charger pour un jeu
        case name = "title"
        case year = "objectBeginDate"
        case artist = "artistDisplayName"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 1. ID (Obligatoire)
        self.id = try container.decode(Int.self, forKey: .id)
        
        // 2. Image avec Fallback (Sécurisé)
        let imageString = try container.decodeIfPresent(String.self, forKey: .image) ?? ""
        self.image = URL(string: imageString) ?? URL(string: "https://via.placeholder.com/150")!
        
        // 3. Texte avec Fallback (Sécurisé)
        self.name = try container.decodeIfPresent(String.self, forKey: .name) ?? "Titre inconnu"
        self.artist = try container.decodeIfPresent(String.self, forKey: .artist) ?? "Artiste inconnu"
        
        // 4. Année (Décodage en Int)
        self.year = try container.decodeIfPresent(Int.self, forKey: .year) ?? 0
    }
}
