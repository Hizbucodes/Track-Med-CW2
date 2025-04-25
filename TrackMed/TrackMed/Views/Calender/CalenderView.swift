//
//  CalenderView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel
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
        appointmentViewModel.appointments(for: selectedDate)
            .sorted { $0.time < $1.time }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }

    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
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
                .accessibilityHint("Go back to the previous screen")

                Text("Calendar")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)
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
                            .accessibilityLabel("Selected date \(dateFormatter.string(from: selectedDate))")

                        Spacer()

                        Button(action: {
                            selectedDate = Date()
                        }) {
                            Text("Today")
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Today")
                        .accessibilityHint("Jump to today's date")
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
                    .accessibilityLabel("Calendar")
                    .accessibilityValue(dateFormatter.string(from: selectedDate))
                    .accessibilityHint("Swipe up or down to change the date")

                    // Schedule for selected date (Medications and Appointments)
                    if medicationViewModel.isLoading || appointmentViewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                            .accessibilityLabel("Loading schedule")
                            .accessibilityHint("Please wait while your schedule is loading")
                    } else if selectedDateLogs.isEmpty && selectedDateAppointments.isEmpty {
                        VStack {
                            Spacer()
                            Text("No medications or appointments scheduled for this day")
                                .foregroundColor(.secondary)
                                .accessibilityLabel("No medications or appointments scheduled for this day")
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
                                        .accessibilityAddTraits(.isHeader)
                                        .accessibilityLabel("Medications scheduled for \(dateFormatter.string(from: selectedDate))")
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
                                        .accessibilityAddTraits(.isHeader)
                                        .accessibilityLabel("Appointments scheduled for \(dateFormatter.string(from: selectedDate))")
                                    ForEach(selectedDateAppointments) { appointment in
                                        AppointmentScheduleRow(appointment: appointment)
                                        
                                    }
                                }
                            }
                            .padding()
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Schedule for \(dateFormatter.string(from: selectedDate))")
                    }
                }
                .onAppear {
                    if let userId = authViewModel.user?.id {
                        appointmentViewModel.fetchAppointments(for: userId)
                    }
                }
            }
        }
    }
}
