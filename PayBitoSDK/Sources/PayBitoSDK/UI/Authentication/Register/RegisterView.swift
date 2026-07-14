  //RegisterView.swift
  //Trading_Terminal

import SwiftUI

// MARK: - Validation helpers

private func isValidEmail(_ s: String) -> Bool {
    NSPredicate(format: "SELF MATCHES %@",
        "^[a-zA-Z0-9._%+-]{1,30}@[a-zA-Z0-9-]{1,30}\\.[a-zA-Z]{2,}$").evaluate(with: s)
}
private func isValidPassword(_ s: String) -> Bool {
    NSPredicate(format: "SELF MATCHES %@",
        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@.$!])[A-Za-z\\d@.$!]{8,35}$").evaluate(with: s)
}
private func isValidFirstName(_ s: String) -> Bool {
    NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]{2,20}$").evaluate(with: s)
}
private func isValidLastName(_ s: String) -> Bool {
    NSPredicate(format: "SELF MATCHES %@",
        "^[a-zA-Z-]{2,20}( [a-zA-Z-]{2,20})?$").evaluate(with: s)
}
private func isValidOrgName(_ s: String) -> Bool {
    NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9 \\-\\.]+$").evaluate(with: s)
}

// MARK: - Country Model

struct Country: Identifiable, Hashable {
    let id   = UUID()
    let name: String
    let code: String
    let iso:  String
    let flag: String
}

private let allCountries: [Country] = [
    Country(name: "United States",  code: "1",   iso: "us", flag: "🇺🇸"),
    Country(name: "India",          code: "91",  iso: "in", flag: "🇮🇳"),
    Country(name: "United Kingdom", code: "44",  iso: "gb", flag: "🇬🇧"),
    Country(name: "Canada",         code: "1",   iso: "ca", flag: "🇨🇦"),
    Country(name: "Australia",      code: "61",  iso: "au", flag: "🇦🇺"),
    Country(name: "Germany",        code: "49",  iso: "de", flag: "🇩🇪"),
    Country(name: "France",         code: "33",  iso: "fr", flag: "🇫🇷"),
    Country(name: "Italy",          code: "39",  iso: "it", flag: "🇮🇹"),
    Country(name: "Spain",          code: "34",  iso: "es", flag: "🇪🇸"),
    Country(name: "Netherlands",    code: "31",  iso: "nl", flag: "🇳🇱"),
    Country(name: "Belgium",        code: "32",  iso: "be", flag: "🇧🇪"),
    Country(name: "Switzerland",    code: "41",  iso: "ch", flag: "🇨🇭"),
    Country(name: "Austria",        code: "43",  iso: "at", flag: "🇦🇹"),
    Country(name: "Sweden",         code: "46",  iso: "se", flag: "🇸🇪"),
    Country(name: "Norway",         code: "47",  iso: "no", flag: "🇳🇴"),
    Country(name: "Denmark",        code: "45",  iso: "dk", flag: "🇩🇰"),
    Country(name: "Finland",        code: "358", iso: "fi", flag: "🇫🇮"),
    Country(name: "Ireland",        code: "353", iso: "ie", flag: "🇮🇪"),
    Country(name: "Portugal",       code: "351", iso: "pt", flag: "🇵🇹"),
    Country(name: "Greece",         code: "30",  iso: "gr", flag: "🇬🇷"),
    Country(name: "Poland",         code: "48",  iso: "pl", flag: "🇵🇱"),
    Country(name: "Russia",         code: "7",   iso: "ru", flag: "🇷🇺"),
    Country(name: "Turkey",         code: "90",  iso: "tr", flag: "🇹🇷"),
    Country(name: "China",          code: "86",  iso: "cn", flag: "🇨🇳"),
    Country(name: "Japan",          code: "81",  iso: "jp", flag: "🇯🇵"),
    Country(name: "South Korea",    code: "82",  iso: "kr", flag: "🇰🇷"),
    Country(name: "Singapore",      code: "65",  iso: "sg", flag: "🇸🇬"),
    Country(name: "Malaysia",       code: "60",  iso: "my", flag: "🇲🇾"),
    Country(name: "Indonesia",      code: "62",  iso: "id", flag: "🇮🇩"),
    Country(name: "Thailand",       code: "66",  iso: "th", flag: "🇹🇭"),
    Country(name: "Vietnam",        code: "84",  iso: "vn", flag: "🇻🇳"),
    Country(name: "Philippines",    code: "63",  iso: "ph", flag: "🇵🇭"),
    Country(name: "Hong Kong",      code: "852", iso: "hk", flag: "🇭🇰"),
    Country(name: "Taiwan",         code: "886", iso: "tw", flag: "🇹🇼"),
    Country(name: "Pakistan",       code: "92",  iso: "pk", flag: "🇵🇰"),
    Country(name: "Bangladesh",     code: "880", iso: "bd", flag: "🇧🇩"),
    Country(name: "Sri Lanka",      code: "94",  iso: "lk", flag: "🇱🇰"),
    Country(name: "Nepal",          code: "977", iso: "np", flag: "🇳🇵"),
    Country(name: "UAE",            code: "971", iso: "ae", flag: "🇦🇪"),
    Country(name: "Saudi Arabia",   code: "966", iso: "sa", flag: "🇸🇦"),
    Country(name: "Qatar",          code: "974", iso: "qa", flag: "🇶🇦"),
    Country(name: "Kuwait",         code: "965", iso: "kw", flag: "🇰🇼"),
    Country(name: "Bahrain",        code: "973", iso: "bh", flag: "🇧🇭"),
    Country(name: "Oman",           code: "968", iso: "om", flag: "🇴🇲"),
    Country(name: "Israel",         code: "972", iso: "il", flag: "🇮🇱"),
    Country(name: "Egypt",          code: "20",  iso: "eg", flag: "🇪🇬"),
    Country(name: "South Africa",   code: "27",  iso: "za", flag: "🇿🇦"),
    Country(name: "Nigeria",        code: "234", iso: "ng", flag: "🇳🇬"),
    Country(name: "Kenya",          code: "254", iso: "ke", flag: "🇰🇪"),
    Country(name: "Brazil",         code: "55",  iso: "br", flag: "🇧🇷"),
    Country(name: "Argentina",      code: "54",  iso: "ar", flag: "🇦🇷"),
    Country(name: "Mexico",         code: "52",  iso: "mx", flag: "🇲🇽"),
    Country(name: "Chile",          code: "56",  iso: "cl", flag: "🇨🇱"),
    Country(name: "Colombia",       code: "57",  iso: "co", flag: "🇨🇴"),
    Country(name: "Peru",           code: "51",  iso: "pe", flag: "🇵🇪"),
    Country(name: "New Zealand",    code: "64",  iso: "nz", flag: "🇳🇿"),
    Country(name: "Ukraine",        code: "380", iso: "ua", flag: "🇺🇦"),
    Country(name: "Czech Republic", code: "420", iso: "cz", flag: "🇨🇿"),
    Country(name: "Romania",        code: "40",  iso: "ro", flag: "🇷🇴"),
    Country(name: "Hungary",        code: "36",  iso: "hu", flag: "🇭🇺")
]

// MARK: - Focus Fields

private enum RegFocus: Hashable {
    case org, firstName, lastName, email, phone, password, retypePassword
}

// MARK: - RegisterView

struct RegisterView: View {
    @State private var navigateToContainer = false

    @Environment(\.dismiss) private var dismiss

    // Form fields
    @State private var orgName         = ""
    @State private var gender          = ""
    @State private var firstName       = ""
    @State private var lastName        = ""
    @State private var email           = ""
    @State private var phone           = ""
    @State private var selectedCountry = allCountries[0]
    @State private var password        = ""
    @State private var retypePassword  = ""
    @State private var isTermsAccepted = false

    // Validation errors
    @State private var orgError   = ""
    @State private var firstError = ""
    @State private var lastError  = ""
    @State private var emailError = ""
    @State private var phoneError = ""
    @State private var pwdError   = ""
    @State private var rePwdError = ""

    // ── FIX: track which fields have been touched ──────────────────
    @State private var phoneTouched    = false
    @State private var pwdTouched      = false
    @State private var rePwdTouched    = false

    // Captcha result
    @State private var captchaToken = ""

    // UI state
    @State private var showPassword      = false
    @State private var showRePwd         = false
    @State private var isLoading         = false
    @State private var alertMsg          = ""
    @State private var showAlert         = false
    @State private var showCaptcha       = false
    @State private var showOTP           = false
    @State private var showCountryPicker = false

    @FocusState private var focusedField: RegFocus?

    private let genders     = [("Male","Mr."), ("Female","Mrs."), ("Other","Other")]
    private let purple      = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let inputBG     = Color.black
    private let inputBorder = Color.gray.opacity(0.45)
    private let darkBG      = Color(red: 0.08, green: 0.10, blue: 0.16)

    var body: some View {
        NavigationView {
            ZStack {
                darkBG.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        pageTitle
                        orgField
                        genderPicker
                        nameRow
                        emailField
                        phoneField
                        passwordField
                        retypePasswordField
                        termsRow
                        submitButton
                        loginLink
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
                if isLoading { loadingOverlay }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showCaptcha) {
            LoginCaptchaView(
                onVerified: { token in
                    captchaToken = token
                    showCaptcha  = false
                    proceedRegistration()
                },
                onCancel: { showCaptcha = false }
            )
            .padding(20)
            .background(Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea())
        }
        .sheet(isPresented: $showCountryPicker) {
            CountryPickerView(
                countries: allCountries,
                selected: $selectedCountry,
                isPresented: $showCountryPicker
            )
        }
        .fullScreenCover(isPresented: $showOTP) {
            SignUpOTPView(
                email: email,
                phone: phone,
                onSuccess: {
                    showOTP = false
                               DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                   navigateToContainer = true
                               }
                },
                firstName: firstName,
                lastName: lastName,
                password: password,
                orgName: orgName,
                country: selectedCountry.name,
                countryCode: selectedCountry.code,
                gender: gender
            )
        }
        .fullScreenCover(isPresented: $navigateToContainer) {
            BillBitcoinsContainerView()
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: { Text(alertMsg) }
    }

    // MARK: - Page title

    private var pageTitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Create Account")
                .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
            Text("Fill in your details to get started")
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.55))
        }
        .padding(.top, 20)
    }

    // MARK: - Organisation Name

    private var orgField: some View {
        RegField(
            label: "Organization Name *",
            placeholder: "Enter organization name",
            text: $orgName,
            error: orgError,
            field: .org,
            focusedField: $focusedField
        ) {
            orgError = isValidOrgName(orgName) ? "" : "Enter a valid organization name"
        }
    }

    // MARK: - Gender picker

    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gender").font(.caption).foregroundColor(.gray)
            HStack(spacing: 10) {
                ForEach(genders, id: \.0) { (val, label) in
                    Button(action: { gender = val }) {
                        Text(label)
                            .font(.system(size: 14, weight: gender == val ? .bold : .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(gender == val ? purple : Color.black)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        gender == val ? purple : Color.gray.opacity(0.45),
                                        lineWidth: 1.5
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Name row

    private var nameRow: some View {
        HStack(spacing: 12) {
            RegField(
                label: "First Name *", placeholder: "First Name",
                text: $firstName, error: firstError,
                field: .firstName, focusedField: $focusedField
            ) {
                firstError = isValidFirstName(firstName) ? "" : "2–20 letters only"
            }
            RegField(
                label: "Last Name *", placeholder: "Last Name",
                text: $lastName, error: lastError,
                field: .lastName, focusedField: $focusedField
            ) {
                lastError = isValidLastName(lastName) ? "" : "2–20 letters only"
            }
        }
    }

    // MARK: - Email

    private var emailField: some View {
        RegField(
            label: "Email Address *", placeholder: "email@example.com",
            text: $email, error: emailError,
            field: .email, focusedField: $focusedField,
            keyboard: .emailAddress
        ) {
            // onBlur is only called by RegField after the field was touched
            emailError = isValidEmail(email) ? "" : "Enter a valid email"
            if emailError.isEmpty && !email.isEmpty { checkEmailAPI() }
        }
    }

    // MARK: - Phone

    private var phoneField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Phone Number *").font(.caption).foregroundColor(.gray)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(inputBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                !phoneError.isEmpty
                                    ? Color.red.opacity(0.70)
                                    : focusedField == .phone ? purple : inputBorder,
                                lineWidth: 1.5
                            )
                    )

                HStack(spacing: 0) {
                    Button(action: { showCountryPicker = true }) {
                        HStack(spacing: 4) {
                            Text(selectedCountry.flag).font(.system(size: 16))
                            Text("+\(selectedCountry.code)")
                                .font(.system(size: 13)).foregroundColor(.white)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10)).foregroundColor(.gray)
                        }
                        .padding(.leading, 12)
                    }
                    .buttonStyle(.plain)

                    Rectangle()
                        .fill(Color.gray.opacity(0.35))
                        .frame(width: 1, height: 24)
                        .padding(.horizontal, 8)

                    TextField("", text: $phone,
                              prompt: Text("Phone number").foregroundColor(.gray))
                        .keyboardType(.phonePad)
                        .foregroundColor(.white)
                        .focused($focusedField, equals: .phone)
                        .onSubmit {
                            // ── FIX: only validate on explicit submit ──
                            if phoneTouched {
                                phoneError = phone.count >= 7 ? "" : "Enter a valid phone number"
                                if phoneError.isEmpty { checkPhoneAPI() }
                            }
                        }
                        .onChange(of: focusedField) { f in
                            if f == .phone {
                                // Field just gained focus — mark as touched
                                phoneTouched = true
                            } else if phoneTouched && !phone.isEmpty {
                                // Field lost focus after being touched and filled
                                phoneError = phone.count >= 7 ? "" : "Enter a valid phone number"
                                if phoneError.isEmpty { checkPhoneAPI() }
                            }
                        }
                    Spacer()
                }
            }
            .frame(height: 50)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .phone }

            if !phoneError.isEmpty {
                Text(phoneError)
                    .font(.system(size: 11)).foregroundColor(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: phoneError.isEmpty)
    }

    // MARK: - Password

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Password *").font(.caption).foregroundColor(.gray)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(inputBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                !pwdError.isEmpty
                                    ? Color.red.opacity(0.70)
                                    : focusedField == .password ? purple : inputBorder,
                                lineWidth: 1.5
                            )
                    )
                HStack {
                    Group {
                        if showPassword {
                            TextField("", text: $password,
                                      prompt: Text("Enter your password").foregroundColor(.gray))
                                .focused($focusedField, equals: .password)
                        } else {
                            SecureField("", text: $password,
                                        prompt: Text("Enter your password").foregroundColor(.gray))
                                .focused($focusedField, equals: .password)
                        }
                    }
                    .autocapitalization(.none).autocorrectionDisabled()
                    .foregroundColor(.white)
                    .onChange(of: focusedField) { f in
                        if f == .password {
                            pwdTouched = true
                        }
                    }
                    .onChange(of: password) { _ in
                        // ── FIX: only validate once the user has started typing ──
                        if pwdTouched && !password.isEmpty {
                            pwdError = isValidPassword(password) ? "" :
                                "Min 8 chars, uppercase, lowercase, digit & special char (@ . $ !)"
                        } else if password.isEmpty {
                            pwdError = ""
                        }
                    }
                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .frame(height: 50)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .password }

            if !pwdError.isEmpty {
                Text(pwdError)
                    .font(.system(size: 11)).foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: pwdError.isEmpty)
    }

    // MARK: - Confirm Password

    private var retypePasswordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Confirm Password *").font(.caption).foregroundColor(.gray)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(inputBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                !rePwdError.isEmpty
                                    ? Color.red.opacity(0.70)
                                    : !retypePassword.isEmpty && retypePassword == password
                                        ? Color.green.opacity(0.60)
                                        : focusedField == .retypePassword ? purple : inputBorder,
                                lineWidth: 1.5
                            )
                    )
                HStack {
                    Group {
                        if showRePwd {
                            TextField("", text: $retypePassword,
                                      prompt: Text("Re-enter password").foregroundColor(.gray))
                                .focused($focusedField, equals: .retypePassword)
                        } else {
                            SecureField("", text: $retypePassword,
                                        prompt: Text("Re-enter password").foregroundColor(.gray))
                                .focused($focusedField, equals: .retypePassword)
                        }
                    }
                    .autocapitalization(.none).autocorrectionDisabled()
                    .foregroundColor(.white)
                    .onChange(of: focusedField) { f in
                        if f == .retypePassword {
                            rePwdTouched = true
                        }
                    }
                    .onChange(of: retypePassword) { _ in
                        // ── FIX: only validate once user has started typing ──
                        if rePwdTouched {
                            if retypePassword.isEmpty { rePwdError = "" }
                            else { rePwdError = retypePassword == password ? "" : "Passwords do not match" }
                        }
                    }
                    Button { showRePwd.toggle() } label: {
                        Image(systemName: showRePwd ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
            .frame(height: 50)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = .retypePassword }

            if !rePwdError.isEmpty {
                Text(rePwdError)
                    .font(.system(size: 11)).foregroundColor(.red)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            } else if !retypePassword.isEmpty && retypePassword == password {
                Text("Password matched ✓")
                    .font(.system(size: 11)).foregroundColor(.green)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: rePwdError.isEmpty)
    }

 

    // MARK: - Terms

    private var termsRow: some View {
        HStack(alignment: .top, spacing: 10) {
            Button(action: { isTermsAccepted.toggle() }) {
                Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
                    .font(.system(size: 20)).foregroundColor(purple)
            }
            .buttonStyle(.plain)
            
            HStack(spacing: 0) {
                Text("I read and accept the ")
                    .foregroundColor(.white.opacity(0.65))
                
                Button(action: {
                    if let url = URL(string: "https://trade.paybito.com/legal/terms-of-use-pay-services.html?broker-Id=PAYB18022021121103") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Terms")
                        .foregroundColor(purple)
                }
                .buttonStyle(.plain)
                
                Text(" & ")
                    .foregroundColor(.white.opacity(0.65))
                
                Button(action: {
                    if let url = URL(string: "https://trade.paybito.com/privacy-policy") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Privacy Policy")
                        .foregroundColor(purple)
                }
                .buttonStyle(.plain)
            }
            .font(.system(size: 13))
        }
    }

    // MARK: - Submit button

    private var submitButton: some View {
        Button(action: handleSubmit) {
            ZStack {
                if isLoading { ProgressView().tint(.white) }
                else {
                    Text("Sign Up")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
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
        .disabled(!canSubmit || isLoading)
        .buttonStyle(.plain)
    }

    // MARK: - Login link

    private var loginLink: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Text("Already a member? ").foregroundColor(.white.opacity(0.55))
                + Text("Sign In").foregroundColor(purple).bold()
            }
            .font(.system(size: 13)).buttonStyle(.plain)
            Spacer()
        }
        .padding(.bottom, 20)
    }

    // MARK: - Loading overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            VStack(spacing: 12) {
                ProgressView().scaleEffect(1.4).tint(.white)
                Text("Please wait…").font(.subheadline).foregroundColor(.white)
            }
            .padding(24)
            .background(Color.white.opacity(0.10))
            .cornerRadius(16)
        }
    }

    // MARK: - Validation gate

    private var canSubmit: Bool {
        !orgName.isEmpty && !firstName.isEmpty && !lastName.isEmpty &&
        !email.isEmpty && !phone.isEmpty && !password.isEmpty &&
        !retypePassword.isEmpty && isTermsAccepted &&
        orgError.isEmpty && firstError.isEmpty && lastError.isEmpty &&
        emailError.isEmpty && phoneError.isEmpty &&
        pwdError.isEmpty && rePwdError.isEmpty &&
        password == retypePassword
    }

    // MARK: - Flow

    private func handleSubmit() {
        guard canSubmit else {
            alertMsg = "Please provide valid details & select terms & conditions"
            showAlert = true
            return
        }
        captchaToken = ""
        showCaptcha  = true
    }

    private func proceedRegistration() {
        guard !captchaToken.isEmpty else {
            alertMsg = "Captcha verification failed. Please try again."
            showAlert = true
            return
        }

        isLoading = true

        // ── DEBUG ──────────────────────────────────────────────────────
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        debugPrint("🚀 SIGNUP SUBMIT - VALUES BEING SENT")
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        debugPrint("   orgName:     '\(orgName)'")
        debugPrint("   firstName:   '\(firstName)'")
        debugPrint("   lastName:    '\(lastName)'")
        debugPrint("   email:       '\(email)'")
        debugPrint("   phone:       '\(phone)'")
        debugPrint("   countryCode: '\(selectedCountry.code)'")   // should be "1"
        debugPrint("   country:     '\(selectedCountry.name)'")   // should be "United States"
        debugPrint("   gender:      '\(gender)'")
        debugPrint("   captcha:     '\(captchaToken.prefix(20))...'")
        debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
        // ──────────────────────────────────────────────────────────────

        // STEP 1: emailCheck (mirrors web handleCaptchaSubmit exactly)
        RegisterService.shared.emailCheck(email: email) { success, _, errMsg in
            DispatchQueue.main.async {
                guard success else {
                    self.isLoading = false
                    self.alertMsg  = errMsg
                    self.showAlert = true
                    return
                }
                debugPrint("✅ emailCheck passed")

                // STEP 2: checkPhoneNo
                RegisterService.shared.checkPhoneNo(
                    phone: self.phone,
                    countryCode: self.selectedCountry.code
                ) { success, _, errMsg in
                    DispatchQueue.main.async {
                        guard success else {
                            self.isLoading = false
                            self.alertMsg  = errMsg
                            self.showAlert = true
                            return
                        }
                        debugPrint("✅ checkPhoneNo passed")

                        // STEP 3: ValidateRegistration
//                        guard let brokerId = UserDefaults.standard.string(forKey: "brokerId"),
//                              !brokerId.isEmpty else {
//                            self.isLoading = false
//                            self.alertMsg = "Broker information is missing. Please select your broker again."
//                            self.showAlert = true
//
//                            debugPrint("❌ brokerId missing in UserDefaults")
//                            return
//                        }
                        let brokerId = UserDefaults.standard.string(forKey: "brokerId")
                            ?? "PAYB18022021121103"

                        debugPrint("📤 Register brokerId:", brokerId)
                        debugPrint("📤 Register brokerId:", brokerId)
                        RegisterService.shared.validateRegistration(
                            orgName:        self.orgName,
                            firstName:      self.firstName,
                            lastName:       self.lastName,
                            email:          self.email,
                            password:       self.password,
                            retypePassword: self.retypePassword,
                            phone:          self.phone,
                            countryCode:    self.selectedCountry.code, // "1"
                            gender:         self.gender,
                            country:        self.selectedCountry.name, // ✅ "United States" not "us"
                            captchaToken:   self.captchaToken,
                            brokerId: brokerId
                        ) { success, json, errMsg in
                            DispatchQueue.main.async {
                                guard success else {
                                    self.isLoading = false
                                    self.alertMsg  = errMsg
                                    self.showAlert = true
                                    return
                                }
                                debugPrint("✅ ValidateRegistration passed")

                                let tempId = json["temp_merchant_id"].stringValue
                                debugPrint("   tempId: '\(tempId)'")

                                UserDefaults.standard.set(tempId,              forKey: "BtempMerchantId")
                                UserDefaults.standard.set(self.email,          forKey: "Bemail")
                                UserDefaults.standard.set(self.firstName,      forKey: "Bfirst_name")
                                UserDefaults.standard.set(self.lastName,       forKey: "Blast_name")
                                UserDefaults.standard.set(self.orgName,        forKey: "BorgName")
                                UserDefaults.standard.set(self.phone,          forKey: "BuserPhone")
                                UserDefaults.standard.set(self.selectedCountry.code, forKey: "BdialCode")
                                UserDefaults.standard.set(self.selectedCountry.name, forKey: "Bcountry")
                                UserDefaults.standard.set(self.gender,         forKey: "Bgender")

                                // STEP 4: sendEmailOtp — fire and forget (web doesn't await)
                                RegisterService.shared.sendEmailOtp(
                                    email: self.email,
                                    tempMerchantId: tempId
                                ) { _, _, _ in }

                                // STEP 5: navigate to OTP
                                self.isLoading = false
                                self.showOTP   = true
                            }
                        }
                    }
                }
            }
        }
    }

    private func sendSignUpOTP(tempId: String) {
        RegisterService.shared.sendEmailOtp(email: email, tempMerchantId: tempId) { _, _, _ in
            DispatchQueue.main.async {
                self.isLoading = false
                self.showOTP   = true
            }
        }
    }

    private func checkEmailAPI() {
        RegisterService.shared.emailCheck(email: email) { success, _, errMsg in
            DispatchQueue.main.async {
                if !success { self.emailError = errMsg }
            }
        }
    }

    private func checkPhoneAPI() {
        guard !phone.isEmpty else { return }
        RegisterService.shared.checkPhoneNo(
            phone: phone,
            countryCode: selectedCountry.code
        ) { success, _, errMsg in
            DispatchQueue.main.async {
                if !success { self.phoneError = errMsg }
            }
        }
    }
}

// MARK: - RegField
// FIX: Added `wasFocused` flag so validation only fires after the user
//      has actually focused (and then left) the field — never on first render.

private struct RegField: View {
    let label:       String
    let placeholder: String
    @Binding var text: String
    var error:       String
    var field:       RegFocus
    @FocusState.Binding var focusedField: RegFocus?
    var keyboard:    UIKeyboardType = .default
    var onBlur:      () -> Void = {}

    // ── FIX: track whether this field was ever focused ─────────────
    @State private var wasFocused = false

    private let purple      = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let inputBG     = Color.black
    private let inputBorder = Color.gray.opacity(0.45)
    var isFocused: Bool { focusedField == field }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.caption).foregroundColor(.gray)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(inputBG)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                !error.isEmpty
                                    ? Color.red.opacity(0.70)
                                    : isFocused ? purple : inputBorder,
                                lineWidth: 1.5
                            )
                    )

                TextField("", text: $text,
                          prompt: Text(placeholder).foregroundColor(.gray))
                    .keyboardType(keyboard)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .foregroundColor(.white)
                    .focused($focusedField, equals: field)
                    .padding()
                    .onSubmit {
                        // Submit always validates (user explicitly confirmed)
                        onBlur()
                    }
                    .onChange(of: focusedField) { f in
                        if f == field {
                            // Field just gained focus — mark touched
                            wasFocused = true
                        } else if wasFocused && !text.isEmpty {
                            // Field lost focus after being touched AND has content
                            onBlur()
                        }
                    }
            }
            .frame(height: 50)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = field }

            if !error.isEmpty {
                Text(error)
                    .font(.system(size: 11)).foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.18), value: error.isEmpty)
    }
}

// MARK: - Dark Nav Bar Modifier

private struct DarkNavBarModifier: ViewModifier {
    let bg: Color
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarColorScheme(.dark, for: .navigationBar)
                .toolbarBackground(bg, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
        } else {
            content
                .onAppear    { applyLegacy(bg: UIColor(bg)) }
                .onDisappear { resetLegacy() }
        }
    }
    private func applyLegacy(bg: UIColor) {
        let a = UINavigationBarAppearance()
        a.configureWithOpaqueBackground(); a.backgroundColor = bg
        a.titleTextAttributes      = [.foregroundColor: UIColor.white]
        a.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance   = a
        UINavigationBar.appearance().scrollEdgeAppearance = a
        UINavigationBar.appearance().compactAppearance    = a
        UINavigationBar.appearance().tintColor            = .white
    }
    private func resetLegacy() {
        let a = UINavigationBarAppearance()
        a.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance   = a
        UINavigationBar.appearance().scrollEdgeAppearance = a
        UINavigationBar.appearance().compactAppearance    = a
        UINavigationBar.appearance().tintColor            = nil
    }
}

// MARK: - Country Picker Sheet

private struct CountryPickerView: View {
    let countries: [Country]
    @Binding var selected:    Country
    @Binding var isPresented: Bool

    @State private var searchText = ""

    private let darkBG     = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let rowBG      = Color.black
    private let borderGrey = Color.gray.opacity(0.35)
    private let purple     = Color(red: 0.45, green: 0.35, blue: 0.90)

    private var filtered: [Country] {
        if searchText.isEmpty { return countries }
        let q = searchText.lowercased()
        return countries.filter {
            $0.name.lowercased().contains(q) ||
            $0.code.contains(q) ||
            $0.iso.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                darkBG.ignoresSafeArea()
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
                        TextField("", text: $searchText,
                                  prompt: Text("Search country or code").foregroundColor(.gray))
                            .foregroundColor(.white)
                            .autocorrectionDisabled().textInputAutocapitalization(.never)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 14).frame(height: 46)
                    .background(
                        RoundedRectangle(cornerRadius: 10).fill(rowBG)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(borderGrey, lineWidth: 1.2))
                    )
                    .padding(.horizontal, 16).padding(.top, 8)

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 8) {
                            ForEach(filtered) { country in
                                Button(action: {
                                    selected     = country
                                    isPresented  = false
                                }) {
                                    HStack(spacing: 12) {
                                        Text(country.flag).font(.system(size: 22))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(country.name)
                                                .font(.system(size: 15, weight: .medium))
                                                .foregroundColor(.white)
                                            Text("+\(country.code)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.55))
                                        }
                                        Spacer()
                                        if country == selected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(purple)
                                        }
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10).fill(rowBG)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(
                                                        country == selected ? purple : borderGrey,
                                                        lineWidth: 1.2
                                                    )
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            if filtered.isEmpty {
                                Text("No country found")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.55))
                                    .padding(.top, 40)
                            }
                        }
                        .padding(.horizontal, 16).padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Select Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { isPresented = false }.foregroundColor(purple)
                }
            }
            .modifier(DarkNavBarModifier(bg: darkBG))
        }
    }
}

// MARK: - Preview

#Preview { RegisterView() }






























//
////  RegisterView.swift
////  Trading_Terminal
//
//import SwiftUI
//
//// MARK: - Validation helpers
//
//private func isValidEmail(_ s: String) -> Bool {
//    NSPredicate(format: "SELF MATCHES %@",
//        "^[a-zA-Z0-9._%+-]{1,30}@[a-zA-Z0-9-]{1,30}\\.[a-zA-Z]{2,}$").evaluate(with: s)
//}
//private func isValidPassword(_ s: String) -> Bool {
//    NSPredicate(format: "SELF MATCHES %@",
//        "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@.$!])[A-Za-z\\d@.$!]{8,35}$").evaluate(with: s)
//}
//private func isValidFirstName(_ s: String) -> Bool {
//    NSPredicate(format: "SELF MATCHES %@", "^[a-zA-Z]{2,20}$").evaluate(with: s)
//}
//private func isValidLastName(_ s: String) -> Bool {
//    NSPredicate(format: "SELF MATCHES %@",
//        "^[a-zA-Z-]{2,20}( [a-zA-Z-]{2,20})?$").evaluate(with: s)
//}
//private func isValidOrgName(_ s: String) -> Bool {
//    NSPredicate(format: "SELF MATCHES %@", "^[A-Za-z0-9 \\-\\.]+$").evaluate(with: s)
//}
//
//// MARK: - Country Model
//
//struct Country: Identifiable, Hashable {
//    let id   = UUID()
//    let name: String
//    let code: String
//    let iso:  String
//    let flag: String
//}
//
//private let allCountries: [Country] = [
//    Country(name: "United States",  code: "1",   iso: "us", flag: "🇺🇸"),
//    Country(name: "India",          code: "91",  iso: "in", flag: "🇮🇳"),
//    Country(name: "United Kingdom", code: "44",  iso: "gb", flag: "🇬🇧"),
//    Country(name: "Canada",         code: "1",   iso: "ca", flag: "🇨🇦"),
//    Country(name: "Australia",      code: "61",  iso: "au", flag: "🇦🇺"),
//    Country(name: "Germany",        code: "49",  iso: "de", flag: "🇩🇪"),
//    Country(name: "France",         code: "33",  iso: "fr", flag: "🇫🇷"),
//    Country(name: "Italy",          code: "39",  iso: "it", flag: "🇮🇹"),
//    Country(name: "Spain",          code: "34",  iso: "es", flag: "🇪🇸"),
//    Country(name: "Netherlands",    code: "31",  iso: "nl", flag: "🇳🇱"),
//    Country(name: "Belgium",        code: "32",  iso: "be", flag: "🇧🇪"),
//    Country(name: "Switzerland",    code: "41",  iso: "ch", flag: "🇨🇭"),
//    Country(name: "Austria",        code: "43",  iso: "at", flag: "🇦🇹"),
//    Country(name: "Sweden",         code: "46",  iso: "se", flag: "🇸🇪"),
//    Country(name: "Norway",         code: "47",  iso: "no", flag: "🇳🇴"),
//    Country(name: "Denmark",        code: "45",  iso: "dk", flag: "🇩🇰"),
//    Country(name: "Finland",        code: "358", iso: "fi", flag: "🇫🇮"),
//    Country(name: "Ireland",        code: "353", iso: "ie", flag: "🇮🇪"),
//    Country(name: "Portugal",       code: "351", iso: "pt", flag: "🇵🇹"),
//    Country(name: "Greece",         code: "30",  iso: "gr", flag: "🇬🇷"),
//    Country(name: "Poland",         code: "48",  iso: "pl", flag: "🇵🇱"),
//    Country(name: "Russia",         code: "7",   iso: "ru", flag: "🇷🇺"),
//    Country(name: "Turkey",         code: "90",  iso: "tr", flag: "🇹🇷"),
//    Country(name: "China",          code: "86",  iso: "cn", flag: "🇨🇳"),
//    Country(name: "Japan",          code: "81",  iso: "jp", flag: "🇯🇵"),
//    Country(name: "South Korea",    code: "82",  iso: "kr", flag: "🇰🇷"),
//    Country(name: "Singapore",      code: "65",  iso: "sg", flag: "🇸🇬"),
//    Country(name: "Malaysia",       code: "60",  iso: "my", flag: "🇲🇾"),
//    Country(name: "Indonesia",      code: "62",  iso: "id", flag: "🇮🇩"),
//    Country(name: "Thailand",       code: "66",  iso: "th", flag: "🇹🇭"),
//    Country(name: "Vietnam",        code: "84",  iso: "vn", flag: "🇻🇳"),
//    Country(name: "Philippines",    code: "63",  iso: "ph", flag: "🇵🇭"),
//    Country(name: "Hong Kong",      code: "852", iso: "hk", flag: "🇭🇰"),
//    Country(name: "Taiwan",         code: "886", iso: "tw", flag: "🇹🇼"),
//    Country(name: "Pakistan",       code: "92",  iso: "pk", flag: "🇵🇰"),
//    Country(name: "Bangladesh",     code: "880", iso: "bd", flag: "🇧🇩"),
//    Country(name: "Sri Lanka",      code: "94",  iso: "lk", flag: "🇱🇰"),
//    Country(name: "Nepal",          code: "977", iso: "np", flag: "🇳🇵"),
//    Country(name: "UAE",            code: "971", iso: "ae", flag: "🇦🇪"),
//    Country(name: "Saudi Arabia",   code: "966", iso: "sa", flag: "🇸🇦"),
//    Country(name: "Qatar",          code: "974", iso: "qa", flag: "🇶🇦"),
//    Country(name: "Kuwait",         code: "965", iso: "kw", flag: "🇰🇼"),
//    Country(name: "Bahrain",        code: "973", iso: "bh", flag: "🇧🇭"),
//    Country(name: "Oman",           code: "968", iso: "om", flag: "🇴🇲"),
//    Country(name: "Israel",         code: "972", iso: "il", flag: "🇮🇱"),
//    Country(name: "Egypt",          code: "20",  iso: "eg", flag: "🇪🇬"),
//    Country(name: "South Africa",   code: "27",  iso: "za", flag: "🇿🇦"),
//    Country(name: "Nigeria",        code: "234", iso: "ng", flag: "🇳🇬"),
//    Country(name: "Kenya",          code: "254", iso: "ke", flag: "🇰🇪"),
//    Country(name: "Brazil",         code: "55",  iso: "br", flag: "🇧🇷"),
//    Country(name: "Argentina",      code: "54",  iso: "ar", flag: "🇦🇷"),
//    Country(name: "Mexico",         code: "52",  iso: "mx", flag: "🇲🇽"),
//    Country(name: "Chile",          code: "56",  iso: "cl", flag: "🇨🇱"),
//    Country(name: "Colombia",       code: "57",  iso: "co", flag: "🇨🇴"),
//    Country(name: "Peru",           code: "51",  iso: "pe", flag: "🇵🇪"),
//    Country(name: "New Zealand",    code: "64",  iso: "nz", flag: "🇳🇿"),
//    Country(name: "Ukraine",        code: "380", iso: "ua", flag: "🇺🇦"),
//    Country(name: "Czech Republic", code: "420", iso: "cz", flag: "🇨🇿"),
//    Country(name: "Romania",        code: "40",  iso: "ro", flag: "🇷🇴"),
//    Country(name: "Hungary",        code: "36",  iso: "hu", flag: "🇭🇺")
//]
//
//// MARK: - Focus Fields
//
//private enum RegFocus: Hashable {
//    case org, firstName, lastName, email, phone, password, retypePassword
//}
//
//// MARK: - RegisterView
//
//struct RegisterView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    // Form fields
//    @State private var orgName         = ""
//    @State private var gender          = ""
//    @State private var firstName       = ""
//    @State private var lastName        = ""
//    @State private var email           = ""
//    @State private var phone           = ""
//    @State private var selectedCountry = allCountries[0]
//    @State private var password        = ""
//    @State private var retypePassword  = ""
//    @State private var isTermsAccepted = false
//
//    // Validation errors
//    @State private var orgError   = ""
//    @State private var firstError = ""
//    @State private var lastError  = ""
//    @State private var emailError = ""
//    @State private var phoneError = ""
//    @State private var pwdError   = ""
//    @State private var rePwdError = ""
//
//    // Captcha result — single JWT token from /solve
//    @State private var captchaToken = ""
//
//    // UI state
//    @State private var showPassword      = false
//    @State private var showRePwd         = false
//    @State private var isLoading         = false
//    @State private var alertMsg          = ""
//    @State private var showAlert         = false
//    @State private var showCaptcha       = false
//    @State private var showOTP           = false
//    @State private var showCountryPicker = false
//
//    @FocusState private var focusedField: RegFocus?
//
//    private let genders     = [("Male","Mr."), ("Female","Mrs."), ("Other","Other")]
//    private let purple      = Color(red: 0.45, green: 0.35, blue: 0.90)
//    private let inputBG     = Color.black
//    private let inputBorder = Color.gray.opacity(0.45)
//    private let darkBG      = Color(red: 0.08, green: 0.10, blue: 0.16)
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                darkBG.ignoresSafeArea()
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 20) {
//                        pageTitle
//                        orgField
//                        genderPicker
//                        nameRow
//                        emailField
//                        phoneField
//                        passwordField
//                        retypePasswordField
//                        termsRow
//                        submitButton
//                        loginLink
//                    }
//                    .padding(20)
//                    .padding(.bottom, 40)
//                }
//                if isLoading { loadingOverlay }
//            }
//            .navigationBarHidden(true)
//        }
//        // ── Captcha sheet ────────────────────────────────────────────
//        .sheet(isPresented: $showCaptcha) {
//            LoginCaptchaView(
//                onVerified: { token in          // ← single JWT token
//                    captchaToken = token
//                    showCaptcha  = false
//                    proceedRegistration()
//                },
//                onCancel: {
//                    showCaptcha = false
//                }
//            )
//            .padding(20)
//            .background(Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea())
//        }
//        .sheet(isPresented: $showCountryPicker) {
//            CountryPickerView(
//                countries: allCountries,
//                selected: $selectedCountry,
//                isPresented: $showCountryPicker
//            )
//        }
//        .fullScreenCover(isPresented: $showOTP) {
//            SignUpOTPView(
//                email: email,
//                phone: phone,
//                onSuccess: {},
//                firstName: firstName,
//                lastName: lastName,
//                password: password,
//                orgName: orgName,
//                country: selectedCountry.name,
//                countryCode: selectedCountry.code,
//                gender: gender
//            )
//        }
//        .alert("Error", isPresented: $showAlert) {
//            Button("OK", role: .cancel) {}
//        } message: { Text(alertMsg) }
//    }
//
//    // MARK: - Page title
//
//    private var pageTitle: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("Create Account")
//                .font(.system(size: 28, weight: .bold)).foregroundColor(.white)
//            Text("Fill in your details to get started")
//                .font(.system(size: 14)).foregroundColor(.white.opacity(0.55))
//        }
//        .padding(.top, 20)
//    }
//
//    // MARK: - Organisation Name
//
//    private var orgField: some View {
//        RegField(
//            label: "Organization Name *",
//            placeholder: "Enter organization name",
//            text: $orgName,
//            error: orgError,
//            field: .org,
//            focusedField: $focusedField
//        ) {
//            orgError = isValidOrgName(orgName) ? "" : "Enter a valid organization name"
//        }
//    }
//
//    // MARK: - Gender picker
//
//    private var genderPicker: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Gender").font(.caption).foregroundColor(.gray)
//            HStack(spacing: 10) {
//                ForEach(genders, id: \.0) { (val, label) in
//                    Button(action: { gender = val }) {
//                        Text(label)
//                            .font(.system(size: 14, weight: gender == val ? .bold : .medium))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity).frame(height: 44)
//                            .background(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .fill(gender == val ? purple : Color.black)
//                            )
//                            .overlay {
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(
//                                        gender == val ? purple : Color.gray.opacity(0.45),
//                                        lineWidth: 1.5
//                                    )
//                            }
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//        }
//    }
//
//    // MARK: - Name row
//
//    private var nameRow: some View {
//        HStack(spacing: 12) {
//            RegField(
//                label: "First Name *", placeholder: "First Name",
//                text: $firstName, error: firstError,
//                field: .firstName, focusedField: $focusedField
//            ) {
//                firstError = isValidFirstName(firstName) ? "" : "2–20 letters only"
//            }
//            RegField(
//                label: "Last Name *", placeholder: "Last Name",
//                text: $lastName, error: lastError,
//                field: .lastName, focusedField: $focusedField
//            ) {
//                lastError = isValidLastName(lastName) ? "" : "2–20 letters only"
//            }
//        }
//    }
//
//    // MARK: - Email
//
//    private var emailField: some View {
//        RegField(
//            label: "Email Address *", placeholder: "email@example.com",
//            text: $email, error: emailError,
//            field: .email, focusedField: $focusedField,
//            keyboard: .emailAddress
//        ) {
//            emailError = isValidEmail(email) ? "" : "Enter a valid email"
//            if emailError.isEmpty && !email.isEmpty { checkEmailAPI() }
//        }
//    }
//
//    // MARK: - Phone
//
//    private var phoneField: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("Phone Number *").font(.caption).foregroundColor(.gray)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(inputBG)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(
//                                !phoneError.isEmpty
//                                    ? Color.red.opacity(0.70)
//                                    : focusedField == .phone ? purple : inputBorder,
//                                lineWidth: 1.5
//                            )
//                    )
//
//                HStack(spacing: 0) {
//                    Button(action: { showCountryPicker = true }) {
//                        HStack(spacing: 4) {
//                            Text(selectedCountry.flag).font(.system(size: 16))
//                            Text("+\(selectedCountry.code)")
//                                .font(.system(size: 13)).foregroundColor(.white)
//                            Image(systemName: "chevron.down")
//                                .font(.system(size: 10)).foregroundColor(.gray)
//                        }
//                        .padding(.leading, 12)
//                    }
//                    .buttonStyle(.plain)
//
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.35))
//                        .frame(width: 1, height: 24)
//                        .padding(.horizontal, 8)
//
//                    TextField("", text: $phone,
//                              prompt: Text("Phone number").foregroundColor(.gray))
//                        .keyboardType(.phonePad)
//                        .foregroundColor(.white)
//                        .focused($focusedField, equals: .phone)
//                        .onSubmit {
//                            phoneError = phone.count >= 7 ? "" : "Enter a valid phone number"
//                            if phoneError.isEmpty { checkPhoneAPI() }
//                        }
//                        .onChange(of: focusedField) { f in
//                            if f != .phone && !phone.isEmpty {
//                                phoneError = phone.count >= 7 ? "" : "Enter a valid phone number"
//                                if phoneError.isEmpty { checkPhoneAPI() }
//                            }
//                        }
//                    Spacer()
//                }
//            }
//            .frame(height: 50)
//            .contentShape(Rectangle())
//            .onTapGesture { focusedField = .phone }
//
//            if !phoneError.isEmpty {
//                Text(phoneError)
//                    .font(.system(size: 11)).foregroundColor(.red)
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//        .animation(.easeInOut(duration: 0.18), value: phoneError.isEmpty)
//    }
//
//    // MARK: - Password
//
//    private var passwordField: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("Password *").font(.caption).foregroundColor(.gray)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(inputBG)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(
//                                !pwdError.isEmpty
//                                    ? Color.red.opacity(0.70)
//                                    : focusedField == .password ? purple : inputBorder,
//                                lineWidth: 1.5
//                            )
//                    )
//                HStack {
//                    Group {
//                        if showPassword {
//                            TextField("", text: $password,
//                                      prompt: Text("Enter your password").foregroundColor(.gray))
//                                .focused($focusedField, equals: .password)
//                        } else {
//                            SecureField("", text: $password,
//                                        prompt: Text("Enter your password").foregroundColor(.gray))
//                                .focused($focusedField, equals: .password)
//                        }
//                    }
//                    .autocapitalization(.none).autocorrectionDisabled()
//                    .foregroundColor(.white)
//                    .onChange(of: password) { _ in
//                        if !password.isEmpty {
//                            pwdError = isValidPassword(password) ? "" :
//                                "Min 8 chars, uppercase, lowercase, digit & special char (@ . $ !)"
//                        }
//                    }
//                    Button { showPassword.toggle() } label: {
//                        Image(systemName: showPassword ? "eye.slash" : "eye")
//                            .foregroundColor(.gray)
//                    }
//                }
//                .padding()
//            }
//            .frame(height: 50)
//            .contentShape(Rectangle())
//            .onTapGesture { focusedField = .password }
//
//            if !pwdError.isEmpty {
//                Text(pwdError)
//                    .font(.system(size: 11)).foregroundColor(.red)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//        .animation(.easeInOut(duration: 0.18), value: pwdError.isEmpty)
//    }
//
//    // MARK: - Confirm Password
//
//    private var retypePasswordField: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text("Confirm Password *").font(.caption).foregroundColor(.gray)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(inputBG)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(
//                                !rePwdError.isEmpty
//                                    ? Color.red.opacity(0.70)
//                                    : !retypePassword.isEmpty && retypePassword == password
//                                        ? Color.green.opacity(0.60)
//                                        : focusedField == .retypePassword ? purple : inputBorder,
//                                lineWidth: 1.5
//                            )
//                    )
//                HStack {
//                    Group {
//                        if showRePwd {
//                            TextField("", text: $retypePassword,
//                                      prompt: Text("Re-enter password").foregroundColor(.gray))
//                                .focused($focusedField, equals: .retypePassword)
//                        } else {
//                            SecureField("", text: $retypePassword,
//                                        prompt: Text("Re-enter password").foregroundColor(.gray))
//                                .focused($focusedField, equals: .retypePassword)
//                        }
//                    }
//                    .autocapitalization(.none).autocorrectionDisabled()
//                    .foregroundColor(.white)
//                    .onChange(of: retypePassword) { _ in
//                        if retypePassword.isEmpty { rePwdError = "" }
//                        else {
//                            rePwdError = retypePassword == password ? "" : "Passwords do not match"
//                        }
//                    }
//                    Button { showRePwd.toggle() } label: {
//                        Image(systemName: showRePwd ? "eye.slash" : "eye")
//                            .foregroundColor(.gray)
//                    }
//                }
//                .padding()
//            }
//            .frame(height: 50)
//            .contentShape(Rectangle())
//            .onTapGesture { focusedField = .retypePassword }
//
//            if !rePwdError.isEmpty {
//                Text(rePwdError)
//                    .font(.system(size: 11)).foregroundColor(.red)
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//            } else if !retypePassword.isEmpty && retypePassword == password {
//                Text("Password matched ✓")
//                    .font(.system(size: 11)).foregroundColor(.green)
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//        .animation(.easeInOut(duration: 0.18), value: rePwdError.isEmpty)
//    }
//
//    // MARK: - Terms
//
//    private var termsRow: some View {
//        HStack(alignment: .top, spacing: 10) {
//            Button(action: { isTermsAccepted.toggle() }) {
//                Image(systemName: isTermsAccepted ? "checkmark.square.fill" : "square")
//                    .font(.system(size: 20)).foregroundColor(purple)
//            }
//            .buttonStyle(.plain)
//            (Text("I read and accept the ").foregroundColor(.white.opacity(0.65))
//             + Text("Terms & Privacy Policy").foregroundColor(purple))
//                .font(.system(size: 13))
//        }
//    }
//
//    // MARK: - Submit button
//
//    private var submitButton: some View {
//        Button(action: handleSubmit) {
//            ZStack {
//                if isLoading { ProgressView().tint(.white) }
//                else {
//                    Text("Sign Up")
//                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
//                }
//            }
//            .frame(maxWidth: .infinity).frame(height: 52)
//            .background(
//                LinearGradient(
//                    colors: [Color(red: 0.62, green: 0.36, blue: 0.96),
//                             Color(red: 0.36, green: 0.49, blue: 0.96)],
//                    startPoint: .leading, endPoint: .trailing
//                )
//            )
//            .cornerRadius(12)
//            .opacity(canSubmit ? 1.0 : 0.5)
//        }
//        .disabled(!canSubmit || isLoading)
//        .buttonStyle(.plain)
//    }
//
//    // MARK: - Login link
//
//    private var loginLink: some View {
//        HStack {
//            Spacer()
//            Button(action: { dismiss() }) {
//                Text("Already a member? ").foregroundColor(.white.opacity(0.55))
//                + Text("Sign In").foregroundColor(purple).bold()
//            }
//            .font(.system(size: 13)).buttonStyle(.plain)
//            Spacer()
//        }
//        .padding(.bottom, 20)
//    }
//
//    // MARK: - Loading overlay
//
//    private var loadingOverlay: some View {
//        ZStack {
//            Color.black.opacity(0.4).ignoresSafeArea()
//            VStack(spacing: 12) {
//                ProgressView().scaleEffect(1.4).tint(.white)
//                Text("Please wait…").font(.subheadline).foregroundColor(.white)
//            }
//            .padding(24)
//            .background(Color.white.opacity(0.10))
//            .cornerRadius(16)
//        }
//    }
//
//    // MARK: - Validation gate
//
//    private var canSubmit: Bool {
//        !orgName.isEmpty && !firstName.isEmpty && !lastName.isEmpty &&
//        !email.isEmpty && !phone.isEmpty && !password.isEmpty &&
//        !retypePassword.isEmpty && isTermsAccepted &&
//        orgError.isEmpty && firstError.isEmpty && lastError.isEmpty &&
//        emailError.isEmpty && phoneError.isEmpty &&
//        pwdError.isEmpty && rePwdError.isEmpty &&
//        password == retypePassword
//    }
//
//    // MARK: - Flow
//
//    private func handleSubmit() {
//        guard canSubmit else {
//            alertMsg = "Please provide valid details & select terms & conditions"
//            showAlert = true
//            return
//        }
//        captchaToken = ""
//        showCaptcha  = true
//    }
//
//    private func proceedRegistration() {
//        guard !captchaToken.isEmpty else {
//            alertMsg = "Captcha verification failed. Please try again."
//            showAlert = true
//            return
//        }
//
//        isLoading = true
//        RegisterService.shared.validateRegistration(
//            orgName:        orgName,
//            firstName:      firstName,
//            lastName:       lastName,
//            email:          email,
//            password:       password,
//            retypePassword: retypePassword,
//            phone:          phone,
//            countryCode:    selectedCountry.code,
//            gender:         gender,
//            country:        selectedCountry.iso,
//            captchaToken:   captchaToken
//        ) { success, json, errMsg in
//            DispatchQueue.main.async {
//                if success {
//                    let tempId = json["temp_merchant_id"].stringValue
//                    UserDefaults.standard.set(tempId,         forKey: "BtempMerchantId")
//                    UserDefaults.standard.set(self.email,     forKey: "Bemail")
//                    UserDefaults.standard.set(self.firstName, forKey: "Bfirst_name")
//                    UserDefaults.standard.set(self.lastName,  forKey: "Blast_name")
//                    UserDefaults.standard.set(self.orgName,   forKey: "BorgName")
//                    UserDefaults.standard.set(self.phone,     forKey: "BuserPhone")
//                    self.sendSignUpOTP(tempId: tempId)
//                } else {
//                    self.isLoading = false
//                    self.alertMsg  = errMsg
//                    self.showAlert = true
//                }
//            }
//        }
//    }
//
//    private func sendSignUpOTP(tempId: String) {
//        RegisterService.shared.sendEmailOtp(email: email, tempMerchantId: tempId) { _, _, _ in
//            DispatchQueue.main.async {
//                self.isLoading = false
//                self.showOTP   = true
//            }
//        }
//    }
//
//    private func checkEmailAPI() {
//        RegisterService.shared.emailCheck(email: email) { success, _, errMsg in
//            DispatchQueue.main.async {
//                if !success { self.emailError = errMsg }
//            }
//        }
//    }
//
//    private func checkPhoneAPI() {
//        guard !phone.isEmpty else { return }
//        RegisterService.shared.checkPhoneNo(
//            phone: phone,
//            countryCode: selectedCountry.code
//        ) { success, _, errMsg in
//            DispatchQueue.main.async {
//                if !success { self.phoneError = errMsg }
//            }
//        }
//    }
//}
//
//// MARK: - RegField
//
//private struct RegField: View {
//    let label:       String
//    let placeholder: String
//    @Binding var text: String
//    var error:       String
//    var field:       RegFocus
//    @FocusState.Binding var focusedField: RegFocus?
//    var keyboard:    UIKeyboardType = .default
//    var onBlur:      () -> Void = {}
//
//    private let purple      = Color(red: 0.45, green: 0.35, blue: 0.90)
//    private let inputBG     = Color.black
//    private let inputBorder = Color.gray.opacity(0.45)
//    var isFocused: Bool { focusedField == field }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            Text(label).font(.caption).foregroundColor(.gray)
//
//            ZStack {
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(inputBG)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 10)
//                            .stroke(
//                                !error.isEmpty
//                                    ? Color.red.opacity(0.70)
//                                    : isFocused ? purple : inputBorder,
//                                lineWidth: 1.5
//                            )
//                    )
//
//                TextField("", text: $text,
//                          prompt: Text(placeholder).foregroundColor(.gray))
//                    .keyboardType(keyboard)
//                    .textInputAutocapitalization(.never)
//                    .autocorrectionDisabled(true)
//                    .foregroundColor(.white)
//                    .focused($focusedField, equals: field)
//                    .padding()
//                    .onSubmit { onBlur() }
//                    .onChange(of: focusedField) { f in
//                        if f != field { onBlur() }
//                    }
//            }
//            .frame(height: 50)
//            .contentShape(Rectangle())
//            .onTapGesture { focusedField = field }
//
//            if !error.isEmpty {
//                Text(error)
//                    .font(.system(size: 11)).foregroundColor(.red)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .transition(.opacity.combined(with: .move(edge: .top)))
//            }
//        }
//        .animation(.easeInOut(duration: 0.18), value: error.isEmpty)
//    }
//}
//
//// MARK: - Dark Nav Bar Modifier
//
//private struct DarkNavBarModifier: ViewModifier {
//    let bg: Color
//    func body(content: Content) -> some View {
//        if #available(iOS 16.0, *) {
//            content
//                .toolbarColorScheme(.dark, for: .navigationBar)
//                .toolbarBackground(bg, for: .navigationBar)
//                .toolbarBackground(.visible, for: .navigationBar)
//        } else {
//            content
//                .onAppear    { applyLegacy(bg: UIColor(bg)) }
//                .onDisappear { resetLegacy() }
//        }
//    }
//    private func applyLegacy(bg: UIColor) {
//        let a = UINavigationBarAppearance()
//        a.configureWithOpaqueBackground(); a.backgroundColor = bg
//        a.titleTextAttributes      = [.foregroundColor: UIColor.white]
//        a.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
//        UINavigationBar.appearance().standardAppearance   = a
//        UINavigationBar.appearance().scrollEdgeAppearance = a
//        UINavigationBar.appearance().compactAppearance    = a
//        UINavigationBar.appearance().tintColor            = .white
//    }
//    private func resetLegacy() {
//        let a = UINavigationBarAppearance()
//        a.configureWithDefaultBackground()
//        UINavigationBar.appearance().standardAppearance   = a
//        UINavigationBar.appearance().scrollEdgeAppearance = a
//        UINavigationBar.appearance().compactAppearance    = a
//        UINavigationBar.appearance().tintColor            = nil
//    }
//}
//
//// MARK: - Country Picker Sheet
//
//private struct CountryPickerView: View {
//    let countries: [Country]
//    @Binding var selected:    Country
//    @Binding var isPresented: Bool
//
//    @State private var searchText = ""
//
//    private let darkBG     = Color(red: 0.08, green: 0.10, blue: 0.16)
//    private let rowBG      = Color.black
//    private let borderGrey = Color.gray.opacity(0.35)
//    private let purple     = Color(red: 0.45, green: 0.35, blue: 0.90)
//
//    private var filtered: [Country] {
//        if searchText.isEmpty { return countries }
//        let q = searchText.lowercased()
//        return countries.filter {
//            $0.name.lowercased().contains(q) ||
//            $0.code.contains(q) ||
//            $0.iso.lowercased().contains(q)
//        }
//    }
//
//    var body: some View {
//        NavigationView {
//            ZStack {
//                darkBG.ignoresSafeArea()
//                VStack(spacing: 12) {
//                    HStack(spacing: 8) {
//                        Image(systemName: "magnifyingglass").foregroundColor(.gray)
//                        TextField("", text: $searchText,
//                                  prompt: Text("Search country or code").foregroundColor(.gray))
//                            .foregroundColor(.white)
//                            .autocorrectionDisabled().textInputAutocapitalization(.never)
//                        if !searchText.isEmpty {
//                            Button(action: { searchText = "" }) {
//                                Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
//                            }
//                            .buttonStyle(.plain)
//                        }
//                    }
//                    .padding(.horizontal, 14).frame(height: 46)
//                    .background(
//                        RoundedRectangle(cornerRadius: 10).fill(rowBG)
//                            .overlay(RoundedRectangle(cornerRadius: 10)
//                                .stroke(borderGrey, lineWidth: 1.2))
//                    )
//                    .padding(.horizontal, 16).padding(.top, 8)
//
//                    ScrollView(showsIndicators: false) {
//                        LazyVStack(spacing: 8) {
//                            ForEach(filtered) { country in
//                                Button(action: {
//                                    selected     = country
//                                    isPresented  = false
//                                }) {
//                                    HStack(spacing: 12) {
//                                        Text(country.flag).font(.system(size: 22))
//                                        VStack(alignment: .leading, spacing: 2) {
//                                            Text(country.name)
//                                                .font(.system(size: 15, weight: .medium))
//                                                .foregroundColor(.white)
//                                            Text("+\(country.code)")
//                                                .font(.system(size: 12))
//                                                .foregroundColor(.white.opacity(0.55))
//                                        }
//                                        Spacer()
//                                        if country == selected {
//                                            Image(systemName: "checkmark.circle.fill")
//                                                .foregroundColor(purple)
//                                        }
//                                    }
//                                    .padding(.horizontal, 14).padding(.vertical, 12)
//                                    .background(
//                                        RoundedRectangle(cornerRadius: 10).fill(rowBG)
//                                            .overlay(
//                                                RoundedRectangle(cornerRadius: 10)
//                                                    .stroke(
//                                                        country == selected ? purple : borderGrey,
//                                                        lineWidth: 1.2
//                                                    )
//                                            )
//                                    )
//                                }
//                                .buttonStyle(.plain)
//                            }
//                            if filtered.isEmpty {
//                                Text("No country found")
//                                    .font(.system(size: 14))
//                                    .foregroundColor(.white.opacity(0.55))
//                                    .padding(.top, 40)
//                            }
//                        }
//                        .padding(.horizontal, 16).padding(.bottom, 20)
//                    }
//                }
//            }
//            .navigationTitle("Select Country")
//            .navigationBarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button("Close") { isPresented = false }.foregroundColor(purple)
//                }
//            }
//            .modifier(DarkNavBarModifier(bg: darkBG))
//        }
//    }
//}
//
//// MARK: - Preview
//
//#Preview { RegisterView() }
