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
            return appointmentViewModel.missedAppointments
        case .taken:
            return appointmentViewModel.completedAppointments
        default:
            return appointmentViewModel.appointments
        }
    }

    // MARK: - View

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
                .accessibilityLabel("Back")
                .accessibilityHint("Go back to previous screen")

                Text("History Log")
                    .font(.title2)
                    .fontWeight(.bold)
                    .accessibilityAddTraits(.isHeader)

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
                        .accessibilityLabel("Show all logs")
                        .accessibilityHint("Double tap to show all medication and appointment logs")
                        FilterTab(title: "Taken", isSelected: selectedFilter == .taken) {
                            selectedFilter = .taken
                        }
                        .accessibilityLabel("Show taken logs")
                        .accessibilityHint("Double tap to show only taken medications and completed appointments")
                        FilterTab(title: "Missed", isSelected: selectedFilter == .missed) {
                            selectedFilter = .missed
                        }
                        .accessibilityLabel("Show missed logs")
                        .accessibilityHint("Double tap to show only missed medications and appointments")
                    }
                    .padding(.top, 8)

                    // Content
                    if medicationViewModel.isLoading || appointmentViewModel.isLoading {
                        ProgressView()
                            .padding(.top, 40)
                            .accessibilityLabel("Loading history logs")
                            .accessibilityHint("Please wait while the history logs are loading")
                    } else if filteredLogs.isEmpty && filteredAppointments.isEmpty {
                        VStack {
                            Spacer()
                            Text("No entries found")
                                .foregroundColor(.secondary)
                                .accessibilityLabel("No entries found")
                                .accessibilityHint("There are no medication or appointment logs for the selected filter")
                            Spacer()
                        }
                    } else {
                        List {
                            // Medication Logs
                            if !filteredLogs.isEmpty {
                                ForEach(sortedGroupKeys, id: \.self) { key in
                                    Section(header:
                                        Text(key)
                                            .accessibilityAddTraits(.isHeader)
                                            .accessibilityLabel(key)
                                    ) {
                                        ForEach(groupedLogs[key] ?? []) { log in
                                            MedicationHistoryRow(log: log)
                                        }
                                    }
                                }
                            }

                            // Appointments
                            if !filteredAppointments.isEmpty {
                                Section(header:
                                    Text("Appointments")
                                        .accessibilityAddTraits(.isHeader)
                                        .accessibilityLabel("Appointments")
                                ) {
                                    ForEach(filteredAppointments) { appointment in
                                        AppointmentHistoryRow(appointment: appointment)
                                    }
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("History log list")
                    }
                }
                .onAppear {
                    if let userId = authViewModel.user?.id {
                        medicationViewModel.fetchMedicationLogs(for: userId, status: selectedFilter)
                        appointmentViewModel.fetchAppointments(for: userId)
                    }
                }
            }
        }
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
        .accessibilityLabel(title)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint("Double tap to filter logs by \(title)")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(log.medicationName), \(log.dosage), scheduled at \(timeFormatter.string(from: log.timeScheduled)), status: \(log.status.rawValue)")
        .accessibilityHint("Medication log entry")
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(appointment.doctorName), \(appointment.specialty), at \(appointment.hospital), on \(appointment.date.formatted(date: .abbreviated, time: .shortened)), status: \(appointment.status.rawValue)\(appointment.notes != nil && !appointment.notes!.isEmpty ? ", notes: \(appointment.notes!)" : "")")
        .accessibilityHint("Appointment log entry")
    }
}
