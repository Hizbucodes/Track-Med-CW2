//
//  TrackMedApp.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//


import SwiftUI
import Firebase

@main
struct TrackMedAppp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                LoginView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
