//
//  FilterOptionsView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-24.
//

import SwiftUI

struct FilterOptionsView: View {
    @Binding var selectedType: LocationType
    var onFilterChanged: (LocationType) -> Void
    @Environment(\.dismiss) var dismiss // For dismissing the sheet

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Filter By")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Filter by location type")

                Button(action: {
                    selectedType = .pharmacy
                    onFilterChanged(.pharmacy)
                }) {
                    HStack {
                        Image(systemName: "pills.fill")
                            .accessibilityHidden(true)
                        Text("Pharmacy")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedType == .pharmacy ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .foregroundColor(selectedType == .pharmacy ? .blue : .primary)
                .accessibilityLabel("Pharmacy filter")
                .accessibilityValue(selectedType == .pharmacy ? "Selected" : "Not selected")
                .accessibilityHint(selectedType == .pharmacy ? "Currently showing pharmacies" : "Double tap to filter by pharmacies")

                Button(action: {
                    selectedType = .wellness
                    onFilterChanged(.wellness)
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .accessibilityHidden(true)
                        Text("Wellness")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedType == .wellness ? Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .foregroundColor(selectedType == .wellness ? .pink : .primary)
                .accessibilityLabel("Wellness filter")
                .accessibilityValue(selectedType == .wellness ? "Selected" : "Not selected")
                .accessibilityHint(selectedType == .wellness ? "Currently showing wellness centers" : "Double tap to filter by wellness centers")

                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .accessibilityLabel("Close filter options")
                    .accessibilityHint("Double tap to close filter options")
                }
            }
        }
    }
}
