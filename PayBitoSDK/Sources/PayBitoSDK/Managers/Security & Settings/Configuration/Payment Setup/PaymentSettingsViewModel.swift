// MARK: - ViewModels

import Foundation
import Combine

// ─────────────────────────────────────────────
// GatewayCardViewModel  (Stripe OR PayPal)
// mirrors the per-card state in StripeCard / PayPalCard React components
// ─────────────────────────────────────────────
final class GatewayCardViewModel: ObservableObject {

    // Form fields
    @Published var clientId: String = ""
    @Published var clientSecret: String = ""
    @Published var isEnabled: Bool = false

    // UI state
    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var showClearConfirm: Bool = false

    // Validation errors
    @Published var clientIdError: String? = nil
    @Published var clientSecretError: String? = nil

    // Toast / alert
    @Published var toastMessage: String? = nil
    @Published var toastIsError: Bool = false

    // Internal
    private(set) var gatewayId: Int? = nil
    let gatewayName: String          // "Stripe" | "Paypal"
    let merchantId: String
    private let service = PaymentGatewayService.shared

    init(gatewayName: String, merchantId: String) {
        self.gatewayName = gatewayName
        self.merchantId  = merchantId
    }

    // Populate from loaded data (mirrors useEffect in React)
    func populate(from gateway: PaymentGateway?) {
        guard let gw = gateway else { return }
        gatewayId    = gw.id
        clientId     = gw.clientId ?? ""
        clientSecret = gw.clientSecret ?? ""
        isEnabled    = gw.isEnabled
    }

    // ─── Validation ─────────────────────────────
    @discardableResult
    func validate() -> Bool {
        clientIdError     = nil
        clientSecretError = nil

        guard isEnabled else { return true }   // only validate when enabled

        if clientId.trimmingCharacters(in: .whitespaces).isEmpty {
            clientIdError = gatewayName == "Stripe"
                ? "Publishable key is required"
                : "Client ID is required"
        } else if gatewayName == "Stripe" && !clientId.hasPrefix("pk_") {
            clientIdError = "Publishable key must start with pk_live_ or pk_test_"
        }

        if clientSecret.trimmingCharacters(in: .whitespaces).isEmpty {
            clientSecretError = "Secret key is required"
        } else if gatewayName == "Stripe" && !clientSecret.hasPrefix("sk_") {
            clientSecretError = "Secret key must start with sk_live_ or sk_test_"
        }

        return clientIdError == nil && clientSecretError == nil
    }

    // ─── Save ────────────────────────────────────
    func handleSave() {
        guard validate() else { return }
        isSaving = true

        if let existingId = gatewayId {
            // Update
            let req = UpdateGatewayRequest(
                merchantId: merchantId,
                id: String(existingId),
                clientId: clientId,
                clientSecret: clientSecret,
                isActive: isEnabled ? "1" : "0"
            )
            service.updateGateway(request: req) { [weak self] result in
                DispatchQueue.main.async { self?.handleSaveResult(result) }
            }
        } else {
            // Add new
            let req = AddGatewayRequest(
                merchantId: merchantId,
                gatewayName: gatewayName,
                clientId: clientId,
                clientSecret: clientSecret
            )
            service.addGateway(request: req) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    switch result {
                    case .success(let res):
                        if res.error != 0 {
                            self.showToast(res.errorMsg ?? "Failed to save.", isError: true)
                        } else {
                            if let returnId = res.returnId { self.gatewayId = returnId }
                            self.finishSaveSuccess()
                        }
                    case .failure(let err):
                        self.showToast(err.localizedDescription, isError: true)
                    }
                    self.isSaving = false
                }
            }
            return
        }
    }

    private func handleSaveResult(_ result: Result<BaseResponse, Error>) {
        isSaving = false
        switch result {
        case .success(let res):
            if Int(res.error) != 0 {
                showToast(res.errorMsg ?? "Failed to save.", isError: true)
            } else {
                finishSaveSuccess()
            }
        case .failure(let err):
            showToast(err.localizedDescription, isError: true)
        }
    }

    private func finishSaveSuccess() {
        saveSuccess = true
        showToast("\(gatewayName) settings saved successfully.", isError: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.saveSuccess = false
        }
        // Refetch to sync state (mirrors React refetch block)
        refetchAndSync()
    }

    private func refetchAndSync() {
        service.getAllGateways(merchantId: merchantId) { [weak self] result in
            guard let self = self else { return }
            if case .success(let res) = result, res.error == 0 {
                if let gw = res.paymentGateways?.first(where: { $0.gatewayName == self.gatewayName }) {
                    DispatchQueue.main.async {
                        self.gatewayId    = gw.id
                        self.clientId     = gw.clientId ?? ""
                        self.clientSecret = gw.clientSecret ?? ""
                        self.isEnabled    = gw.isEnabled 
                    }
                }
            }
        }
    }

    // ─── Clear Keys ──────────────────────────────
    func handleClearKeys() { showClearConfirm = true }

    func confirmClearKeys() {
        showClearConfirm = false
        guard let id = gatewayId else { return }
        isSaving = true
        service.deleteGateway(merchantId: merchantId, gatewayId: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    if res.error != "0" {
                        self.showToast(res.errorMsg ?? "Failed to clear keys.", isError: true)
                    } else {
                        self.clientId     = ""
                        self.clientSecret = ""
                        self.gatewayId    = nil
                        
                        self.showToast("\(self.gatewayName) keys cleared successfully.", isError: false)
                    }
                case .failure(let err):
                    self.showToast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    // ─── Toast helper ────────────────────────────
    private func showToast(_ msg: String, isError: Bool) {
        toastMessage = msg
        toastIsError = isError
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.toastMessage = nil
        }
    }
}

// ─────────────────────────────────────────────
// SecretV4GatewayViewModel
// Covers KurvPay (PayBito Nexus), HostMerchantServices (PayBito Nova),
// NMI (PayBito Zenith) — identical shape: clientId, clientSecret, secretKeyV4.
// ─────────────────────────────────────────────
final class SecretV4GatewayViewModel: ObservableObject {

    @Published var clientId: String = ""
    @Published var clientSecret: String = ""
    @Published var secretKeyV4: String = ""
    @Published var isEnabled: Bool = false

    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var showClearConfirm: Bool = false

    @Published var clientIdError: String? = nil
    @Published var clientSecretError: String? = nil
    @Published var secretKeyV4Error: String? = nil

    @Published var toastMessage: String? = nil
    @Published var toastIsError: Bool = false

    private(set) var gatewayId: Int? = nil
    let gatewayName: String           // "KurvPay" | "HostMerchantServices" | "NMI"
    let displayName: String           // "PayBito Nexus" | "PayBito Nova" | "PayBito Zenith"
    let merchantId: String
    private let service = PaymentGatewayService.shared

    init(gatewayName: String, displayName: String, merchantId: String) {
        self.gatewayName = gatewayName
        self.displayName = displayName
        self.merchantId  = merchantId
    }

    func populate(from gateway: PaymentGateway?) {
        guard let gw = gateway else { return }
        gatewayId    = gw.id
        clientId     = gw.clientId ?? ""
        clientSecret = gw.clientSecret ?? ""
        secretKeyV4  = gw.secretKeyV4 ?? ""
        isEnabled    = gw.isEnabled
    }

    @discardableResult
    func validate() -> Bool {
        clientIdError = nil
        clientSecretError = nil
        secretKeyV4Error = nil
        guard isEnabled else { return true }

        if clientId.trimmingCharacters(in: .whitespaces).isEmpty {
            clientIdError = "Collect.js Tokenization Key is required"
        }
        if clientSecret.trimmingCharacters(in: .whitespaces).isEmpty {
            clientSecretError = "Secret Key is required"
        }
        if secretKeyV4.trimmingCharacters(in: .whitespaces).isEmpty {
            secretKeyV4Error = "V4 Secret Key is required"
        }
        return clientIdError == nil && clientSecretError == nil && secretKeyV4Error == nil
    }

    func handleSave() {
        guard validate() else { return }
        isSaving = true

        if let existingId = gatewayId {
            let req = UpdateGatewayRequest(
                merchantId: merchantId,
                id: String(existingId),
                clientId: clientId,
                clientSecret: clientSecret,
                isActive: isEnabled ? "1" : "0",
                secretKeyV4: secretKeyV4
            )
            service.updateGateway(request: req) { [weak self] result in
                DispatchQueue.main.async { self?.handleSaveResult(result) }
            }
        } else {
            let req = AddGatewayRequest(
                merchantId: merchantId,
                gatewayName: gatewayName,
                clientId: clientId,
                clientSecret: clientSecret,
                secretKeyV4: secretKeyV4
            )
            service.addGateway(request: req) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isSaving = false
                    switch result {
                    case .success(let res):
                        if res.error != 0 {
                            self.showToast(res.errorMsg ?? "Failed to save \(self.displayName) settings.", isError: true)
                        } else {
                            if let returnId = res.returnId { self.gatewayId = returnId }
                            self.finishSaveSuccess()
                        }
                    case .failure(let err):
                        self.showToast(err.localizedDescription, isError: true)
                    }
                }
            }
        }
    }

    private func handleSaveResult(_ result: Result<BaseResponse, Error>) {
        isSaving = false
        switch result {
        case .success(let res):
            if Int(res.error) != 0 {
                showToast(res.errorMsg ?? "Failed to update \(displayName) settings.", isError: true)
            } else {
                finishSaveSuccess()
            }
        case .failure(let err):
            showToast(err.localizedDescription, isError: true)
        }
    }

    private func finishSaveSuccess() {
        saveSuccess = true
        showToast("\(displayName) settings saved successfully.", isError: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.saveSuccess = false }
        refetchAndSync()
    }

    private func refetchAndSync() {
        service.getAllGateways(merchantId: merchantId) { [weak self] result in
            guard let self = self else { return }
            if case .success(let res) = result, res.error == 0 {
                if let gw = res.paymentGateways?.first(where: { $0.gatewayName == self.gatewayName }) {
                    DispatchQueue.main.async {
                        self.gatewayId    = gw.id
                        self.clientId     = gw.clientId ?? ""
                        self.clientSecret = gw.clientSecret ?? ""
                        self.secretKeyV4  = gw.secretKeyV4 ?? ""
                        self.isEnabled    = gw.isEnabled
                    }
                }
            }
        }
    }

    func handleClearKeys() { showClearConfirm = true }

    func confirmClearKeys() {
        showClearConfirm = false
        guard let id = gatewayId else { return }
        isSaving = true
        // KurvPay/HMS/NMI require secretKeyV4 to be resent alongside delete
        service.deleteGateway(merchantId: merchantId, gatewayId: id, secretKeyV4: secretKeyV4) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    if res.error != "0" {
                        self.showToast(res.errorMsg ?? "Failed to clear \(self.displayName) keys.", isError: true)
                    } else {
                        self.clientId = ""
                        self.clientSecret = ""
                        self.secretKeyV4 = ""
                        self.gatewayId = nil
                        self.showToast("\(self.displayName) keys cleared successfully.", isError: false)
                    }
                case .failure(let err):
                    self.showToast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    private func showToast(_ msg: String, isError: Bool) {
        toastMessage = msg
        toastIsError = isError
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.toastMessage = nil }
    }
}

// ─────────────────────────────────────────────
// NetBillingCardViewModel  (PayBito Vertex)
// Fields: accountId (numeric-only), siteTag, authorization, controlKeyword (optional)
// ─────────────────────────────────────────────
final class NetBillingCardViewModel: ObservableObject {

    @Published var accountId: String = "" {
        didSet {
            let digitsOnly = accountId.filter(\.isNumber)
            if digitsOnly != accountId { accountId = digitsOnly }
        }
    }
    @Published var siteTag: String = ""
    @Published var authorization: String = ""
    @Published var controlKeyword: String = ""
    @Published var isEnabled: Bool = false

    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var showClearConfirm: Bool = false

    @Published var accountIdError: String? = nil
    @Published var siteTagError: String? = nil
    @Published var authorizationError: String? = nil

    @Published var toastMessage: String? = nil
    @Published var toastIsError: Bool = false

    private(set) var gatewayId: Int? = nil
    let merchantId: String
    private let service = PaymentGatewayService.shared

    init(merchantId: String) { self.merchantId = merchantId }

    func populate(from gateway: PaymentGateway?) {
        guard let gw = gateway else { return }
        gatewayId      = gw.id
        accountId      = gw.accountId ?? gw.clientId ?? ""
        siteTag        = gw.siteTag ?? gw.clientSecret ?? ""
        authorization  = gw.authorization ?? ""
        controlKeyword = gw.controlKeyword ?? ""
        isEnabled      = gw.isEnabled
    }

    @discardableResult
    func validate() -> Bool {
        accountIdError = nil
        siteTagError = nil
        authorizationError = nil
        guard isEnabled else { return true }

        if accountId.trimmingCharacters(in: .whitespaces).isEmpty {
            accountIdError = "Account ID is required"
        }
        if siteTag.trimmingCharacters(in: .whitespaces).isEmpty {
            siteTagError = "Site Tag is required"
        }
        if authorization.trimmingCharacters(in: .whitespaces).isEmpty {
            authorizationError = "Authorization is required"
        }
        return accountIdError == nil && siteTagError == nil && authorizationError == nil
    }

    func handleSave() {
        guard validate() else { return }
        isSaving = true

        if let existingId = gatewayId {
            let req = UpdateGatewayRequestNumericActive(
                merchantId: merchantId,
                id: String(existingId),
                gatewayName: GatewayName.netbilling,
                isActive: isEnabled ? 1 : 0,
                accountId: accountId,
                siteTag: siteTag,
                authorization: authorization,
                controlKeyword: controlKeyword
            )
            service.updateGateway(request: req) { [weak self] result in
                DispatchQueue.main.async { self?.handleSaveResult(result) }
            }
        } else {
            let req = AddGatewayRequest(
                merchantId: merchantId,
                gatewayName: GatewayName.netbilling,
                clientId: "",
                clientSecret: "",
                accountId: accountId,
                siteTag: siteTag,
                authorization: authorization,
                controlKeyword: controlKeyword
            )
            service.addGateway(request: req) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isSaving = false
                    switch result {
                    case .success(let res):
                        if res.error != 0 {
                            self.showToast(res.errorMsg ?? "Failed to save PayBito Vertex settings.", isError: true)
                        } else {
                            if let returnId = res.returnId { self.gatewayId = returnId }
                            self.finishSaveSuccess()
                        }
                    case .failure(let err):
                        self.showToast(err.localizedDescription, isError: true)
                    }
                }
            }
        }
    }

    private func handleSaveResult(_ result: Result<BaseResponse, Error>) {
        isSaving = false
        switch result {
        case .success(let res):
            if Int(res.error) != 0 {
                showToast(res.errorMsg ?? "Failed to update PayBito Vertex settings.", isError: true)
            } else {
                finishSaveSuccess()
            }
        case .failure(let err):
            showToast(err.localizedDescription, isError: true)
        }
    }

    private func finishSaveSuccess() {
        saveSuccess = true
        showToast("PayBito Vertex settings saved successfully.", isError: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.saveSuccess = false }
        refetchAndSync()
    }

    private func refetchAndSync() {
        service.getAllGateways(merchantId: merchantId) { [weak self] result in
            guard let self = self else { return }
            if case .success(let res) = result, res.error == 0 {
                if let gw = res.paymentGateways?.first(where: { $0.gatewayName.lowercased() == GatewayName.netbilling }) {
                    DispatchQueue.main.async {
                        self.gatewayId      = gw.id
                        self.accountId      = gw.accountId ?? gw.clientId ?? ""
                        self.siteTag        = gw.siteTag ?? gw.clientSecret ?? ""
                        self.authorization  = gw.authorization ?? ""
                        self.controlKeyword = gw.controlKeyword ?? ""
                        self.isEnabled      = gw.isEnabled
                    }
                }
            }
        }
    }

    func handleClearKeys() { showClearConfirm = true }

    func confirmClearKeys() {
        showClearConfirm = false
        guard let id = gatewayId else { return }
        isSaving = true
        service.deleteGateway(merchantId: merchantId, gatewayId: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    if res.error != "0" {
                        self.showToast(res.errorMsg ?? "Failed to clear PayBito Vertex keys.", isError: true)
                    } else {
                        self.accountId = ""
                        self.siteTag = ""
                        self.authorization = ""
                        self.controlKeyword = ""
                        self.gatewayId = nil
                        self.showToast("PayBito Vertex keys cleared successfully.", isError: false)
                    }
                case .failure(let err):
                    self.showToast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    private func showToast(_ msg: String, isError: Bool) {
        toastMessage = msg
        toastIsError = isError
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.toastMessage = nil }
    }
}

// ─────────────────────────────────────────────
// CardFloCardViewModel  (PayBito Sovereign)
// Fields: clientId (API Key), userName, password, cashierKey — always validated.
// ─────────────────────────────────────────────
final class CardFloCardViewModel: ObservableObject {

    @Published var clientId: String = ""
    @Published var userName: String = ""
    @Published var password: String = ""
    @Published var cashierKey: String = ""
    @Published var isEnabled: Bool = true

    @Published var isSaving: Bool = false
    @Published var saveSuccess: Bool = false
    @Published var showClearConfirm: Bool = false

    @Published var clientIdError: String? = nil
    @Published var userNameError: String? = nil
    @Published var passwordError: String? = nil
    @Published var cashierKeyError: String? = nil

    @Published var toastMessage: String? = nil
    @Published var toastIsError: Bool = false

    private(set) var gatewayId: Int? = nil
    let merchantId: String
    let isTestMode: Bool
    private let service = PaymentGatewayService.shared

    /// Webhook URL the merchant must configure in the PayBito Sovereign dashboard.
    var webhookURL: String {
        isTestMode
            ? "https://accounts.paybito.com/SandboxWebhook/cardflowebhook/\(merchantId)"
            : "https://accounts.paybito.com/WebhookProject/webhook/cardflowebhook/\(merchantId)"
    }

    init(merchantId: String, isTestMode: Bool) {
        self.merchantId = merchantId
        self.isTestMode = isTestMode
    }

    func populate(from gateway: PaymentGateway?) {
        guard let gw = gateway else { return }
        gatewayId   = gw.id
        clientId    = gw.clientId ?? ""
        userName    = gw.userName ?? ""
        password    = gw.password ?? ""
        cashierKey  = gw.cashierKey ?? ""
        isEnabled   = gw.isEnabled
    }

    @discardableResult
    func validate() -> Bool {
        clientIdError = nil
        userNameError = nil
        passwordError = nil
        cashierKeyError = nil

        if clientId.trimmingCharacters(in: .whitespaces).isEmpty {
            clientIdError = "API Key is required"
        }
        if userName.trimmingCharacters(in: .whitespaces).isEmpty {
            userNameError = "Username is required"
        }
        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            passwordError = "Password is required"
        }
        if cashierKey.trimmingCharacters(in: .whitespaces).isEmpty {
            cashierKeyError = "Cashier Key is required"
        }
        return clientIdError == nil && userNameError == nil
            && passwordError == nil && cashierKeyError == nil
    }

    func handleSave() {
        guard validate() else { return }
        isSaving = true

        if let existingId = gatewayId {
            let req = UpdateGatewayRequestNumericActive(
                merchantId: merchantId,
                id: String(existingId),
                gatewayName: GatewayName.cardflo,
                clientId: clientId,
                isActive: isEnabled ? 1 : 0,
                userName: userName,
                password: password,
                cashierKey: cashierKey
            )
            service.updateGateway(request: req) { [weak self] result in
                DispatchQueue.main.async { self?.handleSaveResult(result) }
            }
        } else {
            let req = AddGatewayRequest(
                merchantId: merchantId,
                gatewayName: GatewayName.cardflo,
                clientId: clientId,
                clientSecret: "",
                userName: userName,
                password: password,
                cashierKey: cashierKey
            )
            service.addGateway(request: req) { [weak self] result in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.isSaving = false
                    switch result {
                    case .success(let res):
                        if res.error != 0 {
                            self.showToast(res.errorMsg ?? "Failed to save PayBito Sovereign settings.", isError: true)
                        } else {
                            if let returnId = res.returnId { self.gatewayId = returnId }
                            self.finishSaveSuccess()
                        }
                    case .failure(let err):
                        self.showToast(err.localizedDescription, isError: true)
                    }
                }
            }
        }
    }

    private func handleSaveResult(_ result: Result<BaseResponse, Error>) {
        isSaving = false
        switch result {
        case .success(let res):
            if Int(res.error) != 0 {
                showToast(res.errorMsg ?? "Failed to update PayBito Sovereign settings.", isError: true)
            } else {
                finishSaveSuccess()
            }
        case .failure(let err):
            showToast(err.localizedDescription, isError: true)
        }
    }

    private func finishSaveSuccess() {
        saveSuccess = true
        showToast("PayBito Sovereign settings saved successfully.", isError: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.saveSuccess = false }
        refetchAndSync()
    }

    private func refetchAndSync() {
        service.getAllGateways(merchantId: merchantId) { [weak self] result in
            guard let self = self else { return }

            if case .success(let res) = result, res.error == 0 {

                DispatchQueue.main.async {

                    guard let gw = res.paymentGateways?
                        .first(where: { $0.gatewayName == GatewayName.cardflo }) else {

                        self.gatewayId = nil
                        self.clientId = ""
                        self.userName = ""
                        self.password = ""
                        self.cashierKey = ""
                        self.isEnabled = false
                        return
                    }

                    self.gatewayId = gw.id
                    self.clientId = gw.clientId ?? ""
                    self.userName = gw.userName ?? ""
                    self.password = gw.password ?? ""
                    self.cashierKey = gw.cashierKey ?? ""
                    self.isEnabled = gw.isEnabled
                }
            }
        }
    }

    func handleClearKeys() { showClearConfirm = true }

    func confirmClearKeys() {
        showClearConfirm = false
        guard let id = gatewayId else { return }
        isSaving = true
        service.deleteGateway(merchantId: merchantId, gatewayId: id) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):

                    print("========== DELETE RESPONSE ==========")
                    print("error =", res.error)
                    print("errorMsg =", res.errorMsg ?? "nil")

                    if res.error != "0" {
                        print("DELETE FAILED")
                        self.showToast(res.errorMsg ?? "Failed to clear PayBito Sovereign keys.", isError: true)
                    } else {

                        print("DELETE SUCCESS")

                        self.clientId = ""
                        self.userName = ""
                        self.password = ""
                        self.cashierKey = ""
                        self.gatewayId = nil
                        self.refetchAndSync()

                        print("clientId =", self.clientId)
                        print("userName =", self.userName)
                        print("password =", self.password)
                        print("cashierKey =", self.cashierKey)
                        print("gatewayId =", self.gatewayId as Any)

                        self.showToast("PayBito Sovereign keys cleared successfully.", isError: false)
                    }                case .failure(let err):
                    self.showToast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    private func showToast(_ msg: String, isError: Bool) {
        toastMessage = msg
        toastIsError = isError
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in self?.toastMessage = nil }
    }
}

// ─────────────────────────────────────────────
// PaymentSettingsViewModel  (root)
// mirrors PaymentSettings React component — now wires all 7 gateways
// ─────────────────────────────────────────────
final class PaymentSettingsViewModel: ObservableObject {

    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    let stripeVM: GatewayCardViewModel
    let paypalVM: GatewayCardViewModel
    let kurvPayVM: SecretV4GatewayViewModel       // PayBito Nexus
    let hmsVM: SecretV4GatewayViewModel           // PayBito Nova
    let nmiVM: SecretV4GatewayViewModel           // PayBito Zenith
    let netBillingVM: NetBillingCardViewModel     // PayBito Vertex
    let cardFloVM: CardFloCardViewModel           // PayBito Sovereign

    private let merchantId: String
    private let service = PaymentGatewayService.shared

    init(isTestMode: Bool = false) {
        // Uses same multi-key resolution as BuyerInfoService.extractMerchantId()
        merchantId = AuthManager.merchantId   // String(AuthManager.extractMerchantId())

        stripeVM = GatewayCardViewModel(gatewayName: GatewayName.stripe, merchantId: merchantId)
        paypalVM = GatewayCardViewModel(gatewayName: GatewayName.paypal, merchantId: merchantId)
        kurvPayVM = SecretV4GatewayViewModel(gatewayName: GatewayName.kurvPay, displayName: "PayBito Nexus", merchantId: merchantId)
        hmsVM = SecretV4GatewayViewModel(gatewayName: GatewayName.hms, displayName: "PayBito Nova", merchantId: merchantId)
        nmiVM = SecretV4GatewayViewModel(gatewayName: GatewayName.nmi, displayName: "PayBito Zenith", merchantId: merchantId)
        netBillingVM = NetBillingCardViewModel(merchantId: merchantId)
        cardFloVM = CardFloCardViewModel(merchantId: merchantId, isTestMode: isTestMode)

        fetchGateways()
    }

    func fetchGateways() {
        isLoading = true
        service.getAllGateways(merchantId: merchantId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let res):
                    if res.error != 0 {
                        self.errorMessage = res.errorMsg ?? "Failed to load gateways."
                        return
                    }
                    let gateways = res.paymentGateways ?? []
                    self.stripeVM.populate(from: gateways.first { $0.gatewayName == GatewayName.stripe })
                    self.paypalVM.populate(from: gateways.first { $0.gatewayName == GatewayName.paypal })
                    self.kurvPayVM.populate(from: gateways.first { $0.gatewayName == GatewayName.kurvPay })
                    self.hmsVM.populate(from: gateways.first { $0.gatewayName == GatewayName.hms })
                    self.nmiVM.populate(from: gateways.first { $0.gatewayName == GatewayName.nmi })
                    self.netBillingVM.populate(from: gateways.first { $0.gatewayName.lowercased() == GatewayName.netbilling })
                    self.cardFloVM.populate(from: gateways.first { $0.gatewayName == GatewayName.cardflo })
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
