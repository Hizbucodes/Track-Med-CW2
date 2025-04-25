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
            .accessibilityLabel("Back")
            .accessibilityHint("Go back to previous screen")
            
            Text("Refill Tracker")
                .font(.title2)
                .fontWeight(.bold)
                .accessibilityAddTraits(.isHeader)
            
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
                            .accessibilityLabel("Loading medications")
                            .accessibilityHint("Please wait while your medications are loading")
                    } else if refillableMedications.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "pills")
                                .font(.system(size: 48))
                                .foregroundColor(.blue.opacity(0.7))
                                .padding(.top, 40)
                                .accessibilityHidden(true)
                            Text("No medications with refill tracking")
                                .font(.headline)
                                .accessibilityLabel("No medications with refill tracking")
                            Text("Add a medication with refill tracking enabled to see it here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .accessibilityHint("Add a medication with refill tracking enabled to see it here.")
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
                        .accessibilityLabel("Medication name: \(medication.name)")
                    Text(medication.dosage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .accessibilityLabel("Dosage: \(medication.dosage)")
                }
                Spacer()
                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(statusColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(statusColor.opacity(0.1))
                    .cornerRadius(20)
                    .accessibilityLabel("Status: \(statusText)")
            }
            
            if let current = medication.currentSupply, let total = medication.totalSupply {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Current Supply")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .accessibilityHidden(true)
                        Spacer()
                        Text("\(current) of \(total) pills")
                            .font(.subheadline)
                            .accessibilityLabel("Current supply: \(current) out of \(total) pills")
                    }
                    ProgressBar(value: medication.progress, color: statusColor)
                        .accessibilityLabel("Supply progress")
                        .accessibilityValue("\(Int(medication.progress * 100)) percent")
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
                .disabled(isFull)
                .accessibilityLabel("Refill medication")
                .accessibilityHint(isFull ? "Medication is already full" : "Double tap to refill medication to full supply")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(medication.name), \(medication.dosage), Status: \(statusText), Current supply: \(medication.currentSupply ?? 0) out of \(medication.totalSupply ?? 0) pills")
        .accessibilityHint(isFull ? "Medication is already full" : "Double tap refill to mark medication as refilled")
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
                    .accessibilityHidden(true)
                Rectangle()
                    .frame(width: min(CGFloat(self.value) * geometry.size.width, geometry.size.width), height: 10)
                    .foregroundColor(color)
                    .cornerRadius(5)
                    .accessibilityHidden(true)
            }
        }
        .frame(height: 10)
    }
}
