import SwiftUI
import SwiftData

@main
struct ArtGuessrApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: [ArtworkIds.self, GameScore.self])    }
}

#Preview {
    // Création d'un container de test en mémoire
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: ArtworkIds.self, configurations: config)
    
    MainTabView()
        .modelContainer(container)
    
}
