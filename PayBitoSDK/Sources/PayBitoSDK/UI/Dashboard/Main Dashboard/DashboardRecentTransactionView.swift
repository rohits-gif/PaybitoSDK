//
//  PaymentDetailsView.swift
//

import SwiftUI
import Alamofire

// MARK: - Detail Service

final class PaymentDetailService {

    private let baseURL = ConfigurationD.API_BASE_URL

    private func headers() -> HTTPHeaders {
        var h = HTTPHeaders()
        h["Content-Type"] = "application/json"
        h["Origin"]       = "https://trade.paybito.com"
        h["Referer"]      = "https://trade.paybito.com/"
        if let tok = UserDefaults.standard.string(forKey: "Baccess_token"), !tok.isEmpty {
            h["Authorization"] = "bearer \(tok)"
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["Uuid"] = uuid
        }
        return h
    }

    func fetch(merchantId: Int,
               transactionId: Int,
               completion: @escaping (Swift.Result<PaymentTransaction, Error>) -> Void) {

        let url = "\(baseURL)/api/transactions/byFilter"
        let body: [String: Any] = [
            "merchantId":       merchantId,
            "status":           "",
            "paymentMethod":    "",
            "network":          "",
            "search":           "\(transactionId)",
            "productName":      "",
            "catalogueName":    "",
            "subscriptionId":   "",
            "customerId":       "",
            "customerIdentity": "",
            "paymentType":      "",
            "currency":         "",
            "dateRange":        "ALL",
            "fromDate":         "",
            "toDate":           "",
            "page":             1,
            "pageSize":         10
        ]

        print("🔍 [DetailService] POST \(url) — TXN #\(transactionId)")

        Alamofire.request(url, method: .post, parameters: body,
                   encoding: JSONEncoding.default, headers: headers())
            .validate()
            .responseData { response in
                if let raw = response.data {
                    print("🔍 [DetailService] Raw:", String(data: raw, encoding: .utf8)?.prefix(400) ?? "")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(TransactionResponse.self, from: data)
                        if let match = decoded.transactions?.first(where: { $0.transactionId == transactionId })
                            ?? decoded.transactions?.first {
                            print("✅ [DetailService] TXN #\(match.transactionId ?? 0) loaded")
                            completion(.success(match))
                        } else {
                            completion(.failure(
                                NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Transaction not found"])
                            ))
                        }
                    } catch {
                        print("❌ [DetailService] Decode error:", error)
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("❌ [DetailService] Network error:", error)
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - Detail ViewModel

@MainActor
final class PaymentDetailViewModel: ObservableObject {
    @Published var detail: PaymentTransaction?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service = PaymentDetailService()

    func load(merchantId: Int, transactionId: Int) async {
        isLoading    = true
        errorMessage = nil
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            service.fetch(merchantId: merchantId, transactionId: transactionId) { [weak self] (result: Swift.Result<PaymentTransaction, Error>) in
                Task { @MainActor [weak self] in
                    defer { self?.isLoading = false; cont.resume() }
                    switch result {
                    case .success(let txn): self?.detail = txn
                    case .failure(let err): self?.errorMessage = err.localizedDescription
                    }
                }
            }
        }
    }
}

// MARK: - PaymentDetailsView

struct PaymentDetailsView: View {

    let transaction: PaymentTransaction
    @ObservedObject var dashboardVM: PaymentDashboardViewModel

    @StateObject private var vm = PaymentDetailViewModel()
    @Environment(\.dismiss) private var dismiss

    // Use enriched detail once loaded; fall back to list row data instantly
    private var d: PaymentTransaction? { vm.detail }

    // ── Identifier helpers ──
    private var txnID: String            { "#\(transaction.transactionId ?? 0)" }
    private var paymentLinkID: String    { d?.paymentLinkId    ?? "—" }
    private var customerID: String       { "\(d?.customerId    ?? transaction.customerId ?? 0)" }
    private var customerEmail: String    { d?.customerEmail    ?? transaction.customerEmail    ?? "—" }
    private var customerIdentity: String { d?.customerIdentity ?? transaction.customerIdentity ?? "—" }
    private var paymentType: String      { d?.paymentType      ?? transaction.paymentType
                                           ?? (transaction.catalogueName != nil ? "RECURRING" : "ONE-TIME") }

    // ── Transaction helpers ──
    private var currency: String         { d?.currency ?? transaction.currency ?? "—" }

    private var productName: String {
        (d?.productDetails ?? transaction.productDetails)?.first?.productName ?? "—"
    }
    private var productDetails: String {
        guard let p = (d?.productDetails ?? transaction.productDetails)?.first else { return "—" }
        let qty   = p.qty ?? 1
        let price = p.itemPrice ?? 0
        let cur   = p.currency ?? ""
        return "\(qty) x \(cur) \(String(format: "%.2f", price))"
    }
    private var baseAmountStr: String {
        let amt = d?.baseAmount ?? transaction.baseAmount ?? 0
        if currency == "USD" { return String(format: "$%.2f", amt) }
        return String(format: "%.8f %@", amt, currency)
    }
    private var feeAmountStr: String {
        let fee = d?.feeAmount ?? transaction.feeAmount ?? 0
        if currency == "USD" { return String(format: "$%.2f", fee) }
        return String(format: "%.6f %@", fee, currency)
    }
    private var testModeStr: String  { (d?.isTestMode    ?? transaction.isTestMode)    ? "Yes" : "No" }
    private var actionReqStr: String { (d?.isActionRequired ?? transaction.isActionRequired) ? "Yes" : "No" }

    // ── Payment method helpers ──
    private var paymentMethodStr: String { d?.paymentMethod    ?? transaction.paymentMethod    ?? "—" }
    private var networkStr: String       { d?.network          ?? transaction.network          ?? "—" }
    private var sessionID: String        { d?.sessionId        ?? transaction.sessionId        ?? "—" }
    private var intentID: String         { d?.intentId         ?? transaction.intentId         ?? "—" }

    // ── Date helpers ──
    private var createdDate: String {
        fmtDate(d?.paymentCreatedAt ?? transaction.paymentCreatedAt ?? transaction.createdAt)
    }
    private var processDate: String? {
        guard let s = (d?.paymentProcessAt ?? transaction.paymentProcessAt), !s.isEmpty else { return nil }
        return fmtDate(s)
    }

    // ── Timeline entries ──
    private struct TLEntry {
        let title: String
        let subtitle: String?
        let dot: Color
        let subColor: Color
        let done: Bool
    }

    private var timeline: [TLEntry] {
        let st        = (d?.status ?? transaction.status ?? "").lowercased()
        let succeeded = ["succeeded","success","payment_confirmed",
                         "closed_with_exact_payment","closed_with_autometic_overpayment",
                         "closed_with_manual_overpayment"].contains(st)
        let failed    = ["failed","payment_failed","invoice_expired","payment_expired"].contains(st)

        let greenDot  = Color(red: 0.18, green: 0.80, blue: 0.44)
        let blueDot   = Color(red: 0.30, green: 0.60, blue: 1.00)
        let tealSub   = Color(red: 0.30, green: 0.83, blue: 0.75)

        let finalEntry: TLEntry = succeeded
            ? TLEntry(title: "Succeeded",
                      subtitle: "Payment completed",
                      dot: greenDot,
                      subColor: .white.opacity(0.45),
                      done: true)
            : failed
            ? TLEntry(title: "Expired / Failed",
                      subtitle: dashboardVM.statusLabel(d?.status ?? transaction.status),
                      dot: .red.opacity(0.85),
                      subColor: .red.opacity(0.70),
                      done: false)
            : TLEntry(title: "Awaiting Action",
                      subtitle: "Waiting for customer",
                      dot: blueDot,
                      subColor: tealSub,
                      done: false)

        return [
            TLEntry(title: "Created",
                    subtitle: createdDate,
                    dot: greenDot,
                    subColor: .white.opacity(0.45),
                    done: true),
            TLEntry(title: "Processing",
                    subtitle: processDate,
                    dot: processDate != nil ? greenDot : .white.opacity(0.25),
                    subColor: processDate != nil ? .white.opacity(0.45) : .white.opacity(0.30),
                    done: processDate != nil),
            finalEntry
        ]
    }

    // MARK: body

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.07, blue: 0.11).ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(.white)
                    Text("Loading details…")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.40))
                        .padding(.top, 10)
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            identifiersSection
                            transactionSection
                            paymentMethodSection
                            timelineSection
                            Spacer(minLength: 40)
                        }
                    }
                }
            }
        }
        .task {
            guard let midStr = UserDefaults.standard.string(forKey: "Bmerchant_id"),
                  let mid = Int(midStr) else { return }
            await vm.load(merchantId: mid, transactionId: transaction.transactionId ?? 0)
        }
    }

    // MARK: - Header bar

    private var headerBar: some View {
        HStack {
            Text("Payment Details")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            Button { dismiss() } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white.opacity(0.80))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    // MARK: - Sections

    private var identifiersSection: some View {
        section(title: "IDENTIFIERS") {
            row("Transaction ID",    txnID,            accentBlue, bold: false)
            rowDivider
            row("Payment Link ID",   paymentLinkID,    accentBlue)
            rowDivider
            row("Customer ID",       customerID)
            rowDivider
            row("Customer Email",    customerEmail)
            rowDivider
            row("Customer Identity", customerIdentity)
            rowDivider
            row("Payment Type",      paymentType,      .white, bold: true)
        }
    }

    private var transactionSection: some View {
        section(title: "TRANSACTION") {
            row("Product",          productName)
            rowDivider
            row("Product Details",  productDetails)
            rowDivider
            row("Currency",         currency)
            rowDivider
            row("Base Amount",      baseAmountStr,  .white, bold: true)
            rowDivider
            row("Fee Amount",       feeAmountStr)
            rowDivider
            row("Test Mode",        testModeStr)
            rowDivider
            row("Action Required",  actionReqStr)
        }
    }

    private var paymentMethodSection: some View {
        section(title: "PAYMENT DETAILS") {
            row("Payment Method",    paymentMethodStr)
            rowDivider
            row("Network",           networkStr)
            rowDivider
            rowTrunc("Session / Address", sessionID, accentBlue)
            rowDivider
            rowTrunc("Intent ID",    intentID,   accentBlue)
        }
    }

    private var timelineSection: some View {
        section(title: "STATUS TIMELINE") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(timeline.enumerated()), id: \.offset) { idx, entry in
                    HStack(alignment: .top, spacing: 16) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(entry.dot)
                                .frame(width: 14, height: 14)
                                .padding(.top, 2)
                            if idx < timeline.count - 1 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 1.5)
                                    .frame(maxHeight: .infinity)
                            }
                        }
                        .frame(width: 16)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.title)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(entry.done ? .white : entry.dot)
                            if let sub = entry.subtitle {
                                Text(sub)
                                    .font(.system(size: 13))
                                    .foregroundColor(entry.subColor)
                            } else {
                                Text("—")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white.opacity(0.28))
                            }
                            if idx < timeline.count - 1 { Spacer(minLength: 14) }
                        }
                    }
                    .frame(minHeight: idx < timeline.count - 1 ? 60 : 36)
                }
            }
            .padding(.vertical, 8)
        }
    }

    // MARK: - Reusable UI atoms

    private var accentBlue: Color { Color(red: 0.30, green: 0.60, blue: 1.0) }

    @ViewBuilder
    private func section<C: View>(title: String, @ViewBuilder _ content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(accentBlue)
                .tracking(1.2)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 12)

            VStack(spacing: 0) { content() }
                .padding(.horizontal, 20)

            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(maxWidth: .infinity, minHeight: 0.5, maxHeight: 0.5)
                .padding(.top, 8)
        }
    }

    @ViewBuilder
    private func row(_ label: String,
                     _ value: String?,
                     _ color: Color = .white,
                     bold: Bool = false) -> some View {
        HStack(alignment: .center) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.50))
                .frame(minWidth: 110, alignment: .leading)
            Spacer()
            Text(value ?? "—")
                .font(.system(size: 14, weight: bold ? .semibold : .regular))
                .foregroundColor((value != nil && value != "—") ? color : .white.opacity(0.28))
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 11)
    }

    @ViewBuilder
    private func rowTrunc(_ label: String,
                          _ value: String?,
                          _ color: Color = .white) -> some View {
        HStack(alignment: .center) {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.50))
                .frame(minWidth: 110, alignment: .leading)
            Spacer()
            Text(value ?? "—")
                .font(.system(size: 13))
                .foregroundColor(value != nil ? color : .white.opacity(0.28))
                .lineLimit(1)
                .truncationMode(.middle)
                .frame(maxWidth: 170, alignment: .trailing)
        }
        .padding(.vertical, 11)
    }

    @ViewBuilder
    private var rowDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.07))
            .frame(maxWidth: .infinity, minHeight: 0.5, maxHeight: 0.5)
    }

    // MARK: - Date formatter

    private func fmtDate(_ raw: String?) -> String {
        guard let raw, !raw.isEmpty else { return "—" }
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        ]
        let out = DateFormatter()
        out.dateFormat = "MMM dd, yyyy"
        for fmt in formats {
            let df = DateFormatter()
            df.dateFormat = fmt
            if let date = df.date(from: raw) { return out.string(from: date) }
        }
        return String(raw.prefix(10))
    }
}
