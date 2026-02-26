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
    
    // --- États pour la Popup ---
    @State private var showScorePopup = false
    @State private var pointsGainedInRound = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Contenu Principal
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
                            .id(currentStep)
                        
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
                        VStack(spacing: 20) {
                            ProgressView()
                            Text("Préparation de la galerie...")
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .blur(radius: showScorePopup ? 10 : 0) // Flou quand la popup est là
                .disabled(showScorePopup) // Empêche de cliquer sur le jeu
                
                // --- Popup de Score ---
                if showScorePopup {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ScoreView(score: pointsGainedInRound) {
                        dismissPopup()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
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
        case .artist:
            return option.artist
        case .title:
            return option.name
        case .year:
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
            let finalChoice = userChoice(
                name: selectedTitle,
                artist: selectedArtist,
                year: option.year
            )
            
            // On récupère le score du tour renvoyé par le Game
            if let score = gameInstance?.getAwnsers(userAwnser: finalChoice) {
                self.pointsGainedInRound = score
            }
            
            // Affichage de la popup
            withAnimation(.spring()) {
                showScorePopup = true
            }
        }
    }
    
    private func dismissPopup() {
        showScorePopup = false
        currentStep = .artist
        selectedArtist = ""
        selectedTitle = ""
        
        // Charger le tour suivant
        Task {
            try? await gameInstance?.loadNextRound()
        }
    }
    
    private func setupGame() {
        func setupGame() {
            // On vérifie si gameInstance est vide pour éviter de recréer le jeu à chaque apparition
            if gameInstance == nil {
                let newGame = Game(context: modelContext)
                self.gameInstance = newGame
                
                // On lance le chargement de manière asynchrone
                Task {
                    await newGame.startGame()
                }
            }
        }
    }
}
