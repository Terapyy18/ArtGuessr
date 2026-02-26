import SwiftUI
import SwiftData

struct ScoreboardView: View {
    // 1. L'accès direct à ta base de données, trié par date (le plus récent en haut)
    @Query(sort: \GameScore.date, order: .reverse) private var history: [GameScore]
    
    // Pour la suppression si tu veux garder une base propre
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationStack {
            // 2. On remplace le Group vide par une List dynamique
            List {
                if history.isEmpty {
                    VStack(alignment: .center, spacing: 20) {
                        Image(systemName: "tray.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Aucun historique. Lance une partie !")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowBackground(Color.clear)
                } else {
                    // 3. Boucle sur chaque score enregistré
                    ForEach(history) { game in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Art Guesser Classique")
                                    .font(.headline)
                                
                                // Formatage propre de la date de la partie
                                Text(game.date, format: .dateTime.day().month().year().hour().minute())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Affichage du score avec code couleur (vert si >= 50%, orange sinon)
                            Text("\(game.score)")
                                .font(.title2)
                                .bold()
                                .foregroundColor(game.score >= (game.maxScore / 2) ? .green : .orange)
                        }
                        .padding(.vertical, 5)
                    }
                    .onDelete(perform: deleteScore)
                }
            }
            .navigationTitle("Scoreboard")
        }
    }
    
    // Fonctionnalité essentielle : permettre au joueur de vider son historique
    private func deleteScore(offsets: IndexSet) {
        for index in offsets {
            context.delete(history[index])
        }
    }
}
