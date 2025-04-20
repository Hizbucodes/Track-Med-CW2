//
//  AddMedicationView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct AddMedicationView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var selectedFrequency: MedicationFrequency = .onceDaily
    @State private var selectedDuration: MedicationDuration = .sevenDays
    @State private var startDate = Date()
    @State private var medicationTime = Date()
    @State private var remindersEnabled = true
    @State private var refillTracking = true
    @State private var notes = ""
    @State private var currentSupply: String = ""
    @State private var totalSupply: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Medication Details")) {
                    TextField("Medication Name", text: $name)
                    TextField("Dosage (e.g., 500mg)", text: $dosage)
                }
                
                Section(header: Text("How often?")) {
                    Picker("Frequency", selection: $selectedFrequency) {
                        ForEach(MedicationFrequency.allCases, id: \.self) { frequency in
                            Text(frequency.rawValue).tag(frequency)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("For how long?")) {
                    Picker("Duration", selection: $selectedDuration) {
                        ForEach(MedicationDuration.allCases, id: \.self) { duration in
                            Text(duration.rawValue).tag(duration)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Start Date")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                }
                
                Section(header: Text("Medication Time")) {
                    DatePicker("Time", selection: $medicationTime, displayedComponents: .hourAndMinute)
                }
                
                Section {
                    Toggle("Reminders", isOn: $remindersEnabled)
                    Toggle("Refill Tracking", isOn: $refillTracking)
                }
                
                if refillTracking {
                    Section(header: Text("Supply")) {
                        TextField("Current Supply", text: $currentSupply)
                            .keyboardType(.numberPad)
                        TextField("Total Supply", text: $totalSupply)
                            .keyboardType(.numberPad)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                if let errorMessage = medicationViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: addMedication) {
                        if medicationViewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Add Medication")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .disabled(name.isEmpty || dosage.isEmpty || medicationViewModel.isLoading)
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func addMedication() {
        guard let userId = authViewModel.user?.id else { return }
        
        // Calculate times based on frequency
        var medicationTimes: [Date] = []
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: medicationTime)
        
        switch selectedFrequency {
        case .onceDaily:
            if let time = Calendar.current.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: startDate) {
                medicationTimes.append(time)
            }
        case .twiceDaily:
            if let morningTime = Calendar.current.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: startDate),
               let eveningTime = Calendar.current.date(byAdding: .hour, value: 12, to: morningTime) {
                medicationTimes.append(morningTime)
                medicationTimes.append(eveningTime)
            }
        case .threeTimesDaily:
            if let morningTime = Calendar.current.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: startDate),
               let afternoonTime = Calendar.current.date(byAdding: .hour, value: 8, to: morningTime),
               let eveningTime = Calendar.current.date(byAdding: .hour, value: 8, to: afternoonTime) {
                medicationTimes.append(morningTime)
                medicationTimes.append(afternoonTime)
                medicationTimes.append(eveningTime)
            }
        case .fourTimesDaily:
            if let firstTime = Calendar.current.date(bySettingHour: components.hour ?? 0, minute: components.minute ?? 0, second: 0, of: startDate),
               let secondTime = Calendar.current.date(byAdding: .hour, value: 6, to: firstTime),
               let thirdTime = Calendar.current.date(byAdding: .hour, value: 6, to: secondTime),
               let fourthTime = Calendar.current.date(byAdding: .hour, value: 6, to: thirdTime) {
                medicationTimes.append(firstTime)
                medicationTimes.append(secondTime)
                medicationTimes.append(thirdTime)
                medicationTimes.append(fourthTime)
            }
        }
        
        // Create medication
        let medication = Medication(
            name: name,
            dosage: dosage,
            frequency: selectedFrequency,
            duration: selectedDuration,
            startDate: startDate,
            times: medicationTimes,
            remindersEnabled: remindersEnabled,
            refillTracking: refillTracking,
            notes: notes.isEmpty ? nil : notes,
            userId: userId,
            currentSupply: Int(currentSupply),
            totalSupply: Int(totalSupply)
        )
        
        medicationViewModel.addMedication(medication) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
