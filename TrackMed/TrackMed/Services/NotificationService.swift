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
        content.title = "Appointment Reminder"
        content.body = "You have an appointment with Dr. \(appointment.doctorName) at \(appointment.hospital)"
        content.sound = .default

       
        if let reminderDate = Calendar.current.date(byAdding: .hour, value: -5, to: appointment.date) {
            let dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = "appointment_5hours_\(appointment.id ?? UUID().uuidString)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error scheduling appointment notification: \(error.localizedDescription)")
                }
            }
        } else {
            print("Could not calculate reminder date.")
        }
    }

    
    func scheduleAppointmentAtTime(appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Doctor Appointment Reminder"
        content.body = "You have an appointment with Dr. \(appointment.doctorName) at \(appointment.hospital)"
        content.sound = .default

        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: appointment.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let identifier = "appointment_at_time_\(appointment.id ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling appointment notification: \(error.localizedDescription)")
            }
        }
    }
    
    
    func scheduleAppointmentCompletedNotification(appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Appointment Completed"
        content.body = "Your appointment with \(appointment.doctorName) at \(appointment.hospital) has been marked as completed."
        content.sound = .default

      
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "appointment_completed_\(appointment.id ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling completed appointment notification: \(error.localizedDescription)")
            }
        }
    }


    
    func scheduleAppointmentCancelledNotification(appointment: Appointment) {
        let content = UNMutableNotificationContent()
        content.title = "Appointment Cancelled"
        content.body = "Your appointment with \(appointment.doctorName) at \(appointment.hospital) has been cancelled."
        content.sound = .default

       
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "appointment_cancelled_\(appointment.id ?? UUID().uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling cancelled appointment notification: \(error.localizedDescription)")
            }
        }
    }


    
    func scheduleRefillReminder(medication: Medication) {
        let content = UNMutableNotificationContent()
        content.title = "Medication Refill Reminder"
        content.body = "Your supply of \(medication.name) is running low. Time to refill!"
        content.sound = .default
        
        
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
        let identifiers = [
            "appointment_5hours_\(appointmentId)",
            "appointment_at_time_\(appointmentId)"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    
    func clearAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
    }
}
