import SwiftUI

struct ScoreView: View {
    var score: Int
    var details: [(question: String, userAnswer: String, isCorrect: Bool, correctAnswer: String)]
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
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
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .background(Color.indigo.opacity(0.05))
            .cornerRadius(20)

            // --- LE RÉSUMÉ DES RÉPONSES ---
            VStack(alignment: .leading, spacing: 12) {
                ForEach(0..<details.count, id: \.self) { index in
                    let detail = details[index]
                    
                    HStack(alignment: .top) {
                        Image(systemName: detail.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(detail.isCorrect ? .green : .red)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(detail.question)
                                .font(.subheadline).bold()
                            
                            if detail.isCorrect {
                                Text(detail.userAnswer)
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Text("Ta réponse : \(detail.userAnswer)")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .strikethrough()
                                Text("Vraie réponse : \(detail.correctAnswer)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 5)

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
        .padding(25)
        .background(Color(.systemBackground))
        .cornerRadius(30)
        .shadow(radius: 20)
        .padding(20)
    }
}
