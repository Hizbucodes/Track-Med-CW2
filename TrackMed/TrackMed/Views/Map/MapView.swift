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
    @EnvironmentObject var favorites: Favorites
    @State private var showingFavorites = false
    @State private var isShowingFilterOptions = false // To control the presentation of filter options
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            // MARK: - Map Layer
            Map(coordinateRegion: $mapViewModel.region, showsUserLocation: true, annotationItems: mapViewModel.pharmacies) { pharmacy in
                MapAnnotation(coordinate: pharmacy.coordinate) {
                    Button(action: { mapViewModel.selectedLocation = pharmacy }) { Image(systemName: mapViewModel.showType == .pharmacy ? "pills.circle.fill" : "heart.circle.fill") .font(.title) .foregroundColor(mapViewModel.showType == .pharmacy ? .blue : .pink) .background(Color.white.clipShape(Circle())) } } } .ignoresSafeArea()

            // MARK: - UI Overlay
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)

                        TextField("Search Pharmacies or Wellness", text: $mapViewModel.searchText)
                            .focused($isSearchFocused)
                            .onSubmit {
                                mapViewModel.searchNearby(keyword: mapViewModel.searchText)
                            }

                        if !mapViewModel.searchText.isEmpty {
                            Button(action: {
                                mapViewModel.searchText = ""
                                isSearchFocused = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 16)
                    .background(Color.white)

                    .cornerRadius(50)

                    // Filter button
                    Button(action: {
                        isShowingFilterOptions = true // Show filter options when tapped
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                    .sheet(isPresented: $isShowingFilterOptions) { // Present filter options in a sheet
                        FilterOptionsView(selectedType: $mapViewModel.showType) { newType in
                            mapViewModel.showType = newType
                            if newType == .pharmacy {
                                mapViewModel.fetchNearbyPharmacies()
                            } else {
                                mapViewModel.fetchNearbyWellnessCenters()
                            }
                        }
                        .presentationDetents([.medium]) // Adjust the size of the sheet as needed
                    }
                }
                .padding(.horizontal)
                Button(action: { showingFavorites = true }) {
                                    Image(systemName: "heart.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                        .padding(10)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 3)
                                }
                                .padding(.trailing, 16)
                                .frame(maxWidth: .infinity, alignment: .trailing)

                Spacer()
                
                

                // MARK: - Bottom Detail Card
                if let selectedLocation = mapViewModel.selectedLocation {
                    LocationDetailCard(
                                        location: selectedLocation,
                                        isFavorite: favorites.contains(selectedLocation),
                                        toggleFavorite: { favorites.toggle(selectedLocation) },
                                        getDirections: {
                                            mapViewModel.getDirections(to: selectedLocation)
                                        },
                                        closeAction: {
                                            mapViewModel.selectedLocation = nil
                                        }
                                    )
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: mapViewModel.selectedLocation)
                    .padding(.bottom, 60)
                }
            }
            .onAppear {
                if mapViewModel.searchText.isEmpty {
                    if mapViewModel.showType == .pharmacy {
                        mapViewModel.fetchNearbyPharmacies()
                    } else {
                        mapViewModel.fetchNearbyWellnessCenters()
                    }
                }
            }
        }.sheet(isPresented: $showingFavorites) {
            FavoritesView()
                .environmentObject(mapViewModel)
                .environmentObject(favorites)
        }
    }

    struct LocationDetailCard: View {
        let location: Pharmacy
        let isFavorite: Bool
            let toggleFavorite: () -> Void
        let getDirections: () -> Void
        let closeAction: () -> Void

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

                    Button(action: closeAction) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Button(action: toggleFavorite) {
                                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                                            .foregroundColor(isFavorite ? .red : .gray)
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
}
