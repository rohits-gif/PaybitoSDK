//
//  DashboardModels.swift
//

import Foundation

// MARK: - Dashboard Payment History Response

struct DashboardPaymentHistoryResponse: Codable {
    let returnId: Int?
    let message: String?
    let status: String?
    let volumeDetails: [MetricDetail]?
    let paymentDetails: [MetricDetail]?
    let balanceDetails: [MetricDetail]?
}

struct MetricDetail: Codable {
    let labelText: String?
    let value: Double?
    let subTextValue: Double?
}

// MARK: - Merchant Status Response

struct MerchantStatResponse: Codable {
    let error: String?
    let error_msg: String?
    let basic_verification_submitted: String?
    let crypto_address_added: String?
    let remaining_withdrawable_amt: String?
    let bank_account_added: String?
    let basic_verification_completed: String?
    
    enum CodingKeys: String, CodingKey {
        case error, error_msg, basic_verification_submitted, crypto_address_added, remaining_withdrawable_amt, bank_account_added, basic_verification_completed
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        error = try? container.decodeIfPresent(String.self, forKey: .error)
        error_msg = try? container.decodeIfPresent(String.self, forKey: .error_msg)
        
        if let val = try? container.decodeIfPresent(Int.self, forKey: .basic_verification_submitted) { basic_verification_submitted = String(val) }
        else { basic_verification_submitted = try? container.decodeIfPresent(String.self, forKey: .basic_verification_submitted) }
        
        if let val = try? container.decodeIfPresent(Int.self, forKey: .crypto_address_added) { crypto_address_added = String(val) }
        else { crypto_address_added = try? container.decodeIfPresent(String.self, forKey: .crypto_address_added) }
        
        if let val = try? container.decodeIfPresent(Double.self, forKey: .remaining_withdrawable_amt) { remaining_withdrawable_amt = String(val) }
        else if let val = try? container.decodeIfPresent(Int.self, forKey: .remaining_withdrawable_amt) { remaining_withdrawable_amt = String(val) }
        else { remaining_withdrawable_amt = try? container.decodeIfPresent(String.self, forKey: .remaining_withdrawable_amt) }
        
        if let val = try? container.decodeIfPresent(Int.self, forKey: .bank_account_added) { bank_account_added = String(val) }
        else { bank_account_added = try? container.decodeIfPresent(String.self, forKey: .bank_account_added) }
        
        if let val = try? container.decodeIfPresent(Int.self, forKey: .basic_verification_completed) { basic_verification_completed = String(val) }
        else { basic_verification_completed = try? container.decodeIfPresent(String.self, forKey: .basic_verification_completed) }
    }
}

// MARK: - User Details Response

struct UserDetailsResponse: Codable {
    let userTierType: Int?
    let bankDetailsStatus: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let phone: String?
    let country: String?
    let status: Int?
    let uuid: String?
    let userId: Int?
}

// MARK: - Transaction Filter Request

struct TransactionFilter: Codable {
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

    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "Encode", code: -1)
        }
        return dict
    }
}

// MARK: - Transaction Response

struct TransactionResponse: Codable {
    let transactions: [PaymentTransaction]?
    let totalCount: Int?
    let succeededCount: Int?
    let failedCount: Int?
    let refundedCount: Int?
}

// MARK: - PaymentTransaction
// Single model used for both the list and detail screen.
// All fields come directly from the /api/transactions/byFilter JSON response.

struct PaymentTransaction: Codable, Identifiable {
    var id: Int { transactionId ?? 0 }

    // Identifiers
    let transactionId: Int?
    let sessionId: String?
    let intentId: String?
    let customerId: Int?
    let customerName: String?
    let customerEmail: String?
    let customerIdentityId: String?
    let customerIdentity: String?
    let paymentLinkId: String?          // ✅ "PCN2208"
    let paymentType: String?            // ✅ "ONE-TIME" / "RECURRING"
    let catalogueName: String?

    // Amounts
    let discountAmount: Double?
    let feeAmount: Double?
    let baseAmount: Double?
    let paidAmount: Double?
    let amount: Double?
    let currency: String?               // ✅ top-level "XRP", "USD", "HCX" …

    // Payment method
    let paymentMethod: String?          // ✅ "Stripe", "Guest Checkout" …
    let paymentSubDetails: String?      // ✅ "Card", "Crypto", "NATIVE" …
    let paymentId: String?
    let subscriptionId: String?
    let network: String?                // ✅ "NATIVE", "ERC", null …
    let cycle: String?
    let nextBillingDate: String?

    // Status
    let status: String?
    let subscriptionStatus: String?
    let refundId: String?
    let refundStatus: String?

    // Dates
    let paymentCreatedAt: String?       // ✅ "2026-05-27 10:00:38"
    let paymentProcessAt: String?       // ✅ null until processed
    let paymentInitiatedAt: String?
    let createdAt: String?              // kept for fallback compatibility

    // Flags
    let testMode: Int?                  // 0 or 1
    let actionRequired: Int?            // 0 or 1
    let trialDays: Int?

    // Products
    let productDetails: [ProductDetail]?

    // Computed helpers
    var isTestMode: Bool        { testMode == 1 }
    var isActionRequired: Bool  { actionRequired == 1 }
}

// MARK: - ProductDetail

struct ProductDetail: Codable {
    let productId: Int?
    let productName: String?
    let priceId: Int?
    let currency: String?               // product-level currency e.g. "USD"
    let qty: Int?
    let itemPrice: Double?
}

// MARK: - Crypto Balance Response

struct CryptoBalanceResponse: Codable {
    let error: String?
    let coin_balance: [CoinBalance]?
}

struct CoinBalance: Codable {
    let currency_code: String?
    let currency_name: String?
    let balance: String?
    let logo: String?
    let network: String?
    let currency_id: String?
    let is_broker_currency: Bool?
}

// MARK: - UI State Enums

enum AccountStatus: String {
    case active   = "Active"
    case inactive = "Not Active"
    var isActive: Bool { self == .active }
}

enum BankDetailsStatus: String {
    case notSubmitted = "NOT_SUBMITTED"
    case submitted    = "SUBMITTED"
    case completed    = "COMPLETED"
    case rejected     = "REJECTED"

    var displayText: String {
        switch self {
        case .notSubmitted: return "Fill Bank Info"
        case .submitted:    return "Submitted"
        case .completed:    return "Completed"
        case .rejected:     return "Rejected"
        }
    }
}
