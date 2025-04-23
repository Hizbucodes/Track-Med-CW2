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
    @State private var passwordsMatch = true
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    private var isFormValid: Bool {
        return !username.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !authViewModel.isLoading
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
                                Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
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
                                Image(systemName: isConfirmPasswordVisible ? "eye.slash" : "eye")
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
                        
                        if !passwordsMatch {
                            Text("Passwords don't match")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // Error message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 10)
                
                // Sign up button
                Button(action: {
                    if password == confirmPassword {
                        passwordsMatch = true
                        authViewModel.signUp(name: username, email: email, password: password)
                    } else {
                        passwordsMatch = false
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
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .padding(.horizontal, 24)
        }
        .navigationBarHidden(true)
    }
}
