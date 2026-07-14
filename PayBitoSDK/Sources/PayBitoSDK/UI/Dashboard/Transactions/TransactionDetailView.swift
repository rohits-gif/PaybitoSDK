
//
//  TransactionDetailView.swift
//  Trading_Terminal
//

import SwiftUI

// MARK: - Transaction Detail View

struct TransactionDetailView: View {
    let transaction: TransactionP
    let viewModel: TransactionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showMarkAsTestAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.bbDarkBG.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        statusSection
                        customerSection
                        paymentDetailsSection
                        transactionDetailsSection
                        if isSubscription { subscriptionSection }
                        actionsSection
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Transaction Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
        .alert("Mark Transaction", isPresented: $showMarkAsTestAlert) {
            Button("Cancel", role: .cancel) {}
            Button(isTest ? "Mark as Regular" : "Mark as Test") {
                viewModel.markTransactions(
                    ids: [String(transaction.transactionId)],
                    asTest: !isTest
                ) { success in
                    if success { dismiss() }
                }
            }
        } message: {
            Text(isTest
                 ? "This will mark the transaction as a regular transaction."
                 : "This will mark the transaction as a test transaction.")
        }
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(spacing: 16) {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: statusIcon)
                        .font(.system(size: 48))
                        .foregroundColor(statusColor)
                    Text(statusDisplayName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(statusColor)
                }
                Spacer()
            }
            .padding(.vertical, 20)
            .background(Color.bbCardBG)
            .cornerRadius(14)

            // Amount breakdown — matches web drawer
            VStack(spacing: 6) {
                Text(formattedTotalAmount)
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.white)

                HStack(spacing: 12) {
                    Text("Base: \(fmtAmt(transaction.baseAmount, transaction.currency))")
                        .font(.system(size: 12))
                        .foregroundColor(Color.bbLabelGray)
                    Text("·")
                        .foregroundColor(Color.bbLabelGray.opacity(0.4))
                    Text("Fee: \(fmtAmt(transaction.feeAmount, transaction.currency))")
                        .font(.system(size: 12))
                        .foregroundColor(Color.bbLabelGray)
                }

                if isTest {
                    HStack(spacing: 5) {
                        Image(systemName: "testtube.2").font(.system(size: 11))
                        Text("Test Transaction").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.95, green: 0.65, blue: 0.10))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Color(red: 0.95, green: 0.65, blue: 0.10).opacity(0.15))
                    .cornerRadius(6)
                }
            }
        }
    }

    // MARK: - Customer Section

    private var customerSection: some View {
        DetailSection(title: "Customer") {
            if let email = transaction.customerEmail, !email.isEmpty {
                DetailRow(label: "Email", value: email, icon: "envelope.fill")
            }
            if let id = transaction.customerId {
                DetailRow(label: "Customer ID", value: "\(id)", icon: "number", isCopyable: true)
            }
            if let identity = transaction.customerIdentity, !identity.isEmpty {
                DetailRow(label: "Identity", value: identity, icon: "person.badge.shield.checkmark")
            }
            if let type = transaction.paymentType {
                DetailRow(label: "Payment Type", value: type, icon: "arrow.triangle.2.circlepath")
            }
        }
    }

    // MARK: - Payment Details Section

    private var paymentDetailsSection: some View {
        DetailSection(title: "Payment Details") {
            DetailRow(label: "Transaction ID", value: "#\(transaction.transactionId)",
                      icon: "barcode", isCopyable: true)

            if let linkId = transaction.paymentLinkId, !linkId.isEmpty {
                DetailRow(label: "Payment Link ID", value: linkId, icon: "link", isCopyable: true)
            }
            if let method = transaction.paymentMethod, !method.isEmpty {
                DetailRow(label: "Payment Method", value: method, icon: "wallet.pass")
            }
            if let network = transaction.paymentSubDetails, !network.isEmpty {
                DetailRow(label: "Network", value: network, icon: "network")
            }
            if let currency = transaction.currency {
                DetailRow(label: "Currency", value: currency, icon: "dollarsign.circle")
            }
            if let session = transaction.sessionId, !session.isEmpty {
                DetailRow(label: "Session / Address", value: session,
                          icon: "link.circle", isCopyable: true)
            }
            if let intent = transaction.intentId, !intent.isEmpty {
                DetailRow(label: "Intent ID", value: intent, icon: "doc.text", isCopyable: true)
            }
        }
    }

    // MARK: - Transaction Details Section

    private var transactionDetailsSection: some View {
        DetailSection(title: "Transaction Details") {
            if let product = displayProductName {
                DetailRow(label: "Product", value: product, icon: "shippingbox")
            }
            if let created = transaction.paymentCreatedAt {
                DetailRow(label: "Created", value: formatDateString(created), icon: "clock")
            }
            if let processed = transaction.paymentProcessAt {
                DetailRow(label: "Processed", value: formatDateString(processed),
                          icon: "checkmark.circle")
            }
            DetailRow(label: "Test Mode", value: isTest ? "Yes" : "No",
                      icon: isTest ? "testtube.2" : "checkmark.circle.fill")
            if let action = transaction.actionRequired {
                DetailRow(label: "Action Required",
                          value: action == 1 ? "Yes" : "No",
                          icon: "exclamationmark.triangle")
            }
        }
    }

    // MARK: - Subscription Section

    private var subscriptionSection: some View {
        DetailSection(title: "Subscription Info") {
            if let subId = transaction.subscriptionId, subId != "0" {
                DetailRow(label: "Subscription ID", value: subId,
                          icon: "arrow.triangle.2.circlepath", isCopyable: true)
            }
            if let status = transaction.subscriptionStatus {
                DetailRow(label: "Sub. Status", value: status.capitalized,
                          icon: "circle.fill")
            }
            if let cycle = transaction.cycle, cycle != "0" {
                DetailRow(label: "Billing Cycle", value: cycle, icon: "calendar.badge.clock")
            }
            if let next = transaction.nextBillingDate {
                DetailRow(label: "Next Billing", value: formatDateString(next),
                          icon: "calendar")
            }
            if let days = transaction.trialDays, days > 0 {
                DetailRow(label: "Trial Days", value: "\(days) days", icon: "gift")
            }
        }
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        Button(action: { showMarkAsTestAlert = true }) {
            HStack {
                Image(systemName: isTest ? "checkmark.circle" : "testtube.2")
                Text(isTest ? "Mark as Regular" : "Mark as Test")
                    .font(.system(size: 15, weight: .semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(.white)
            .background(Color.bbCardBG)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bbBorder, lineWidth: 1))
        }
    }

    // MARK: - Helpers

    private var isTest: Bool { transaction.testMode == 1 }

    private var isSubscription: Bool {
        transaction.paymentType == "RECURRING" ||
        transaction.paymentType == "SUBSCRIPTION" ||
        (transaction.subscriptionId != nil && transaction.subscriptionId != "0")
    }
    
    private var displayProductName: String? {
        if let details = transaction.productDetails,
           let first = details.first,
           let name = first.productName,
           !name.isEmpty {
            return name
        }
        return nil
    }

    // Mirrors web mapStatus()
    private var mappedStatus: String {
        guard let s = transaction.status?.lowercased() else { return "pending" }
        let succeeded  = ["success","succeeded","payment_confirmed",
                          "closed_with_autometic_overpayment","closed_with_exact_payment",
                          "closed_with_manual_overpayment"]
        let failed     = ["failed","invoice_expired","payment_failed","closed_with_underpayment"]
        let refunded   = ["refunded","refund_approved","refund_requested"]
        let processing = ["payment_created","payment_processing","payment_initiated",
                          "waiting","processing"]
        let cancelled  = ["subscription_canclled","subscription_cancelled"]
        if succeeded.contains(s)  { return "succeeded" }
        if failed.contains(s)     { return "failed" }
        if refunded.contains(s)   { return "refunded" }
        if processing.contains(s) { return "processing" }
        if cancelled.contains(s)  { return "cancelled" }
        return "pending"
    }

    private var statusColor: Color {
        switch mappedStatus {
        case "succeeded":  return Color.bbAccentGreen
        case "failed":     return Color(red: 0.97, green: 0.34, blue: 0.34)
        case "refunded":   return Color(red: 0.51, green: 0.55, blue: 0.98)
        case "processing": return Color(red: 0.96, green: 0.62, blue: 0.11)
        case "cancelled":  return Color(red: 0.94, green: 0.27, blue: 0.27)
        default:           return Color.bbLabelGray
        }
    }

    private var statusIcon: String {
        switch mappedStatus {
        case "succeeded":  return "checkmark.circle.fill"
        case "failed":     return "xmark.circle.fill"
        case "refunded":   return "arrow.counterclockwise.circle.fill"
        case "processing": return "clock.fill"
        case "cancelled":  return "minus.circle.fill"
        default:           return "hourglass"
        }
    }

    // Mirrors web statusLabel()
    private var statusDisplayName: String {
        let labels: [String: String] = [
            "payment_created":                    "Payment Created",
            "payment_processing":                 "Payment Processing",
            "payment_initiated":                  "Payment Initiated",
            "payment_confirmed":                  "Payment Confirmed",
            "closed_with_exact_payment":          "Closed",
            "closed_with_autometic_overpayment":  "Closed w/ Overpayment",
            "closed_with_manual_overpayment":     "Closed w/ Overpayment",
            "closed_with_underpayment":           "Closed w/ Underpayment",
            "invoice_expired":                    "Expired",
            "payment_failed":                     "Failed",
            "refunded":                           "Refunded",
            "refund_approved":                    "Refund Approved",
            "refund_requested":                   "Refund Requested",
            "subscription_canclled":              "Subscription Cancelled",
            "subscription_cancelled":             "Subscription Cancelled",
            "succeeded":                          "Succeeded",
            "success":                            "Success",
            "failed":                             "Failed",
            "processing":                         "Processing",
            "pending":                            "Pending"
        ]
        return labels[transaction.status?.lowercased() ?? ""]
            ?? transaction.status ?? "Processing"
    }

    private var formattedTotalAmount: String {
        fmtAmt((transaction.baseAmount ?? 0) + (transaction.feeAmount ?? 0),
               transaction.currency)
    }

    private func fmtAmt(_ value: Double?, _ currency: String?) -> String {
        let num = value ?? 0
        let sym = currency == "USD" ? "$" : currency == "EUR" ? "€" : ""
        let suffix = ["USD","EUR","GBP"].contains(currency ?? "") ? "" : " \(currency ?? "")"
        if abs(num) < 0.0001 && num != 0 {
            return "\(sym)\(String(format: "%.8f", num))\(suffix)"
        }
        return "\(sym)\(String(format: "%.2f", num))\(suffix)"
    }

    private func formatDateString(_ raw: String) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = f.date(from: raw) {
            f.dateFormat = "MMM d, yyyy · h:mm a"
            return f.string(from: date)
        }
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) {
            f.dateFormat = "MMM d, yyyy · h:mm a"
            return f.string(from: date)
        }
        return raw
    }
}

// MARK: - Detail Section

private struct DetailSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if #available(iOS 16.0, *) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.bbLabelGray)
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .padding(.horizontal, 4)
            } else {
                // Fallback on earlier versions
            }

            VStack(spacing: 0) {
                content
            }
            .background(Color.bbCardBG)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bbBorder, lineWidth: 1))
        }
    }
}

// MARK: - Detail Row

private struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    var isCopyable: Bool = false
    @State private var copied = false

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color.bbLabelGray)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(Color.bbLabelGray)
                Text(value)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            if isCopyable {
                Button(action: {
                    UIPasteboard.general.string = value
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                }) {
                    Image(systemName: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundColor(copied ? Color.bbAccentGreen : Color.bbLabelGray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .overlay(
            Divider().background(Color.bbBorder),
            alignment: .bottom
        )
    }
}

// MARK: - Export Sheet
// MARK: - Export Sheet

struct ExportSheet: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var exportedFileURL: URL?
    @State private var showShareSheet = false
    @State private var exportError: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.bbDarkBG.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 64))
                        .foregroundColor(Color.bbAccentBlue)

                    Text("Export Transactions")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text("Export current transactions as a CSV file with filters applied.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.bbLabelGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    if let error = exportError {
                        Text(error)
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.97, green: 0.34, blue: 0.34))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    Spacer()

                    Button(action: exportCSV) {
                        if isExporting {
                            ProgressView().tint(.white)
                        } else {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("Export CSV")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(.white)
                    .background(viewModel.transactions.isEmpty
                                ? Color.bbAccentBlue.opacity(0.4)
                                : Color.bbAccentBlue)
                    .cornerRadius(12)
                    .disabled(isExporting || viewModel.transactions.isEmpty)
                    .padding(.horizontal, 20)

                    if viewModel.transactions.isEmpty {
                        Text("No transactions to export")
                            .font(.system(size: 12))
                            .foregroundColor(Color.bbLabelGray)
                    }
                }
                .padding(.vertical, 40)
            }
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = exportedFileURL {
                ShareSheet(items: [url])
            }
        }
    }

    // Matches web handleExportCSV — builds CSV client-side from txnList
    private func exportCSV() {
        guard !viewModel.transactions.isEmpty else { return }
        isExporting = true
        exportError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let headers = [
                "Transaction ID", "Customer ID", "Customer Email",
                "Customer Identity", "Product Name", "Payment Type",
                "Currency", "Base Amount", "Fee Amount", "Total Amount",
                "Paid Amount", "Status", "Payment Method", "Network",
                "Session ID", "Created Date", "Processed Date", "Test Mode"
            ]

            let rows: [[String]] = viewModel.transactions.map { t in
                let productName: String
                if let details = t.productDetails,
                   let first = details.first,
                   let name = first.productName { productName = name }
                else { productName = "—" }

                let base  = t.baseAmount ?? 0
                let fee   = t.feeAmount  ?? 0
                let total = base + fee

                return [
                    "\(t.transactionId)",
                    t.customerId != nil ? "\(t.customerId!)" : "—",
                    t.customerEmail ?? "—",
                    t.customerIdentity ?? "—",
                    productName,
                    t.paymentType ?? "ONE-TIME",
                    t.currency ?? "—",
                    String(base),
                    String(fee),
                    String(total),
                    String(t.paidAmount ?? 0),
                    t.status ?? "—",
                    t.paymentMethod ?? "—",
                    t.paymentSubDetails ?? "—",
                    t.sessionId ?? "—",
                    t.paymentCreatedAt ?? "—",
                    t.paymentProcessAt ?? "—",
                    t.testMode == 1 ? "Yes" : "No"
                ]
            }

            let csvLines = ([headers] + rows).map { row in
                row.map { cell in
                    "\"\(cell.replacingOccurrences(of: "\"", with: "\"\""))\""
                }.joined(separator: ",")
            }
            let csvString = "\u{FEFF}" + csvLines.joined(separator: "\n")

            guard let data = csvString.data(using: .utf8) else {
                DispatchQueue.main.async {
                    isExporting = false
                    exportError = "Failed to generate CSV."
                }
                return
            }

            let timestamp = Int(Date().timeIntervalSince1970)
            let fileName  = "transactions_\(timestamp).csv"
            let tempURL   = FileManager.default.temporaryDirectory
                .appendingPathComponent(fileName)

            do {
                try data.write(to: tempURL, options: .atomic)
                DispatchQueue.main.async {
                    isExporting = false
                    exportedFileURL = tempURL
                    showShareSheet  = true
                }
            } catch {
                DispatchQueue.main.async {
                    isExporting = false
                    exportError = "Failed to save file: \(error.localizedDescription)"
                }
            }
        }
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @ObservedObject var viewModel: TransactionsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.bbDarkBG.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        FilterOptionSection(title: "Date Range") {
                            ForEach(DateRangeFilter.allCases.filter { $0 != .custom }, id: \.self) { range in
                                FilterOptionRow(
                                    title: range.rawValue,
                                    isSelected: viewModel.selectedDateRange == range
                                ) {
                                    viewModel.applyDateRange(range)
                                }
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Reset") { viewModel.clearFilters() }.foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - Filter Option Components

private struct FilterOptionSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.white)

            VStack(spacing: 1) { content }
                .background(Color.bbCardBG)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bbBorder, lineWidth: 1))
        }
    }
}

private struct FilterOptionRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title).font(.system(size: 14)).foregroundColor(.white)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color.bbAccentBlue)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(isSelected ? Color.bbAccentBlue.opacity(0.1) : Color.clear)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

