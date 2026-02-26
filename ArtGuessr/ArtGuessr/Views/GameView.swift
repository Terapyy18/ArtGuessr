import SwiftUI
import SwiftData

// Énumération pour gérer les étapes du quiz
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
    @State private var selectedYear: Int = 0
    
    // --- État de verrouillage (Réactif au chargement) ---
    @State private var isImageLoaded: Bool = false
    
    // --- États pour la Popup ---
    @State private var showScorePopup = false
    @State private var pointsGainedInRound = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                if let game = gameInstance {
                    if game.isGameOver {
                        // --- 1. ÉCRAN DE FIN DE PARTIE ---
                        GameOverView(score: game.currentScore) {
                            saveScoreAndRestart(finalScore: game.currentScore)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    } else if let artwork = game.currentArtwork {
                        // --- 2. ÉCRAN DE JEU ---
                        VStack(spacing: 25) {
                            // Zone Image avec détection de phase
                            AsyncImage(url: artwork.image) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 300)
                                        .onAppear { isImageLoaded = false }
                                    
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 300)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                        .onAppear {
                                            // Sécurité : Déclenche l'activation
                                            withAnimation { isImageLoaded = true }
                                        }
                                    
                                case .failure:
                                    VStack {
                                        Image(systemName: "photo.fill").font(.largeTitle)
                                        Text("Image indisponible")
                                    }
                                    .frame(height: 300)
                                    .onAppear { isImageLoaded = true }
                                    
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .padding(.top)
                            // Force le passage à true si l'image est déjà en cache
                            .task(id: artwork.image) {
                                // On attend un cycle pour laisser AsyncImage tenter le chargement
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                if !isImageLoaded { isImageLoaded = true }
                            }
                            
                            // Groupe des contrôles (Désactivé tant que isImageLoaded est false)
                            VStack(spacing: 25) {
                                Text(questionText)
                                    .font(.title3).bold()
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .id(currentStep)
                                
                                VStack(spacing: 12) {
                                    ForEach(game.currentOptions, id: \.id) { option in
                                        Button(action: {
                                            handleUserSelection(for: option)
                                        }) {
                                            Text(buttonLabel(for: option))
                                                .font(.callout)
                                                .foregroundColor(isImageLoaded ? .primary : .secondary)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(isImageLoaded ? Color.indigo.opacity(0.1) : Color.gray.opacity(0.1))
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(isImageLoaded ? Color.indigo.opacity(0.3) : Color.clear, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .disabled(!isImageLoaded)
                            .opacity(isImageLoaded ? 1.0 : 0.5)
                            
                            Spacer()
                            
                            Text("Manche \(game.currentRound) / \(Game.nbRounds)")
                                .font(.caption).foregroundColor(.secondary).padding(.bottom)
                        }
                        .blur(radius: showScorePopup ? 10 : 0)
                        .disabled(showScorePopup)
                        .transition(.opacity)
                        
                    } else {
                        // --- 3. CHARGEMENT INITIAL (SKELETON) ---
                        GameSkeletonView()
                    }
                }
                
                // --- 4. POPUP DE FIN DE ROUND ---
                if showScorePopup, let artwork = gameInstance?.currentArtwork {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    
                    ScoreView(
                        score: pointsGainedInRound,
                        details: [
                            (question: "Artiste", userAnswer: selectedArtist, isCorrect: selectedArtist == artwork.artist, correctAnswer: artwork.artist),
                            (question: "Titre", userAnswer: selectedTitle, isCorrect: selectedTitle == artwork.name, correctAnswer: artwork.name),
                            (question: "Année", userAnswer: String(selectedYear), isCorrect: selectedYear == artwork.year, correctAnswer: String(artwork.year))
                        ]
                    ) {
                        dismissPopup()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("Art Guesser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let game = gameInstance, !game.isGameOver {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text("\(game.currentScore)").bold()
                        }
                    }
                }
            }
            .onAppear { setupGame() }
        }
    }
    
    // MARK: - Helper Methods
    
    private var questionText: String {
        switch currentStep {
        case .artist: return "Qui est l'artiste ?"
        case .title: return "Quel est le titre de l'œuvre ?"
        case .year: return "En quelle année a-t-elle été créée ?"
        }
    }

    private func buttonLabel(for option: ArtWork) -> String {
        switch currentStep {
        case .artist: return option.artist
        case .title: return option.name
        case .year: return "\(option.year)"
        }
    }
    
    private func handleUserSelection(for option: ArtWork) {
        withAnimation {
            switch currentStep {
            case .artist:
                selectedArtist = option.artist
                currentStep = .title
            case .title:
                selectedTitle = option.name
                currentStep = .year
            case .year:
                selectedYear = option.year
                let finalChoice = userChoice(name: selectedTitle, artist: selectedArtist, year: selectedYear)
                if let score = gameInstance?.getAwnsers(userAwnser: finalChoice) {
                    self.pointsGainedInRound = score
                }
                showScorePopup = true
            }
        }
    }
    
    private func dismissPopup() {
        withAnimation {
            showScorePopup = false
            // On remet isImageLoaded à false AVANT de charger le prochain round
            isImageLoaded = false
            resetRoundState()
        }
    }
    
    private func resetRoundState() {
        currentStep = .artist
        selectedArtist = ""
        selectedTitle = ""
        selectedYear = 0
        Task {
            try? await gameInstance?.loadNextRound()
        }
    }
    
    private func setupGame() {
        if gameInstance == nil {
            let newGame = Game(context: modelContext)
            self.gameInstance = newGame
            Task { await newGame.startGame() }
        }
    }
    
    private func saveScoreAndRestart(finalScore: Int) {
        let newScoreRecord = GameScore(score: finalScore, maxScore: 10, date: .now)
        modelContext.insert(newScoreRecord)
        
        isImageLoaded = false
        currentStep = .artist
        gameInstance = nil
        setupGame()
    }
}

// MARK: - GameSkeletonView
struct GameSkeletonView: View {
    @State private var isPulsing = false
    var body: some View {
        VStack(spacing: 25) {
            RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)).frame(height: 300).padding(.top)
            RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)).frame(width: 250, height: 30)
            VStack(spacing: 15) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)).frame(height: 55)
                }
            }.padding(.horizontal)
            Spacer()
        }
        .opacity(isPulsing ? 0.6 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { isPulsing = true }
        }
    }
}
