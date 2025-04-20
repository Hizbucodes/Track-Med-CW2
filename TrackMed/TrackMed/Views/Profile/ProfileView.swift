//
//  ProfileView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditName = false
    @State private var showEditEmail = false
    @State private var showEditPassword = false
    @State private var showLanguagePicker = false
    @State private var showLogoutConfirmation = false
    
    let languages = [
        ("English", "en"),
        ("Tamil", "ta"),
        ("Sinhala", "si")
    ]
    
    var body: some View {
        NavigationView {
            List {
                // Profile header
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text(authViewModel.user?.name ?? "User")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(authViewModel.user?.email ?? "Email")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                Section(header: Text("Account Settings")) {
                    Button(action: { showEditName = true }) {
                        HStack {
                            Label("Name", systemImage: "person.fill")
                            Spacer()
                            Text(authViewModel.user?.name ?? "")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { showEditEmail = true }) {
                        HStack {
                            Label("Email", systemImage: "envelope.fill")
                            Spacer()
                            Text(authViewModel.user?.email ?? "")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: { showEditPassword = true }) {
                        HStack {
                            Label("Password", systemImage: "lock.fill")
                            Spacer()
                            Text("Change")
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("App Settings")) {
                    Button(action: { showLanguagePicker = true }) {
                        HStack {
                            Label("Language", systemImage: "globe")
                            Spacer()
                            Text(getCurrentLanguageName())
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Toggle(isOn: Binding(
                        get: { authViewModel.user?.useBiometricAuth ?? false },
                        set: { authViewModel.updateProfile(useBiometricAuth: $0) }
                    )) {
                        Label("Face ID / Touch ID", systemImage: "faceid")
                    }
                }
                
                Section {
                    Button(action: {
                        showLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Log Out")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Profile")
            .sheet(isPresented: $showEditName) {
                EditProfileView(
                    title: "Edit Name",
                    value: authViewModel.user?.name ?? "",
                    onSave: { authViewModel.updateProfile(name: $0) }
                )
            }
            .sheet(isPresented: $showEditEmail) {
                EditProfileView(
                    title: "Edit Email",
                    value: authViewModel.user?.email ?? "",
                    keyboardType: .emailAddress,
                    onSave: { _ in /* This would update email, but requires re-authentication */ }
                )
            }
            .sheet(isPresented: $showEditPassword) {
                ChangePasswordView()
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView(
                    languages: languages,
                    currentLanguage: authViewModel.user?.language ?? "en",
                    onSelect: { authViewModel.updateProfile(language: $0) }
                )
            }
            .alert(isPresented: $showLogoutConfirmation) {
                Alert(
                    title: Text("Log Out"),
                    message: Text("Are you sure you want to log out?"),
                    primaryButton: .destructive(Text("Log Out")) {
                        authViewModel.signOut()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func getCurrentLanguageName() -> String {
        let code = authViewModel.user?.language ?? "en"
        return languages.first { $0.1 == code }?.0 ?? "English"
    }
}

struct EditProfileView: View {
    let title: String
    @State private var value: String
    let keyboardType: UIKeyboardType
    let onSave: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    init(title: String, value: String, keyboardType: UIKeyboardType = .default, onSave: @escaping (String) -> Void) {
        self.title = title
        self._value = State(initialValue: value)
        self.keyboardType = keyboardType
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("", text: $value)
                    .keyboardType(keyboardType)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding()
                
                Spacer()
            }
            .navigationTitle(title)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave(value)
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                }
                
                Section(header: Text("New Password")) {
                    SecureField("Enter new password", text: $newPassword)
                    SecureField("Confirm new password", text: $confirmPassword)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Update Password") {
                        if newPassword == confirmPassword {
                            // This would call a method on AuthViewModel to change password
                            // Requires re-authentication
                            errorMessage = nil
                            presentationMode.wrappedValue.dismiss()
                        } else {
                            errorMessage = "Passwords don't match"
                        }
                    }
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct LanguagePickerView: View {
    let languages: [(String, String)]
    let currentLanguage: String
    let onSelect: (String) -> Void
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                ForEach(languages, id: \.1) { language in
                    Button(action: {
                        onSelect(language.1)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Text(language.0)
                            Spacer()
                            if language.1 == currentLanguage {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle("Language")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
