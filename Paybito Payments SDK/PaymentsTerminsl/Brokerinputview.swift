//
//  Brokerinputview.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 19/05/26.
//
//
//  BrokerInputView.swift
//  Trading_Terminal
//
//  SwiftUI conversion of brokerInputControllerV2.swift
//  Connects to ChoosePlatformView → LoginView (Payment) or loginViewController (Financial)
//

import SwiftUI
import Alamofire
import SwiftyJSON
import SDWebImageSwiftUI   // For broker logo (same as sd_setImage)

// MARK: - BrokerInputView
struct brokerDetails {
    static var brokerID = ""
    static var brokerLogo = ""
    static var brokerName = ""
    static var brokerDomain = ""
    static var brokerWebsite = ""
    static var brokerAdd = ""
    static var brokerEmail = ""
}


struct BrokerInputView: View {

    // MARK: State
    @State private var isDomainMode     = true
    @State private var inputText        = ""
    @State private var isLoading        = false
    @State private var alertMessage     = ""
    @State private var showAlert        = false
    @State private var showBrokerCard   = false
    @State private var navigatePlatform = false

    // MARK: Colors (matching UIKit originals)
    private let purpleAccent = Color(red: 0.42, green: 0.35, blue: 0.95)
    private let darkBG       = Color(red: 0.05, green: 0.07, blue: 0.12)
    private let cardBG       = Color(red: 0.10, green: 0.13, blue: 0.20)
    private let segmentBG    = Color(red: 0.12, green: 0.15, blue: 0.22)

    @FocusState private var fieldFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                darkBG.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        logoSection
                        titlesSection
                        segmentControl
                        inputSection
                        if showBrokerCard { brokerCard }
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 48)
                }
                .onTapGesture { fieldFocused = false }

                if isLoading { loadingOverlay }
            }
            .navigationDestination(isPresented: $navigatePlatform) {
                ChoosePlatformView()
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: { Text(alertMessage) }
            .navigationBarHidden(true)
            .onAppear {
                // Auto-navigate if BROKERID is pre-set (mirrors viewWillAppear logic)
                if !BROKERID.isEmpty {
                    getDetailByBrokerID(brokerId: BROKERID, autoNavigate: true)
                }
            }
        }
    }

    // MARK: - Logo

    private var logoSection: some View {
        Image("TC")
            .resizable()
            .scaledToFit()
            .frame(width: 90, height: 90)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Titles

    private var titlesSection: some View {
        VStack(spacing: 8) {
            Text("Find Your Broker")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 24)

            Text("Search by domain or broker ID to get started")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Segment Control

    private var segmentControl: some View {
        ZStack(alignment: .leading) {
            // Track
            RoundedRectangle(cornerRadius: 14)
                .fill(segmentBG)
                .frame(height: 52)

            // Sliding pill
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 11)
                    .fill(purpleAccent)
                    .frame(width: geo.size.width / 2 - 6, height: 44)
                    .offset(x: isDomainMode ? 4 : geo.size.width / 2 + 2, y: 4)
                    .animation(.easeInOut(duration: 0.25), value: isDomainMode)
            }
            .frame(height: 52)

            // Buttons
            HStack(spacing: 0) {
                Button {
                    switchMode(toDomain: true)
                } label: {
                    Text("Domain")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(isDomainMode ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }

                Button {
                    switchMode(toDomain: false)
                } label: {
                    Text("Broker ID")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(!isDomainMode ? .white : .white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
            }
        }
        .frame(height: 52)
        .padding(.top, 32)
    }

    // MARK: - Input Section

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(isDomainMode ? "Please enter your Domain" : "Please enter your Broker ID")
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.55))
                .padding(.top, 28)

            // Input card
            HStack(spacing: 4) {
                if isDomainMode {
                    Text("www.")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.45))
                        .frame(width: 44)
                }

                ZStack(alignment: .leading) {
                    if inputText.isEmpty {
                        Text(isDomainMode ? "domain.com" : "BROKERID1234***")
                            .foregroundColor(.white.opacity(0.3))
                            .font(.system(size: 16))
                    }

                    TextField("", text: $inputText)
                        .focused($fieldFocused)
                        .foregroundColor(.white)
                        .font(.system(size: 16))
                        .textInputAutocapitalization(isDomainMode ? .never : .characters)
                        .autocorrectionDisabled()
                        .keyboardType(isDomainMode ? .URL : .asciiCapable)
                        .submitLabel(.go)
                        .onSubmit { handleEnter() }
                        .onChange(of: inputText) { newVal in
                            inputText = sanitize(newVal)
                        }
                }
                // Go button
                Button(action: handleEnter) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(purpleAccent)
                        .clipShape(Circle())
                }
            }
            .padding(.leading, isDomainMode ? 16 : 16)
            .padding(.trailing, 10)
            .frame(height: 64)
            .background(cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - Broker Card

    private var brokerCard: some View {
        Button(action: handleBrokerCardTap) {
            HStack(spacing: 14) {
                // Logo
                WebImage(url: URL(string: brokerDetails.brokerLogo))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
                    .background(segmentBG)
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(brokerDetails.brokerName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(brokerDetails.brokerDomain)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                    Text(brokerDetails.brokerAdd)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(purpleAccent)
                    .frame(width: 14, height: 20)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .background(cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(purpleAccent.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.top, 20)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
            ProgressView()
                .scaleEffect(1.4)
                .tint(.white)
                .padding(24)
                .background(Color.white.opacity(0.10))
                .cornerRadius(16)
        }
    }

    // MARK: - Actions

    private func switchMode(toDomain: Bool) {
        isDomainMode  = toDomain
        inputText     = ""
        showBrokerCard = false
        fieldFocused  = false
    }

    private func sanitize(_ text: String) -> String {
        if isDomainMode {
            // Block www prefix while typing
            return text
        } else {
            // Broker ID: only alphanumerics + _.-  and uppercase
            let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_.-"))
            let filtered = text.unicodeScalars.filter { allowed.contains($0) }
            return String(String.UnicodeScalarView(filtered)).uppercased()
        }
    }

    private func handleEnter() {
        fieldFocused = false
        guard !inputText.isEmpty else {
            alertMessage = "Field should not be empty"
            showAlert    = true
            return
        }

        if isDomainMode {
            let lowered = inputText.lowercased()
            if lowered.hasPrefix("www.") || lowered.hasPrefix("www") {
                alertMessage = "Please enter domain without 'www.' — e.g. paybito.com"
                showAlert    = true
                return
            }
            getDetailByDomainNew()
        } else {
            getDetailByBrokerID(brokerId: inputText, autoNavigate: false)
        }
    }

    private func handleBrokerCardTap() {
        SET_OBJ_FOR_KEY(obj: "I", key: "count")
        navigatePlatform = true
    }

    // MARK: - Network

    private func getDetailByDomainNew() {
        isLoading = true
        let domainInput = inputText.lowercased()
        let urlString   = "https://accounts.paybito.com/api/home/exchangeDetailsForTradingTerminal?domain=\(domainInput)"

        guard let url = URL(string: urlString) else {
            alertMessage = "Invalid URL."
            showAlert    = true
            isLoading    = false
            return
        }

        Alamofire.request(url, method: .get, headers: requestHeader.headerWithoutAuthToken())
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let json = try? JSON(JSONSerialization.jsonObject(with: data)) else {
                        DispatchQueue.main.async {
                            self.isLoading    = false
                            self.alertMessage = "Invalid server response format."
                            self.showAlert    = true
                        }
                        return
                    }
                    switch response.response?.statusCode {
                    case 200:
                        brokerDetails.brokerID     = json["brokerId"].stringValue
                        brokerDetails.brokerLogo   = json["exchangeLogo"].stringValue
                        brokerDetails.brokerDomain = json["exchange"].stringValue
                        brokerDetails.brokerName   = json["companyName"].stringValue
                        SET_OBJ_FOR_KEY(obj: json["domain"].stringValue, key: "brokerDomain")
                        self.getDetailByBrokerID(brokerId: brokerDetails.brokerID, autoNavigate: false)
                    case 401:
                        DispatchQueue.main.async {
                            self.isLoading    = false
                            self.alertMessage = "Server unauthorized (401)."
                            self.showAlert    = true
                        }
                    default:
                        DispatchQueue.main.async {
                            self.isLoading    = false
                            self.alertMessage = "Unexpected server response."
                            self.showAlert    = true
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.isLoading    = false
                        self.alertMessage = error.localizedDescription
                        self.showAlert    = true
                    }
                }
            }
    }

    /// autoNavigate: true → skip broker card, jump straight to login (used for pre-set BROKERID)
    private func getDetailByBrokerID(brokerId: String, autoNavigate: Bool) {
        isLoading = true
        let url   = "https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo?brokerId=\(brokerId)"

        Alamofire.request(url, method: .get, parameters: nil,
                          encoding: URLEncoding.httpBody,
                          headers: requestHeader.headerWithAuthToken())
            .responseJSON { response in
                guard let value = response.result.value as? [String: Any] else {
                    DispatchQueue.main.async { self.isLoading = false }
                    return
                }
                let resJson = JSON(value)
                DispatchQueue.main.async {
                    self.isLoading = false
                    if resJson["code"].intValue == 1 {
                        self.alertMessage = resJson["message"].stringValue
                        self.showAlert    = true
                        self.showBrokerCard = false
                        return
                    }
                    if response.response?.statusCode == 200 {

                        brokerDetails.brokerDomain = resJson["domain"].stringValue

                        print("🌐 API domain:", brokerDetails.brokerDomain)

                        for val in resJson["value"].arrayValue {

                            let brokerId = val["broker_id"].stringValue

                            let brokerLogo = val["exchange_logo"].stringValue

                            let brokerName = val["exchange"].stringValue

                            print("✅ API brokerId:", brokerId)

                            print("✅ API brokerName:", brokerName)

                            print("✅ API brokerLogo:", brokerLogo)

                            brokerDetails.brokerID = brokerId

                            brokerDetails.brokerLogo = brokerLogo

                            brokerDetails.brokerWebsite = val["company_website"].stringValue

                            brokerDetails.brokerName = brokerName

                            brokerDetails.brokerEmail = val["support_email"].stringValue

                            brokerDetails.brokerAdd = val["company_address"].stringValue

                            SET_OBJ_FOR_KEY(obj: brokerDetails.brokerName, key: "companyName")

                            SET_OBJ_FOR_KEY(obj: brokerId, key: "brokerId")

                            SET_OBJ_FOR_KEY(obj: brokerId, key: "broker_id")

                            SET_OBJ_FOR_KEY(obj: brokerDetails.brokerLogo, key: "loader_icon")

                            SET_OBJ_FOR_KEY(obj: brokerDetails.brokerDomain, key: "paybitoURL")

                            SET_OBJ_FOR_KEY(obj: "I", key: "count")

                            print(

                                "💾 UserDefaults brokerId:",

                                UserDefaults.standard.string(forKey: "brokerId") ?? "nil"

                            )

                            print(

                                "💾 UserDefaults broker_id:",

                                UserDefaults.standard.string(forKey: "broker_id") ?? "nil"

                            )

                            print(

                                "💾 UserDefaults loader_icon:",

                                UserDefaults.standard.string(forKey: "loader_icon") ?? "nil"

                            )

                        }
                        if autoNavigate {
                            self.navigatePlatform = true
                        } else {
                            withAnimation { self.showBrokerCard = true }
                        }
                    }
                }
            }
    }
}
class requestHeader {
    class func headerWithAuthToken() -> HTTPHeaders{
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(OBJ_FOR_KEY(key: "ACCESS_TOKEN") ?? "")",
            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
                    ]
//        "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
        return headers
    }
    class func headerWithoutAuthToken() -> HTTPHeaders{
        let headers = [
            "Content-Type": "application/json",
            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
           // "Authorization": "Bearer \(OBJ_FOR_KEY(key: "ACCESS_TOKEN")!)"
                    ]
        return headers
    }
    class func headerWithAuthTokenForMultipart() -> HTTPHeaders{
        let headers = [
            "Content-Type": "multipart/form-data",
            "authorization": "BEARER \(OBJ_FOR_KEY(key: "ACCESS_TOKEN") ?? "")",
            "origin": "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
           // "Authorization": "Bearer \(OBJ_FOR_KEY(key: "ACCESS_TOKEN")!)"
                    ]
        return headers
    }
}

// MARK: - Placeholder helper

//extension View {
//    func placeholder<Content: View>(
//        when shouldShow: Bool,
//        alignment: Alignment = .leading,
//        @ViewBuilder placeholder: () -> Content
//    ) -> some View {
//        ZStack(alignment: alignment) {
//            placeholder().opacity(shouldShow ? 1 : 0)
//            self
//        }
//    }
//}

// MARK: - Preview
#Preview { BrokerInputView() }
