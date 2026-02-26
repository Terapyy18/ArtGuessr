import SwiftUI
import SwiftData

struct GameView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = GameViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.gameInstance != nil {
                    if viewModel.isGameOver {
                        // --- 1. ÉCRAN DE FIN DE PARTIE ---
                        GameOverView(score: viewModel.currentScore) {
                            viewModel.saveScoreAndRestart(context: modelContext, finalScore: viewModel.currentScore)
                        }
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing),
                            removal: .move(edge: .leading)
                        ))
                        
                    } else if let artwork = viewModel.currentArtwork {
                        // --- 2. ÉCRAN DE JEU ---
                        VStack(spacing: 25) {
                            // Zone Image avec détection de phase
                            AsyncImage(url: artwork.image) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(height: 300)
                                        .onAppear { viewModel.isImageLoaded = false }
                                    
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 300)
                                        .cornerRadius(12)
                                        .shadow(radius: 5)
                                        .onAppear {
                                            withAnimation { viewModel.isImageLoaded = true }
                                        }
                                    
                                case .failure:
                                    VStack {
                                        Image(systemName: "photo.fill").font(.largeTitle)
                                        Text("Image indisponible")
                                    }
                                    .frame(height: 300)
                                    .onAppear { viewModel.isImageLoaded = true }
                                    
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .padding(.top)
                            .task(id: artwork.image) {
                                try? await Task.sleep(nanoseconds: 100_000_000)
                                if !viewModel.isImageLoaded { viewModel.isImageLoaded = true }
                            }
                            
                            // Groupe des contrôles
                            VStack(spacing: 25) {
                                Text(viewModel.questionText)
                                    .font(.title3).bold()
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .id(viewModel.currentStep)
                                
                                VStack(spacing: 12) {
                                    ForEach(viewModel.currentOptions, id: \.id) { option in
                                        Button(action: {
                                            withAnimation(.easeInOut) {
                                                viewModel.handleUserSelection(for: option)
                                            }
                                        }) {
                                            Text(viewModel.buttonLabel(for: option))
                                                .font(.callout)
                                                .foregroundColor(viewModel.isImageLoaded ? .primary : .secondary)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(viewModel.isImageLoaded ? Color.indigo.opacity(0.1) : Color.gray.opacity(0.1))
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(viewModel.isImageLoaded ? Color.indigo.opacity(0.3) : Color.clear, lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .disabled(!viewModel.isImageLoaded)
                            .opacity(viewModel.isImageLoaded ? 1.0 : 0.5)
                            
                            Spacer()
                            
                            Text("Manche \(viewModel.currentRound) / \(Game.nbRounds)")
                                .font(.caption).foregroundColor(.secondary).padding(.bottom)
                        }
                        .blur(radius: viewModel.showScorePopup ? 10 : 0)
                        .disabled(viewModel.showScorePopup)
                        .transition(.opacity)
                        
                    } else {
                        // --- 3. CHARGEMENT INITIAL (SKELETON) ---
                        GameSkeletonView()
                    }
                }
                
                // --- 4. POPUP DE FIN DE ROUND ---
                if viewModel.showScorePopup {
                    Color.black.opacity(0.3).ignoresSafeArea()
                    
                    ScoreView(
                        score: viewModel.pointsGainedInRound,
                        details: viewModel.scoreDetails
                    ) {
                        withAnimation {
                            viewModel.dismissPopup()
                        }
                    }
                    .transition(.scale.combined(with: .opacity))
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
            .onAppear { viewModel.setupGame(context: modelContext) }
        }
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
            }
            .padding(.horizontal)
            Spacer()
        }
        .padding()
        .opacity(isPulsing ? 0.6 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { isPulsing = true }
        }
    }
}
