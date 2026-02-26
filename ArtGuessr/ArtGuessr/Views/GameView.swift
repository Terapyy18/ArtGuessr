import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameInstance: Game?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                if let game = gameInstance {
                    // Zone Image
                    if let artwork : ArtWork = game.currentArtwork {
                        AsyncImage(url: artwork.image) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // L'image charge
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 300)
                            case .failure(let error):
                                VStack {
                                    Image(systemName: "exclamationmark.triangle")
                                    Text(error.localizedDescription) // Affiche l'erreur de téléchargement
                                }
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                    
                    Text("Qui a peint cette œuvre ?")
                        .font(.title2).bold()
                    
                    // Options
                    VStack(spacing: 15) {
                        ForEach(game.currentOptions, id: \.id) { artwork in
                            Button(action: {
                                let awnsers : userChoice = userChoice(name: artwork.name, artist: artwork.artist, year: artwork.year)
                                gameInstance?.getAwnsers(userAwnser: awnsers)
                            }) {
                                Text(artwork.artist)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.indigo.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                } else {
                    ProgressView("Chargement...")
                }
                Spacer()
            }
            .navigationTitle("Art Guesser")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Score: \(gameInstance?.currentScore ?? 0)")
                }
            }
            .onAppear {
                if gameInstance == nil {
                    gameInstance = Game(context: modelContext)
                    Task {
                        await gameInstance?.startGame()
                    }
                }
            }
        }
    }
}

