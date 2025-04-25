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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Doctor name")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        
                        HStack {
                            Image(systemName: "person.circle")
                                .foregroundColor(.gray)
                            
                            TextField("e.g. Dr. Gunathilaka", text: $doctorName).accessibilityLabel("Doctor name")
                                .accessibilityHint("Enter the doctor's name")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Consultant Hospital or channeling center")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.gray)
                            
                            TextField("e.g. Asiri or channeling center kandy", text: $hospital).accessibilityLabel("Hospital or channeling center")
                                .accessibilityHint("Enter the hospital or channeling center")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specialty")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        
                        HStack {
                            Image(systemName: "stethoscope")
                                .foregroundColor(.gray)
                            
                            TextField("e.g. Dermatologist", text: $specialty).accessibilityLabel("Specialty")
                                .accessibilityHint("Enter the doctor's specialty")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 50)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Who's Appointment")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        Button(action: { showWhoOptions.toggle() }) {
                            HStack {
                                Image(systemName: "person")
                                    .foregroundColor(.gray)
                                
                                Text(forWhom.isEmpty ? "e.g. Me" : forWhom)
                                    .foregroundColor(forWhom == "Me" ? .gray : .black)

                                
                                Spacer()
                                
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }.accessibilityLabel("Appointment for")
                            .accessibilityValue(forWhom)
                            .accessibilityHint("Double tap to select who the appointment is for")
                    }
                    
                    
                    HStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Appointment Date")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .accessibilityHidden(true)
                            Button(action: { showDatePicker.toggle() }) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.gray)
                                        .accessibilityHidden(true)
                                    Text(dateFormatter.string(from: date))
                                        .foregroundColor(.black)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                        .accessibilityHidden(true)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 50)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }.accessibilityLabel("Appointment date")
                                .accessibilityValue(dateFormatter.string(from: date))
                                .accessibilityHint("Double tap to select appointment date")
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Appointment Time")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .accessibilityHidden(true)
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.gray)
                                    .accessibilityHidden(true)
                        
                                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                                    .labelsHidden()
                                    .frame(maxWidth: .infinity)
                                    .accessibilityLabel("Appointment time")
                                                                        .accessibilityValue(
                                                                            DateFormatter.localizedString(from: time, dateStyle: .none, timeStyle: .short))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 50)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Appointment Note")
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        TextEditor(text: $notes)
                            .frame(height: 100)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            ).accessibilityLabel("Appointment notes")
                            .accessibilityHint("Add notes or special instructions")
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
                    
                    
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "bell.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 16))
                                .accessibilityHidden(true)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("Reminders")
                                .font(.headline)
                                .accessibilityHidden(true)
                            Text("Get notified when it's time for appointment schedule")
                                .font(.caption)
                                .foregroundColor(.gray).accessibilityHidden(true)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $remindersEnabled)
                            .labelsHidden()
                            .accessibilityLabel("Reminders")
                            .accessibilityValue(remindersEnabled ? "On" : "Off")
                            .accessibilityHint("Double tap to toggle appointment reminders")
                    }
                    .padding()
                    .background(Color(red: 0.95, green: 0.97, blue: 1.0))
                    .cornerRadius(10)
                    
                    Spacer(minLength: 30)
                    
                    
                    Button(action: addAppointment) {
                        Text("Add Appointment")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(doctorName.isEmpty || hospital.isEmpty || specialty.isEmpty || viewModel.isLoading ? Color.blue.opacity(0.5) : Color.blue)
                            .cornerRadius(50)
                    }
                    .disabled(doctorName.isEmpty || hospital.isEmpty || specialty.isEmpty || viewModel.isLoading)
                    .accessibilityLabel("Add appointment")
                                        .accessibilityHint("Double tap to save this appointment")
                    
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(50)
                    }.accessibilityLabel("Cancel")
                        .accessibilityHint("Double tap to cancel and go back")
                }
                .padding()
                .padding(.bottom, 40)
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
            date: combinedDateTime,
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


struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
                    .accessibilityLabel("Select appointment date")
                Button("Done") {
                    isPresented = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
                .accessibilityLabel("Done")
                                .accessibilityHint("Double tap to confirm date selection")
                Spacer()
            }
            .navigationTitle("Select Date")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            })
        }
    }
}


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
                                    .accessibilityLabel("\(option) selected")
                            }
                        }
                    }.accessibilityLabel(option)
                        .accessibilityHint(selectedOption == option ? "Currently selected" : "Double tap to select \(option)")
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Who's Appointment")
            .navigationBarItems(trailing: Button("Close") {
                isPresented = false
            }.accessibilityLabel("Close")
                .accessibilityHint("Double tap to close"))
        }
    }
}
