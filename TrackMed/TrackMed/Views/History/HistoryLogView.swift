//
//  HistoryLogView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct HistoryLogView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedFilter: MedicationStatus?
    @State private var showClearConfirmation = false
    
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Filter tabs
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
                
                if medicationViewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if filteredLogs.isEmpty {
                    VStack {
                        Spacer()
                        Text("No medication logs found")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(sortedGroupKeys, id: \.self) { key in
                            Section(header: Text(key)) {
                                ForEach(groupedLogs[key] ?? []) { log in
                                    MedicationHistoryRow(log: log)
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
            .navigationTitle("History Log")
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
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
                }
            }
        }
    }
    
    private func clearAllLogs() {
        // This would implement the logic for clearing all logs
        // In a real implementation, you'd call a method on the viewModel
    }
}

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
