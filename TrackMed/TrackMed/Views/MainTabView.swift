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
        ZStack(alignment: .bottom) {
        
            Group {
                if selectedTab == 0 {
                    HomeView()
                        .environmentObject(medicationViewModel)
                        .environmentObject(appointmentViewModel)
                        .onAppear {
                            if let userId = authViewModel.user?.id {
                                medicationViewModel.fetchMedications(for: userId)
                                appointmentViewModel.fetchAppointments(for: userId)
                            }
                        }
                } else if selectedTab == 1 {
                    MapView()
                        .environmentObject(mapViewModel)
                } else {
                    ProfileView()
                        .environmentObject(authViewModel)
                }
            }
            
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
                    .padding(.bottom, 0)
            }
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer()
            
            
            TabButton(
                iconName: "house.fill",
                isSelected: selectedTab == 0,
                action: { selectedTab = 0 }
            ).accessibilityLabel("Home Screen")
            
            Spacer()
            
            
            TabButton(
                iconName: "paperplane.fill",
                isSelected: selectedTab == 1,
                action: { selectedTab = 1 }
            ).accessibilityLabel("Map Screen")
            
            Spacer()
            
           
            TabButton(
                iconName: "person.fill",
                isSelected: selectedTab == 2,
                action: { selectedTab = 2 }
            ).accessibilityLabel("Profile Screen")
            
            Spacer()
        }
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.95, green: 0.97, blue: 1.0))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 0)
        )
        .padding(.horizontal, 16)
    }
}

struct TabButton: View {
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .environment(\.symbolVariants, .none)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? Color.blue : Color.gray.opacity(0.8))
                
                
                Circle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(width: 4, height: 4)
            }
            .frame(height: 40)
        }
    }
}


struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(AuthViewModel())
            .environmentObject(MedicationViewModel())
            .environmentObject(AppointmentViewModel())
            .environmentObject(MapViewModel())
    }
}
