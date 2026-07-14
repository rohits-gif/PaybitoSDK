//
//  TransactionsViewModel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 27/04/26.
//
//  TransactionsViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

@MainActor
class TransactionsViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var transactions: [TransactionP] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Filter
    @Published var selectedFilter: TxnFilter = .all
    @Published var showTestOnly = false
    @Published var searchText = ""
    @Published var selectedDateRange: DateRangeFilter = .allTime
    @Published var customDateFrom = ""
    @Published var customDateTo = ""
    @Published var selectedPaymentMethod = ""
    @Published var selectedNetwork = ""
    @Published var selectedCurrency = ""
    @Published var selectedPaymentType = ""

    // Summary
    @Published var totalVolume: Double = 0
    @Published var successVolume: Double = 0
    @Published var failedVolume: Double = 0
    @Published var refundedVolume: Double = 0
    @Published var totalCount: Int = 0
    @Published var succeededCount: Int = 0
    @Published var failedCount: Int = 0
    @Published var refundedCount: Int = 0
    @Published var cancelledCount: Int = 0
    @Published var totalRecords: Int = 0

    // Pagination
    @Published var currentPage = 1
    @Published var totalPages = 1
    @Published var pageSize = 20

    private let apiService = TransactionAPIService.shared
    private var cancellables = Set<AnyCancellable>()
    private let merchantId: Int

    // MARK: - Init

    init(merchantId: Int) {
        self.merchantId = merchantId
        setupSearchDebounce()
    }

    // MARK: - Search Debounce

    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(400), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.currentPage = 1
                self?.fetchTransactions()
            }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    func fetchTransactions() {
        isLoading = true
        errorMessage = nil

        let request = buildFilterRequest()

        apiService.getTransactionsByFilter(request: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                self.isLoading = false

                switch result {
                case .success(let response):
                    self.transactions   = response.transactions  ?? []
                    self.totalVolume    = response.totalVolume   ?? 0
                    self.successVolume  = response.successVolume ?? 0
                    self.failedVolume   = response.failedVolume  ?? 0
                    self.refundedVolume = response.refundedVolume ?? 0
                    self.totalCount     = response.totalCount    ?? 0
                    self.succeededCount = response.succeededCount ?? 0
                    self.failedCount    = response.failedCount   ?? 0
                    self.refundedCount  = response.refundedCount ?? 0
                    self.cancelledCount = response.cancelledCount ?? 0
                    self.totalPages     = response.totalPages    ?? 1
                    self.totalRecords   = response.totalRecords  ?? 0

                case .failure(let error):
                    self.transactions = []
                    self.errorMessage = error.localizedDescription
                    self.logDecodingError(error)
                }
            }
        }
    }

    func loadNextPage() {
        guard currentPage < totalPages, !isLoading else { return }
        currentPage += 1
        fetchTransactions()
    }

    // MARK: - Filter Builders

    private func statusString() -> String {
        if showTestOnly { return "TEST" }
        switch selectedFilter {
        case .all:        return ""
        case .success:    return "SUCCESS"
        case .failed:     return "FAILED"
        case .processing: return "PROCESSING"
        case .refunded:   return "REFUNDED"
        case .cancelled:  return "CANCELLED"
//        case .testUser:   return "TEST"
        }
    }

    private func dateRangeString() -> String {
        if selectedDateRange == .custom { return "CUSTOM" }
        switch selectedDateRange {
        case .allTime:    return "ALL"
        case .today:      return "TODAY"
        case .last7Days:  return "LAST_7_DAYS"
        case .last30Days: return "LAST_30_DAYS"
        case .thisMonth:  return "THIS_MONTH"
        default:          return "ALL"
        }
    }

    private func buildFilterRequest() -> TransactionFilterRequest {
        TransactionFilterRequest(
            merchantId: merchantId,
            status: statusString(),
            paymentMethod: selectedPaymentMethod,
            network: selectedNetwork,
            search: searchText,
            productName: "",
            catalogueName: "",
            subscriptionId: "",
            customerId: "",
            customerIdentity: "",
            paymentType: selectedPaymentType,
            currency: selectedCurrency,
            dateRange: dateRangeString(),
            fromDate: selectedDateRange == .custom ? customDateFrom : "",
            toDate: selectedDateRange == .custom ? customDateTo : "",
            page: currentPage,
            pageSize: pageSize
        )
    }

    // MARK: - Filter Actions

    func applyFilter(_ filter: TxnFilter) {
        selectedFilter = filter
        showTestOnly = false
        currentPage = 1
        fetchTransactions()
    }

    func toggleTestOnly() {
        showTestOnly.toggle()
        currentPage = 1
        fetchTransactions()
    }

    func applyDateRange(_ range: DateRangeFilter) {
        selectedDateRange = range
        currentPage = 1
        fetchTransactions()
    }

    func clearFilters() {
        selectedFilter = .all
        showTestOnly = false
        selectedDateRange = .allTime
        customDateFrom = ""
        customDateTo = ""
        selectedPaymentMethod = ""
        selectedNetwork = ""
        selectedCurrency = ""
        selectedPaymentType = ""
        searchText = ""
        currentPage = 1
        fetchTransactions()
    }

    // MARK: - Mark as Test

    func markTransactions(ids: [String], asTest: Bool, completion: @escaping (Bool) -> Void) {
        let request = MarkAsTestRequest(
            merchantId: merchantId,
            transactionId: ids.joined(separator: ","),
            status: asTest ? "MARKED" : "UNMARKED"
        )

        apiService.markAsTestTransaction(request: request) { [weak self] (result: Result<GenericResponse, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if response.status == true {
                        self?.fetchTransactions()
                        completion(true)
                    } else {
                        self?.errorMessage = response.message
                        completion(false)
                    }
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }

    // MARK: - Formatted Stats

    var totalVolumeFormatted:    String { formatUSD(totalVolume) }
    var successVolumeFormatted:  String { formatUSD(successVolume) }
    var failedVolumeFormatted:   String { formatUSD(failedVolume) }
    var refundedVolumeFormatted: String { formatUSD(refundedVolume) }

    private func formatUSD(_ amount: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "USD"
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: amount)) ?? "$0.00"
    }

    // MARK: - Debug

    private func logDecodingError(_ error: Error) {
        guard let de = error as? DecodingError else {
            print("❌ Error:", error)
            return
        }
        switch de {
        case .typeMismatch(let t, let ctx):
            print("❌ TypeMismatch:", t)
            print("📍 Path:", ctx.codingPath.map(\.stringValue))
            print("🧠 Debug:", ctx.debugDescription)
        case .valueNotFound(let t, let ctx):
            print("❌ ValueNotFound:", t)
            print("📍 Path:", ctx.codingPath.map(\.stringValue))
        case .keyNotFound(let k, let ctx):
            print("❌ KeyNotFound:", k.stringValue)
            print("📍 Path:", ctx.codingPath.map(\.stringValue))
        case .dataCorrupted(let ctx):
            print("❌ DataCorrupted")
            print("📍 Path:", ctx.codingPath.map(\.stringValue))
            print("🧠 Debug:", ctx.debugDescription)
        @unknown default:
            print("❌ Unknown decoding error")
        }
    }
}

// MARK: - Filter Enums

enum TxnFilter: String, CaseIterable {
    case all        = "All"
    case success    = "Success"
    case failed     = "Failed"
    case processing = "Processing"
    case refunded   = "Refunded"
    case cancelled  = "Cancelled"
//    case testUser   = "Test User"
}

enum DateRangeFilter: String, CaseIterable {
    case allTime    = "All time"
    case today      = "Today"
    case last7Days  = "Last 7 days"
    case last30Days = "Last 30 days"
    case thisMonth  = "This month"
    case custom     = "Custom range"
}

