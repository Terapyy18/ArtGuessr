import SwiftUI

struct MainTabView: View {
    @StateObject private var game = Game()

    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Game", systemImage: "books.vertical.fill")
                }
            
            ScoreBoardView()
                .tabItem {
                    Label("Scoreboard", systemImage: "info.circle")
                }
        }
        .accentColor(.indigo) // Donne un style direct
    }
}
