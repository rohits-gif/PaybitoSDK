// MARK: - TwoFAViews.swift

import SwiftUI
import Combine

// ─────────────────────────────────────────────────────────────────────────────
// MARK: OTPInputField
// ─────────────────────────────────────────────────────────────────────────────

struct OTPInputField: View {
    let placeholder: String
    @Binding var text: String

    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        self._text       = text
    }

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.25))
                    .padding(.horizontal, 16)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .foregroundColor(.white)
                .keyboardType(.numberPad)
                .font(.system(size: 14))
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
                )
        )
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: GmailOTPSheet  (twoFAKey == 0)
// Email OTP only → calls verifyEmailOTPAndGetKey → navigates to QR screen.
// Dismisses when vm.showGmailOTPSheet goes false (set by verifyEmailOTPAndGetKey).
// ─────────────────────────────────────────────────────────────────────────────

struct GmailOTPSheet: View {

    @ObservedObject var vm: TwofaUserSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var otpCode:     String  = ""
    @State private var shakeOffset: CGFloat = 0
    @State private var didProceed:  Bool    = false

    var body: some View {
        VStack(spacing: 0) {

            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 40, height: 4)
                .padding(.top, 14)
                .padding(.bottom, 22)

            HStack {
                Spacer()
                Text("Gmail OTP")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: cancelSheet) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.10)).frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 22)

            VStack(alignment: .leading, spacing: 16) {

                if vm.isLoading && otpCode.isEmpty {
                    HStack(spacing: 10) {
                        ProgressView().tint(.white).scaleEffect(0.85)
                        Text("Sending OTP to your email…")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("*One-time password sent to your email.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email OTP")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.70))
                    OTPInputField("Enter email OTP", text: $otpCode)
                        .offset(x: shakeOffset)
                        .disabled(vm.isLoading && otpCode.isEmpty)
                }

                if vm.resendCountdown > 0 {
                    Text("You can resend OTP after \(vm.resendCountdown) sec.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
                } else {
                    Button(action: { vm.resendOTP() }) {
                        Text("Resend OTP")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95))
                    }
                }

                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            HStack(spacing: 12) {
                Button(action: submitOTP) {
                    ZStack {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Submit")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.60, green: 0.50, blue: 1.00),
                                     Color(red: 0.40, green: 0.28, blue: 0.88)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(14)
                }
                .disabled(otpCode.trimmingCharacters(in: .whitespaces).isEmpty || vm.isLoading)
                .opacity(otpCode.isEmpty ? 0.55 : 1.0)

                Button(action: cancelSheet) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.70))
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .overlay(RoundedRectangle(cornerRadius: 14)
                            .stroke(Color(red: 0.45, green: 0.35, blue: 0.90), lineWidth: 1.5))
                }
                .disabled(vm.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .onChange(of: vm.showGmailOTPSheet) { isShowing in
            if !isShowing && !didProceed {
                if !vm.googleAuthKey.isEmpty {
                    didProceed = true
                    dismiss()
                }
            }
        }
        .onDisappear {
            if !didProceed { vm.onOTPSheetDismissedWithoutVerify() }
        }
    }

    private func submitOTP() {
        let trimmed = otpCode.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { triggerShake(); return }
        vm.verifyEmailOTPAndGetKey(emailOTP: trimmed)
    }

    private func cancelSheet() {
        otpCode = ""
        vm.onOTPSheetDismissedWithoutVerify()
        dismiss()
    }

    private func triggerShake() {
        let steps: [(CGFloat, Double)] = [(-8,0.00),(8,0.08),(-6,0.16),(6,0.24),(0,0.32)]
        for (offset, delay) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.default) { shakeOffset = offset }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: DisableOTPSheet — shown when user toggles 2FA OFF
// Sends OTP to email, verifies it, then calls disableGoogleAuth.
// Cancel / swipe reverts the toggle back to ON via onDisableOTPSheetDismissedWithoutVerify.
// ─────────────────────────────────────────────────────────────────────────────

struct DisableOTPSheet: View {

    @ObservedObject var vm: TwofaUserSettingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var otpCode:    String  = ""
    @State private var authCode:   String  = ""
    @State private var shakeOTP:   CGFloat = 0
    @State private var shakeAuth:  CGFloat = 0
    @State private var didDisable: Bool    = false

    private var canSubmit: Bool {
        !otpCode.trimmingCharacters(in: .whitespaces).isEmpty &&
        authCode.count == 6 &&
        !vm.isLoading
    }

    var body: some View {
        VStack(spacing: 0) {

            Capsule()
                .fill(Color.white.opacity(0.18))
                .frame(width: 40, height: 4)
                .padding(.top, 14)
                .padding(.bottom, 22)

            // Title row
            HStack {
                Spacer()
                Text("Disable 2FA")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: cancelSheet) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.10)).frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white.opacity(0.65))
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)

            // Warning banner
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.20))
                    .font(.system(size: 14))
                Text("You are about to disable Two-Factor Authentication. This will reduce your account security.")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.80))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(Color(red: 1.0, green: 0.75, blue: 0.20).opacity(0.12))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(red: 1.0, green: 0.75, blue: 0.20).opacity(0.35), lineWidth: 1)
            )
            .padding(.horizontal, 24)
            .padding(.bottom, 22)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    // ── Email OTP block ──────────────────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        if vm.isLoading && otpCode.isEmpty {
                            HStack(spacing: 10) {
                                ProgressView().tint(.white).scaleEffect(0.85)
                                Text("Sending OTP to your email…")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.55))
                            }
                        } else {
                            Text("*One-time password sent to your email.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.55))
                        }

                        Text("Email OTP")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.70))
                        OTPInputField("Enter email OTP", text: $otpCode)
                            .offset(x: shakeOTP)
                            .disabled(vm.isLoading && otpCode.isEmpty)

                        if vm.resendCountdown > 0 {
                            Text("You can resend OTP after \(vm.resendCountdown) sec.")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
                        } else {
                            Button(action: { vm.resendOTP() }) {
                                Text("Resend OTP")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95))
                            }
                        }
                    }

                    // ── Divider ──────────────────────────────────────────────
                    Rectangle()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 1)

                    // ── Google Authenticator block ───────────────────────────
                    VStack(alignment: .leading, spacing: 8) {
                        Text("*Open Google Authenticator and enter the 6-digit code shown for this account.")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.55))
                            .lineSpacing(3)

                        Text("Google Authenticator Code")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.70))
                        OTPInputField("6-digit code from authenticator", text: $authCode)
                            .offset(x: shakeAuth)
                            .onChange(of: authCode) { val in
                                let filtered = String(val.filter { $0.isNumber }.prefix(6))
                                if filtered != val { authCode = filtered }
                            }
                    }

                    if !vm.errorMessage.isEmpty {
                        Text(vm.errorMessage)
                            .font(.system(size: 12))
                            .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
                    }
                }
                .padding(.horizontal, 24)
            }
            .scrollDismissesKeyboard(.interactively)

            Spacer()

            // Action buttons
            HStack(spacing: 12) {
                Button(action: submitOTP) {
                    ZStack {
                        if vm.isLoading {
                            ProgressView().tint(.white)
                        } else {
                            Text("Confirm Disable")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(maxWidth: .infinity).frame(height: 52)
                    .background(Color(red: 0.85, green: 0.22, blue: 0.22))
                    .cornerRadius(14)
                }
                .disabled(!canSubmit)
                .opacity(canSubmit ? 1.0 : 0.55)

                Button(action: cancelSheet) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white.opacity(0.70))
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                        )
                }
                .disabled(vm.isLoading)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .onChange(of: vm.showDisableOTPSheet) { isShowing in
            if !isShowing {
                didDisable = true
                dismiss()
            }
        }
        .onDisappear {
            if !didDisable {
                vm.onDisableOTPSheetDismissedWithoutVerify()
            }
        }
    }

    private func submitOTP() {
        var shook = false
        if otpCode.trimmingCharacters(in: .whitespaces).isEmpty {
            triggerShake(target: &shakeOTP); shook = true
        }
        if authCode.count < 6 {
            triggerShake(target: &shakeAuth); shook = true
        }
        guard !shook else { return }
        vm.verifyOTPAndDisable(emailOTP: otpCode.trimmingCharacters(in: .whitespaces),
                               googleAuthCode: authCode)
    }

    private func cancelSheet() {
        otpCode  = ""
        authCode = ""
        vm.onDisableOTPSheetDismissedWithoutVerify()
        dismiss()
    }

    private func triggerShake(target: inout CGFloat) {
        let steps: [(CGFloat, Double)] = [(-8,0.00),(8,0.08),(-6,0.16),(6,0.24),(0,0.32)]
        let isOTP = target == shakeOTP
        for (val, delay) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.default) {
                    if isOTP { shakeOTP = val } else { shakeAuth = val }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: TwoFAFullSheet  (twoFAKey == 1)
// Shows BOTH fields:
//   • Email OTP  — verified against GetTwoFactorykey to receive google_auth_key
//   • Google Authenticator code — entered here by the user from their GA app
// ─────────────────────────────────────────────────────────────────────────────

struct TwoFAFullSheet: View {

    @ObservedObject var vm: TwofaUserSettingsViewModel
    var sendOTPOnAppear: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var emailOTP:  String  = ""
    @State private var authCode:  String  = ""
    @State private var shakeOTP:  CGFloat = 0
    @State private var shakeAuth: CGFloat = 0
    @State private var didVerify: Bool    = false

    private var canSubmit: Bool {
        !emailOTP.trimmingCharacters(in: .whitespaces).isEmpty &&
        authCode.count == 6 &&
        !vm.isLoading
    }

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.16).ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.20))
                        .frame(width: 40, height: 5)
                    Spacer()
                }
                .padding(.top, 12)
                .padding(.bottom, 28)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Email OTP block ──────────────────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("*One-time password sent to your email.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.55))

                            Text("Email OTP")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)

                            OTPInputField("Enter email OTP", text: $emailOTP)
                                .offset(x: shakeOTP)

                            if vm.resendCountdown > 0 {
                                Text("You can resend OTP after \(vm.resendCountdown) sec.")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
                                    .padding(.top, 2)
                            } else {
                                Button(action: { vm.resendOTP() }) {
                                    Text("Resend OTP")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95))
                                }
                                .padding(.top, 2)
                            }
                        }
                        .padding(.horizontal, 24)

                        Rectangle()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 1)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)

                        // ── Google Authenticator block ───────────────────────
                        VStack(alignment: .leading, spacing: 8) {
                            Text("*Open Google Authenticator and enter the 6-digit code shown for this account.")
                                .font(.system(size: 13))
                                .foregroundColor(.white.opacity(0.55))
                                .lineSpacing(3)

                            Text("Google Authenticator Code")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)

                            OTPInputField("6-digit code from authenticator", text: $authCode)
                                .offset(x: shakeAuth)
                                .onChange(of: authCode) { val in
                                    let filtered = String(val.filter { $0.isNumber }.prefix(6))
                                    if filtered != val { authCode = filtered }
                                }
                        }
                        .padding(.horizontal, 24)

                        if !vm.errorMessage.isEmpty {
                            Text(vm.errorMessage)
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                        }
                        if !vm.successMessage.isEmpty {
                            Text(vm.successMessage)
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.50))
                                .padding(.horizontal, 24)
                                .padding(.top, 12)
                        }
                    }
                }
                .scrollDismissesKeyboard(.interactively)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: submitBoth) {
                        ZStack {
                            if vm.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Submit")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.48, green: 0.36, blue: 0.94),
                                         Color(red: 0.36, green: 0.25, blue: 0.82)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    .disabled(!canSubmit)
                    .opacity(canSubmit ? 1.0 : 0.55)

                    Button(action: cancelSheet) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .overlay(RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(red: 0.36, green: 0.27, blue: 0.80), lineWidth: 1.5))
                    }
                    .disabled(vm.isLoading)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 36)
            }
        }
        .overlay(alignment: .topTrailing) {
            Button(action: cancelSheet) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.12)).frame(width: 30, height: 30)
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 14)
            .padding(.trailing, 16)
        }
        .onChange(of: vm.dismissOTPSheet) { shouldDismiss in
            if shouldDismiss {
                didVerify = true
                vm.dismissOTPSheet = false
                dismiss()
            }
        }
        .onAppear {
            if sendOTPOnAppear { vm.sendOTP() }
        }
        .onDisappear {
            if !didVerify { vm.onOTPSheetDismissedWithoutVerify() }
        }
    }

    private func submitBoth() {
        let otpTrimmed = emailOTP.trimmingCharacters(in: .whitespaces)
        var shook = false
        if otpTrimmed.isEmpty {
            triggerShake(target: &shakeOTP)
            shook = true
        }
        if authCode.count < 6 {
            triggerShake(target: &shakeAuth)
            shook = true
        }
        guard !shook else { return }
        vm.verifyBothAndEnable(emailOTP: otpTrimmed, googleAuthCode: authCode)
    }

    private func cancelSheet() {
        vm.onOTPSheetDismissedWithoutVerify()
        dismiss()
    }

    private func triggerShake(target: inout CGFloat) {
        let steps: [(CGFloat, Double)] = [(-8,0.00),(8,0.08),(-6,0.16),(6,0.24),(0,0.32)]
        let isOTP = target == shakeOTP
        for (val, delay) in steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.default) {
                    if isOTP { shakeOTP = val } else { shakeAuth = val }
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: TwofaSecuritySectionView
// ─────────────────────────────────────────────────────────────────────────────

struct TwofaSecuritySectionView: View {
    
    @ObservedObject var vm: TwofaUserSettingsViewModel
    var twoFAKey: Int = 1
    
    @State private var showFullSheetFromToggle = false
    @State private var showDisableSheet        = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // header card
            HStack(spacing: 12) {
                Image(systemName: "shield.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Security & Authentication")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Protect your account with additional security layers")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.50))
                }
                Spacer()
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color(red: 0.12, green: 0.15, blue: 0.22))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(Color(red: 0.90, green: 0.55, blue: 0.10), lineWidth: 1.5))
            
            // toggles card
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Two-Factor Authentication (2FA)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Require a verification code when signing in")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.50))
                        if vm.twoFAState.showsPartialBadge {
                            Text(vm.twoFAState.statusLabel ?? "")
                                .font(.system(size: 11))
                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.20))
                                .padding(.top, 2)
                        }
                    }
                    Spacer()
                    Toggle("", isOn: $vm.googleAuthToggle)
                        .labelsHidden()
                        .tint(Color(red: 0.45, green: 0.35, blue: 0.90))
                        .disabled(vm.isLoading)
                }
                .padding(.horizontal, 16).padding(.vertical, 16)
                
                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
                
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Phone Authentication")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Text("Receive SMS verification codes for login")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.50))
                    }
                    Spacer()
                    Toggle("", isOn: $vm.phoneAuthEnabled)
                        .labelsHidden()
                        .tint(Color(red: 0.45, green: 0.35, blue: 0.90))
                }
                .padding(.horizontal, 16).padding(.vertical, 16)
            }
            .background(Color(red: 0.10, green: 0.12, blue: 0.19))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
        }
        .padding(.top, 4)
        
        // ── Enable flow: GmailOTPSheet (twoFAKey == 0) ──────────────────────
        .sheet(isPresented: $vm.showGmailOTPSheet) {
            GmailOTPSheet(vm: vm)
                .presentationDetents([.height(460)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .interactiveDismissDisabled(false)
        }
        // ── Enable flow: intercept for TwoFAFullSheet (twoFAKey == 1) ───────
        .onChange(of: vm.showGmailOTPSheet) { isShowing in
            if isShowing && twoFAKey == 1 {
                vm.showGmailOTPSheet = false
                showFullSheetFromToggle = true
            }
        }
        .sheet(isPresented: $showFullSheetFromToggle) {
            TwoFAFullSheet(vm: vm, sendOTPOnAppear: false)
                .presentationDetents([.large])
                .presentationCornerRadius(24)
        }
        // ── Disable flow: DisableOTPSheet ────────────────────────────────────
        .onChange(of: vm.showDisableOTPSheet) { isShowing in
            if isShowing { showDisableSheet = true }
        }
        // In TwofaSecuritySectionView, change:
        .sheet(isPresented: $showDisableSheet) {
            DisableOTPSheet(vm: vm)
                .presentationDetents([.large])   // ← was .height(520)
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(24)
                .interactiveDismissDisabled(vm.isLoading)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: TwofaView  (main entry point)
// ─────────────────────────────────────────────────────────────────────────────

struct TwofaView: View {

    @StateObject private var vm      = TwofaUserSettingsViewModel()
    @State private var newEmail      = ""
    @State private var showFullSheet = false

    var currentEmail: String {
        UserDefaults.standard.string(forKey: "Bemail") ?? ""
    }

    var twoFAKey: Int = 1

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.06, blue: 0.10).ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {

                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.white)
                                .font(.system(size: 18, weight: .medium))
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("User Settings")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Manage your account preferences, security, and API access")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)

                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 52)
                        Text(currentEmail)
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.50))
                            .padding(.horizontal, 16)
                    }
                    .padding(.horizontal, 20)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Email")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.50))
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.06))
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1))
                                .frame(height: 52)
                            if newEmail.isEmpty {
                                Text("Enter new email")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.25))
                                    .padding(.horizontal, 16)
                                    .allowsHitTesting(false)
                            }
                            TextField("", text: $newEmail)
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                                .padding(.horizontal, 16)
                        }
                        .frame(height: 52)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    Button(action: {
                        if twoFAKey == 1 { showFullSheet = true }
                        else             { vm.sendOTP() }
                    }) {
                        Text("Update Email")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 54)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.36, green: 0.31, blue: 0.81),
                                             Color(red: 0.29, green: 0.25, blue: 0.75)],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer()

                    TwofaSecuritySectionView(vm: vm, twoFAKey: twoFAKey)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $vm.showQRSetupScreen) {
                let otpURL = vm.buildOTPAuthURL(
                    issuer:      "PayBito",
                    accountName: UserDefaults.standard.string(forKey: "Bemail") ?? "user"
                )
                Qrauthsetupview(
                    otpAuthURL:      otpURL,
                    recoveryKey:     vm.googleAuthKey,
                    prefillAuthCode: vm.pendingGoogleAuthCode
                ) { code in
                    vm.saveTwoFactorSettings(googleFactorOTP: code)
                }
            }
        }
        .sheet(isPresented: $showFullSheet) {
            TwoFAFullSheet(vm: vm, sendOTPOnAppear: true)
                .presentationDetents([.large])
                .presentationCornerRadius(24)
        }
        .onAppear { vm.fetchUserSettings() }
    }

    @ViewBuilder
    private var qrSetupDestination: some View {
        if vm.googleAuthKey.isEmpty {
            VStack(spacing: 16) {
                ProgressView().tint(.white)
                Text("Loading QR code…")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 14))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.05, green: 0.06, blue: 0.10).ignoresSafeArea())
            .onAppear {
                debugPrint("⚠️ [QR] Reached QR screen with empty googleAuthKey — timing issue upstream")
            }
        } else {
            let otpURL = vm.buildOTPAuthURL(issuer: "PayBito", accountName: currentEmail)
            let _ = debugPrint("🔑 [QR] otpURL=\(otpURL) key=\(vm.googleAuthKey) pendingCode=\(vm.pendingGoogleAuthCode)")
            Qrauthsetupview(
                otpAuthURL:      otpURL,
                recoveryKey:     vm.googleAuthKey,
                prefillAuthCode: vm.pendingGoogleAuthCode
            ) { code in
                vm.saveTwoFactorSettings(googleFactorOTP: code) { }
            }
            .overlay(alignment: .bottom) {
                if vm.isLoading {
                    HStack(spacing: 8) {
                        ProgressView().tint(.white)
                        Text("Saving…").font(.system(size: 13)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 12)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12).padding(.bottom, 40)
                } else if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .font(.system(size: 13)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color(red: 0.8, green: 0.15, blue: 0.15).opacity(0.9))
                        .cornerRadius(12).padding(.bottom, 40)
                } else if !vm.successMessage.isEmpty {
                    Text(vm.successMessage)
                        .font(.system(size: 13)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 12)
                        .background(Color(red: 0.15, green: 0.65, blue: 0.35).opacity(0.9))
                        .cornerRadius(12).padding(.bottom, 40)
                }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: Previews
// ─────────────────────────────────────────────────────────────────────────────

#Preview("twoFAKey 1 — Email OTP → QR") { TwofaView(twoFAKey: 1) }
#Preview("twoFAKey 0 — Gmail OTP only") { TwofaView(twoFAKey: 0) }
#Preview("Security section — key 1") {
    ZStack {
        Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()
        TwofaSecuritySectionView(vm: TwofaUserSettingsViewModel(), twoFAKey: 1).padding()
    }
}















//
//// MARK: - TwoFAViews.swift
//
//import SwiftUI
//import Combine
//
//// ─────────────────────────────────────────────────────────────────────────────
//// MARK: OTPInputField
//// ─────────────────────────────────────────────────────────────────────────────
//
//struct OTPInputField: View {
//    let placeholder: String
//    @Binding var text: String
//
//    init(_ placeholder: String, text: Binding<String>) {
//        self.placeholder = placeholder
//        self._text       = text
//    }
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//            if text.isEmpty {
//                Text(placeholder)
//                    .font(.system(size: 14))
//                    .foregroundColor(.white.opacity(0.25))
//                    .padding(.horizontal, 16)
//                    .allowsHitTesting(false)
//            }
//            TextField("", text: $text)
//                .foregroundColor(.white)
//                .keyboardType(.numberPad)
//                .font(.system(size: 14))
//                .padding(.horizontal, 16)
//                .padding(.vertical, 16)
//        }
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white.opacity(0.05))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 12)
//                        .stroke(Color.white.opacity(0.10), lineWidth: 1)
//                )
//        )
//    }
//}
//
//// ─────────────────────────────────────────────────────────────────────────────
//// MARK: GmailOTPSheet  (twoFAKey == 0)
//// Email OTP only → calls verifyEmailOTPAndGetKey → navigates to QR screen.
//// Dismisses when vm.showGmailOTPSheet goes false (set by verifyEmailOTPAndGetKey).
//// ─────────────────────────────────────────────────────────────────────────────
//
//struct GmailOTPSheet: View {
//
//    @ObservedObject var vm: TwofaUserSettingsViewModel
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var otpCode:     String  = ""
//    @State private var shakeOffset: CGFloat = 0
//    @State private var didProceed:  Bool    = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//
//            Capsule()
//                .fill(Color.white.opacity(0.18))
//                .frame(width: 40, height: 4)
//                .padding(.top, 14)
//                .padding(.bottom, 22)
//
//            HStack {
//                Spacer()
//                Text("Gmail OTP")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.white)
//                Spacer()
//                Button(action: cancelSheet) {
//                    ZStack {
//                        Circle().fill(Color.white.opacity(0.10)).frame(width: 32, height: 32)
//                        Image(systemName: "xmark")
//                            .font(.system(size: 12, weight: .semibold))
//                            .foregroundColor(.white.opacity(0.65))
//                    }
//                }
//            }
//            .padding(.horizontal, 24)
//            .padding(.bottom, 22)
//
//            VStack(alignment: .leading, spacing: 16) {
//
//                if vm.isLoading && otpCode.isEmpty {
//                    HStack(spacing: 10) {
//                        ProgressView().tint(.white).scaleEffect(0.85)
//                        Text("Sending OTP to your email…")
//                            .font(.system(size: 13))
//                            .foregroundColor(.white.opacity(0.55))
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                } else {
//                    Text("*One-time password sent to your email.")
//                        .font(.system(size: 13))
//                        .foregroundColor(.white.opacity(0.55))
//                }
//
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Email OTP")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(.white.opacity(0.70))
//                    OTPInputField("Enter email OTP", text: $otpCode)
//                        .offset(x: shakeOffset)
//                        .disabled(vm.isLoading && otpCode.isEmpty)
//                }
//
//                if vm.resendCountdown > 0 {
//                    Text("You can resend OTP after \(vm.resendCountdown) sec.")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
//                } else {
//                    Button(action: { vm.resendOTP() }) {
//                        Text("Resend OTP")
//                            .font(.system(size: 13, weight: .semibold))
//                            .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95))
//                    }
//                }
//
//                if !vm.errorMessage.isEmpty {
//                    Text(vm.errorMessage)
//                        .font(.system(size: 12))
//                        .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
//                }
//            }
//            .padding(.horizontal, 24)
//
//            Spacer()
//
//            HStack(spacing: 12) {
//                Button(action: submitOTP) {
//                    ZStack {
//                        if vm.isLoading {
//                            ProgressView().tint(.white)
//                        } else {
//                            Text("Submit")
//                                .font(.system(size: 16, weight: .semibold))
//                                .foregroundColor(.white)
//                        }
//                    }
//                    .frame(maxWidth: .infinity).frame(height: 52)
//                    .background(
//                        LinearGradient(
//                            colors: [Color(red: 0.60, green: 0.50, blue: 1.00),
//                                     Color(red: 0.40, green: 0.28, blue: 0.88)],
//                            startPoint: .topLeading, endPoint: .bottomTrailing
//                        )
//                    )
//                    .cornerRadius(14)
//                }
//                .disabled(otpCode.trimmingCharacters(in: .whitespaces).isEmpty || vm.isLoading)
//                .opacity(otpCode.isEmpty ? 0.55 : 1.0)
//
//                Button(action: cancelSheet) {
//                    Text("Cancel")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(.white.opacity(0.70))
//                        .frame(maxWidth: .infinity).frame(height: 52)
//                        .overlay(RoundedRectangle(cornerRadius: 14)
//                            .stroke(Color(red: 0.45, green: 0.35, blue: 0.90), lineWidth: 1.5))
//                }
//                .disabled(vm.isLoading)
//            }
//            .padding(.horizontal, 24)
//            .padding(.bottom, 36)
//        }
//        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
//        // verifyEmailOTPAndGetKey sets showGmailOTPSheet = false on success.
//        // Watch that going false → mark didProceed and dismiss so NavigationStack
//        // can push QR screen (showQRSetupScreen fires 0.65s later, after sheet is gone).
//        .onChange(of: vm.showGmailOTPSheet) { isShowing in
//            if !isShowing && !didProceed {
//                // Only treat this as "proceeding" if we have a key — not a cancel
//                if !vm.googleAuthKey.isEmpty {
//                    didProceed = true
//                    dismiss()
//                }
//            }
//        }
//        .onDisappear {
//            if !didProceed { vm.onOTPSheetDismissedWithoutVerify() }
//        }
//    }
//
//    private func submitOTP() {
//        let trimmed = otpCode.trimmingCharacters(in: .whitespaces)
//        guard !trimmed.isEmpty else { triggerShake(); return }
//        vm.verifyEmailOTPAndGetKey(emailOTP: trimmed)
//    }
//
//    private func cancelSheet() {
//        otpCode = ""
//        vm.onOTPSheetDismissedWithoutVerify()
//        dismiss()
//    }
//
//    private func triggerShake() {
//        let steps: [(CGFloat, Double)] = [(-8,0.00),(8,0.08),(-6,0.16),(6,0.24),(0,0.32)]
//        for (offset, delay) in steps {
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                withAnimation(.default) { shakeOffset = offset }
//            }
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────────────────────
//// MARK: TwoFAFullSheet  (twoFAKey == 1)
//// Shows BOTH fields:
////   • Email OTP  — verified against GetTwoFactorykey to receive google_auth_key
////   • Google Authenticator code — entered here by the user from their GA app
////
//// Flow:
////   1. User fills both fields and taps Submit
////   2. verifyBothAndEnable(emailOTP:googleAuthCode:) is called
////      → POSTs emailOTP to GetTwoFactorykey → receives google_auth_key
////      → stores googleAuthCode locally so Qrauthsetupview can pre-fill / pass it
////         to saveTwoFactorSettings on the next screen
////   3. VM sets dismissOTPSheet = true → sheet self-dismisses
////   4. 0.65s later VM sets showQRSetupScreen = true → NavigationStack pushes Qrauthsetupview
////
//// NOTE: googleAuthCode is NOT sent to GetTwoFactorykey (that endpoint ignores it).
////       It is stored on the VM as pendingGoogleAuthCode and forwarded to
////       saveTwoFactorSettings when the QR screen's onSubmit fires.
//// ─────────────────────────────────────────────────────────────────────────────
//
//
//struct TwoFAFullSheet: View {
//
//    @ObservedObject var vm: TwofaUserSettingsViewModel
//    /// true only for the Update Email button path — toggle path already called sendOTP()
//    var sendOTPOnAppear: Bool = false
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var emailOTP:   String  = ""
//    @State private var authCode:   String  = ""
//    @State private var shakeOTP:   CGFloat = 0
//    @State private var shakeAuth:  CGFloat = 0
//    @State private var didVerify:  Bool    = false
//
//    /// Both fields must be non-empty to enable Submit
//    private var canSubmit: Bool {
//        !emailOTP.trimmingCharacters(in: .whitespaces).isEmpty &&
//        authCode.count == 6 &&
//        !vm.isLoading
//    }
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.07, green: 0.09, blue: 0.16).ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 0) {
//
//                // drag indicator
//                HStack {
//                    Spacer()
//                    RoundedRectangle(cornerRadius: 3)
//                        .fill(Color.white.opacity(0.20))
//                        .frame(width: 40, height: 5)
//                    Spacer()
//                }
//                .padding(.top, 12)
//                .padding(.bottom, 28)
//
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 0) {
//
//                        // ── Email OTP block ──────────────────────────────────
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("*One-time password sent to your email.")
//                                .font(.system(size: 13))
//                                .foregroundColor(.white.opacity(0.55))
//
//                            Text("Email OTP")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(.white)
//
//                            OTPInputField("Enter email OTP", text: $emailOTP)
//                                .offset(x: shakeOTP)
//
//                            if vm.resendCountdown > 0 {
//                                Text("You can resend OTP after \(vm.resendCountdown) sec.")
//                                    .font(.system(size: 13, weight: .medium))
//                                    .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
//                                    .padding(.top, 2)
//                            } else {
//                                Button(action: { vm.resendOTP() }) {
//                                    Text("Resend OTP")
//                                        .font(.system(size: 13, weight: .semibold))
//                                        .foregroundColor(Color(red: 0.55, green: 0.45, blue: 0.95))
//                                }
//                                .padding(.top, 2)
//                            }
//                        }
//                        .padding(.horizontal, 24)
//
//                        // divider
//                        Rectangle()
//                            .fill(Color.white.opacity(0.08))
//                            .frame(height: 1)
//                            .padding(.horizontal, 24)
//                            .padding(.vertical, 20)
//
//                        // ── Google Authenticator block ───────────────────────
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("*Open Google Authenticator and enter the 6-digit code shown for this account.")
//                                .font(.system(size: 13))
//                                .foregroundColor(.white.opacity(0.55))
//                                .lineSpacing(3)
//
//                            Text("Google Authenticator Code")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundColor(.white)
//
//                            OTPInputField("6-digit code from authenticator", text: $authCode)
//                                .offset(x: shakeAuth)
//                                .onChange(of: authCode) { val in
//                                    let filtered = String(val.filter { $0.isNumber }.prefix(6))
//                                    if filtered != val { authCode = filtered }
//                                }
//                        }
//                        .padding(.horizontal, 24)
//
//                        // error / success messages
//                        if !vm.errorMessage.isEmpty {
//                            Text(vm.errorMessage)
//                                .font(.system(size: 12))
//                                .foregroundColor(Color(red: 1.0, green: 0.28, blue: 0.28))
//                                .padding(.horizontal, 24)
//                                .padding(.top, 12)
//                        }
//                        if !vm.successMessage.isEmpty {
//                            Text(vm.successMessage)
//                                .font(.system(size: 12))
//                                .foregroundColor(Color(red: 0.30, green: 0.85, blue: 0.50))
//                                .padding(.horizontal, 24)
//                                .padding(.top, 12)
//                        }
//                    }
//                }
//                .scrollDismissesKeyboard(.interactively)
//
//                Spacer()
//
//                // action buttons
//                HStack(spacing: 12) {
//                    Button(action: submitBoth) {
//                        ZStack {
//                            if vm.isLoading {
//                                ProgressView().tint(.white)
//                            } else {
//                                Text("Submit")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        .frame(maxWidth: .infinity).frame(height: 54)
//                        .background(
//                            LinearGradient(
//                                colors: [Color(red: 0.48, green: 0.36, blue: 0.94),
//                                         Color(red: 0.36, green: 0.25, blue: 0.82)],
//                                startPoint: .leading, endPoint: .trailing
//                            )
//                        )
//                        .cornerRadius(14)
//                    }
//                    .disabled(!canSubmit)
//                    .opacity(canSubmit ? 1.0 : 0.55)
//
//                    Button(action: cancelSheet) {
//                        Text("Cancel")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity).frame(height: 54)
//                            .overlay(RoundedRectangle(cornerRadius: 14)
//                                .stroke(Color(red: 0.36, green: 0.27, blue: 0.80), lineWidth: 1.5))
//                    }
//                    .disabled(vm.isLoading)
//                }
//                .padding(.horizontal, 24)
//                .padding(.bottom, 36)
//            }
//        }
//        .overlay(alignment: .topTrailing) {
//            Button(action: cancelSheet) {
//                ZStack {
//                    Circle().fill(Color.white.opacity(0.12)).frame(width: 30, height: 30)
//                    Image(systemName: "xmark")
//                        .font(.system(size: 12, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//            .padding(.top, 14)
//            .padding(.trailing, 16)
//        }
//        // verifyBothAndEnable sets dismissOTPSheet = true on success.
//        // Sheet self-dismisses here; VM fires showQRSetupScreen = true 0.65s later
//        // so NavigationStack pushes Qrauthsetupview only after sheet is fully gone.
//        .onChange(of: vm.dismissOTPSheet) { shouldDismiss in
//            if shouldDismiss {
//                didVerify = true
//                vm.dismissOTPSheet = false  // reset for next open
//                dismiss()
//            }
//        }
//        // Only send OTP on appear when called from Update Email button path.
//        // Toggle path already called sendOTP() before opening this sheet.
//        .onAppear {
//            if sendOTPOnAppear { vm.sendOTP() }
//        }
//        .onDisappear {
//            if !didVerify { vm.onOTPSheetDismissedWithoutVerify() }
//        }
//    }
//
//    // Submit: validate both fields locally, then call VM.
//    // emailOTP → GetTwoFactorykey (receives google_auth_key back)
//    // authCode → stored on VM as pendingGoogleAuthCode, forwarded to
//    //            saveTwoFactorSettings when Qrauthsetupview's onSubmit fires.
//    private func submitBoth() {
//        let otpTrimmed = emailOTP.trimmingCharacters(in: .whitespaces)
//        var shook = false
//        if otpTrimmed.isEmpty {
//            triggerShake(target: &shakeOTP)
//            shook = true
//        }
//        if authCode.count < 6 {
//            triggerShake(target: &shakeAuth)
//            shook = true
//        }
//        guard !shook else { return }
//        vm.verifyBothAndEnable(emailOTP: otpTrimmed, googleAuthCode: authCode)
//    }
//
//    private func cancelSheet() {
//        vm.onOTPSheetDismissedWithoutVerify()
//        dismiss()
//    }
//
//    private func triggerShake(target: inout CGFloat) {
//        // Capture a local binding-equivalent via a closure to avoid inout + async conflict
//        let steps: [(CGFloat, Double)] = [(-8,0.00),(8,0.08),(-6,0.16),(6,0.24),(0,0.32)]
//        // Determine which field to shake based on current target address — use separate helpers
//        let isOTP = target == shakeOTP
//        for (val, delay) in steps {
//            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
//                withAnimation(.default) {
//                    if isOTP { shakeOTP = val } else { shakeAuth = val }
//                }
//            }
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────────────────────
//// MARK: TwofaSecuritySectionView
//// ─────────────────────────────────────────────────────────────────────────────
//
//struct TwofaSecuritySectionView: View {
//
//    @ObservedObject var vm: TwofaUserSettingsViewModel
//    var twoFAKey: Int = 1
//
//    @State private var showFullSheetFromToggle = false
//
//    var body: some View {
//        VStack(spacing: 0) {
//
//            // header card
//            HStack(spacing: 12) {
//                Image(systemName: "shield.fill")
//                    .font(.system(size: 16))
//                    .foregroundColor(.white)
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Security & Authentication")
//                        .font(.system(size: 15, weight: .bold))
//                        .foregroundColor(.white)
//                    Text("Protect your account with additional security layers")
//                        .font(.system(size: 12))
//                        .foregroundColor(.white.opacity(0.50))
//                }
//                Spacer()
//            }
//            .padding(.horizontal, 16).padding(.vertical, 14)
//            .background(Color(red: 0.12, green: 0.15, blue: 0.22))
//            .cornerRadius(12)
//            .overlay(RoundedRectangle(cornerRadius: 12)
//                .stroke(Color(red: 0.90, green: 0.55, blue: 0.10), lineWidth: 1.5))
//
//            // toggles card
//            VStack(spacing: 0) {
//                HStack {
//                    VStack(alignment: .leading, spacing: 3) {
//                        Text("Two-Factor Authentication (2FA)")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                        Text("Require a verification code when signing in")
//                            .font(.system(size: 12))
//                            .foregroundColor(.white.opacity(0.50))
//                        if vm.twoFAState.showsPartialBadge {
//                            Text(vm.twoFAState.statusLabel ?? "")
//                                .font(.system(size: 11))
//                                .foregroundColor(Color(red: 1.0, green: 0.75, blue: 0.20))
//                                .padding(.top, 2)
//                        }
//                    }
//                    Spacer()
//                    Toggle("", isOn: $vm.googleAuthToggle)
//                        .labelsHidden()
//                        .tint(Color(red: 0.45, green: 0.35, blue: 0.90))
//                        .disabled(vm.isLoading)
//                }
//                .padding(.horizontal, 16).padding(.vertical, 16)
//
//                Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
//
//                HStack {
//                    VStack(alignment: .leading, spacing: 3) {
//                        Text("Phone Authentication")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                        Text("Receive SMS verification codes for login")
//                            .font(.system(size: 12))
//                            .foregroundColor(.white.opacity(0.50))
//                    }
//                    Spacer()
//                    Toggle("", isOn: $vm.phoneAuthEnabled)
//                        .labelsHidden()
//                        .tint(Color(red: 0.45, green: 0.35, blue: 0.90))
//                }
//                .padding(.horizontal, 16).padding(.vertical, 16)
//            }
//            .background(Color(red: 0.10, green: 0.12, blue: 0.19))
//            .cornerRadius(14)
//            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.08), lineWidth: 1))
//        }
//        .padding(.top, 4)
//
//        // twoFAKey == 0: GmailOTPSheet — presented directly by showGmailOTPSheet
//        .sheet(isPresented: $vm.showGmailOTPSheet) {
//            GmailOTPSheet(vm: vm)
//                .presentationDetents([.height(460)])
//                .presentationDragIndicator(.hidden)
//                .presentationCornerRadius(24)
//                .interactiveDismissDisabled(false)
//        }
//        // twoFAKey == 1: intercept showGmailOTPSheet and redirect to TwoFAFullSheet.
//        // sendOTP() was already called by the toggle → sendOTPOnAppear: false.
//        .onChange(of: vm.showGmailOTPSheet) { isShowing in
//            if isShowing && twoFAKey == 1 {
//                vm.showGmailOTPSheet = false
//                showFullSheetFromToggle = true
//            }
//        }
//        .sheet(isPresented: $showFullSheetFromToggle) {
//            TwoFAFullSheet(vm: vm, sendOTPOnAppear: false)
//                .presentationDetents([.large])
//                .presentationCornerRadius(24)
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────────────────────
//// MARK: TwofaView  (main entry point)
//// twoFAKey == 0 → GmailOTPSheet (email OTP only) → QR screen
//// twoFAKey == 1 → TwoFAFullSheet (email OTP only here; GA code on QR screen) → QR screen
//// Both paths converge: vm.showQRSetupScreen = true → NavigationStack pushes Qrauthsetupview
//// ─────────────────────────────────────────────────────────────────────────────
//
//struct TwofaView: View {
//
//    @StateObject private var vm      = TwofaUserSettingsViewModel()
//    @State private var newEmail      = ""
//    @State private var showFullSheet = false
//
//    var currentEmail: String {
//        UserDefaults.standard.string(forKey: "Bemail") ?? ""
//    }
//
//    /// 0 = Gmail OTP only → QR screen
//    /// 1 = Email OTP sheet → QR screen (GA code entered on QR screen)
//    var twoFAKey: Int = 1
//
//    var body: some View {
//        NavigationStack {
//            ZStack {
//                Color(red: 0.05, green: 0.06, blue: 0.10).ignoresSafeArea()
//
//                VStack(alignment: .leading, spacing: 0) {
//
//                    // header
//                    HStack(spacing: 12) {
//                        Button(action: {}) {
//                            Image(systemName: "arrow.left")
//                                .foregroundColor(.white)
//                                .font(.system(size: 18, weight: .medium))
//                        }
//                        VStack(alignment: .leading, spacing: 2) {
//                            Text("User Settings")
//                                .font(.system(size: 20, weight: .semibold))
//                                .foregroundColor(.white)
//                            Text("Manage your account preferences, security, and API access")
//                                .font(.system(size: 12))
//                                .foregroundColor(.white.opacity(0.45))
//                        }
//                        Spacer()
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                    .padding(.bottom, 28)
//
//                    // current email
//                    ZStack(alignment: .leading) {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.white.opacity(0.06))
//                            .frame(height: 52)
//                        Text(currentEmail)
//                            .font(.system(size: 14))
//                            .foregroundColor(.white.opacity(0.50))
//                            .padding(.horizontal, 16)
//                    }
//                    .padding(.horizontal, 20)
//
//                    // new email field
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("New Email")
//                            .font(.system(size: 13))
//                            .foregroundColor(.white.opacity(0.50))
//                        ZStack(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(Color.white.opacity(0.06))
//                                .overlay(RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.white.opacity(0.08), lineWidth: 1))
//                                .frame(height: 52)
//                            if newEmail.isEmpty {
//                                Text("Enter new email")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.white.opacity(0.25))
//                                    .padding(.horizontal, 16)
//                                    .allowsHitTesting(false)
//                            }
//                            TextField("", text: $newEmail)
//                                .foregroundColor(.white)
//                                .font(.system(size: 14))
//                                .padding(.horizontal, 16)
//                        }
//                        .frame(height: 52)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 12)
//
//                    // Update Email button
//                    // twoFAKey == 0: sendOTP() → showGmailOTPSheet = true → GmailOTPSheet
//                    // twoFAKey == 1: open TwoFAFullSheet directly; sheet calls sendOTP() itself
//                    Button(action: {
//                        if twoFAKey == 1 { showFullSheet = true }
//                        else             { vm.sendOTP() }
//                    }) {
//                        Text("Update Email")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity).frame(height: 54)
//                            .background(
//                                LinearGradient(
//                                    colors: [Color(red: 0.36, green: 0.31, blue: 0.81),
//                                             Color(red: 0.29, green: 0.25, blue: 0.75)],
//                                    startPoint: .leading, endPoint: .trailing
//                                )
//                            )
//                            .cornerRadius(12)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//
//                    Spacer()
//
//                    TwofaSecuritySectionView(vm: vm, twoFAKey: twoFAKey)
//                        .padding(.horizontal, 20)
//                        .padding(.bottom, 24)
//                }
//            }
//            .navigationBarHidden(true)
//            // Both twoFAKey paths converge here.
//            // vm.showQRSetupScreen is set true 0.65s after the OTP sheet dismisses,
//            // ensuring the sheet animation is fully complete before navigation fires.
//            
//            
//            
////            .navigationDestination(isPresented: $vm.showQRSetupScreen) {
////                qrSetupDestination
////            }
//            
//            
//            
//            .navigationDestination(isPresented: $vm.showQRSetupScreen) {
//                let otpURL = vm.buildOTPAuthURL(
//                    issuer:      "PayBito",
//                    accountName: UserDefaults.standard.string(forKey: "Bemail") ?? "user"
//                )
//                Qrauthsetupview(
//                    otpAuthURL:      otpURL,
//                    recoveryKey:     vm.googleAuthKey,
//                    prefillAuthCode: vm.pendingGoogleAuthCode
//                ) { code in
//                    vm.saveTwoFactorSettings(googleFactorOTP: code)
//                }
//            }
//            
//            
//            
//            
//        }
//        // Update Email → TwoFAFullSheet; sendOTPOnAppear: true because no prior sendOTP() call
//        .sheet(isPresented: $showFullSheet) {
//            TwoFAFullSheet(vm: vm, sendOTPOnAppear: true)
//                .presentationDetents([.large])
//                .presentationCornerRadius(24)
//        }
//        .onAppear { vm.fetchUserSettings() }
//    }
//
//    // ── QR destination ────────────────────────────────────────────────────────
//    // Reached from BOTH twoFAKey paths via vm.showQRSetupScreen = true.
//    // googleAuthKey is always populated before this fires (set before dismissOTPSheet/
//    // showGmailOTPSheet, which trigger dismiss, which precedes showQRSetupScreen by 0.65s).
//    @ViewBuilder
//    private var qrSetupDestination: some View {
//        if vm.googleAuthKey.isEmpty {
//            // Safety fallback — should never be hit with correct timing
//            VStack(spacing: 16) {
//                ProgressView().tint(.white)
//                Text("Loading QR code…")
//                    .foregroundColor(.white.opacity(0.6))
//                    .font(.system(size: 14))
//            }
//            .frame(maxWidth: .infinity, maxHeight: .infinity)
//            .background(Color(red: 0.05, green: 0.06, blue: 0.10).ignoresSafeArea())
//            .onAppear {
//                debugPrint("⚠️ [QR] Reached QR screen with empty googleAuthKey — timing issue upstream")
//            }
//        } else {
//            let otpURL = vm.buildOTPAuthURL(issuer: "PayBito", accountName: currentEmail)
//            let _ = debugPrint("🔑 [QR] otpURL=\(otpURL) key=\(vm.googleAuthKey) pendingCode=\(vm.pendingGoogleAuthCode)")
//            Qrauthsetupview(
//                otpAuthURL:          otpURL,
//                recoveryKey:         vm.googleAuthKey,
//                prefillAuthCode:     vm.pendingGoogleAuthCode  // pre-fills GA code field if already entered in TwoFAFullSheet
//            ) { code in
//                vm.saveTwoFactorSettings(googleFactorOTP: code) { }
//            }
//            .overlay(alignment: .bottom) {
//                if vm.isLoading {
//                    HStack(spacing: 8) {
//                        ProgressView().tint(.white)
//                        Text("Saving…").font(.system(size: 13)).foregroundColor(.white)
//                    }
//                    .padding(.horizontal, 20).padding(.vertical, 12)
//                    .background(Color.black.opacity(0.7))
//                    .cornerRadius(12).padding(.bottom, 40)
//                } else if !vm.errorMessage.isEmpty {
//                    Text(vm.errorMessage)
//                        .font(.system(size: 13)).foregroundColor(.white)
//                        .padding(.horizontal, 20).padding(.vertical, 12)
//                        .background(Color(red: 0.8, green: 0.15, blue: 0.15).opacity(0.9))
//                        .cornerRadius(12).padding(.bottom, 40)
//                } else if !vm.successMessage.isEmpty {
//                    Text(vm.successMessage)
//                        .font(.system(size: 13)).foregroundColor(.white)
//                        .padding(.horizontal, 20).padding(.vertical, 12)
//                        .background(Color(red: 0.15, green: 0.65, blue: 0.35).opacity(0.9))
//                        .cornerRadius(12).padding(.bottom, 40)
//                }
//            }
//        }
//    }
//}
//
//// ─────────────────────────────────────────────────────────────────────────────
//// MARK: Previews
//// ─────────────────────────────────────────────────────────────────────────────
//
//#Preview("twoFAKey 1 — Email OTP → QR") { TwofaView(twoFAKey: 1) }
//#Preview("twoFAKey 0 — Gmail OTP only") { TwofaView(twoFAKey: 0) }
//#Preview("Security section — key 1") {
//    ZStack {
//        Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()
//        TwofaSecuritySectionView(vm: TwofaUserSettingsViewModel(), twoFAKey: 1).padding()
//    }
//}





