import SwiftUI

struct ScoreView: View {
    var score: Int
    var onDismiss: () -> Void // Action pour fermer la pop-up
    
    var body: some View {
        VStack(spacing: 25) {
            Text(score == 3 ? "Parfait !" : "Terminé !")
                .font(.system(.title, design: .serif)).bold()
                .padding(.top)

            VStack(spacing: 10) {
                Text("Votre score")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                Text("\(score) / 3")
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundColor(.indigo)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.indigo.opacity(0.05))
            .cornerRadius(20)

            Button(action: onDismiss) {
                Text("Continuer")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.indigo)
                    .cornerRadius(15)
            }
        }
        .padding(30)
        .background(Color(.systemBackground))
        .cornerRadius(30)
        .shadow(radius: 20)
        .padding(20) // Marge extérieure pour ne pas coller aux bords de l'écran
    }
}

