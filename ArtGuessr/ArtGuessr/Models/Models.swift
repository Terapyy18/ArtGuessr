import Foundation
import SwiftData

struct ObjectIDsResponse: Codable {
    let objectIDs: [Int]
}

@Model class ArtworkIds {
    @Attribute(.unique) var id : Int
    
    init(id : Int){
        self.id = id
    }
}
