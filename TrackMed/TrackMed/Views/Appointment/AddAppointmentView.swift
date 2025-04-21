//
//  AddAppointmentView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct AddAppointmentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = AppointmentViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var doctorName = ""
    @State private var hospital = ""
    @State private var specialty = ""
    @State private var forWhom = "Me"
    @State private var date = Date()
    @State private var time = Date()
    @State private var notes = ""
    @State private var remindersEnabled = true
    @State private var showWhoOptions = false
    @State private var showDatePicker = false
    
    private let whoOptions = ["Me", "Mom", "Child", "Spouse", "Dad", "Sister", "Brother", "Other"]
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
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
                
                Text("Doctor Appointment")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            .padding()
            .background(Color(red: 0.95, green: 0.97, blue: 1.0))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Doctor name
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Doctor name")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.gray)
                            
                            TextField("e.g. Dr. Gunathilaka", text: $doctorName)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Hospital
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Consultant Hospital or channeling center")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                            
                            TextField("e.g. Asiri or channeling center kandy", text: $hospital)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Specialty
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specialty")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        HStack {
                            Image(systemName: "stethoscope")
                                .foregroundColor(.gray)
                            
                            TextField("e.g. Dermatologist", text: $specialty)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Who's Appointment
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who's Appointment")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Button(action: { showWhoOptions.toggle() }) {
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                
                                Text("e.g. Me")
                                    .foregroundColor(forWhom == "Me" ? .gray : .black)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Date and Time
                    HStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Appointment Date")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            Button(action: { showDatePicker.toggle() }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                    
                                    Text(dateFormatter.string(from: date))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Appointment Time")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                
                                // Time picker will use default system picker
                                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appointment Note")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if notes.isEmpty {
                                        Text("Add notes or special instructions...")
                                            .foregroundColor(.gray)
                                            .padding(.leading, 8)
                                            .padding(.top, 12)
                                            .allowsHitTesting(false)
                                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                                    }
                                }
                            )
                    }
                    
                    // Reminders
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "bell.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Reminders")
                                .font(.headline)
                            
                            Text("Get notified when it's time to take your medication")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $remindersEnabled)
                            .labelsHidden()
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                    .cornerRadius(10)
                    
                    Spacer(minLength: 30)
                    
                    // Add Appointment Button
                    Button(action: addAppointment) {
                        Text("Add Appointment")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(doctorName.isEmpty || hospital.isEmpty || specialty.isEmpty || viewModel.isLoading)
                    
                    // Cancel Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $date, isPresented: $showDatePicker)
        }
        .fullScreenCover(isPresented: $showWhoOptions) {
            WhoOptionsSheet(selectedOption: $forWhom, options: whoOptions, isPresented: $showWhoOptions)
        }
    }
    
    private func addAppointment() {
        guard let userId = authViewModel.user?.id else { return }
        
        // Combine date and time
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        let combinedDateTime = calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: 0,
            of: date
        ) ?? date
        
        let appointment = Appointment(
            doctorName: doctorName,
            hospital: hospital,
            specialty: specialty,
            forWhom: forWhom,
            date: date,
            time: combinedDateTime,
            notes: notes.isEmpty ? nil : notes,
            remindersEnabled: remindersEnabled,
            userId: userId
        )
        
        viewModel.addAppointment(appointment) { success in
            if success {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

// Helper view for the date picker sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                
                Button("Done") {
                    isPresented = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}

// Helper view for the who options sheet
struct WhoOptionsSheet: View {
    @Binding var selectedOption: String
    let options: [String]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                        isPresented = false
                    }) {
                        HStack {
                            Text(option)
                            
                            Spacer()
                            
                            if selectedOption == option {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Who's Appointment")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}
