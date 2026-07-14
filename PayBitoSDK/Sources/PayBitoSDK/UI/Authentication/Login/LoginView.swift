import SwiftUI
import SwiftyJSON
import SDWebImageSwiftUI

// MARK: - LoginView

public struct LoginView: View {
    public init() {}
    @Environment(\.dismiss) private var dismiss
    
    @State private var brokerName = ""
    @State private var brokerLogo = ""

    @State private var isLoggedIn        = false
    @State private var email             = ""
    @State private var password          = ""
    @State private var isPasswordVisible = false
    @State private var isLoading         = false
    @State private var alertMessage      = ""
    @State private var showAlert         = false
    @State private var showOTP           = false
    @State private var showRegister      = false
    @State private var showForgotPwd     = false
    @State private var showCaptcha       = false
    @State private var captchaToken      = ""
    // ── Parsed from checkMGAStatus response ─────────────────────────────
    // API returns "google_auth_enabled": 1  or  "google_auth_enabled": 0
    @State private var googleAuthEnabled: Int = 0

    enum Field { case email, password }
    @FocusState private var focusedField: Field?

    var onLoginSuccess: (() -> Void)?

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    backButton
                    headerSection
                    formSection
                    actionSection
                    footerLinks
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)
                .padding(.bottom, 40)
            }
            .onTapGesture { focusedField = nil }

            if isLoading { loadingOverlay }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            brokerName = UserDefaults.standard.string(forKey: "companyName") ?? "Payments"

            brokerLogo = UserDefaults.standard.string(forKey: "loader_icon") ?? ""

            if LoginService.isSessionActive {
                isLoggedIn = true
            }
        }
        // ── OTP sheet — receives the google_auth_enabled flag ────────────
        .sheet(isPresented: $showOTP) {
            LoginOtpView(
                email:             email,
                password:          password,
                googleAuthEnabled: googleAuthEnabled,   // ← passed here
                onSuccess: {
                    showOTP = false

                    NotificationCenter.default.post(
                        name: NSNotification.Name("userDidLogin"),
                        object: nil
                    )
                },
                onError: { msg in
                    alertMessage = msg
                    showAlert    = true
                }
            )
        }
        .sheet(isPresented: $showRegister)  { RegisterView() }
        .sheet(isPresented: $showForgotPwd) { ForgotPasswordEmailView() }
        .sheet(isPresented: $showCaptcha) {
            LoginCaptchaView(
                onVerified: { token in
                    captchaToken = token
                    showCaptcha  = false
                    isLoading    = true
                    proceedAfterCaptcha()
                },
                onCancel: {
                    showCaptcha = false
                    isLoading   = false
                }
            )
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
//        .fullScreenCover(isPresented: $isLoggedIn) {
//            BillBitcoinsContainerView(onLogout: {
//                LoginService.clearSession()
//                isLoggedIn = false
//            })
//        }
    }

    // MARK: - Subviews

    private var backButton: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundStyle(Color.white)
                .font(.headline)
            }
            Spacer()
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {

            if !brokerLogo.isEmpty {

                WebImage(url: URL(string: brokerLogo))
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.25))
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )

            } else {

                Image(systemName: "creditcard.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(Color.accentColor)
            }

            Text(brokerName.isEmpty ? "Payments" : brokerName)
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)

            Text("Sign in to your merchant account")
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }

    private var formSection: some View {
        VStack(spacing: 14) {
            // Email
            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address*").font(.caption).foregroundStyle(Color.gray)
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.white)
                    TextField(
                        text: $email,
                        prompt: Text("Enter your email")
                            .foregroundStyle(.gray)
                    ) {
                        Text("")
                    }
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .email)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .password }
                    .foregroundStyle(.black)
                    .padding()
                }
                .frame(height: 50)
                .contentShape(Rectangle())
                .onTapGesture { focusedField = .email }
            }
            // Password
            VStack(alignment: .leading, spacing: 6) {
                Text("Password*").font(.caption).foregroundStyle(Color.gray)
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(Color.white)
                    HStack {
                        Group {
                            if isPasswordVisible {
                                TextField(
                                    text: $password,
                                    prompt: Text("Enter your password")
                                        .foregroundStyle(.gray)
                                ) {
                                    Text("")
                                }
                            } else {
                                SecureField(
                                    text: $password,
                                    prompt: Text("Enter your password")
                                        .foregroundStyle(.gray)
                                ) {
                                    Text("")
                                }
                            }
                        }
                        .focused($focusedField, equals: .password)
                        .submitLabel(.done)
                        .onSubmit { focusedField = nil; handleSignIn() }
                        .foregroundStyle(Color.black)

                        Button {
                            isPasswordVisible.toggle()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                focusedField = .password
                            }
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundStyle(Color.gray)
                        }
                    }
                    .padding()
                }
                .frame(height: 50)
                .contentShape(Rectangle())
                .onTapGesture { focusedField = .password }
            }
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            Button {
                focusedField = nil
                handleSignIn()
            } label: {
                ZStack {
                    if isLoading { ProgressView().tint(.white) }
                    else { Text("Sign In").font(.headline).foregroundStyle(Color.white) }
                }
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.62, green: 0.36, blue: 0.96),
                                 Color(red: 0.36, green: 0.49, blue: 0.96)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1.0)
            }
            .disabled(isLoading || email.isEmpty || password.isEmpty)

            Button("Forgot Password?") { showForgotPwd = true }
                .font(.subheadline).foregroundStyle(Color.blue)
        }
    }

    private var footerLinks: some View {
        HStack {
            Text("Don't have an account?").font(.subheadline).foregroundStyle(Color.gray)
            Button("Sign Up") { showRegister = true }
                .font(.subheadline.bold()).foregroundStyle(Color.blue)
        }
        .padding(.bottom, 32)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().scaleEffect(1.4).tint(.white)
                Text("Signing in…").font(.subheadline).foregroundStyle(Color.white)
            }
            .padding(24)
            .background(Color.white.opacity(0.10))
            .cornerRadius(16)
        }
    }

    // MARK: - Login flow

    private func handleSignIn() {
        guard !email.isEmpty, !password.isEmpty else { return }
        focusedField = nil
        captchaToken = ""
        showCaptcha  = true
    }

    private func proceedAfterCaptcha() {
        LoginService.shared.checkMgaStatus(
            email:              email,
            password:           password,
            gRecaptchaResponse: captchaToken
        ) { success, json, errMsg in
            DispatchQueue.main.async {
                let errorCode   = json["errorCode"].stringValue
                let isHardBlock = !success && (
                    errorCode == "AUTH_ERROR" ||
                    errorCode == "INVALID_CREDENTIALS"
                )
                if isHardBlock {
                    self.isLoading    = false
                    self.alertMessage = errMsg
                    self.showAlert    = true
                } else {
                    // ── KEY FIX: field name is "google_auth_enabled" in the API ──
                    // Handles both Int (1/0) and String ("1"/"0") server responses
                    let raw = json["google_auth_enabled"]
                    self.googleAuthEnabled = raw.intValue != 0
                        ? raw.intValue
                        : (raw.stringValue == "1" ? 1 : 0)

                    #if DEBUG
                    print("▶ google_auth_enabled = \(self.googleAuthEnabled)")
                    #endif

                    self.sendOTP()
                }
            }
        }
    }

    private func sendOTP() {
        LoginService.shared.sendEmailOTP(email: email, password: password) { success, _, errMsg in
            DispatchQueue.main.async {
                self.isLoading = false
                if success {
                    self.showOTP = true
                } else {
                    self.alertMessage = errMsg.isEmpty ? "Failed to send OTP." : errMsg
                    self.showAlert    = true
                }
            }
        }
    }
}

// MARK: - OTP Sheet

private enum OTPField: Hashable { case otp, googleAuth }

struct LoginOtpView: View {

    let email:             String
    let password:          String
    /// 1 = show Google Authenticator field, 0 = hide it
    /// Driven by "google_auth_enabled" from checkMGAStatus API response
    let googleAuthEnabled: Int
    var onSuccess:         () -> Void
    var onError:           (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var otpCode   = ""
    @State private var googleOTP = ""
    @State private var isLoading = false
    @State private var alertMsg  = ""
    @State private var showAlert = false
    @FocusState private var focusedField: OTPField?

    // 7-digit numeric email OTP
    private var isEmailOTPValid: Bool {
        otpCode.count == 7 && otpCode.allSatisfy(\.isNumber)
    }

    // 6-digit numeric Google OTP (only checked when enabled)
    private var isGoogleOTPValid: Bool {
        googleOTP.count == 6 && googleOTP.allSatisfy(\.isNumber)
    }

    // Submit gate: both fields must pass when google auth is ON
    private var canSubmit: Bool {
        guard isEmailOTPValid else { return false }
        return googleAuthEnabled == 1 ? isGoogleOTPValid : true
    }

//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.black.ignoresSafeArea()
//
//                ScrollView {
//                    VStack(spacing: 24) {
//
//                        // Icon
//                        Image(systemName: "envelope.badge.shield.half.filled.fill")
//                            .resizable().scaledToFit()
//                            .frame(width: 64, height: 64)
//                            .foregroundStyle(Color.accentColor)
//                            .padding(.top, 32)
//
//                        Text("Security Authentication")
//                            .font(.title2).bold().foregroundStyle(Color.white)
//
//                        Text("Enter the verification code sent to\n**\(maskedEmail)**")
//                            .font(.subheadline).foregroundStyle(Color.gray)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//
//                        // ── Email OTP ────────────────────────────────────
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text("*One-time password sent to your email.")
//                                .font(.caption).foregroundStyle(Color.gray)
//                            Text("Email OTP")
//                                .font(.caption).bold().foregroundStyle(Color.gray)
//
//                            TextField("Enter 7-digit OTP", text: $otpCode)
//                                .keyboardType(.numberPad)
//                                .focused($focusedField, equals: .otp)
//                                .onChange(of: otpCode) { val in
//                                    // Cap at 7 digits
//                                    if val.count > 7 { otpCode = String(val.prefix(7)) }
//                                    // Auto-submit only when Google Auth is NOT required
//                                    if val.count == 7 && googleAuthEnabled != 1 {
//                                        handleVerify()
//                                    }
//                                }
//                                .foregroundStyle(Color.primary)
//                                .padding(14)
//                                .background(Color(.secondarySystemBackground))
//                                .cornerRadius(10)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
//                                )
//                        }
//                        .padding(.horizontal)
//
//                        // ── Google Authenticator ─────────────────────────
//                        // Shown ONLY when googleAuthEnabled == 1
//                        if googleAuthEnabled == 1 {
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("*Input 6 digit Code from your Google Authenticator app.")
//                                    .font(.caption).foregroundStyle(Color.gray)
//                                Text("Google Authenticator Code")
//                                    .font(.caption).bold().foregroundStyle(Color.gray)
//
//                                TextField("Enter 6-digit code", text: $googleOTP)
//                                    .keyboardType(.numberPad)
//                                    .focused($focusedField, equals: .googleAuth)
//                                    .onChange(of: googleOTP) { val in
//                                        // Cap at 6 digits
//                                        if val.count > 6 { googleOTP = String(val.prefix(6)) }
//                                    }
//                                    .foregroundStyle(Color.primary)
//                                    .padding(14)
//                                    .background(Color(.secondarySystemBackground))
//                                    .cornerRadius(10)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 10)
//                                            .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
//                                    )
//                            }
//                            .padding(.horizontal)
//                            .transition(.move(edge: .bottom).combined(with: .opacity))
//                        }
//
//                        // ── Confirm button ───────────────────────────────
//                        Button { handleVerify() } label: {
//                            ZStack {
//                                if isLoading { ProgressView().tint(.white) }
//                                else {
//                                    Text("Confirm")
//                                        .font(.headline).foregroundStyle(Color.white)
//                                }
//                            }
//                            .frame(maxWidth: .infinity).frame(height: 52)
//                            .background(
//                                LinearGradient(
//                                    colors: [Color(red: 0.62, green: 0.36, blue: 0.96),
//                                             Color(red: 0.36, green: 0.49, blue: 0.96)],
//                                    startPoint: .leading, endPoint: .trailing
//                                )
//                            )
//                            .cornerRadius(12)
//                            .opacity(canSubmit ? 1.0 : 0.5)
//                        }
//                        .disabled(isLoading || !canSubmit)
//                        .padding(.horizontal)
//
//                        Button("Resend Code") { resendOTP() }
//                            .font(.subheadline).foregroundStyle(Color.blue)
//
//                        Spacer().frame(height: 40)
//                    }
//                }
//                .animation(.easeInOut(duration: 0.25), value: googleAuthEnabled)
//                .onTapGesture { focusedField = nil }
//            }
//            .ignoresSafeArea(.keyboard, edges: .bottom)
//            .navigationTitle("Verify Identity")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }
//                        .foregroundStyle(Color.white)
//                }
//            }
//            .alert("Error", isPresented: $showAlert) {
//                Button("OK", role: .cancel) {}
//            } message: { Text(alertMsg) }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                focusedField = .otp
//            }
//        }
//    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 24) {

                            // Icon
                            Image(systemName: "envelope.badge.shield.half.filled.fill")
                                .resizable().scaledToFit()
                                .frame(width: 64, height: 64)
                                .foregroundStyle(Color.accentColor)
                                .padding(.top, 32)

                            Text("Security Authentication")
                                .font(.title2).bold().foregroundStyle(Color.white)

                            Text("Enter the verification code sent to\n**\(maskedEmail)**")
                                .font(.subheadline).foregroundStyle(Color.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            // ── Email OTP ────────────────────────────────────
                            VStack(alignment: .leading, spacing: 6) {
                                Text("*One-time password sent to your email.")
                                    .font(.caption).foregroundStyle(Color.gray)
                                Text("Email OTP")
                                    .font(.caption).bold().foregroundStyle(Color.gray)

                                TextField("Enter 7-digit OTP", text: $otpCode)
                                    .keyboardType(.numberPad)
                                    .focused($focusedField, equals: .otp)
                                    .onChange(of: otpCode) { val in
                                        if val.count > 7 { otpCode = String(val.prefix(7)) }
                                        if val.count == 7 && googleAuthEnabled != 1 {
                                            handleVerify()
                                        }
                                    }
                                    .foregroundStyle(Color.primary)
                                    .padding(14)
                                    .background(Color(.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                                    )
                            }
                            .padding(.horizontal)
                            .id(OTPField.otp)

                            // ── Google Authenticator ─────────────────────────
                            if googleAuthEnabled == 1 {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("*Input 6 digit Code from your Google Authenticator app.")
                                        .font(.caption).foregroundStyle(Color.gray)
                                    Text("Google Authenticator Code")
                                        .font(.caption).bold().foregroundStyle(Color.gray)

                                    TextField("Enter 6-digit code", text: $googleOTP)
                                        .keyboardType(.numberPad)
                                        .focused($focusedField, equals: .googleAuth)
                                        .onChange(of: googleOTP) { val in
                                            if val.count > 6 { googleOTP = String(val.prefix(6)) }
                                        }
                                        .foregroundStyle(Color.primary)
                                        .padding(14)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5)
                                        )
                                }
                                .padding(.horizontal)
                                .id(OTPField.googleAuth)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }

                            // ── Confirm button ───────────────────────────────
                            Button { handleVerify() } label: {
                                ZStack {
                                    if isLoading { ProgressView().tint(.white) }
                                    else {
                                        Text("Confirm")
                                            .font(.headline).foregroundStyle(Color.white)
                                    }
                                }
                                .frame(maxWidth: .infinity).frame(height: 52)
                                .background(
                                    LinearGradient(
                                        colors: [Color(red: 0.62, green: 0.36, blue: 0.96),
                                                 Color(red: 0.36, green: 0.49, blue: 0.96)],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .opacity(canSubmit ? 1.0 : 0.5)
                            }
                            .disabled(isLoading || !canSubmit)
                            .padding(.horizontal)
                            .id("confirmButton")

                            Button("Resend Code") { resendOTP() }
                                .font(.subheadline).foregroundStyle(Color.blue)

                            // Extra bottom spacer so the last fields/button can
                            // scroll clear of the keyboard
                            Spacer().frame(height: 280)
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: googleAuthEnabled)
                    .onTapGesture { focusedField = nil }
                    .onChange(of: focusedField) { newValue in
                        guard let newValue else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo(newValue, anchor: .center)
                            }
                        }
                    }
                    .onChange(of: googleAuthEnabled) { newValue in
                        guard newValue == 1 else { return }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            withAnimation {
                                proxy.scrollTo("confirmButton", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Verify Identity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.white)
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: { Text(alertMsg) }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .otp
            }
        }
    }
     

    // MARK: - Helpers

    private var maskedEmail: String {
        guard let at = email.range(of: "@") else { return email }
        let local  = String(email[..<at.lowerBound])
        let domain = String(email[at.lowerBound...])
        guard local.count > 3 else { return email }
        return String(local.prefix(3))
            + String(repeating: "*", count: local.count - 3)
            + domain
    }

    private func handleVerify() {
        guard canSubmit, !isLoading else { return }
        isLoading = true

        // Postman-confirmed payload:
        //   email, password, email_otp, google_Factor_Otp (only when enabled)
        LoginService.shared.loginDetails(
            email:         email,
            password:      password,
            emailOTP:      otpCode,
            googleAuthOTP: googleAuthEnabled == 1 ? googleOTP : ""
        ) { success, json, errMsg in
            DispatchQueue.main.async {
                if success {
                    let selectedBrokerId = UserDefaults.standard.string(forKey: "brokerId")
                        ?? "PAYB18022021121103"
                    LoginService.shared.persistSession(from: json, selectedBrokerId: selectedBrokerId)
                    self.postLoginCalls(json: json)
                } else {
                    self.isLoading = false
                    self.alertMsg  = errMsg.isEmpty
                        ? "Verification failed. Please check your code(s)."
                        : errMsg
                    self.showAlert = true
                }
            }
        }
    }

    private func postLoginCalls(json: JSON) {
//        let merchantId = json["merchant_id"].intValue
//        let uuid       = json["uuid"].stringValue
//        let brokerId   = json["brokerId"].stringValue.isEmpty
//            ? (UserDefaults.standard.string(forKey: "brokerId") ?? "PAYB18022021121103")
//            : json["brokerId"].stringValue
        
        let merchantId = json["merchant_id"].intValue
        let uuid       = json["uuid"].stringValue
        
        // ✅ Broker validation
        let selectedBrokerId = UserDefaults.standard.string(forKey: "brokerId")
            ?? "PAYB18022021121103"
        let returnedBrokerId = json["brokerId"].stringValue
        
        if !returnedBrokerId.isEmpty && returnedBrokerId != selectedBrokerId {
            self.isLoading = false
            self.alertMsg  = "These credentials don't belong to the selected broker. Please go back and select the correct broker."
            self.showAlert = true
            return   // ← stop here, don't persist session
        }
        
        // Only persist AFTER broker validation passes
        LoginService.shared.persistSession(from: json, selectedBrokerId: selectedBrokerId)
        
        let brokerId = returnedBrokerId.isEmpty ? selectedBrokerId : returnedBrokerId
        let group = DispatchGroup()

        group.enter()
        LoginService.shared.fetchMerchantStatus(merchantId: merchantId) { success, statusJson, _ in
            if success {
                let flag = statusJson["transaction_status_flag"].intValue
                UserDefaults.standard.set(
                    flag == 0 ? "get-started" : "dashboard", forKey: "BlandingPage")
                UserDefaults.standard.set(statusJson["email_confirmed"].stringValue,
                                          forKey: "Bemail_confirmed")
                UserDefaults.standard.set(statusJson["basic_verification_submitted"].stringValue,
                                          forKey: "Bbasic_verification_submitted")
                UserDefaults.standard.set(statusJson["crypto_address_added"].stringValue,
                                          forKey: "Bcrypto_address_added")
                UserDefaults.standard.set(statusJson["account_status_id"].stringValue,
                                          forKey: "Baccount_status_id")
            }
            group.leave()
        }

        group.enter()
        LoginService.shared.getBrokerInfo(brokerId: brokerId) { _, _, _ in group.leave() }

        if !uuid.isEmpty {
            group.enter()
            LoginService.shared.getProfilePicture(uuid: uuid) { _, picJson, _ in
                let url = picJson["profile_image"].stringValue
                if !url.isEmpty {
                    UserDefaults.standard.set(url, forKey: "BprofileImageURL")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.isLoading = false
            self.onSuccess()
        }
    }

    private func resendOTP() {
        LoginService.shared.sendEmailOTP(email: email, password: password) { success, _, errMsg in
            DispatchQueue.main.async {
                if !success {
                    self.alertMsg  = errMsg.isEmpty ? "Failed to resend OTP." : errMsg
                    self.showAlert = true
                }
            }
        }
    }
}

// MARK: - Previews
#Preview("Login") { LoginView() }

#Preview("OTP — Google Auth OFF (googleAuthEnabled = 0)") {
    LoginOtpView(
        email: "rajit+140@hashcashconsultants.com",
        password: "secret",
        googleAuthEnabled: 0,
        onSuccess: {},
        onError: { _ in }
    )
}

#Preview("OTP — Google Auth ON (googleAuthEnabled = 1)") {
    LoginOtpView(
        email: "rajit+140@hashcashconsultants.com",
        password: "secret",
        googleAuthEnabled: 1,
        onSuccess: {},
        onError: { _ in }
    )
}























//
////  LoginView.swift
//
//
////  LoginView.swift
//
//import SwiftUI
//import SwiftyJSON
//
//// MARK: - LoginView
//
//struct LoginView: View {
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var isLoggedIn        = false
//    @State private var email             = ""
//    @State private var password          = ""
//    @State private var isPasswordVisible = false
//    @State private var isLoading         = false
//    @State private var alertMessage      = ""
//    @State private var showAlert         = false
//    @State private var showOTP           = false
//    @State private var showRegister      = false
//    @State private var showForgotPwd     = false
//    @State private var showCaptcha       = false
//    @State private var captchaToken      = ""   // ← stores JWT from /solve
//
//    enum Field { case email, password }
//    @FocusState private var focusedField: Field?
//
//    var onLoginSuccess: (() -> Void)?
//
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//
//            ScrollView {
//                VStack(spacing: 28) {
//                    backButton
//                    headerSection
//                    formSection
//                    actionSection
//                    footerLinks
//                }
//                .padding(.horizontal, 24)
//                .padding(.top, 48)
//                .padding(.bottom, 40)
//            }
//            .onTapGesture { focusedField = nil }
//
//            if isLoading { loadingOverlay }
//        }
//        .ignoresSafeArea(.keyboard, edges: .bottom)
//        .onAppear {
//            if LoginService.isSessionActive {
//                isLoggedIn = true
//            }
//        }
//        // OTP sheet
//        .sheet(isPresented: $showOTP) {
//            LoginOtpView(
//                email:     email,
//                password:  password,
//                onSuccess: {
//                    showOTP    = false
//                    isLoggedIn = true
//                    onLoginSuccess?()
//                },
//                onError: { msg in
//                    alertMessage = msg
//                    showAlert    = true
//                }
//            )
//        }
//        .sheet(isPresented: $showRegister)  { RegisterView() }
//        .sheet(isPresented: $showForgotPwd) { ForgotPasswordEmailView() }
//        // ── Captcha sheet ─────────────────────────────────────────────
//        .sheet(isPresented: $showCaptcha) {
//            LoginCaptchaView(
//                onVerified: { token in      // ← single JWT token
//                    captchaToken = token
//                    showCaptcha  = false
//                    isLoading    = true
//                    proceedAfterCaptcha()
//                },
//                onCancel: {
//                    showCaptcha = false
//                    isLoading   = false
//                }
//            )
//        }
//        .alert("Error", isPresented: $showAlert) {
//            Button("OK", role: .cancel) {}
//        } message: {
//            Text(alertMessage)
//        }
//      
//       
//        .fullScreenCover(isPresented: $isLoggedIn) {
//            BillBitcoinsContainerView(onLogout: {
//                LoginService.clearSession()
//                isLoggedIn = false
//            })
//        }
//    }
//
//    // MARK: - Header
//    private var backButton: some View {
//        HStack {
//            Button {
//                dismiss()
//            } label: {
//                HStack(spacing: 6) {
//                    Image(systemName: "chevron.left")
//                    Text("Back")
//                }
//                .foregroundColor(.white)
//                .font(.headline)
//            }
//
//            Spacer()
//        }
//    }
//
//    private var headerSection: some View {
//        VStack(spacing: 13) {
//            Image(systemName: "creditcard.fill")
//                .resizable().scaledToFit()
//                .frame(width: 64, height: 64)
//                .foregroundColor(.accentColor)
//            Text("Payments")
//                .font(.largeTitle).foregroundColor(.white).bold()
//            Text("Sign in to your merchant account")
//                .font(.subheadline).foregroundColor(.gray)
//        }
//    }
//
//    // MARK: - Form
//
//    private var formSection: some View {
//        VStack(spacing: 14) {
//
//            // Email
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Email Address*").font(.caption).foregroundColor(.gray)
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).fill(Color.white)
//                    TextField("Enter your email", text: $email)
//                        .keyboardType(.emailAddress)
//                        .textInputAutocapitalization(.never)
//                        .autocorrectionDisabled()
//                        .focused($focusedField, equals: .email)
//                        .submitLabel(.next)
//                        .onSubmit { focusedField = .password }
//                        .foregroundColor(.black)
//                        .padding()
//                }
//                .frame(height: 50)
//                .contentShape(Rectangle())
//                .onTapGesture { focusedField = .email }
//            }
//
//            // Password
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Password*").font(.caption).foregroundColor(.gray)
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).fill(Color.white)
//                    HStack {
//                        Group {
//                            if isPasswordVisible {
//                                TextField("Enter your password", text: $password)
//                            } else {
//                                SecureField("Enter your password", text: $password)
//                            }
//                        }
//                        .focused($focusedField, equals: .password)
//                        .submitLabel(.done)
//                        .onSubmit { focusedField = nil; handleSignIn() }
//                        .foregroundColor(.black)
//
//                        Button {
//                            isPasswordVisible.toggle()
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
//                                focusedField = .password
//                            }
//                        } label: {
//                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .padding()
//                }
//                .frame(height: 50)
//                .contentShape(Rectangle())
//                .onTapGesture { focusedField = .password }
//            }
//        }
//    }
//
//    // MARK: - Actions
//
//    private var actionSection: some View {
//        VStack(spacing: 12) {
//            Button {
//                focusedField = nil
//                handleSignIn()
//            } label: {
//                ZStack {
//                    if isLoading { ProgressView().tint(.white) }
//                    else { Text("Sign In").font(.headline).foregroundColor(.white) }
//                }
//                .frame(maxWidth: .infinity).frame(height: 52)
//                .background(
//                    LinearGradient(
//                        colors: [Color(red: 0.62, green: 0.36, blue: 0.96),
//                                 Color(red: 0.36, green: 0.49, blue: 0.96)],
//                        startPoint: .leading, endPoint: .trailing
//                    )
//                )
//                .cornerRadius(12)
//                .opacity(email.isEmpty || password.isEmpty ? 0.5 : 1.0)
//            }
//            .disabled(isLoading || email.isEmpty || password.isEmpty)
//
//            Button("Forgot Password?") { showForgotPwd = true }
//                .font(.subheadline).foregroundColor(.blue)
//        }
//    }
//
//    // MARK: - Footer
//
//    private var footerLinks: some View {
//        HStack {
//            Text("Don't have an account?").font(.subheadline).foregroundColor(.gray)
//            Button("Sign Up") { showRegister = true }
//                .font(.subheadline.bold()).foregroundColor(.blue)
//        }
//        .padding(.bottom, 32)
//    }
//
//    // MARK: - Loading overlay
//
//    private var loadingOverlay: some View {
//        ZStack {
//            Color.black.opacity(0.4).ignoresSafeArea()
//            VStack(spacing: 12) {
//                ProgressView().scaleEffect(1.4).tint(.white)
//                Text("Signing in…").font(.subheadline).foregroundColor(.white)
//            }
//            .padding(24)
//            .background(Color.white.opacity(0.10))
//            .cornerRadius(16)
//        }
//    }
//
//    // MARK: - Login flow
//
//    private func handleSignIn() {
//        guard !email.isEmpty, !password.isEmpty else { return }
//        focusedField = nil
//        captchaToken = ""
//        showCaptcha  = true     // show captcha first
//    }
//
//    private func proceedAfterCaptcha() {
//        // Pass JWT token as gRecaptchaResponse
//        LoginService.shared.checkMgaStatus(
//            email:              email,
//            password:           password,
//            gRecaptchaResponse: captchaToken    // ← JWT from /solve
//        ) { success, json, errMsg in
//            DispatchQueue.main.async {
//                let errorCode   = json["errorCode"].stringValue
//                let isHardBlock = !success && (
//                    errorCode == "AUTH_ERROR" ||
//                    errorCode == "INVALID_CREDENTIALS"
//                )
//                if isHardBlock {
//                    self.isLoading    = false
//                    self.alertMessage = errMsg
//                    self.showAlert    = true
//                } else {
//                    self.sendOTP()
//                }
//            }
//        }
//    }
//
//    private func sendOTP() {
//        LoginService.shared.sendEmailOTP(email: email, password: password) { success, _, errMsg in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                if success {
//                    self.showOTP = true
//                } else {
//                    self.alertMessage = errMsg.isEmpty ? "Failed to send OTP." : errMsg
//                    self.showAlert    = true
//                }
//            }
//        }
//    }
//}
//
//// MARK: - OTP Sheet
//
//private enum OTPField: Hashable { case code }
//
//struct LoginOtpView: View {
//
//    let email:     String
//    let password:  String
//    var onSuccess: () -> Void
//    var onError:   (String) -> Void
//
//    @Environment(\.dismiss) private var dismiss
//    @State private var otpCode        = ""
//    @State private var googleOTP      = ""
//    @State private var isLoading      = false
//    @State private var alertMsg       = ""
//    @State private var showAlert      = false
//    @State private var showGoogleAuth = false
//    @FocusState private var otpFocused: OTPField?
//
//    private var isOTPValid: Bool {
//        otpCode.count == 7 && otpCode.allSatisfy(\.isNumber)
//    }
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                Color.black.ignoresSafeArea()
//                ScrollView {
//                    VStack(spacing: 24) {
//                        Image(systemName: "envelope.badge.shield.half.filled.fill")
//                            .resizable().scaledToFit()
//                            .frame(width: 64, height: 64)
//                            .foregroundColor(.accentColor)
//                            .padding(.top, 32)
//
//                        Text("Security Authentication")
//                            .font(.title2).bold().foregroundColor(.white)
//
//                        Text("Enter the verification code sent to\n**\(maskedEmail)**")
//                            .font(.subheadline).foregroundColor(.gray)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//
//                        VStack(alignment: .leading, spacing: 6) {
//                            Text("E-mail verification code")
//                                .font(.caption).foregroundColor(.gray)
//                            TextField("7-digit OTP", text: $otpCode)
//                                .keyboardType(.numberPad)
//                                .focused($otpFocused, equals: .code)
//                                .onChange(of: otpCode) { val in
//                                    if val.count > 7 { otpCode = String(val.prefix(7)) }
//                                    if val.count == 7 && !showGoogleAuth { handleVerify() }
//                                }
//                                .foregroundColor(.primary)
//                                .padding(14)
//                                .background(Color(.secondarySystemBackground))
//                                .cornerRadius(10)
//                                .overlay(RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5))
//                        }
//                        .padding(.horizontal)
//
//                        if showGoogleAuth {
//                            VStack(alignment: .leading, spacing: 6) {
//                                Text("Google Authenticator Code")
//                                    .font(.caption).foregroundColor(.gray)
//                                TextField("6-digit code", text: $googleOTP)
//                                    .keyboardType(.numberPad)
//                                    .foregroundColor(.primary)
//                                    .padding(14)
//                                    .background(Color(.secondarySystemBackground))
//                                    .cornerRadius(10)
//                                    .overlay(RoundedRectangle(cornerRadius: 10)
//                                        .stroke(Color.accentColor.opacity(0.6), lineWidth: 1.5))
//                            }
//                            .padding(.horizontal)
//                        }
//
//                        Button { handleVerify() } label: {
//                            ZStack {
//                                if isLoading { ProgressView().tint(.white) }
//                                else { Text("Confirm").font(.headline).foregroundColor(.white) }
//                            }
//                            .frame(maxWidth: .infinity).frame(height: 52)
//                            .background(
//                                LinearGradient(
//                                    colors: [Color(red: 0.62, green: 0.36, blue: 0.96),
//                                             Color(red: 0.36, green: 0.49, blue: 0.96)],
//                                    startPoint: .leading, endPoint: .trailing
//                                )
//                            )
//                            .cornerRadius(12)
//                            .opacity(!isOTPValid ? 0.5 : 1.0)
//                        }
//                        .disabled(isLoading || !isOTPValid)
//                        .padding(.horizontal)
//
//                        Button("Resend Code") { resendOTP() }
//                            .font(.subheadline).foregroundColor(.blue)
//
//                        Spacer().frame(height: 40)
//                    }
//                }
//                .onTapGesture { otpFocused = nil }
//            }
//            .ignoresSafeArea(.keyboard, edges: .bottom)
//            .navigationTitle("Verify Identity")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button("Cancel") { dismiss() }.foregroundColor(.white)
//                }
//            }
//            .alert("Error", isPresented: $showAlert) {
//                Button("OK", role: .cancel) {}
//            } message: { Text(alertMsg) }
//        }
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                otpFocused = .code
//            }
//        }
//    }
//
//    private var maskedEmail: String {
//        guard let at = email.range(of: "@") else { return email }
//        let local  = String(email[..<at.lowerBound])
//        let domain = String(email[at.lowerBound...])
//        guard local.count > 3 else { return email }
//        return String(local.prefix(3)) + String(repeating: "*", count: local.count - 3) + domain
//    }
//
//    private func handleVerify() {
//        guard isOTPValid, !isLoading else { return }
//        isLoading = true
//
//        LoginService.shared.loginDetails(
//            email:         email,
//            password:      password,
//            emailOTP:      otpCode,
//            googleAuthOTP: googleOTP
//        ) { success, json, errMsg in
//            DispatchQueue.main.async {
//                if success {
//                    LoginService.shared.persistSession(from: json)
//                    self.postLoginCalls(json: json)
//                } else {
//                    self.isLoading = false
//                    self.alertMsg  = errMsg.isEmpty ? "Verification failed. Check your OTP." : errMsg
//                    self.showAlert = true
//                }
//            }
//        }
//    }
//
//    private func postLoginCalls(json: JSON) {
//        let merchantId = json["merchant_id"].intValue
//        let uuid       = json["uuid"].stringValue
//        let brokerId   = json["brokerId"].stringValue.isEmpty
//            ? (UserDefaults.standard.string(forKey: "brokerId") ?? "PAYB18022021121103")
//            : json["brokerId"].stringValue
//        let group = DispatchGroup()
//
//        group.enter()
//        LoginService.shared.fetchMerchantStatus(merchantId: merchantId) { success, statusJson, _ in
//            if success {
//                let flag = statusJson["transaction_status_flag"].intValue
//                UserDefaults.standard.set(flag == 0 ? "get-started" : "dashboard", forKey: "BlandingPage")
//                UserDefaults.standard.set(statusJson["email_confirmed"].stringValue,              forKey: "Bemail_confirmed")
//                UserDefaults.standard.set(statusJson["basic_verification_submitted"].stringValue, forKey: "Bbasic_verification_submitted")
//                UserDefaults.standard.set(statusJson["crypto_address_added"].stringValue,         forKey: "Bcrypto_address_added")
//                UserDefaults.standard.set(statusJson["account_status_id"].stringValue,            forKey: "Baccount_status_id")
//            }
//            group.leave()
//        }
//
//        group.enter()
//        LoginService.shared.getBrokerInfo(brokerId: brokerId) { _, _, _ in group.leave() }
//
//        if !uuid.isEmpty {
//            group.enter()
//            LoginService.shared.getProfilePicture(uuid: uuid) { _, picJson, _ in
//                let url = picJson["profile_image"].stringValue
//                if !url.isEmpty { UserDefaults.standard.set(url, forKey: "BprofileImageURL") }
//                group.leave()
//            }
//        }
//
//        group.notify(queue: .main) {
//            self.isLoading = false
//            self.onSuccess()
//        }
//    }
//
//    private func resendOTP() {
//        LoginService.shared.sendEmailOTP(email: email, password: password) { success, _, errMsg in
//            DispatchQueue.main.async {
//                if !success {
//                    self.alertMsg  = errMsg.isEmpty ? "Failed to resend OTP." : errMsg
//                    self.showAlert = true
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Preview
//#Preview("Login") { LoginView() }
//#Preview("OTP") {
//    LoginOtpView(email: "test@example.com", password: "secret",
//                 onSuccess: {}, onError: { _ in })
//}
