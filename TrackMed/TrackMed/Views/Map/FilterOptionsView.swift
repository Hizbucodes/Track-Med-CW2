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
        NavigationView{
            VStack(spacing: 20) {
                Text("Filter By")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Button(action: {
                    selectedType = .pharmacy
                    onFilterChanged(.pharmacy)
                }) {
                    HStack {
                        Image(systemName: "pills.fill")
                        Text("Pharmacy")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedType == .pharmacy ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .foregroundColor(selectedType == .pharmacy ? .blue : .primary)
                
                Button(action: {
                    selectedType = .wellness
                    onFilterChanged(.wellness)
                }) {
                    HStack {
                        Image(systemName: "heart.fill")
                        Text("Wellness")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedType == .wellness ? Color.pink.opacity(0.2) : Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .foregroundColor(selectedType == .wellness ? .pink : .primary)
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline) // Ensure title is in the top bar
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        dismiss() // Dismiss the sheet
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}
