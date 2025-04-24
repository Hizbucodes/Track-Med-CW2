//
//  Favorites.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-24.
//

// Favorites.swift
import Foundation

class Favorites: ObservableObject {
    @Published var favoriteIDs: Set<String>
    private let key = "FavoritePharmacies"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteIDs = decoded
        } else {
            favoriteIDs = []
        }
    }
    
    func toggle(_ pharmacy: Pharmacy) {
        let id = pharmacy.uniqueID
        if favoriteIDs.contains(id) {
            favoriteIDs.remove(id)
        } else {
            favoriteIDs.insert(id)
        }
        save()
    }
    
    func contains(_ pharmacy: Pharmacy) -> Bool {
        favoriteIDs.contains(pharmacy.uniqueID)
    }
    
    private func save() {
        if let data = try? JSONEncoder().encode(favoriteIDs) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
