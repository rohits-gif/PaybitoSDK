//MARK: - TwofaUserSettingsViewModel.swift

import SwiftUI
import Combine

@MainActor
final class TwofaUserSettingsViewModel: ObservableObject {

    // MARK: - Published UI State

    @Published var firstName:  String = ""
    @Published var lastName:   String = ""
    @Published var phone:      String = ""

    @Published var googleAuthToggle: Bool = false {
        didSet {
            guard !isSyncingFromAPI else { return }
            handleToggleChange(newValue: googleAuthToggle)
        }
    }

    @Published var phoneAuthEnabled: Bool = false

    @Published var isLoading:      Bool   = false
    @Published var errorMessage:   String = ""
    @Published var successMessage: String = ""

    // MARK: Sheet / Navigation flags

    /// Step 1 sheet: enter email OTP (GmailOTPSheet / TwoFAFullSheet)
    @Published var showGmailOTPSheet: Bool = false

    /// Step 2a: signals TwoFAFullSheet to dismiss itself (twoFAKey == 1 path)
    /// Reset to false by the sheet after it calls dismiss()
    @Published var dismissOTPSheet: Bool = false

    /// Step 2b navigation: show QR setup screen after GetTwoFactorykey succeeds
    @Published var googleAuthKey:         String = ""   // TOTP secret for QR
    @Published var showQRSetupScreen:     Bool   = false

    /// GA code entered in TwoFAFullSheet (twoFAKey == 1).
    @Published var pendingGoogleAuthCode: String = ""

    @Published var resendCountdown: Int = 0

    /// Disable flow: OTP sheet shown when toggle turns OFF
    @Published var showDisableOTPSheet: Bool = false

    // MARK: - Internal State

    private(set) var twoFAState:           TwoFAState = .neverSetup
    private(set) var rawGoogleAuthEnabled: Int = 0
    private(set) var rawTwoFactorEnabled:  Int = 0

    var isSyncingFromAPI = false
    private var countdownTimer: Timer?

    // MARK: - Service & Merchant ID

    let service: TwofaUserSettingsServiceProtocol

    var merchantId: String {
        let intKeys = ["Bmerchant_id", "merchant_id", "BmerchantId"]
        for key in intKeys {
            let val = UserDefaults.standard.integer(forKey: key)
            if val != 0 { return "\(val)" }
        }
        let stringKeys = ["merchantId", "Bmerchant_id_str"]
        for key in stringKeys {
            if let val = UserDefaults.standard.string(forKey: key), !val.isEmpty { return val }
        }
        debugPrint("❌ [TwofaVM] merchantId not found")
        return ""
    }

    // MARK: - Init

    init(service: TwofaUserSettingsServiceProtocol = TwofaUserSettingsService.shared) {
        self.service = service
    }

    deinit {
        countdownTimer?.invalidate()
    }

    // MARK: - Fetch Settings

    func fetchUserSettings() {
        guard !merchantId.isEmpty else {
            errorMessage = "Merchant ID not found. Please log in again."
            return
        }
        isLoading = true
        clearMessages()
        service.fetchUserSettings(merchantId: merchantId) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let data): self.applyAPIResponse(data)
            case .failure(let err):  self.errorMessage = err.localizedDescription
            }
        }
    }

    // MARK: - Apply API Response

    private func applyAPIResponse(_ data: TwofaUserSettingsResponse) {
        rawGoogleAuthEnabled = data.googleAuthEnabled
        rawTwoFactorEnabled  = data.twoFactorAuthEnabled

        twoFAState = TwoFAState(
            twoFactorAuthEnabled: data.twoFactorAuthEnabled,
            googleAuthEnabled:    data.googleAuthEnabled
        )

        firstName        = data.firstName ?? ""
        lastName         = data.lastName  ?? ""
        phone            = data.phoneNo   ?? ""
        phoneAuthEnabled = data.phoneAuthEnabled == 1

        isSyncingFromAPI = true
        googleAuthToggle = twoFAState.isToggleOn
        isSyncingFromAPI = false

        debugPrint("📊 [VM] state=\(twoFAState) google_auth=\(rawGoogleAuthEnabled) two_factor=\(rawTwoFactorEnabled)")
    }

    // MARK: - Toggle Logic

    private func handleToggleChange(newValue: Bool) {
        newValue ? onToggleTurnedOn() : onToggleTurnedOff()
    }

    private func onToggleTurnedOn() {
        guard !merchantId.isEmpty else {
            revertToggleOff()
            errorMessage = "Session expired. Please log in again."
            return
        }
        sendOTP()
    }

    // MARK: - Toggle OFF → Send OTP first, then disable after verification

    private func onToggleTurnedOff() {
        guard !merchantId.isEmpty else {
            revertToggleOn()
            errorMessage = "Session expired. Please log in again."
            return
        }
        sendDisableOTP()
    }

    // MARK: - Send OTP for Disable flow

    func sendDisableOTP() {
        guard !isLoading else { return }
        isLoading = true
        clearMessages()

        let email = UserDefaults.standard.string(forKey: "Bemail") ?? ""
        debugPrint("📤 [VM] sendDisableOTP merchantId=\(merchantId) email=\(email)")

        service.sendGmailOTP(merchantId: merchantId, email: email) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.startResendCountdown()
                self.showDisableOTPSheet = true
            case .failure(let err):
                self.revertToggleOn()
                self.errorMessage = "Failed to send OTP: \(err.localizedDescription)"
            }
        }
    }

    // MARK: - Verify OTP then disable Google Auth

    // REPLACE this method signature and body:
    func verifyOTPAndDisable(emailOTP: String, googleAuthCode: String) {
        guard !emailOTP.isEmpty else { errorMessage = "Please enter the OTP"; return }
        guard googleAuthCode.count == 6 else { errorMessage = "Please enter the 6-digit authenticator code"; return }
        isLoading = true
        clearMessages()
        debugPrint("🔐 [VM] verifyOTPAndDisable emailOTP=\(emailOTP) googleAuthCode=\(googleAuthCode)")

        service.disableGoogleAuth(merchantId: merchantId) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                debugPrint("✅ [VM] disableGoogleAuth success")
                self.stopResendCountdown()
                self.showDisableOTPSheet  = false
                self.successMessage       = "Two-Factor Authentication disabled."
                self.isSyncingFromAPI     = true
                self.rawGoogleAuthEnabled = 0
                self.rawTwoFactorEnabled  = 0
                self.twoFAState           = .neverSetup
                self.googleAuthToggle     = false
                self.isSyncingFromAPI     = false
            case .failure(let err):
                debugPrint("❌ [VM] disableGoogleAuth failed: \(err.localizedDescription)")
                self.showDisableOTPSheet = false
                self.revertToggleOn()
                self.errorMessage = "Failed to disable 2FA: \(err.localizedDescription)"
            }
        }
    }
    // MARK: - Disable OTP Sheet dismissed without verifying

    func onDisableOTPSheetDismissedWithoutVerify() {
        debugPrint("⚠️ [VM] Disable OTP sheet dismissed without verify — reverting toggle ON")
        stopResendCountdown()
        revertToggleOn()
    }

    // MARK: - Step 1: Send OTP (Enable flow)
    // Called by: toggle ON, TwoFAFullSheet.onAppear, Update Email button (twoFAKey == 0)

    func sendOTP() {
        guard !isLoading else { return }
        isLoading = true
        clearMessages()

        let email = UserDefaults.standard.string(forKey: "Bemail") ?? ""
        debugPrint("📤 [VM] sendOTP merchantId=\(merchantId) email=\(email)")

        service.sendGmailOTP(merchantId: merchantId, email: email) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.startResendCountdown()
                self.showGmailOTPSheet = true
            case .failure(let err):
                self.revertToggleOff()
                self.errorMessage = "Failed to send OTP: \(err.localizedDescription)"
            }
        }
    }

    // MARK: - Step 2: Verify Email OTP → get google_auth_key (twoFAKey == 0)

    func verifyEmailOTPAndGetKey(emailOTP: String) {
        guard !emailOTP.isEmpty else {
            errorMessage = "Please enter the email OTP"
            return
        }
        isLoading = true
        clearMessages()
        debugPrint("🔐 [VM] GetTwoFactorykey (key==0) emailOTP=\(emailOTP)")

        service.getTwoFactoryKey(
            merchantId:     merchantId,
            email:          UserDefaults.standard.string(forKey: "Bemail") ?? "",
            emailOTP:       emailOTP,
            googleAuthCode: ""
        ) { [weak self] (result: Swift.Result<GetTwoFactoryKeyResponse, Error>) in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                guard let key = response.googleAuthKey, !key.isEmpty else {
                    self.errorMessage = "No Google Auth key returned. Please try again."
                    return
                }
                debugPrint("✅ [VM] verifyEmailOTPAndGetKey google_auth_key=\(key)")
                self.stopResendCountdown()
                self.googleAuthKey   = key
                self.dismissOTPSheet = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                    self.showQRSetupScreen = true
                }

            case .failure(let err):
                debugPrint("❌ [VM] verifyEmailOTPAndGetKey failed: \(err.localizedDescription)")
                self.errorMessage = err.localizedDescription
            }
        }
    }

    // MARK: - Step 2 (alt): Verify Email OTP → get google_auth_key (twoFAKey == 1)

    func verifyBothAndEnable(emailOTP: String, googleAuthCode: String) {
        guard !emailOTP.isEmpty else {
            errorMessage = "Please enter the email OTP"
            return
        }
        isLoading = true
        clearMessages()
        debugPrint("🔐 [VM] GetTwoFactorykey (key==1) emailOTP=\(emailOTP)")

        service.getTwoFactoryKey(
            merchantId:     merchantId,
            email:          UserDefaults.standard.string(forKey: "Bemail") ?? "",
            emailOTP:       emailOTP,
            googleAuthCode: ""
        ) { [weak self] (result: Swift.Result<GetTwoFactoryKeyResponse, Error>) in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let response):
                guard let key = response.googleAuthKey, !key.isEmpty else {
                    self.errorMessage = "No Google Auth key returned. Please try again."
                    return
                }
                debugPrint("✅ [VM] verifyBothAndEnable google_auth_key=\(key)")
                self.stopResendCountdown()
                self.googleAuthKey         = key
                self.pendingGoogleAuthCode = googleAuthCode
                self.dismissOTPSheet       = true

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                    guard let self else { return }
                    guard !self.showGmailOTPSheet else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                            self?.showQRSetupScreen = true
                        }
                        return
                    }
                    self.showQRSetupScreen = true
                }

            case .failure(let err):
                debugPrint("❌ [VM] verifyBothAndEnable failed: \(err.localizedDescription)")
                self.errorMessage = err.localizedDescription
            }
        }
    }

    // MARK: - Step 3: Save Two Factor Settings

    func saveTwoFactorSettings(googleFactorOTP: String, onSuccess: (() -> Void)? = nil) {
        guard !googleFactorOTP.isEmpty else {
            errorMessage = "Please enter the 6-digit code from your authenticator app"
            return
        }
        isLoading = true
        clearMessages()
        debugPrint("💾 [VM] SaveTwoFactorSettings otp=\(googleFactorOTP)")

        service.saveTwoFactorSettings(
            merchantId:        merchantId,
            googleAuthEnabled: "1",
            googleFactorOTP:   googleFactorOTP
        ) { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success:
                debugPrint("✅ [VM] SaveTwoFactorSettings — 2FA fully enabled")
                self.successMessage        = "Two-Factor Authentication enabled successfully!"
                self.showQRSetupScreen     = false
                self.googleAuthKey         = ""
                self.pendingGoogleAuthCode = ""
                self.isSyncingFromAPI      = true
                self.rawGoogleAuthEnabled  = 1
                self.rawTwoFactorEnabled   = 1
                self.twoFAState            = .fullyEnabled
                self.googleAuthToggle      = true
                self.isSyncingFromAPI      = false
                onSuccess?()

            case .failure(let err):
                debugPrint("❌ [VM] SaveTwoFactorSettings failed: \(err.localizedDescription)")
                self.errorMessage = err.localizedDescription
            }
        }
    }

    // MARK: - Enable OTP Sheet dismissed without verifying

    func onOTPSheetDismissedWithoutVerify() {
        debugPrint("⚠️ [VM] Sheet dismissed without verify — reverting toggle OFF")
        stopResendCountdown()
        revertToggleOff()
    }

    // MARK: - Resend OTP

    func resendOTP() {
        isLoading = true
        clearMessages()
        let email = UserDefaults.standard.string(forKey: "Bemail") ?? ""
        service.sendGmailOTP(merchantId: merchantId, email: email) { [weak self] result in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success:
                self.startResendCountdown()
            case .failure(let err):
                self.errorMessage = "Failed to resend OTP: \(err.localizedDescription)"
            }
        }
    }

    // MARK: - Helpers

    func buildOTPAuthURL(issuer: String = "PayBito", accountName: String = "") -> String {
        guard !googleAuthKey.isEmpty else {
            debugPrint("⚠️ [VM] buildOTPAuthURL called with empty googleAuthKey")
            return ""
        }
        let account = accountName.isEmpty ? "user" : accountName
        return "otpauth://totp/\(issuer):\(account)?secret=\(googleAuthKey)&issuer=\(issuer)"
    }

    private func revertToggleOff() {
        isSyncingFromAPI = true
        googleAuthToggle = false
        isSyncingFromAPI = false
    }

    private func revertToggleOn() {
        isSyncingFromAPI = true
        googleAuthToggle = true
        isSyncingFromAPI = false
    }

    // MARK: - Countdown Timer

    func startResendCountdown(from seconds: Int = 112) {
        stopResendCountdown()
        resendCountdown = seconds
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { timer.invalidate(); return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                if self.resendCountdown > 0 { self.resendCountdown -= 1 }
                else { timer.invalidate(); self.countdownTimer = nil }
            }
        }
    }

    func stopResendCountdown() {
        countdownTimer?.invalidate()
        countdownTimer  = nil
        resendCountdown = 0
    }

    func clearMessages() { errorMessage = ""; successMessage = "" }
    func clearError()    { errorMessage = "" }
    func clearSuccess()  { successMessage = "" }
}



















////MARK: - TwofaUserSettingsViewModel.swift
//
//import SwiftUI
//import Combine
//
//@MainActor
//final class TwofaUserSettingsViewModel: ObservableObject {
//
//    // MARK: - Published UI State
//
//    @Published var firstName:  String = ""
//    @Published var lastName:   String = ""
//    @Published var phone:      String = ""
//
//    @Published var googleAuthToggle: Bool = false {
//        didSet {
//            guard !isSyncingFromAPI else { return }
//            handleToggleChange(newValue: googleAuthToggle)
//        }
//    }
//
//    @Published var phoneAuthEnabled: Bool = false
//
//    @Published var isLoading:      Bool   = false
//    @Published var errorMessage:   String = ""
//    @Published var successMessage: String = ""
//
//    // MARK: Sheet / Navigation flags
//
//    /// Step 1 sheet: enter email OTP (GmailOTPSheet / TwoFAFullSheet)
//    @Published var showGmailOTPSheet: Bool = false
//
//    /// Step 2a: signals TwoFAFullSheet to dismiss itself (twoFAKey == 1 path)
//    /// Reset to false by the sheet after it calls dismiss()
//    @Published var dismissOTPSheet: Bool = false
//
//    /// Step 2b navigation: show QR setup screen after GetTwoFactorykey succeeds
//    /// Fired 0.65s after dismissOTPSheet (or showGmailOTPSheet = false) so the
//    /// sheet is fully gone before NavigationStack pushes Qrauthsetupview.
//    @Published var googleAuthKey:         String = ""   // TOTP secret for QR
//    @Published var showQRSetupScreen:     Bool   = false
//
//    /// GA code entered in TwoFAFullSheet (twoFAKey == 1).
//    /// Passed to saveTwoFactorSettings via Qrauthsetupview's onSubmit callback.
//    /// Empty on twoFAKey == 0 path (user enters code directly on QR screen).
//    @Published var pendingGoogleAuthCode: String = ""
//
//    @Published var resendCountdown: Int = 0
//
//    // MARK: - Internal State
//
//    private(set) var twoFAState:           TwoFAState = .neverSetup
//    private(set) var rawGoogleAuthEnabled: Int = 0
//    private(set) var rawTwoFactorEnabled:  Int = 0
//
//    var isSyncingFromAPI = false
//    private var countdownTimer: Timer?
//
//    // MARK: - Service & Merchant ID
//
//    let service: TwofaUserSettingsServiceProtocol
//
//    var merchantId: String {
//        let intKeys = ["Bmerchant_id", "merchant_id", "BmerchantId"]
//        for key in intKeys {
//            let val = UserDefaults.standard.integer(forKey: key)
//            if val != 0 { return "\(val)" }
//        }
//        let stringKeys = ["merchantId", "Bmerchant_id_str"]
//        for key in stringKeys {
//            if let val = UserDefaults.standard.string(forKey: key), !val.isEmpty { return val }
//        }
//        debugPrint("❌ [TwofaVM] merchantId not found")
//        return ""
//    }
//
//    // MARK: - Init
//
//    init(service: TwofaUserSettingsServiceProtocol = TwofaUserSettingsService.shared) {
//        self.service = service
//    }
//
//    deinit {
//        countdownTimer?.invalidate()
//    }
//
//    // MARK: - Fetch Settings
//
//    func fetchUserSettings() {
//        guard !merchantId.isEmpty else {
//            errorMessage = "Merchant ID not found. Please log in again."
//            return
//        }
//        isLoading = true
//        clearMessages()
//        service.fetchUserSettings(merchantId: merchantId) { [weak self] result in
//            guard let self else { return }
//            self.isLoading = false
//            switch result {
//            case .success(let data): self.applyAPIResponse(data)
//            case .failure(let err):  self.errorMessage = err.localizedDescription
//            }
//        }
//    }
//
//    // MARK: - Apply API Response
//
//    private func applyAPIResponse(_ data: TwofaUserSettingsResponse) {
//        rawGoogleAuthEnabled = data.googleAuthEnabled
//        rawTwoFactorEnabled  = data.twoFactorAuthEnabled
//
//        twoFAState = TwoFAState(
//            twoFactorAuthEnabled: data.twoFactorAuthEnabled,
//            googleAuthEnabled:    data.googleAuthEnabled
//        )
//
//        firstName        = data.firstName ?? ""
//        lastName         = data.lastName  ?? ""
//        phone            = data.phoneNo   ?? ""
//        phoneAuthEnabled = data.phoneAuthEnabled == 1
//
//        isSyncingFromAPI = true
//        googleAuthToggle = twoFAState.isToggleOn
//        isSyncingFromAPI = false
//
//        debugPrint("📊 [VM] state=\(twoFAState) google_auth=\(rawGoogleAuthEnabled) two_factor=\(rawTwoFactorEnabled)")
//    }
//
//    // MARK: - Toggle Logic
//
//    private func handleToggleChange(newValue: Bool) {
//        newValue ? onToggleTurnedOn() : onToggleTurnedOff()
//    }
//
//    private func onToggleTurnedOn() {
//        guard !merchantId.isEmpty else {
//            revertToggleOff()
//            errorMessage = "Session expired. Please log in again."
//            return
//        }
//        sendOTP()
//    }
//
//    // MARK: - Step 1: Send OTP
//    // Called by: toggle ON, TwoFAFullSheet.onAppear, Update Email button (twoFAKey == 0)
//
//    func sendOTP() {
//        guard !isLoading else { return }
//        isLoading = true
//        clearMessages()
//
//        let email = UserDefaults.standard.string(forKey: "Bemail") ?? ""
//        debugPrint("📤 [VM] sendOTP merchantId=\(merchantId) email=\(email)")
//
//        service.sendGmailOTP(merchantId: merchantId, email: email) { [weak self] result in
//            guard let self else { return }
//            self.isLoading = false
//            switch result {
//            case .success:
//                self.startResendCountdown()
//                self.showGmailOTPSheet = true
//            case .failure(let err):
//                self.revertToggleOff()
//                self.errorMessage = "Failed to send OTP: \(err.localizedDescription)"
//            }
//        }
//    }
//
//    // MARK: - Step 2: Verify Email OTP → get google_auth_key → navigate to QR screen
//    // Called by GmailOTPSheet (twoFAKey == 0 path).
//    // On success: sets showGmailOTPSheet = false (sheet dismisses itself via onChange),
//    // then after 0.65s sets showQRSetupScreen = true so NavigationStack pushes QR screen.
//
//    func verifyEmailOTPAndGetKey(emailOTP: String) {
//        guard !emailOTP.isEmpty else {
//            errorMessage = "Please enter the email OTP"
//            return
//        }
//        isLoading = true
//        clearMessages()
//        debugPrint("🔐 [VM] GetTwoFactorykey (key==0) emailOTP=\(emailOTP)")
//
//        service.getTwoFactoryKey(
//            merchantId:     merchantId,
//            email:          UserDefaults.standard.string(forKey: "Bemail") ?? "",
//            emailOTP:       emailOTP,
//            googleAuthCode: ""
//        ) { [weak self] (result: Swift.Result<GetTwoFactoryKeyResponse, Error>) in
//            guard let self else { return }
//            self.isLoading = false
//
//            switch result {
//            case .success(let response):
//                guard let key = response.googleAuthKey, !key.isEmpty else {
//                    self.errorMessage = "No Google Auth key returned. Please try again."
//                    return
//                }
//                debugPrint("✅ [VM] verifyEmailOTPAndGetKey google_auth_key=\(key)")
//                self.stopResendCountdown()
//                self.googleAuthKey    = key
//                // Signal the sheet to dismiss (GmailOTPSheet watches dismissOTPSheet)
//                self.dismissOTPSheet  = true
//                // Wait for sheet dismiss animation, then push QR screen
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
//                    self.showQRSetupScreen = true
//                }
//
//            case .failure(let err):
//                debugPrint("❌ [VM] verifyEmailOTPAndGetKey failed: \(err.localizedDescription)")
//                self.errorMessage = err.localizedDescription
//            }
//        }
//    }
//
//    // MARK: - Step 2 (alt): Verify Email OTP → get google_auth_key → navigate to QR screen
//    // Called by TwoFAFullSheet (twoFAKey == 1 path).
//    // googleAuthCode param is kept to avoid changing call sites but intentionally unused —
//    // the actual 6-digit GA code is entered on the QR screen (Step 3) and sent to
//    // SaveTwoFactorSettings, not to GetTwoFactorykey.
//    //
//    // On success: sets dismissOTPSheet = true (TwoFAFullSheet watches this to self-dismiss),
//    // then after 0.65s sets showQRSetupScreen = true so NavigationStack pushes QR screen.
//
//    // MARK: - Step 2 (alt): Verify Email OTP → get google_auth_key → navigate to QR screen
//
//    func verifyBothAndEnable(emailOTP: String, googleAuthCode: String) {
//        guard !emailOTP.isEmpty else {
//            errorMessage = "Please enter the email OTP"
//            return
//        }
//        isLoading = true
//        clearMessages()
//        debugPrint("🔐 [VM] GetTwoFactorykey (key==1) emailOTP=\(emailOTP)")
//
//        service.getTwoFactoryKey(
//            merchantId:     merchantId,
//            email:          UserDefaults.standard.string(forKey: "Bemail") ?? "",
//            emailOTP:       emailOTP,
//            googleAuthCode: ""
//        ) { [weak self] (result: Swift.Result<GetTwoFactoryKeyResponse, Error>) in
//            guard let self else { return }
//            self.isLoading = false
//
//            switch result {
//            case .success(let response):
//                guard let key = response.googleAuthKey, !key.isEmpty else {
//                    self.errorMessage = "No Google Auth key returned. Please try again."
//                    return
//                }
//                debugPrint("✅ [VM] verifyBothAndEnable google_auth_key=\(key)")
//                self.stopResendCountdown()
//                self.googleAuthKey         = key
//                self.pendingGoogleAuthCode = googleAuthCode
//
//                // Step 1: signal TwoFAFullSheet to call dismiss()
//                self.dismissOTPSheet = true
//
//                // Step 2: wait for sheet to fully animate off-screen, THEN push QR screen.
//                // 0.65s was too tight on slower devices — bumped to 0.8s.
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
//                    guard let self else { return }
//                    // Guard: only navigate if sheet is actually gone
//                    guard !self.showGmailOTPSheet else {
//                        // Sheet still showing — try again in 0.3s
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
//                            self?.showQRSetupScreen = true
//                        }
//                        return
//                    }
//                    self.showQRSetupScreen = true
//                }
//
//            case .failure(let err):
//                debugPrint("❌ [VM] verifyBothAndEnable failed: \(err.localizedDescription)")
//                self.errorMessage = err.localizedDescription
//            }
//        }
//    }
//
//    // MARK: - Step 3: Save Two Factor Settings
//    // Called by Qrauthsetupview after user scans QR and enters 6-digit code.
//    // Payload: { merchant_id, google_auth_enabled: "1", google_factor_otp: "<code>" }
//
//    func saveTwoFactorSettings(googleFactorOTP: String, onSuccess: (() -> Void)? = nil) {
//        guard !googleFactorOTP.isEmpty else {
//            errorMessage = "Please enter the 6-digit code from your authenticator app"
//            return
//        }
//        isLoading = true
//        clearMessages()
//        debugPrint("💾 [VM] SaveTwoFactorSettings otp=\(googleFactorOTP)")
//
//        service.saveTwoFactorSettings(
//            merchantId:        merchantId,
//            googleAuthEnabled: "1",
//            googleFactorOTP:   googleFactorOTP
//        ) { [weak self] result in
//            guard let self else { return }
//            self.isLoading = false
//
//            switch result {
//            case .success:
//                debugPrint("✅ [VM] SaveTwoFactorSettings — 2FA fully enabled")
//                self.successMessage       = "Two-Factor Authentication enabled successfully!"
//                self.showQRSetupScreen    = false
//                self.googleAuthKey        = ""
//                self.pendingGoogleAuthCode = ""
//                self.isSyncingFromAPI     = true
//                self.rawGoogleAuthEnabled = 1
//                self.rawTwoFactorEnabled  = 1
//                self.twoFAState           = .fullyEnabled
//                self.googleAuthToggle     = true
//                self.isSyncingFromAPI     = false
//                onSuccess?()
//
//            case .failure(let err):
//                debugPrint("❌ [VM] SaveTwoFactorSettings failed: \(err.localizedDescription)")
//                self.errorMessage = err.localizedDescription
//            }
//        }
//    }
//
//    // MARK: - Toggle OFF → DisableGoogleAuth
//
//    private func onToggleTurnedOff() {
//        isLoading = true
//        clearMessages()
//
//        service.disableGoogleAuth(merchantId: merchantId) { [weak self] result in
//            guard let self else { return }
//            self.isLoading = false
//            switch result {
//            case .success:
//                self.successMessage       = "Two-Factor Authentication disabled."
//                self.isSyncingFromAPI     = true
//                self.rawGoogleAuthEnabled = 0
//                self.rawTwoFactorEnabled  = 0
//                self.twoFAState           = .neverSetup
//                self.googleAuthToggle     = false
//                self.isSyncingFromAPI     = false
//            case .failure(let err):
//                self.isSyncingFromAPI = true
//                self.googleAuthToggle = true
//                self.isSyncingFromAPI = false
//                self.errorMessage = "Failed to disable 2FA: \(err.localizedDescription)"
//            }
//        }
//    }
//
//    // MARK: - Sheet Dismissed Without Verify
//
//    func onOTPSheetDismissedWithoutVerify() {
//        debugPrint("⚠️ [VM] Sheet dismissed without verify — reverting")
//        stopResendCountdown()
//        revertToggleOff()
//    }
//
//    // MARK: - Resend OTP
//
//    func resendOTP() {
//        isLoading = true
//        clearMessages()
//        let email = UserDefaults.standard.string(forKey: "Bemail") ?? ""
//        service.sendGmailOTP(merchantId: merchantId, email: email) { [weak self] result in
//            guard let self else { return }
//            self.isLoading = false
//            switch result {
//            case .success:
//                self.startResendCountdown()
//            case .failure(let err):
//                self.errorMessage = "Failed to resend OTP: \(err.localizedDescription)"
//            }
//        }
//    }
//
//    // MARK: - Helpers
//
//    func buildOTPAuthURL(issuer: String = "PayBito", accountName: String = "") -> String {
//        guard !googleAuthKey.isEmpty else {
//            debugPrint("⚠️ [VM] buildOTPAuthURL called with empty googleAuthKey")
//            return ""
//        }
//        let account = accountName.isEmpty ? "user" : accountName
//        return "otpauth://totp/\(issuer):\(account)?secret=\(googleAuthKey)&issuer=\(issuer)"
//    }
//
//    private func revertToggleOff() {
//        isSyncingFromAPI = true
//        googleAuthToggle = false
//        isSyncingFromAPI = false
//    }
//
//    // MARK: - Countdown Timer
//
//    func startResendCountdown(from seconds: Int = 112) {
//        stopResendCountdown()
//        resendCountdown = seconds
//        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
//            guard let self else { timer.invalidate(); return }
//            Task { @MainActor [weak self] in
//                guard let self else { return }
//                if self.resendCountdown > 0 { self.resendCountdown -= 1 }
//                else { timer.invalidate(); self.countdownTimer = nil }
//            }
//        }
//    }
//
//    func stopResendCountdown() {
//        countdownTimer?.invalidate()
//        countdownTimer  = nil
//        resendCountdown = 0
//    }
//
//    func clearMessages() { errorMessage = ""; successMessage = "" }
//    func clearError()    { errorMessage = "" }
//    func clearSuccess()  { successMessage = "" }
//}
//
//
//
//
//
//
//
//
