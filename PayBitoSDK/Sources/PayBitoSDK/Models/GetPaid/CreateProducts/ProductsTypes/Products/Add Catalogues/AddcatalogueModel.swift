//
//  AddcatalogueModel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

//
//  AddCatalogueModel.swift
//  Trading_Terminal
//
//  Request/response models for the Add Catalogue APIs.
//

import Foundation

// ─────────────────────────────────────────────
// MARK: - Create Catalogue Request
// ─────────────────────────────────────────────

/// POST /shopping/catalogs
/// Body: { merchantId, catalogName, description }
struct CreateCatalogueRequest: Encodable {
    let merchantId:  Int
    let catalogName: String
    let description: String
}

// ─────────────────────────────────────────────
// MARK: - Create Catalogue Response
// ─────────────────────────────────────────────

/// { "status": true, "message": "...", "data": { ... } }
struct CreateCatalogueResponse: Decodable {
    let status:  Bool
    let message: String
    let data:    CreateCatalogueData
}

struct CreateCatalogueData: Decodable {
    let id:          Int
    let merchantId:  Int
    let catalogName: String
    let description: String
    let createdAt:   String
}

// ─────────────────────────────────────────────
// MARK: - Add Product to New Catalogue Response
// ─────────────────────────────────────────────

/// POST /shopping/catalogs/add-product-price
/// Response: { "success": bool, "returnId": int, "message": string }
struct AddProductToNewCatalogueResponse: Decodable {
    let success:  Bool
    let returnId: Int
    let message:  String
}

// ─────────────────────────────────────────────
// MARK: - Product List (reused from service)
// ─────────────────────────────────────────────

struct ACVProductList: Decodable {
    let status: Bool
    let data:   ACVProductListData
}

struct ACVProductListData: Decodable {
    let total:    Int
    let products: [ACVAPIProduct]
}

struct ACVAPIProduct: Decodable, Identifiable {
    let productId: String
    let name:      String
    let status:    String
    let prices:    [ACVAPIPrice]

    var id: String { productId }

    var oneTimePrices: [ACVAPIPrice] {
        prices.filter { $0.priceType == "one-time" }
    }
}

struct ACVAPIPrice: Decodable, Identifiable {
    let priceId:    Int
    let priceType:  String
    let currencies: [ACVAPICurrency]

    var id: Int { priceId }

    var displayLabel: String {
        let amounts = currencies
            .map { "\($0.currency) \(String(format: "%.2f", $0.amount))" }
            .joined(separator: " / ")
        return "Price #\(priceId)  ·  \(amounts)"
    }

    var currencyCodes: [String] {
        currencies.map { $0.currency }
    }
}

struct ACVAPICurrency: Decodable {
    let currency: String
    let amount:   Double
    let `default`: Bool
}
