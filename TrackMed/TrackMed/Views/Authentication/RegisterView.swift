//
//  RegisterView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false

    // Per-field error messages
    @State private var usernameError: String?
    @State private var emailError: String?
    @State private var passwordError: String?
    @State private var confirmPasswordError: String?

    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !authViewModel.isLoading
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    private func isValidPassword(_ password: String) -> Bool {
        // At least 6 characters, at least one number
        let passwordRegEx = "^(?=.*[0-9]).{6,}$"
        let passwordPred = NSPredicate(format: "SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Back button
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    Spacer()
                }
                .padding(.top, 10)

                // App logo and title
                VStack(spacing: 10) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.white)
                        .padding(20)
                        .background(Color.blue)
                        .cornerRadius(12)
                    Text("NAVIGATION")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .font(.caption)
                }
                .padding(.top, 10)

                // Main headline
                VStack(alignment: .leading, spacing: 8) {
                    Text("Register now to")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("access your account")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Effortlessly register, access your account, and enjoy seamless convenience!")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 10)

                // Form fields
                VStack(spacing: 24) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Username")
                            .fontWeight(.medium)
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            TextField("Enter your username", text: $username)
                                .autocapitalization(.words)
                        }
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        if let error = usernameError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Email")
                            .fontWeight(.medium)
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            TextField("Enter your email address", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        if let error = emailError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Password")
                            .fontWeight(.medium)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                            } else {
                                SecureField("Enter your password", text: $password)
                            }
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        if let error = passwordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Confirm password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Confirm Password")
                            .fontWeight(.medium)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            if isConfirmPasswordVisible {
                                TextField("Enter your confirm password", text: $confirmPassword)
                            } else {
                                SecureField("Enter your confirm password", text: $confirmPassword)
                            }
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                        if let error = confirmPasswordError {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    // Server-side error message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 10)

                // Sign up button
                Button(action: {
                    // Reset all errors
                    usernameError = nil
                    emailError = nil
                    passwordError = nil
                    confirmPasswordError = nil
                    authViewModel.errorMessage = nil

                    var isValid = true

                    if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        usernameError = "Please enter your username."
                        isValid = false
                    }
                    if !isValidEmail(email) {
                        emailError = "Please enter a valid email address."
                        isValid = false
                    }
                    if !isValidPassword(password) {
                        passwordError = "Password must be at least 6 characters and contain at least one number."
                        isValid = false
                    }
                    if password != confirmPassword {
                        confirmPasswordError = "Passwords don't match."
                        isValid = false
                    }

                    if isValid {
                        authViewModel.signUp(name: username, email: email, password: password)
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign up")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(
                    isFormValid ? Color.blue : Color.blue.opacity(0.5)
                )
                .cornerRadius(30)
                .disabled(!isFormValid)
                .padding(.top, 15)

                // Already have an account option
                HStack {
                    Text("Already have an account?")
                        .font(.subheadline)
                    Button("Sign in") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
}
