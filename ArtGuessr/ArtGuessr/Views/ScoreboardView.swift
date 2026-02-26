import SwiftUI
import SwiftData

struct ScoreboardView: View {
    @Query(sort: \GameScore.date, order: .reverse) private var history: [GameScore]
    @Environment(\.modelContext) private var context
    var body: some View {
        NavigationStack {
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
                    ForEach(history) { game in
                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Art Guesser Classique")
                                    .font(.headline)
                                Text(game.date, format: .dateTime.day().month().year().hour().minute())
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
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
    
    private func deleteScore(offsets: IndexSet) {
        for index in offsets {
            context.delete(history[index])
        }
    }
}
