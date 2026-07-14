//
//  RegisterOtpView.swift
//  Trading_Terminal
//


import SwiftUI
import SwiftyJSON
import Alamofire

struct SignUpOTPView: View {
    
    enum OTPFocusField: Hashable {
        case otpCode
    }

    let email:     String
    let phone:     String
    var onSuccess: () -> Void
    let firstName: String
    let lastName: String
    let password: String
    let orgName: String
    let country: String
    let countryCode: String
    let gender: String

    @Environment(\.dismiss) private var dismiss
//    @State private var navigateToGetStarted = false
    @State private var emailOTP   = ""
    @State private var isLoading  = false
    @State private var isResending = false
    @State private var alertMsg   = ""
    @State private var showAlert  = false
    @State private var resendCooldown = 0
    @State private var timer: Timer?
    @FocusState private var focusedField: OTPFocusField?

    private let purple  = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let fieldBG = Color(red: 0.12, green: 0.15, blue: 0.22)

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()
                    
                    VStack(spacing: 28) {
                        
                        // Header
                        HStack {
                            Button(action: { dismiss() }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white).frame(width: 36, height: 36)
                            }
                            .buttonStyle(.plain)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        Spacer()
                        
                        // Icon
                        ZStack {
                            Circle()
                                .fill(purple.opacity(0.15))
                                .frame(width: 100, height: 100)
                            Image(systemName: "envelope.badge.fill")
                                .resizable().scaledToFit()
                                .frame(width: 48, height: 48)
                                .foregroundColor(purple)
                        }
                        
                        VStack(spacing: 8) {
                            Text("Verify Your Email")
                                .font(.system(size: 24, weight: .bold)).foregroundColor(.white)
                            Text("We sent a 7-digit verification code to\n**\(maskedEmail)**")
                                .font(.system(size: 14)).foregroundColor(.white.opacity(0.55))
                                .multilineTextAlignment(.center)
                        }
                        
                        // OTP input
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email Verification Code")
                                .font(.system(size: 13)).foregroundColor(.white.opacity(0.55))
                            TextField("Enter 7-digit code", text: $emailOTP)
                                .keyboardType(.numberPad)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .font(.system(size: 22, weight: .bold, design: .monospaced))
                                .padding(16)
                                .background(fieldBG)
                                .cornerRadius(12)
                                .focused($focusedField, equals: .otpCode)
                            
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(purple.opacity(0.60), lineWidth: 1.5)
                                }
                                .onChange(of: emailOTP) { val in
                                    if val.count > 7 { emailOTP = String(val.prefix(7)) }
                                    if val.count == 7 { handleVerify() }
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // Verify button
                        Button(action: handleVerify) {
                            ZStack {
                                if isLoading { ProgressView().tint(.white) }
                                else {
                                    Text("Verify & Create Account")
                                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                                }
                            }
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(purple)
                            .cornerRadius(12)
                            .opacity(emailOTP.count == 7 ? 1.0 : 0.5)
                        }
                        .disabled(isLoading || emailOTP.count != 7)
                        .buttonStyle(.plain)
                        .padding(.horizontal, 24)
                        
                        // Resend section - IMPROVED with loading state
                        VStack(spacing: 8) {
                            if resendCooldown > 0 {
                                Text("Resend code in \(resendCooldown)s")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.45))
                            } else {
                                Button(action: resendOTP) {
                                    HStack(spacing: 6) {
                                        if isResending {
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: purple))
                                                .scaleEffect(0.8)
                                        }
                                        Text(isResending ? "Sending..." : "Resend Code")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(isResending ? purple.opacity(0.5) : purple)
                                    }
                                }
                                .buttonStyle(.plain)
                                .disabled(isResending)
                            }
                            
                            // Helpful hint
                            Text("Check spam folder if not received")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.35))
                                .multilineTextAlignment(.center)
                        }
                        
                        Spacer()
                    }
                }
//                .navigationDestination(isPresented: $navigateToGetStarted) {
//                                GetStartedView()
//                                    .navigationBarBackButtonHidden(true)
//                            }
//                            .navigationBarHidden(true)
                .alert(showAlert ? (alertMsg.contains("Success") ? "Success" : "Error") : "Error",
                       isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMsg)
                }
                .onAppear {
                    focusedField = .otpCode
                    debugPrint("🟢 SignUpOTPView appeared")
                    
                    let tempId = UserDefaults.standard.string(forKey: "BtempMerchantId") ?? ""
                    
                    // 🔥 SEND OTP IMMEDIATELY (LIKE WEB)
                    if !tempId.isEmpty {
                        debugPrint("📧 Sending INITIAL OTP...")
                        
//                        RegisterService.shared.sendEmailOtp(email: email, tempMerchantId: tempId) { success, json, errorMsg in
//                            DispatchQueue.main.async {
//                                debugPrint("📥 Initial OTP Response:")
//                                debugPrint("   Success: \(success)")
//                                debugPrint("   Error: \(errorMsg)")
//                                
//                                if success {
//                                    debugPrint("✅ INITIAL OTP SENT")
//                                    self.startCooldown(120)
//                                } else {
//                                    debugPrint("❌ INITIAL OTP FAILED")
//                                    self.alertMsg = errorMsg.isEmpty ? "Failed to send OTP" : errorMsg
//                                    self.showAlert = true
//                                }
//                            }
//                        }
                    } else {
                        debugPrint("❌ TempMerchantId missing")
                        self.alertMsg = "Session expired. Please restart registration."
                        self.showAlert = true
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    debugPrint("🔴 SignUpOTPView disappeared")
                }
            }
        
        } else {
            // Fallback on earlier versions
        }
    }

    // MARK: - Masked email

    private var maskedEmail: String {
        guard let at = email.range(of: "@") else { return email }
        let local  = String(email[..<at.lowerBound])
        let domain = String(email[at.lowerBound...])
        guard local.count > 3 else { return email }
        return String(local.prefix(3)) + String(repeating: "*", count: local.count - 3) + domain
    }

    // MARK: - Verify OTP

    private func handleVerify() {
        guard emailOTP.count == 7, !isLoading else { return }
        isLoading = true

        let tempId = UserDefaults.standard.string(forKey: "BtempMerchantId") ?? ""
        guard let brokerId = UserDefaults.standard.string(forKey: "brokerId"),

              !brokerId.isEmpty else {

            alertMsg = "Broker information is missing. Please select your broker again."

            showAlert = true

            return

        }

        // Exact web registration payload — 9 fields only
        let params: [String: String] = [
            "first_name":        firstName,
            "last_name":         lastName,
            "email":             email,
            "password":          password,
            "organization_name": orgName,
            "temp_merchant_id":  tempId,
            "email_otp":         emailOTP,
            "country":           country,
            "countryCode":       countryCode,
            "phone":             phone,
            "gender":            gender,
            "referredBy":        "",
            "brokerId":          brokerId   // ✅ required
        ]
        debugPrint("📤 registration payload (\(params.count) keys):")
        params.forEach { debugPrint("   \($0.key): '\($0.value)'") }

        Alamofire.request(
            "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/registration",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: [
                "Content-Type": "application/json",
                "Accept":       "application/json, text/plain, */*",
                "Origin":       "https://trade.paybito.com",
                "Referer":      "https://trade.paybito.com/",
                "User-Agent":   "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
            ]
        ).responseString { response in
            DispatchQueue.main.async {
                self.isLoading = false

                let statusCode = response.response?.statusCode ?? -1
                debugPrint("📥 Response Status: \(statusCode)")
                debugPrint("📥 Response Body: \(response.value ?? "NIL")")

                guard let body = response.value,
                      let data = body.data(using: .utf8),
                      let json = try? JSON(data: data) else {
                    self.alertMsg  = "Could not parse server response."
                    self.showAlert = true
                    return
                }

                let first = json.array?.first ?? json
                let err   = first["error"].stringValue
                let msg   = first["error_msg"].stringValue

                debugPrint("   error: '\(err)'  msg: '\(msg)'")

                if err == "0" {
                    debugPrint("✅ REGISTRATION SUCCESS")
                    let data = first["data"]
                    UserDefaults.standard.set(data["oauth2"]["access_token"].stringValue, forKey: "Baccess_token")
                    UserDefaults.standard.set(data["uuid"].stringValue,                   forKey: "Buuid")
                    UserDefaults.standard.set(data["merchant_id"].stringValue,            forKey: "Bmerchant_id")
                    UserDefaults.standard.set(data["email_confirmed"].stringValue,        forKey: "Bemail_confirmed")
                    UserDefaults.standard.set(data["basic_verification_submitted"].stringValue, forKey: "Bbasic_verification_submitted")
                    UserDefaults.standard.set(data["crypto_address_added"].stringValue,   forKey: "Bcrypto_address_added")
                    UserDefaults.standard.set(data["first_name"].stringValue,             forKey: "Bfirst_name")
                    UserDefaults.standard.set(data["last_name"].stringValue,              forKey: "Blast_name")
                    UserDefaults.standard.set(data["email"].stringValue,                  forKey: "Bemail")
//                    self.navigateToGetStarted = true
                    self.onSuccess()
                } else {
                    self.alertMsg  = msg.isEmpty ? "Verification failed." : msg
                    self.showAlert = true
                }
            }
        }
    }

    // MARK: - Resend OTP - FULLY DEBUGGED VERSION

    private func resendOTP() {
        debugPrint("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        debugPrint("🔄 RESEND OTP - STARTING")
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        
        let tempId = UserDefaults.standard.string(forKey: "BtempMerchantId") ?? ""
        
        debugPrint("📝 Resend Request Details:")
        debugPrint("   Email: \(email)")
        debugPrint("   TempMerchantId: '\(tempId)'")
        debugPrint("   TempId isEmpty: \(tempId.isEmpty)")
        debugPrint("   TempId count: \(tempId.count)")
        
        // Validate temp_merchant_id exists
        guard !tempId.isEmpty else {
            debugPrint("❌ ERROR: TempMerchantId is EMPTY!")
            debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
            self.alertMsg = "Session expired. Please restart registration."
            self.showAlert = true
            return
        }
        
        isResending = true
        
        debugPrint("📞 Calling RegisterService.getSignUpEmailOtp...")
        
        RegisterService.shared.sendEmailOtp(email: email, tempMerchantId: tempId) { success, json, errorMsg in
            DispatchQueue.main.async {
                self.isResending = false
                
                debugPrint("📥 Resend Response Received:")
                debugPrint("   Success: \(success)")
                debugPrint("   Error Message: '\(errorMsg)'")
                debugPrint("   JSON: \(json)")
                
                if success {
                    debugPrint("✅ OTP RESENT SUCCESSFULLY")
                    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
                    self.startCooldown(120)
                    self.alertMsg = "✓ Verification code sent successfully!"
                    self.showAlert = true
                } else {
                    debugPrint("❌ RESEND FAILED")
                    debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n")
                    
                    // Enhanced error handling
                    var displayMsg = errorMsg
                    
                    if errorMsg.lowercased().contains("unauthorized") ||
                       errorMsg.lowercased().contains("401") {
                        displayMsg = "⚠️ Session expired. Please restart registration."
                    } else if errorMsg.lowercased().contains("session") ||
                              errorMsg.lowercased().contains("expired") ||
                              errorMsg.lowercased().contains("invalid") {
                        displayMsg = "⚠️ Invalid session. Please restart registration."
                    } else if errorMsg.lowercased().contains("limit") ||
                              errorMsg.lowercased().contains("too many") ||
                              errorMsg.lowercased().contains("rate") {
                        displayMsg = "⚠️ Too many requests. Please wait 2 minutes."
                    } else if errorMsg.isEmpty {
                        displayMsg = "Failed to send code. Please try again."
                    }
                    
                    self.alertMsg = displayMsg
                    self.showAlert = true
                }
            }
        }
    }

    private func startCooldown(_ seconds: Int) {
        timer?.invalidate()
        resendCooldown = seconds
        debugPrint("⏱️ Cooldown started: \(seconds) seconds")
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if resendCooldown > 0 {
                resendCooldown -= 1
            } else {
                timer?.invalidate()
                debugPrint("⏱️ Cooldown completed")
            }
        }
    }
}

// MARK: - Preview
#Preview {
    SignUpOTPView(
        email: "test@example.com",
        phone: "+11234567890",
        onSuccess: {
            print("Preview: OTP Success")
        },
        firstName: "John",
        lastName: "Doe",
        password: "Password123",
        orgName: "TestOrg",
        country: "United States",
        countryCode: "+1", gender: "Male"
    )
}
