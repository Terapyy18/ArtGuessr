import Foundation
import SwiftUI
import SwiftData

struct APIService {
    
    @MainActor
    static func fetchAndStore50IDs(context: ModelContext) async -> [Int] {
        let urlString = "https://collectionapi.metmuseum.org/public/collection/v1/search?isHighlight=true&hasImages=true&q=painting&hasArtist=true"
        
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ObjectIDsResponse.self, from: data)
            
            let top50 = Array(response.objectIDs.shuffled().prefix(50))
            
            for id in top50 {
                context.insert(ArtworkIds(id: id))
            }
            
            try context.save()
            return top50
            
        } catch {
            print("Erreur réseau ou base de données : \(error.localizedDescription)")
        }
        
        return []
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
    
    static func getAllPaintingsAtOnce(ids: [Int]) async -> [ArtWork] {
        @Environment(\.modelContext) var modelContext
        let allIds: [Int] = await fetchAndStore50IDs(context: modelContext)
        let baseUrl = "https://collectionapi.metmuseum.org/public/collection/v1/objects/"
        
        return await withTaskGroup(of: ArtWork?.self) { group in
            for id in allIds {
                group.addTask {
                    guard let url = URL(string: baseUrl + String(id)) else { return nil }
                    
                    do {
                        let (data, response) = try await URLSession.shared.data(from: url)
                        
                        guard let httpResponse = response as? HTTPURLResponse,
                              httpResponse.statusCode == 200 else { return nil }
                        
                        // 1. Décodage initial
                        let decoded = try JSONDecoder().decode(ArtWork.self, from: data)
                        
                        // 2. Vérification stricte (Image, Titre, Artiste, Année non vides)
                        // On vérifie que les chaînes ne sont pas juste des espaces ou vides
                        let hasTitle = !decoded.name.trimmingCharacters(in: .whitespaces).isEmpty
                        let hasArtist = !decoded.artist.trimmingCharacters(in: .whitespaces).isEmpty
                        let hasImage = !decoded.image.absoluteString.isEmpty
                        let hasYear = decoded.year != 0 // Ou une autre logique selon l'API
                        
                        if hasTitle && hasArtist && hasImage && hasYear {
                            return decoded
                        } else {
                            print("Données incomplètes pour l'ID \(id)")
                            return nil
                        }
                        
                    } catch {
                        print("Erreur réseau ou décodage pour l'ID \(id): \(error)")
                        return nil
                    }
                }
            }
            
            // Accumulation des résultats valides uniquement
            var validArtworks: [ArtWork] = []
            for await artwork in group {
                if let artwork = artwork {
                    validArtworks.append(artwork)
                }
            }
            return validArtworks
        }
    }
}
