//
//  AddMedicationView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import FirebaseFirestore

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
    @State private var refillTracking = false
    @State private var notes = ""
    @State private var currentSupply: String = ""
    @State private var totalSupply: String = ""
    
    // For custom date/time picker sheets
    @State private var showingDatePicker = false
    @State private var showingTimePicker = false
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(red: 0.95, green: 0.97, blue: 1.0)
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 38, height: 38)
                            
                            Image(systemName: "arrow.left")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                
                        }
                    }
                    .padding(.leading)
                    
                    Text("Add Medication")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading, 8)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .frame(height: 68)
            
            
            
            ScrollView {
                VStack(spacing: 20) {
                    // Medication Details
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medication name")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "pill.fill")
                                .foregroundColor(.gray)
                            TextField("e.g. amoxicillin", text: $name)
                                .accessibilityLabel("Medication name")
                                    .accessibilityHint("Enter the name of your medication")
                                .font(.body)
                        }
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )


                        
                        Text("Dosage")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.top, 16)
                        
                        HStack {
                            Image(systemName: "scalemass.fill")
                                .foregroundColor(.gray)
                            TextField("e.g. 500mg", text: $dosage)
                                .accessibilityLabel("Dosage")
                                    .accessibilityHint("Enter the dosage for your medication")
                                .font(.body)
                        }
                        .padding()
                        .background(Color.clear)
                        .overlay(
                            Capsule()
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )

                    }
                    .padding(.horizontal)
                    .padding(.vertical)
                    
                    // Frequency
                    VStack(alignment: .leading, spacing: 10) {
                        Text("How often?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(MedicationFrequency.allCases, id: \.self) { frequency in
                                Button(action: {
                                    selectedFrequency = frequency
                                }) {
                                    VStack(spacing: 8) {
                                        Image(systemName: frequencyIcon(for: frequency))
                                            .font(.system(size: 22))
                                        Text(frequency.rawValue)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(selectedFrequency == frequency ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                    .cornerRadius(15)
                                }
                                .accessibilityLabel(frequency.rawValue)
                                .accessibilityValue(selectedFrequency == frequency ? "Selected" : "Not selected")
                                .accessibilityHint(selectedFrequency == frequency ? "Currently selected" : "Double tap to select \(frequency.rawValue)")
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Duration
                    VStack(alignment: .leading, spacing: 10) {
                        Text("For how long?")
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(MedicationDuration.allCases, id: \.self) { duration in
                                Button(action: {
                                    selectedDuration = duration
                                }) {
                                    VStack(spacing: 6) {
                                        Text(displayValue(for: duration))
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        Text(duration.rawValue)
                                            .font(.subheadline)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(selectedDuration == duration ? Color.blue.opacity(0.1) : Color(.systemGray6))
                                    .cornerRadius(15)
                                }
                                .accessibilityLabel(duration.rawValue)
                                .accessibilityValue(selectedDuration == duration ? "Selected" : "Not selected")
                                .accessibilityHint(selectedDuration == duration ? "Currently selected" : "Double tap to select \(duration.rawValue)")
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Date Picker
                    VStack(alignment: .leading) {
                        Text("Select Starting Date")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                        
                        Button(action: {
                            showingDatePicker = true
                        }) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.primary)
                                Text(startDate, formatter: dateFormatter)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        }
                        .accessibilityLabel("Starting date")
                        .accessibilityValue(dateFormatter.string(from: startDate))
                        .accessibilityHint("Double tap to select a starting date")
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .sheet(isPresented: $showingDatePicker) {
                            DatePickerSheet(selectedDate: $startDate, isPresented: $showingDatePicker)
                        }
                        
                        Text("Medication Time")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        Button(action: {
                            showingTimePicker = true
                        }) {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.primary)
                                Text(medicationTime, formatter: timeFormatter)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                        }
                        .accessibilityLabel("Starting time")
                        .accessibilityValue(dateFormatter.string(from: startDate))
                        .accessibilityHint("Double tap to select a starting time")
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal)
                        .sheet(isPresented: $showingTimePicker) {
                            TimePickerSheet(selectedTime: $medicationTime, isPresented: $showingTimePicker)
                        }
                    }
                    
                    // Reminders
                    VStack {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "bell.fill")
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Reminders")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Get notified when it's time to take your medication")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $remindersEnabled)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        
                        // Refill Tracking
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 36, height: 36)
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Refill Tracking")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("Get notified when you need to refill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: $refillTracking)
                                .labelsHidden()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.05))
                        .cornerRadius(15)
                        .padding(.horizontal)
                    }
                    
                    // Supply fields (shown only if refill tracking is enabled)
                    if refillTracking {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Supply")
                                .font(.headline)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            HStack(spacing: 12) {
                                VStack(alignment: .leading) {
                                    Text("Current Supply")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("", text: $currentSupply)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                                .frame(maxWidth: .infinity)
                                
                                VStack(alignment: .leading) {
                                    Text("Total Supply")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    TextField("", text: $totalSupply)
                                        .keyboardType(.numberPad)
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(10)
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading) {
                        TextEditor(text: $notes)
                            .frame(minHeight: 100)
                            .padding(5)
                            .background(Color(.systemGray6))
                            .cornerRadius(15)
                            .overlay(
                                Group {
                                    if notes.isEmpty {
                                        Text("Add notes or special instructions...")
                                            .foregroundColor(Color(.placeholderText))
                                            .padding(10)
                                            .allowsHitTesting(false)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                            )
                            .padding(.horizontal)
                    }
                    
                    // Error Message
                    if let errorMessage = medicationViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: addMedication) {
                            if medicationViewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            } else {
                                Text("Add Medication")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(name.isEmpty || dosage.isEmpty || medicationViewModel.isLoading ? Color.blue.opacity(0.5) : Color.blue)
                        )
                        .disabled(name.isEmpty || dosage.isEmpty || medicationViewModel.isLoading)
                        .padding(.horizontal)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .fill(Color(.systemGray5))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
                .padding(.top)
            }
        }
        .navigationBarHidden(true)
    }
    
    // Helper function to get appropriate icon for frequency
    private func frequencyIcon(for frequency: MedicationFrequency) -> String {
        switch frequency {
        case .onceDaily:
            return "1.circle.fill"
        case .twiceDaily:
            return "2.circle.fill"
        case .threeTimesDaily:
            return "3.circle.fill"
        case .fourTimesDaily:
            return "4.circle.fill"
        }
    }
    
    // Helper function to get display value for duration
    private func displayValue(for duration: MedicationDuration) -> String {
        switch duration {
        case .sevenDays:
            return "7"
        case .fourteenDays:
            return "14"
        case .thirtyDays:
            return "30"
        case .ninetyDays:
            return "90"
        case .ongoing:
            return "∞"
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
    
    // Formatters for date and time display
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

// Custom Time Picker Sheet
struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
            }
            .navigationTitle("Select Time")
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}

