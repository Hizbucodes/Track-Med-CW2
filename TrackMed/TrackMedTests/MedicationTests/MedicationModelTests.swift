//
//  MedicationViewModelTests.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-25.
//

import XCTest
@testable import TrackMed
import FirebaseFirestore

class MedicationModelTests: XCTestCase {
    
    // MARK: - Medication Tests
    
    func testMedicationInitialization() {
        let date = Date()
        let med = Medication(
            name: "Ibuprofen",
            dosage: "200mg",
            frequency: .onceDaily,
            duration: .sevenDays,
            startDate: date,
            times: [date],
            remindersEnabled: true,
            refillTracking: false,
            userId: "user123"
        )
        
        XCTAssertEqual(med.name, "Ibuprofen")
        XCTAssertEqual(med.dosage, "200mg")
        XCTAssertEqual(med.frequency, .onceDaily)
        XCTAssertEqual(med.times.count, 1)
        XCTAssertTrue(med.remindersEnabled)
        XCTAssertFalse(med.refillTracking)
    }
    
    func testProgressCalculation() {
        let medWithSupply = Medication(
            name: "Test",
            dosage: "100mg",
            frequency: .onceDaily,
            duration: .sevenDays,
            startDate: Date(),
            times: [],
            remindersEnabled: false,
            refillTracking: false,
            userId: "user123",
            currentSupply: 5,
            totalSupply: 10
        )
        
        XCTAssertEqual(medWithSupply.progress, 0.5, accuracy: 0.001)
        
        let medNoSupply = Medication(
            name: "Test",
            dosage: "100mg",
            frequency: .onceDaily,
            duration: .sevenDays,
            startDate: Date(),
            times: [],
            remindersEnabled: false,
            refillTracking: false,
            userId: "user123"
        )
        
        XCTAssertEqual(medNoSupply.progress, 0.0)
    }
    
    func testFirestoreDocumentIDMapping() {
        var med = Medication(
            name: "Aspirin",
            dosage: "81mg",
            frequency: .onceDaily,
            duration: .ongoing,
            startDate: Date(),
            times: [],
            remindersEnabled: true,
            refillTracking: true,
            userId: "user456"
        )
        
        // Simulate Firestore document ID
        med.id = "med_12345"
        XCTAssertEqual(med.id, "med_12345")
    }
    
    // MARK: - MedicationLog Tests
    
    func testMedicationLogStatus() {
        let scheduledTime = Date()
        let logTaken = MedicationLog(
            medicationId: "med_123",
            medicationName: "Ibuprofen",
            dosage: "200mg",
            timeScheduled: scheduledTime,
            timeTaken: scheduledTime.addingTimeInterval(60),
            status: .taken,
            userId: "user123"
        )
        
        XCTAssertEqual(logTaken.status, .taken)
        XCTAssertNotNil(logTaken.timeTaken)
        
        let logMissed = MedicationLog(
            medicationId: "med_123",
            medicationName: "Ibuprofen",
            dosage: "200mg",
            timeScheduled: scheduledTime,
            timeTaken: nil,
            status: .missed,
            userId: "user123"
        )
        
        XCTAssertEqual(logMissed.status, .missed)
    }
    
    func testLogCreatedAtTimestamp() {
        let log = MedicationLog(
            medicationId: "med_123",
            medicationName: "Test",
            dosage: "50mg",
            timeScheduled: Date(),
            status: .scheduled,
            userId: "user123"
        )
        
        XCTAssertNotNil(log.createdAt)
        XCTAssertLessThanOrEqual(log.createdAt.timeIntervalSinceNow, 1.0)
    }
}

// MARK: - Enum Tests
class MedicationEnumTests: XCTestCase {
    
    func testMedicationFrequencyCases() {
        let cases = MedicationFrequency.allCases
        XCTAssertEqual(cases, [.onceDaily, .twiceDaily, .threeTimesDaily, .fourTimesDaily])
    }
    
    func testMedicationDurationRawValues() {
        XCTAssertEqual(MedicationDuration.sevenDays.rawValue, "7 days")
        XCTAssertEqual(MedicationDuration.ongoing.rawValue, "Ongoing")
    }
    
    func testMedicationStatusDecoding() throws {
        let jsonData = """
        ["Taken", "Missed", "Scheduled"]
        """.data(using: .utf8)!
        
        let statuses = try JSONDecoder().decode([MedicationStatus].self, from: jsonData)
        XCTAssertEqual(statuses, [.taken, .missed, .scheduled])
    }
}
