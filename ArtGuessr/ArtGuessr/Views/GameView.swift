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
                    // C'EST ICI QUE LE SKELETON AGIT
                    GameSkeletonView()
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
    
    private func buttonLabel(for option: ArtWork) -> String {
        switch currentStep {
        case .artist: return option.artist
        case .title: return option.name
        case .year: return "\(option.year)"
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
            // Majuscule corrigée pour appeler la struct (UserChoice au lieu de userChoice)
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

// MARK: - COMPOSANT SKELETON
struct GameSkeletonView: View {
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 25) {
            // Fausse image
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.top)
            
            // Fausse question
            Text("Qui a peint cette œuvre mystère ?")
                .font(.title2).bold()
            
            // Faux boutons
            VStack(spacing: 15) {
                ForEach(0..<4, id: \.self) { _ in
                    Text("Chargement en cours...")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .redacted(reason: .placeholder)
        .opacity(isPulsing ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
