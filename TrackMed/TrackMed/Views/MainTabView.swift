//
//  MainTabView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var medicationViewModel = MedicationViewModel()
    @StateObject var appointmentViewModel = AppointmentViewModel()
    @StateObject var mapViewModel = MapViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .environmentObject(medicationViewModel)
                .environmentObject(appointmentViewModel)
                .onAppear {
                    if let userId = authViewModel.user?.id {
                        medicationViewModel.fetchMedications(for: userId)
                        appointmentViewModel.fetchAppointments(for: userId)
                    }
                }
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)
            
            MapView()
                .environmentObject(mapViewModel)
                .tabItem {
                    Label("Pharmacies", systemImage: "location")
                }
                .tag(1)
            
            ProfileView()
                .environmentObject(authViewModel)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
                .tag(2)
        }
    }
}


#Preview {
    MainTabView()
}
