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
    @State private var selectedYear: Int = 0 // Ajouté pour l'envoyer à la ScoreView
    
    // --- États pour la Popup ---
    @State private var showScorePopup = false
    @State private var pointsGainedInRound = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                // --- Contenu Principal ---
                VStack(spacing: 25) {
                    if let game = gameInstance {
                        
                        // ==========================================
                        // 1. LE RÉSUMÉ DE PARTIE (GAME OVER)
                        // ==========================================
                        if game.isGameOver {
                            VStack(spacing: 30) {
                                Image(systemName: "trophy.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.yellow)
                                    .padding(.top, 40)
                                
                                Text("Partie Terminée !")
                                    .font(.largeTitle).bold()
                                
                                VStack(spacing: 10) {
                                    Text("Ton score final")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                    
                                    Text("\(game.currentScore) / 10")
                                        .font(.system(size: 60, weight: .black, design: .rounded))
                                        .foregroundColor(game.currentScore >= 5 ? .green : .orange)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    saveScoreAndRestart(finalScore: game.currentScore)
                                }) {
                                    Text("Sauvegarder et Rejouer")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.indigo)
                                        .cornerRadius(16)
                                        .shadow(radius: 5)
                                }
                                .padding(.horizontal, 30)
                                .padding(.bottom, 20)
                            }
                            
                        // ==========================================
                        // 2. LE JEU EN COURS
                        // ==========================================
                        } else if let artwork = game.currentArtwork {
                            
                            // Zone Image
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
                            
                            // Question Dynamique
                            Text(questionText)
                                .font(.title2).bold()
                                .id(currentStep)
                            
                            // Options de réponse
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
                            
                            Spacer()
                            
                        } else {
                            GameSkeletonView()
                        }
                    } else {
                        GameSkeletonView()
                    }
                }
                .blur(radius: showScorePopup ? 10 : 0)
                .disabled(showScorePopup)
                
                // ==========================================
                // 3. POPUP DE FIN DE ROUND
                // ==========================================
                if showScorePopup, let artwork = gameInstance?.currentArtwork {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
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
            .navigationTitle(gameInstance?.isGameOver == true ? "Résumé" : "Art Guesser")
            .toolbar {
                if gameInstance?.isGameOver == false {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(.yellow)
                            Text("Score: \(gameInstance?.currentScore ?? 0)")
                                .bold()
                        }
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
            selectedYear = option.year // On sauvegarde l'année pour la popup
            
            // On laisse ton implémentation userChoice stricte
            let finalChoice = userChoice(
                name: selectedTitle,
                artist: selectedArtist,
                year: selectedYear
            )
            
            if let score = gameInstance?.getAwnsers(userAwnser: finalChoice) {
                self.pointsGainedInRound = score
            }
            
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
        selectedYear = 0
        
        Task {
            try? await gameInstance?.loadNextRound()
        }
    }
    
    private func setupGame() {
        if gameInstance == nil {
            let newGame = Game(context: modelContext)
            self.gameInstance = newGame
            Task {
                await newGame.startGame()
            }
        }
    }
    
    // MARK: - Sauvegarde
    private func saveScoreAndRestart(finalScore: Int) {
        let newScoreRecord = GameScore(score: finalScore, maxScore: 10, date: .now)
        modelContext.insert(newScoreRecord)
        
        gameInstance = nil
        setupGame()
    }
}

// MARK: - COMPOSANT SKELETON
struct GameSkeletonView: View {
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 25) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 300)
                .cornerRadius(12)
                .padding(.top)
            
            Text("Qui a peint cette œuvre mystère ?")
                .font(.title2).bold()
            
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
            Spacer()
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
