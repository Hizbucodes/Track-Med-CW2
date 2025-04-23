//
//  RefillTrackerView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct RefillTrackerView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var refillableMedications: [Medication] {
        medicationViewModel.medications.filter { $0.refillTracking && $0.currentSupply != nil && $0.totalSupply != nil }
    }

    
    var body: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .font(.system(size: 18))
                }
            }
            .padding(.trailing, 10)
            
            Text("Refill Tracker")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    if medicationViewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                    } else if refillableMedications.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "pills")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.7))
                                .padding(.top, 40)
                            
                            Text("No medications with refill tracking")
                                .font(.headline)
                            
                            Text("Add a medication with refill tracking enabled to see it here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    } else {
                        ForEach(refillableMedications) { medication in
                            RefillCard(medication: medication) { newSupply in
                                updateMedicationSupply(medication: medication, newSupply: newSupply)
                            }
                        }
                    }
                }
                .padding()
            }
          
        }
    }
    
    private func updateMedicationSupply(medication: Medication, newSupply: Int) {
        guard let id = medication.id else { return }
        medicationViewModel.updateMedicationSupply(id: id, currentSupply: newSupply) { _ in }
    }
}

struct RefillCard: View {
    let medication: Medication
    let onRefill: (Int) -> Void
    
    // Add this computed property
    var isFull: Bool {
        guard let current = medication.currentSupply,
              let total = medication.totalSupply else { return false }
        return current >= total
    }
    
    var statusColor: Color {
        let progress = medication.progress
        if progress > 0.5 {
            return .green
        } else if progress > 0.2 {
            return .yellow
        } else {
            return .red
        }
    }
    
    var statusText: String {
        let progress = medication.progress
        if progress > 0.5 {
            return "Good"
        } else if progress > 0.2 {
            return "Low"
        } else {
            return "Critical"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(medication.name)
                        .font(.headline)
                    
                    Text(medication.dosage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(20)
            }
            
            if let current = medication.currentSupply, let total = medication.totalSupply {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Supply")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(current) of \(total) pills")
                            .font(.subheadline)
                    }
                    
                    ProgressBar(value: medication.progress, color: statusColor)
                }
            }
            
            HStack {
                Spacer()
                
                Button(action: {
                    if let total = medication.totalSupply {
                        onRefill(total)
                    }
                }) {
                    Text("Refill")
                        .font(.headline)
                        .foregroundColor(isFull ? .black : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                        .background(isFull ? Color.gray.opacity(0.2) : Color.blue)
                        .cornerRadius(50)
                }
                .disabled(isFull) // Disable when full
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}


struct ProgressBar: View {
    var value: Double
    var color: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(width: geometry.size.width, height: 10)
                    .opacity(0.1)
                    .foregroundColor(Color(.systemGray4))
                    .cornerRadius(5)
                
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 10)
                    .foregroundColor(color)
                    .cornerRadius(5)
            }
        }
        .frame(height: 10)
    }
}
