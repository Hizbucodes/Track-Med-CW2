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

            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    switch errorCode {
                    case .wrongPassword, .invalidEmail, .userNotFound, .invalidCredential:
                        self.errorMessage = "Incorrect email or password. Please try again."
                    case .networkError:
                        self.errorMessage = "Network error. Please check your connection."
                    default:
                        self.errorMessage = error.localizedDescription
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                }
                self.isLoading = false
                return
            }

            if let userId = result?.user.uid {
                self.fetchUserData(userId: userId)
            }
        }
    }

    
    func signUp(name: String, email: String, password: String) {
        // Client-side validation
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.errorMessage = "Please enter your name."
            return
        }
        if !isValidEmail(email) {
            self.errorMessage = "Please enter a valid email address."
            return
        }
        if !isValidPassword(password) {
            self.errorMessage = "Password must be at least 6 characters and contain at least one number."
            return
        }

        isLoading = true
        errorMessage = nil

        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error as NSError? {
                if let errorCode = AuthErrorCode(rawValue: error.code) {
                    switch errorCode {
                    case .emailAlreadyInUse:
                        self.errorMessage = "This email is already registered."
                    case .invalidEmail:
                        self.errorMessage = "Please enter a valid email address."
                    case .weakPassword:
                        self.errorMessage = "Password is too weak."
                    default:
                        self.errorMessage = error.localizedDescription
                    }
                } else {
                    self.errorMessage = error.localizedDescription
                }
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
    
    func updatePassword(currentPassword: String, newPassword: String, completion: @escaping (Result<Bool, Error>) -> Void) {
          guard let user = Auth.auth().currentUser else {
              completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
              return
          }
          
          // Re-authenticate first
          let credential = EmailAuthProvider.credential(
              withEmail: user.email ?? "",
              password: currentPassword
          )
          
          user.reauthenticate(with: credential) { _, error in
              if let error = error {
                  completion(.failure(error))
                  return
              }
              
              // Update password after successful re-authentication
              user.updatePassword(to: newPassword) { error in
                  if let error = error {
                      completion(.failure(error))
                  } else {
                      completion(.success(true))
                  }
              }
          }
      }
    
    
      func handlePasswordResetError(_ error: Error) -> String {
          if let errorCode = AuthErrorCode(rawValue: error._code) {
              switch errorCode {
              case .invalidEmail:
                  return "Please enter a valid email address"
              case .userNotFound:
                  return "No account found with this email"
              default:
                  return error.localizedDescription
              }
          }
          return "Unknown error occurred"
      }
      
      func sendPasswordReset(email: String, completion: @escaping (Result<Bool, Error>) -> Void) {
          Auth.auth().sendPasswordReset(withEmail: email) { error in
              if let error = error {
                  completion(.failure(error))
              } else {
                  completion(.success(true))
              }
          }
      }
    
   
    func authenticateWithBiometrics(completion: @escaping (Bool) -> Void) {
        BiometricAuthService.authenticate { [weak self] success, error in
            DispatchQueue.main.async {
                if success {
                    self?.isAuthenticated = true // Auto-login on success
                } else {
                    self?.errorMessage = error ?? "Biometric authentication failed"
                }
                completion(success)
            }
        }
    }


}
