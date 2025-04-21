//
//  MapViewModel.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import MapKit
import Combine

enum LocationType {
    case pharmacy
    case wellness
}

class MapViewModel: ObservableObject {
    @Published var pharmacies: [Pharmacy] = []
    @Published var region = MKCoordinateRegion()
    @Published var selectedLocation: Pharmacy?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var showType: LocationType = .pharmacy
    
    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        if let location = locationManager.location?.coordinate {
            userLocation = location
            region = MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
    }
    
    func fetchNearbyPharmacies() {
        isLoading = true
        
        guard let userLocation = userLocation else {
            errorMessage = "Unable to determine your location"
            isLoading = false
            return
        }
        
        // In a real app, you would query a database or API for pharmacies near the user's location
        // For this example, we'll create some sample data
        
        let samplePharmacies = [
            Pharmacy(
                name: "Central Pharmacy",
                address: "123 Main St",
                phoneNumber: "123-456-7890",
                latitude: userLocation.latitude + 0.01,
                longitude: userLocation.longitude - 0.01,
                openingHours: "9 AM - 9 PM",
                isOpen24Hours: false
            ),
            Pharmacy(
                name: "MediCare Pharmacy",
                address: "456 A9 road",
                phoneNumber: "987-654-3210",
                latitude: userLocation.latitude - 0.01,
                longitude: userLocation.longitude + 0.01,
                openingHours: "8 AM - 10 PM",
                isOpen24Hours: false
            ),
            Pharmacy(
                name: "24/7 Pharmacy",
                address: "789 Pine St",
                phoneNumber: "555-123-4567",
                latitude: userLocation.latitude + 0.015,
                longitude: userLocation.longitude + 0.015,
                openingHours: nil,
                isOpen24Hours: true
            )
        ]
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.pharmacies = samplePharmacies
            self.isLoading = false
        }
    }
    
    func fetchNearbyWellnessCenters() {
        // Similar implementation to fetchNearbyPharmacies but for wellness centers
        // For this example, we'll use the same model structure
    }
    
    func getDirections(to pharmacy: Pharmacy) {
        guard userLocation != nil else { return }
        
        let placemark = MKPlacemark(coordinate: pharmacy.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pharmacy.name
        
        MKMapItem.openMaps(
            with: [mapItem],
            launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ]
        )
    }
}
