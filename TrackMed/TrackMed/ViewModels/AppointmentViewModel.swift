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
    
    // MARK: - Filtered Appointments
    
    var upcomingAppointments: [Appointment] {
        appointments.filter {
            $0.status == .scheduled && $0.date >= Date()
        }
        .sorted(by: { $0.date < $1.date })
    }

    var completedAppointments: [Appointment] {
        appointments.filter { $0.status == .completed }
            .sorted(by: { $0.date > $1.date })
    }

    var missedAppointments: [Appointment] {
        appointments.filter { $0.status == .missed && $0.date < Date() }
            .sorted(by: { $0.date > $1.date })
    }

    var cancelledAppointments: [Appointment] {
        appointments.filter { $0.status == .cancelled }
            .sorted(by: { $0.date > $1.date })
    }
    
    func appointments(for date: Date) -> [Appointment] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return appointments.filter { appointment in
            return appointment.time >= startOfDay && appointment.time < endOfDay
        }.sorted(by: { $0.time < $1.time })
    }
    
    // MARK: - Firestore CRUD
    
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
                NotificationService.shared.scheduleAppointmentAtTime(appointment: appointment)
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

            
            NotificationService.shared.cancelAppointmentNotification(appointmentId: id)

            if appointment.remindersEnabled {
                NotificationService.shared.scheduleAppointmentReminder(appointment: appointment)
                NotificationService.shared.scheduleAppointmentAtTime(appointment: appointment)
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
                if status == .completed || status == .cancelled {
                    NotificationService.shared.cancelAppointmentNotification(appointmentId: id)
                }
                
                if status == .cancelled {
                    self.db.collection("appointments").document(id).getDocument { snapshot, error in
                        if let appointment = try? snapshot?.data(as: Appointment.self) {
                            NotificationService.shared.scheduleAppointmentCancelledNotification(appointment: appointment)
                        }
                    }
                }
                
                if status == .completed {
                    self.db.collection("appointments").document(id).getDocument { snapshot, error in
                        if let appointment = try? snapshot?.data(as: Appointment.self) {
                            NotificationService.shared.scheduleAppointmentCompletedNotification(appointment: appointment)
                        }
                    }
                }
                completion(true)
            }
        }
    }




}
