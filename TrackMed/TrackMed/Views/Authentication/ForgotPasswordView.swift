//
//  ForgotPasswordView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-23.
//

import SwiftUICore
import SwiftUI

struct ForgotPasswordView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "lock.rotation")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Text("Reset Password")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    Text("Enter your email to receive password reset instructions")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                }
                
                // Email field
                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                // Error message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                // Success message
                if showSuccess {
                    Text("Reset email sent successfully!")
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                // Submit button
                Button(action: sendResetEmail) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(email.isEmpty || isLoading)
                
                Spacer()
            }
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func sendResetEmail() {
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return
        }
        
        isLoading = true
        errorMessage = nil
        showSuccess = false
        
        authViewModel.sendPasswordReset(email: email) { result in
            isLoading = false
            switch result {
            case .success:
                showSuccess = true
                // Auto-dismiss after 2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    presentationMode.wrappedValue.dismiss()
                }
            case .failure(let error):
                errorMessage = authViewModel.handlePasswordResetError(error)
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
