
// MARK: - UserSettingsView.swift
// Trading_Terminal
//
// Created by Sk Jasimuddin on 14/04/26.

import SwiftUI

// MARK: - Shared Input Style

private struct SettingsTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false
    var keyboardType: UIKeyboardType = .default
    var field: UserSettingsView.Field
    var focusedField: FocusState<UserSettingsView.Field?>.Binding

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused(focusedField, equals: field)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .focused(focusedField, equals: field)
            }
        }
        .autocapitalization(.none)
        .autocorrectionDisabled()
        .foregroundColor(.white)
        .padding(14)
        .background(Color(red: 0.12, green: 0.15, blue: 0.22))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(Color.white.opacity(0.12), lineWidth: 1))
        .onTapGesture {
            focusedField.wrappedValue = field
        }
    }
}

private struct PurpleButton: View {
    let title: String
    var isOutlined = false
    var isSuccess = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(isOutlined ? Color(red: 0.55, green: 0.45, blue: 0.95) : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    isSuccess
                    ? Color.green
                    : (isOutlined ? Color.clear : Color(red: 0.45, green: 0.35, blue: 0.90))
                )
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isOutlined
                            ? Color(red: 0.45, green: 0.35, blue: 0.90)
                            : Color.clear,
                            lineWidth: 1.5
                        )
                )
        }
        .buttonStyle(.plain)
        .disabled(isSuccess)
    }
}

// MARK: - Success/Error Message Banner

private struct MessageBanner: View {
    let message: String
    let isError: Bool
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isError ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? .red : .green)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.white)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(isError ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isError ? Color.red : Color.green, lineWidth: 1)
        )
    }
}

// MARK: - Section Header Card

private struct SectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String
    let borderColor: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.50))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(red: 0.12, green: 0.15, blue: 0.22))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(borderColor, lineWidth: 1.5))
    }
}

// MARK: - Main View

struct UserSettingsView: View {
    @State private var showPasswordOTPModal = false
    @State private var otpCode = ""
    @State private var otpType: OTPType = .google

    enum OTPType { case google, email, both }

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm     = UserSettingsViewModel()

    // ── TwofaViewModel drives the security section + OTP sheet ──
    @StateObject private var twofaVM = TwofaUserSettingsViewModel()

    enum Field: Hashable {
        case firstName, lastName, phone
        case currentPassword, newPassword, retypePassword
        case email, apiKey
    }

    @FocusState private var focusedField: Field?

    private var currentEmail: String { UserDefaults.standard.string(forKey: "Bemail") ?? "" }
    @State private var newEmail = ""

    @State private var currentPassword = ""
    @State private var newPassword     = ""
    @State private var retypePassword  = ""

    @State private var settingsSaved   = false
    @State private var passwordChanged = false
    @State private var apiKeyName      = ""

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()

            VStack(spacing: 0) {
                pageHeader

                if !vm.errorMessage.isEmpty {
                    MessageBanner(message: vm.errorMessage, isError: true) { vm.clearError() }
                        .padding(.horizontal, 16).padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if !vm.successMessage.isEmpty {
                    MessageBanner(message: vm.successMessage, isError: false) { vm.clearSuccess() }
                        .padding(.horizontal, 16).padding(.top, 12)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        profileInfoSection
                        updateEmailSection

                        // ── 2FA section — GmailOTPSheet is embedded inside here ──
                        TwofaSecuritySectionView(vm: twofaVM)

                        changePasswordSection
                        createAPIKeySection
                        allAPIKeysSection
                        accountDeletionSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }

            if vm.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        // Password OTP sheet (existing — unchanged)
        .sheet(isPresented: $showPasswordOTPModal) {
            OTPVerificationView(
                otpCode: $otpCode,
                type: otpType,
                onConfirm: { handleOTPConfirm() }
            )
        }
        .animation(.easeInOut(duration: 0.3), value: vm.errorMessage)
        .animation(.easeInOut(duration: 0.3), value: vm.successMessage)
        .onAppear {
            vm.fetchUserSettings()
            twofaVM.fetchUserSettings()   // load 2FA state on appear
        }
    }

    func handleOTPConfirm() {
        switch otpType {
        case .google:
            vm.changePassword(current: currentPassword, new: newPassword, otp: otpCode)
        case .email:
            vm.verifyEmailOTP(otp: otpCode)
        case .both:
            break
        }
        otpCode = ""
    }

    // MARK: - Page Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("User Settings")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("Manage your account preferences, security, and API access")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.50))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 4)
    }

    // MARK: - 1. Profile Information

    private var profileInfoSection: some View {
        VStack(spacing: 14) {
            SectionHeader(
                icon: "person.fill",
                title: "Profile Information",
                subtitle: "Update your personal details",
                borderColor: Color(red: 0.20, green: 0.40, blue: 0.95)
            )

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("First Name").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                    SettingsTextField(placeholder: "First Name", text: $vm.firstName, field: .firstName, focusedField: $focusedField)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Last Name").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                    SettingsTextField(placeholder: "Last Name", text: $vm.lastName, field: .lastName, focusedField: $focusedField)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Phone").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                SettingsTextField(placeholder: "Phone Number", text: $vm.phone, keyboardType: .phonePad, field: .phone, focusedField: $focusedField)
            }

            PurpleButton(title: settingsSaved ? "✓ Saved" : "SAVE", isSuccess: settingsSaved) {
                vm.saveSettings()
                withAnimation { settingsSaved = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    withAnimation { settingsSaved = false }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - 2. Update Email Address

    private var updateEmailSection: some View {
        VStack(spacing: 14) {
            SectionHeader(
                icon: "envelope.fill",
                title: "Update Email Address",
                subtitle: "Change the email associated with your account",
                borderColor: Color(red: 0.10, green: 0.72, blue: 0.45)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Current Email").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                Text(currentEmail.isEmpty ? "—" : currentEmail)
                    .font(.system(size: 14)).foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(Color(red: 0.12, green: 0.15, blue: 0.22))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("New Email").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                SettingsTextField(placeholder: "Enter new email", text: $newEmail, keyboardType: .emailAddress, field: .email, focusedField: $focusedField)
            }

            PurpleButton(title: "Update Email") {
                print("Update email to:", newEmail)
            }
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - 4. Change Password

    private var changePasswordSection: some View {
        VStack(spacing: 14) {
            SectionHeader(
                icon: "key.fill",
                title: "Change Password",
                subtitle: "Update your account password regularly for security",
                borderColor: Color(red: 0.90, green: 0.55, blue: 0.10)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Current Password").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                SettingsTextField(placeholder: "Enter current password", text: $currentPassword, isSecure: true, field: .currentPassword, focusedField: $focusedField)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("New Password").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                SettingsTextField(placeholder: "Enter new password", text: $newPassword, isSecure: true, field: .newPassword, focusedField: $focusedField)
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("Retype Password").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                SettingsTextField(placeholder: "Retype new password", text: $retypePassword, isSecure: true, field: .retypePassword, focusedField: $focusedField)
            }

            // Uses twofaVM.googleAuthToggle to decide whether to require OTP
            PurpleButton(title: passwordChanged ? "✓ Changed" : "Change Password", isSuccess: passwordChanged) {
                if twofaVM.googleAuthToggle {
                    otpType = .google
                    showPasswordOTPModal = true
                    
                } else {
                    vm.changePassword(current: currentPassword, new: newPassword, otp: "")
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - 5. Create API Key

    private var createAPIKeySection: some View {
        VStack(spacing: 14) {
            SectionHeader(
                icon: "key.fill",
                title: "Create API Key",
                subtitle: "Generate new API keys for integrations",
                borderColor: Color(red: 0.20, green: 0.40, blue: 0.95)
            )
            SettingsTextField(placeholder: "Enter API Key name", text: $apiKeyName, field: .apiKey, focusedField: $focusedField)
            PurpleButton(title: "Create") {
                print("Create API key:", apiKeyName)
            }
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - 6. All API Keys

    private var allAPIKeysSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "key.fill").font(.system(size: 16)).foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("All API Keys").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Text("Manage your existing API keys").font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
                }
                Spacer()
                Button(action: {}) {
                    Text("Delete All")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(red: 0.95, green: 0.30, blue: 0.30))
                        .padding(.horizontal, 12).padding(.vertical, 6)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(red: 0.95, green: 0.30, blue: 0.30), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color(red: 0.12, green: 0.15, blue: 0.22))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(red: 0.10, green: 0.72, blue: 0.45), lineWidth: 1.5))

            Text("No API keys added yet")
                .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.35))
                .frame(maxWidth: .infinity).padding(.vertical, 28)
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - 7. Account Deletion

    private var accountDeletionSection: some View {
        VStack(spacing: 14) {
            HStack(spacing: 12) {
                Image(systemName: "trash.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 0.95, green: 0.30, blue: 0.30))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Account Deletion").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Text("Permanently delete your account data. This action cannot be undone.")
                        .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(red: 0.22, green: 0.10, blue: 0.10))
            .cornerRadius(12)

            Button(action: {}) {
                Text("Delete My Data")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color(red: 0.95, green: 0.30, blue: 0.30))
                    .frame(maxWidth: .infinity).frame(height: 50)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(red: 0.95, green: 0.30, blue: 0.30), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    UserSettingsView()
}
