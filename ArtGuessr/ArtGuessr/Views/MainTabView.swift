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
                    Label("House", systemImage: "house")

                }
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "info.circle")
                }
        }
        .accentColor(.indigo)
    }
}
