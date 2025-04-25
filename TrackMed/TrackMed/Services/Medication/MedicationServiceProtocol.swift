//
//  MedicationServiceProtocol.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-25.
//

// MedicationServiceProtocol.swift
protocol MedicationServiceProtocol {
    func fetchMedications() -> [Medication]
    func addMedication(_ medication: Medication)
}
