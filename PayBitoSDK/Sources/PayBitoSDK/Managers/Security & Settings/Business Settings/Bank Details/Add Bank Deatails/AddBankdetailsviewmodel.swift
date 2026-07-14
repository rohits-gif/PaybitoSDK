//
//  BankDetailsViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine
import Alamofire

// MARK: - SubmissionStatus

enum SubmissionStatus {
    case notSubmitted
    case submitted
    case pendingVerification

    var label: String {
        switch self {
        case .notSubmitted:        return "Not Submitted"
        case .submitted:           return "Submitted"
        case .pendingVerification: return "Pending Verification"
        }
    }
}

// MARK: - AddBankDetailsViewModel

@MainActor
final class AddBankDetailsViewModel: ObservableObject {
   
    @Published var selectedBankDocType = "Voided Check"
    @Published var bankDocFileName: String?
    @Published var bankDocFileURL: URL?

    let bankDocOptions = [
        "Voided Check",
        "Recent Bank Statement (last 3 months)",
        "Screenshot or PDF from Online Banking",
        "Bank Letter / Bank Account Verification Letter",
        "Direct Deposit Form / ACH Authorization Form"
    ]

    func handleBankDocument(url: URL) {
        let size = (try? url.resourceValues(forKeys: [.fileSizeKey]))?.fileSize ?? 0

        if size > 5 * 1024 * 1024 {
            errorMessage = "File must be smaller than 5 MB."
            return
        }

        bankDocFileName = url.lastPathComponent
        bankDocFileURL = url
    }

    func removeBankDocument() {
        bankDocFileName = nil
        bankDocFileURL = nil
    }

    // ─── Published UI State ───────────────────────────────────────────────────
    @Published var name:          String = ""
    @Published var accountNumber: String = ""
    @Published var code:          String = ""
    @Published var bankName:      String = ""
    @Published var address:       String = ""

    @Published var accountType: String = AccountType.personalSavings.rawValue
    @Published var codeType:    String = CodeType.ifsc.rawValue

    // ─── UI Feedback ──────────────────────────────────────────────────────────
    @Published var isLoading:        Bool             = false
    @Published var errorMessage:     String?          = nil
    @Published var successMessage:   String?          = nil
    @Published var submissionStatus: SubmissionStatus = .notSubmitted

    // ─── Picker Options ───────────────────────────────────────────────────────
    let accountOptions: [String] = AccountType.allCases.map(\.rawValue)
    let codeOptions:    [String] = CodeType.allCases.map(\.rawValue)

    // ─── API Endpoints ────────────────────────────────────────────────────────
    private let fetchURL  = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/GetUserBankDetails"
    private let updateURL = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/UpdateUserBankDetails"

    // ─── UUID ─────────────────────────────────────────────────────────────────
    private var resolvedUUID: String {
        UserDefaults.standard.string(forKey: "Bexchange_uuid")
            ?? UserDefaults.standard.string(forKey: "billbitcoins_exchange_uuid")
            ?? UserDefaults.standard.string(forKey: "Buuid")
            ?? ""
    }

    // ─── Auth Headers ─────────────────────────────────────────────────────────
    private var requestHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Origin":       "https://trade.paybito.com",
            "Referer":      "https://trade.paybito.com/"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "bearer \(token)"
            debugPrint("🔑 [BDViewModel] token attached")
        } else {
            debugPrint("❌ [BDViewModel] token missing")
        }
        if let uid = UserDefaults.standard.string(forKey: "Buuid"), !uid.isEmpty {
            h["Uuid"] = uid
        }
        return h
    }

    // ─── Init ─────────────────────────────────────────────────────────────────
    init() {
        debugPrint("🔵 [BDViewModel] Initialized | uuid=\(resolvedUUID)")
    }

    // =========================================================================
    // MARK: - Fetch Bank Details
    // =========================================================================

    func fetchExistingBankDetails() {
        guard !resolvedUUID.isEmpty else {
            errorMessage = "User session expired. Please log in again."
            debugPrint("❌ [BDViewModel] fetchExistingBankDetails — UUID empty")
            return
        }

        isLoading    = true
        errorMessage = nil

        let body: [String: Any] = ["uuid": resolvedUUID]

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [BDViewModel] fetchExistingBankDetails")
        debugPrint("   URL  : \(fetchURL)")
        debugPrint("   body : \(body)")
        debugPrint("════════════════════════════════════════")

        Alamofire
            .request(fetchURL,
                     method:     .post,
                     parameters: body,
                     encoding:   JSONEncoding.default,
                     headers:    requestHeaders)
            .validate(statusCode: 200..<300)
            .responseData { [weak self] response in
                guard let self else { return }

                DispatchQueue.main.async {
                    self.isLoading = false
                    debugPrint("📥 [BDViewModel] fetchExistingBankDetails HTTP \(response.response?.statusCode ?? -1)")

                    if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                        debugPrint("   raw: \(raw.prefix(500))")
                    }

                    switch response.result {
                    case .success(let data):
                        do {
                            let decoded = try JSONDecoder().decode(BankDetailsResponse.self, from: data)
                            debugPrint("✅ [BDViewModel] fetch decoded | id=\(decoded.bankDetails?.bankDetailsId ?? -1)")

                            if decoded.error.hasError {
                                debugPrint("❌ [BDViewModel] API error: \(decoded.error.errorMsg)")
                                self.errorMessage = decoded.error.errorMsg
                                return
                            }

                            guard let detail = decoded.bankDetails else {
                                debugPrint("⚠️  [BDViewModel] bankDetails nil")
                                return
                            }

                            self.populateFields(from: detail)
                            self.deriveSubmissionStatus(from: detail)

                        } catch {
                            debugPrint("❌ [BDViewModel] fetch decode error: \(error)")
                            self.errorMessage = error.localizedDescription
                        }

                    case .failure(let error):
                        debugPrint("❌ [BDViewModel] fetch network error: \(error)")
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
    }
    private func populateFields(from detail: BankDetailsModel) {
        name          = detail.benificiaryName ?? ""
        accountNumber = detail.accountNo       ?? ""
        bankName      = detail.bankName        ?? ""
        address       = detail.bankAddress     ?? ""

        let known = AccountType.allCases.map(\.rawValue)
        if let t = detail.accountType, known.contains(t) {
            accountType = t
        } else {
            accountType = AccountType.personalSavings.rawValue
        }

        // Code type — routing takes priority to match web behaviour
        if let r = detail.routingNo, !r.isEmpty {
            codeType = "ROUTING NUMBER"
            code     = r
        } else if let s = detail.swiftCode, !s.isEmpty {
            codeType = CodeType.swift.rawValue
            code     = s
        } else if let i = detail.ifscCode, !i.isEmpty {
            codeType = CodeType.ifsc.rawValue
            code     = i
        }

        // Doc type if previously saved
        if let docType = detail.bankVerificationDocType, !docType.isEmpty,
           bankDocOptions.contains(docType) {
            selectedBankDocType = docType
        }

        debugPrint("🟢 Fields populated — name:\(name) bank:\(bankName) code:\(codeType):\(code)")
    }

    private func deriveSubmissionStatus(from detail: BankDetailsModel) {
        // bankDetailsId > 0 means a record exists on the server
        if let id = detail.bankDetailsId, id > 0 {
            submissionStatus = .submitted
        } else {
            submissionStatus = .notSubmitted
        }
    }

    // =========================================================================
    // MARK: - Save Bank Details
    // =========================================================================

//    func persistBankDetailsToServer() {
//        guard performFieldValidation() else { return }
//
//        isLoading      = true
//        errorMessage   = nil
//        successMessage = nil
//
//        let swiftVal = (codeType == CodeType.swift.rawValue) ? code : ""
//        let ifscVal  = (codeType == CodeType.ifsc.rawValue)  ? code : ""
//
//        let body: [String: Any] = [
//            "uuid":             resolvedUUID,
//            "benificiary_name": name.trimmingCharacters(in: .whitespaces),
//            "bank_name":        bankName.trimmingCharacters(in: .whitespaces),
//            "account_no":       accountNumber.trimmingCharacters(in: .whitespaces),
//            "accountType":      accountType,
//            "routing_no":       code.trimmingCharacters(in: .whitespaces),
//            "swiftCode":        swiftVal,
//            "ifscCode":         ifscVal,
//            "bankAddress":      address.trimmingCharacters(in: .whitespaces),
//            "bank_cheque":      ""
//        ]
//
//        debugPrint("════════════════════════════════════════")
//        debugPrint("📡 [BDViewModel] persistBankDetailsToServer")
//        debugPrint("   URL        : \(updateURL)")
//        debugPrint("   accountType: \(accountType) | codeType: \(codeType)")
//        debugPrint("   body       : \(body)")
//        debugPrint("════════════════════════════════════════")
//
//        Alamofire
//            .request(updateURL,
//                     method:     .post,
//                     parameters: body,
//                     encoding:   JSONEncoding.default,
//                     headers:    requestHeaders)
//            .validate(statusCode: 200..<300)
//            .responseData { [weak self] response in
//                guard let self else { return }
//
//                DispatchQueue.main.async {
//                    self.isLoading = false
//                    debugPrint("📥 [BDViewModel] persistBankDetailsToServer HTTP \(response.response?.statusCode ?? -1)")
//
//                    if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
//                        debugPrint("   raw: \(raw.prefix(500))")
//                    }
//
//                    switch response.result {
//                    case .success(let data):
//                        do {
//                            let decoded = try JSONDecoder().decode(UpdateBankDetailsResponse.self, from: data)
//                            debugPrint("✅ [BDViewModel] save decoded")
//
//                            if decoded.error.hasError {
//                                debugPrint("❌ [BDViewModel] API error: \(decoded.error.errorMsg)")
//                                self.errorMessage = decoded.error.errorMsg
//                                return
//                            }
//
//                            self.successMessage   = "Bank details saved successfully."
//                            self.submissionStatus = .submitted
//                            debugPrint("🟢 [BDViewModel] Bank details updated ✓")
//
//                        } catch {
//                            debugPrint("❌ [BDViewModel] save decode error: \(error)")
//                            self.errorMessage = error.localizedDescription
//                        }
//
//                    case .failure(let error):
//                        debugPrint("❌ [BDViewModel] save network error: \(error)")
//                        self.errorMessage = error.localizedDescription
//                    }
//                }
//            }
//    }
    
    func persistBankDetailsToServer() {

        guard performFieldValidation() else { return }

        isLoading = true
        errorMessage = nil
        successMessage = nil

        let swiftVal = (codeType == CodeType.swift.rawValue) ? code : ""
        let ifscVal  = (codeType == CodeType.ifsc.rawValue)  ? code : ""

//        let body: [String: Any] = [
//            "uuid": resolvedUUID,
//            "benificiary_name": name.trimmingCharacters(in: .whitespaces),
//            "bank_name": bankName.trimmingCharacters(in: .whitespaces),
//            "account_no": accountNumber.trimmingCharacters(in: .whitespaces),
//            "accountType": accountType,
//            "routing_no": code.trimmingCharacters(in: .whitespaces),
//            "swiftCode": swiftVal,
//            "ifscCode": ifscVal,
//            "bankAddress": address.trimmingCharacters(in: .whitespaces),
//
//            // ✅ NEW
//            "bankVerificationDocumentType": selectedBankDocType
//        ]

        let uploadURL =
        "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/UpdateUserBankDetails-v2"

        // ✅ Multipart headers
        var headers: HTTPHeaders = [
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"),
           !token.isEmpty {

            headers["Authorization"] = "bearer \(token)"
        }

        if let uid = UserDefaults.standard.string(forKey: "Buuid"),
           !uid.isEmpty {

            headers["UUID"] = uid
        }

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [BDViewModel] UpdateUserBankDetails-v2")
        debugPrint("URL: \(uploadURL)")
//        debugPrint("BODY: \(body)")
        debugPrint("FILE: \(bankDocFileName ?? "NONE")")
        debugPrint("════════════════════════════════════════")

        Alamofire.upload(

            multipartFormData: { multipart in

                // ✅ EXACT SAME AS WEB

                let bankData: [String: Any] = [

                    "uuid": self.resolvedUUID,

                    "benificiary_name":
                        self.name.trimmingCharacters(in: .whitespaces),

                    "bank_name":
                        self.bankName.trimmingCharacters(in: .whitespaces),

                    "account_no":
                        self.accountNumber
                            .trimmingCharacters(in: .whitespaces)
                            .replacingOccurrences(of: " ", with: ""),

                    "accountType":
                        self.accountType,

                    "ifscCode":
                        self.codeType == CodeType.ifsc.rawValue
                        ? self.code
                            .trimmingCharacters(in: .whitespaces)
                            .uppercased()
                        : "",

                    "swiftCode":
                        self.codeType == CodeType.swift.rawValue
                        ? self.code
                            .trimmingCharacters(in: .whitespaces)
                            .uppercased()
                        : "",

                    "routing_no":
                        self.codeType == "ROUTING NUMBER"
                        ? self.code.trimmingCharacters(in: .whitespaces)
                        : "",

                    "bankAddress":
                        self.address.trimmingCharacters(in: .whitespaces),

                    // ✅ EXACT WEB KEY
                    "bankVerificationDocType":
                        self.selectedBankDocType,

                    // ✅ REQUIRED
                    "country": ""
                ]

                do {

                    let jsonData = try JSONSerialization.data(
                        withJSONObject: bankData,
                        options: []
                    )

                    // ✅ formData.append("bankData", JSON.stringify(bankData))

                    multipart.append(
                        jsonData,
                        withName: "bankData"
                    )

                } catch {

                    debugPrint("❌ Failed to serialize bankData")
                }

                // ✅ formData.append("doc", bankDocFile)

                if let fileURL = self.bankDocFileURL {

                    multipart.append(
                        fileURL,
                        withName: "doc",
                        fileName: fileURL.lastPathComponent,
                        mimeType: self.mimeType(for: fileURL)
                    )
                }
            },
            to: uploadURL,
            method: .post,
            headers: headers,

            encodingCompletion: { result in

                switch result {

                case .success(let upload, _, _):

                    upload
                        .validate(statusCode: 200..<300)
                        .responseData { response in

                            DispatchQueue.main.async {

                                self.isLoading = false

                                debugPrint("📥 HTTP \(response.response?.statusCode ?? -1)")

                                if let raw = response.data.flatMap({
                                    String(data: $0, encoding: .utf8)
                                }) {

                                    debugPrint(raw)
                                }

                                switch response.result {

                                case .success(let data):

                                    do {

                                        let decoded = try JSONDecoder().decode(
                                            UpdateBankDetailsResponse.self,
                                            from: data
                                        )

                                        if decoded.error.hasError {

                                            self.errorMessage =
                                            decoded.error.errorMsg

                                            return
                                        }

                                        self.successMessage =
                                        "Bank details saved successfully."

                                        self.submissionStatus = .submitted

                                    } catch {

                                        self.errorMessage =
                                        error.localizedDescription
                                    }

                                case .failure(let error):

                                    self.errorMessage =
                                    error.localizedDescription
                                }
                            }
                        }

                case .failure(let error):

                    DispatchQueue.main.async {

                        self.isLoading = false
                        self.errorMessage = error.localizedDescription
                    }
                }
            }
        )
    }
    private func mimeType(for url: URL) -> String {

        switch url.pathExtension.lowercased() {

        case "pdf":
            return "application/pdf"

        case "jpg", "jpeg":
            return "image/jpeg"

        case "png":
            return "image/png"

        default:
            return "application/octet-stream"
        }
    }

    // =========================================================================
    // MARK: - Populate Fields
    // =========================================================================

    private func populateFields(from detail: AddBankDetail) {
        name          = detail.benificiaryName ?? ""
        accountNumber = detail.accountNo       ?? ""
        bankName      = detail.bankName        ?? ""
        address       = detail.bankAddress     ?? ""

        let known = AccountType.allCases.map(\.rawValue)
        if let t = detail.accountType, known.contains(t) {
            accountType = t
        } else {
            accountType = AccountType.personalSavings.rawValue
            debugPrint("⚠️  [BDViewModel] unknown accountType — defaulting")
        }

        if let s = detail.swiftCode, !s.isEmpty {
            codeType = CodeType.swift.rawValue
            code     = s
        } else if let i = detail.ifscCode, !i.isEmpty {
            codeType = CodeType.ifsc.rawValue
            code     = i
        } else {
            code = detail.routingNo ?? ""
        }

        debugPrint("🟢 [BDViewModel] fields populated — name:\(name) bank:\(bankName)")
    }

    // =========================================================================
    // MARK: - Submission Status
    // =========================================================================

    private func deriveSubmissionStatus(from detail: AddBankDetail) {
        if let id = detail.bankDetailsId, id > 0 {
            submissionStatus = .submitted
            debugPrint("🟢 [BDViewModel] status=submitted (id=\(id))")
        } else {
            let filled = !name.isEmpty && !accountNumber.isEmpty &&
                         !code.isEmpty && !bankName.isEmpty && !address.isEmpty
            submissionStatus = filled ? .submitted : .notSubmitted
        }
    }

    // =========================================================================
    // MARK: - Validation
    // =========================================================================

    private func performFieldValidation() -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Account holder's name is required."; return false
        }
        if accountNumber.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Account number is required."; return false
        }
        if code.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a valid \(codeType)."; return false
        }
        if bankName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Bank name is required."; return false
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Bank address is required."; return false
        }
        debugPrint("✅ [BDViewModel] validation passed")
        return true
    }

    // =========================================================================
    // MARK: - Helpers
    // =========================================================================

    func clearAlerts() {
        errorMessage   = nil
        successMessage = nil
    }
}
