//
//  WHEndpointViewModel.swift
//

import Foundation
import Combine

// MARK: - View State

enum WHViewState: Equatable {
    case idle
    case loadingEndpoints
    case loadedEndpoints
    case emptyEndpoints
    case failedToLoad(String)
}

// MARK: - ViewModel

final class WHEndpointViewModel: ObservableObject {

    // MARK: Published
    @Published var displayEndpoints:       [WHEndpointDisplayItem] = []
    @Published var viewState:              WHViewState = .idle
    @Published var showErrorAlertFlag:     Bool = false
    @Published var activeAlertMessage:     String?
    @Published var selectedEndpointFilter: String = "All endpoints"
    @Published var isFetchingEndpoints:    Bool = false

    // MARK: Config
    private(set) var merchantId: Int
    private var allEndpoints:    [WHEndpointDisplayItem] = []

    // MARK: - Init
    init(merchantId: Int = 0) {
        self.merchantId = WHEndpointViewModel.resolveMerchantId(fallback: merchantId)
        WHEndpointViewModel.dumpAllUserDefaultsKeys()   // ✅ prints every stored key once
    }

    // MARK: - Resolve merchantId from UserDefaults
    private static func resolveMerchantId(fallback: Int) -> Int {

        // ✅ ADD your app's real key here once dumpAllUserDefaultsKeys() reveals it
        let candidates: [(String, Bool)] = [
            ("BmerchantId",   false),   // Int
            ("Bmerchant_id",  false),
            ("merchantId",    false),
            ("merchant_id",   false),
            ("BuserId",       false),
            ("Buser_id",      false),
            ("BmerchantId",   true),    // String versions
            ("Bmerchant_id",  true),
            ("merchantId",    true),
            ("merchant_id",   true),
        ]

        for (key, asString) in candidates {
            if asString {
                if let str = UserDefaults.standard.string(forKey: key),
                   let parsed = Int(str), parsed > 0 {
                    debugPrint("✅ [WHViewModel] merchantId=\(parsed) from String key '\(key)'")
                    return parsed
                }
            } else {
                let val = UserDefaults.standard.integer(forKey: key)
                if val > 0 {
                    debugPrint("✅ [WHViewModel] merchantId=\(val) from Int key '\(key)'")
                    return val
                }
            }
        }

        if fallback > 0 {
            debugPrint("✅ [WHViewModel] merchantId=\(fallback) from fallback param")
            return fallback
        }

        // ⚠️ Temporary hardcode — remove once real key is found
        debugPrint("⚠️ [WHViewModel] merchantId NOT found in UserDefaults — using 27135")
        return 27135
    }

    // MARK: - Debug: dump all UserDefaults keys to find the merchantId key
    static func dumpAllUserDefaultsKeys() {
        #if DEBUG
        let dict = UserDefaults.standard.dictionaryRepresentation()
        let merchantRelated = dict.filter { key, value in
            let k = key.lowercased()
            return k.contains("merchant") || k.contains("userid") ||
                   k.contains("user_id") || k.contains("uid") ||
                   k.contains("id")
        }
        debugPrint("════ [WHViewModel] UserDefaults keys containing 'merchant/user/id' ════")
        for (key, value) in merchantRelated.sorted(by: { $0.key < $1.key }) {
            debugPrint("   \(key) = \(value)")
        }
        debugPrint("══════════════════════════════════════════════════════════════════════")
        #endif
    }

    // MARK: - Update merchantId at runtime (e.g. after login)
    func configure(merchantId: Int) {
        self.merchantId = merchantId
        debugPrint("✅ [WHViewModel] merchantId configured to \(merchantId)")
        loadWebhookEndpointsFromAPI()
    }

    // MARK: - Fetch

    func loadWebhookEndpointsFromAPI() {
        guard !isFetchingEndpoints else { return }
        isFetchingEndpoints = true
        viewState = .loadingEndpoints

        debugPrint("📡 [WHViewModel] loading endpoints for merchantId=\(merchantId)")

        WebhookEndpointService.shared.fetchMerchantWebhookEndpoints(merchantId: merchantId) { [weak self] result in
            guard let self else { return }
            self.isFetchingEndpoints = false
            switch result {
            case .success(let response):
                let items = response.data.map { WHEndpointDisplayItem(from: $0) }
                self.allEndpoints = items
                self.applyCurrentFilter()
                self.viewState    = items.isEmpty ? .emptyEndpoints : .loadedEndpoints
                debugPrint("✅ [WHViewModel] loaded \(items.count) endpoint(s)")
            case .failure(let error):
                self.viewState          = .failedToLoad(error.localizedDescription)
                self.activeAlertMessage = error.localizedDescription
                self.showErrorAlertFlag = true
                debugPrint("❌ [WHViewModel] load failed: \(error.localizedDescription)")
            }
        }
    }

    func retryFetchingWebhookEndpoints() {
        loadWebhookEndpointsFromAPI()
    }

    // MARK: - Filtering

    func applyEndpointFilter(_ url: String) {
        selectedEndpointFilter = url
        applyCurrentFilter()
    }

    func resetEndpointFilter() {
        selectedEndpointFilter = "All endpoints"
        applyCurrentFilter()
    }

    private func applyCurrentFilter() {
        if selectedEndpointFilter == "All endpoints" {
            displayEndpoints = allEndpoints
        } else {
            displayEndpoints = allEndpoints.filter { $0.url == selectedEndpointFilter }
        }
    }
}
