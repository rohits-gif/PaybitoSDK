//
//  Paymentlinksviewmodel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/05/26.
//

////  ViewPaymentLinksViewModel.swift
////  Trading_Terminal
////

import Foundation

// MARK: - ViewModel

final class ViewPaymentLinksViewModel: ObservableObject {

    // MARK: - Published state

    @Published var payments:     [PaymentLinkItem] = []
    @Published var isLoading:    Bool              = false
    @Published var errorMessage: String?           = nil

    // Pagination
    @Published var currentPage: Int = 1
    @Published var totalCount:  Int = 0

    let itemsPerPage: Int = 10

    // MARK: - Computed pagination helpers

    var totalPages: Int {
        max(1, Int(ceil(Double(totalCount) / Double(itemsPerPage))))
    }

    var showStart: Int { (currentPage - 1) * itemsPerPage + 1 }
    var showEnd:   Int { min(currentPage  * itemsPerPage, totalCount) }

    var canGoPrevious: Bool { currentPage > 1 }
    var canGoNext:     Bool { currentPage < totalPages }

    var visiblePages: [Int] {
        var start = max(1, currentPage - 2)
        let end   = min(totalPages, start + 4)
        start     = max(1, end - 4)
        return Array(start...end)
    }

    // MARK: - Dynamic merchantId ✅

    private var merchantId: Int {
        Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "") ?? 0
    }

    // MARK: - Public API

    func onAppear() {
        guard payments.isEmpty else { return }
        loadPage(1)
    }

    func goToFirstPage()    { guard canGoPrevious else { return }; loadPage(1) }
    func goToPreviousPage() { guard canGoPrevious else { return }; loadPage(currentPage - 1) }
    func goToNextPage()     { guard canGoNext     else { return }; loadPage(currentPage + 1) }
    func goToLastPage()     { guard canGoNext     else { return }; loadPage(totalPages) }

    func goToPage(_ page: Int) {
        let clamped = min(max(page, 1), totalPages)
        guard clamped != currentPage else { return }
        loadPage(clamped)
    }

    // MARK: - Private fetch

    private func loadPage(_ page: Int) {
        guard !isLoading else { return }

        isLoading    = true
        errorMessage = nil

        ViewPaymentLinksService.shared.fetchPayments(
            merchantId: merchantId,   // ✅ dynamic
            offset:     page,
            limit:      itemsPerPage
        ) { [weak self] (result: Swift.Result<PaymentLinksResponse, Error>) in
            guard let self = self else { return }

            self.isLoading = false

            switch result {
            case .success(let response):
                self.payments    = response.payments
                self.totalCount  = response.totalCount
                self.currentPage = page

            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}



