protocol GameInterface {
    func startGame() async
    
    func loadNextRound() async throws
    func checkAnswers(title: String, artist: String, year: Int) -> Int
    
    var isGameOver: Bool { get }
    var currentScore: Int { get }
    
    var currentArtwork : ArtWork? {get set}
    var currentOptions :[ArtWork] {get set}
    
    
    // func saveResult() // Pour SwiftData
}
