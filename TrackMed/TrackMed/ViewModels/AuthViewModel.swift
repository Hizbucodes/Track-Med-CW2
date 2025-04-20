//
//  AuthViewModel.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import LocalAuthentication
import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        checkAuthStatus()
    }
    
    private func checkAuthStatus() {
        if let currentUser = auth.currentUser {
            fetchUserData(userId: currentUser.uid)
        }
    }
    
    func signIn(email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        auth.signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            if let userId = result?.user.uid {
                self.fetchUserData(userId: userId)
            }
        }
    }
    
    func signUp(name: String, email: String, password: String) {
        isLoading = true
        errorMessage = nil
        
        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
                return
            }
            
            if let userId = result?.user.uid {
                let newUser = User(id: userId, email: email, name: name)
                self.saveUserData(user: newUser)
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            self.errorMessage = "Error signing out: \(error.localizedDescription)"
        }
    }
    
    private func fetchUserData(userId: String) {
        isLoading = true
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorMessage = "Error fetching user data: \(error.localizedDescription)"
                return
            }
            
            if let document = document, document.exists {
                do {
                    let user = try document.data(as: User.self)
                    DispatchQueue.main.async {
                        self.user = user
                        self.isAuthenticated = true
                    }
                } catch {
                    self.errorMessage = "Error decoding user data: \(error.localizedDescription)"
                }
            } else {
                self.errorMessage = "User document not found"
            }
        }
    }
    
    private func saveUserData(user: User) {
        guard let userId = user.id else { return }
        
        do {
            try db.collection("users").document(userId).setData(from: user)
            self.user = user
            self.isAuthenticated = true
            self.isLoading = false
        } catch {
            self.errorMessage = "Error saving user data: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
    
    func updateProfile(name: String? = nil, language: String? = nil, useBiometricAuth: Bool? = nil) {
        guard var currentUser = user, let userId = currentUser.id else { return }
        isLoading = true
        
        if let name = name {
            currentUser.name = name
        }
        
        if let language = language {
            currentUser.language = language
        }
        
        if let useBiometricAuth = useBiometricAuth {
            currentUser.useBiometricAuth = useBiometricAuth
        }
        
        saveUserData(user: currentUser)
    }
    
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access your medical data"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        completion(true)
                    } else {
                        self.errorMessage = authenticationError?.localizedDescription
                        completion(false)
                    }
                }
            }
        } else {
            self.errorMessage = "Biometric authentication not available"
            completion(false)
        }
    }
}
