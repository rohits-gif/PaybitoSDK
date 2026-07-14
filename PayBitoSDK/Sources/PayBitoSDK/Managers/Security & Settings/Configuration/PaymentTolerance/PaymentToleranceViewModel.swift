//  PaymentToleranceViewModel.swift

import Foundation
import Combine

class PaymentToleranceViewModel: ObservableObject {

    @Published var assets: [PTolerance.AssetItem] = []
    @Published var selectedCurrencyId: String = ""

    @Published var isAutomaticAcceptUnderpayment: Bool = false
    @Published var underPaymentToleranceLimit: String = ""

    @Published var isAutomaticAcceptOverpayment: Bool = false
    @Published var overPaymentToleranceLimit: String = ""

    @Published var isLoading: Bool = false
    @Published var toastMessage: String? = nil
    @Published var toastIsError: Bool = false

    private let service = PaymentToleranceService.shared

    // MARK: - Load Assets
    func loadAssets() {
        print("🚀 [PTViewModel] loadAssets called")
        isLoading = true

        service.fetchLedgerAmount { [weak self]
            (result: Swift.Result<PTolerance.LedgerResponse, PTolerance.PTServiceError>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("✅ [PTViewModel] loadAssets — error: \(response.error)")
                    guard response.error == "0" else {
                        self.toast(response.error_msg ?? "Error", isError: true)
                        return
                    }
                    let filtered: [PTolerance.AssetItem] = (response.coin_balance ?? [])
                        .filter { $0.currency_type == 2 }
                        .map { coin in
                            PTolerance.AssetItem(
                                assetId:    coin.currency_id,
                                assetName:  coin.currency_name,
                                assetCode:  coin.currency_code,
                                assetImage: coin.logo,
                                network:    coin.network
                            )
                        }
                    print("✅ [PTViewModel] filtered assets: \(filtered.count)")
                    filtered.forEach { print("   💰 \($0.assetCode) id:\($0.assetId)") }
                    self.assets = filtered
                    if let first = filtered.first {
                        self.selectedCurrencyId = String(first.assetId)
                        self.loadSettings(currencyId: self.selectedCurrencyId)
                    } else {
                        print("⚠️ [PTViewModel] no currency_type==2 assets")
                    }
                case .failure(let error):
                    print("❌ [PTViewModel] loadAssets failed: \(error)")
                    self.toast(error.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Load Settings
    func loadSettings(currencyId: String) {
        print("🚀 [PTViewModel] loadSettings — currencyId: \(currencyId)")
        isLoading = true

        service.getMerchantSettings(currencyId: currencyId) { [weak self]
            (result: Swift.Result<PTolerance.MerchantSettingsResponse, PTolerance.PTServiceError>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("✅ [PTViewModel] loadSettings — error: \(response.error)")
                    print("   underpayment: \(response.underpayment_tolerance ?? "nil")")
                    print("   overpayment:  \(response.overpayment_tolerance ?? "nil")")
                    print("   accept_under: \(response.accept_underpayments ?? "nil")")
                    print("   accept_over:  \(response.accept_overpayments ?? "nil")")
                    guard response.error == "0" else {
                        self.toast(response.error_msg ?? "Error", isError: true)
                        return
                    }
                    self.underPaymentToleranceLimit = self.fmt(response.underpayment_tolerance, dp: 2)
                    self.overPaymentToleranceLimit  = self.fmt(response.overpayment_tolerance,  dp: 2)
                    self.isAutomaticAcceptUnderpayment = self.parseBool(response.accept_underpayments)
                    self.isAutomaticAcceptOverpayment  = self.parseBool(response.accept_overpayments)
                case .failure(let error):
                    print("❌ [PTViewModel] loadSettings failed: \(error)")
                    self.toast(error.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Save Settings
    func saveSettings() {
        print("🚀 [PTViewModel] saveSettings")
        print("   currencyId:   \(selectedCurrencyId)")
        print("   under:        \(underPaymentToleranceLimit)")
        print("   over:         \(overPaymentToleranceLimit)")
        print("   acceptUnder:  \(isAutomaticAcceptUnderpayment)")
        print("   acceptOver:   \(isAutomaticAcceptOverpayment)")

        let payload = PTolerance.SetSettingsPayload(
            currency_id:            selectedCurrencyId,
            overpayment_tolerance:  fmt(overPaymentToleranceLimit,  dp: 5),
            underpayment_tolerance: fmt(underPaymentToleranceLimit, dp: 5),
            accept_underpayments:   isAutomaticAcceptUnderpayment ? "yes" : "no",
            accept_overpayments:    isAutomaticAcceptOverpayment  ? "yes" : "no"
        )
        isLoading = true

        service.setMerchantSettings(payload: payload) { [weak self]
            (result: Swift.Result<PTolerance.SetSettingsResponse, PTolerance.PTServiceError>) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let response):
                    print("✅ [PTViewModel] saveSettings — error: \(response.error)")
                    guard response.error == "0" else {
                        self.toast(response.error_msg ?? "Error", isError: true)
                        return
                    }
                    self.toast("Payment tolerance settings saved successfully", isError: false)
                case .failure(let error):
                    print("❌ [PTViewModel] saveSettings failed: \(error)")
                    self.toast(error.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Helpers
    var canSave: Bool {
        !overPaymentToleranceLimit.isEmpty  ||
        isAutomaticAcceptOverpayment        ||
        !underPaymentToleranceLimit.isEmpty ||
        isAutomaticAcceptUnderpayment
    }

    var selectedAssetCode: String {
        assets.first(where: { String($0.assetId) == selectedCurrencyId })?.assetCode ?? ""
    }

    private func fmt(_ value: String?, dp: Int) -> String {
        guard let v = value, let d = Double(v) else { return "" }
        return String(format: "%.\(dp)f", d)
    }

    private func parseBool(_ value: String?) -> Bool {
        guard let v = value, !v.isEmpty, v != "no" else { return false }
        return true
    }

    func toast(_ msg: String, isError: Bool) {
        toastIsError = isError
        toastMessage = msg
    }
}
