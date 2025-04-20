//
//  LoginView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Logo and app name
                VStack(spacing: 10) {
                    Image(systemName: "pills.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)
                    
                    Text("TrackMed")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Welcome back!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 40)
                
                // Email field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Password field
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // Remember me & Forgot password
                HStack {
                    Button(action: { rememberMe.toggle() }) {
                        HStack {
                            Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                .foregroundColor(rememberMe ? .blue : .gray)
                            Text("Remember me")
                                .font(.subheadline)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Forgot Password?") {
                        // Handle forgot password
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                }
                .padding(.vertical, 8)
                
                // Error message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }
                
                // Sign in button
                Button(action: {
                    authViewModel.signIn(email: email, password: password)
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign in")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                
                // Sign up option
                HStack {
                    Text("Don't have an account?")
                        .font(.subheadline)
                    
                    Button("Sign up") {
                        showRegister = true
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                }
                .padding(.top, 16)
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showRegister) {
                RegisterView()
                    .environmentObject(authViewModel)
            }
        }
    }
}
