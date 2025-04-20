////
////  NotificationsView.swift
////  TrackMed
////
////  Created by Hizbullah 006 on 2025-04-20.
////
//
//import SwiftUI
//
//struct NotificationsView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var medicationViewModel: MedicationViewModel
//    
//    @State private var notifications: [NotificationItem] = []
//    
//    var body: some View {
//        NavigationView {
//            ZStack {
//                if notifications.isEmpty {
//                    VStack(spacing: 16) {
//                        Image(systemName: "bell.slash")
//                            .font(.system(size: 48))
//                            .foregroundColor(.gray)
//                            .padding(.bottom, 8)
//                        
//                        Text("No notifications")
//                            .font(.title3)
//                            .fontWeight(.semibold)
//                        
//                        Text("You don't have any notifications at the moment.")
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal, 32)
//                    }
//                } else {
//                    List {
//                        ForEach(notifications) { notification in
//                            NotificationRow(notification: notification)
//                        }
//                    }
//                    .listStyle(InsetGroupedListStyle())
//                }
//            }
//            .navigationTitle("Notifications")
//            .navigationBarItems(trailing: Button("Close") {
//                presentationMode.wrappedValue.dismiss()
//            })
//            .onAppear {
//                // Generate sample notifications based on upcoming medications
//                generateSampleNotifications()
//            }
//        }
//    }
//    
//    private func generateSampleNotifications() {
//        let calendar = Calendar.current
//        
//        // Today's medications
//        let todayLogs = medicationViewModel.medicationLogs.filter { Calendar.current.isDateInToday($0.timeScheduled) }
//            .sorted { $0.timeScheduled < $1.timeScheduled }
//        
//        var notificationItems: [NotificationItem] = []
//        
//        for (index, log) in todayLogs.enumerated() {
//            let isUpcoming = log.timeScheduled > Date()
//            
//            if isUpcoming {
//                notificationItems.append(
//                    NotificationItem(
//                        id: "med_\(index)",
//                        title: "Medication Reminder",
//                        message: "Time to take \(log.medicationName) \(log.dosage)",
//                        time: log.timeScheduled,
//                        type: .medication
//                    )
//                )
//            }
//        }
//        
//        // Add a refill reminder if applicable
//        let lowSupplyMeds = medicationViewModel.medications.filter { med in
//            guard let current = med.currentSupply, let total = med.totalSupply else { return false }
//            return Double(current) / Double(total) <= 0.2
//        }
//        
//        for med in lowSupplyMeds {
//            notificationItems.append(
//                NotificationItem(
//                    id: "refill_\(med.id ?? "")",
//                    title: "Refill Reminder",
//                    message: "Your supply of \(med.name) is running low. Time to refill!",
//                    time: Date().addingTimeInterval(-3600), // 1 hour ago
//                    type: .refill
//                )
//            )
//        }
//        
//        notifications = notificationItems.sorted(by: { $0.time > $1.time })
//    }
//}
//
//enum NotificationType {
//    case medication
//    case appointment
//    case refill
//}
//
//struct NotificationItem: Identifiable {
//    let id: String
//    let title: String
//    let message: String
//    let time: Date
//    let type: NotificationType
//}
//
//struct Notification
