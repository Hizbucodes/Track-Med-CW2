//
//  HomeView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showNotifications = false
    @State private var showAddMedication = false
    @State private var showCalendar = false
    @State private var showHistoryLog = false
    @State private var showRefillTracker = false
    @State private var showAddAppointment = false
    
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
                                // Track
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                                    .frame(width: 180, height: 180)
                                
                                // Progress
                                Circle()
                                    .trim(from: 0, to: medicationViewModel.dailyProgress)
                                    .stroke(Color.blue, lineWidth: 12)
                                    .frame(width: 180, height: 180)
                                    .rotationEffect(.degrees(-90))
                                
                                // Content
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
                                
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 10, height: 10)
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
                                    text: "View Calender",
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
                        
                        if medicationViewModel.medicationLogs.isEmpty {
                            HStack {
                                Spacer()
                                Text("No medications scheduled for today")
                                    .foregroundColor(.secondary)
                                    .padding()
                                Spacer()
                            }
                            .frame(height: 80)
                            .background(Color(.systemBackground))
                            .cornerRadius(12)
                        } else {
                            ForEach(medicationViewModel.medicationLogs.filter { Calendar.current.isDateInToday($0.timeScheduled) }) { log in
                                MedicationLogRow(log: log) {
                                    medicationViewModel.markMedicationAs(
                                        log.status == .taken ? .scheduled : .taken,
                                        logId: log.id ?? "",
                                        completion: { _ in }
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
//            .sheet(isPresented: $showNotifications) {
//                NotificationsView()
//            }
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
                }
            }
        }
    }
}

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

struct MedicationLogRow: View {
    let log: MedicationLog
    let toggleAction: () -> Void
    @State private var isFavorite = false
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        HStack {
            // Favorite button
            Button(action: { isFavorite.toggle() }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .gray)
            }
            .padding(.trailing, 4)
            
            // Medication info
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
                    
                    Text(dateFormatter.string(from: log.timeScheduled))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Status button
            if log.status == .taken {
                HStack {
                    Text("Taken")
                        .font(.subheadline)
                    Image(systemName: "checkmark")
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray5))
                .cornerRadius(20)
            } else {
                Button(action: toggleAction) {
                    Text("Take")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}



#Preview {
    HomeView()
        .environmentObject(MedicationViewModel())
        .environmentObject(AuthViewModel())// If needed
}

