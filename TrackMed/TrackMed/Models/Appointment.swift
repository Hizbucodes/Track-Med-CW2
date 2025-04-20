//
//  Appointment.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import FirebaseFirestore

struct Appointment: Identifiable, Codable {
    @DocumentID var id: String?
    var doctorName: String
    var hospital: String
    var specialty: String
    var forWhom: String
    var date: Date
    var time: Date
    var notes: String?
    var remindersEnabled: Bool
    var userId: String
    var status: AppointmentStatus = .scheduled
    var createdAt: Date = Date()
    
    enum AppointmentStatus: String, Codable {
        case scheduled = "Scheduled"
        case completed = "Completed"
        case cancelled = "Cancelled"
    }
}
