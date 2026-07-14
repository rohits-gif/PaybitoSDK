//
//  ShippingModel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 19/05/26.
//

//  ShippingModel.swift

import Foundation

enum Shipping {

    // MARK: - UI Model
    struct Profile: Identifiable {
        let id: Int
        var name: String
        var shippingHandling: String   // e.g. "2.50"
        var taxRate: String            // e.g. "8.00"
        var isDefault: Bool
        var isActive: Bool
        var createdAt: String?
    }

    // MARK: - API Response Models
    struct ProfileRecord: Decodable {
        let id: Int
        let profileName: String
        let handlingFeeValue: Double?
        let taxRate: Double?
        let isDefaultProfile: Int?
        let isActive: Int?
        let createdAt: String?
    }

    struct FetchAllResponse: Decodable {
        let error: Int
        let message: String?
        let data: [ProfileRecord]?
    }

    struct MutateResponse: Decodable {
        let error: String
        let message: String?
        let data: ProfileRecord?
    }

    struct DeleteResponse: Decodable {
        let error: Int
        let message: String?
    }

    // MARK: - Payloads (used internally by service)
    struct CreatePayload {
        let name: String
        let shippingHandling: Double
        let taxRate: Double
        let isDefaultProfile: Int
    }

    struct UpdatePayload {
        let id: Int
        let name: String
        let shippingHandling: Double
        let taxRate: Double
        let isDefaultProfile: Int
    }
}
