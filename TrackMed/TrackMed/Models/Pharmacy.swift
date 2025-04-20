//
//  Pharmacy.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import CoreLocation
import FirebaseFirestore

struct Pharmacy: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var address: String
    var phoneNumber: String?
    var latitude: Double
    var longitude: Double
    var openingHours: String?
    var isOpen24Hours: Bool
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
