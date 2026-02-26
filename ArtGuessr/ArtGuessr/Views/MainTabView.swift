import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house.fill")
                }
            
            GameView()
                .tabItem {
                    Label("Jouer", systemImage: "paintpalette.fill")
                }
            
            ScoreboardView()
                .tabItem {
                    Label("Scores", systemImage: "list.number")
                }
        }
        .accentColor(.indigo)
    }
}
