//
//  GetStartedView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 16/04/26.
//
//
//  GetStartedView.swift


import SwiftUI
import Alamofire
import SwiftyJSON

struct GetStartedView: View {
    // MARK: - State
    @StateObject private var viewModel = GetStartedViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToDashboard = false
    @State private var showEnterpriseKyc = false
    
    var cameFromDashboard = false
    
    // MARK: - Colors
    private let darkBG = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let cardBG = Color(red: 0.12, green: 0.15, blue: 0.22)
    private let accentGreen = Color(red: 0.15, green: 0.75, blue: 0.45)
    private let accentBlue = Color(red: 0.35, green: 0.40, blue: 0.95)
    private let dimGray = Color(red: 0.35, green: 0.38, blue: 0.45)
    
    var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
//                headerView
                
                Divider()
                    .background(Color.white.opacity(0.08))
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Welcome section
                        welcomeSection
                        
                        // Steps
                        stepsSection
                        
                        if viewModel.businessActivated {

                                  cardPaymentsSection

                              }
                    }
                    .padding(.top, 28)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchMerchantStatus()
            viewModel.loadCompanyInfo()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("refreshGetStarted"))) { _ in
            print("✅ refreshGetStarted received — calling fetchMerchantStatus")
            viewModel.fetchMerchantStatus()
        }
        .alert("Log Out", isPresented: $viewModel.showLogoutConfirmation) {
            Button("YES", role: .destructive) {
                viewModel.performLogout()
            }
            Button("NO", role: .cancel) {}
        } message: {
            Text("Do you want to sign out?")
        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.shouldNavigateToLogin {
                    // Handle navigation to login
                    viewModel.shouldNavigateToLogin = false
                }
            }
        } message: {
            Text(viewModel.alertMessage)
        }
       
        .fullScreenCover(isPresented: $viewModel.showBusinessActivation) {
            BusinessActivationView()
        }
        .fullScreenCover(isPresented: $navigateToDashboard) {
            BillBitcoinsContainerView()
        }
        .fullScreenCover(isPresented: $showEnterpriseKyc) {
            EnterpriseKycFormView()
        }
        
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack(spacing: 12) {
            // Logo
            AsyncImage(url: URL(string: BConstant.shared.appImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 40, height: 40)
            .cornerRadius(10)
            
            Spacer()
            
            // Toggle Pill
            pillToggle
            
            // Profile Button
//            Button(action: {
//                viewModel.showProfileSheet = true
//            })
//            {
//                Image(systemName: "person.circle.fill")
//                    .font(.system(size: 24))
//                    .foregroundColor(.white)
//            }
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
    
    private var pillToggle: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(viewModel.pillToggled ? Color(red: 0.15, green: 0.65, blue: 0.40) : Color(white: 0.18))
                .frame(width: 72, height: 32)
            
            // Indicator
            RoundedRectangle(cornerRadius: 12)
                .fill(accentBlue)
                .frame(width: 32, height: 28)
                .offset(x: viewModel.pillToggled ? 36 : 2)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.pillToggled)
            
            HStack(spacing: 8) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.pillToggled ? .white.opacity(0.5) : .white)
                
                Spacer()
                
                Image(systemName: "square.grid.2x2.fill")
                    .font(.system(size: 16))
                    .foregroundColor(viewModel.pillToggled ? .white : .white.opacity(0.5))
            }
            .padding(.horizontal, 8)
            .frame(width: 72)
        }
        .onTapGesture {
            viewModel.pillToggled = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                dismiss()
            }
        }
    }
    
    // MARK: - Welcome Section
    private var welcomeSection: some View {
        VStack(spacing: 6) {
            Text(viewModel.welcomeText)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text("Let's get you ready to accept payments.")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .padding(.top, 16)
            }
            
            Text(viewModel.statusText)
                .font(.system(size: 13))
                .foregroundColor(viewModel.allStepsComplete ? accentGreen : .white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Steps Section
    private var stepsSection: some View {
        VStack(spacing: 16) {
            // Step 1
            stepRow(
                step: 1,
                icon: "envelope.fill",
                title: "Email Confirmed",
                description: viewModel.step1Description,
                actionTitle: viewModel.step1ActionTitle,
                isComplete: viewModel.emailConfirmed,
                dotColor: viewModel.emailConfirmed ? accentGreen : accentBlue,
                dotText: viewModel.emailConfirmed ? "✓" : "1",
                isEnabled: true,
                showLine: true,
                action: {
                    viewModel.resendEmailConfirmation()
                }
            )
            
            // Step 2
            stepRow(
                step: 2,
                icon: "person.fill",
                title: "Business Activation",
                description: viewModel.step2Description,
                actionTitle: viewModel.step2ActionTitle,
                isComplete: viewModel.businessActivated,
                dotColor: viewModel.businessActivated ? accentGreen : accentBlue,
                dotText: viewModel.businessActivated ? "✓" : "2",
                isEnabled: true,
                showLine: true,
                action: {
                    viewModel.showBusinessActivation = true
                }
            )
            
            // Step 3
            stepRow(
                step: 3,
                icon: "building.columns.fill",
                title: "Create your first payment link",
                description: viewModel.step3Description,
                actionTitle: "Create",
                isComplete: viewModel.cryptoAdded,
                dotColor: viewModel.cryptoAdded ? accentGreen : (viewModel.businessActivated ? accentBlue : dimGray),
                dotText: viewModel.cryptoAdded ? "✓" : "3",
                isEnabled: viewModel.businessActivated,
                showLine: false,
                action: {
                    // Navigate to dashboard
                    print("Tapped")
                    navigateToDashboard = true
                }
            )
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Card Payments Section
    private var cardPaymentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 48, height: 48)
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Accepting Card Payments")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Enable secure credit and debit card processing for your business with a quick application.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                Spacer(minLength: 0)
            }
            
            // Bullet points
            VStack(alignment: .leading, spacing: 10) {
                cardPaymentBullet("Accept major card networks")
                cardPaymentBullet("Fast onboarding process")
                cardPaymentBullet("Secure & compliant payments")
            }
            
            Text("Application review typically takes 5–7 business days.")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.45))
            
            Button(action: {
                // TODO: navigate to card application flow
                showEnterpriseKyc = true
            }) {
                Text("Apply Now")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(accentBlue)
                    .cornerRadius(10)
            }
        }
        .padding(18)
        .background(cardBG)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private func cardPaymentBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(accentGreen)
                .padding(.top, 2)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))
        }
    }
    
    // MARK: - Step Row
    private func stepRow(
        step: Int,
        icon: String,
        title: String,
        description: String,
        actionTitle: String,
        isComplete: Bool,
        dotColor: Color,
        dotText: String,
        isEnabled: Bool,
        showLine: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center, spacing: 12) {
            // Dot and line container
            VStack(spacing: 4) {
                // Dot
                ZStack {
                    Circle()
                        .fill(dotColor)
                        .frame(width: 44, height: 44)
                    
                    Text(dotText)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Line
                if showLine {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 2)
                        .frame(minHeight: 60)
                }
            }
            
            // Card
            stepCard(
                icon: icon,
                title: title,
                description: description,
                actionTitle: actionTitle,
                isComplete: isComplete,
                isEnabled: isEnabled,
                action: action
            )
        }
    }
    
    // MARK: - Step Card
    private func stepCard(
        icon: String,
        title: String,
        description: String,
        actionTitle: String,
        isComplete: Bool,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 32))
                .foregroundColor(accentGreen)
                .frame(height: 32)
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(isComplete ? accentGreen : .white.opacity(0.6))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: action) {
                Text(isComplete ? "Completed ✓" : actionTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isComplete ? accentGreen : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        isComplete ? accentGreen.opacity(0.2) :
                        isEnabled ? accentBlue : dimGray
                    )
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(isComplete ? Color.clear : (isEnabled ? accentBlue : Color.clear), lineWidth: 1)
                    )
            }
            .disabled(!isEnabled || isComplete)
            .opacity(isEnabled || isComplete ? 1.0 : 0.4)
        }
        .padding(16)
        .background(cardBG)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isComplete ? accentGreen.opacity(0.5) : Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
//    // MARK: - Profile Sheet
//    private var profileActionSheet: some View {
//        VStack(spacing: 0) {
//            Button(action: {
//                viewModel.showProfileSheet = false
//                // Navigate to profile
//            }) {
//                Text("Profile")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//            }
//            
//            Divider()
//            
//            Button(role: .destructive, action: {
//                viewModel.showProfileSheet = false
//                viewModel.showLogoutConfirmation = true
//            }) {
//                Text("Log Out")
//                    .foregroundColor(.red)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//            }
//            
//            Divider()
//            
//            Button(action: {
//                viewModel.showProfileSheet = false
//            }) {
//                Text("Cancel")
//                    .frame(maxWidth: .infinity)
//                    .padding()
//            }
//        }
//        .background(Color(UIColor.systemBackground))
//        .cornerRadius(12)
//        .padding()
//        // MARK: - Sheet
//        .sheet(isPresented: $viewModel.showProfileSheet) {
//            if #available(iOS 16.0, *) {
//                profileActionSheet
//                    .presentationDetents([.height(200)])
//            } else {
//                profileActionSheet
//            }
//        }
//    }
}

// MARK: - View Model
class GetStartedViewModel: ObservableObject {
    @Published var emailConfirmed = false
    @Published var businessActivated = false
    @Published var cryptoAdded = false
    @Published var isLoading = false
    @Published var statusText = ""
    @Published var welcomeText = "Welcome to Paybito,"
    @Published var pillToggled = false
    
    @Published var showProfileSheet = false
    @Published var showLogoutConfirmation = false
    @Published var showBusinessActivation = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var shouldNavigateToLogin = false
    
    var step1Description: String {
        emailConfirmed ? "Nice, your email address has been confirmed." : "Your email address is not confirmed yet."
    }
    
    var step1ActionTitle: String {
        emailConfirmed ? "Completed ✓" : "Resend Email"
    }
    
    var step2Description: String {
        businessActivated ? "Your business has been verified. You can edit your details." : "Verify your business to activate live processing."
    }
    
    var step2ActionTitle: String {
        businessActivated ? "Completed ✓" : "Activate"
    }
    
    var step3Description: String {
        cryptoAdded ? "Crypto address added. You are ready to accept payments!" : "Start accepting payments."
    }
    
    var allStepsComplete: Bool {
        emailConfirmed && businessActivated && cryptoAdded
    }
    
    func loadCompanyInfo() {
        let company = UserDefaults.standard.string(forKey: "companyName") ?? BConstant.shared.appTitle
        welcomeText = "Welcome to \(company),"
    }
    
    // MARK: - API Calls
    func fetchMerchantStatus() {
        isLoading = true
        guard let token = UserDefaults.standard.string(forKey: "Baccess_token"),
              let uuid = UserDefaults.standard.string(forKey: "Buuid"),
              !token.isEmpty, !uuid.isEmpty else {

            DispatchQueue.main.async {
                self.alertTitle = appName
                self.alertMessage = "Session missing. Please login again."
                self.shouldNavigateToLogin = true
                self.showAlert = true
            }
            return
        }
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Origin": "https://trade.paybito.com",
            "Authorization": "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? ""),
            "UUID": UserDefaults.standard.string(forKey: "Buuid") ?? ""
        ]
        let params: [String: Any] = ["merchant_id": Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0]
        
        Alamofire.request(bbaseurlLive + "FetchMerchantStatus", method: .post,
                          parameters: params, encoding: JSONEncoding.default, headers: header)
            .responseJSON { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                
                if response.result.isSuccess, let value = response.result.value {
                    let json = JSON(value)
                    for val in json.arrayValue {
                        if val["error"].intValue == 0 {
                            DispatchQueue.main.async {
                                self.emailConfirmed = val["email_confirmed"].intValue == 1
                                self.businessActivated = val["basic_verification_submitted"].intValue == 1
                                self.cryptoAdded = val["crypto_address_added"].intValue == 1
                                UserDefaults.standard.set(val["basic_verification_submitted"].intValue,
                                                          forKey: "Bbasic_verification_submitted")
                                self.updateStatusText()
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showAlertWithMessage(title: appName, message: val["error_msg"].stringValue)
                            }
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertTitle = appName
                        self.alertMessage = "Session timeout."
                        self.shouldNavigateToLogin = true
                        self.showAlert = true
                    }
                }
            }
    }
    
    func resendEmailConfirmation() {
        isLoading = true
        
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Origin": "https://portal.paybito.com",
            "Authorization": "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? ""),
            "UUID": UserDefaults.standard.string(forKey: "Buuid") ?? ""
        ]
        let params: [String: Any] = ["merchant_id": Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0]
        
        Alamofire.request(bbaseurlLive + "ResendEmailConfirm", method: .post,
                          parameters: params, encoding: JSONEncoding.default, headers: header)
            .responseJSON { [weak self] response in
                guard let self = self else { return }
                self.isLoading = false
                
                if let value = response.result.value {
                    let json = JSON(value)
                    for val in json.arrayValue {
                        let msg = val["error_msg"].stringValue
                        DispatchQueue.main.async {
                            self.showAlertWithMessage(title: appName, message: msg)
                        }
                    }
                }
            }
    }
    
    func performLogout() {
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? ""),
            "UUID": UserDefaults.standard.string(forKey: "Buuid") ?? ""
        ]
        let params: [String: Any] = ["merchant_id": Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0]
        
        Alamofire.request(bbaseurlLive + "LogoutMerchant", method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: header).responseJSON { _ in }
        
        // Clear stored data
        ["Blogin", "Bbasic_verification_submitted", "Bmerchant_id", "Bemail", "Bfirst_name",
         "Blast_name", "Bemail_confirmed", "Bcrypto_address_added", "Blogingornot", "BuserId"].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
        
        // Navigate to login
        shouldNavigateToLogin = true
        
        
    }
    
    private func updateStatusText() {
        let stepsLeft = [emailConfirmed, businessActivated, cryptoAdded].filter { !$0 }.count
        if stepsLeft == 0 {
            statusText = "Your account has been fully activated."
        } else {
            statusText = "You are \(stepsLeft) step\(stepsLeft > 1 ? "s" : "") away from accepting Bitcoin"
        }
    }
    
    private func showAlertWithMessage(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
    }
}

// MARK: - Preview
struct GetStartedView_Previews: PreviewProvider {
    static var previews: some View {
        GetStartedView()
    }
}
