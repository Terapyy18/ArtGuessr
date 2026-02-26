import SwiftUI

struct MainTabView: View {

    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Game", systemImage: "books.vertical.fill")
                }
            
            ScoreboardView()
                .tabItem {
                    Label("Home", systemImage: "house")

                }
            HomeView()
                .tabItem {
                    Label("Scoreboard", systemImage: "info.circle")
                }
        }
        .accentColor(.indigo)
    }
}
