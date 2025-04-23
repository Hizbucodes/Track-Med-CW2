//
//  CalenderView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel // Add this
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()

    var selectedDateLogs: [MedicationLog] {
        medicationViewModel.medicationLogs.filter {
            Calendar.current.isDate($0.timeScheduled, inSameDayAs: selectedDate)
        }
        .sorted { $0.timeScheduled < $1.timeScheduled }
    }

    var selectedDateAppointments: [Appointment] {
        appointmentViewModel.appointments(for: selectedDate) // Use the function from AppointmentViewModel
            .sorted { $0.time < $1.time }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy" // Added year for clarity
        return formatter
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
            VStack(spacing: 0) {
                // Calendar header
                HStack {
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.headline)

                    Spacer()

                    Button(action: {
                        selectedDate = Date()
                    }) {
                        Text("Today")
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemBackground))

                // Calendar view
                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .background(Color(.systemBackground))

                // Schedule for selected date (Medications and Appointments)
                if medicationViewModel.isLoading || appointmentViewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if selectedDateLogs.isEmpty && selectedDateAppointments.isEmpty {
                    VStack {
                        Spacer()
                        Text("No medications or appointments scheduled for this day")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            if !selectedDateLogs.isEmpty {
                                Text("Medications")
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ForEach(selectedDateLogs) { log in
                                    MedicationLogRow(log: log) {
                                        medicationViewModel.markMedicationAs(
                                            log.status == .taken ? .scheduled : .taken,
                                            logId: log.id ?? "",
                                            completion: { _ in }
                                        )
                                    }
                                }
                            }

                            if !selectedDateAppointments.isEmpty {
                                Text("Appointments")
                                    .font(.title3)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ForEach(selectedDateAppointments) { appointment in
                                    AppointmentScheduleRow(appointment: appointment)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear {
                if let userId = authViewModel.user?.id { // Assuming AuthViewModel is available if needed
                    appointmentViewModel.fetchAppointments(for: userId) // Ensure appointments are fetched
                }
            }
        }
    }
}

// Ensure AppointmentScheduleRow and MedicationLogRow are defined elsewhere
