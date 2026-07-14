//  FreeHandlingView.swift
//  Trading_Terminal
//
//  Created by Rajit HashCash on 14/04/26.
//

//import SwiftUI
//
//struct FeeHandlingView: View {
//
//    @Environment(\.dismiss) private var dismiss
//    @State private var selectedOption: FeeOption = .customerPays
//
//    enum FeeOption {
//        case customerPays
//        case merchantAbsorbs
//    }
//
//    // Colors
//    private let bgGradient = LinearGradient(
//        colors: [
//            Color(red: 0.05, green: 0.07, blue: 0.12),
//            Color(red: 0.02, green: 0.04, blue: 0.08)
//        ],
//        startPoint: .topLeading,
//        endPoint: .bottomTrailing
//    )
//
//    private let cardBg = Color(red: 0.12, green: 0.14, blue: 0.20)
//    private let borderColor = Color.white.opacity(0.08)
//    private let purple = Color(red: 0.60, green: 0.35, blue: 0.95)
//    private let blue = Color(red: 0.30, green: 0.60, blue: 1.0)
//    private let subtitleColor = Color.gray.opacity(0.7)
//
//    var body: some View {
//        ZStack {
//            bgGradient.ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 0) {
//
//                // HEADER
//                HStack(spacing: 12) {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .foregroundColor(.white)
//                    }
//
//                    VStack(alignment: .leading, spacing: 2) {
//                        Text("Fee Handling")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(.white)
//
//                        Text("Configure how processing fees are handled")
//                            .font(.system(size: 12))
//                            .foregroundColor(subtitleColor)
//                    }
//
//                    Spacer()
//                }
//                .padding(16)
//
//                Divider().background(Color.white.opacity(0.1))
//
//                ScrollView {
//                    VStack(spacing: 20) {
//
//                        //  MAIN CARD
//                        VStack(alignment: .leading, spacing: 16) {
//
//                            // Title
//                            HStack(spacing: 10) {
//                                Image(systemName: "percent")
//                                    .foregroundColor(purple)
//
//                                VStack(alignment: .leading) {
//                                    Text("Processing Fee Settings")
//                                        .foregroundColor(.white)
//                                        .font(.system(size: 16, weight: .semibold))
//
//                                    Text("Choose who pays the processing fee")
//                                        .foregroundColor(subtitleColor)
//                                        .font(.system(size: 12))
//                                }
//                            }
//
//                            // Info Box
//                            HStack(alignment: .top, spacing: 10) {
//                                Circle()
//                                    .fill(purple)
//                                    .frame(width: 8, height: 8)
//                                    .padding(.top, 5)
//
//                                Text("This setting determines whether the processing fee is added on top of the checkout total (customer pays) or deducted from your payout (merchant absorbs). This applies across all billing profiles.")
//                                    .foregroundColor(subtitleColor)
//                                    .font(.system(size: 12))
//                            }
//                            .padding()
//                            .background(Color.white.opacity(0.05))
//                            .cornerRadius(10)
//
//                            // Section Label
//                            Text("PROCESSING FEE HANDLING")
//                                .foregroundColor(subtitleColor)
//                                .font(.system(size: 11, weight: .semibold))
//
//                            // Options
//                            optionCard(
//                                title: "Customer Pays Fee",
//                                subtitle: "Fee added on top of checkout total",
//                                isSelected: selectedOption == .customerPays
//                            ) {
//                                selectedOption = .customerPays
//                            }
//
//                            optionCard(
//                                title: "Merchant Absorbs Fee",
//                                subtitle: "Fee deducted from your payout",
//                                isSelected: selectedOption == .merchantAbsorbs
//                            ) {
//                                selectedOption = .merchantAbsorbs
//                            }
//
//                            // Save Button
//                            HStack {
//                                Spacer()
//
//                                Button(action: {
//                                    print("Saved")
//                                }) {
//                                    HStack {
//                                        Image(systemName: "checkmark")
//                                        Text("Save Changes")
//                                    }
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 20)
//                                    .padding(.vertical, 12)
//                                    .background(
//                                        LinearGradient(
//                                            colors: [purple, blue],
//                                            startPoint: .leading,
//                                            endPoint: .trailing
//                                        )
//                                    )
//                                    .cornerRadius(20)
//                                }
//                            }
//                        }
//                        .padding(16)
//                        .background(cardBg)
//                        .cornerRadius(16)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(borderColor)
//                        )
//                        .padding(.horizontal, 16)
//                        .padding(.top, 20)
//
//                        Spacer(minLength: 40)
//                    }
//                }
//            }
//
//            // Floating Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//
//                    Button(action: {}) {
//                        Image(systemName: "plus")
//                            .foregroundColor(.white)
//                            .font(.system(size: 22, weight: .bold))
//                            .frame(width: 60, height: 60)
//                            .background(
//                                LinearGradient(
//                                    colors: [blue, blue.opacity(0.8)],
//                                    startPoint: .topLeading,
//                                    endPoint: .bottomTrailing
//                                )
//                            )
//                            .cornerRadius(18)
//                    }
//                    .padding(20)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//    }
//
//    //  Option Card (Radio Style)
//    func optionCard(
//        title: String,
//        subtitle: String,
//        isSelected: Bool,
//        action: @escaping () -> Void
//    ) -> some View {
//
//        HStack(spacing: 12) {
//
//            Circle()
//                .stroke(isSelected ? purple : Color.gray, lineWidth: 2)
//                .frame(width: 18, height: 18)
//                .overlay(
//                    Circle()
//                        .fill(isSelected ? purple : Color.clear)
//                        .frame(width: 10, height: 10)
//                )
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(title)
//                    .foregroundColor(.white)
//                    .font(.system(size: 14, weight: .semibold))
//
//                Text(subtitle)
//                    .foregroundColor(subtitleColor)
//                    .font(.system(size: 12))
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(Color.white.opacity(isSelected ? 0.08 : 0.04))
//        .cornerRadius(12)
//        .overlay(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(isSelected ? purple : borderColor, lineWidth: 1.5)
//        )
//        .onTapGesture {
//            action()
//        }
//    }
//}
//
//// Preview
//#Preview {
//    FeeHandlingView()
//}


//  FeeHandlingView.swift
//  Trading_Terminal
//
//  Created by Rajit HashCash on 14/04/26.
//
//  FeeHandlingView.swift
//  Trading_Terminal
//
//  Created by Rajit HashCash on 14/04/26.
//

//  FeeHandlingView.swift
//  Trading_Terminal
//
//  Created by Rajit HashCash on 14/04/26.
//

import SwiftUI
import Alamofire

// ─────────────────────────────────────────────────────────────────
// MARK: - Models
// ─────────────────────────────────────────────────────────────────

private struct ProcessingFeeStatusResponse: Decodable {
    let status: Bool
    let data: ProcessingFeeData?
}

private struct ProcessingFeeData: Decodable {
    let isProcessingFeeEnabled: Int
}

private struct UpdateProcessingFeeResponse: Decodable {
    let status: Bool
    let data: String?
}

// ─────────────────────────────────────────────────────────────────
// MARK: - API Service
// ─────────────────────────────────────────────────────────────────

private struct FeeHandlingAPI {

    static let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // ✅ Exact same keys as PaymentOptionsService
    static func headers() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        return [
            "Authorization": "bearer \(token)",
            "UUID":           uuid,
            "Content-Type":  "application/json",
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/"
        ]
    }

    // ✅ Exact same merchantId resolution as PaymentOptionsService
    static func merchantId() -> Int {
        if let v = UserDefaults.standard.value(forKey: "merchantId") as? Int { return v }
        if let v = UserDefaults.standard.value(forKey: "BMerchantId") as? Int { return v }
        if let v = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") { return v }
        if let v = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") { return v }

        // JWT fallback
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")
        if parts.count >= 2 {
            var payload   = parts[1]
            let remainder = payload.count % 4
            if remainder != 0 { payload += String(repeating: "=", count: 4 - remainder) }
            if let data   = Data(base64Encoded: payload),
               let json   = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let sub    = json["sub"] as? String,
               let idStr  = sub.components(separatedBy: "-").first,
               let id     = Int(idStr) {
                print("✅ merchantId from JWT: \(id)")
                return id
            }
        }

        print("❌ merchantId fallback failed")
        return 0
    }

    // GET - Fetch current processing fee status
    static func fetchStatus(
        onSuccess: @escaping (ProcessingFeeStatusResponse) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        let mid = merchantId()
        let url = "\(baseURL)/processing-fee/status/\(mid)"
        print("📡 [FeeHandling] fetchStatus → \(url)")

        Alamofire.request(url, method: .get, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 Status: \(response.response?.statusCode ?? -1)")
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 fetchStatus: \(raw)")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(ProcessingFeeStatusResponse.self, from: data)
                        onSuccess(decoded)
                    } catch {
                        print("❌ [FeeHandling] Decode error: \(error)")
                        onFailure(error)
                    }
                case .failure(let error):
                    print("❌ [FeeHandling] Network error: \(error)")
                    onFailure(error)
                }
            }
    }

    // POST - Update processing fee status
    static func updateStatus(
        status: Int,
        onSuccess: @escaping (UpdateProcessingFeeResponse) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        let url: String = "\(baseURL)/processing-fee/create"
        let parameters: Parameters = [
            "merchantId": merchantId(),
            "status":     status
        ]
        print("📡 [FeeHandling] updateStatus → \(parameters)")

        Alamofire.request(
            url,
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print("📡 Status: \(response.response?.statusCode ?? -1)")
            if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                print("📥 updateStatus: \(raw)")
            }
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(UpdateProcessingFeeResponse.self, from: data)
                    onSuccess(decoded)
                } catch {
                    print("❌ [FeeHandling] Decode error: \(error)")
                    onFailure(error)
                }
            case .failure(let error):
                print("❌ [FeeHandling] Network error: \(error)")
                onFailure(error)
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - Fee Toast (private to avoid redeclaration conflicts)
// ─────────────────────────────────────────────────────────────────

private struct FeeToast: Equatable {
    enum FeeToastType { case success, error }
    let type: FeeToastType
    let message: String
}

// ─────────────────────────────────────────────────────────────────
// MARK: - Main View
// ─────────────────────────────────────────────────────────────────

struct FeeHandlingView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var selectedOption: FeeOption = .customerPays
    @State private var isLoading: Bool           = true
    @State private var isSaving: Bool            = false
    @State private var feeToast: FeeToast?       = nil

    enum FeeOption {
        case customerPays
        case merchantAbsorbs
    }

    private var isReadOnly: Bool {
        (UserDefaults.standard.string(forKey: "page_access") ?? "") == "READ"
    }

    // ── Colors ──────────────────────────────────────────────────
    private let bgGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.07, blue: 0.12),
            Color(red: 0.02, green: 0.04, blue: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    private let cardBg        = Color(red: 0.12, green: 0.14, blue: 0.20)
    private let borderColor   = Color.white.opacity(0.08)
    private let purple        = Color(red: 0.60, green: 0.35, blue: 0.95)
    private let blue          = Color(red: 0.30, green: 0.60, blue: 1.0)
    private let subtitleColor = Color.gray.opacity(0.7)

    // ─────────────────────────────────────────────────────────────
    // MARK: Body
    // ─────────────────────────────────────────────────────────────

    var body: some View {
        ZStack {
            bgGradient.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                headerBar
                Divider().background(Color.white.opacity(0.1))
                mainContent
            }

            if let toast = feeToast {
                toastOverlay(toast)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { loadProcessingFeeStatus() }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: Sub-views
    // ─────────────────────────────────────────────────────────────

    private var headerBar: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Fee Handling")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Configure how processing fees are handled")
                    .font(.system(size: 12))
                    .foregroundColor(subtitleColor)
            }
            Spacer()
        }
        .padding(16)
    }

    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 16) {

                    // Card title
                    HStack(spacing: 10) {
                        Image(systemName: "percent")
                            .foregroundColor(purple)
                        VStack(alignment: .leading) {
                            Text("Processing Fee Settings")
                                .foregroundColor(.white)
                                .font(.system(size: 16, weight: .semibold))
                            Text("Choose who pays the processing fee")
                                .foregroundColor(subtitleColor)
                                .font(.system(size: 12))
                        }
                    }

                    // Info box
                    HStack(alignment: .top, spacing: 10) {
                        Circle()
                            .fill(purple)
                            .frame(width: 8, height: 8)
                            .padding(.top, 5)
                        Text("This setting determines whether the processing fee is added on top of the checkout total (customer pays) or deducted from your payout (merchant absorbs). This applies across all billing profiles.")
                            .foregroundColor(subtitleColor)
                            .font(.system(size: 12))
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(10)

                    // Section label
                    Text("PROCESSING FEE HANDLING")
                        .foregroundColor(subtitleColor)
                        .font(.system(size: 11, weight: .semibold))

                    if isLoading {
                        loadingView
                    } else {
                        optionCard(
                            title: "Customer Pays Fee",
                            subtitle: "Fee added on top of checkout total",
                            isSelected: selectedOption == .customerPays
                        ) {
                            if !isReadOnly { selectedOption = .customerPays }
                        }

                        optionCard(
                            title: "Merchant Absorbs Fee",
                            subtitle: "Fee deducted from your payout",
                            isSelected: selectedOption == .merchantAbsorbs
                        ) {
                            if !isReadOnly { selectedOption = .merchantAbsorbs }
                        }

                        if !isReadOnly {
                            HStack {
                                Spacer()
                                saveButton
                            }
                        }
                    }
                }
                .padding(16)
                .background(cardBg)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor))
                .padding(.horizontal, 16)
                .padding(.top, 20)

                Spacer(minLength: 40)
            }
        }
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            VStack(spacing: 10) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: purple))
                    .scaleEffect(1.2)
                Text("Loading...")
                    .foregroundColor(subtitleColor)
                    .font(.system(size: 13))
            }
            .padding(.vertical, 40)
            Spacer()
        }
    }

    private var saveButton: some View {
        Button(action: handleSave) {
            HStack(spacing: 6) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Saving...")
                } else {
                    Image(systemName: "checkmark")
                    Text("Save Changes")
                }
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                LinearGradient(colors: [purple, blue], startPoint: .leading, endPoint: .trailing)
            )
            .cornerRadius(20)
        }
        .disabled(isSaving)
    }

    private func toastOverlay(_ toast: FeeToast) -> some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                Image(systemName: toast.type == .success
                      ? "checkmark.circle.fill"
                      : "xmark.circle.fill")
                    .foregroundColor(toast.type == .success ? .green : .red)
                Text(toast.message)
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .medium))
                Spacer()
            }
            .padding()
            .background(Color(red: 0.15, green: 0.17, blue: 0.24))
            .cornerRadius(12)
            .padding(.horizontal, 16)
            .padding(.bottom, 30)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.3), value: feeToast)
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: Option Card
    // ─────────────────────────────────────────────────────────────

    func optionCard(
        title: String,
        subtitle: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 12) {
            Circle()
                .stroke(isSelected ? purple : Color.gray, lineWidth: 2)
                .frame(width: 18, height: 18)
                .overlay(
                    Circle()
                        .fill(isSelected ? purple : Color.clear)
                        .frame(width: 10, height: 10)
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))
                Text(subtitle)
                    .foregroundColor(subtitleColor)
                    .font(.system(size: 12))
            }
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(isSelected ? 0.08 : 0.04))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? purple : borderColor, lineWidth: 1.5)
        )
        .onTapGesture { action() }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: API Calls
    // ─────────────────────────────────────────────────────────────

    private func loadProcessingFeeStatus() {
        isLoading = true

        FeeHandlingAPI.fetchStatus(
            onSuccess: { response in
                DispatchQueue.main.async {
                    isLoading = false
                    if response.status, let data = response.data {
                        selectedOption = data.isProcessingFeeEnabled == 1
                            ? .customerPays
                            : .merchantAbsorbs
                    } else {
                        print("⚠️ [FeeHandling] status false or no data — defaulting to customerPays")
                        selectedOption = .customerPays
                    }
                }
            },
            onFailure: { error in
                DispatchQueue.main.async {
                    isLoading = false
                    print("❌ [FeeHandling] fetchStatus error: \(error)")
                    selectedOption = .customerPays
                }
            }
        )
    }

    private func handleSave() {
        guard !isReadOnly else {
            displayToast(type: .error, message: "You need write access to perform this operation")
            return
        }

        isSaving = true
        let status = selectedOption == .customerPays ? 1 : 0

        FeeHandlingAPI.updateStatus(
            status: status,
            onSuccess: { response in
                DispatchQueue.main.async {
                    isSaving = false
                    if response.status {
                        displayToast(
                            type: .success,
                            message: response.data ?? "Processing fee preference saved successfully."
                        )
                    } else {
                        displayToast(type: .error, message: "Failed to update processing fee status.")
                    }
                }
            },
            onFailure: { error in
                DispatchQueue.main.async {
                    isSaving = false
                    print("❌ [FeeHandling] updateStatus error: \(error)")
                    displayToast(type: .error, message: "Something went wrong. Please try again.")
                }
            }
        )
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: Toast
    // ─────────────────────────────────────────────────────────────

    private func displayToast(type: FeeToast.FeeToastType, message: String) {
        withAnimation { feeToast = FeeToast(type: type, message: message) }
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation { feeToast = nil }
            }
        }
    }
}

// ─────────────────────────────────────────────────────────────────
// MARK: - Preview
// ─────────────────────────────────────────────────────────────────

#Preview {
    FeeHandlingView()
}
