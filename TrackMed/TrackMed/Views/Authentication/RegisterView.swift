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
                    .accessibilityLabel("Back")
                    .accessibilityHint("Go back to previous screen")
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
                        .accessibilityLabel("TrackMed App Logo")
                        .accessibilityHint("Welcome to TrackMed")
                    Text("NAVIGATION")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .font(.caption)
                        .accessibilityHidden(true)
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Register now to access your account. Effortlessly register, access your account, and enjoy seamless convenience.")

                // Form fields
                VStack(spacing: 24) {
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Username")
                            .fontWeight(.medium)
                            .accessibilityHidden(true)
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                                .accessibilityHidden(true)
                            TextField("Enter your username", text: $username)
                                .autocapitalization(.words)
                                .accessibilityLabel("Username")
                                .accessibilityHint("Enter your username")
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
                                .accessibilityLabel("Username error: \(error)")
                        }
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Email")
                            .fontWeight(.medium)
                            .accessibilityHidden(true)
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                                .accessibilityHidden(true)
                            TextField("Enter your email address", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .accessibilityLabel("Email address")
                                .accessibilityHint("Enter your email address")
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
                                .accessibilityLabel("Email error: \(error)")
                        }
                    }

                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Password")
                            .fontWeight(.medium)
                            .accessibilityHidden(true)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                                .accessibilityHidden(true)
                            if isPasswordVisible {
                                TextField("Enter your password", text: $password)
                                    .accessibilityLabel("Password")
                                    .accessibilityHint("Enter your password")
                            } else {
                                SecureField("Enter your password", text: $password)
                                    .accessibilityLabel("Password")
                                    .accessibilityHint("Enter your password")
                            }
                            Button(action: {
                                isPasswordVisible.toggle()
                            }) {
                                Image(systemName: isPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                            .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
                            .accessibilityHint("Double tap to toggle password visibility")
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
                                .accessibilityLabel("Password error: \(error)")
                        }
                    }

                    // Confirm password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter Confirm Password")
                            .fontWeight(.medium)
                            .accessibilityHidden(true)
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                                .accessibilityHidden(true)
                            if isConfirmPasswordVisible {
                                TextField("Enter your confirm password", text: $confirmPassword)
                                    .accessibilityLabel("Confirm password")
                                    .accessibilityHint("Enter your password again")
                            } else {
                                SecureField("Enter your confirm password", text: $confirmPassword)
                                    .accessibilityLabel("Confirm password")
                                    .accessibilityHint("Enter your password again")
                            }
                            Button(action: {
                                isConfirmPasswordVisible.toggle()
                            }) {
                                Image(systemName: isConfirmPasswordVisible ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                            }
                            .accessibilityLabel(isConfirmPasswordVisible ? "Hide confirm password" : "Show confirm password")
                            .accessibilityHint("Double tap to toggle confirm password visibility")
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
                                .accessibilityLabel("Confirm password error: \(error)")
                        }
                    }

                    // Server-side error message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .accessibilityLabel("Registration error: \(errorMessage)")
                    }
                }
                .padding(.top, 10)

                // Sign up button
                Button(action: {
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
                            .accessibilityLabel("Signing up. Please wait.")
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
                .accessibilityLabel("Sign up")
                .accessibilityHint("Double tap to create your account")

                // Already have an account option
                HStack {
                    Text("Already have an account?")
                        .font(.subheadline)
                        .accessibilityHidden(true)
                    Button("Sign in") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Sign in")
                    .accessibilityHint("Double tap to go to the sign in screen")
                }
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
}
