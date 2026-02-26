import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
                .tag(0)
            
            GameView()
                .tabItem {
                    Label("Jeu", systemImage: "play.fill")
                }
                .tag(1)
            
            ScoreboardView()
                .tabItem {
                    Label("Scores", systemImage: "trophy.fill")
                }
                .tag(2)
        }
        .accentColor(.indigo)
    }
}
