import SwiftUI

struct GameView: View {
    @State private var score = 0
    @State private var mockArtists = ["Vincent van Gogh", "Claude Monet", "Pablo Picasso", "Léonard de Vinci"]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(4/3, contentMode: .fit)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .overlay(
                        VStack {
                            Image(systemName: "photo.artframe")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("Chargement de la peinture...")
                                .foregroundColor(.gray)
                                .padding(.top, 5)
                        }
                    )
                    .padding(.horizontal)
                
                // 2. La Question
                Text("Qui a peint cette œuvre ?")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // 3. Les 4 choix (QCM)
                VStack(spacing: 15) {
                    ForEach(mockArtists, id: \.self) { artist in
                        Button(action: {
                            print("Joueur a cliqué sur : \(artist)")
                        }) {
                            Text(artist)
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.indigo.opacity(0.1))
                                .foregroundColor(.indigo)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.indigo, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .navigationTitle("Art Guesser") // Titre cohérent
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Text("Score: \(score)")
                        .font(.headline)
                        .foregroundColor(.indigo)
                }
            }
        }
    }
}
