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
    
    static func fetchById(id: Int) async -> ArtWork? {
        let urlString = "https://collectionapi.metmuseum.org/public/collection/v1/objects/\(id)"
        
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Erreur : Œuvre introuvable (ID: \(id))")
                return nil
            }
            
            let artwork = try JSONDecoder().decode(ArtWork.self, from: data)
            return artwork
            
        } catch {
            print("Erreur de décodage ou réseau : \(error)")
            return nil
        }
    }
}
