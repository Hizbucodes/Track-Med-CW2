//
//  CalenderView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    
    var selectedDateLogs: [MedicationLog] {
        medicationViewModel.medicationLogs.filter { log in
            Calendar.current.isDate(log.timeScheduled, inSameDayAs: selectedDate)
        }
        .sorted { $0.timeScheduled < $1.timeScheduled }
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }
    
    var body: some View {
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
                
                // Medication schedule for selected date
                if medicationViewModel.isLoading {
                    ProgressView()
                        .padding(.top, 40)
                } else if selectedDateLogs.isEmpty {
                    VStack {
                        Spacer()
                        Text("No medications scheduled for this day")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
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
                        .padding()
                    }
                }
            }
            .navigationTitle("Calendar")
            .navigationBarItems(leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
