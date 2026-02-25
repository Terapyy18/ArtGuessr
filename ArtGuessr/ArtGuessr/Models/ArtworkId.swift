import SwiftData

@Model class ArtworkIds{
    @Attribute(.unique) var id : Int
    
    init(id : Int){
        self.id = id
    }
}
