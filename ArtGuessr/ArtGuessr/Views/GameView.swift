import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Instanciation du cerveau
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.gameInstance != nil {
                    if viewModel.isGameOver {
                        // --- 1. ÉCRAN DE FIN DE PARTIE ---
                        GameOverView(score: viewModel.currentScore) {
                            viewModel.saveScoreAndRestart(context: modelContext)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    } else if let artwork = viewModel.currentArtwork {
                        // --- 2. ÉCRAN DE JEU ---
                        VStack(spacing: 25) {
                            // Zone Image
                            AsyncImage(url: artwork.image) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().frame(height: 300)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 300)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                case .failure:
                                    VStack {
                                        Image(systemName: "photo.fill").font(.largeTitle)
                                        Text("Image indisponible")
                                    }
                                    .frame(height: 300)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .padding(.top)
                            
                            // Question Dynamique
                            Text(viewModel.questionText)
                                .font(.title3).bold()
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .id(viewModel.currentStep)
                            
                            // Options de réponse
                            VStack(spacing: 12) {
                                ForEach(viewModel.currentOptions, id: \.id) { option in
                                    Button(action: {
                                        // On garde l'animation visuelle dans la vue
                                        withAnimation(.easeInOut) {
                                            viewModel.handleUserSelection(for: option)
                                        }
                                    }) {
                                        Text(viewModel.buttonLabel(for: option))
                                            .font(.callout)
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
                            
                            // Indicateur de progression
                            Text("Manche \(viewModel.currentRound) / \(Game.nbRounds)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.bottom)
                        }
                        .blur(radius: viewModel.showScorePopup ? 10 : 0)
                        .disabled(viewModel.showScorePopup)
                        .transition(.opacity)
                        
                    } else {
                        // --- 3. CHARGEMENT / SKELETON ---
                        GameSkeletonView()
                    }
                } else {
                    GameSkeletonView()
                }
                
                // --- 4. POPUP DE FIN DE ROUND ---
                if viewModel.showScorePopup {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ScoreView(
                        score: viewModel.pointsGainedInRound,
                        details: viewModel.scoreDetails
                    ) {
                        withAnimation {
                            viewModel.dismissPopup()
                        }
                    }
                    .transition(.scale.combined(with: .opacity).animation(.spring(response: 0.3, dampingFraction: 0.7)))
                }
            }
            .navigationTitle("Art Guesser")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.isGameOver && viewModel.gameInstance != nil {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 4) {
                            Image(systemName: "star.fill").foregroundColor(.yellow)
                            Text("\(viewModel.currentScore)").bold()
                        }
                    }
                }
            }
            .onAppear {
                // On passe le contexte SwiftData au ViewModel
                viewModel.setupGame(context: modelContext)
            }
        }
    }
}

// Le composant Skeleton (qui reste logiquement dans le fichier de la Vue ou dans un fichier UI dédié)
struct GameSkeletonView: View {
    @State private var isPulsing = false
    
    var body: some View {
        VStack(spacing: 25) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
                .frame(height: 300)
                .padding(.top)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 250, height: 30)
            
            VStack(spacing: 15) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 55)
                }
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .opacity(isPulsing ? 0.6 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
