import SwiftUI
import SwiftData
import Combine

enum GameStep {
    case artist, title, year
}

@MainActor
class GameViewModel: ObservableObject {
    // L'instance de ton jeu (le modèle de données profond)
    @Published var gameInstance: Game?
    
    // Les états du flux
    @Published var currentStep: GameStep = .artist
    @Published var selectedArtist: String = ""
    @Published var selectedTitle: String = ""
    @Published var selectedYear: Int = 0
    
    // Les états de la popup
    @Published var showScorePopup = false
    @Published var pointsGainedInRound = 0
    
    // MARK: - Propriétés calculées pour alléger la vue
    var isGameOver: Bool { gameInstance?.isGameOver ?? false }
    var currentScore: Int { gameInstance?.currentScore ?? 0 }
    var currentRound: Int { gameInstance?.currentRound ?? 1 }
    var currentArtwork: ArtWork? { gameInstance?.currentArtwork }
    var currentOptions: [ArtWork] { gameInstance?.currentOptions ?? [] }
    
    var questionText: String {
        switch currentStep {
        case .artist: return "Qui est l'artiste ?"
        case .title: return "Quel est le titre de l'œuvre ?"
        case .year: return "En quelle année a-t-elle été créée ?"
        }
    }
    
    func buttonLabel(for option: ArtWork) -> String {
        switch currentStep {
        case .artist: return option.artist
        case .title: return option.name
        case .year: return "\(option.year)"
        }
    }
    
    // Le tableau dynamique pour ta ScoreView
    var scoreDetails: [(question: String, userAnswer: String, isCorrect: Bool, correctAnswer: String)] {
        guard let artwork = currentArtwork else { return [] }
        return [
            ("Artiste", selectedArtist, selectedArtist == artwork.artist, artwork.artist),
            ("Titre", selectedTitle, selectedTitle == artwork.name, artwork.name),
            ("Année", String(selectedYear), selectedYear == artwork.year, String(artwork.year))
        ]
    }
    
    // MARK: - Logique métier
    
    func setupGame(context: ModelContext) {
        if gameInstance == nil {
            let newGame = Game(context: context)
            self.gameInstance = newGame
            Task {
                await newGame.startGame()
            }
        }
    }
    
    func handleUserSelection(for option: ArtWork) {
        switch currentStep {
        case .artist:
            selectedArtist = option.artist
            currentStep = .title
        case .title:
            selectedTitle = option.name
            currentStep = .year
        case .year:
            selectedYear = option.year
            // J'utilise ta syntaxe exacte comme demandé
            let finalChoice = userChoice(
                name: selectedTitle,
                artist: selectedArtist,
                year: selectedYear
            )
            
            if let score = gameInstance?.getAwnsers(userAwnser: finalChoice) {
                self.pointsGainedInRound = score
            }
            showScorePopup = true
        }
    }
    
    func dismissPopup() {
        showScorePopup = false
        currentStep = .artist
        selectedArtist = ""
        selectedTitle = ""
        selectedYear = 0
        
        Task {
            try? await gameInstance?.loadNextRound()
        }
    }
    
    func saveScoreAndRestart(context: ModelContext) {
        let newScoreRecord = GameScore(score: currentScore, maxScore: 10, date: .now)
        context.insert(newScoreRecord)
        
        currentStep = .artist
        selectedArtist = ""
        selectedTitle = ""
        selectedYear = 0
        gameInstance = nil
        setupGame(context: context)
    }
}
