//
//  Editproductmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

//
//  EditProductModel.swift
//  Trading_Terminal
//

import Foundation

// MARK: - PUT Request

struct EditProductRequest: Encodable {
    let merchantId:  Int
    let name:        String
    let productType: String            // "PAYMENT_LINK"
    let description: String
    let imageUrl:    String
    let attributes:  [String: [String]]  // {} by default
    let metadata:    [String: String]  // {} by default
    let status:      String            // "ACTIVE" | "DRAFT"
    let addPrices:   [EditProductPriceRequest]
}

struct EditProductPriceRequest: Encodable {
    let priceId:       Int?
    let isDefault:     Bool
    let priceType:     String          // "one-time" | "subscription"
    let intervalType:  String?
    let intervalCount: Int?
    let trialDays:     Int
    let totalCycles:   String
    let retryAttempts: Int?
    let retryInterval: Int?
    let variant:       [String: String]
    let sku:           String
    let inventory:     EditProductInventory
    let currencies:    [EditProductCurrency]
}

struct EditProductInventory: Encodable {
    let track:    Bool
    let quantity: Int
}

struct EditProductCurrency: Encodable {
    let currency:  String
    let amount:    Double
    let isDefault: Bool
}

// MARK: - PUT Response

struct EditProductResponse: Decodable {
    let status:  Bool
    let message: String
    let data:    EditProductResponseData?
}

struct EditProductResponseData: Decodable {}

// MARK: - Convenience Init

extension EditProductPriceRequest {
    init(
        priceId:        Int?   = nil,
        isDefault:      Bool,
        priceType:      String,
        sku:            String,
        amount:         Double,
        currency:       String,
        trackInventory: Bool,
        quantity:       Int,
        variant:        [String: String] = [:]
    ) {
        self.priceId       = priceId
        self.isDefault     = isDefault
        self.priceType     = priceType
        self.intervalType  = nil
        self.intervalCount = nil
        self.trialDays     = 0
        self.totalCycles   = "0"
        self.retryAttempts = nil
        self.retryInterval = nil
        self.variant       = variant
        self.sku           = sku
        self.inventory     = EditProductInventory(track: trackInventory, quantity: quantity)
        self.currencies    = [EditProductCurrency(currency: currency, amount: amount, isDefault: true)]
    }
}













////  EditProductModel.swift
////  Trading_Terminal

//import Foundation
//
//// MARK: - Request
//
//struct EditProductRequest: Encodable {
//    let merchantId:  Int
//    let name:        String
//    let productType: String            // "PAYMENT_LINK"
//    let description: String
//    let imageUrl:    String
//    let attributes:  [String: String]  // {} by default
//    let metadata:    [String: String]  // {} by default
//    let status:      String            // "ACTIVE" | "DRAFT"
//    let addPrices:   [EditProductPriceRequest]
//}
//
//struct EditProductPriceRequest: Encodable {
//    let priceId:       Int?            // nil → new price; existing Int → update
//    let isDefault:     Bool
//    let priceType:     String          // "one-time" | "subscription"
//    let intervalType:  String?         // nil for one-time
//    let intervalCount: Int?            // nil for one-time
//    let trialDays:     Int             // 0
//    let totalCycles:   String          // "0"
//    let retryAttempts: Int?            // nil
//    let retryInterval: Int?            // nil
//    let variant:       [String: String]// {}
//    let sku:           String
//    let inventory:     EditProductInventory
//    let currencies:    [EditProductCurrency]
//}
//
//struct EditProductInventory: Encodable {
//    let track:    Bool
//    let quantity: Int
//}
//
//struct EditProductCurrency: Encodable {
//    let currency:  String   // "USD"
//    let amount:    Double
//    let isDefault: Bool
//}
//
//// MARK: - Response
//
//struct EditProductResponse: Decodable {
//    let status:  Bool
//    let message: String
//    let data:    EditProductResponseData?
//}
//
//// API returns `"data": null` on success — kept for forward-compat
//struct EditProductResponseData: Decodable {}
//
//// MARK: - Convenience inits
//
//extension EditProductPriceRequest {
//    /// Single-currency convenience init used by the ViewModel
//    init(
//        priceId:        Int?   = nil,
//        isDefault:      Bool,
//        priceType:      String,
//        sku:            String,
//        amount:         Double,
//        currency:       String,
//        trackInventory: Bool,
//        quantity:       Int
//    ) {
//        self.priceId       = priceId
//        self.isDefault     = isDefault
//        self.priceType     = priceType
//        self.intervalType  = nil
//        self.intervalCount = nil
//        self.trialDays     = 0
//        self.totalCycles   = "0"
//        self.retryAttempts = nil
//        self.retryInterval = nil
//        self.variant       = [:]
//        self.sku           = sku
//        self.inventory     = EditProductInventory(track: trackInventory, quantity: quantity)
//        self.currencies    = [EditProductCurrency(currency: currency, amount: amount, isDefault: true)]
//    }
//}
