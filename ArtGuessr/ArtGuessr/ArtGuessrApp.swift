import SwiftUI
import SwiftData

@main
struct ArtGuessrApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(for: ArtworkIds.self)
    }
}

#Preview{
    MainTabView()
}
