import Foundation
import SwiftData

struct APIService {
    
    @MainActor
    static func fetchAndStore50IDs(context: ModelContext) async {
        let urlString = "https://collectionapi.metmuseum.org/public/collection/v1/search?isHighlight=true&hasImages=true&q=painting"
        
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ObjectIDsResponse.self, from: data)
            
            let top50 = Array(response.objectIDs.shuffled().prefix(50))
            
            for id in top50 {
                context.insert(ArtworkIds(id: id))
            }
            
            try context.save()
            print("Succès : 50 IDs stockés.")
            
        } catch {
            print("Erreur réseau ou base de données : \(error.localizedDescription)")
        }
    }
}
