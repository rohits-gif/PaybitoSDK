// MARK: - GoogleAuthSetupView.swift
// Step 3 of the 2FA setup flow:
//   1. Shows QR code built from google_auth_key returned by GetTwoFactorykey
//   2. Shows recovery key (the same google_auth_key)
//   3. User enters 6-digit code from their authenticator app
//   4. onSubmit callback → TwofaView calls vm.saveTwoFactorSettings(googleFactorOTP:)
//      which POSTs to /MerchantDashboard/SaveTwoFactorSettings
//      Payload: { merchant_id, google_auth_enabled: "1", google_factor_otp: "<code>" }

import SwiftUI
import CoreImage.CIFilterBuiltins

// MARK: - QR Code Generator

struct QRCodeView: View {
    let data: String
    let size: CGFloat

    var body: some View {
        if let image = generateQRCode(from: data) {
            Image(uiImage: image)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .frame(width: size, height: size)
                .overlay(Text("QR Error").foregroundColor(.red))
        }
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let context = CIContext()
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(Data(string.utf8), forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")
        guard let outputImage = filter.outputImage else { return nil }
        let scaleX = size / outputImage.extent.size.width
        let scaleY = size / outputImage.extent.size.height
        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

// MARK: - Recovery Key Row

struct RecoveryKeyRow: View {
    let key: String
    @Binding var copied: Bool

    private var accentBlue: Color { Color(red: 0.482, green: 0.549, blue: 1.0) }

    var body: some View {
        HStack {
            Text(key)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer()
            Button {
                UIPasteboard.general.string = key
                withAnimation(.spring(response: 0.3)) { copied = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { copied = false }
                }
            } label: {
                Text(copied ? "Copied!" : "Copy")
                    .font(.system(.subheadline, weight: .semibold))
                    .foregroundColor(copied ? .green : accentBlue)
                    .animation(.easeInOut, value: copied)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
    }
}

// MARK: - Main View

struct Qrauthsetupview: View {

    /// otpauth:// URL built from google_auth_key — scanned by Google Authenticator
    let otpAuthURL: String
    /// The raw TOTP secret (google_auth_key) — shown as recovery key
    let recoveryKey: String
    /// Optional: 6-digit code already entered in TwoFAFullSheet (twoFAKey == 1 path).
    /// Pre-fills the auth code field so the user doesn't have to type it again.
    var prefillAuthCode: String = ""

    @State private var authCode:      String = ""
    @State private var keyCopied:     Bool   = false
    @State private var isSubmitting:  Bool   = false
    @State private var showError:     Bool   = false
    @State private var errorMessage:  String = ""
    @State private var submitSuccess: Bool   = false

    /// Callback: receives the validated 6-digit code.
    /// Caller (TwofaView) uses this to call vm.saveTwoFactorSettings(googleFactorOTP:)
    var onSubmit: ((String) -> Void)?

    // MARK: Colors
    private var bgColor:       Color { Color(red: 0.059, green: 0.067, blue: 0.090) }
    private var accentPurple:  Color { Color(red: 0.482, green: 0.424, blue: 0.965) }
    private var accentBlue:    Color { Color(red: 0.482, green: 0.549, blue: 1.000) }
    private var textPrimary:   Color { .white }
    private var textSecondary: Color { Color(red: 0.612, green: 0.639, blue: 0.686) }
    private var dangerRed:     Color { Color(red: 0.973, green: 0.443, blue: 0.443) }

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    // MARK: Header
                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color(red: 0.118, green: 0.133, blue: 0.208))
                                .frame(width: 72, height: 72)
                                .shadow(color: accentPurple.opacity(0.3), radius: 12, x: 0, y: 0)
                            Image(systemName: "lock.shield.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [accentBlue, accentPurple],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .padding(.top, 28)
                        Text("Google Authentication")
                            .font(.system(.title2, weight: .bold))
                            .foregroundColor(accentBlue)
                    }
                    .padding(.bottom, 24)

                    // MARK: Instructions
                    VStack(spacing: 6) {
                        Text("Scan this QR code with Google Authenticator")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundColor(textPrimary)
                            .multilineTextAlignment(.center)
                        Text("Open the Google Authenticator app on your phone and tap the + button to scan.")
                            .font(.system(.caption))
                            .foregroundColor(textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                    // MARK: QR Code Card
                    VStack(spacing: 0) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .padding(6)
                            QRCodeView(data: otpAuthURL, size: 220)
                                .padding(16)
                        }
                        .frame(width: 260, height: 260)
                        .background(Color.black)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1))
                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 0)
                    }
                    .padding(.bottom, 28)

                    // MARK: Recovery Key Section
                    VStack(spacing: 10) {
                        Text("Save this emergency recovery key")
                            .font(.system(.subheadline, weight: .semibold))
                            .foregroundColor(textPrimary)
                        Text("If you lose access to your phone, you won't be able to log in without this key. Print, copy, or write it down without letting anyone see it.")
                            .font(.system(.caption))
                            .foregroundColor(textSecondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(3)
                        Text("Seriously, save this key!")
                            .font(.system(.caption, weight: .semibold))
                            .foregroundColor(dangerRed)
                        RecoveryKeyRow(key: recoveryKey, copied: $keyCopied)
                            .padding(.top, 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)

                    // MARK: Auth Code Input
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Google Authenticator Code")
                            .font(.system(.caption, weight: .medium))
                            .foregroundColor(accentBlue)
                            .padding(.leading, 4)
                        TextField("6-digit code", text: $authCode)
                            .keyboardType(.numberPad)
                            .foregroundColor(textPrimary)
                            .tint(accentPurple)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.white.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        authCode.isEmpty ? accentBlue.opacity(0.6) : accentPurple,
                                        lineWidth: 1.5
                                    )
                            )
                            .onChange(of: authCode) { newValue in
                                authCode = String(newValue.filter { $0.isNumber }.prefix(6))
                                showError = false
                            }
                    }
                    .padding(.horizontal, 20)

                    if showError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.circle.fill").font(.caption)
                            Text(errorMessage).font(.caption)
                        }
                        .foregroundColor(dangerRed)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // MARK: Submit Button
                    Button { handleSubmit() } label: {
                        ZStack {
                            if isSubmitting {
                                ProgressView().tint(.white)
                            } else {
                                Text(submitSuccess ? "✓ Verified!" : "Submit")
                                    .font(.system(.body, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(
                            LinearGradient(
                                colors: submitSuccess
                                    ? [Color(red: 0.133, green: 0.773, blue: 0.369),
                                       Color(red: 0.086, green: 0.639, blue: 0.290)]
                                    : [Color(red: 0.545, green: 0.361, blue: 0.965),
                                       Color(red: 0.427, green: 0.157, blue: 0.851)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(
                            color: (submitSuccess
                                ? Color(red: 0.133, green: 0.773, blue: 0.369)
                                : accentPurple).opacity(0.4),
                            radius: 10, x: 0, y: 4
                        )
                        .scaleEffect(isSubmitting ? 0.97 : 1.0)
                        .animation(.spring(response: 0.3), value: isSubmitting)
                    }
                    .disabled(isSubmitting || authCode.count < 6)
                    .opacity(authCode.count < 6 ? 0.6 : 1.0)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            // Pre-fill if code was already entered in TwoFAFullSheet (twoFAKey == 1)
            if !prefillAuthCode.isEmpty { authCode = prefillAuthCode }
        }
    }

    // MARK: - Submit
    // Validates the 6-digit code, then fires the onSubmit callback.
    // The actual API call (SaveTwoFactorSettings) is made by TwofaView via the callback.

    private func handleSubmit() {
        guard authCode.count == 6 else {
            withAnimation {
                errorMessage = "Please enter a 6-digit code."
                showError = true
            }
            return
        }
        isSubmitting = true
        // Brief visual feedback before handing off to parent
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            isSubmitting = false
            withAnimation(.spring()) { submitSuccess = true }
            onSubmit?(authCode)
        }
    }
}

// MARK: - Preview

#Preview {
    Qrauthsetupview(
        otpAuthURL: "otpauth://totp/PayBito:user@example.com?secret=K5YVNUNDJO7W2EX5TYFRO3Z37FYMPBJX&issuer=PayBito",
        recoveryKey: "K5YVNUNDJO7W2EX5TYFRO3Z37FYMPBJX"
    ) { code in
        print("Submitted code: \(code)")
    }
}

















//// MARK: - GoogleAuthSetupView.swift
//// Step 3 of the 2FA setup flow:
////   1. Shows QR code built from google_auth_key returned by GetTwoFactorykey
////   2. Shows recovery key (the same google_auth_key)
////   3. User enters 6-digit code from their authenticator app
////   4. onSubmit callback → TwofaView calls vm.saveTwoFactorSettings(googleFactorOTP:)
////      which POSTs to /MerchantDashboard/SaveTwoFactorSettings
////      Payload: { merchant_id, google_auth_enabled: "1", google_factor_otp: "<code>" }
//
//import SwiftUI
//import CoreImage.CIFilterBuiltins
//
//// MARK: - QR Code Generator
//
//struct QRCodeView: View {
//    let data: String
//    let size: CGFloat
//
//    var body: some View {
//        if let image = generateQRCode(from: data) {
//            Image(uiImage: image)
//                .interpolation(.none)
//                .resizable()
//                .scaledToFit()
//                .frame(width: size, height: size)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//        } else {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white)
//                .frame(width: size, height: size)
//                .overlay(Text("QR Error").foregroundColor(.red))
//        }
//    }
//
//    private func generateQRCode(from string: String) -> UIImage? {
//        let context = CIContext()
//        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
//        filter.setValue(Data(string.utf8), forKey: "inputMessage")
//        filter.setValue("M", forKey: "inputCorrectionLevel")
//        guard let outputImage = filter.outputImage else { return nil }
//        let scaleX = size / outputImage.extent.size.width
//        let scaleY = size / outputImage.extent.size.height
//        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
//        return UIImage(cgImage: cgImage)
//    }
//}
//
//// MARK: - Recovery Key Row
//
//struct RecoveryKeyRow: View {
//    let key: String
//    @Binding var copied: Bool
//
//    private var accentBlue: Color { Color(red: 0.482, green: 0.549, blue: 1.0) }
//
//    var body: some View {
//        HStack {
//            Text(key)
//                .font(.system(.subheadline, design: .monospaced))
//                .foregroundColor(.white)
//                .lineLimit(1)
//                .minimumScaleFactor(0.7)
//            Spacer()
//            Button {
//                UIPasteboard.general.string = key
//                withAnimation(.spring(response: 0.3)) { copied = true }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    withAnimation { copied = false }
//                }
//            } label: {
//                Text(copied ? "Copied!" : "Copy")
//                    .font(.system(.subheadline, weight: .semibold))
//                    .foregroundColor(copied ? .green : accentBlue)
//                    .animation(.easeInOut, value: copied)
//            }
//        }
//        .padding(.horizontal, 16).padding(.vertical, 14)
//        .background(Color.white.opacity(0.07))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
//    }
//}
//
//// MARK: - Main View
//
//struct Qrauthsetupview: View {
//
//    /// otpauth:// URL built from google_auth_key — scanned by Google Authenticator
//    let otpAuthURL: String
//    /// The raw TOTP secret (google_auth_key) — shown as recovery key
//    let recoveryKey: String
//
//    @State private var authCode:      String = ""
//    @State private var keyCopied:     Bool   = false
//    @State private var isSubmitting:  Bool   = false
//    @State private var showError:     Bool   = false
//    @State private var errorMessage:  String = ""
//    @State private var submitSuccess: Bool   = false
//
//    /// Callback: receives the validated 6-digit code.
//    /// Caller (TwofaView) uses this to call vm.saveTwoFactorSettings(googleFactorOTP:)
//    var onSubmit: ((String) -> Void)?
//
//    // MARK: Colors
//    private var bgColor:       Color { Color(red: 0.059, green: 0.067, blue: 0.090) }
//    private var accentPurple:  Color { Color(red: 0.482, green: 0.424, blue: 0.965) }
//    private var accentBlue:    Color { Color(red: 0.482, green: 0.549, blue: 1.000) }
//    private var textPrimary:   Color { .white }
//    private var textSecondary: Color { Color(red: 0.612, green: 0.639, blue: 0.686) }
//    private var dangerRed:     Color { Color(red: 0.973, green: 0.443, blue: 0.443) }
//
//    var body: some View {
//        ZStack {
//            bgColor.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//
//                    // MARK: Header
//                    VStack(spacing: 10) {
//                        ZStack {
//                            Circle()
//                                .fill(Color(red: 0.118, green: 0.133, blue: 0.208))
//                                .frame(width: 72, height: 72)
//                                .shadow(color: accentPurple.opacity(0.3), radius: 12, x: 0, y: 0)
//                            Image(systemName: "lock.shield.fill")
//                                .font(.system(size: 32))
//                                .foregroundStyle(
//                                    LinearGradient(
//                                        colors: [accentBlue, accentPurple],
//                                        startPoint: .topLeading, endPoint: .bottomTrailing
//                                    )
//                                )
//                        }
//                        .padding(.top, 28)
//                        Text("Google Authentication")
//                            .font(.system(.title2, weight: .bold))
//                            .foregroundColor(accentBlue)
//                    }
//                    .padding(.bottom, 24)
//
//                    // MARK: Instructions
//                    VStack(spacing: 6) {
//                        Text("Scan this QR code with Google Authenticator")
//                            .font(.system(.subheadline, weight: .semibold))
//                            .foregroundColor(textPrimary)
//                            .multilineTextAlignment(.center)
//                        Text("Open the Google Authenticator app on your phone and tap the + button to scan.")
//                            .font(.system(.caption))
//                            .foregroundColor(textSecondary)
//                            .multilineTextAlignment(.center)
//                            .lineSpacing(3)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//
//                    // MARK: QR Code Card
//                    VStack(spacing: 0) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(Color.white)
//                                .padding(6)
//                            QRCodeView(data: otpAuthURL, size: 220)
//                                .padding(16)
//                        }
//                        .frame(width: 260, height: 260)
//                        .background(Color.black)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .overlay(RoundedRectangle(cornerRadius: 20)
//                            .stroke(Color.white.opacity(0.1), lineWidth: 1))
//                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 0)
//                    }
//                    .padding(.bottom, 28)
//
//                    // MARK: Recovery Key Section
//                    VStack(spacing: 10) {
//                        Text("Save this emergency recovery key")
//                            .font(.system(.subheadline, weight: .semibold))
//                            .foregroundColor(textPrimary)
//                        Text("If you lose access to your phone, you won't be able to log in without this key. Print, copy, or write it down without letting anyone see it.")
//                            .font(.system(.caption))
//                            .foregroundColor(textSecondary)
//                            .multilineTextAlignment(.center)
//                            .lineSpacing(3)
//                        Text("Seriously, save this key!")
//                            .font(.system(.caption, weight: .semibold))
//                            .foregroundColor(dangerRed)
//                        RecoveryKeyRow(key: recoveryKey, copied: $keyCopied)
//                            .padding(.top, 4)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 24)
//
//                    // MARK: Auth Code Input
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text("Google Authenticator Code")
//                            .font(.system(.caption, weight: .medium))
//                            .foregroundColor(accentBlue)
//                            .padding(.leading, 4)
//                        TextField("6-digit code", text: $authCode)
//                            .keyboardType(.numberPad)
//                            .foregroundColor(textPrimary)
//                            .tint(accentPurple)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 14)
//                            .background(Color.white.opacity(0.05))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(
//                                        authCode.isEmpty ? accentBlue.opacity(0.6) : accentPurple,
//                                        lineWidth: 1.5
//                                    )
//                            )
//                            .onChange(of: authCode) { newValue in
//                                authCode = String(newValue.filter { $0.isNumber }.prefix(6))
//                                showError = false
//                            }
//                    }
//                    .padding(.horizontal, 20)
//
//                    if showError {
//                        HStack(spacing: 6) {
//                            Image(systemName: "exclamationmark.circle.fill").font(.caption)
//                            Text(errorMessage).font(.caption)
//                        }
//                        .foregroundColor(dangerRed)
//                        .padding(.horizontal, 20)
//                        .padding(.top, 8)
//                        .transition(.opacity.combined(with: .move(edge: .top)))
//                    }
//
//                    // MARK: Submit Button
//                    Button { handleSubmit() } label: {
//                        ZStack {
//                            if isSubmitting {
//                                ProgressView().tint(.white)
//                            } else {
//                                Text(submitSuccess ? "✓ Verified!" : "Submit")
//                                    .font(.system(.body, weight: .semibold))
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        .frame(maxWidth: .infinity).frame(height: 52)
//                        .background(
//                            LinearGradient(
//                                colors: submitSuccess
//                                    ? [Color(red: 0.133, green: 0.773, blue: 0.369),
//                                       Color(red: 0.086, green: 0.639, blue: 0.290)]
//                                    : [Color(red: 0.545, green: 0.361, blue: 0.965),
//                                       Color(red: 0.427, green: 0.157, blue: 0.851)],
//                                startPoint: .leading, endPoint: .trailing
//                            )
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                        .shadow(
//                            color: (submitSuccess
//                                ? Color(red: 0.133, green: 0.773, blue: 0.369)
//                                : accentPurple).opacity(0.4),
//                            radius: 10, x: 0, y: 4
//                        )
//                        .scaleEffect(isSubmitting ? 0.97 : 1.0)
//                        .animation(.spring(response: 0.3), value: isSubmitting)
//                    }
//                    .disabled(isSubmitting || authCode.count < 6)
//                    .opacity(authCode.count < 6 ? 0.6 : 1.0)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 16)
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)
//    }
//
//    // MARK: - Submit
//    // Validates the 6-digit code, then fires the onSubmit callback.
//    // The actual API call (SaveTwoFactorSettings) is made by TwofaView via the callback.
//
//    private func handleSubmit() {
//        guard authCode.count == 6 else {
//            withAnimation {
//                errorMessage = "Please enter a 6-digit code."
//                showError = true
//            }
//            return
//        }
//        isSubmitting = true
//        // Brief visual feedback before handing off to parent
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            isSubmitting = false
//            withAnimation(.spring()) { submitSuccess = true }
//            onSubmit?(authCode)
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    Qrauthsetupview(
//        otpAuthURL: "otpauth://totp/PayBito:user@example.com?secret=K5YVNUNDJO7W2EX5TYFRO3Z37FYMPBJX&issuer=PayBito",
//        recoveryKey: "K5YVNUNDJO7W2EX5TYFRO3Z37FYMPBJX"
//    ) { code in
//        print("Submitted code: \(code)")
//    }
//}












//// MARK: - GoogleAuthSetupView.swift
//// Step 3 of the 2FA setup flow:
////   1. Shows QR code built from google_auth_key returned by GetTwoFactorykey
////   2. Shows recovery key (the same google_auth_key)
////   3. User enters 6-digit code from their authenticator app
////   4. onSubmit callback → TwofaView calls vm.saveTwoFactorSettings(googleFactorOTP:)
////      which POSTs to /MerchantDashboard/SaveTwoFactorSettings
////      Payload: { merchant_id, google_auth_enabled: "1", google_factor_otp: "<code>" }
//
//import SwiftUI
//import CoreImage.CIFilterBuiltins
//
//// MARK: - QR Code Generator
//
//struct QRCodeView: View {
//    let data: String
//    let size: CGFloat
//
//    var body: some View {
//        if let image = generateQRCode(from: data) {
//            Image(uiImage: image)
//                .interpolation(.none)
//                .resizable()
//                .scaledToFit()
//                .frame(width: size, height: size)
//                .clipShape(RoundedRectangle(cornerRadius: 12))
//        } else {
//            RoundedRectangle(cornerRadius: 12)
//                .fill(Color.white)
//                .frame(width: size, height: size)
//                .overlay(Text("QR Error").foregroundColor(.red))
//        }
//    }
//
//    private func generateQRCode(from string: String) -> UIImage? {
//        let context = CIContext()
//        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
//        filter.setValue(Data(string.utf8), forKey: "inputMessage")
//        filter.setValue("M", forKey: "inputCorrectionLevel")
//        guard let outputImage = filter.outputImage else { return nil }
//        let scaleX = size / outputImage.extent.size.width
//        let scaleY = size / outputImage.extent.size.height
//        let scaled = outputImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
//        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
//        return UIImage(cgImage: cgImage)
//    }
//}
//
//// MARK: - Recovery Key Row
//
//struct RecoveryKeyRow: View {
//    let key: String
//    @Binding var copied: Bool
//
//    private var accentBlue: Color { Color(red: 0.482, green: 0.549, blue: 1.0) }
//
//    var body: some View {
//        HStack {
//            Text(key)
//                .font(.system(.subheadline, design: .monospaced))
//                .foregroundColor(.white)
//                .lineLimit(1)
//                .minimumScaleFactor(0.7)
//            Spacer()
//            Button {
//                UIPasteboard.general.string = key
//                withAnimation(.spring(response: 0.3)) { copied = true }
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    withAnimation { copied = false }
//                }
//            } label: {
//                Text(copied ? "Copied!" : "Copy")
//                    .font(.system(.subheadline, weight: .semibold))
//                    .foregroundColor(copied ? .green : accentBlue)
//                    .animation(.easeInOut, value: copied)
//            }
//        }
//        .padding(.horizontal, 16).padding(.vertical, 14)
//        .background(Color.white.opacity(0.07))
//        .clipShape(RoundedRectangle(cornerRadius: 12))
//        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.12), lineWidth: 1))
//    }
//}
//
//// MARK: - Main View
//
//struct Qrauthsetupview: View {
//
//    /// otpauth:// URL built from google_auth_key — scanned by Google Authenticator
//    let otpAuthURL: String
//    /// The raw TOTP secret (google_auth_key) — shown as recovery key
//    let recoveryKey: String
//
//    @State private var authCode:       String = ""
//    @State private var keyCopied:      Bool   = false
//    @State private var isSubmitting:   Bool   = false
//    @State private var showError:      Bool   = false
//    @State private var errorMessage:   String = ""
//    @State private var submitSuccess:  Bool   = false
//
//    /// Callback: receives the validated 6-digit code.
//    /// Caller (TwofaView) uses this to call vm.saveTwoFactorSettings(googleFactorOTP:)
//    var onSubmit: ((String) -> Void)?
//
//    // MARK: Colors
//    private var bgColor:       Color { Color(red: 0.059, green: 0.067, blue: 0.090) }
//    private var accentPurple:  Color { Color(red: 0.482, green: 0.424, blue: 0.965) }
//    private var accentBlue:    Color { Color(red: 0.482, green: 0.549, blue: 1.000) }
//    private var textPrimary:   Color { .white }
//    private var textSecondary: Color { Color(red: 0.612, green: 0.639, blue: 0.686) }
//    private var dangerRed:     Color { Color(red: 0.973, green: 0.443, blue: 0.443) }
//
//    var body: some View {
//        ZStack {
//            bgColor.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//
//                    // MARK: Header
//                    VStack(spacing: 10) {
//                        ZStack {
//                            Circle()
//                                .fill(Color(red: 0.118, green: 0.133, blue: 0.208))
//                                .frame(width: 72, height: 72)
//                                .shadow(color: accentPurple.opacity(0.3), radius: 12, x: 0, y: 0)
//                            Image(systemName: "lock.shield.fill")
//                                .font(.system(size: 32))
//                                .foregroundStyle(
//                                    LinearGradient(
//                                        colors: [accentBlue, accentPurple],
//                                        startPoint: .topLeading, endPoint: .bottomTrailing
//                                    )
//                                )
//                        }
//                        .padding(.top, 28)
//                        Text("Google Authentication")
//                            .font(.system(.title2, weight: .bold))
//                            .foregroundColor(accentBlue)
//                    }
//                    .padding(.bottom, 24)
//
//                    // MARK: Instructions
//                    VStack(spacing: 6) {
//                        Text("Scan this QR code with Google Authenticator")
//                            .font(.system(.subheadline, weight: .semibold))
//                            .foregroundColor(textPrimary)
//                            .multilineTextAlignment(.center)
//                        Text("Open the Google Authenticator app on your phone and tap the + button to scan.")
//                            .font(.system(.caption))
//                            .foregroundColor(textSecondary)
//                            .multilineTextAlignment(.center)
//                            .lineSpacing(3)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//
//                    // MARK: QR Code Card
//                    VStack(spacing: 0) {
//                        ZStack {
//                            RoundedRectangle(cornerRadius: 16)
//                                .fill(Color.white)
//                                .padding(6)
//                            QRCodeView(data: otpAuthURL, size: 220)
//                                .padding(16)
//                        }
//                        .frame(width: 260, height: 260)
//                        .background(Color.black)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .overlay(RoundedRectangle(cornerRadius: 20)
//                            .stroke(Color.white.opacity(0.1), lineWidth: 1))
//                        .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 0)
//                    }
//                    .padding(.bottom, 28)
//
//                    // MARK: Recovery Key Section
//                    VStack(spacing: 10) {
//                        Text("Save this emergency recovery key")
//                            .font(.system(.subheadline, weight: .semibold))
//                            .foregroundColor(textPrimary)
//                        Text("If you lose access to your phone, you won't be able to log in without this key. Print, copy, or write it down without letting anyone see it.")
//                            .font(.system(.caption))
//                            .foregroundColor(textSecondary)
//                            .multilineTextAlignment(.center)
//                            .lineSpacing(3)
//                        Text("Seriously, save this key!")
//                            .font(.system(.caption, weight: .semibold))
//                            .foregroundColor(dangerRed)
//                        RecoveryKeyRow(key: recoveryKey, copied: $keyCopied)
//                            .padding(.top, 4)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 24)
//
//                    // MARK: Auth Code Input
//                    VStack(alignment: .leading, spacing: 6) {
//                        Text("Google Authenticator Code")
//                            .font(.system(.caption, weight: .medium))
//                            .foregroundColor(accentBlue)
//                            .padding(.leading, 4)
//                        TextField("6-digit code", text: $authCode)
//                            .keyboardType(.numberPad)
//                         //   .font(.system(.title3, weight: .medium, design: .monospaced))
//                            .foregroundColor(textPrimary)
//                            .tint(accentPurple)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 14)
//                            .background(Color.white.opacity(0.05))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(
//                                        authCode.isEmpty ? accentBlue.opacity(0.6) : accentPurple,
//                                        lineWidth: 1.5
//                                    )
//                            )
//                            .onChange(of: authCode) { newValue in
//                                authCode = String(newValue.filter { $0.isNumber }.prefix(6))
//                                showError = false
//                            }
//                    }
//                    .padding(.horizontal, 20)
//
//                    if showError {
//                        HStack(spacing: 6) {
//                            Image(systemName: "exclamationmark.circle.fill").font(.caption)
//                            Text(errorMessage).font(.caption)
//                        }
//                        .foregroundColor(dangerRed)
//                        .padding(.horizontal, 20)
//                        .padding(.top, 8)
//                        .transition(.opacity.combined(with: .move(edge: .top)))
//                    }
//
//                    // MARK: Submit Button
//                    Button { handleSubmit() } label: {
//                        ZStack {
//                            if isSubmitting {
//                                ProgressView().tint(.white)
//                            } else {
//                                Text(submitSuccess ? "✓ Verified!" : "Submit")
//                                    .font(.system(.body, weight: .semibold))
//                                    .foregroundColor(.white)
//                            }
//                        }
//                        .frame(maxWidth: .infinity).frame(height: 52)
//                        .background(
//                            LinearGradient(
//                                colors: submitSuccess
//                                    ? [Color(red: 0.133, green: 0.773, blue: 0.369),
//                                       Color(red: 0.086, green: 0.639, blue: 0.290)]
//                                    : [Color(red: 0.545, green: 0.361, blue: 0.965),
//                                       Color(red: 0.427, green: 0.157, blue: 0.851)],
//                                startPoint: .leading, endPoint: .trailing
//                            )
//                        )
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                        .shadow(
//                            color: (submitSuccess
//                                ? Color(red: 0.133, green: 0.773, blue: 0.369)
//                                : accentPurple).opacity(0.4),
//                            radius: 10, x: 0, y: 4
//                        )
//                        .scaleEffect(isSubmitting ? 0.97 : 1.0)
//                        .animation(.spring(response: 0.3), value: isSubmitting)
//                    }
//                    .disabled(isSubmitting || authCode.count < 6)
//                    .opacity(authCode.count < 6 ? 0.6 : 1.0)
//                    .padding(.horizontal, 20)
//                    .padding(.top, 16)
//                    .padding(.bottom, 40)
//                }
//            }
//        }
//        .navigationBarBackButtonHidden(true)  // prevent accidental back during setup
//    }
//
//    // MARK: - Submit
//    // Validates the 6-digit code, then fires the onSubmit callback.
//    // The actual API call (SaveTwoFactorSettings) is made by the parent (TwofaView).
//
//    private func handleSubmit() {
//        guard authCode.count == 6 else {
//            withAnimation {
//                errorMessage = "Please enter a 6-digit code."
//                showError = true
//            }
//            return
//        }
//        isSubmitting = true
//        // Brief visual feedback before handing off
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
//            isSubmitting = false
//            withAnimation(.spring()) { submitSuccess = true }
//            // Notify parent to call SaveTwoFactorSettings
//            onSubmit?(authCode)
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    Qrauthsetupview(
//        otpAuthURL: "otpauth://totp/PayBito:user@example.com?secret=JVIGANXPEEOT6WBACZXSV5D3PFSTVNMB&issuer=PayBito",
//        recoveryKey: "JVIGANXPEEOT6WBACZXSV5D3PFSTVNMB"
//    ) { code in
//        print("Submitted code: \(code)")
//    }
//}


