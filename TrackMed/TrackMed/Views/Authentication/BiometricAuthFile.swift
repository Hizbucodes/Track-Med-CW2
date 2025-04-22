//
//  BiometricAuthFile.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-22.
//


import SwiftUI

struct BiometricAuthView: View {
    @State private var isUnlocked = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 24) {
            if isUnlocked {
                Text("Authenticated Successfully! 🎉")
                    .foregroundColor(.green)
            } else {
                Button {
                    authenticate()
                } label: {
                    HStack {
                        Image(systemName: BiometricAuthService.biometricType() == .faceID ? "faceid" : "touchid")
                        Text("Continue with \(BiometricAuthService.biometricType() == .faceID ? "Face ID" : "Touch ID")")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func authenticate() {
        BiometricAuthService.authenticate { success, error in
            if success {
                isUnlocked = true
                // Proceed to main app content
            } else {
                errorMessage = error ?? "Authentication failed"
            }
        }
    }
}
