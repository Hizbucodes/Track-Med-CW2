//
//  Medication.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import FirebaseFirestore

enum MedicationFrequency: String, Codable, CaseIterable {
    case onceDaily = "Once daily"
    case twiceDaily = "Twice daily"
    case threeTimesDaily = "Three times daily"
    case fourTimesDaily = "Four times daily"
}

enum MedicationDuration: String, Codable, CaseIterable {
    case sevenDays = "7 days"
    case fourteenDays = "14 days"
    case thirtyDays = "30 days"
    case ninetyDays = "90 days"
    case ongoing = "Ongoing"
}

enum MedicationStatus: String, Codable {
    case taken = "Taken"
    case missed = "Missed"
    case scheduled = "Scheduled"
}

struct Medication: Identifiable, Codable {
    @DocumentID var id: String?
    var name: String
    var dosage: String
    var frequency: MedicationFrequency
    var duration: MedicationDuration
    var startDate: Date
    var times: [Date]
    var remindersEnabled: Bool
    var refillTracking: Bool
    var notes: String?
    var userId: String
    var currentSupply: Int?
    var totalSupply: Int?
    
    var progress: Double {
        guard let current = currentSupply, let total = totalSupply, total > 0 else {
            return 0.0
        }
        return Double(current) / Double(total)
    }
}

struct MedicationLog: Identifiable, Codable {
    @DocumentID var id: String?
    var medicationId: String
    var medicationName: String
    var dosage: String
    var timeScheduled: Date
    var timeTaken: Date?
    var status: MedicationStatus
    var userId: String
    var createdAt: Date = Date()
}
