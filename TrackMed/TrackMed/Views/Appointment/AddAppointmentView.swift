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
    
    private let whoOptions = ["Me", "Spouse", "Child", "Parent", "Other"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Doctor Information")) {
                    TextField("Doctor Name", text: $doctorName)
                    TextField("Hospital/Clinic", text: $hospital)
                    TextField("Specialty", text: $specialty)
                    
                    Picker("Who's Appointment", selection: $forWhom) {
                        ForEach(whoOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                
                Section(header: Text("Appointment Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    Toggle("Get Reminders", isOn: $remindersEnabled)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: addAppointment) {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Add Appointment")
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .disabled(doctorName.isEmpty || hospital.isEmpty || specialty.isEmpty || viewModel.isLoading)
                }
            }
            .navigationTitle("Doctor Appointment")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
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
