//
//  Pharmacy.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import MapKit

import MapKit

struct Pharmacy: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let phoneNumber: String?
    let latitude: Double
    let longitude: Double
    let openingHours: String?
    let isOpen24Hours: Bool

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // Initializer to convert MKMapItem
    init(from item: MKMapItem) {
        self.name = item.name ?? "Unknown"
        self.address = item.placemark.title ?? "No address"
        self.phoneNumber = item.phoneNumber
        self.latitude = item.placemark.coordinate.latitude
        self.longitude = item.placemark.coordinate.longitude
        self.openingHours = nil
        self.isOpen24Hours = false
    }

    // Equatable conformance
    static func ==(lhs: Pharmacy, rhs: Pharmacy) -> Bool {
        lhs.id == rhs.id
    }
}

