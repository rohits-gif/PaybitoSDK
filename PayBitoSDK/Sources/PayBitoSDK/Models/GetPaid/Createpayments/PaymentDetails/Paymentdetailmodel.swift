//
//  Paymentdetailmodel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/05/26.
//

////
////  ViewPaymentDetailModel.swift
////  Trading_Terminal
////
////  Matches: GET /billbitcoins-v2/payment/profileDetailsByld?id=PCN2942&merchantId=21758
////
///

import Foundation

// MARK: - Root Response

struct ViewPaymentDetailResponse: Codable {
    let message:                String?
    var error:                  Int?
    var returnId:               Int?
    var merchantId:             Int?
    var brokerId:               String?
    var isProcessingFeeApplied: Int?
    var products:               [VPDProduct]?
    var billingProfiles:        [VPDBillingProfile]?
    var buyersProfiles:         [VPDBuyersProfile]?
    var shippingProfiles:       [VPDShippingProfile]?
    var discounts:              [VPDDiscount]?
    var redirectUrlProfile:     [VPDRedirectProfile]?

    enum CodingKeys: String, CodingKey {
        case message, error, returnId, merchantId, brokerId, isProcessingFeeApplied
        case products, billingProfiles, buyersProfiles, shippingProfiles, discounts, redirectUrlProfile
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        
        func decodeSafeInt(forKey key: CodingKeys) -> Int? {
            if let i = try? container.decodeIfPresent(Int.self, forKey: key) { return i }
            if let s = try? container.decodeIfPresent(String.self, forKey: key), let i = Int(s) { return i }
            return nil
        }
        
        self.error = decodeSafeInt(forKey: .error)
        self.returnId = decodeSafeInt(forKey: .returnId)
        self.merchantId = decodeSafeInt(forKey: .merchantId)
        self.isProcessingFeeApplied = decodeSafeInt(forKey: .isProcessingFeeApplied)
        self.brokerId = try? container.decodeIfPresent(String.self, forKey: .brokerId)

        self.products = (try? container.decodeIfPresent([VPDProduct].self, forKey: .products)) ?? []
        self.billingProfiles = (try? container.decodeIfPresent([VPDBillingProfile].self, forKey: .billingProfiles)) ?? []
        self.buyersProfiles = (try? container.decodeIfPresent([VPDBuyersProfile].self, forKey: .buyersProfiles)) ?? []
        self.shippingProfiles = (try? container.decodeIfPresent([VPDShippingProfile].self, forKey: .shippingProfiles)) ?? []
        self.discounts = (try? container.decodeIfPresent([VPDDiscount].self, forKey: .discounts)) ?? []
        self.redirectUrlProfile = (try? container.decodeIfPresent([VPDRedirectProfile].self, forKey: .redirectUrlProfile)) ?? []
    }
}

// MARK: - Product

struct VPDProduct: Codable {
    let productId:   String?
    let productType: String?
    let itemQuantity: Int?
    let catalogId:   Int?
    let name:        String?
    let status:      String?
    let prices:      [VPDPrice]?
    // attributes/metadata are open dicts — skip decoding, not used in UI
    enum CodingKeys: String, CodingKey {
        case productId, productType, itemQuantity, catalogId, name, status, prices
    }
}

struct VPDPrice: Codable {
    let priceId:       Int?
    let priceType:     String?         // "recurring" | "one_time"
    let intervalType:  String?         // "Month" | "Year" etc.
    let intervalCount: Int?
    let trialDays:     Int?
    let trialEnabled:  Int?
    let currencies:    [VPDPriceCurrency]?
    let `default`:     Bool?

    enum CodingKeys: String, CodingKey {
        case priceId, priceType, intervalType, intervalCount
        case trialDays, trialEnabled, currencies
        case `default` = "default"
    }
}

struct VPDPriceCurrency: Codable {
    let currency: String?   // "USD"
    let amount:   Double?
    let `default`: Bool?

    enum CodingKeys: String, CodingKey {
        case currency, amount
        case `default` = "default"
    }
}

// MARK: - Billing Profile
// Note: JSON has no top-level "displayOrder" on billingProfiles in latest response

struct VPDBillingProfile: Codable {
    let id:                 Int?
    let billingType:        String?        // "recurring"
    let profileName:        String?
    let currencies:         [VPDBillingCurrency]?
    let billingMethod:      [VPDBillingMethod]?
    let isBuyCryptoEnabled: Int?
}

struct VPDBillingCurrency: Codable {
    let currencyId: Int?
    let currency:   String?
}

struct VPDBillingMethod: Codable {
    let pmId:         Int?
    let methodName:   String?
    let displayOrder: Int?    // optional — present in latest JSON
}

// MARK: - Buyers Profile

struct VPDBuyersProfile: Codable {
    let id:                        Int?
    let merchantId:                Int?
    let profileName:               String?
    let collectEmail:              Int?
    let collectFullName:           Int?
    let collectAddress:            Int?
    let collectPhoneNumber:        Int?
    let collectCompanyName:        Int?
    let collectTaxInfo:            Int?
    let collectCryptoRefundAddress: Int?
    let collectOrderNotes:         Int?
    let isDefaultProfile:          Int?
    let createdAt:                 String?
    // customFields is [] in all responses, skipped
    enum CodingKeys: String, CodingKey {
        case id, merchantId, profileName
        case collectEmail, collectFullName, collectAddress
        case collectPhoneNumber, collectCompanyName, collectTaxInfo
        case collectCryptoRefundAddress, collectOrderNotes
        case isDefaultProfile, createdAt
    }
}

// MARK: - Shipping / Discount (empty arrays in current API)

struct VPDShippingProfile: Codable {
    let profileName: String?
    let handlingFeeValue: Double?
    let taxRate: Double?
}

struct VPDDiscount: Codable {
    let profileName: String?
    let discountPercentage: Double?
    let minimumCartValue: Double?
}

// MARK: - Redirect Profile

struct VPDRedirectProfile: Codable {
    let id:             Int?
    let templateName:   String?
    let successUrl:     String?
    let successMode:    String?
    let failureUrl:     String?
    let failureMode:    String?
    let isDefault:      Int?
    let createdAt:      String?
    let updatedAt:      String?
    let advanceOptions: [VPDAdvanceOption]?
}

struct VPDAdvanceOption: Codable {
    let paramKey:  String?
    let isEnabled: Int?
}

// MARK: - Computed Helpers

extension ViewPaymentDetailResponse {
    var primaryProduct:      VPDProduct?        { products?.first }
    var defaultBilling:      VPDBillingProfile? { billingProfiles?.first }
    var defaultBuyer:        VPDBuyersProfile?  { buyersProfiles?.first }
    var defaultRedirect:     VPDRedirectProfile? {
        redirectUrlProfile?.first(where: { $0.isDefault == 1 }) ?? redirectUrlProfile?.first
    }
    var feeHandlingText: String { isProcessingFeeApplied == 1 ? "Customer Pays" : "Merchant Pays" }
}

extension VPDProduct {
    var activePrice: VPDPrice? {
        prices?.first(where: { $0.default == true }) ?? prices?.first
    }
    var primaryCurrency: VPDPriceCurrency? {
        activePrice?.currencies?.first(where: { $0.default == true }) ?? activePrice?.currencies?.first
    }
    var isSubscription: Bool { activePrice?.priceType == "recurring" }
    var intervalLabel:  String? {
        guard isSubscription,
              let type  = activePrice?.intervalType,
              let count = activePrice?.intervalCount else { return nil }
        return "Every \(count) \(type)"
    }
    var formattedAmount: String {
        guard let c = primaryCurrency, let amt = c.amount, let curr = c.currency else { return "—" }
        let val = amt.truncatingRemainder(dividingBy: 1) == 0
            ? "\(Int(amt))"
            : String(format: "%.2f", amt)
        return "\(curr) \(val)"
    }
}

extension VPDBuyersProfile {
    var collectedFields: [String] {
        var f: [String] = []
        if collectEmail              == 1 { f.append("Email") }
        if collectFullName           == 1 { f.append("Full Name") }
        if collectAddress            == 1 { f.append("Address") }
        if collectPhoneNumber        == 1 { f.append("Phone Number") }
        if collectCompanyName        == 1 { f.append("Company Name") }
        if collectTaxInfo            == 1 { f.append("Tax Info") }
        if collectCryptoRefundAddress == 1 { f.append("Crypto Refund Address") }
        if collectOrderNotes         == 1 { f.append("Order Notes") }
        return f
    }
}
