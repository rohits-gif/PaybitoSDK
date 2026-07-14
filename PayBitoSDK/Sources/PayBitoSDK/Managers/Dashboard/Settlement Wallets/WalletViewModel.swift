////import Foundation
////import Combine
////
////@MainActor
////class WalletViewModel: ObservableObject {
////
////    // MARK: - Published State
////
////    @Published var assets: [WalletAsset] = []
////    @Published var transactions: [UserTransaction] = []
////    @Published var ledger: LedgerData? = nil
////
////    @Published var isLoadingAssets = false
////    @Published var isLoadingTransactions = false
////    @Published var errorMessage: String? = nil
////    @Published var successMessage: String? = nil
////
////    // Pagination
////    @Published var currentPage = 1
////    @Published var totalPages = 1
////    @Published var totalCount = 0
////
////    // Withdraw sheet state
////    @Published var selectedAsset: WalletAsset? = nil
////    @Published var showWithdrawSheet = false
////    @Published var selectedWithdrawOption: WithdrawOption? = nil
////    @Published var isWithdrawing = false
////
////    // MARK: - Auth (MUST be set before calling APIs)
////
////    var merchantId: Int = 0
////    var token: String = ""
////    var uuid: String = ""
////
////    private let api = WalletAPIService.shared
////
////    // MARK: - Auth Check
////
////    private var isValidAuth: Bool {
////        return merchantId > 0 && !token.isEmpty && !uuid.isEmpty
////    }
////
////    // MARK: - Load All
////
////    func loadAll() {
////
////        print("========== WALLET AUTH DEBUG ==========")
////
////            print("merchantId => \(merchantId)")
////
////            print("token empty => \(token.isEmpty)")
////
////            print("token => \(token)")
////
////            print("uuid empty => \(uuid.isEmpty)")
////
////            print("uuid => \(uuid)")
////
////            print("=======================================")
////
////        guard isValidAuth else {
////            errorMessage = "Missing authentication"
////            return
////        }
////
////        fetchAssets()
////        fetchTransactions(page: 1)
////        fetchLedger()
////    }
////
////    // MARK: - Fetch Assets
////
////    func fetchAssets() {
////        guard isValidAuth else { return }
////
////        isLoadingAssets = true
////        errorMessage = nil
////
////        api.fetchWalletAssets(
////            merchantId: merchantId,
////            token: token,
////            uuid: uuid
////        ) { [weak self] result in
////
////            Task { @MainActor in
////                guard let self else { return }
////
////                self.isLoadingAssets = false
////
////                switch result {
////                case .success(let assets):
////                    self.assets = assets
////
////                case .failure(let error):
////                    self.errorMessage = error.localizedDescription
////                }
////            }
////        }
////    }
////
////    // MARK: - Fetch Transactions
////
////    func fetchTransactions(page: Int) {
////
////        guard isValidAuth else { return }
////
////        isLoadingTransactions = true
////        currentPage = page
////
////        api.fetchUserTransactions(
////            merchantId: merchantId,
////            page: page,
////            pageSize: 10,
////            token: token,
////            uuid: uuid
////        ) { [weak self] result in
////
////            Task { @MainActor in
////
////                guard let self else { return }
////
////                self.isLoadingTransactions = false
////
////                switch result {
////
////                case .success(let res):
////
////                    self.transactions = res.trxnList ?? []
////
////                    self.totalCount = res.totalCount ?? 0
////
////                    self.totalPages = 1
////
////                case .failure(let error):
////
////                    self.errorMessage = error.localizedDescription
////                }
////            }
////        }
////    }
////
////    // MARK: - Fetch Ledger
////
////    func fetchLedger() {
////        guard isValidAuth else { return }
////
////        api.fetchLedgerBalance(
////            merchantId: merchantId,
////            token: token,
////            uuid: uuid
////        ) { [weak self] result in
////
////            Task { @MainActor in
////                guard let self else { return }
////
////                switch result {
////                case .success(let data):
////                    self.ledger = data
////
////                case .failure:
////                    break // non-critical
////                }
////            }
////        }
////    }
////
////    // MARK: - Withdraw Dispatcher
////
////    func submitWithdraw(option: WithdrawOption, params: [String: Any]) {
////        guard isValidAuth else {
////            errorMessage = "Missing authentication"
////            return
////        }
////
////        guard let assetId = selectedAsset?.assetId else {
////            errorMessage = "No asset selected"
////            return
////        }
////
////        isWithdrawing = true
////        errorMessage = nil
////
////        switch option {
////
////        case .externalWallet:
////            handleExternalWithdraw(assetId: assetId, params: params)
////
////        case .paybitoWallet:
////            handlePaybitoWithdraw(assetId: assetId, params: params)
////
////        case .bankAccount:
////            handleBankWithdraw(params: params)
////        }
////    }
////
////    // MARK: - Withdraw Handlers
////
////    private func handleExternalWithdraw(assetId: String, params: [String: Any]){
////        guard
////            let address = params["walletAddress"] as? String,
////            let amount  = params["amount"] as? Double
////        else {
////            isWithdrawing = false
////            errorMessage = "Invalid external wallet params"
////            return
////        }
////
////        let req = ExternalWithdrawRequest(
////            merchantId: merchantId,
////            assetId: assetId,
////            amount: amount,
////            walletAddress: address,
////            network: params["network"] as? String,
////            twoFACode: params["twoFACode"] as? String
////        )
////
////        api.withdrawToExternalWallet(
////            request: req,
////            token: token,
////            uuid: uuid
////        ) { [weak self] result in
////            self?.handleWithdrawResult(result)
////        }
////    }
////
////    private func handlePaybitoWithdraw(assetId: String, params: [String: Any]) {
////
////        guard
////            let userId = params["paybitoUserId"] as? String,
////            let amount = params["amount"] as? Double
////        else {
////            isWithdrawing = false
////            errorMessage = "Invalid Paybito params"
////            return
////        }
////
////        let req = PayBitoTransferRequest(
////            merchantId: merchantId,
////            assetId: assetId,
////            amount: amount,
////            paybitoUserId: userId
////        )
////
////        api.transferToPaybitoWallet(
////            request: req,
////            token: token,
////            uuid: uuid
////        ) { [weak self] result in
////            self?.handleWithdrawResult(result)
////        }
////    }
////
////    private func handleBankWithdraw(params: [String: Any]) {
////
////        guard
////            let bankId = params["bankAccountId"] as? Int,
////            let amount = params["amount"] as? Double
////        else {
////            isWithdrawing = false
////            errorMessage = "Invalid bank params"
////            return
////        }
////
////        let req = BankWithdrawRequest(
////            merchantId: merchantId,
////            amount: amount,
////            bankAccountId: bankId
////        )
////
////        api.withdrawToBankAccount(
////            request: req,
////            token: token,
////            uuid: uuid
////        ) { [weak self] result in
////            self?.handleWithdrawResult(result)
////        }
////    }
////
////    // MARK: - Withdraw Result
////
////    private func handleWithdrawResult(_ result: Swift.Result<GenericWalletResponse, Error>) {
////
////        Task { @MainActor in
////            self.isWithdrawing = false
////
////            switch result {
////
////            case .success(let res):
////                if res.status == true {
////                    self.successMessage = res.message ?? "Withdrawal successful"
////                    self.showWithdrawSheet = false
////
////                    self.fetchAssets()
////                    self.fetchTransactions(page: 1)
////
////                } else {
////                    self.errorMessage = res.message ?? "Withdrawal failed"
////                }
////
////            case .failure(let error):
////                self.errorMessage = error.localizedDescription
////            }
////        }
////    }
////}
//
//
//
//
//
//
//
//
//
////
////  WalletViewModel.swift
////  Trading_Terminal
////
////  Uses Swift.Result explicitly to avoid Alamofire ambiguity.
////
//
//import Foundation
//import Combine
//
//@MainActor
//class WalletViewModel: ObservableObject {
//
//    // MARK: - Published State
//
//    @Published var assets: [WalletAsset]          = []
//    @Published var transactions: [UserTransaction] = []
//    @Published var ledger: LedgerData?             = nil
//
//    @Published var isLoadingAssets       = false
//    @Published var isLoadingTransactions = false
//    @Published var errorMessage: String?   = nil
//    @Published var successMessage: String? = nil
//
//    @Published var currentPage = 1
//    @Published var totalPages  = 1
//    @Published var totalCount  = 0
//
//    @Published var selectedAsset: WalletAsset?          = nil
//    @Published var showWithdrawSheet                    = false
//    @Published var selectedWithdrawOption: WithdrawOption? = nil
//    @Published var isWithdrawing                        = false
//
//    @Published var cryptoAddressInfo: CryptoAddressResponse? = nil
//    @Published var isLoadingCryptoAddress = false
//
//    @Published var paybitoFees: FeesByCurrencyResponse?  = nil
//    @Published var isLoadingFees                         = false
//    @Published var showPaybitoTransferView               = false
//
//    // MARK: - Auth
//
//    var merchantId: Int = 0
//    var token: String   = ""
//    var uuid: String    = ""
//
//    private let api = WalletAPIService.shared
//
//    private var isValidAuth: Bool {
//        merchantId > 0 && !token.isEmpty && !uuid.isEmpty
//    }
//
//    // MARK: - Load All
//
//    func loadAll() {
//        print("========== WALLET AUTH DEBUG ==========")
//        print("merchantId => \(merchantId)")
//        print("token      => \(token.prefix(40))...")
//        print("uuid       => \(uuid)")
//        print("=======================================")
//        guard isValidAuth else { errorMessage = "Missing authentication"; return }
//        fetchAssets()
//        fetchTransactions(page: 1)
//        fetchLedger()
//    }
//
//    // MARK: - Fetch Assets
//
//    func fetchAssets() {
//        guard isValidAuth else { return }
//        isLoadingAssets = true
//        errorMessage    = nil
//
//        api.fetchWalletAssets(merchantId: merchantId, token: token, uuid: uuid) { [weak self] (result: Swift.Result<[WalletAsset], Error>) in
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                self.isLoadingAssets = false
//                switch result {
//                case .success(let assets): self.assets = assets
//                case .failure(let error):  self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//
//    // MARK: - Fetch Transactions
//
//    func fetchTransactions(page: Int) {
//        guard isValidAuth else { return }
//        isLoadingTransactions = true
//        currentPage           = page
//
//        api.fetchUserTransactions(
//            merchantId: merchantId, page: page, pageSize: 10,
//            token: token, uuid: uuid
//        ) { [weak self] (result: Swift.Result<UserTransactionsWResponse, Error>) in
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                self.isLoadingTransactions = false
//                switch result {
//                case .success(let res):
//                    self.transactions = res.trxnList ?? []
//                    self.totalCount   = res.totalCount ?? 0
//                    self.totalPages   = 1
//                case .failure(let error):
//                    self.errorMessage = error.localizedDescription
//                }
//            }
//        }
//    }
//
//    // MARK: - Fetch Ledger
//
//    func fetchLedger() {
//        guard isValidAuth else { return }
//        api.fetchLedgerBalance(merchantId: merchantId, token: token, uuid: uuid) { [weak self] (result: Swift.Result<LedgerData, Error>) in
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                if case .success(let data) = result { self.ledger = data }
//            }
//        }
//    }
//
//    // MARK: - Step 1: Withdraw Tapped → getCryptoAddress
//
//    func onWithdrawTapped(asset: WalletAsset) {
//        guard isValidAuth else { errorMessage = "Missing authentication"; return }
//        selectedAsset          = asset
//        cryptoAddressInfo      = nil
//        paybitoFees            = nil
//        isLoadingCryptoAddress = true
//
//        api.getCryptoAddress(
//            currencyId: asset.assetId,
//            merchantId: merchantId,
//            token: token,
//            uuid: uuid
//        ) { [weak self] (result: Swift.Result<CryptoAddressResponse, Error>) in
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                self.isLoadingCryptoAddress = false
//                switch result {
//                case .success(let info):
//                    self.cryptoAddressInfo = info
//                    self.showWithdrawSheet = true
//                case .failure(let error):
//                    self.errorMessage = "Could not load address: \(error.localizedDescription)"
//                }
//            }
//        }
//    }
//
//    // MARK: - Step 2a: PayBito Selected → getFeesByCurrencyId
//
//    func onPaybitoSelected() {
//        guard let asset = selectedAsset, isValidAuth else { return }
//        showWithdrawSheet      = false
//        selectedWithdrawOption = .paybitoWallet
//        paybitoFees            = nil
//        isLoadingFees          = true
//
//        // Pass network_type from getCryptoAddress response — required by fees API
//        let networkType = cryptoAddressInfo?.networkType
//
//        api.getFeesByCurrency(
//            currencyId: asset.assetId,
//            merchantId: merchantId,
//            networkType: networkType,
//            token: token,
//            uuid: uuid
//        ) { [weak self] (result: Swift.Result<FeesByCurrencyResponse, Error>) in
//            Task { @MainActor [weak self] in
//                guard let self = self else { return }
//                self.isLoadingFees = false
//                switch result {
//                case .success(let fees):
//                    self.paybitoFees            = fees
//                    self.showPaybitoTransferView = true
//                case .failure(let error):
//                    self.errorMessage          = "Could not load fees: \(error.localizedDescription)"
//                    self.selectedWithdrawOption = nil
//                }
//            }
//        }
//    }
//
//    // MARK: - Step 2b/2c: Other options
//
//    func onExternalWalletSelected() {
//        showWithdrawSheet      = false
//        selectedWithdrawOption = .externalWallet
//    }
//
//    func onBankAccountSelected() {
//        showWithdrawSheet      = false
//        selectedWithdrawOption = .bankAccount
//    }
//
//    // MARK: - Step 3a: Submit PayBito Transfer
//
//    func submitPaybitoTransfer(amount: Double) {
//        guard let asset = selectedAsset, isValidAuth else {
//            errorMessage = "Missing asset or auth"; return
//        }
//        isWithdrawing = true
//        errorMessage  = nil
//
//        let req = PayBitoTransferRequest(
//            merchantId: merchantId,
//            currencyId: asset.assetId,
//            amount: amount
//        )
//        api.withdrawToPaybito(request: req, token: token, uuid: uuid) { [weak self] (result: Swift.Result<GenericWalletResponse, Error>) in
//            self?.handleWithdrawResult(result)
//        }
//    }
//
//    // MARK: - Step 3b: Submit External Withdraw
//
//    func submitExternalWithdraw(address: String, amount: Double) {
//        guard let asset = selectedAsset, isValidAuth else {
//            errorMessage = "Missing asset or auth"; return
//        }
//        isWithdrawing = true
//        errorMessage  = nil
//
//        let req = ExternalWithdrawRequest(
//            merchantId: merchantId,
//            assetId: asset.assetId,
//            amount: amount,
//            walletAddress: address,
//            network: nil,
//            twoFACode: nil
//        )
//        api.withdrawToExternalWallet(request: req, token: token, uuid: uuid) { [weak self] (result: Swift.Result<GenericWalletResponse, Error>) in
//            self?.handleWithdrawResult(result)
//        }
//    }
//
//    // MARK: - Step 3c: Submit Bank Withdraw
//
//    func submitBankWithdraw(bankAccountId: Int, amount: Double) {
//        guard isValidAuth else { errorMessage = "Missing auth"; return }
//        isWithdrawing = true
//        errorMessage  = nil
//
//        let req = BankWithdrawRequest(merchantId: merchantId, amount: amount, bankAccountId: bankAccountId)
//        api.withdrawToBankAccount(request: req, token: token, uuid: uuid) { [weak self] (result: Swift.Result<GenericWalletResponse, Error>) in
//            self?.handleWithdrawResult(result)
//        }
//    }
//
//    // MARK: - Withdraw Result Handler
//
//    private func handleWithdrawResult(_ result: Swift.Result<GenericWalletResponse, Error>) {
//        Task { @MainActor in
//            self.isWithdrawing = false
//            switch result {
//            case .success(let res):
//                if res.status == true {
//                    self.successMessage          = res.message ?? "Withdrawal successful"
//                    self.showWithdrawSheet        = false
//                    self.showPaybitoTransferView  = false
//                    self.selectedWithdrawOption   = nil
//                    self.fetchAssets()
//                    self.fetchTransactions(page: 1)
//                } else {
//                    self.errorMessage = res.message ?? "Withdrawal failed"
//                }
//            case .failure(let error):
//                self.errorMessage = error.localizedDescription
//            }
//        }
//    }
//
//    // MARK: - Dismiss All
//
//    func dismissAll() {
//        showWithdrawSheet       = false
//        showPaybitoTransferView = false
//        selectedWithdrawOption  = nil
//        selectedAsset           = nil
//        cryptoAddressInfo       = nil
//        paybitoFees             = nil
//    }
//}



//
//  SettlementViewModel.swift
//  SettlementWallet
//
//  Single source of truth for all settlement wallet state.
//  Mirrors Dashboard.jsx state declarations and handler functions 1-to-1.
//

import Foundation
import Combine

@MainActor
final class SettlementViewModel: ObservableObject {

    private let service = SettlementService.shared

    // MARK: ──────────────────────────────────────────────
    // MARK: Auth (injected from parent / UserDefaults)
    // MARK: ──────────────────────────────────────────────

    var merchantId: String { UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "" }
    var authToken:  String { UserDefaults.standard.string(forKey: "Baccess_token") ?? "" }
    var authUuid:   String { UserDefaults.standard.string(forKey: "Buuid") ?? "" }
    var userEmail:  String { UserDefaults.standard.string(forKey: "Bemail") ?? "" }
    var brokerId: String {

        UserDefaults.standard.string(forKey: "brokerId")

        ?? "PAYB18022021121103"

    }
    var exchangeUuid: String { UserDefaults.standard.string(forKey: "Bexchange_uuid") ?? "" }
    var homeCurrency: String { UserDefaults.standard.string(forKey: "Bhome_currency") ?? "USD" }
    var isGoogleAuthEnabled: Bool {

        let value = UserDefaults.standard.object(forKey: "Bis_google_auth_enabled")

        print("Google Auth Value:", value ?? "nil")

        return UserDefaults.standard.string(forKey: "Bis_google_auth_enabled") == "1"

    }

    // MARK: ──────────────────────────────────────────────
    // MARK: Dashboard Data
    // MARK: ──────────────────────────────────────────────

    @Published var assets: [SettlementAsset] = []
    @Published var transactions: [SettlementTransaction] = []
    @Published var totalTransactionCount: Int = 0
    @Published var currentPage: Int = 1
    let pageSize: Int = 20

    @Published var isLoadingAssets:       Bool = false
    @Published var isLoadingTransactions: Bool = false

    // MARK: ──────────────────────────────────────────────
    // MARK: Withdraw Flow — shared
    // MARK: ──────────────────────────────────────────────


    @Published var selectedAsset: SettlementAsset? = nil
    @Published var activeWithdrawType: WithdrawType? = nil

    // Sheet visibility
    @Published var showWithdrawTypeSheet:    Bool = false
    @Published var showNetworkSelectSheet:   Bool = false
    @Published var showExternalAddressForm:  Bool = false
    @Published var showExternalAuthModal:    Bool = false
    @Published var showExchangeTransferForm: Bool = false
    @Published var showExchangeAuthModal:    Bool = false   // Google Auth TOTP gate
    @Published var showBankTransferForm:     Bool = false
    @Published var showKycStatusModal:       Bool = false

    // MARK: ──────────────────────────────────────────────
    // MARK: Network / Token selection (USDT ERC20 vs TRC20)
    // MARK: ──────────────────────────────────────────────

    @Published var selectedNetwork: String? = nil   // e.g. "erc" / "trc"
    @Published var availableNetworks: [String] = []
    @Published var networkLabel: String = ""        // "ERC 20" / "BTC" etc.

    // MARK: ──────────────────────────────────────────────
    // MARK: External Wallet Form State
    // Mirrors: externalAddress, savedBitcoinAddresses, addressEntryMode,
    //          isValidCryptoMsg, classForValidCrypto, addressValid,
    //          amountForTransferToExternalAddress, coinTagValue, networkFee
    // MARK: ──────────────────────────────────────────────

    @Published var savedAddresses: [SavedCryptoAddress] = []
    @Published var addressEntryMode: AddressEntryMode = .manual
    @Published var externalAddress: String = ""
    @Published var addressValidationState: WalletAddressValidationState = .idle
    @Published var isValidatingAddress: Bool = false

    @Published var externalAmount: String = ""
    @Published var externalAmountError: String = ""
    @Published var coinTagValue: String = ""         // Memo / Tag for HCX, XRP, HCNET
    @Published var networkFee: String = ""           // Estimated network fee display
    @Published var isLoadingFees: Bool = false

    // Limits from getFeesByCurrencyId
    @Published var feesInfo: CurrencyFeesResponse? = nil

    var minSend: Double { feesInfo?.minSendAmount ?? 0 }
    var maxSend: Double { feesInfo?.maxSendAmount ?? 0 }

    // MARK: ──────────────────────────────────────────────
    // MARK: External Auth state
    // Mirrors: externalWalletEmailAuthOtp, externalWalletGoogleAuthCode,
    //          isTimerStartForExternalWalletGetCode, getCodeTimer
    // MARK: ──────────────────────────────────────────────

    @Published var externalEmailOTP: String = ""
    @Published var externalGoogleAuthCode: String = ""
    @Published var externalOtpTimerSeconds: Int = 0
    @Published var isExternalOtpTimerActive: Bool = false

    private var externalOtpTimer: Timer? = nil

    // MARK: ──────────────────────────────────────────────
    // MARK: Exchange / PayBito Transfer State
    // Mirrors: amount (in transferModal), isLoggedInToExchange,
    //          fromFee, toFee, showPaybitoSecurityAuthTranscationModal
    // MARK: ──────────────────────────────────────────────

    @Published var exchangeTransferAmount: String = ""
    @Published var exchangeTransferAmountError: String = ""
    @Published var exchangeGoogleAuthCode: String = ""
    @Published var isExchangeTransferAmountValid: Bool = false
    @Published var isSubmittingExchange: Bool = false

    // Cached after getFeesByCurrencyId for exchange flow
    @Published var exchangeFeesInfo: CurrencyFeesResponse? = nil
    var exchangeFromFee: String { exchangeFeesInfo?.fromFee ?? "0" }
    var exchangeToFee:   String { exchangeFeesInfo?.toFee   ?? "0" }

    // MARK: ──────────────────────────────────────────────
    // MARK: Bank Withdrawal State
    // Mirrors: cryptoAmountForBank, fiatEquivalentAmount, googleAuthOtpForBankWithdraw,
    //          merchantBankDetails, fiatMarketPrice, bankWithdrawLimit,
    //          userDocsStatus, bankDetailsStatus, userTierType
    // MARK: ──────────────────────────────────────────────

    @Published var userDocsStatus: UserDocsStatus = .missing
    @Published var bankDetailsStatus: String? = nil
    @Published var userTierType: String? = nil
    @Published var merchantBankDetails: BanksDetails? = nil
    @Published var fiatMarketPrice: Double = 0
    @Published var bankWithdrawMin: Double = 0
    @Published var bankWithdrawMax: Double = 0

    @Published var cryptoAmountForBank: String = ""
    @Published var fiatEquivalentAmount: String = ""
    @Published var bankGoogleAuthCode: String = ""
    @Published var bankAmountError: String = ""
    @Published var isSubmittingBank: Bool = false

    var isBankWithdrawDisabled: Bool {
        guard let fiat = Double(fiatEquivalentAmount), fiat > 0 else { return true }
        guard bankGoogleAuthCode.count == 6 else { return true }
        guard fiat >= bankWithdrawMin else { return true }
        guard fiat <= bankWithdrawMax else { return true }
        return false
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: Global feedback
    // MARK: ──────────────────────────────────────────────

    @Published var successMessage: String? = nil
    @Published var errorMessage:   String? = nil
    @Published var isLoading: Bool = false

    // MARK: ──────────────────────────────────────────────
    // MARK: isTestMode — mirrors React isTestMode guard
    // MARK: ──────────────────────────────────────────────

    var isTestMode: Bool {
        UserDefaults.standard.bool(forKey: "BisTestMode")
    }

    // MARK: ══════════════════════════════════════════════
    // MARK: LOAD ALL — called on onAppear
    // MARK: ══════════════════════════════════════════════

    func loadAll() {
        Task { await fetchLedgerAssets() }
        Task { await fetchTransactions() }
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 1. Fetch Ledger Assets
    //    Mirrors: handleRenderLedgerAmount()
    // MARK: ──────────────────────────────────────────────

    func fetchLedgerAssets() async {
        isLoadingAssets = true
        do {
            let response = try await service.fetchLedgerAmount(merchantId: merchantId)
            if let err = response.error, err != "0" {
                errorMessage = response.errorMsg ?? "Failed to load assets"
            } else {
                // Mirror React filter: !(iter.currency_type === "1" && iter.coinBalance === "0")
                assets = (response.coinBalance ?? []).filter { asset in
                    !(asset.isFiat && asset.balance == "0")
                }
            }
        } catch {
            print("ERROR:", error)

            if let decodingError = error as? DecodingError {
                print("DECODING ERROR:", decodingError)
            }

            errorMessage = error.localizedDescription
        }
        isLoadingAssets = false
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: 2. Fetch Transactions
    //    Mirrors: renderUserTransactions()
    // MARK: ──────────────────────────────────────────────

    func fetchTransactions(page: Int? = nil) async {
        let p = page ?? currentPage
        isLoadingTransactions = true
        do {
            let response = try await service.getUserTransactions(
                userId: merchantId, pageNo: p, pageSize: pageSize
            )
            if let err = response.error, err != "0" {
                errorMessage = response.errorMsg ?? "Failed to load transactions"
            } else {
                transactions = response.trxnList ?? []
                totalTransactionCount = response.totalCount ?? 0
                currentPage = p
            }
        } catch {
            print("ERROR:", error)

            if let decodingError = error as? DecodingError {
                print("DECODING ERROR:", decodingError)
            }

            errorMessage = error.localizedDescription
        }
        isLoadingTransactions = false
    }

    // MARK: ══════════════════════════════════════════════
    // MARK: WITHDRAW ENTRY POINT
    //    Mirrors: handleCriptoWithdraw()
    // MARK: ══════════════════════════════════════════════

    func handleWithdrawTapped(asset: SettlementAsset) {
        guard !asset.isFiat else { return }
        selectedAsset = asset

        // USDT (id==16) requires network selection first — mirrors React
        if asset.currencyId == "16" {
            availableNetworks = asset.network ?? []
            selectedNetwork = nil
            showNetworkSelectSheet = true
        } else {
            availableNetworks = asset.network ?? []
            selectedNetwork = nil
            Task { await fetchSavedAddressesAndOpenWithdrawSheet(asset: asset) }
        }
    }

    /// After network is selected for multi-network coins (USDT)
    func onNetworkSelected(_ network: String) {
        selectedNetwork = network
        showNetworkSelectSheet = false
        guard let asset = selectedAsset else { return }
        Task { await fetchSavedAddressesAndOpenWithdrawSheet(asset: asset) }
    }

    private func fetchSavedAddressesAndOpenWithdrawSheet(asset: SettlementAsset) async {
        isLoading = true
        savedAddresses = (try? await service.getCryptoAddresses(
            currencyId: asset.currencyId,
            merchantId: merchantId
        )) ?? []
        isLoading = false
        // Reset external form state
        externalAddress = ""
        coinTagValue = ""
        addressValidationState = .idle
        addressEntryMode = .manual
        showWithdrawTypeSheet = true
    }

    // MARK: ══════════════════════════════════════════════
    // MARK: TYPE SELECTION
    // MARK: ══════════════════════════════════════════════

    func onWithdrawTypeSelected(_ type: WithdrawType) {
        showWithdrawTypeSheet = false
        switch type {
        case .exchange: handleExchangeWithdrawTapped()
        case .external: handleExternalWithdrawTapped()
        case .bank:     Task { await handleBankWithdrawTapped() }
        }
    }

    // MARK: ══════════════════════════════════════════════
    // MARK: A. EXCHANGE / PAYBITO TRANSFER
    // MARK: ══════════════════════════════════════════════

    /// Mirrors: balenceTranfertoPaybitoModal()
    private func handleExchangeWithdrawTapped() {
        guard let asset = selectedAsset else { return }

        Task {
            isLoading = true
            do {
                // Determine tokenType for fee lookup — mirrors React
                var tokenType: String? = nil
                if asset.currencyId == "16" || asset.currencyId == "148" {
                    tokenType = "erc"
                }
                let fees = try await service.getFeesByCurrency(
                    currencyId: asset.currencyId,
                    merchantId: merchantId,
                    tokenType: tokenType
                )
                exchangeFeesInfo = fees
                exchangeTransferAmount = ""
                exchangeTransferAmountError = ""
                exchangeGoogleAuthCode = ""
                isLoading = false
                showExchangeTransferForm = true
            } catch {
                isLoading = false
                print("ERROR:", error)

                if let decodingError = error as? DecodingError {
                    print("DECODING ERROR:", decodingError)
                }

                errorMessage = error.localizedDescription
            }
        }
    }

    /// Mirrors: closeTransferModal() → handleExchangeUserDetails() → balanceTransfertoPaybito()
    func submitExchangeTransfer() {
        guard !isTestMode else {
            errorMessage = "This feature is not available for test mode"
            return
        }
        guard let asset = selectedAsset,
              let balance = Double(asset.balance),
              let amount  = Double(exchangeTransferAmount) else { return }

        if amount >= balance {
            errorMessage = "Insufficient Balance"
            return
        }

        Task {
            isSubmittingExchange = true
            isLoading = true
            do {
                
                print("\n===== LOCAL VALUES =====")

                print("merchantId =", merchantId)

                print("authUuid =", authUuid)

                print("authToken =", authToken)

                print("brokerId from property =", brokerId)

                print("raw brokerId =", UserDefaults.standard.string(forKey: "BbrokerId") ?? "nil")
                print("\n===== STEP 1 AUTO LOGIN =====")

                let loginRes = try await service.autoLoginExchange(
                    merchantId: merchantId,
                    brokerId: brokerId,
                    uuid: authUuid,
                    authToken: authToken
                )

                print("AUTO LOGIN SUCCESS")
                print("token =", loginRes.token ?? "nil")
                print("userId =", loginRes.userId ?? "nil")
                print("uuid =", loginRes.uuid ?? "nil")
                print("errorData =", loginRes.error?.errorData ?? -1)
                print("errorMessage =", loginRes.error?.errorMessage ?? "nil")

             
                guard loginRes.error?.errorData == 0 else {
                    throw ServiceError.apiError(loginRes.error?.errorMessage ?? "Exchange login failed")
                }

                let exchangeToken = loginRes.token ?? ""

                // userId is now guaranteed to be a clean "158994" string or nil
                guard let exchangeUserId = loginRes.userId, !exchangeUserId.isEmpty else {
                    throw ServiceError.apiError("Exchange login returned no userId — check model decoding")
                }

                print("exchangeToken:  '\(exchangeToken)'")
                print("exchangeUserId: '\(exchangeUserId)'")   // must print "158994", not ""
                print("exchangeUuid:   '\(loginRes.uuid ?? "NIL")'")

                // userAccountStatus — pass userId as Int since API expects integer
                guard let userIdInt = Int(exchangeUserId) else {
                    throw ServiceError.apiError("userId '\(exchangeUserId)' is not a valid integer")
                }
                print("\n===== STEP 2 USER ACCOUNT STATUS =====")

                print("exchangeToken =", exchangeToken)

                print("exchangeUserId =", exchangeUserId)

                print("exchangeUuid =", loginRes.uuid ?? "nil")

                let statusRes = try await service.userAccountStatus(
                    token:  exchangeToken,
                    uuid:   loginRes.uuid ?? "",   // ← loginRes.uuid, NOT loginRes.exchangeUuid
                    userId: userIdInt
                )
                print("USER ACCOUNT STATUS SUCCESS")

//                print("status =", statusRes.userResult?.status ?? -1)

//                print("userId =", statusRes.userResult?.userId ?? -1)

//                print("uuid =", statusRes.userResult?.uuid ?? "nil")

                print("USER ACCOUNT STATUS SUCCESS")
                print("status =", statusRes.status ?? -1)

                guard statusRes.status == 1 else {
                    throw ServiceError.apiError("Your user has been blocked by Admin")
                }

                UserDefaults.standard.set(exchangeToken,  forKey: "paybito_access_token")
                UserDefaults.standard.set(exchangeUserId, forKey: "Bpaybito_id")

                // Step 2 — check google auth enabled
                let settings = try await service.fetchUserSettings(merchantId: merchantId)
                guard settings.googleAuthEnabled == "1" else {
                    throw ServiceError.apiError("Please turn on Google Authentication from Settings first")
                }

                isLoading = false
                isSubmittingExchange = false
                // Step 3 — open Google Auth gate
                showExchangeTransferForm = false
                showExchangeAuthModal = true

            } catch {
                isLoading = false
                isSubmittingExchange = false
                print("ERROR:", error)

                if let decodingError = error as? DecodingError {
                    print("DECODING ERROR:", decodingError)
                }

                errorMessage = error.localizedDescription
            }
        }
    }

    /// Called when user enters Google Auth code and taps Confirm
    /// Mirrors: transferToPaybitoWallet()
    func confirmExchangeTransfer() {
        guard !exchangeGoogleAuthCode.isEmpty else {
            errorMessage = "Please enter Google Auth code"
            return
        }
        guard let asset = selectedAsset else { return }
        let paybitoId = UserDefaults.standard.string(forKey: "Bpaybito_id") ?? ""

        Task {
            isLoading = true
            do {
                let req = TransferToPaybitoRequest(
                    merchantId:  merchantId,
                    customerId:  paybitoId,
                    amount:      exchangeTransferAmount,
                    currencyId:  asset.currencyId,
                    type:        "Transfer",
                    secureToken: exchangeGoogleAuthCode
                )
                print("===== TRANSFER TO PAYBITO =====")
                print("merchantId:", merchantId)
                print("paybitoId:", paybitoId)
                print("amount:", exchangeTransferAmount)
                print("currencyId:", asset.currencyId)
                print("secureToken:", exchangeGoogleAuthCode)
                let res = try await service.transferToPaybito(request: req)
                print("===== TRANSFER RESPONSE =====")

                print(res)
                if let err = res.error, err != "0" {
                    throw ServiceError.apiError(res.errorMsg ?? "Transfer failed")
                }
                successMessage = res.errorMsg ?? "Transfer successful"
                showExchangeAuthModal = false
                exchangeGoogleAuthCode = ""
                exchangeTransferAmount = ""
                await fetchLedgerAssets()
                await fetchTransactions()
            } catch {
                print("ERROR:", error)

                if let decodingError = error as? DecodingError {
                    print("DECODING ERROR:", decodingError)
                }

                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: Exchange amount validation
    /// Mirrors React transferAmt() and onChange handler in transferModal
    func validateExchangeAmount(_ raw: String) {
        exchangeTransferAmount = raw
        guard !raw.isEmpty, let val = Double(raw) else {
            exchangeTransferAmountError = ""
            isExchangeTransferAmountValid = false
            return
        }
        let min = Double(exchangeFromFee) ?? 0
        let max = Double(exchangeToFee)   ?? 0
        if val < min {
            exchangeTransferAmountError = "Minimum amount is \(exchangeFromFee)"
            isExchangeTransferAmountValid = false
        } else if val > max {
            exchangeTransferAmountError = "Maximum amount is \(exchangeToFee)"
            isExchangeTransferAmountValid = false
        } else {
            exchangeTransferAmountError = ""
            isExchangeTransferAmountValid = true
        }
    }

    // MARK: ══════════════════════════════════════════════
    // MARK: B. EXTERNAL WALLET
    // MARK: ══════════════════════════════════════════════

    private func handleExternalWithdrawTapped() {

        guard let asset = selectedAsset else { return }

        networkLabel = selectedNetwork ?? asset.defaultNetworkLabel

        Task {

            isLoading = true

            do {

                let tokenType = resolvedTokenType(for: asset)

                async let addressTask = service.getCryptoAddresses(
                    currencyId: asset.currencyId,
                    merchantId: merchantId
                )

                async let feeTask = service.getFeesByCurrency(
                    currencyId: asset.currencyId,
                    merchantId: merchantId,
                    tokenType: tokenType
                )

                let (addresses, fees) = try await (
                    addressTask,
                    feeTask
                )

                savedAddresses = addresses
                feesInfo = fees

                print("===== SAVED ADDRESSES =====")
                print(addresses)

                print("===== FEES =====")
                print(fees)

                showExternalAddressForm = true

            } catch {

                print("ERROR:", error)

                errorMessage = error.localizedDescription
            }

            isLoading = false
        }
    }

    // MARK: Address entry mode toggle
    // Mirrors: handleManualEntryMode() / handleSavedEntryMode()

    func switchToManualEntry() {
        addressEntryMode = .manual
        externalAddress = ""
        addressValidationState = .idle
    }

    func switchToSavedEntry() {
        addressEntryMode = .saved
        externalAddress = ""
        addressValidationState = .idle
    }

    func selectSavedAddress(_ address: String) {
        externalAddress = address
        Task { await validateAddress(address) }
    }

    // MARK: Address validation
    // Mirrors: isAddressValid() → validateExternalAddress()

    func onAddressChanged(_ newAddress: String) {
        externalAddress = newAddress
        guard !newAddress.isEmpty else {
            addressValidationState = .idle
            return
        }
        Task { await validateAddress(newAddress) }
    }

    private func validateAddress(_ address: String) async {
        guard let asset = selectedAsset else { return }

        isValidatingAddress = true

        do {
            let res = try await service.validateAddress(
                currencyId: asset.currencyId,
                address: address,
                merchantId: merchantId,
                tokenType: selectedNetwork
            )

            print("===== ADDRESS VALIDATION RESPONSE =====")
            print("error =", res.error ?? "nil")
            print("errorMsg =", res.errorMsg ?? "nil")

            if let err = res.error, err != "0" {
                addressValidationState = .invalid(res.errorMsg ?? "Invalid address")
            } else {
                addressValidationState = .valid(res.errorMsg ?? "valid address")
            }

        } catch {
            print("===== VALIDATION ERROR =====")
            print(error)

            addressValidationState = .invalid(error.localizedDescription)
        }

        isValidatingAddress = false
    }

    // MARK: Amount field
    // Mirrors React rate() + onChange for externalAddressTransferAmount

    func onExternalAmountChanged(_ raw: String) {
        externalAmount = raw
        guard !raw.isEmpty, let val = Double(raw) else {
            externalAmountError = ""
            networkFee = ""
            return
        }
        if val > maxSend {
            externalAmountError = "Maximum amount is \(feesInfo?.toFee ?? "")"
        } else if val < minSend {
            externalAmountError = "Minimum amount is \(feesInfo?.fromFee ?? "")"
        } else {
            externalAmountError = ""
        }
        // Fetch live network fee — mirrors rate()
        Task { await fetchNetworkFee(for: raw) }
    }

    /// Set max amount — mirrors maxSendAmount()
    func setMaxExternalAmount() {
        guard let asset = selectedAsset,
              let balance = Double(asset.balance),
              let minFee  = Double(feesInfo?.minFee ?? "0"),
              let feeRate = Double(feesInfo?.feeRate ?? "0") else { return }

        let maxAmt = (balance - minFee - ((balance - minFee) * feeRate / 100))
        let precision = feesInfo?.precisionInt ?? 8
        if maxAmt <= 0 {
            externalAmount = "0"
            networkFee = ""
        } else {
            externalAmount = String(format: "%.\(precision)f", maxAmt)
            Task { await fetchNetworkFee(for: externalAmount) }
        }
    }

    private func fetchNetworkFee(for amount: String) async {
        guard let asset = selectedAsset, !amount.isEmpty,
              let val = Double(amount), val > 0 else { return }
        do {
            let res = try await service.getNetworkFee(
                sendAmount: amount,
                currency:   asset.currencyCode,
                merchantId: merchantId
            )
            if let err = res.error, err != "0" {
                networkFee = "0"
            } else if let entry = res.feesList?.first {
                let precision = entry.currencyPrecision ?? (feesInfo?.precisionInt ?? 8)
                if let total = entry.totalFees {
                    // Validate amount is still in range — mirrors React rate()
                    if let from = entry.fromFee, let to = entry.toFee, val >= from, val <= to {
                        networkFee = String(format: "%.\(precision)f", total)
                    } else {
                        networkFee = "0"
                    }
                }
            }
        } catch {
            networkFee = "0"
        }
    }

    // MARK: Proceed to Security Verification
    // Mirrors: handleTranferToExternalAddress()

    func proceedToExternalAuth() {
        guard !isTestMode else {
            errorMessage = "This feature is not available for test mode"
            return
        }
        guard let asset = selectedAsset,
              let balance = Double(asset.balance),
              let amount  = Double(externalAmount) else {
            errorMessage = "Please provide valid address and amount"
            return
        }
        if amount > balance {
            errorMessage = "Insufficient Balance"
            return
        }
        guard !externalAddress.isEmpty,
              !externalAmount.isEmpty,
              addressValidationState.isValid,
              amount > 0 else {
            errorMessage = "Please provide valid address and amount"
            return
        }
        Task {

            do {

                let settings = try await service.fetchUserSettings(
                    merchantId: merchantId
                )

                guard settings.googleAuthEnabled == "1" else {
                    errorMessage = "Please Turn on Google Authentication from Settings First."
                    return
                }

                showExternalAddressForm = false
                externalEmailOTP = ""
                externalGoogleAuthCode = ""
                showExternalAuthModal = true

                await requestExternalEmailOTP()

            } catch {
                errorMessage = error.localizedDescription
            }
        }
        // Start email OTP automatically — mirrors onShow in React
        showExternalAddressForm = false
        externalEmailOTP = ""
        externalGoogleAuthCode = ""
        showExternalAuthModal = true
        Task { await requestExternalEmailOTP() }
    }

    // MARK: Email OTP for external wallet
    // Mirrors: sendMailForExternalWallet() / externalWalletOtpVerificationMail()

    func requestExternalEmailOTP() async {
        do {
            let res = try await service.requestEmailOTPForExternalTransfer(
                email:      userEmail,
                merchantId: merchantId
            )
            if let err = res.error, err != "0" {
                errorMessage = res.errorMsg ?? "Failed to send OTP"
            } else {
                successMessage = "OTP has been sent to your email id"
                startExternalOtpTimer(seconds: 120)
            }
        } catch {
            print("ERROR:", error)

            if let decodingError = error as? DecodingError {
                print("DECODING ERROR:", decodingError)
            }

            errorMessage = error.localizedDescription
        }
    }

    // MARK: OTP countdown — mirrors startGetCodeTimer(120)

    private func startExternalOtpTimer(seconds: Int) {
        externalOtpTimer?.invalidate()
        externalOtpTimerSeconds = seconds
        isExternalOtpTimerActive = true
        externalOtpTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.externalOtpTimerSeconds <= 1 {
                    self.externalOtpTimer?.invalidate()
                    self.externalOtpTimerSeconds = 0
                    self.isExternalOtpTimerActive = false
                } else {
                    self.externalOtpTimerSeconds -= 1
                }
            }
        }
    }

    // MARK: Final external wallet submit
    // Mirrors: transferToExternal()

    func submitExternalTransfer() {
        guard let asset = selectedAsset else { return }

        Task {
            isLoading = true
            do {
                var req = SendToOtherRequest(
                    userId:      merchantId,
                    currencyId:  asset.currencyId,
                    sendAmount:  externalAmount,
                    toAdd:       externalAddress,
                    otp:         externalEmailOTP,
                    email:       userEmail,
                    secureToken: externalGoogleAuthCode
                )
                if !coinTagValue.isEmpty { req.memo = coinTagValue }
                if asset.currencyId == "16", let net = selectedNetwork {
                    req.tokenType = net
                }
                let res = try await service.sendToExternalWallet(request: req)
                if let err = res.error, err != "0" {
                    throw ServiceError.apiError(res.errorMsg ?? "Transfer failed")
                }
                successMessage = "Amount has been transferred successfully"
                showExternalAuthModal = false
                // Reset state
                externalAddress = ""
                externalAmount  = ""
                coinTagValue    = ""
                networkFee      = ""
                addressValidationState = .idle
                await fetchLedgerAssets()
                await fetchTransactions()
            } catch {
                print("ERROR:", error)

                if let decodingError = error as? DecodingError {
                    print("DECODING ERROR:", decodingError)
                }

                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

    // MARK: ══════════════════════════════════════════════
    // MARK: C. BANK WITHDRAWAL
    // MARK: ══════════════════════════════════════════════

    /// Mirrors: handleInitiateWithdrawToBankAccount()
    private func handleBankWithdrawTapped() async {

        
        do {

            let settings = try await service.fetchUserSettings(

                merchantId: merchantId

            )

            print("Google Auth From API:", settings.googleAuthEnabled ?? "nil")

            guard settings.googleAuthEnabled == "1" else {

                isLoading = false

                errorMessage = "Please turn on Google Authentication in Settings."

                return

            }

            // Check KYC + bank status

            let details = try await service.getUserDetails()
            userDocsStatus  = details.userDocsStatus ?? .missing
            bankDetailsStatus = details.bankDetailsStatus
            userTierType    = details.userTierType

            guard userDocsStatus.isApproved else {
                isLoading = false
                showWithdrawTypeSheet = false
                showKycStatusModal = true
                return
            }

            // Fetch bank limits, market price, bank details in parallel
            guard let asset = selectedAsset else { isLoading = false; return }

            async let limitRes    = service.getTransactionLimit(currency: homeCurrency, tierType: userTierType)
            async let convertRes  = service.convertPrice(fromCurrency: asset.currencyCode, toCurrency: homeCurrency)
            async let bankRes     = service.getUserBankDetails()

            let (limits, convert, bank) = try await (limitRes, convertRes, bankRes)

            // Limits
            bankWithdrawMin = limits.minLimit       ?? 0
            bankWithdrawMax = limits.dailySendLimit ?? 0

            // Market price
            if let err = convert.error, err.errorData == 1 {
                throw ServiceError.apiError(convert.error?.errorMsg ?? "Failed to get market price")
            }
            fiatMarketPrice = convert.marketPrice ?? 0

            // Bank details
            if let err = bank.error, err.errorData == 1 {
                throw ServiceError.apiError(bank.error?.errorMsg ?? "Failed to get bank details")
            }
            merchantBankDetails = bank.bankDetails

            cryptoAmountForBank   = ""
            fiatEquivalentAmount  = ""
            bankGoogleAuthCode    = ""
            bankAmountError       = ""

            isLoading = false
            showWithdrawTypeSheet = false
            showBankTransferForm  = true

        } catch {
            isLoading = false
            print("ERROR:", error)

            if let decodingError = error as? DecodingError {
                print("DECODING ERROR:", decodingError)
            }

            errorMessage = error.localizedDescription
        }
    }

    /// Real-time fiat conversion — mirrors handleCryptoAmountChange()
    func onBankCryptoAmountChanged(_ raw: String) {
        cryptoAmountForBank = raw
        guard !raw.isEmpty, let val = Double(raw) else {
            fiatEquivalentAmount = ""
            bankAmountError = ""
            return
        }
        let fiat = (val * fiatMarketPrice).rounded(toDecimalPlaces: 2)
        fiatEquivalentAmount = String(format: "%.2f", fiat)

        // Validate limits
        if fiat > bankWithdrawMax {
            bankAmountError = "Maximum amount is \(bankWithdrawMax)"
        } else if fiat < bankWithdrawMin {
            bankAmountError = "Minimum amount is \(bankWithdrawMin)"
        } else {
            bankAmountError = ""
        }
    }

    /// Mirrors: handleBankWithdraw()
    func submitBankWithdrawal() {
        guard !isTestMode else {
            errorMessage = "This feature is not available for test mode"
            return
        }
        guard let asset = selectedAsset,
              let balance = Double(asset.balance),
              let cryptoAmt = Double(cryptoAmountForBank),
              cryptoAmt <= balance else {
            errorMessage = "Insufficient balance for this withdrawal amount"
            return
        }
        guard !bankGoogleAuthCode.isEmpty else {
            errorMessage = "Please provide Google Authentication OTP"
            return
        }
        guard !cryptoAmountForBank.isEmpty else {
            errorMessage = "Please provide crypto amount"
            return
        }

        Task {
            isSubmittingBank = true
            isLoading = true
            do {
                let body = CreateWithdrawalRequestBody(
                    userUuid:         exchangeUuid,
                    merchantUuid:     authUuid,
                    merchantId:       merchantId,
                    securityCode:     bankGoogleAuthCode,
                    amount:           cryptoAmountForBank,
                    fiatAmount:       fiatEquivalentAmount,
                    currencyId:       asset.currencyId,
                    fiatCurrencyCode: homeCurrency,
                    bankId:           merchantBankDetails?.bankDetailsId
                )
                let res = try await service.createWithdrawalRequest(body: body)
                if let err = res.error, err.errorData != 0 {
                    throw ServiceError.apiError(err.errorMessage ?? "Withdrawal failed")
                }
                successMessage = "Bank withdrawal request submitted"
                showBankTransferForm = false
                await fetchLedgerAssets()
                await fetchTransactions()
            } catch {
                print("ERROR:", error)

                if let decodingError = error as? DecodingError {
                    print("DECODING ERROR:", decodingError)
                }

                errorMessage = error.localizedDescription
            }
            isLoading = false
            isSubmittingBank = false
        }
    }

    // MARK: ──────────────────────────────────────────────
    // MARK: Helpers
    // MARK: ──────────────────────────────────────────────

    private func resolvedTokenType(for asset: SettlementAsset) -> String? {
        if let net = selectedNetwork { return net }
        if asset.currencyId == "16" || asset.currencyId == "148" { return "erc" }
        return nil
    }

    func resetWithdrawState() {
        selectedAsset = nil
        activeWithdrawType = nil
        selectedNetwork = nil
        externalAddress = ""
        externalAmount = ""
        coinTagValue = ""
        networkFee = ""
        addressValidationState = .idle
        exchangeTransferAmount = ""
        exchangeGoogleAuthCode = ""
        bankGoogleAuthCode = ""
        cryptoAmountForBank = ""
        fiatEquivalentAmount = ""
        externalEmailOTP = ""
        externalGoogleAuthCode = ""
        externalOtpTimer?.invalidate()
        externalOtpTimerSeconds = 0
        isExternalOtpTimerActive = false
    }

    deinit {
        externalOtpTimer?.invalidate()
    }
}

// MARK: - Double rounding helper

private extension Double {
    func rounded(toDecimalPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
