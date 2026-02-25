struct Game: Identifiable, Decodable, Sendable {
    let id: Int
}

class Game : GameInterface {
    
    static let nbRounds : Int = 10
    
    var isGameOver : Bool = false
    var currentScore: Int = 0
    
    var currentArtwork: ArtWork? = nil
    var currentOptions: [ArtWork] = []
    
    var userChoice : UserChoice? = nil
        
    init(){}
    
    func startGame() async {
        // TODO : Récupérer tous les ids stockés dans SwiftData
        // Mettre les indexes et score à 0
        
        // APIService.fetchAndStore50ID()
        
    }
    
    func loadNextRound() async throws {
        // TODO : Fetch l'API avec trois ids random de allids
        // Choisir qui sera la main, et qui seront les options
        // Mettre tout ça dans les variables correpsondantes
        // Augmenter l'index de 1
        
        // APiService
    }
    
    func checkAnswers(title: String, artist: String, year: Int) -> Int {
        var tempScore: Int = 0
        
        if let artwork = currentArtwork, let choice = userChoice {
            
            if choice.name == artwork.name {
                tempScore += 1
            }
            
            if choice.artist == artwork.artist {
                tempScore += 1
            }
            
            if choice.year == artwork.year {
                tempScore += 1
            }
        }
        
        return tempScore
    }
    
    
    func gameCycle(){
        // TODO : gérer le lancement de chaque fonction au bon moment et gérer le nombre de rounds
    }
    
    struct UserChoice {
        var name : String
        var artist : String
        var year : Date
    }
    
}
