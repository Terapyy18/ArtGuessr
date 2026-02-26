import Observation
import SwiftData

@Observable
@MainActor
class Game: GameInterface {
    // --- Propriétés de Score et État ---
    static let nbRounds: Int = 10
    var isGameOver: Bool = false
    var currentScore: Int = 0
    var currentRound: Int = 0
    
    // --- Données du tour actuel ---
    var currentArtwork: ArtWork? = nil
    var currentOptions: [ArtWork] = []
    
    // --- RÉSERVE DE DONNÉES (La modif est ici) ---
    // On stocke les objets ArtWork déjà téléchargés et validés
    private var artworksPool: [ArtWork] = []
    
    var context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Logique de démarrage
    func startGame() async {
        // 1. Nettoyage des anciens IDs si nécessaire
        try? context.delete(model: ArtworkIds.self)
        try? context.save()
        
        // 2. Récupération des IDs initiaux (via ton API Service actuel)
        await APIService.fetchAndStore50IDs(context: self.context)
        
        // 3. Récupération de la liste des IDs stockés
        let descriptor = FetchDescriptor<ArtworkIds>()
        guard let storedIds = try? context.fetch(descriptor) else { return }
        let idsToFetch = storedIds.map { $0.id }.shuffled()
        
        print("Démarrage du téléchargement massif...")
        self.artworksPool = await APIService.getAllPaintingsAtOnce(ids: Array(idsToFetch.prefix(30)))
        print("Pool prêt avec \(artworksPool.count) œuvres valides.")
        
        // 5. Lancement du premier tour
        await loadNextRound()
    }
    
    // MARK: - Logique de Round
    func loadNextRound() async {
        print("Passage au tour suivant...")
        
        // Vérifie si on a fini le nombre de rounds ou si le pool est vide
        if currentRound >= Game.nbRounds || artworksPool.count < 3 {
            self.isGameOver = true
            return
        }
        
        // PIOCHE LOCALE (Plus de 'await' réseau ici !)
        // On prend les 3 premières œuvres de notre réserve
        let roundArtworks = Array(artworksPool.prefix(3))
        artworksPool.removeFirst(3) // On les retire de la réserve
        
        // Mise à jour de l'interface (Instantané)
        self.currentRound += 1
        self.currentArtwork = roundArtworks[0]
        self.currentOptions = roundArtworks.shuffled()
    }
    
    // MARK: - Validation
    func getAwnsers(userAwnser: userChoice) -> Int? {
        guard let artwork = currentArtwork else { return nil }
        
        var tempScore = 0
        if userAwnser.name == artwork.name { tempScore += 1 }
        if userAwnser.artist == artwork.artist { tempScore += 1 }
        if userAwnser.year == artwork.year { tempScore += 1 }
        
        currentScore += tempScore
        return tempScore
    }
    
    // Méthodes d'interface non utilisées ici
    func checkAnswers(title: String, artist: String, year: Int) -> Int { return 0 }
    func gameCycle() {}
}
