//
//  FavoritesView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-24.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @EnvironmentObject var favorites: Favorites
    @Environment(\.dismiss) private var dismiss

    var favoritePharmacies: [Pharmacy] {
        mapViewModel.pharmacies.filter { favorites.contains($0) }
    }

    var body: some View {
        NavigationView {
            List(favoritePharmacies) { pharmacy in
                VStack(alignment: .leading) {
                    Text(pharmacy.name)
                    Text(pharmacy.address)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(pharmacy.name), \(pharmacy.address)")
                .accessibilityHint("Double tap for more details about \(pharmacy.name)")
            }
            .navigationTitle("Favorites")
            .accessibilityAddTraits(.isHeader)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Close favorites")
                    .accessibilityHint("Double tap to close the favorites list")
                }
            }
            .overlay {
                if favoritePharmacies.isEmpty {
                    Text("No favorites yet")
                        .foregroundColor(.secondary)
                        .accessibilityLabel("No favorites yet")
                        .accessibilityHint("You have not added any pharmacies or wellness centers to favorites")
                }
            }
        }
    }
}
