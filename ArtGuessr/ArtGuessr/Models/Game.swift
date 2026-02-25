import Foundation
import SwiftData

struct GameRecord: Identifiable, Decodable, Sendable {
    let id: Int
}

class Game: GameInterface {
    
    static let nbRounds: Int = 10
    
    var isGameOver: Bool = false
    var currentScore: Int = 0
    var currentRound: Int = 0
    
    var currentArtwork: ArtWork? = nil
    var currentOptions: [ArtWork] = []
    
    // Liste des IDs disponibles pour la partie en cours afin d'éviter les répétitions
    private var sessionIds: [Int] = []
    
    var userChoice: UserChoice? = nil
    
    var context: ModelContext
        
    init(context: ModelContext) {
        self.context = context
    }
    
    func startGame() async {
        // 1. Réinitialisation de l'état du jeu
        self.currentScore = 0
        self.currentRound = 0
        self.isGameOver = false
        
        // 2. Nettoyage des anciens IDs dans SwiftData pour éviter les doublons
        do {
            try context.delete(model: ArtworkIds.self)
            try context.save()
        } catch {
            print("Erreur lors du nettoyage des IDs : \(error)")
        }
        
        // 3. Récupération de nouveaux IDs (50 comme défini dans APIService)
        await APIService.fetchAndStore50IDs(context: self.context)
        
        // 4. Préparation de la liste d'IDs pour cette session
        let descriptor = FetchDescriptor<ArtworkIds>()
        if let storedIds = try? context.fetch(descriptor) {
            self.sessionIds = storedIds.map { $0.id }.shuffled()
        }
        
        // 5. Lancement du premier tour
        try? await loadNextRound()
    }
    
    func loadNextRound() async throws {
        // Vérifie si on a atteint la fin du quiz
        if currentRound >= Game.nbRounds {
            self.isGameOver = true
            return
        }
        
        // Vérifie qu'on a assez d'IDs restants (besoin de 3 pour les options)
        guard sessionIds.count >= 3 else {
            self.isGameOver = true
            return
        }
        
        // Pioche 3 IDs et les retire de la session
        let roundIds = Array(sessionIds.prefix(3))
        sessionIds.removeFirst(3)
        
        var fetchedArtworks: [ArtWork] = []
        for id in roundIds {
            if let artwork = await APIService.fetchById(id: id) {
                fetchedArtworks.append(artwork)
            }
        }
        
        // Validation et mise à jour de l'état
        if fetchedArtworks.count >= 3 {
            self.currentRound += 1
            self.currentArtwork = fetchedArtworks[0] // La première est la bonne réponse
            self.currentOptions = fetchedArtworks.shuffled() // Mélange pour l'affichage
        } else {
            // En cas d'échec réseau sur une œuvre, on tente de charger le tour suivant
            try await loadNextRound()
        }
    }
    
    func getRandomArtworkId() -> Int? {
        let descriptor = FetchDescriptor<ArtworkIds>()
        
        do {
            let allStoredArtworks = try context.fetch(descriptor)
            return allStoredArtworks.randomElement()?.id
            
        } catch {
            print("Erreur lors du fetch des IDs : \(error)")
            return nil
        }
    }
    
    func checkAnswers(title: String, artist: String, year: Int) -> Int {
        var pointsGagnes: Int = 0
        
        if let artwork = currentArtwork {
            if title == artwork.name { pointsGagnes += 1 }
            if artist == artwork.artist { pointsGagnes += 1 }
            if year == artwork.year { pointsGagnes += 1 }
        }
        
        // Mise à jour du score global
        self.currentScore += pointsGagnes
        
        // Si c'était le dernier tour, on termine la partie
        if currentRound >= Game.nbRounds {
            self.isGameOver = true
        }
        
        return pointsGagnes
    }
    
    func gameCycle() {}
    
    struct UserChoice {
        var name: String
        var artist: String
        var year: Int
    }
}
