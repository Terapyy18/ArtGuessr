import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 35) {
                    
                    VStack(spacing: 15) {
                        Image(systemName: "paintpalette.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.indigo)
                            .shadow(color: .indigo.opacity(0.3), radius: 10, y: 5)
                        
                        Text("Art Guesser")
                            .font(.system(.largeTitle, design: .rounded))
                            .fontWeight(.black)
                        
                        Text("Découvrez des peintures en s'amusant !")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
//                    Button(action: {
//                        selectedTab = 1
//                    }) {
//                        HStack(spacing: 20) {
//                            Image(systemName: "play.fill")
//                                .font(.title)
//                            
//                            VStack(alignment: .leading) {
//                                Text("la date de publication")
//                                    .font(.headline)
//                                Text("7 Rounds - 4 Choix")
//                                    .font(.subheadline)
//                                    .opacity(0.8)
//                            }
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                        }
//                        .padding()
//                        .foregroundColor(.white)
//                        .background(Color.indigo)
//                        .cornerRadius(16)
//                        .shadow(color: .indigo.opacity(0.4), radius: 8, y: 4)
//                        
//                    }
//                    
//                    .padding(.horizontal, 25)
                }
                Button(action: {
                    selectedTab = 1
                }) {
                    HStack(spacing: 20) {
                        Image(systemName: "play.fill")
                            .font(.title)
                        
                        VStack(alignment: .leading) {
                            Text("Le titre de l'oeuvre")
                                .font(.headline)
                            Text("10 Rounds - 4 Choix")
                                .font(.subheadline)
                                .opacity(0.8)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.indigo)
                    .cornerRadius(16)
                    .shadow(color: .indigo.opacity(0.4), radius: 8, y: 4)
                    
                }
                .padding(.horizontal, 25)

            }
            
            .navigationTitle("Accueil")
            .navigationBarHidden(true)
        }
    }
}
