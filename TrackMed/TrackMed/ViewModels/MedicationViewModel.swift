//
//  MedicationViewModel.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore

class MedicationViewModel: ObservableObject {
    @Published var medications: [Medication] = []
    @Published var medicationLogs: [MedicationLog] = []
    @Published var todayMedications: [Medication] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    deinit {
        listenerRegistration?.remove()
    }
    
    func fetchMedications(for userId: String) {
        isLoading = true
        
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("medications")
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error fetching medications: \(error.localizedDescription)"
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.medications = []
                    return
                }
                
                self.medications = documents.compactMap { document in
                    try? document.data(as: Medication.self)
                }
                
                self.fetchTodayMedications(for: userId)
            }
    }
    
    func fetchTodayMedications(for userId: String) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        db.collection("medicationLogs")
            .whereField("userId", isEqualTo: userId)
            .whereField("timeScheduled", isGreaterThanOrEqualTo: startOfDay)
            .whereField("timeScheduled", isLessThan: endOfDay)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.errorMessage = "Error fetching today's medications: \(error.localizedDescription)"
                    return
                }
                
                let logs = snapshot?.documents.compactMap { try? $0.data(as: MedicationLog.self) } ?? []
                
                // Get unique medications for today
                var medicationIds = Set<String>()
                for log in logs {
                    medicationIds.insert(log.medicationId)
                }
                
                self.todayMedications = self.medications.filter { medication in
                    guard let id = medication.id else { return false }
                    return medicationIds.contains(id)
                }
            }
    }
    
    func fetchMedicationLogs(for userId: String, status: MedicationStatus? = nil) {
        isLoading = true
        
        var query: Query = db.collection("medicationLogs")
            .whereField("userId", isEqualTo: userId)
            .order(by: "timeScheduled", descending: true)
        
        if let status = status {
            query = query.whereField("status", isEqualTo: status.rawValue)
        }
        
        query.getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error fetching medication logs: \(error.localizedDescription)"
                return
            }
            
            self.medicationLogs = snapshot?.documents.compactMap { try? $0.data(as: MedicationLog.self) } ?? []
        }
    }
    
    // MARK: - CRUD Operations
    
    func addMedication(_ medication: Medication, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        do {
            let docRef = try db.collection("medications").addDocument(from: medication)
            
            // Schedule notifications if enabled
            if medication.remindersEnabled {
                for time in medication.times {
                    NotificationService.shared.scheduleMedicationReminder(
                        medication: medication,
                        time: time
                    )
                }
            }
            
            // Generate medication logs for the duration
            self.generateMedicationLogs(medication: medication, medicationId: docRef.documentID)
            
            isLoading = false
            completion(true)
        } catch {
            errorMessage = "Error adding medication: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }
    
    func updateMedication(_ medication: Medication, completion: @escaping (Bool) -> Void) {
        guard let id = medication.id else {
            errorMessage = "Medication ID is missing"
            completion(false)
            return
        }
        
        isLoading = true
        
        do {
            try db.collection("medications").document(id).setData(from: medication)
            
            // Update notifications
            NotificationService.shared.cancelMedicationNotifications(medicationId: id)
            
            if medication.remindersEnabled {
                for time in medication.times {
                    NotificationService.shared.scheduleMedicationReminder(
                        medication: medication,
                        time: time
                    )
                }
            }
            
            isLoading = false
            completion(true)
        } catch {
            errorMessage = "Error updating medication: \(error.localizedDescription)"
            isLoading = false
            completion(false)
        }
    }
    
    func deleteMedication(id: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        db.collection("medications").document(id).delete { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "Error deleting medication: \(error.localizedDescription)"
                self.isLoading = false
                completion(false)
                return
            }
            
            // Delete associated logs
            self.db.collection("medicationLogs")
                .whereField("medicationId", isEqualTo: id)
                .getDocuments { snapshot, error in
                    if let error = error {
                        self.errorMessage = "Error fetching logs: \(error.localizedDescription)"
                        self.isLoading = false
                        completion(false)
                        return
                    }
                    
                    let batch = self.db.batch()
                    snapshot?.documents.forEach { document in
                        batch.deleteDocument(document.reference)
                    }
                    
                    batch.commit { error in
                        self.isLoading = false
                        
                        if let error = error {
                            self.errorMessage = "Error deleting logs: \(error.localizedDescription)"
                            completion(false)
                        } else {
                            // Cancel notifications
                            NotificationService.shared.cancelMedicationNotifications(medicationId: id)
                            completion(true)
                        }
                    }
                }
        }
    }
    
    func markMedicationAs(_ status: MedicationStatus, logId: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        let docRef = db.collection("medicationLogs").document(logId)
        
        docRef.updateData([
            "status": status.rawValue,
            "timeTaken": status == .taken ? Date() : nil
        ]) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error updating medication status: \(error.localizedDescription)"
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateMedicationSupply(id: String, currentSupply: Int, completion: @escaping (Bool) -> Void) {
        isLoading = true
        
        db.collection("medications").document(id).updateData([
            "currentSupply": currentSupply
        ]) { [weak self] error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error updating medication supply: \(error.localizedDescription)"
                completion(false)
            } else {
                // Check if refill notification should be triggered
                if let medication = self.medications.first(where: { $0.id == id }),
                   let total = medication.totalSupply,
                   Double(currentSupply) / Double(total) <= 0.2 {
                    NotificationService.shared.scheduleRefillReminder(medication: medication)
                }
                
                completion(true)
            }
        }
    }
    
    // Helper methods
    
    private func generateMedicationLogs(medication: Medication, medicationId: String) {
        let calendar = Calendar.current
        
        // Calculate end date based on duration
        let endDate: Date
        let startDate = medication.startDate
        
        switch medication.duration {
        case .sevenDays:
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate)!
        case .fourteenDays:
            endDate = calendar.date(byAdding: .day, value: 14, to: startDate)!
        case .thirtyDays:
            endDate = calendar.date(byAdding: .day, value: 30, to: startDate)!
        case .ninetyDays:
            endDate = calendar.date(byAdding: .day, value: 90, to: startDate)!
        case .ongoing:
            // For ongoing, schedule for 3 months ahead
            endDate = calendar.date(byAdding: .month, value: 3, to: startDate)!
        }
        
        var currentDate = startDate
        let batch = db.batch()
        
        while currentDate <= endDate {
            for time in medication.times {
                let components = calendar.dateComponents([.hour, .minute], from: time)
                
                guard let scheduleTime = calendar.date(
                    bySettingHour: components.hour ?? 0,
                    minute: components.minute ?? 0,
                    second: 0,
                    of: currentDate
                ) else { continue }
                
                // Skip if the time is in the past
                if scheduleTime < Date() {
                    continue
                }
                
                let log = MedicationLog(
                    medicationId: medicationId,
                    medicationName: medication.name,
                    dosage: medication.dosage,
                    timeScheduled: scheduleTime,
                    status: .scheduled,
                    userId: medication.userId
                )
                
                do {
                    let docRef = db.collection("medicationLogs").document()
                    try batch.setData(from: log, forDocument: docRef)
                } catch {
                    print("Error creating log: \(error)")
                }
            }
            
            // Move to next day
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        // Commit the batch
        batch.commit { error in
            if let error = error {
                print("Error committing logs batch: \(error)")
            }
        }
    }
    
    var dailyProgress: Double {
        let totalToday = todayMedications.count
        if totalToday == 0 { return 0 }
        
        let takenCount = medicationLogs.filter { $0.status == .taken && Calendar.current.isDateInToday($0.timeScheduled) }.count
        return Double(takenCount) / Double(totalToday)
    }
    
    var takenMedicationsCount: Int {
        medicationLogs.filter { $0.status == .taken && Calendar.current.isDateInToday($0.timeScheduled) }.count
    }
    
    var totalMedicationsForToday: Int {
        medicationLogs.filter { Calendar.current.isDateInToday($0.timeScheduled) }.count
    }
}
