//
//  Usermanagementviewmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  UserManagementViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

// MARK: - ViewModel

@MainActor
final class UserManagementViewModel: ObservableObject {

    // ------------------------------------------------------------------ //
    //  MARK: – Published State
    // ------------------------------------------------------------------ //
    @Published var merchants:    [SubMerchantAPIModel] = []
    @Published var isLoading:    Bool                  = false
    @Published var errorMessage: String?               = nil
    @Published var showError:    Bool                  = false

    // ------------------------------------------------------------------ //
    //  MARK: – Computed helpers for stats row
    // ------------------------------------------------------------------ //
    var totalUsers:  Int { merchants.count }
    var activeUsers: Int {
        merchants.filter {
            $0.accountStatusId != UserAccountStatus.accountDeleted.rawValue
            && $0.accountStatusId != UserAccountStatus.accountDisabled.rawValue
        }.count
    }
    var totalAccessMenus: Int {
        merchants.first?.accessList.count ?? 27
    }

    // ------------------------------------------------------------------ //
    //  MARK: – Dependencies
    // ------------------------------------------------------------------ //
    private let service: UserManagementServiceProtocol

    init(service: UserManagementServiceProtocol = UserManagementService.shared) {
        self.service = service
    }

    // ------------------------------------------------------------------ //
    //  MARK: – Load
    // ------------------------------------------------------------------ //
    func loadSubMerchants(merchantId: String) {
        guard !isLoading else {
            debugPrint("[UMViewModel] Already loading – skipped duplicate call.")
            return
        }

        isLoading    = true
        errorMessage = nil

        debugPrint("────────────────────────────────────────")
        debugPrint("🔄 [UMViewModel] loadSubMerchants")
        debugPrint("   merchantId : \(merchantId)")
        debugPrint("────────────────────────────────────────")

        // Swift.Result<T, Error> — matches project convention (no ServiceResult wrapper needed)
        service.fetchSubMerchantList(merchantId: merchantId) { [weak self] (result: Swift.Result<SubMerchantListResponse, Error>) in
            guard let self = self else { return }

            // Already dispatched to main by service layer
            self.isLoading = false

            switch result {
            case .success(let response):
                if response.error == 0 {
                    self.merchants = response.list

                    debugPrint("────────────────────────────────────────")
                    debugPrint("✅ [UMViewModel] LIST SECTION")
                    debugPrint("   Total : \(response.list.count)")
                    response.list.enumerated().forEach { idx, m in
                        debugPrint("   [\(idx + 1)] \(m.fullName) | \(m.email) | \(m.phone) | statusId=\(m.accountStatusId) | \(m.accountStatusDisplay)")
                    }
                    debugPrint("────────────────────────────────────────")

                } else {
                    let msg = "API error: \(response.errorMsg)"
                    self.errorMessage = msg
                    self.showError    = true
                    debugPrint("❌ [UMViewModel] API error: \(response.errorMsg)")
                }

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.showError    = true
                debugPrint("❌ [UMViewModel] Network error: \(error.localizedDescription)")
            }
        }
    }

    // ------------------------------------------------------------------ //
    //  MARK: – Refresh (public helper)
    // ------------------------------------------------------------------ //
    func refresh() {
        let merchantId = UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
        isLoading = false          // reset guard so refresh always fires
        loadSubMerchants(merchantId: merchantId)
    }
}

