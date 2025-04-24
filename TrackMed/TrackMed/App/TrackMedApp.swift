//
//  TrackMedApp.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//


import SwiftUI
import Firebase

@main
struct TrackMedApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var favorites = Favorites()
    
    @State private var showSplash = true
    @State private var showOnboarding = true

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView(isActive: $showSplash)
            } else if showOnboarding {
                OnboardingView(isOnboarding: $showOnboarding)
            } else if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
                    .environmentObject(favorites)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

