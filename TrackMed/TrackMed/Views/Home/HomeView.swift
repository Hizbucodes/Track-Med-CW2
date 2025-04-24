//
//  HomeView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var showNotifications = false
    @State private var showAddMedication = false
    @State private var showCalendar = false
    @State private var showHistoryLog = false
    @State private var showRefillTracker = false
    @State private var showAddAppointment = false

    // Today's Medications
    var todaysMedicationLogs: [MedicationLog] {
        medicationViewModel.medicationLogs.filter { Calendar.current.isDateInToday($0.timeScheduled) }
    }

    // Today's Appointments
    var todaysAppointments: [Appointment] {
        appointmentViewModel.appointments.filter { Calendar.current.isDateInToday($0.date) }
    }
    
    var notificationCount: Int {
        // Medication reminders for today that are upcoming
        let todayLogs = medicationViewModel.medicationLogs.filter { Calendar.current.isDateInToday($0.timeScheduled) && $0.timeScheduled > Date() }
        // Today's appointments
        let todayAppointments = appointmentViewModel.appointments.filter { Calendar.current.isDateInToday($0.date) }
        // Low supply medications
        let lowSupplyMeds = medicationViewModel.medications.filter { med in
            guard let current = med.currentSupply, let total = med.totalSupply else { return false }
            return Double(current) / Double(total) <= 0.2
        }
        return todayLogs.count + todayAppointments.count + lowSupplyMeds.count
    }


    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Progress section
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Daily Progress")
                                .font(.headline)
                                .fontWeight(.bold)
                            ZStack {
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                    .frame(width: 180, height: 180)
                                Circle()
                                    .trim(from: 0, to: medicationViewModel.dailyProgress)
                                    .stroke(Color.blue, lineWidth: 12)
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(-90))
                                VStack {
                                    Text("\(Int(medicationViewModel.dailyProgress * 100))%")
                                        .font(.system(size: 36, weight: .bold))
                                    Text("\(medicationViewModel.takenMedicationsCount) of \(medicationViewModel.totalMedicationsForToday) doses")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                        }
                        .padding(20)
                        .background(Color(.systemBackground))
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)

                        // Notification bell
                        Button(action: {
                            showNotifications = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bell.fill")
                                    .font(.title3)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                // Show the red badge only if there are notifications
                                if notificationCount > 0 {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 10, height: 10)
                                }
                            }
                        }
                        .padding(12)

                    }

                    // Quick Actions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.headline)
                            .fontWeight(.bold)

                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                QuickActionButton(
                                    icon: "plus",
                                    text: "Add Medication",
                                    action: { showAddMedication = true }
                                )
                                QuickActionButton(
                                    icon: "calendar",
                                    text: "View Calendar",
                                    action: { showCalendar = true }
                                )
                            }
                            HStack(spacing: 12) {
                                QuickActionButton(
                                    icon: "clock.arrow.circlepath",
                                    text: "History Log",
                                    action: { showHistoryLog = true }
                                )
                                QuickActionButton(
                                    icon: "pills",
                                    text: "Refill Tracker",
                                    action: { showRefillTracker = true }
                                )
                            }
                            QuickActionButton(
                                icon: "person.crop.circle.badge.plus",
                                text: "Add Doctor Appointment",
                                action: { showAddAppointment = true }
                            )
                        }
                    }
                    .padding(.bottom, 30)

                    // Today's Schedule
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Today's Schedule")
                                .font(.headline)
                                .fontWeight(.bold)
                            Spacer()
                            Button("See All") {
                                showCalendar = true
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                        }

                        if todaysMedicationLogs.isEmpty && todaysAppointments.isEmpty {
                            HStack {
                                Spacer()
                                Text("No medications or appointments scheduled for today")
                                    .foregroundColor(.secondary)
                                    .padding()
                                Spacer()
                            }
                            .frame(height: 80)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        } else {
                            // Show today's medication logs
                            ForEach(todaysMedicationLogs) { log in
                                MedicationLogRow(log: log) {
                                    medicationViewModel.markMedicationAs(
                                        log.status == .taken ? .scheduled : .taken,
                                        logId: log.id ?? "",
                                        completion: { _ in }
                                    )
                                }
                            }
                            // Show today's appointments
                            ForEach(todaysAppointments) { appointment in
                                AppointmentScheduleRow(appointment: appointment)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .sheet(isPresented: $showNotifications) {
                NotificationsView()
                    .environmentObject(medicationViewModel)
            }
            .sheet(isPresented: $showAddMedication) {
                AddMedicationView()
                    .environmentObject(medicationViewModel)
            }
            .sheet(isPresented: $showCalendar) {
                CalendarView()
                    .environmentObject(medicationViewModel)
            }
            .sheet(isPresented: $showHistoryLog) {
                HistoryLogView()
                    .environmentObject(medicationViewModel)
                    .environmentObject(appointmentViewModel)
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showRefillTracker) {
                RefillTrackerView()
                    .environmentObject(medicationViewModel)
            }
            .sheet(isPresented: $showAddAppointment) {
                AddAppointmentView()
                    .environmentObject(authViewModel)
            }
            .onAppear {
                if let userId = authViewModel.user?.id {
                    medicationViewModel.fetchMedications(for: userId)
                    medicationViewModel.fetchMedicationLogs(for: userId)
                    appointmentViewModel.fetchAppointments(for: userId)
                }
            }
        }
    }
}

// MARK: - QuickActionButton

struct QuickActionButton: View {
    let icon: String
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                Text(text)
                    .font(.system(size: 14))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

// MARK: - AppointmentScheduleRow

struct AppointmentScheduleRow: View {
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel

    let appointment: Appointment

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .foregroundColor(.green)
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.doctorName)
                    .font(.headline)
                Text(appointment.specialty)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(timeFormatter.string(from: appointment.time))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()

            Text(appointment.status == .scheduled ? "Scheduled" : appointment.status.rawValue)
                .font(.subheadline)
                .foregroundColor(statusColor(for: appointment.status))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(statusColor(for: appointment.status).opacity(0.1))
                )

            if appointment.status == .scheduled {
                Menu {
                    Button("Cancel", role: .destructive) {
                        updateStatus(to: .cancelled)
                    }
                    Button("Complete") {
                        updateStatus(to: .completed)
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5)) // Adjust size as needed
                            .foregroundColor(.gray)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundColor(.gray)
                        Image(systemName: "circle.fill")
                            .font(.system(size: 5))
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    func statusColor(for status: Appointment.AppointmentStatus) -> Color {
        switch status {
        case .scheduled:
            return .blue
        case .completed:
            return .green
        case .cancelled, .missed:
            return .red
        }
    }

    func updateStatus(to newStatus: Appointment.AppointmentStatus) {
        if let appointmentId = appointment.id {
            appointmentViewModel.updateAppointmentStatus(id: appointmentId, status: newStatus) { success in
                if success {
                    print("Appointment status updated to \(newStatus)")
                } else {
                    print("Error updating appointment status to \(newStatus)")
                }
            }
        }
    }
}

struct MedicationLogRow: View {
    let log: MedicationLog
    let onToggle: () -> Void

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        HStack {
            Image(systemName: "pills")
                .foregroundColor(.blue)
            VStack(alignment: .leading, spacing: 4) {
                Text(log.medicationName)
                    .font(.headline)
                Text(log.dosage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(timeFormatter.string(from: log.timeScheduled))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if log.status == .taken {
                HStack(spacing: 4) {
                    Text("Taken")
                        .font(.subheadline)
                    Image(systemName: "checkmark")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .cornerRadius(20)
            } else {
                Button(action: onToggle) {
                    Text("Take")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(Color(red: 0.95, green: 0.98, blue: 1.0))
        .cornerRadius(16)
    }
}
