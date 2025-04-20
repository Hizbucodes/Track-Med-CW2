//
//  MapView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var mapViewModel: MapViewModel
    @State private var selectedFilter: LocationType = .pharmacy
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map
                Map(coordinateRegion: $mapViewModel.region, showsUserLocation: true, annotationItems: mapViewModel.pharmacies) { pharmacy in
                    MapAnnotation(coordinate: pharmacy.coordinate) {
                        Button(action: {
                            mapViewModel.selectedLocation = pharmacy
                        }) {
                            Image(systemName: "pills.circle.fill")
                                .font(.title)
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                        }
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                
                VStack {
                    HStack {
                        Picker("Location Type", selection: $selectedFilter) {
                            Text("Pharmacies").tag(LocationType.pharmacy)
                            Text("Wellness").tag(LocationType.wellness)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedFilter) { newValue in
                            mapViewModel.showType = newValue
                            if newValue == .pharmacy {
                                mapViewModel.fetchNearbyPharmacies()
                            } else {
                                mapViewModel.fetchNearbyWellnessCenters()
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(10)
                    .padding()
                    
                    Spacer()
                    
                    if let selectedLocation = mapViewModel.selectedLocation {
                        LocationDetailCard(location: selectedLocation) {
                            mapViewModel.getDirections(to: selectedLocation)
                        }
                        .transition(.move(edge: .bottom))
                        .animation(.spring(), value: mapViewModel.selectedLocation)
                    }
                }
            }
            .navigationTitle("Nearby Locations")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                mapViewModel.fetchNearbyPharmacies()
            }
        }
    }
}

struct LocationDetailCard: View {
    let location: Pharmacy
    let getDirections: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name)
                        .font(.headline)
                    
                    Text(location.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if location.isOpen24Hours {
                    Text("Open 24h")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(20)
                } else if let hours = location.openingHours {
                    Text(hours)
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(20)
                }
            }
            
            if let phone = location.phoneNumber {
                Button(action: {
                    let tel = "tel://" + phone.replacingOccurrences(of: "-", with: "")
                    if let url = URL(string: tel) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                        
                        Text(phone)
                            .foregroundColor(.blue)
                    }
                }
            }
            
            HStack {
                Spacer()
                
                Button(action: getDirections) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Get Directions")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 0)
        .padding()
    }
}
