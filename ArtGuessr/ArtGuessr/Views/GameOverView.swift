import SwiftUI

struct GameOverView: View {
    let score: Int
    var onRestart: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "trophy.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            VStack(spacing: 10) {
                Text("Partie Terminée !")
                    .font(.largeTitle).bold()
                
                Text("Votre score final est de")
                    .foregroundColor(.secondary)
                
                Text("\(score) points")
                    .font(.system(size: 50, weight: .heavy, design: .rounded))
                    .foregroundColor(.indigo)
            }
            
            Button(action: onRestart) {
                Text("Rejouer une partie")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}
