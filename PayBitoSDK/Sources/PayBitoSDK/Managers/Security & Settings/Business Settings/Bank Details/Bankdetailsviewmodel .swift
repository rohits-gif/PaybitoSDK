//
//  BankDetailsViewModel.swift
//  PaymentsTerminal
//
//  Created by HashCash on 25/05/26.
//
//  Updated: handles bankDetails == nil (not yet submitted by user)

import Foundation
import Combine

// MARK: - View State

enum BankDetailsViewState {
    case idle
    case loading
    case loaded(BankDetailsModel)   // details present
    case empty                 // 200 OK but bankDetails is null
    case error(String)
}

// MARK: - ViewModel

@MainActor
final class BankDetailsViewModel: ObservableObject {

    // MARK: Published State
    @Published private(set) var viewState:    BankDetailsViewState = .idle
    @Published private(set) var bankDetails:  BankDetailsModel?         = nil
    @Published private(set) var isLoading:    Bool                 = false
    @Published private(set) var errorMessage: String?              = nil

    // MARK: Aliases expected by BusinessSettingsView
    var state: BankDetailsViewState { viewState }
    func load(uuid: String) { loadBankDetails(uuid: uuid) }

    var subtitleText: String {
        switch viewState {
        case .idle:           return "Your registered bank account"
        case .loading:        return "Fetching bank details…"
        case .loaded(let d):  return d.bankName ?? "Bank account on file"
        case .empty:          return "No bank account added yet"
        case .error:          return "Could not load bank details"
        }
    }

    // MARK: Convenience computed for view binding
    var holderName:  String { bankDetails?.benificiaryName ?? "N/A" }
    var accountNo:   String { bankDetails?.accountNo       ?? "N/A" }
    var accountType: String { bankDetails?.accountType     ?? "N/A" }
    var bankName:    String { bankDetails?.bankName        ?? "N/A" }
    var bankAddress: String { bankDetails?.bankAddress     ?? "N/A" }
    var bankCode:    String { bankDetails?.displayBankCode ?? "N/A" }
    var isSubmitted: Bool   { bankDetails?.isSubmittedSafe ?? false }

    // MARK: Dependencies
    private let service: BankDetailsServiceProtocol

    init(service: BankDetailsServiceProtocol = BankDetailsService.shared) {
        self.service = service
        print("🏗  [BankDetailsViewModel] Initialized.")
    }

    // MARK: - Load

    func loadBankDetails(uuid: String) {
        guard !isLoading else {
            print("⏭  [BankDetailsViewModel] Already loading – skipping.")
            return
        }

        print("🔄 [BankDetailsViewModel] loadBankDetails — uuid: \(uuid)")
        isLoading    = true
        errorMessage = nil
        viewState    = .loading

        service.fetchBankDetails(uuid: uuid) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success(let response):

                    if response.error.hasError {
                        // API returned 200 but flagged an error in the envelope
                        let msg = response.error.errorMsg.isEmpty
                            ? "API error (code \(response.error.errorData))"
                            : response.error.errorMsg
                        self.errorMessage = msg
                        self.viewState    = .error(msg)
                        print("⚠️  [BankDetailsViewModel] API-level error: \(msg)")
                        return
                    }

                    if let details = response.bankDetails {
                        // Happy path — details present
                        self.bankDetails = details
                        self.viewState   = .loaded(details)
                        print("✅ [BankDetailsViewModel] Loaded.")
                        print("   Holder   : \(details.benificiaryName ?? "nil")")
                        print("   Bank     : \(details.bankName        ?? "nil")")
                        print("   Acct     : \(details.accountNo       ?? "nil")")
                        print("   Submitted: \(details.isSubmittedSafe)")
                    } else {
                        // 200 OK, no error, but bankDetails is null
                        self.bankDetails = nil
                        self.viewState   = .empty
                        print("ℹ️  [BankDetailsViewModel] No bank details on file for this user.")
                    }

                case .failure(let error):
                    let msg          = error.localizedDescription
                    self.errorMessage = msg
                    self.viewState   = .error(msg)
                    print("❌ [BankDetailsViewModel] Network error: \(msg)")
                }
            }
        }
    }

    // MARK: - Reset

    func reset() {
        print("♻️  [BankDetailsViewModel] Reset.")
        bankDetails  = nil
        errorMessage = nil
        viewState    = .idle
        isLoading    = false
    }
}
