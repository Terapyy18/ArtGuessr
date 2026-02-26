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
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: ArtworkIds.self, GameScore.self,
        configurations: config
    )
    
    GameView()
        .modelContainer(container)
}
