// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  ForgotPasswordEmailView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 23/04/26.
//

//import SwiftUI
//
//// MARK: - Constants
//enum AppConfig {
//    static let siteNameAlias    = "SITE_ALIAS"
//    static let demoBrokerOrigin = "https://demo.paybito.com"
//    static let currentOrigin    = Bundle.main.infoDictionary?["APP_ORIGIN"] as? String ?? ""
//}
//
//private extension UserDefaults {
//    func branding(_ suffix: String) -> String {
//        string(forKey: "\(AppConfig.siteNameAlias)_\(suffix)") ?? ""
//    }
//}
//
//// MARK: - Toast model
//struct ToastMessage: Equatable {
//    enum Style { case success, error }
//    let style: Style
//    let message: String
//}
//
//// MARK: - Service layer
//struct ForgotPasswordRequestPayload: Encodable {
//    let email: String
//    let gRecaptchaResponse: String
//    let sessionId: String
//}
//
//struct ForgotPasswordResponse: Decodable {
//    let error: String
//    let error_msg: String
//}
//
//enum MerchantService {
//    static func forgotPassword(_ payload: ForgotPasswordPayload) async throws -> ForgotPasswordResponse {
//
//        guard let url = URL(string: "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/ForgotPassword") else {
//            throw URLError(.badURL)
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("https://trade.paybito.com", forHTTPHeaderField: "Origin")
//        request.setValue("https://trade.paybito.com/", forHTTPHeaderField: "Referer")
//        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
//
//        request.httpBody = try JSONEncoder().encode(payload)
//
//        // 🔍 REQUEST DEBUG
//        print("\n🚀 REQUEST URL:", url.absoluteString)
//        print("📤 REQUEST BODY:", String(data: request.httpBody!, encoding: .utf8) ?? "nil")
//        print("📤 HEADERS:", request.allHTTPHeaderFields ?? [:])
//
//        let (data, response) = try await URLSession.shared.data(for: request)
//
//        // 🔍 RESPONSE DEBUG
//        if let httpResponse = response as? HTTPURLResponse {
//            print("\n📥 STATUS CODE:", httpResponse.statusCode)
//            print("📥 RESPONSE HEADERS:", httpResponse.allHeaderFields)
//        }
//
//        let rawResponse = String(data: data, encoding: .utf8) ?? "Unable to decode response"
//        print("\n📥 RAW RESPONSE:\n", rawResponse)
//
//        // 🔥 Try ARRAY
//        do {
//            let items = try JSONDecoder().decode([ForgotPasswordResponse].self, from: data)
//            print("✅ Decoded as ARRAY")
//
//            guard let first = items.first else {
//                throw URLError(.cannotParseResponse)
//            }
//            return first
//
//        } catch {
//            print("❌ ARRAY decode failed:", error)
//        }
//
//        // 🔥 Try OBJECT
//        do {
//            let item = try JSONDecoder().decode(ForgotPasswordResponse.self, from: data)
//            print("✅ Decoded as OBJECT")
//            return item
//
//        } catch {
//            print("❌ OBJECT decode failed:", error)
//        }
//
//        throw NSError(
//            domain: "DecodingError",
//            code: -1,
//            userInfo: [
//                NSLocalizedDescriptionKey: "Failed to decode. Check logs."
//            ]
//        )
//    }
//}
//
//// MARK: - Loader overlay
//struct LoaderOverlay: View {
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.35).ignoresSafeArea()
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                .scaleEffect(1.8)
//        }
//    }
//}
//
//// MARK: - Main ForgotPassword view  (mirrors ForgotPassword.jsx)
//struct ForgotPasswordEmailView: View {
//
//    // Branding
//    private let navbarColour: Color = {
//        Color(hex: UserDefaults.standard.branding("navbarColour"))
//            ?? Color(red: 0.05, green: 0.09, blue: 0.18)
//    }()
//    private let backgroundColour: Color = {
//        Color(hex: UserDefaults.standard.branding("backgroundColour"))
//            ?? Color(red: 0.07, green: 0.11, blue: 0.20)
//    }()
//    private let backgroundImageURL: URL? = {
//        URL(string: UserDefaults.standard.branding("backgroundImageLink"))
//    }()
//    private let isBackgroundImage: Bool = {
//        UserDefaults.standard.branding("isBackgroundImage") != "0"
//    }()
//    private let logoURL: URL? = {
//        URL(string: UserDefaults.standard.branding("exchangeLogo"))
//    }()
//    private let exchangeTitle: String = {
//        UserDefaults.standard.branding("exchange")
//    }()
//    private let isDemoBroker: Bool = {
//        AppConfig.currentOrigin == AppConfig.demoBrokerOrigin
//    }()
//
//    // State  (mirrors this.state)
//    @State private var email             = ""
//    @State private var showLoader        = false
//    @State private var showCaptchaModal  = false   // mirrors showCaptchaModal
//    @State private var toast: ToastMessage? = nil
//
//    // ── NEW: navigation states ──
//    @State private var showForgotCaptcha = false   // → ForgotPasswordCaptchaView
//    @State private var showOTPVerify     = false   // → ForgotPasswordOTPView
//
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        ZStack {
//            backgroundLayer
//
//            VStack(spacing: 0) {
//                navBar
//                Spacer().frame(height: 40)
//                cardContent.padding(.horizontal, 16)
//                Spacer()
//                if isDemoBroker { poweredByFooter }
//            }
//
//            if showLoader { LoaderOverlay() }
//
//            if let t = toast {
//                toastBanner(t)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//                    .zIndex(10)
//            }
//        }
//        // ── Captcha sheet (puzzle slider) ──
//        .sheet(isPresented: $showForgotCaptcha) {
//            LoginCaptchaView(
//                //email: email,
//                onVerified: { captcha, sessionId in
//                    print("🧩 CAPTCHA (from sheet):", captcha)
//                            print("🧩 SESSION ID (from sheet):", sessionId)
//
//                    showForgotCaptcha = false
//                    // ✅ SHOW SUCCESS TOAST HERE
//                             showToast(.success, "Your reset link has been sent to your email")
//                    handleCaptchaSubmit(captcha: captcha, sessionId: sessionId)
//                },
//                onCancel: {
//                    showForgotCaptcha = false
//                }
//            )
//        }
//
//        .navigationBarHidden(true)
//        .onAppear { UIApplication.shared.setTitle(exchangeTitle) }
//    }
//
//    // MARK: - Sub-views
//
//    @ViewBuilder
//    private var backgroundLayer: some View {
//        if isBackgroundImage, let url = backgroundImageURL {
//            AsyncImage(url: url) { phase in
//                switch phase {
//                case .success(let img): img.resizable().scaledToFill()
//                default: backgroundColour
//                }
//            }
//            .ignoresSafeArea()
//        } else {
//            backgroundColour.ignoresSafeArea()
//        }
//    }
//
//    private var navBar: some View {
//        HStack {
//            if let url = logoURL {
//                AsyncImage(url: url) { phase in
//                    if case .success(let img) = phase {
//                        img.resizable().scaledToFit().frame(height: 36)
//                    }
//                }
//            } else {
//                Image("paybitologo", bundle: .sdkModule).resizable().scaledToFit().frame(height: 36)
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(navbarColour)
//    }
//
//    private var cardContent: some View {
//        VStack(spacing: 20) {
//
//            Text("Forgot Password")
//                .font(.system(size: 22, weight: .bold))
//                .foregroundColor(.white)
//
//            Text("Enter your email address that you used to register. We'll send you an email with your username and a link to reset your password.")
//                .font(.system(size: 14))
//                .foregroundColor(Color.white.opacity(0.65))
//                .multilineTextAlignment(.center)
//
//            // Email field  (mirrors emailRef input)
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Email Address")
//                    .foregroundColor(Color.white.opacity(0.6))
//                    .font(.system(size: 13))
//                TextField("", text: $email)
//                    .keyboardType(.emailAddress)
//                    .autocapitalization(.none)
//                    .disableAutocorrection(true)
//                    .padding()
//                    .background(Color.white.opacity(0.08))
//                    .cornerRadius(10)
//                    .foregroundColor(.white)
//                    .accentColor(.white)
//            }
//
//            // Submit button  (mirrors handleForgotPassword onSubmit)
//            Button(action: handleForgotPassword) {
//                Text("Reset My Password")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(
//                        LinearGradient(
//                            colors: [Color.purple, Color.blue],
//                            startPoint: .leading, endPoint: .trailing
//                        )
//                    )
//                    .cornerRadius(14)
//            }
//
//            // Back to Sign In  (mirrors <Link to="/">)
//            Button(action: { dismiss() }) {
//                Text("Back To Sign In")
//                    .font(.system(size: 14))
//                    .foregroundColor(.blue)
//            }
//        }
//        .padding(24)
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .fill(Color(red: 0.08, green: 0.12, blue: 0.22))
//        )
//    }
//
//    private var poweredByFooter: some View {
//        Link(destination: URL(string: "https://www.paybito.com/")!) {
//            HStack(spacing: 6) {
//                Image("paybitologo", bundle: .sdkModule).resizable().scaledToFit().frame(height: 24)
//                Text("Powered by PayBito infrastructure")
//                    .font(.system(size: 13)).foregroundColor(.primary)
//            }
//            .padding(.horizontal, 14).padding(.vertical, 10)
//            .background(Color(.systemBackground).opacity(0.9))
//            .cornerRadius(8)
//        }
//        .padding(.bottom, 20).padding(.trailing, 16)
//        .frame(maxWidth: .infinity, alignment: .trailing)
//    }
//
//    @ViewBuilder
//    private func toastBanner(_ t: ToastMessage) -> some View {
//        VStack {
//            HStack(spacing: 10) {
//                Image(systemName: t.style == .success
//                      ? "checkmark.circle.fill" : "xmark.circle.fill")
//                    .foregroundColor(t.style == .success ? .green : .red)
//                Text(t.message)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.white)
//                Spacer()
//            }
//            .padding()
//            .background(Color(red: 0.12, green: 0.16, blue: 0.28))
//            .cornerRadius(12)
//            .padding(.horizontal, 16)
//            .padding(.top, 60)
//            Spacer()
//        }
//    }
//
//    // MARK: - Logic  (mirrors class methods)
//
//    /// mirrors handleForgotPassword — opens captcha first
//    private func handleForgotPassword() {
//        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
//            showToast(.error, "Please provide valid email address")
//            return
//        }
//        showForgotCaptcha = true   // ← open puzzle captcha
//    }
//
//    /// mirrors handleCaptchaSubmit — calls MerchantForgotPassword API
//    private func handleCaptchaSubmit(captcha: String, sessionId: String) {
//        // Guard against empty captcha or sessionId
//        let trimmedCaptcha   = captcha.trimmingCharacters(in: .whitespaces)
//        let trimmedSessionId = sessionId.trimmingCharacters(in: .whitespaces)
//
//        guard !trimmedCaptcha.isEmpty else {
//            showToast(.error, "Captcha verification failed. Please try again.")
//            return
//        }
//        guard !trimmedSessionId.isEmpty else {
//            showToast(.error, "Session expired. Please try again.")
//            return
//        }
//        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
//            showToast(.error, "Please provide valid email address")
//            return
//        }
//
//        showLoader = true
//
//        let payload = ForgotPasswordPayload(
//            email:              email.trimmingCharacters(in: .whitespaces),
//            gRecaptchaResponse: trimmedCaptcha,
//            sessionId:          trimmedSessionId
//        )
//
//        Task {
//            defer { DispatchQueue.main.async { self.showLoader = false } }
//            do {
//                let response = try await MerchantService.forgotPassword(payload)
//                DispatchQueue.main.async {
//                    if response.error != "0" {
//                        self.showToast(.error, response.error_msg)
//                    } else {
//                        self.showOTPVerify = true
//                    }
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    self.showToast(.error, error.localizedDescription)
//                }
//            }
//        }
//    }
//
//    private func showToast(_ style: ToastMessage.Style, _ message: String) {
//        withAnimation { toast = ToastMessage(style: style, message: message) }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
//            withAnimation { toast = nil }
//        }
//    }
//}
//
//extension UIApplication {
//    func setTitle(_ title: String) { _ = title }
//}
//
//#Preview { ForgotPasswordEmailView() }

//  ForgotPasswordEmailView.swift
//  Trading_Terminal

import SwiftUI

// Add this line at the top of ForgotPasswordEmailView.swift
// after the imports — no need to redeclare the struct
typealias ForgotPasswordResponse = APIBaseResponse

// MARK: - Constants
enum AppConfig {
    static let siteNameAlias    = "SITE_ALIAS"
    static let demoBrokerOrigin = "https://demo.paybito.com"
    static let currentOrigin    = Bundle.main.infoDictionary?["APP_ORIGIN"] as? String ?? ""
}

private extension UserDefaults {
    func branding(_ suffix: String) -> String {
        string(forKey: "\(AppConfig.siteNameAlias)_\(suffix)") ?? ""
    }
}

// MARK: - Toast model
struct ToastMessage: Equatable {
    enum Style { case success, error }
    let style: Style
    let message: String
}

// NOTE: ForgotPasswordPayload & ForgotPasswordResponse live in
//       Forgotpasswordservice.swift — do NOT redeclare them here.

enum MerchantService {
    static func forgotPassword(_ payload: ForgotPasswordPayload) async throws -> ForgotPasswordResponse {

        guard let url = URL(string: "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/ForgotPassword") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",           forHTTPHeaderField: "Content-Type")
        request.setValue("https://trade.paybito.com",  forHTTPHeaderField: "Origin")
        request.setValue("https://trade.paybito.com/", forHTTPHeaderField: "Referer")
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X)",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = try JSONEncoder().encode(payload)

        #if DEBUG
        print("\n🚀 REQUEST URL:", url.absoluteString)
        print("📤 REQUEST BODY:", String(data: request.httpBody!, encoding: .utf8) ?? "nil")
        #endif

        let (data, response) = try await URLSession.shared.data(for: request)

        #if DEBUG
        if let http = response as? HTTPURLResponse {
            print("📥 STATUS CODE:", http.statusCode)
        }
        print("📥 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")
        #endif

        // Try array format first
        if let items = try? JSONDecoder().decode([ForgotPasswordResponse].self, from: data),
           let first = items.first {
            return first
        }
        // Try object format
        if let item = try? JSONDecoder().decode(ForgotPasswordResponse.self, from: data) {
            return item
        }

        throw NSError(
            domain: "DecodingError",
            code: -1,
            userInfo: [NSLocalizedDescriptionKey: "Failed to decode response."]
        )
    }
}

// MARK: - Loader overlay
struct LoaderOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.8)
        }
    }
}

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6, let intVal = UInt64(hex, radix: 16) else { return nil }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8)  & 0xFF) / 255.0
        let b = Double( intVal        & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - ForgotPasswordEmailView

struct ForgotPasswordEmailView: View {

    // Branding
    private let navbarColour: Color = {
        Color(hex: UserDefaults.standard.branding("navbarColour"))
            ?? Color(red: 0.05, green: 0.09, blue: 0.18)
    }()
    private let backgroundColour: Color = {
        Color(hex: UserDefaults.standard.branding("backgroundColour"))
            ?? Color(red: 0.07, green: 0.11, blue: 0.20)
    }()
    private let backgroundImageURL: URL? = {
        URL(string: UserDefaults.standard.branding("backgroundImageLink"))
    }()
    private let isBackgroundImage: Bool = {
        UserDefaults.standard.branding("isBackgroundImage") != "0"
    }()
    private let logoURL: URL? = {
        URL(string: UserDefaults.standard.branding("exchangeLogo"))
    }()
    private let exchangeTitle: String = {
        UserDefaults.standard.branding("exchange")
    }()
    private let isDemoBroker: Bool = {
        AppConfig.currentOrigin == AppConfig.demoBrokerOrigin
    }()

    @State private var email             = ""
    @State private var showLoader        = false
    @State private var showForgotCaptcha = false
    @State private var showOTPVerify     = false
    @State private var toast: ToastMessage? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                navBar
                Spacer().frame(height: 40)
                cardContent.padding(.horizontal, 16)
                Spacer()
                if isDemoBroker { poweredByFooter }
            }

            if showLoader { LoaderOverlay() }

            if let t = toast {
                toastBanner(t)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(10)
            }
        }
        // ── Captcha sheet ─────────────────────────────────────────────
        .sheet(isPresented: $showForgotCaptcha) {
            LoginCaptchaView(
                onVerified: { token in          // ← single JWT token
                    showForgotCaptcha = false
                    handleCaptchaSubmit(token: token)
                },
                onCancel: {
                    showForgotCaptcha = false
                }
            )
        }
        .navigationBarHidden(true)
        .onAppear { UIApplication.shared.setTitle(exchangeTitle) }
    }

    // MARK: - Sub-views

    @ViewBuilder
    private var backgroundLayer: some View {
        if isBackgroundImage, let url = backgroundImageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let img): img.resizable().scaledToFill()
                default: backgroundColour
                }
            }
            .ignoresSafeArea()
        } else {
            backgroundColour.ignoresSafeArea()
        }
    }

    private var navBar: some View {
        HStack {
            if let url = logoURL {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFit().frame(height: 36)
                    }
                }
            } else {
                Image("paybitologo", bundle: .sdkModule).resizable().scaledToFit().frame(height: 36)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(navbarColour)
    }

    private var cardContent: some View {
        VStack(spacing: 20) {

            Text("Forgot Password")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)

            Text("Enter your email address that you used to register. We'll send you an email with your username and a link to reset your password.")
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.65))
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 6) {
                Text("Email Address")
                    .foregroundColor(Color.white.opacity(0.6))
                    .font(.system(size: 13))
                TextField("", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .accentColor(.white)
            }

            Button(action: handleForgotPassword) {
                Text("Reset My Password")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }

            Button(action: { dismiss() }) {
                Text("Back To Sign In")
                    .font(.system(size: 14))
                    .foregroundColor(.blue)
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.08, green: 0.12, blue: 0.22))
        )
    }

    private var poweredByFooter: some View {
        Link(destination: URL(string: "https://www.paybito.com/")!) {
            HStack(spacing: 6) {
                Image("paybitologo", bundle: .sdkModule).resizable().scaledToFit().frame(height: 24)
                Text("Powered by PayBito infrastructure")
                    .font(.system(size: 13)).foregroundColor(.primary)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(Color(.systemBackground).opacity(0.9))
            .cornerRadius(8)
        }
        .padding(.bottom, 20).padding(.trailing, 16)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    @ViewBuilder
    private func toastBanner(_ t: ToastMessage) -> some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: t.style == .success
                      ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(t.style == .success ? .green : .red)
                Text(t.message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color(red: 0.12, green: 0.16, blue: 0.28))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.top, 60)
            Spacer()
        }
    }

    // MARK: - Logic

    private func handleForgotPassword() {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            showToast(.error, "Please provide valid email address")
            return
        }
        showForgotCaptcha = true
    }

    private func handleCaptchaSubmit(token: String) {
        let trimmedToken = token.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)

        guard !trimmedToken.isEmpty else {
            showToast(.error, "Captcha verification failed. Please try again.")
            return
        }
        guard !trimmedEmail.isEmpty else {
            showToast(.error, "Please provide valid email address")
            return
        }

        showLoader = true

        // ForgotPasswordPayload defined in Forgotpasswordservice.swift
        let payload = ForgotPasswordPayload(
            email:              trimmedEmail,
            gRecaptchaResponse: trimmedToken
        )

        Task {
            defer { DispatchQueue.main.async { self.showLoader = false } }
            do {
                let response = try await MerchantService.forgotPassword(payload)
                DispatchQueue.main.async {
                    if response.error != "0" {
                        self.showToast(.error, response.error_msg)
                    } else {
                        self.showToast(.success, "Your reset link has been sent to your email")
                        self.showOTPVerify = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showToast(.error, error.localizedDescription)
                }
            }
        }
    }

    private func showToast(_ style: ToastMessage.Style, _ message: String) {
        withAnimation { toast = ToastMessage(style: style, message: message) }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation { toast = nil }
        }
    }
}

extension UIApplication {
    func setTitle(_ title: String) { _ = title }
}

#Preview { ForgotPasswordEmailView() }
