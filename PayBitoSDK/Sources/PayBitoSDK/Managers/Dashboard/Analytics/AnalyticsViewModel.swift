// AnalyticsViewModel.swift
// BillBitcoins — MVVM ViewModel for the Insights / Analytics screen.
// Mirrors the React class-component state + API handler methods exactly.

import Foundation
import Combine

// MARK: - Revenue view granularity

enum RevenueGranularity: String, CaseIterable, Identifiable {
    case daily   = "Daily"
    case weekly  = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }

    var apiValue: String {
        switch self {
        case .daily:   return "DAILY"
        case .weekly:  return "WEEKLY"
        case .monthly: return "MONTHLY"
        }
    }
}

// MARK: - Revenue overlay filter (mirrors React "revenueOverlay" select)

enum RevenueOverlay: String, CaseIterable, Identifiable {
    case revenue  = "Revenue"
    case payments = "Payments"
    case fees     = "Fees"
    case all      = "All"
    var id: String { rawValue }
}

// MARK: - ViewModel

@MainActor
final class AnalyticsViewModel: ObservableObject {

    // ── Date range ──────────────────────────────────────────────────────
    @Published var startDate: Date = Calendar.current.date(byAdding: .day, value: -15, to: Date()) ?? Date()
    @Published var endDate:   Date = Date()
    @Published var selectedCurrency: String = "ALL"

    // ── Chart controls ──────────────────────────────────────────────────
    @Published var revenueGranularity: RevenueGranularity = .daily
    @Published var revenueOverlay:     RevenueOverlay     = .all

    // ── Key Metrics ─────────────────────────────────────────────────────
    @Published var kpiLoading:       Bool   = false
    @Published var totalVolume:      String = "—"
    @Published var totalTxn:         String = "—"
    @Published var successRate:      String = "—"
    @Published var avgPayment:       String = "—"
    @Published var processingFee:    String = "—"
    @Published var customerFee:      String = "—"

    // ── Revenue Over Time ───────────────────────────────────────────────
    @Published var revenueLoading:   Bool               = false
    @Published var chartPoints:      [ChartDataPoint]   = []

    // ── Transaction Health ──────────────────────────────────────────────
    @Published var healthLoading:    Bool               = false
    @Published var statusSlices:     [StatusSlice]      = []
    @Published var methodBars:       [MethodBar]        = []

    // ── Payment Source Performance ──────────────────────────────────────
    @Published var paymentSourceLoading: Bool               = false
    @Published var paymentSourceData:    [PaymentSourceItem] = []

    // ── Top Products ────────────────────────────────────────────────────
    @Published var topProductsLoading: Bool             = false
    @Published var topProductsData:    [TopProductItem] = []

    // ── Transaction Size Distribution ───────────────────────────────────
    @Published var txnSizeLoading: Bool               = false
    @Published var txnSizeData:    [TxnSizeBucket]    = []

    // ── Geographic Distribution ─────────────────────────────────────────
    @Published var geoLoading: Bool       = false
    @Published var geoData:    [GeoItem] = []

    // ── Failure Summary ─────────────────────────────────────────────────
    @Published var failureLoading: Bool           = false
    @Published var failureData:    [FailureItem] = []

    // ── Settlement Overview ─────────────────────────────────────────────
    @Published var settlementLoading:      Bool   = false
    @Published var totalSettled:           String = "—"
    @Published var pendingSettlement:      String = "—"
    @Published var avgSettlementTime:      String = "—"

    // ── Toast / Error ───────────────────────────────────────────────────
    @Published var toastMessage: String?
    @Published var toastIsError: Bool = false
    
    
    // ── Report Export ───────────────────────────────────────────────────
    @Published var reportLoading: Bool = false
    @Published var reportType: String = ""

    // Trigger used by the View to start XLSX export
    @Published var exportTrigger: (rows: [ReportRow], type: String)?
    @Published var exportURL: URL?

    // ── Cancellables ────────────────────────────────────────────────────
    private var cancellables = Set<AnyCancellable>()
    private let service      = AnalyticsAPIService.shared

    // MARK: - Merchant ID

    private var merchantId: String {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""

        // extract merchant id from token (sub = "29738-...")
        if let payload = token.split(separator: ".").dropFirst().first,
           let data = Data(base64Encoded: String(payload).padding(toLength: ((payload.count+3)/4)*4, withPad: "=", startingAt: 0)),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sub = json["sub"] as? String {

            return sub.components(separatedBy: "-").first ?? ""
        }

        return ""
    }
//    private var merchantId: String {
//        UserDefaults.standard.string(forKey: "BB_merchant_id") ?? "2589"
//    }
    // MARK: - Payload builder (mirrors buildPayload() in React)

    private func buildPayload(timeDuration: String? = nil) -> AnalyticsPayload {
        AnalyticsPayload(
            merchantId:   merchantId,
            currency:     selectedCurrency,
            startDate:    toApiDate(startDate),
            endDate:      toApiDate(endDate),
            timeDuration: timeDuration
        )
    }

    /// dd/MM/yyyy  (matches toApiDate() in the React component)
    private func toApiDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yyyy"
        return f.string(from: date)
    }

    // MARK: - USD formatter

    private func fmtUSD(_ val: Double?) -> String {
        guard let v = val else { return "—" }
        return "$" + String(format: "%.2f", v)
            .replacingOccurrences(of: "(\\d)(?=(\\d{3})+\\.)", with: "$1,", options: .regularExpression)
    }

    private func fmtCount(_ val: Int?) -> String {
        guard let v = val else { return "—" }
        return NumberFormatter.localizedString(from: NSNumber(value: v), number: .decimal)
    }

    private func fmtPct(_ val: Double?) -> String {
        guard let v = val else { return "—" }
        return String(format: "%.2f%%", v)
    }

    // MARK: - Refresh All (mirrors refreshAllPanels)

    func refreshAll() {
        fetchKeyMetrics()
        fetchRevenueOverTime()
        fetchTransactionHealth()
        fetchPaymentSourcePerformance()
        fetchTopProducts()
        fetchTxnSizeDistribution()
        fetchGeographicDistribution()
        fetchFailureTxnSummary()
        fetchSettlementOverview()
    }

    // MARK: - 1. Key Metrics

    func fetchKeyMetrics() {
        kpiLoading = true
        let payload = buildPayload(timeDuration: "MONTHLY")
        service.fetchKeyMetrics(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.kpiLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load key metrics")
                        return
                    }
                    self.totalVolume   = self.fmtUSD(r.totalProcessedVolume)
                    self.totalTxn      = self.fmtCount(r.totalTransactions)
                    self.successRate   = self.fmtPct(r.successRate)
                    self.avgPayment    = self.fmtUSD(r.averagePaymentSize)
                    self.processingFee = self.fmtUSD(r.processingFeesCollected)
                    self.customerFee   = self.fmtUSD(r.customerPaidFees)
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 2. Revenue Over Time

    func fetchRevenueOverTime() {
        revenueLoading = true
        let payload = buildPayload(timeDuration: revenueGranularity.apiValue)
        service.fetchRevenueOverTime(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.revenueLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load revenue data")
                        return
                    }
                    let sorted = (r.chartData ?? [])
                        .sorted { ($0.timeStamp ?? "") < ($1.timeStamp ?? "") }
                    self.chartPoints = sorted.map {
                        ChartDataPoint(label: $0.formattedDate,
                                       revenue: $0.revenue,
                                       count:   $0.count,
                                       fees:    $0.fees)
                    }
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 3. Transaction Health

    func fetchTransactionHealth() {
        healthLoading = true
        let payload = buildPayload()
        service.fetchTransactionHealth(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.healthLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load health data")
                        return
                    }
                    // Payment status slices
                    if let sb = r.paymentStatusBreakdown?.first {
                        var slices: [StatusSlice] = []
                        let map: [(String?, String, String)] = [
                            (sb.successCount, "Successful", "#3fb950"),
                            (sb.pendingCount, "Pending",    "#d29922"),
                            (sb.expiredCount, "Expired",    "#8b949e"),
                            (sb.failedCount,  "Failed",     "#f85149"),
                        ]
                        for (raw, label, color) in map {
                            let v = Int(raw ?? "0") ?? 0
                            if v > 0 { slices.append(StatusSlice(label: label, value: v, color: color)) }
                        }
                        self.statusSlices = slices
                    }
                    // Method bars
                    let methodColors: [String: String] = [
                        "BTC": "#d29922", "ETH": "#58a6ff", "USDT": "#3fb950",
                        "USDC": "#39c5cf", "BCH": "#bc8cff", "XRP": "#f85149",
                    ]
                    self.methodBars = (r.paymentMethodDistribution ?? []).map { item in
                        let code = item.currencyCode ?? ""
                        return MethodBar(
                            label:      code,
                            value:      item.count,
                            percentage: item.pct,
                            color:      methodColors[code] ?? "#bc8cff"
                        )
                    }
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 4. Payment Source Performance

    func fetchPaymentSourcePerformance() {
        paymentSourceLoading = true
        let payload = buildPayload()
        service.fetchPaymentSourcePerformance(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.paymentSourceLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load payment source data")
                        return
                    }
                    self.paymentSourceData = r.paymentSourceData ?? []
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 5. Top Products

    func fetchTopProducts() {
        topProductsLoading = true
        let payload = buildPayload()
        service.fetchTopProducts(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.topProductsLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load top products")
                        return
                    }
                    self.topProductsData = r.topProductsData ?? []
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 6. Transaction Size Distribution

    func fetchTxnSizeDistribution() {
        txnSizeLoading = true
        let payload = buildPayload()
        service.fetchTxnSizeDistribution(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.txnSizeLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load distribution data")
                        return
                    }
                    self.txnSizeData = r.transactionSizeDistribution ?? []
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 7. Geographic Distribution

    func fetchGeographicDistribution() {
        geoLoading = true
        let payload = buildPayload()
        service.fetchGeographicDistribution(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.geoLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load geographic data")
                        return
                    }
                    self.geoData = r.geographicDistribution ?? []
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 8. Failure Transaction Summary

    func fetchFailureTxnSummary() {
        failureLoading = true
        let payload = buildPayload()
        service.fetchFailureTxnSummary(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.failureLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load failure data")
                        return
                    }
                    self.failureData = r.failureTxnData ?? []
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - 9. Settlement Overview

    func fetchSettlementOverview() {
        settlementLoading = true
        let payload = buildPayload()
        service.fetchSettlementOverview(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.settlementLoading = false
                switch result {
                case .success(let r):
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to load settlement data")
                        return
                    }
                    self.totalSettled      = self.fmtUSD(r.totalSettled)
                    self.pendingSettlement = self.fmtUSD(r.pendingSettlement)
                    self.avgSettlementTime = "\(Int(r.avgSettlementTime ?? 0))"
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }
    
    func downloadReport(type: String) {
        // Mirrors: this.setState({ showLoader: true })
        reportLoading = true
        reportType    = type

        let payload = ReportPayload(
            merchantId: merchantId,
            currency:   selectedCurrency,
            startDate:  toApiDate(startDate),
            endDate:    toApiDate(endDate),
            reportType: type,
            offset:     0,
            limit:      10
        )

        service.fetchReport(payload: payload) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                // Mirrors: this.setState({ showLoader: false })
                self.reportLoading = false

                switch result {
                case .success(let r):
                    // Mirrors: if (responseData.error !== "0")
                    guard r.isSuccess else {
                        self.showError(r.errorMsg ?? r.message ?? "Failed to fetch report")
                        return
                    }
                    // Mirrors: if (!responseData.report_data || length === 0)
                    guard let rawRows = r.reportData, !rawRows.isEmpty else {
                        self.toastMessage = "No data available for this report"
                        self.toastIsError = false
                        return
                    }

                    let rows: [ReportRow] = rawRows.map { item in
                        ReportRow(
                            invoiceId: item["invoiceId"] ?? "",
                            invoiceDate: item["invoiceDate"] ?? "",
                            currency: item["currency"] ?? "",
                            amountPaid: item["amountPaid"] ?? "",
                            amountPaidHomeCurr: item["amountPaidHomeCurr"] ?? "",
                            status: item["status"] ?? "",

                            txnCharge: item["txnCharge"] ?? "",
                            txnChargeHomeCurr: item["txnChargeHomeCurr"] ?? "",
                            txnPer: item["txnPer"] ?? "",

                            totalInvoices: item["totalInvoices"] ?? "",
                            totalAmountPaid: item["totalAmountPaid"] ?? "",
                            totalAmountPaidHomeCurr: item["totalAmountPaidHomeCurr"] ?? "",

                            customerName: item["customerName"] ?? "",
                            customerEmail: item["customerEmail"] ?? "",
                            amount: item["amount"] ?? "",
                            recurringPeriod: item["recurringPeriod"] ?? "",
                            totalCycles: item["totalCycles"] ?? "",
                            startDate: item["startDate"] ?? "",
                            nextBillingDate: item["nextBillingDate"] ?? "",
                            description: item["description"] ?? ""
                        )
                    }

                    self.exportTrigger = (rows: rows, type: type)
                case .failure(let err):
                    self.showError(err.localizedDescription)
                }
            }
        }
    }

    // MARK: - Computed helpers used by the View

    /// Total transaction count across all payment sources
    var totalPaymentSourceTxn: Int {
        paymentSourceData.reduce(0) { $0 + $1.count }
    }

    /// Max revenue among top products (for bar width normalisation)
    var maxTopProductRevenue: Double {
        topProductsData.map(\.revenueVal).max() ?? 1
    }

    /// Max transaction count in geo data
    var maxGeoTxn: Int {
        geoData.map(\.count).max() ?? 1
    }

    /// Max failure count
    var maxFailCount: Int {
        failureData.map(\.count).max() ?? 1
    }

    // MARK: - Toast helper

    private func showError(_ msg: String) {
        toastMessage = msg
        toastIsError = true
    }
}
