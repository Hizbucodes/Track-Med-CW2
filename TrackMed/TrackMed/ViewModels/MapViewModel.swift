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

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var pharmacies: [Pharmacy] = []
    @Published var region = MKCoordinateRegion()
    @Published var selectedLocation: Pharmacy?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var showType: LocationType = .pharmacy
    @Published var searchText: String = "" {
        didSet {
            searchNearby(keyword: searchText)
        }
    }


    private let db = Firestore.firestore()
    private let locationManager = CLLocationManager()
    private var cancellables = Set<AnyCancellable>()
    private var hasFetchedOnce = false

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, !hasFetchedOnce else { return }
        DispatchQueue.main.async {
            self.userLocation = location.coordinate
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            
            if self.showType == .pharmacy {
                self.fetchNearbyPharmacies()
            } else {
                self.fetchNearbyWellnessCenters()
            }
            self.hasFetchedOnce = true
            self.locationManager.stopUpdatingLocation() // Stop after first valid fetch
        }
    }


    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "Failed to get location: \(error.localizedDescription)"
        }
    }

    func searchNearby(keyword: String) {
        guard let userLocation = userLocation else {
            self.errorMessage = "Location not available"
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword.isEmpty
            ? (showType == .pharmacy ? "Pharmacy" : "Wellness Center")
            : keyword

        request.region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )

        let search = MKLocalSearch(request: request)
        isLoading = true

        search.start { response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }

                guard let items = response?.mapItems else {
                    self.errorMessage = "No results found"
                    return
                }

                self.pharmacies = items.map { Pharmacy(from: $0) }
            }
        }
    }

    
   
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .denied, .restricted:
            errorMessage = "Enable location services in Settings"
        default: break
        }
    }

    func fetchNearbyPharmacies() {
        searchNearby(keyword: "Pharmacy")
    }

    func fetchNearbyWellnessCenters() {
        searchNearby(keyword: "Wellness Center")
    }

    func getDirections(to pharmacy: Pharmacy) {
        guard userLocation != nil else { return }

        let placemark = MKPlacemark(coordinate: pharmacy.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = pharmacy.name

        MKMapItem.openMaps(
            with: [mapItem],
            launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        )
    }
}
