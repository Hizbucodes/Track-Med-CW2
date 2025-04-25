//
//  LoginView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = UserDefaults.standard.string(forKey: "rememberedEmail") ?? ""
    @State private var password = ""
    @State private var rememberMe = UserDefaults.standard.bool(forKey: "rememberMe")
    @State private var showRegister = false
    @State private var showBiometricError = false
    @State private var biometricErrorMessage: String?
    @State private var showForgotPassword = false
    @State private var showPassword = false
    @State private var showLoginAlert = false

    private var shouldAutoTriggerBiometrics: Bool {
        UserDefaults.standard.bool(forKey: "biometricEnabled") &&
        UserDefaults.standard.string(forKey: "biometricEmail") != nil &&
        BiometricAuthService.biometricType() != .none
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and app name
                Image(systemName: "pills.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 30)
                    .accessibilityLabel("TrackMed App Logo")
                    .accessibilityHint("Welcome to TrackMed")

                VStack(alignment: .leading, spacing: 8){
                    Text("Hello")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(Color(.blue))
                    Text("There!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Sign in now and start exploring all that our app has to offer. We're excited to welcome you to our community!")
                        .font(.caption)
                        .padding(.top, 10)
                }
                .padding(.bottom, 40)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Hello there! Sign in now and start exploring all that our app has to offer. We're excited to welcome you to our community.")

                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .accessibilityLabel("Email address")
                            .accessibilityHint("Enter your email address")
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }

                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.black)
                            .accessibilityHidden(true)
                        if showPassword {
                            TextField("Password", text: $password)
                                .accessibilityLabel("Password")
                                .accessibilityHint("Enter your password")
                        } else {
                            SecureField("Password", text: $password)
                                .accessibilityLabel("Password")
                                .accessibilityHint("Enter your password")
                        }
                        Button(action: {
                            showPassword.toggle()
                        }) {
                            Image(systemName: showPassword ? "eye" : "eye.slash")
                                .foregroundColor(.gray)
                        }
                        .accessibilityLabel(showPassword ? "Hide password" : "Show password")
                        .accessibilityHint("Double tap to toggle password visibility")
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 50)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }

                // Remember me & Forgot password
                HStack {
                    Button(action: {
                        rememberMe.toggle()
                        UserDefaults.standard.set(rememberMe, forKey: "rememberMe")
                        if rememberMe {
                            UserDefaults.standard.set(email, forKey: "rememberedEmail")
                        } else {
                            UserDefaults.standard.removeObject(forKey: "rememberedEmail")
                        }
                    }) {
                        HStack {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? .blue : .gray)
                                .accessibilityHidden(true)
                            Text("Remember me")
                                .font(.subheadline)
                                .foregroundStyle(Color(.black))
                        }
                    }
                    .accessibilityLabel("Remember me checkbox")
                    .accessibilityValue(rememberMe ? "Checked" : "Unchecked")
                    .accessibilityHint("Double tap to toggle remember me")

                    Spacer()

                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Forgot Password")
                    .accessibilityHint("Double tap to reset your password")
                }
                .padding(.vertical, 8)
                .padding(.bottom, 80)

                // Sign in button
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .accessibilityLabel("Signing in. Please wait.")
                    } else {
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(50)
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                .accessibilityLabel("Sign in")
                .accessibilityHint("Double tap to sign in to your account")

                // Biometric error display
                if showBiometricError, let biometricErrorMessage = biometricErrorMessage {
                    Text(biometricErrorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                        .accessibilityLabel("Biometric authentication error")
                        .accessibilityHint(biometricErrorMessage)
                }

                // Sign up option
                HStack {
                    Text("Don't have an account?")
                        .font(.subheadline)
                        .accessibilityHidden(true)
                    Button("Sign up") {
                        showRegister = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .accessibilityLabel("Sign up")
                    .accessibilityHint("Double tap to create a new account")
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
                    .environmentObject(authViewModel)
            }
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authViewModel)
            }
            .onAppear {
                if shouldAutoTriggerBiometrics && !authViewModel.isAuthenticated && BiometricAuthService.biometricType() != .none {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        authViewModel.authenticateWithBiometrics { success in
                            if !success {
                                biometricErrorMessage = authViewModel.errorMessage
                                showBiometricError = true
                            }
                        }
                    }
                }
            }
            .alert("Login Error", isPresented: $showLoginAlert, actions: {
                Button("OK", role: .cancel) {
                    authViewModel.errorMessage = nil
                }
            }, message: {
                Text(authViewModel.errorMessage ?? "Unknown error")
            })
            .onChange(of: authViewModel.errorMessage) { newValue in
                showLoginAlert = newValue != nil
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
