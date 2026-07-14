//
//  Analyticsmodels.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 28/04/26.
//

import Foundation

// MARK: - Common Base

struct BaseResponse: Codable {
    let error: String
    let errorMsg: String?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg  = "error_msg"
        case message
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Shared Request Payload

struct AnalyticsPayload: Encodable {
    let merchantId: String
    let currency:   String
    let startDate:  String
    let endDate:    String
    var timeDuration: String?

    enum CodingKeys: String, CodingKey {
        case merchantId   = "merchant_id"
        case currency
        case startDate    = "start_date"
        case endDate      = "end_date"
        case timeDuration = "time_duration"
    }
}

// MARK: - Key Metrics

struct KeyMetricsResponse: Codable {
    let error: String
    let errorMsg: String?
    let message: String?
    let totalProcessedVolume: Double?
    let totalTransactions:    Int?
    let successRate:          Double?
    let averagePaymentSize:   Double?
    let processingFeesCollected: Double?
    let customerPaidFees:     Double?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg               = "error_msg"
        case message
        case totalProcessedVolume   = "total_processed_volume"
        case totalTransactions      = "total_transactions"
        case successRate            = "success_rate"
        case averagePaymentSize     = "average_payment_size"
        case processingFeesCollected = "processing_fees_collected"
        case customerPaidFees       = "customer_paid_fees"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Revenue Over Time

struct RevenueChartPoint: Codable {
    let timeStamp:    String?
    let vol:          String?
    let paymentCount: String?
    let txnCharge:    String?

    enum CodingKeys: String, CodingKey {
        case timeStamp    = "time_stamp"
        case vol
        case paymentCount = "payment_count"
        case txnCharge    = "TXN_CHARGE"
    }

    var revenue:      Double { Double(vol ?? "0") ?? 0 }
    var count:        Int    { Int(paymentCount ?? "0") ?? 0 }
    var fees:         Double { Double(txnCharge ?? "0") ?? 0 }

    var formattedDate: String {
        guard let ts = timeStamp else { return "" }
        let iso = ISO8601DateFormatter()
        iso.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fallback = DateFormatter()
        fallback.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = iso.date(from: ts) ?? fallback.date(from: ts) ?? Date()
        let out = DateFormatter()
        out.dateFormat = "MMM yyyy"
        return out.string(from: date)
    }
}

struct RevenueOverTimeResponse: Codable {
    let error:     String
    let errorMsg:  String?
    let message:   String?
    let chartData: [RevenueChartPoint]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg  = "error_msg"
        case message
        case chartData = "chart_data"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Transaction Health

struct PaymentStatusBreakdown: Codable {
    let successCount: String?
    let pendingCount: String?
    let expiredCount: String?
    let failedCount:  String?

    enum CodingKeys: String, CodingKey {
        case successCount = "SUCCESS_COUNT"
        case pendingCount = "PENDING_COUNT"
        case expiredCount = "EXPIRED_COUNT"
        case failedCount  = "FAILED_COUNT"
    }
}

struct PaymentMethodItem: Codable {
    let currencyCode:     String?
    let transactionCount: String?
    let percentage:       String?

    enum CodingKeys: String, CodingKey {
        case currencyCode     = "CURRENCY_CODE"
        case transactionCount = "TRANSACTION_COUNT"
        case percentage       = "PERCENTAGE"
    }

    var count: Int    { Int(transactionCount ?? "0") ?? 0 }
    var pct:   Double { Double(percentage ?? "0") ?? 0 }
}

struct TransactionHealthResponse: Codable {
    let error:     String
    let errorMsg:  String?
    let message:   String?
    let paymentStatusBreakdown:    [PaymentStatusBreakdown]?
    let paymentMethodDistribution: [PaymentMethodItem]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg                  = "error_msg"
        case message
        case paymentStatusBreakdown    = "payment_status_breakdown"
        case paymentMethodDistribution = "payment_method_distribution"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Payment Source Performance

struct PaymentSourceItem: Codable {
    let paymentType:      String?
    let transactionCount: String?
    let revenue:          String?

    enum CodingKeys: String, CodingKey {
        case paymentType      = "payment_type"
        case transactionCount = "transaction_count"
        case revenue
    }

    var count:      Int    { Int(transactionCount ?? "0") ?? 0 }
    var revenueVal: Double { Double(revenue ?? "0") ?? 0 }
    var displayName: String {
        (paymentType ?? "—").replacingOccurrences(of: "_", with: " ")
    }
}

struct PaymentSourcePerformanceResponse: Codable {
    let error:             String
    let errorMsg:          String?
    let message:           String?
    let paymentSourceData: [PaymentSourceItem]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg          = "error_msg"
        case message
        case paymentSourceData = "payment_source_data"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Top Products

struct TopProductItem: Codable {
    let productDescription: String?
    let transactionCount:   String?
    let revenue:            String?

    enum CodingKeys: String, CodingKey {
        case productDescription = "product_description"
        case transactionCount   = "transaction_count"
        case revenue
    }

    var count:      Int    { Int(transactionCount ?? "0") ?? 0 }
    var revenueVal: Double { Double(revenue ?? "0") ?? 0 }
}

struct TopProductsResponse: Codable {
    let error:           String
    let errorMsg:        String?
    let message:         String?
    let topProductsData: [TopProductItem]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg        = "error_msg"
        case message
        case topProductsData = "top_products_data"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Transaction Size Distribution

struct TxnSizeBucket: Codable {
    let bucket:           String?
    let transactionCount: String?

    enum CodingKeys: String, CodingKey {
        case bucket
        case transactionCount = "transaction_count"
    }

    var count: Int { Int(transactionCount ?? "0") ?? 0 }
}

struct TxnSizeDistributionResponse: Codable {
    let error:                      String
    let errorMsg:                   String?
    let message:                    String?
    let transactionSizeDistribution: [TxnSizeBucket]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg                    = "error_msg"
        case message
        case transactionSizeDistribution = "transaction_size_distribution"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Geographic Distribution

struct GeoItem: Codable {
    let country:          String?
    let transactionCount: String?

    enum CodingKeys: String, CodingKey {
        case country
        case transactionCount = "transaction_count"
    }

    var count: Int { Int(transactionCount ?? "0") ?? 0 }
}

struct GeographicDistributionResponse: Codable {
    let error:                  String
    let errorMsg:               String?
    let message:                String?
    let geographicDistribution: [GeoItem]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg               = "error_msg"
        case message
        case geographicDistribution = "geographic_distribution"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Failure Summary

struct FailureItem: Codable {
    let reason:           String?
    let transactionCount: String?

    enum CodingKeys: String, CodingKey {
        case reason
        case transactionCount = "transaction_count"
    }

    var count: Int { Int(transactionCount ?? "0") ?? 0 }
}

struct FailureTxnSummaryResponse: Codable {
    let error:          String
    let errorMsg:       String?
    let message:        String?
    let failureTxnData: [FailureItem]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg       = "error_msg"
        case message
        case failureTxnData = "failure_txn_data"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Settlement Overview

struct SettlementOverviewResponse: Codable {
    let error:             String
    let errorMsg:          String?
    let message:           String?
    let totalSettled:      Double?
    let pendingSettlement: Double?
    let avgSettlementTime: Double?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg          = "error_msg"
        case message
        case totalSettled      = "total_settled"
        case pendingSettlement = "pending_settlement"
        case avgSettlementTime = "avg_settlement_time"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Reports

struct ReportPayload: Encodable {
    let merchantId: String
    let currency:   String
    let startDate:  String
    let endDate:    String
    let reportType: String
    let offset:     Int
    let limit:      Int

    enum CodingKeys: String, CodingKey {
        case merchantId = "merchant_id"
        case currency
        case startDate  = "start_date"
        case endDate    = "end_date"
        case reportType = "report_type"
        case offset
        case limit
    }
}

struct ReportResponse: Codable {
    let error:      String
    let errorMsg:   String?
    let message:    String?
    let reportData: [[String: String?]]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg   = "error_msg"
        case message
        case reportData = "report_data"
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - View Model helper types

struct ChartDataPoint: Identifiable {
    let id    = UUID()
    let label:   String
    let revenue: Double
    let count:   Int
    let fees:    Double
}

struct StatusSlice: Identifiable {
    let id    = UUID()
    let label: String
    let value: Int
    let color: String   // hex string for SwiftUI Color(hex:)
}

struct MethodBar: Identifiable {
    let id         = UUID()
    let label:     String
    let value:     Int
    let percentage: Double
    let color:     String
}

// Replace existing ReportRow with this universal model
struct ReportRow: Codable {

    // TRANSACTIONS
    let invoiceId:              String?
    let invoiceDate:            String?
    let currency:               String?
    let amountPaid:             String?
    let amountPaidHomeCurr:     String?
    let status:                 String?

    // FEES (extra fields)
    let txnCharge:              String?
    let txnChargeHomeCurr:      String?
    let txnPer:                 String?

    // REVENUE_SUMMARY (extra fields)
    let totalInvoices:          String?
    let totalAmountPaid:        String?
    let totalAmountPaidHomeCurr: String?

    // SUBSCRIPTIONS (extra fields)
    let customerName:           String?
    let customerEmail:          String?
    let amount:                 String?
    let recurringPeriod:        String?
    let totalCycles:            String?
    let startDate:              String?
    let nextBillingDate:        String?
    let description:            String?

    enum CodingKeys: String, CodingKey {
        case invoiceId              = "invoice_id"
        case invoiceDate            = "invoice_date"
        case currency
        case amountPaid             = "amount_paid"
        case amountPaidHomeCurr     = "amount_paid_home_curr"
        case status
        case txnCharge              = "txn_charge"
        case txnChargeHomeCurr      = "txn_charge_home_curr"
        case txnPer                 = "txn_per"
        case totalInvoices          = "total_invoices"
        case totalAmountPaid        = "total_amount_paid"
        case totalAmountPaidHomeCurr = "total_amount_paid_home_curr"
        case customerName           = "customer_name"
        case customerEmail          = "customer_email"
        case amount
        case recurringPeriod        = "recurring_period"
        case totalCycles            = "total_cycles"
        case startDate              = "start_date"
        case nextBillingDate        = "next_billing_date"
        case description
    }
}
