//
//  HistoryLogView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct HistoryLogView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var selectedFilter: MedicationStatus?
    @State private var showClearConfirmation = false

    // MARK: - Medication Filtering

    var filteredLogs: [MedicationLog] {
        if let filter = selectedFilter {
            return medicationViewModel.medicationLogs.filter { $0.status == filter }
        } else {
            return medicationViewModel.medicationLogs
        }
    }

    var groupedLogs: [String: [MedicationLog]] {
        Dictionary(grouping: filteredLogs) { log in
            if Calendar.current.isDateInToday(log.timeScheduled) {
                return "Today"
            } else if Calendar.current.isDateInYesterday(log.timeScheduled) {
                return "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM d, yyyy"
                return formatter.string(from: log.timeScheduled)
            }
        }
    }

    var sortedGroupKeys: [String] {
        groupedLogs.keys.sorted { key1, key2 in
            if key1 == "Today" { return true }
            if key2 == "Today" { return false }
            if key1 == "Yesterday" { return true }
            if key2 == "Yesterday" { return false }

            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"

            guard let date1 = formatter.date(from: key1),
                  let date2 = formatter.date(from: key2) else {
                return key1 < key2
            }

            return date1 > date2
        }
    }

    // MARK: - Appointment Filtering

    var filteredAppointments: [Appointment] {
        switch selectedFilter {
        case .missed:
            // Missed: scheduled appointments in the past
            return appointmentViewModel.missedAppointments
        case .taken:
            // Taken: completed appointments
            return appointmentViewModel.completedAppointments
        default:
            // All: show all appointments
            return appointmentViewModel.appointments
        }
    }

    // MARK: - View

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
            
            Text("History Log")
                .font(.title2)
                .fontWeight(.bold)
            
            Spacer()
        }
        .padding()
        .background(Color(red: 0.95, green: 0.97, blue: 1.0))
        NavigationView {
            VStack(spacing: 0) {
                // Filter Tabs
                HStack(spacing: 0) {
                    FilterTab(title: "All", isSelected: selectedFilter == nil) {
                        selectedFilter = nil
                    }
                    FilterTab(title: "Taken", isSelected: selectedFilter == .taken) {
                        selectedFilter = .taken
                    }
                    FilterTab(title: "Missed", isSelected: selectedFilter == .missed) {
                        selectedFilter = .missed
                    }
                }
                .padding(.top, 8)

                // Content
                if medicationViewModel.isLoading || appointmentViewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if filteredLogs.isEmpty && filteredAppointments.isEmpty {
                    VStack {
                        Spacer()
                        Text("No entries found")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        // Medication Logs
                        if !filteredLogs.isEmpty {
                            ForEach(sortedGroupKeys, id: \.self) { key in
                                Section(header: Text(key)) {
                                    ForEach(groupedLogs[key] ?? []) { log in
                                        MedicationHistoryRow(log: log)
                                    }
                                }
                            }
                        }

                        // Appointments
                        if !filteredAppointments.isEmpty {
                            Section(header: Text("Appointments")) {
                                ForEach(filteredAppointments) { appointment in
                                    AppointmentHistoryRow(appointment: appointment)
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }

                // Clear All Data button
                Button(action: {
                    showClearConfirmation = true
                }) {
                    Text("Clear All Data")
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(Color(.systemBackground))
                .cornerRadius(0)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: -1)
            }
           
            .alert(isPresented: $showClearConfirmation) {
                Alert(
                    title: Text("Clear All Logs"),
                    message: Text("Are you sure you want to delete all medication logs? This action cannot be undone."),
                    primaryButton: .destructive(Text("Clear All")) {
                        clearAllLogs()
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                if let userId = authViewModel.user?.id {
                    medicationViewModel.fetchMedicationLogs(for: userId, status: selectedFilter)
                    appointmentViewModel.fetchAppointments(for: userId)
                }
            }
        }
    }

    private func clearAllLogs() {
        // Implement the logic for clearing all logs if needed
    }
}

// MARK: - FilterTab

struct FilterTab: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .foregroundColor(isSelected ? .blue : .primary)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isSelected ? .blue : .clear)
                        .padding(.top, 36)
                )
        }
        .background(Color(.systemBackground))
    }
}

// MARK: - MedicationHistoryRow

struct MedicationHistoryRow: View {
    let log: MedicationLog

    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.medicationName)
                    .font(.headline)

                Text(log.dosage)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Text(timeFormatter.string(from: log.timeScheduled))
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Text(log.status.rawValue)
                .font(.subheadline)
                .foregroundColor(log.status == .taken ? .green : (log.status == .missed ? .red : .gray))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            log.status == .taken
                                ? Color.green.opacity(0.1)
                                : (log.status == .missed ? Color.red.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                )
        }
    }
}

// MARK: - AppointmentHistoryRow

struct AppointmentHistoryRow: View {
    let appointment: Appointment

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.doctorName)
                    .font(.headline)
                Text(appointment.specialty)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(appointment.hospital)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(appointment.date.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                if let notes = appointment.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Text(appointment.status.rawValue)
                .font(.subheadline)
                .foregroundColor(appointment.status == .completed ? .green : .blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(appointment.status == .completed ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                )
        }
    }
}
