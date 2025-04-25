//
//  ProfileView.swift
//  TrackMed
//
//  Created by Hizbullah 006 on 2025-04-20.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditName = false
    @State private var showEditEmail = false
    @State private var showEditPassword = false
    @State private var showLogoutConfirmation = false

    var body: some View {
        NavigationView {
            VStack {
                List {
                    // Profile header
                    VStack {
                        Image("user-image")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .padding(.top, 20)
                            .accessibilityLabel("User profile image")
                            .accessibilityHint("Profile picture of the user")

                        Text(authViewModel.user?.name ?? "User")
                            .font(.title)
                            .fontWeight(.bold)
                            .accessibilityLabel("Name: \(authViewModel.user?.name ?? "User")")

                        Text(authViewModel.user?.email ?? "Email")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .accessibilityLabel("Email: \(authViewModel.user?.email ?? "Email")")
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Profile. Name: \(authViewModel.user?.name ?? "User"). Email: \(authViewModel.user?.email ?? "Email")")

                    Section(header: Text("Account Settings")
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("Account Settings")) {
                        Button(action: { showEditName = true }) {
                            HStack {
                                Label("Name", systemImage: "person.fill")
                                    .accessibilityHidden(true)
                                Spacer()
                                Text(authViewModel.user?.name ?? "")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel("Edit name")
                        .accessibilityHint("Double tap to edit your name")

                        Button(action: { showEditPassword = true }) {
                            HStack {
                                Label("Password", systemImage: "lock.fill")
                                    .accessibilityHidden(true)
                                Spacer()
                                Text("Change")
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .accessibilityHidden(true)
                            }
                        }
                        .accessibilityLabel("Change password")
                        .accessibilityHint("Double tap to change your password")
                    }

                    Section(header: Text("App Settings")
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel("App Settings")) {
                        Toggle(isOn: Binding(
                            get: { authViewModel.user?.useBiometricAuth ?? false },
                            set: {
                                authViewModel.updateProfile(useBiometricAuth: $0)
                                UserDefaults.standard.set($0, forKey: "biometricEnabled")
                                if $0 {
                                    UserDefaults.standard.set(authViewModel.user?.email, forKey: "biometricEmail")
                                } else {
                                    UserDefaults.standard.removeObject(forKey: "biometricEmail")
                                }
                            }
                        )) {
                            Label("Face ID", systemImage: "faceid")
                                .accessibilityHidden(true)
                        }
                        .accessibilityLabel("Face ID authentication")
                        .accessibilityValue(authViewModel.user?.useBiometricAuth == true ? "Enabled" : "Disabled")
                        .accessibilityHint("Double tap to \(authViewModel.user?.useBiometricAuth == true ? "disable" : "enable") Face ID authentication")
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
                        .accessibilityLabel("Log out")
                        .accessibilityHint("Double tap to log out of your account")
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .padding(.bottom, 40)
            .navigationTitle("Profile")
            .accessibilityAddTraits(.isHeader)
            .sheet(isPresented: $showEditName) {
                EditProfileView(
                    title: "Edit Name",
                    value: authViewModel.user?.name ?? "",
                    onSave: { authViewModel.updateProfile(name: $0) }
                )
            }
            .sheet(isPresented: $showEditPassword) {
                ChangePasswordView()
                    .environmentObject(authViewModel)
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
                    .accessibilityLabel(title)
                    .accessibilityHint("Enter your new \(title.lowercased())")

                Spacer()
            }
            .navigationTitle(title)
            .accessibilityAddTraits(.isHeader)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .accessibilityLabel("Cancel")
                .accessibilityHint("Double tap to cancel and go back"),
                trailing: Button("Save") {
                    onSave(value)
                    presentationMode.wrappedValue.dismiss()
                }
                .accessibilityLabel("Save")
                .accessibilityHint("Double tap to save changes")
            )
        }
    }
}

struct ChangePasswordView: View {
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Current Password")
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("Current Password")) {
                    SecureField("Enter current password", text: $currentPassword)
                        .accessibilityLabel("Current password")
                        .accessibilityHint("Enter your current password")
                }

                Section(header: Text("New Password")
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityLabel("New Password")) {
                    SecureField("Enter new password (min 6 characters)", text: $newPassword)
                        .accessibilityLabel("New password")
                        .accessibilityHint("Enter your new password. Minimum 6 characters.")
                    SecureField("Confirm new password", text: $confirmPassword)
                        .accessibilityLabel("Confirm new password")
                        .accessibilityHint("Re-enter your new password")
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                }

                Section {
                    Button(action: updatePassword) {
                        HStack {
                            Text("Update Password")
                            if isLoading {
                                ProgressView()
                                    .padding(.leading, 8)
                            }
                        }
                    }
                    .disabled(!formIsValid)
                    .accessibilityLabel("Update password")
                    .accessibilityHint("Double tap to update your password")
                }
            }
            .navigationTitle("Change Password")
            .accessibilityAddTraits(.isHeader)
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .accessibilityLabel("Cancel")
            .accessibilityHint("Double tap to cancel and go back"))
        }
    }

    private var formIsValid: Bool {
        !currentPassword.isEmpty &&
        newPassword.count >= 6 &&
        newPassword == confirmPassword &&
        !isLoading
    }

    private func updatePassword() {
        guard formIsValid else { return }

        isLoading = true
        errorMessage = nil

        authViewModel.updatePassword(
            currentPassword: currentPassword,
            newPassword: newPassword
        ) { result in
            isLoading = false
            switch result {
            case .success:
                presentationMode.wrappedValue.dismiss()
            case .failure(let error):
                handleError(error)
            }
        }
    }

    private func handleError(_ error: Error) {
        switch error {
        case AuthErrorCode.wrongPassword:
            errorMessage = "Incorrect current password"
        case AuthErrorCode.weakPassword:
            errorMessage = "Password should be at least 6 characters"
        default:
            errorMessage = error.localizedDescription
        }
    }
}
