//
//  AppointmentViewModel.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class AppointmentViewModel: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchAppointments(for userId: String) {
        isLoading = true
        
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("appointments")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching appointments: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.appointments = []
                    return
                }
                
                self.appointments = documents.compactMap { document in
                    try? document.data(as: Appointment.self)
                }
            }
    }
    
    func addAppointment(_ appointment: Appointment, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        do {
            _ = try db.collection("appointments").addDocument(from: appointment)
            
            if appointment.remindersEnabled {
                NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
            }
            
            isLoading = false
            completion(true)
        } catch {
            errorMessage = "Error adding appointment: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }
    
    func updateAppointment(_ appointment: Appointment, completion: @escaping (Bool) -> Void) {
        guard let id = appointment.id else {
            errorMessage = "Appointment ID is missing"
            completion(false)
            return
        }
        
        isLoading = true
        
        do {
            try db.collection("appointments").document(id).setData(from: appointment)
            
            // Update notification
            NotificationService.shared.cancelAppointmentNotification(appointmentId: id)
            
            if appointment.remindersEnabled {
                NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
            }
            
            isLoading = false
            completion(true)
        } catch {
            errorMessage = "Error updating appointment: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }
    
    func deleteAppointment(id: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        db.collection("appointments").document(id).delete { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error deleting appointment: \(error.localizedDescription)"
                completion(false)
            } else {
                NotificationService.shared.cancelAppointmentNotification(appointmentId: id)
                completion(true)
            }
        }
    }
    
    func updateAppointmentStatus(id: String, status: Appointment.AppointmentStatus, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        db.collection("appointments").document(id).updateData([
            "status": status.rawValue
        ]) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error updating appointment status: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}




// MARK: - Filtering Appointments

   func todaysScheduledAppointments(for date: Date = Date()) -> [Appointment] {
       let calendar = Calendar.current
       let startOfDay = calendar.startOfDay(for: date)
       let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

       return appointments.filter { appointment in
           appointment.status == .scheduled &&
           appointment.date >= startOfDay &&
           appointment.date < endOfDay
       }.sorted(by: { $0.time < $1.time }) // Sort by time
   }

   func scheduledAppointmentsForDate(_ date: Date) -> [Appointment] {
       let calendar = Calendar.current
       let startOfDay = calendar.startOfDay(for: date)
       let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

       return appointments.filter { appointment in
           appointment.status == .scheduled &&
           appointment.date >= startOfDay &&
           appointment.date < endOfDay
       }.sorted(by: { $0.time < $1.time }) // Sort by time
   }

   func pastAppointments() -> [Appointment] {
       let todayStartOfDay = Calendar.current.startOfDay(for: Date())
       return appointments.filter { appointment in
           appointment.date < todayStartOfDay
       }.sorted(by: { $0.date > $1.date }) // Show most recent first
   }

   func upcomingAppointments() -> [Appointment] {
       let todayEndOfDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
       return appointments.filter { appointment in
           appointment.date >= todayEndOfDay
       }.sorted(by: { $0.date < $1.date }) // Show soonest first
   }

   func allAppointmentsSortedByDate() -> [Appointment] {
       appointments.sorted(by: { $0.date < $1.date })
   }

// MARK: - CRUD Operations

    func addAppointment(_ appointment: Appointment, completion: @escaping (Bool) -> Void) {
        isLoading = true
        do {
            _ = try db.collection("appointments").addDocument(from: appointment) { error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error adding appointment: \(error.localizedDescription)"
                    completion(false)
                } else {
                    completion(true)
                    if appointment.remindersEnabled {
                        NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
                    }
                }
            }
        } catch {
            errorMessage = "Error encoding appointment: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }

    func updateAppointment(_ appointment: Appointment, completion: @escaping (Bool) -> Void) {
        isLoading = true
        guard let id = appointment.id else {
            errorMessage = "Appointment ID is missing"
            isLoading = false
            completion(false)
            return
        }

        do {
            try db.collection("appointments").document(id).setData(from: appointment) { error in
                self.isLoading = false
                if let error = error {
                    self.errorMessage = "Error updating appointment: \(error.localizedDescription)"
                    completion(false)
                } else {
                    NotificationService.shared.cancelAppointmentNotification(appointmentId: id)
                    if appointment.remindersEnabled {
                        NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
                    }
                    completion(true)
                }
            }
        } catch {
            errorMessage = "Error encoding appointment: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }

    func deleteAppointment(id: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        db.collection("appointments").document(id).delete { error in
            self.isLoading = false
            if let error = error {
                self.errorMessage = "Error deleting appointment: \(error.localizedDescription)"
                completion(false)
            } else {
                NotificationService.shared.cancelAppointmentNotification(appointmentId: id)
                completion(true)
            }
        }
    }

    func updateAppointmentStatus(id: String, status: Appointment.AppointmentStatus, completion: @escaping (Bool) -> Void) {
        isLoading = true
        db.collection("appointments").document(id).updateData([
            "status": status.rawValue
        ]) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false

            if let error = error {
                self.errorMessage = "Error updating appointment status: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
