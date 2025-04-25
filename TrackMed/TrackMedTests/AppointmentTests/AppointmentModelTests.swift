//
//  AppointmentModelTests.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-25.
//

import XCTest
@testable import TrackMed
import FirebaseFirestore

class AppointmentModelTests: XCTestCase {
    
    // MARK: - Initialization Tests
    func testAppointmentInitialization() {
        let date = Date()
        let time = Date().addingTimeInterval(3600) // 1 hour from now
        let appointment = Appointment(
            doctorName: "Dr. Smith",
            hospital: "General Hospital",
            specialty: "Cardiology",
            forWhom: "Myself",
            date: date,
            time: time,
            notes: "Bring insurance card",
            remindersEnabled: true,
            userId: "user123"
        )
        
        XCTAssertEqual(appointment.doctorName, "Dr. Smith")
        XCTAssertEqual(appointment.hospital, "General Hospital")
        XCTAssertEqual(appointment.forWhom, "Myself")
        XCTAssertEqual(appointment.date, date)
        XCTAssertEqual(appointment.time, time)
        XCTAssertTrue(appointment.remindersEnabled)
        XCTAssertEqual(appointment.status, .scheduled) // Default value
        XCTAssertNotNil(appointment.createdAt)
    }
    
    // MARK: - Default Values
    func testDefaultStatusAndCreatedAt() {
        let appointment = Appointment(
            doctorName: "Dr. Lee",
            hospital: "Clinic",
            specialty: "Dermatology",
            forWhom: "Child",
            date: Date(),
            time: Date(),
            remindersEnabled: false,
            userId: "user456"
        )
        
        XCTAssertEqual(appointment.status, .scheduled)
        XCTAssertLessThanOrEqual(abs(appointment.createdAt.timeIntervalSinceNow), 1.0)
    }
    
    // MARK: - Firestore Compatibility
    func testDocumentIDMapping() {
        var appointment = Appointment(
            doctorName: "Test",
            hospital: "Test",
            specialty: "Test",
            forWhom: "Test",
            date: Date(),
            time: Date(),
            remindersEnabled: false,
            userId: "testUser"
        )
        appointment.id = "apt_XYZ789" // Simulate Firestore ID
        XCTAssertEqual(appointment.id, "apt_XYZ789")
    }
    
    // MARK: - Status Transitions
    func testStatusUpdates() {
        var appointment = Appointment(
            doctorName: "Dr. Adams",
            hospital: "Urgent Care",
            specialty: "General Practice",
            forWhom: "Parent",
            date: Date(),
            time: Date(),
            remindersEnabled: true,
            userId: "user101"
        )
        
        appointment.status = .completed
        XCTAssertEqual(appointment.status, .completed)
        
        appointment.status = .missed
        XCTAssertEqual(appointment.status, .missed)
    }
}

// MARK: - AppointmentStatus Tests
class AppointmentStatusTests: XCTestCase {
    func testStatusRawValues() {
        XCTAssertEqual(Appointment.AppointmentStatus.scheduled.rawValue, "Scheduled")
        XCTAssertEqual(Appointment.AppointmentStatus.missed.rawValue, "Missed")
    }
    
    func testStatusDecoding() throws {
        let json = """
        ["Scheduled", "Completed", "Cancelled", "Missed"]
        """.data(using: .utf8)!
        let statuses = try JSONDecoder().decode([Appointment.AppointmentStatus].self, from: json)
        XCTAssertEqual(statuses, [.scheduled, .completed, .cancelled, .missed])
    }
}
