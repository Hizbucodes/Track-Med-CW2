//
//  MockMedicationService.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-25.
//


class MockMedicationService: MedicationServiceProtocol {
    var medications: [Medication] = []
    
    func fetchMedications() -> [Medication] {
        return medications
    }
    
    func addMedication(_ medication: Medication) {
        medications.append(medication)
    }
}
