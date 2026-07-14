// Online Swift compiler to run Swift program online
// Print "Try programiz.pro" message
// DashboardViewModel.swift
import Foundation
import Combine
import SwiftUI

@MainActor
class PaymentDashboardViewModel: ObservableObject {
    
    @Published var uiData = DashboardUIData()
    @Published var recentTransactions: [PaymentTransaction] = []
    @Published var totalTransactionCount = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    @Published var selectedTab: TransactionTab = .all
    @Published var searchText = ""
    @Published var tabCounts: [TransactionTab: Int] = [:]
    @Published var cryptoAssets: [CoinBalance] = []
    
    private let service = DashboardService()
    private var cancellables = Set<AnyCancellable>()
    
    enum TransactionTab: String, CaseIterable {
        case all = "All", succeeded = "Success", failed = "Failed", processing = "Processing", refunded = "Refunded", test = "Test User"
        var statusFilter: String {
            switch self {
            case .all: return ""
            case .succeeded: return "SUCCESS"
            case .failed: return "FAILED"
            case .processing: return "PROCESSING"
            case .refunded: return "REFUNDED"
            case .test: return ""
            }
        }
    }
    
    struct DashboardUIData {
        var totalProcessed: Double = 0
        var totalProcessedChange: Double = 0
        var totalProcessedLabel = "TOTAL PROCESSED (ALL-TIME)"
        
        var bankAccountAdded: Bool = false
        
        var successfulTransactions: Int = 0
        var successRate: Double = 0
        var withdrawalLimit: Double = 0
        var successLabel = "Successful Transactions"
        var availableBalance: Double = 0
        var availableLabel = "Available for Withdrawal"
        var accountStatus: AccountStatus = .inactive
        var withdrawalTier: Int = 1
        var remainingBeforeKyc: String = "0"
        var bankDetailsStatus: BankDetailsStatus = .notSubmitted
        var walletAddressAdded = false
    }
    
    init() {
        Publishers.CombineLatest($selectedTab, $searchText)
            .debounce(for: .milliseconds(400), scheduler: DispatchQueue.main)
            .sink { [weak self] tab, search in
                self?.fetchTransactions(tab: tab, search: search)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch All
    func fetchAllDashboardData() async {
        await fetchDashboardMetrics()
        await fetchAccountData()
        await fetchCryptoAssets()
        fetchTransactions(tab: selectedTab, search: searchText)
    }
    
    // MARK: - Dashboard Metrics
    func fetchDashboardMetrics() async {
        guard let merchantId = getMerchantId() else {
            showErrorMsg("Merchant ID missing")
            return
        }
        await setLoading(true)
        print("\n📊 [VM] Fetching Dashboard Metrics — Merchant: \(merchantId)")
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            service.getDashboardPaymentHistory(merchantId: merchantId) { [weak self] result in
                Task { @MainActor in
                    defer {
                        self?.isLoading = false
                        continuation.resume()
                    }
                    switch result {
                    case .success(let response):
                        print("✅ [VM] Metrics success")
                        self?.processMetrics(response)
                    case .failure(let error):
                        print("❌ [VM] Metrics failed: \(error.localizedDescription)")
                        self?.showErrorMsg(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    private func processMetrics(_ response: DashboardPaymentHistoryResponse) {
        if let vol = response.volumeDetails?.first {
            uiData.totalProcessed = vol.value ?? 0
            uiData.totalProcessedChange = vol.subTextValue ?? 0
            uiData.totalProcessedLabel = vol.labelText ?? uiData.totalProcessedLabel
        }
        
        
        if let pay = response.paymentDetails?.first {
            uiData.successfulTransactions = Int(pay.value ?? 0)
            uiData.successRate = pay.subTextValue ?? 0
            uiData.successLabel = pay.labelText ?? uiData.successLabel
        }
        if let bal = response.balanceDetails?.first {
            uiData.availableBalance = bal.value ?? 0
            uiData.availableLabel = bal.labelText ?? uiData.availableLabel
        }
        print("📊 [VM] processed=\(uiData.totalProcessed), success=\(uiData.successfulTransactions), balance=\(uiData.availableBalance)")
    }
    
    // MARK: - Account Data
    func fetchAccountData() async {
        guard let merchantIdStr = getMerchantIdString() else {
            print("❌ [VM] Merchant ID string missing")
            return
        }
        
        // ── Merchant Status ──
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            service.getMerchantStatus(merchantId: merchantIdStr) { [weak self] result in
                Task { @MainActor [weak self] in
                    defer { continuation.resume() }
                    switch result {
                    case .success(let resp):
                        if resp.error == "0" {
                            // ✅ Account Status: basic_verification_submitted == "1" → Active
                                self?.uiData.accountStatus = (resp.basic_verification_submitted == "1") ? .active : .inactive
                                
                                // ✅ Withdrawable Limit
                                self?.uiData.remainingBeforeKyc = resp.remaining_withdrawable_amt ?? "0"
                            
                            // ✅ Wallet address
                            self?.uiData.walletAddressAdded = (resp.crypto_address_added == "1")
                            
                           
                            // ✅ Bank account
                          //  self?.uiData.bankAccountAdded = (resp.bank_account_added == 1)
                            
                            print("🏪 [VM] Status: \(self?.uiData.accountStatus.rawValue ?? "")")
                            print("🏪 [VM] Wallet: \(resp.crypto_address_added ?? "0")")
                            print("🏪 [VM] Bank: \(resp.bank_account_added ?? "0")")
                            print("🏪 [VM] KYC limit: \(resp.remaining_withdrawable_amt ?? "0")")
                        }
                    case .failure(let error):
                        print("⚠️ [VM] Merchant status (non-fatal): \(error.localizedDescription)")
                    }
                }
            }
        }
        
        // ── User Details (Withdrawal Tier + Bank Status) ──
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            service.getUserDetails { [weak self] result in
                Task { @MainActor [weak self] in
                    defer { continuation.resume() }
                    switch result {
                    case .success(let resp):
                        // ✅ userTierType from API
                        self?.uiData.withdrawalTier = resp.userTierType ?? 1
                        // ✅ bankDetailsStatus mapping
                        switch resp.bankDetailsStatus {
                        case "0": self?.uiData.bankDetailsStatus = .submitted
                        case "2": self?.uiData.bankDetailsStatus = .completed
                        case "3": self?.uiData.bankDetailsStatus = .rejected
                        default:  self?.uiData.bankDetailsStatus = .notSubmitted
                        }
                        print("👤 [VM] Tier: \(self?.uiData.withdrawalTier ?? 1)")
                        print("👤 [VM] Bank status: \(self?.uiData.bankDetailsStatus.displayText ?? "")")
                    case .failure(let error):
                        print("⚠️ [VM] User details (non-fatal): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Transactions
    func fetchTransactions(tab: TransactionTab, search: String) {
        guard let merchantId = getMerchantId() else {
            print("❌ [VM] Merchant ID missing for transactions")
            return
        }
        
        let status = (tab == .test) ? "" : tab.statusFilter
        let request = TransactionFilterRequest(
            merchantId: merchantId,
            status: status,
            paymentMethod: "",
            network: "",
            search: search,
            productName: "",
            catalogueName: "",
            subscriptionId: "",
            customerId: "",
            customerIdentity: "",
            paymentType: "",
            currency: "",
            dateRange: "ALL",
            fromDate: "",
            toDate: "",
            page: 1,
            pageSize: 10
        )
        
        print("📋 [VM] Fetching transactions: tab=\(tab.rawValue), search=\(search)")
        isLoading = true
        
        service.getTransactionsByFilter(request: request) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let resp):
                    var txns = resp.transactions ?? []
                    if tab == .test {
                        // ✅ testMode is Int — use isTestMode computed property
                        txns = txns.filter { $0.isTestMode }
                    }
                    self?.recentTransactions = txns
                    self?.totalTransactionCount = resp.totalCount ?? 0
                    self?.tabCounts[.all] = resp.totalCount ?? 0
                    self?.tabCounts[.succeeded] = resp.succeededCount ?? 0
                    self?.tabCounts[.failed] = resp.failedCount ?? 0
                    self?.tabCounts[.refunded] = resp.refundedCount ?? 0
                    self?.tabCounts[.processing] = 0
                    // ✅ isTestMode computed property
                    self?.tabCounts[.test] = (resp.transactions ?? []).filter { $0.isTestMode }.count
                    print("✅ [VM] Loaded \(txns.count) transactions")
                case .failure(let err):
                    // ✅ non-fatal — just print
                    print("📋 [VM] Transactions failed (non-fatal): \(err.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Crypto Assets
    func fetchCryptoAssets() async {
        guard let merchantId = getMerchantIdString() else {
            print("❌ [VM] Merchant ID missing for crypto assets")
            return
        }
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            service.fetchUsdBtcLedgerAmount(merchantId: merchantId) { [weak self] result in
                Task { @MainActor in
                    defer { continuation.resume() }
                    switch result {
                    case .success(let resp):
                        print("💰 [VM] error=\(resp.error ?? "nil"), coins=\(resp.coin_balance?.count ?? 0)")
                        if let balances = resp.coin_balance {
                            self?.cryptoAssets = balances.filter { $0.currency_code != "USD" }
                            if let data = try? JSONEncoder().encode(self?.cryptoAssets) {
                                UserDefaults.standard.set(data, forKey: "\(ConfigurationD.SITENAME_ALIAS)_assets")
                            }
                            print("💰 [VM] Saved \(self?.cryptoAssets.count ?? 0) crypto assets")
                        }
                    case .failure(let error):
                        print("💰 [VM] Crypto failed (non-fatal): \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func getMerchantId() -> Int? {
        let key = "Bmerchant_id"
        guard let str = UserDefaults.standard.string(forKey: key) else {
            print("❌ [VM] Merchant ID not found for key:", key)
            return nil
        }
        let id = Int(str)
        if id == nil { print("❌ [VM] Failed to convert merchant ID: \(str)") }
        else { print("✅ [VM] Merchant ID: \(id!)") }
        return id
    }
    
    private func getMerchantIdString() -> String? {
        let key = "Bmerchant_id"
        let value = UserDefaults.standard.string(forKey: key)
        if value == nil { print("❌ [VM] Merchant ID string not found") }
        return value
    }
    
    private func setLoading(_ loading: Bool) async {
        await MainActor.run { self.isLoading = loading }
    }
    
    private func showErrorMsg(_ msg: String) {
        errorMessage = msg
        showError = true
        print("⚠️ [VM] Error: \(msg)")
    }
    
    // MARK: - Formatting
    func formatCurrency(_ amount: Double, currency: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        if currency == "USD" { formatter.currencySymbol = "$" }
        else if currency == "EUR" { formatter.currencySymbol = "€" }
        else if currency == "GBP" { formatter.currencySymbol = "£" }
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currency) \(amount)"
    }
    
    func formatDate(_ dateStr: String?) -> String {
        guard let dateStr else { return "—" }
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        if let date = fmt.date(from: dateStr) {
            fmt.dateFormat = "MMM dd, yyyy"
            return fmt.string(from: date)
        }
        return dateStr
    }
    
    func statusLabel(_ status: String?) -> String {
        let map = [
            "payment_created": "Payment Created",
            "payment_processing": "Payment Processing",
            "payment_initiated": "Payment Initiated",
            "payment_confirmed": "Payment Confirmed",
            "closed_with_autometic_overpayment": "Closed with Overpayment",
            "closed_with_exact_payment": "Closed",
            "closed_with_manual_overpayment": "Closed with Overpayment",
            "closed_with_underpayment": "Closed with Underpayment",
            "invoice_expired": "Expired",
            "payment_failed": "Failed",
            "refunded": "Refunded",
            "refund_approved": "Refund Approved",
            "refund_requested": "Refund Requested",
            "succeeded": "Succeeded",
            "success": "Success",
            "failed": "Failed",
            "pending": "Pending",
            "processing": "Processing"
        ]
        let key = (status ?? "").lowercased()
        return map[key] ?? key.capitalized.replacingOccurrences(of: "_", with: " ")
    }
    
    func statusColor(_ status: String?) -> Color {
        let s = (status ?? "").lowercased()
        if ["success", "succeeded", "payment_confirmed"].contains(s) { return .bbAccentGreen }
        if ["failed", "invoice_expired", "payment_failed"].contains(s) { return .red }
        if ["refunded", "refund_approved"].contains(s) { return .blue }
        return .orange
    }
    
    func statusBadgeColor(_ status: String?) -> Color {
        statusColor(status).opacity(0.15)
    }
    
    
    
    func fetchDashboardData() async {
        // ── Fetch broker info first so domain is ready for payment links ──
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            service.fetchBrokerWiseExchangeInfo {
                continuation.resume()
            }
        }

        await fetchDashboardMetrics()
        await fetchAccountData()
        await fetchCryptoAssets()
        fetchTransactions(tab: selectedTab, search: searchText)
    }
    
    
}
