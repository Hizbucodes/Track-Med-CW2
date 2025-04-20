//
//  NotificationService.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {}
    
    func requestPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Error requesting notification permissions: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleMedicationReminder(medication: Medication, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Reminder"
        content.body = "Time to take \(medication.name) \(medication.dosage)"
        content.sound = .default
        
        // Extract hour and minute components for daily repeating notification
        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let identifier = "medication_\(medication.id ?? UUID().uuidString)_\(components.hour ?? 0)_\(components.minute ?? 0)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling medication notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleAppointmentReminder(appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Doctor Appointment Reminder"
        content.body = "You have an appointment with Dr. \(appointment.doctorName) tomorrow at \(appointment.hospital)"
        content.sound = .default
        
        // Set reminder for 1 day before
        let appointmentDate = appointment.date
        if let reminderDate = Calendar.current.date(byAdding: .day, value: -1, to: appointmentDate) {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let identifier = "appointment_\(appointment.id ?? UUID().uuidString)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling appointment notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleRefillReminder(medication: Medication) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Refill Reminder"
        content.body = "Your supply of \(medication.name) is running low. Time to refill!"
        content.sound = .default
        
        // Trigger immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let identifier = "refill_\(medication.id ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling refill notification: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelMedicationNotifications(medicationId: String) {
        notificationCenter.getPendingNotificationRequests { requests in
            let identifiers = requests.filter { $0.identifier.starts(with: "medication_\(medicationId)") }
                                      .map { $0.identifier }
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    func cancelAppointmentNotification(appointmentId: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["appointment_\(appointmentId)"])
    }
    
    func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}
