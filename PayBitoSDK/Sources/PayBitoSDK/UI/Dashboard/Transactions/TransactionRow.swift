//
//  TransactionRow.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 27/04/26.
//

//
//  TransactionRow.swift
//  Trading_Terminal
//

import SwiftUI

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: TransactionP
    var isSelected: Bool = false
    var onSelect: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

   
            HStack(alignment: .top, spacing: 10) {

                // Checkbox (only shown when onSelect provided)
                if let onSelect {
                    Button(action: onSelect) {
                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                            .font(.system(size: 18))
                            .foregroundColor(isSelected ? Color.bbAccentBlue : Color.bbLabelGray)
                    }
                    .buttonStyle(.plain)
                }

                // Txn ID + TEST badge
                VStack(alignment: .leading, spacing: 3) {
                    Text("#\(transaction.transactionId)")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color.bbAccentBlue)
                        .lineLimit(1)

                    if transaction.testMode == 1 {
                        Text("TEST")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color.bbLabelGray)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.bbLabelGray.opacity(0.15))
                            .cornerRadius(4)
                    }
                }

                Spacer()

                // Status badge
                statusBadge

                // Amount + Date
                VStack(alignment: .trailing, spacing: 3) {
                    Text(formattedAmount)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(amountColor)

                    Text(formattedDate)
                        .font(.system(size: 11))
                        .foregroundColor(Color.bbLabelGray)
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            Divider()
                .background(Color.bbBorder)
                .padding(.horizontal, 14)

            // ── Bottom: Product | Method | Network | Address ──
            VStack(alignment: .leading, spacing: 7) {

                // Product name + payment type tag
                HStack(spacing: 8) {
                    Text(displayProductName)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Spacer()

                    // Payment type tag — ONE-TIME / SUBSCRIPTION / RECURRING
                    if let paymentType = transaction.paymentType {
                        Text(paymentType)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(paymentType == "SUBSCRIPTION" || paymentType == "RECURRING"
                                ? Color(red: 0.67, green: 0.55, blue: 0.99)
                                : Color(red: 0.38, green: 0.64, blue: 0.98))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background((paymentType == "SUBSCRIPTION" || paymentType == "RECURRING"
                                ? Color(red: 0.55, green: 0.36, blue: 0.96)
                                : Color(red: 0.23, green: 0.51, blue: 0.96)).opacity(0.15))
                            .cornerRadius(5)
                    }
                }

                // Customer email
                if let email = transaction.customerEmail, !email.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color.bbLabelGray)
                        Text(email)
                            .font(.system(size: 12))
                            .foregroundColor(Color.bbLabelGray)
                            .lineLimit(1)
                    }
                }

                // Method + Network row
                HStack(spacing: 16) {
                    if let method = transaction.paymentMethod, !method.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: paymentMethodIcon(method))
                                .font(.system(size: 11))
                                .foregroundColor(Color.bbLabelGray)
                            Text(method)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color.bbLabelGray)
                        }
                    }

                    Spacer()

                    if let network = transaction.paymentSubDetails, !network.isEmpty {
                        HStack(spacing: 5) {
                            Image(systemName: "network")
                                .font(.system(size: 11))
                                .foregroundColor(Color.bbLabelGray)
                            Text(network)
                                .font(.system(size: 12))
                                .foregroundColor(Color.bbLabelGray)
                        }
                    }
                }

                // Session / Address (truncated)
                if let address = transaction.sessionId, !address.isEmpty {
                    HStack(spacing: 5) {
                        Image(systemName: "link")
                            .font(.system(size: 11))
                            .foregroundColor(Color.bbLabelGray.opacity(0.6))
                        Text(address.count > 20
                             ? String(address.prefix(20)) + "…"
                             : address)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color.bbLabelGray.opacity(0.6))
                            .lineLimit(1)
                    }
                }

                // Fee breakdown — matches web "Base: x | Fee: y"
                HStack(spacing: 4) {
                    Text("Base: \(fmtAmt(transaction.baseAmount, transaction.currency))")
                        .font(.system(size: 11))
                        .foregroundColor(Color.bbLabelGray.opacity(0.7))
                    Text("·")
                        .foregroundColor(Color.bbLabelGray.opacity(0.4))
                    Text("Fee: \(fmtAmt(transaction.feeAmount, transaction.currency))")
                        .font(.system(size: 11))
                        .foregroundColor(Color.bbLabelGray.opacity(0.7))

                    Spacer()

                    // Currency tag
                    if let currency = transaction.currency {
                        Text(currency)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(red: 0.13, green: 0.86, blue: 0.93))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Color(red: 0.04, green: 0.71, blue: 0.85).opacity(0.12))
                            .cornerRadius(5)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 14)
        }
        .background(isSelected
            ? Color.bbAccentBlue.opacity(0.06)
            : Color.bbCardBG)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSelected ? Color.bbAccentBlue.opacity(0.3) : Color.bbBorder,
                        lineWidth: 1)
        )
    }

    // MARK: - Status Badge
    // Matches web mapStatus() + statusLabel()

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(statusColor)
                .frame(width: 6, height: 6)
            Text(statusDisplayName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(statusColor)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(statusColor.opacity(0.12))
        .cornerRadius(20)
    }

    // Maps raw status strings — mirrors web mapStatus()
    private var mappedStatus: String {
        guard let s = transaction.status?.lowercased() else { return "pending" }
        let succeeded = ["success","succeeded","payment_confirmed",
                         "closed_with_autometic_overpayment","closed_with_exact_payment",
                         "closed_with_manual_overpayment"]
        let failed    = ["failed","invoice_expired","payment_failed","closed_with_underpayment"]
        let refunded  = ["refunded","refund_approved","refund_requested"]
        let processing = ["payment_created","payment_processing","payment_initiated",
                          "waiting","processing"]
        let cancelled = ["subscription_canclled","subscription_cancelled"]

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

    // Mirrors web statusLabel()
    private var statusDisplayName: String {
        let labels: [String: String] = [
            "payment_created": "Payment Created",
            "payment_processing": "Payment Processing",
            "payment_initiated": "Payment Initiated",
            "payment_confirmed": "Payment Confirmed",
            "closed_with_exact_payment": "Closed",
            "closed_with_autometic_overpayment": "Closed w/ Overpayment",
            "closed_with_manual_overpayment": "Closed w/ Overpayment",
            "closed_with_underpayment": "Closed w/ Underpayment",
            "invoice_expired": "Expired",
            "payment_failed": "Failed",
            "refunded": "Refunded",
            "refund_approved": "Refund Approved",
            "refund_requested": "Refund Requested",
            "subscription_canclled": "Sub. Cancelled",
            "subscription_cancelled": "Sub. Cancelled",
            "succeeded": "Succeeded",
            "success": "Success",
            "failed": "Failed",
            "processing": "Processing",
            "pending": "Pending"
        ]
        return labels[transaction.status?.lowercased() ?? ""] ?? (transaction.status ?? "Processing")
    }

    // MARK: - Computed Helpers

    // Matches web displayProductName logic
    private var displayProductName: String {
        if let details = transaction.productDetails,
           let first = details.first,
           let name = first.productName,
           !name.isEmpty {
            return name
        }
        return "—"
    }

    private var amountColor: Color {
        switch mappedStatus {
        case "succeeded": return Color.bbAccentGreen
        case "failed":    return Color(red: 0.97, green: 0.34, blue: 0.34)
        case "refunded":  return Color(red: 0.96, green: 0.62, blue: 0.11)
        default:          return .white
        }
    }

    // Matches web fmtAmt — total = base + fee
    private var formattedAmount: String {
        let base = transaction.baseAmount ?? 0
        let fee  = transaction.feeAmount  ?? 0
        return fmtAmt(base + fee, transaction.currency)
    }

    private func fmtAmt(_ value: Double?, _ currency: String?) -> String {
        let num = value ?? 0
        let sym = currency == "USD" ? "$" : currency == "EUR" ? "€" : ""
        let suffix = ["USD","EUR","GBP"].contains(currency ?? "") ? "" : " \(currency ?? "")"
        if abs(num) < 0.0001 && num != 0 {
            return "\(sym)\(String(format: "%.8f", num))\(suffix)"
        }
        let formatted = String(format: "%.2f", num)
        return "\(sym)\(formatted)\(suffix)"
    }

    // Matches web fmtDate
    private var formattedDate: String {
        let raw = transaction.paymentCreatedAt ?? transaction.txnDate ?? ""
        guard !raw.isEmpty else { return "—" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        // Try "yyyy-MM-dd HH:mm:ss" first (backend format)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: raw) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        // Fallback: ISO8601
        let iso = ISO8601DateFormatter()
        if let date = iso.date(from: raw) {
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
        return raw
    }

    private func paymentMethodIcon(_ method: String) -> String {
        let m = method.lowercased()
        if m.contains("stripe")                    { return "creditcard.fill" }
        if m.contains("paypal")                    { return "p.circle.fill" }
        if m.contains("bitcoin") || m.contains("btc") { return "bitcoinsign.circle" }
        if m.contains("eth")                       { return "e.circle" }
        if m.contains("wallet")                    { return "wallet.pass.fill" }
        return "creditcard"
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bbDarkBG.ignoresSafeArea()

        ScrollView {
            VStack(spacing: 12) {

                TransactionRow(
                    transaction: TransactionP(
                        transactionId: 12345,
                        merchantId: 29738,
                        customerId: 123,
                        customerEmail: "john.doe@example.com",
                        customerIdentity: "VERIFIED",
                        productDetails: nil,
                        paymentType: "ONE-TIME",
                        currency: "USD",
                        baseAmount: 149.00,
                        feeAmount: 1.50,
                        discountAmount: nil,
                        paidAmount: 150.50,
                        status: "payment_confirmed",
                        paymentMethod: "STRIPE",
                        paymentSubDetails: "NATIVE",
                        sessionId: "cs_live_abc123xyz",
                        intentId: nil,
                        paymentLinkId: nil,
                        subscriptionId: nil,
                        subscriptionStatus: nil,
                        nextBillingDate: nil,
                        cycle: nil,
                        trialDays: nil,
                        isTrialAvailed: nil,
                        testMode: 0,
                        actionRequired: 0,
                        paymentCreatedAt: "2026-04-27 10:30:00",
                        paymentInitiatedAt: nil,
                        paymentProcessAt: "2026-04-27 10:31:00",
                        txnDate: nil
                    ),
                    isSelected: false,
                    onSelect: {}
                )

                TransactionRow(
                    transaction: TransactionP(
                        transactionId: 67890,
                        merchantId: 29738,
                        customerId: 456,
                        customerEmail: "jane.smith@example.com",
                        customerIdentity: "GUEST",
                        productDetails: nil,
                        paymentType: "SUBSCRIPTION",
                        currency: "BTC",
                        baseAmount: 0.00215,
                        feeAmount: 0.00005,
                        discountAmount: nil,
                        paidAmount: 0.0022,
                        status: "payment_failed",
                        paymentMethod: "Brand Wallet",
                        paymentSubDetails: "ERC",
                        sessionId: "0xabc123def456",
                        intentId: nil,
                        paymentLinkId: nil,
                        subscriptionId: "sub_123",
                        subscriptionStatus: "active",
                        nextBillingDate: nil,
                        cycle: "monthly",
                        trialDays: nil,
                        isTrialAvailed: nil,
                        testMode: 1,
                        actionRequired: 0,
                        paymentCreatedAt: "2026-04-26 08:15:00",
                        paymentInitiatedAt: nil,
                        paymentProcessAt: nil,
                        txnDate: nil
                    ),
                    isSelected: true,
                    onSelect: {}
                )
            }
            .padding()
        }
    }
}
