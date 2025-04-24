//
//  NotificationsView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var medicationViewModel: MedicationViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel
    
    @State private var notifications: [NotificationItem] = []
    
    var body: some View {
        NavigationView {
            ZStack {
                if notifications.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                            .padding(.bottom, 8)
                        
                        Text("No notifications")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("You don't have any notifications at the moment.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                } else {
                    List {
                        ForEach(notifications) { notification in
                            NotificationRow(notification: notification)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("Notifications")
            .navigationBarItems(trailing:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color.black)
                        .clipShape(Circle())
                }
            )

            .onAppear {
                generateSampleNotifications()
            }
        }
    }
    
    private func generateSampleNotifications() {
        let calendar = Calendar.current
        

        let todayLogs = medicationViewModel.medicationLogs.filter { Calendar.current.isDateInToday($0.timeScheduled) }
            .sorted { $0.timeScheduled < $1.timeScheduled }
        
        var notificationItems: [NotificationItem] = []
        
        for (index, log) in todayLogs.enumerated() {
            let isUpcoming = log.timeScheduled > Date()
            
            if isUpcoming {
                notificationItems.append(
                    NotificationItem(
                        id: "med_\(index)",
                        title: "Medication Reminder",
                        message: "Time to take \(log.medicationName) \(log.dosage)",
                        time: log.timeScheduled,
                        type: .medication
                    )
                )
            }
        }
        
    
                let todayAppointments = appointmentViewModel.appointments.filter {
                    Calendar.current.isDateInToday($0.date)
                }
                for appointment in todayAppointments {
                    notificationItems.append(
                        NotificationItem(
                            id: "appointment_\(appointment.id ?? "")",
                            title: "Appointment Reminder",
                            message: "\(appointment.doctorName) at \(appointment.hospital)",
                            time: appointment.date,
                            type: .appointment
                        )
                    )
                }
        
        
    
        let lowSupplyMeds = medicationViewModel.medications.filter { med in
            guard let current = med.currentSupply, let total = med.totalSupply else { return false }
            return Double(current) / Double(total) <= 0.2
        }
        
        for med in lowSupplyMeds {
            notificationItems.append(
                NotificationItem(
                    id: "refill_\(med.id ?? "")",
                    title: "Refill Reminder",
                    message: "Your supply of \(med.name) is running low. Time to refill!",
                    time: Date().addingTimeInterval(-3600), // 1 hour ago
                    type: .refill
                )
            )
        }
        
        notifications = notificationItems.sorted(by: { $0.time > $1.time })
    }
}

