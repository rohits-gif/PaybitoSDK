//
//  TransactionModels.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 27/04/26.
//
//
//  TransactionModels.swift
//  Trading_Terminal
//

import Foundation
import SwiftUI

// MARK: - Filter Request (matches web fetchTransactions payload exactly)

struct TransactionFilterRequest: Encodable {
    let merchantId: Int
    let status: String
    let paymentMethod: String
    let network: String
    let search: String
    let productName: String
    let catalogueName: String
    let subscriptionId: String
    let customerId: String
    let customerIdentity: String
    let paymentType: String
    let currency: String
    let dateRange: String
    let fromDate: String
    let toDate: String
    let page: Int
    let pageSize: Int

    enum CodingKeys: String, CodingKey {
        case merchantId          // ✅ stays camelCase — API expects "merchantId"
        case status
        case paymentMethod       // ✅ camelCase
        case network
        case search
        case productName         // ✅ camelCase
        case catalogueName       // ✅ camelCase
        case subscriptionId      // ✅ camelCase
        case customerId          // ✅ camelCase
        case customerIdentity    // ✅ camelCase
        case paymentType         // ✅ camelCase
        case currency
        case dateRange           // ✅ camelCase
        case fromDate            // ✅ camelCase
        case toDate              // ✅ camelCase
        case page
        case pageSize            // ✅ camelCase
    }
}

// MARK: - Transaction Model (matches web txnList items)
struct TransactionP: Identifiable, Codable {

    var id: Int { transactionId }

    let transactionId: Int
    let merchantId: Int?
    let customerId: Int?
    let customerEmail: String?
    let customerIdentity: String?

    let productDetails: [ProductDetail]?

    let paymentType: String?
    let currency: String?

    let baseAmount: Double?
    let feeAmount: Double?
    let discountAmount: Double?
    let paidAmount: Double?

    let status: String?
    let paymentMethod: String?
    let paymentSubDetails: String?

    let sessionId: String?
    let intentId: String?
    let paymentLinkId: String?

    let subscriptionId: String?
    let subscriptionStatus: String?

    let nextBillingDate: String?
    let cycle: String?

    let trialDays: Int?
    let isTrialAvailed: Int?

    let testMode: Int?          // ✅ FIXED
    let actionRequired: Int?    // ✅ FIXED

    let paymentCreatedAt: String?
    let paymentInitiatedAt: String?
    let paymentProcessAt: String?
    let txnDate: String?
}
//struct ProductDetail: Codable {
//    let productName: String?
//    let qty: Int?
//    let itemPrice: Double?
//    let currency: String?
//}

// MARK: - Response (matches web res.data structure)

struct TransactionsResponse: Codable {
    let transactions: [TransactionP]?
    let totalVolume: Double?
    let successVolume: Double?
    let failedVolume: Double?
    let refundedVolume: Double?
    let totalCount: Int?
    let succeededCount: Int?
    let failedCount: Int?
    let refundedCount: Int?
    let cancelledCount: Int?
    let totalPages: Int?
    let totalRecords: Int?
}

// MARK: - Mark as Test Request (matches web MarkAsTestTransaction payload)

struct MarkAsTestRequest: Encodable {
    let merchantId: Int
    let transactionId: String   // comma-separated IDs e.g. "123,456"
    let status: String          // "MARKED" or "UNMARKED"
}

// MARK: - Export Request

struct ExportTransactionsRequest: Encodable {
    let merchantId: Int
    let status: String
    let paymentMethod: String
    let network: String
    let currency: String
    let dateRange: String
    let fromDate: String
    let toDate: String
    let format: String          // "csv"
}

// MARK: - Generic Response

struct GenericResponse: Codable {
    let status: Bool?
    let message: String?
    let data: Bool?
}
//struct TransactionsResponse: Codable {
//    let transactions: [TransactionP]?
//    let totalVolume: Double?
//    let successVolume: Double?
//    let failedVolume: Double?
//    let refundedVolume: Double?
//    let totalCount: Int?
//    let succeededCount: Int?
//    let failedCount: Int?
//    let refundedCount: Int?
//    let cancelledCount: Int?
//    let totalPages: Int?
//    let totalRecords: Int?
//}
