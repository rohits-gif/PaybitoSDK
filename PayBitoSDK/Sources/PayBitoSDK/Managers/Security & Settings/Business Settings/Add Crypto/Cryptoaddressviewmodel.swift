//
//  Cryptoaddressviewmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 03/06/26.
//

// CryptoAddressViewModel.swift
// Mirrors every piece of state and logic from the React class component:
//   • loads assets on init (handleRenderAssets)
//   • opens the Add/Edit modal (handleGetAddress)
//   • validates addresses on blur (validateCryptoAddress)
//   • saves addresses (handleSaveAddress)

import Foundation
import Combine

@MainActor
final class CryptoAddressViewModel: ObservableObject {

    // ── Injected dependency ──────────────────────────────────────────────────
    private let service: CryptoAddressService

    init(service: CryptoAddressService = .shared) {
        self.service = service
    }

    // ── Asset list ───────────────────────────────────────────────────────────
    @Published var assets: [CryptoAsset] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    // ── Modal visibility ─────────────────────────────────────────────────────
    @Published var showAddressModal: Bool = false

    // ── Selected asset ───────────────────────────────────────────────────────
    @Published var selectedAsset: CryptoAsset? = nil

    // ── Form fields ──────────────────────────────────────────────────────────
    @Published var addressName: String = "" {
        didSet { validateAddressNameField() }
    }
    @Published var memo: String = "" {
        didSet { validateMemoField() }
    }
    @Published var nativeAddress: String = "" {
        didSet { nativeValidationState = .idle }
    }
    @Published var ercAddress: String = "" {
        didSet { ercValidationState = .idle }
    }
    @Published var trcAddress: String = "" {
        didSet { trcValidationState = .idle }
    }

    // ── Inline field errors ──────────────────────────────────────────────────
    @Published var addressNameError: String = ""
    @Published var memoError: String = ""

    // ── Address validation states (mirrors React state per field) ────────────
    @Published var nativeValidationState: AddressValidationState = .idle
    @Published var ercValidationState:    AddressValidationState = .idle
    @Published var trcValidationState:    AddressValidationState = .idle

    // ── Auto-withdraw (USDT only) ────────────────────────────────────────────
    @Published var autoWithdrawNetwork: String = "ERC"   // "ERC" or "TRC"

    // ── "Once set, cannot be removed" guards (mirrors hadInitial* in React) ──
    private var hadInitialNativeAddress: Bool = false
    private var hadInitialERCAddress:    Bool = false
    private var hadInitialTRCAddress:    Bool = false

    // ── Toast/feedback ───────────────────────────────────────────────────────
    @Published var toastMessage: String? = nil
    @Published var toastIsSuccess: Bool = true

    // ── Permission (mirrors currentPageAccess()) ─────────────────────────────
//    var hasWritePermission: Bool {
//        // Read the permission that the login flow stored in UserDefaults
//        UserDefaults.standard.string(forKey: "Bpermission") == "WRITE"
//    }
    var hasWritePermission: Bool {

        true

    }

    private var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? ""
    }

    var isUSDT: Bool {
        selectedAsset?.assetId == "16"
    }

    var showMemoField: Bool {
        selectedAsset?.assetCode == "HCX" || selectedAsset?.assetCode == "XRP"
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Load assets  (handleRenderAssets in React)
    // ─────────────────────────────────────────────────────────────────────────
    func loadAssets() {
        isLoading = true
        service.fetchLedgerAssets(merchantId: merchantId) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let response):

                    guard let coinBalance = response.coin_balance else {
                        self.showToast("No assets found", success: false)
                        return
                    }
                    // Filter currency_type == "2" (crypto), same as React
                    self.assets = coinBalance
                        .filter { $0.currency_type == "2" }
                        .map { cb in
                            CryptoAsset(
                                id:               cb.currency_id,
                                assetName:        cb.currency_name,
                                assetCode:        cb.currency_code,
                                assetId:          cb.currency_id,
                                assetImage:       cb.logo,
                                network:          cb.network?.values ?? [],
                                coinBalance:      cb.balance,
                                isBrokerCurrency: cb.is_broker_currency ?? 0
                            )
                        }
                case .failure(let err):
                    self.showToast(err.localizedDescription, success: false)
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Open modal  (handleGetAddress in React)
    // ─────────────────────────────────────────────────────────────────────────
    func openAddressModal(for asset: CryptoAsset) {
        guard hasWritePermission else {
            showToast("You need write access to perform this operation", success: false)
            return
        }

        resetModalState()
        isLoading = true

        service.fetchCryptoAddress(currencyId: asset.assetId,
                                   merchantId: merchantId) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let responses):
                    guard !responses.isEmpty else { return }

                    let statusObj = responses[responses.count - 1]
                    if statusObj.error != nil && statusObj.error != "0" {
                        self.showToast(statusObj.error_msg ?? "Error fetching address", success: false)
                        return
                    }

                    var ercAddr   = ""
                    var trcAddr   = ""
                    var nativeAddr = ""
                    var addrName  = ""
                    var memo      = ""
                    var autoNet   = "ERC"
                    var enabledAutoWithdraw = 1

                    // Iterate all except the last (error) object — matches React logic
                    let dataRows = responses.dropLast()
                    for (i, r) in dataRows.enumerated() {
                        switch r.network_type {
                        case "ERC":
                            ercAddr = r.bitcoin_address ?? ""
                            if (r.isEnabledAutoWithdraw ?? 0) == 1 { autoNet = "ERC" }
                        case "TRC":
                            trcAddr = r.bitcoin_address ?? ""
                            if (r.isEnabledAutoWithdraw ?? 0) == 1 { autoNet = "TRC" }
                        default:  // "NATIVE" or nil
                            nativeAddr = r.bitcoin_address ?? ""
                            enabledAutoWithdraw = r.isEnabledAutoWithdraw ?? 1
                        }
                        if i == 0 {
                            addrName = r.address_name ?? ""
                            memo     = r.memo ?? ""
                        }
                    }

                    self.selectedAsset               = asset
                    self.addressName                 = addrName
                    self.memo                        = memo
                    self.nativeAddress               = nativeAddr
                    self.ercAddress                  = ercAddr
                    self.trcAddress                  = trcAddr
                    self.autoWithdrawNetwork         = autoNet
                    self.hadInitialNativeAddress     = !nativeAddr.isEmpty
                    self.hadInitialERCAddress        = !ercAddr.isEmpty
                    self.hadInitialTRCAddress        = !trcAddr.isEmpty
                    self.showAddressModal            = true

                case .failure(let err):
                    self.showToast(err.localizedDescription, success: false)
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Validate single field on blur  (validateCryptoAddress in React)
    // ─────────────────────────────────────────────────────────────────────────
    func validateAddressOnBlur(networkType: String = "") {
        guard let asset = selectedAsset else { return }

        let address: String
        let stateKeyPrefix: String

        if isUSDT {
            switch networkType {
            case "ERC":
                address = ercAddress
                stateKeyPrefix = "ERC"
            case "TRC":
                address = trcAddress
                stateKeyPrefix = "TRC"
            default:
                return
            }
        } else {
            address = nativeAddress
            stateKeyPrefix = ""
        }

        guard !address.isEmpty else {
            setValidationState(.idle, prefix: stateKeyPrefix)
            return
        }

        setValidationState(.validating, prefix: stateKeyPrefix)

        let tokenType = networkType.isEmpty
            ? (asset.network.first ?? "")
            : networkType

        service.validateCryptoAddress(
            address:    address,
            currency:   asset.assetCode,
            currencyId: asset.assetId,
            tokenType:  tokenType,
            memo:       memo
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let res):
                    let state: AddressValidationState = res.error == "1" ? .invalid : .valid
                    self.setValidationState(state, prefix: stateKeyPrefix)
                case .failure:
                    self.setValidationState(.invalid, prefix: stateKeyPrefix)
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Save address  (handleSaveAddress in React)
    // ─────────────────────────────────────────────────────────────────────────
    func saveAddress() {
        guard hasWritePermission else {
            showToast("You need write access to perform this operation", success: false)
            return
        }
        guard let asset = selectedAsset else { return }

        // 1. Address name validation
        if addressName.isEmpty || !addressNameError.isEmpty {
            showToast(addressNameError.isEmpty ? "Address Name cannot be empty" : addressNameError,
                      success: false)
            return
        }

        // 2. Address presence rules
        if isUSDT {
            if hadInitialERCAddress && ercAddress.isEmpty {
                showToast("USDT ERC Address cannot be removed once set", success: false); return
            }
            if hadInitialTRCAddress && trcAddress.isEmpty {
                showToast("USDT TRC Address cannot be removed once set", success: false); return
            }
            if ercAddress.isEmpty && trcAddress.isEmpty {
                showToast("At least one address (ERC or TRC) must be provided", success: false); return
            }
        } else {
            if hadInitialNativeAddress && nativeAddress.isEmpty {
                showToast("Address cannot be removed once set", success: false); return
            }
            if nativeAddress.isEmpty {
                showToast("Address cannot be empty", success: false); return
            }
        }

        // 3. Memo validation for HCX / XRP
        if showMemoField && (memo.isEmpty || !memoError.isEmpty) {
            showToast(memoError.isEmpty ? "Memo/Destination Tag is required" : memoError,
                      success: false)
            return
        }
        if !memo.isEmpty && !memoError.isEmpty {
            showToast(memoError, success: false); return
        }

        isLoading = true

        // 4. Validate all addresses before saving (same as React Promise.all)
        let group = DispatchGroup()
        var validationFailed = false

        func validate(_ addr: String, network: String, prefix: String) {
            guard !addr.isEmpty else { return }
            group.enter()
            let tokenType = network.isEmpty ? (asset.network.first ?? "") : network
            service.validateCryptoAddress(
                address: addr,
                currency: asset.assetCode,
                currencyId: asset.assetId,
                tokenType: tokenType,
                memo: memo
            ) { result in

                switch result {

                case .success(let res):

                    if res.error == "1" {
                        validationFailed = true
                    }

                case .failure:

                    validationFailed = true
                }

                group.leave()
            }
        }

        if isUSDT {
            validate(ercAddress, network: "ERC", prefix: "ERC")
            validate(trcAddress, network: "TRC", prefix: "TRC")
        } else {
            validate(nativeAddress, network: "", prefix: "")
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if validationFailed {
                self.isLoading = false
                if self.ercValidationState == .invalid {
                    self.showToast("Invalid ERC address", success: false)
                    return
                }

                if self.trcValidationState == .invalid {
                    self.showToast("Invalid TRC address", success: false)
                    return
                }

                if self.nativeValidationState == .invalid {
                    self.showToast("Invalid address", success: false)
                    return
                }
                return
            }
            self.submitSaveRequest(asset: asset)
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Build payload & call API
    // ─────────────────────────────────────────────────────────────────────────
    private func submitSaveRequest(asset: CryptoAsset) {
        var payloads: [AddCryptoAddressPayload] = []

        if isUSDT {
            if !ercAddress.isEmpty {
                payloads.append(AddCryptoAddressPayload(
                    crypto_address:           ercAddress,
                    address_name:             addressName,
                    currency_id:              16,
                    merchant_id:              merchantId,
                    networkType:              "ERC",
                    isEnabledAutoWithdraw:    autoWithdrawNetwork == "ERC" ? 1 : 0,
                    memo:                     ""
                ))
            }
            if !trcAddress.isEmpty {
                payloads.append(AddCryptoAddressPayload(
                    crypto_address:           trcAddress,
                    address_name:             addressName,
                    currency_id:              16,
                    merchant_id:              merchantId,
                    networkType:              "TRC",
                    isEnabledAutoWithdraw:    autoWithdrawNetwork == "TRC" ? 1 : 0,
                    memo:                     ""
                ))
            }
        } else {
            payloads.append(AddCryptoAddressPayload(
                crypto_address:           nativeAddress,
                address_name:             addressName,
                currency_id:              Int(asset.assetId) ?? 0,
                merchant_id:              merchantId,
                networkType:              "NATIVE",
                isEnabledAutoWithdraw:    0,
                memo:                     memo
            ))
        }

        service.saveCryptoAddresses(payloads) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let res):
                    if res.error != "0" {
                        self.showToast(res.error_msg ?? "Save failed", success: false)
                    } else {
                        self.showToast("Address saved successfully", success: true)
                        self.dismissModal()
                        self.loadAssets()  // refresh card list
                    }
                case .failure(let err):
                    self.showToast(err.localizedDescription, success: false)
                }
            }
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Dismiss / cancel
    // ─────────────────────────────────────────────────────────────────────────
    func dismissModal() {
        showAddressModal = false
        resetModalState()
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Inline field validators (called on each keystroke via didSet)
    // ─────────────────────────────────────────────────────────────────────────
    private func validateAddressNameField() {
        if addressName.isEmpty {
            addressNameError = "Address Name cannot be empty"
        } else {
            let regex = #"^[a-zA-Z0-9_ ]{1,100}$"#
            addressNameError = addressName.range(of: regex, options: .regularExpression) != nil
                ? ""
                : "Letters, numbers, spaces, and underscores only. Max 100 characters."
        }
    }

    private func validateMemoField() {
        let code = selectedAsset?.assetCode ?? ""
        if (code == "HCX" || code == "XRP") && memo.isEmpty {
            memoError = "Memo/Destination Tag is required"
        } else if !memo.isEmpty {
            let regex = #"^[a-zA-Z0-9]{1,30}$"#
            memoError = memo.range(of: regex, options: .regularExpression) != nil
                ? ""
                : "Letters and numbers only. No spaces or special characters. Max 30 characters."
        } else {
            memoError = ""
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // MARK: Helpers
    // ─────────────────────────────────────────────────────────────────────────
    private func setValidationState(_ state: AddressValidationState, prefix: String) {
        switch prefix {
        case "ERC": ercValidationState    = state
        case "TRC": trcValidationState    = state
        default:    nativeValidationState  = state
        }
    }

    private func resetModalState() {
        selectedAsset              = nil
        addressName                = ""
        memo                       = ""
        nativeAddress              = ""
        ercAddress                 = ""
        trcAddress                 = ""
        addressNameError           = ""
        memoError                  = ""
        nativeValidationState      = .idle
        ercValidationState         = .idle
        trcValidationState         = .idle
        autoWithdrawNetwork        = "ERC"
        hadInitialNativeAddress    = false
        hadInitialERCAddress       = false
        hadInitialTRCAddress       = false
    }

    func showToast(_ message: String, success: Bool) {
        toastMessage   = message
        toastIsSuccess = success
    }
}
