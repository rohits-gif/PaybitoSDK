//
//  Createproductsmodel.swift
//  Trading_Terminal
//
//  Created by HashCash on 11/05/26.


import Foundation

// MARK: - API Response Models

struct PCAPIResponse: Codable {
    let status: Bool
    let data: PCProductData?
}

struct PCProductData: Codable {
    let total: Int
    let products: [PCAPIProduct]
}

struct PCAPIProduct: Codable, Identifiable {
    var id: String { productId }
    let productId: String
    let productType: String
    let catalogId: Int
    let name: String
    let description: String?
    let imageUrl: String? 
    //let attributes: [String: String]
    
    let attributes: [String: [String]]
    let metadata: PCMetadata
    let status: String
    let createdAt: String
    let updatedAt: String
    let prices: [PCPrice]

    // MARK: Computed helpers

    var isActive: Bool { status.uppercased() == "ACTIVE" }

    var defaultPrice: PCPrice? {
        prices.first(where: { $0.default }) ?? prices.first
    }

    var displayCurrency: String {
        defaultPrice?.defaultCurrency?.currency ?? "—"
    }

    var displayAmount: Double {
        defaultPrice?.defaultCurrency?.amount ?? 0
    }

    var displayBillingType: String {
        guard let price = defaultPrice else { return "—" }
        if price.priceType == "one-time" {
            return "One-time"
        } else if price.priceType == "recurring" {
            let interval = price.intervalType ?? "Month"
            return "\(interval) subscription"
        }
        return price.priceType
    }

    var isTracked: Bool {
        defaultPrice?.metadata.inventory.track ?? false
    }

    var skuCode: String? {
        let sku = defaultPrice?.metadata.sku ?? ""
        return sku.isEmpty ? nil : sku
    }
}



struct PCMetadata: Codable {
    let values: [String: String]

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        values = (try? container.decode([String: String].self)) ?? [:]
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(values)
    }



    enum CodingKeys: String, CodingKey {
        case type
    }
}

struct PCPrice: Codable {
    let priceId: Int
    let priceType: String
    let intervalType: String?
    let intervalCount: Int
    let trialDays: Int
    let trialEnabled: Int
    let retryAttempts: Int
    let totalCycles: Int
    let metadata: PCPriceMetadata
    let currencies: [PCCurrency]
    let `default`: Bool

    var defaultCurrency: PCCurrency? {
        currencies.first(where: { $0.default }) ?? currencies.first
    }
}

struct PCPriceMetadata: Codable {
    let sku: String
    let inventory: PCInventory
}

struct PCInventory: Codable {
    let track: Bool
    let quantity: Int
}

struct PCCurrency: Codable {
    let currency: String
    let amount: Double
    let `default`: Bool
}
