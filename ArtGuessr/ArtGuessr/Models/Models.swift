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
@Model
class GameScore {
    var score: Int
    var maxScore: Int
    var date: Date
    
    init(score: Int, maxScore: Int = 10, date: Date = .now) {
        self.score = score
        self.maxScore = maxScore
        self.date = date
    }
}
