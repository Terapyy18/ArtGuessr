struct ArtWork: Identifiable, Codable {
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
}
