import SwiftUI
import SwiftData

// Enumération pour gérer les étapes du quiz
enum GameStep {
    case artist, title, year
}

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var gameInstance: Game?
    
    // --- États pour le flux de questions ---
    @State private var currentStep: GameStep = .artist
    @State private var selectedArtist: String = ""
    @State private var selectedTitle: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                if let game = gameInstance, let artwork = game.currentArtwork {
                    
                    // 1. Zone Image
                    AsyncImage(url: artwork.image) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(height: 300)
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 300)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                        case .failure:
                            VStack {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Erreur de chargement")
                            }
                            .frame(height: 300)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .padding(.top)
                    
                    // 2. Question Dynamique
                    Text(questionText)
                        .font(.title2).bold()
                        .id(currentStep) // Identifiant pour l'animation
                    
                    // 3. Options de réponse
                    VStack(spacing: 15) {
                        ForEach(game.currentOptions, id: \.id) { option in
                            Button(action: {
                                withAnimation(.spring()) {
                                    handleUserSelection(for: option)
                                }
                            }) {
                                // On appelle la fonction qui gère maintenant la conversion Int -> String
                                Text(buttonLabel(for: option))
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.indigo.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                } else {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Préparation de la galerie...")
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .navigationTitle("Art Guesser")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                        Text("Score: \(gameInstance?.currentScore ?? 0)")
                            .bold()
                    }
                }
            }
            .onAppear {
                setupGame()
            }
        }
    }
    
    // MARK: - Logique d'affichage
    
    private var questionText: String {
        switch currentStep {
        case .artist: return "Qui a peint cette œuvre ?"
        case .title: return "Quel est le nom du tableau ?"
        case .year: return "En quelle année ?"
        }
    }
    
    // CORRECTION ICI : On convertit l'année en String si c'est un Int
    private func buttonLabel(for option: ArtWork) -> String {
        switch currentStep {
        case .artist:
            return option.artist
        case .title:
            return option.name
        case .year:
            // Si option.year est un Int, on le transforme en String
            return "\(option.year)"
        }
    }
    
    // MARK: - Logique de jeu
    
    private func handleUserSelection(for option: ArtWork) {
        switch currentStep {
        case .artist:
            selectedArtist = option.artist
            currentStep = .title
            
        case .title:
            selectedTitle = option.name
            currentStep = .year
            
        case .year:
            // On crée la réponse finale
            // Note: Assure-toi que userChoice accepte un Int ou un String pour l'année selon ton modèle
            let finalChoice = userChoice(
                name: selectedTitle,
                artist: selectedArtist,
                year: option.year
            )
            
            gameInstance?.getAwnsers(userAwnser: finalChoice)
            
            // Reset pour le prochain tour
            currentStep = .artist
            selectedArtist = ""
            selectedTitle = ""
        }
    }
    
    private func setupGame() {
        if gameInstance == nil {
            gameInstance = Game(context: modelContext)
            Task {
                await gameInstance?.startGame()
            }
        }
    }
}
