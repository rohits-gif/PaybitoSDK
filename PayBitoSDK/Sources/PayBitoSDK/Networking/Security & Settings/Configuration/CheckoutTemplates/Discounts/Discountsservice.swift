//
//  Discountsservice.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 22/05/26.
//
//
//  DiscountsService.swift
//  PaymentsTerminal
//
//  Created by Sk Jasimuddin on 22/05/26.
//

import Foundation
import SwiftUI

// MARK: - Models

struct DiscountRecord: Codable, Identifiable {
    let id: Int
    let merchantId: Int
    let minimumCartValue: Double
    let discountPercentage: Double
    let profileName: String
    let isDefaultProfile: Int
    let status: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case merchantId
        case minimumCartValue
        case discountPercentage
        case profileName
        case isDefaultProfile
        case status
        case createdAt
    }

    init(
        id: Int,
        merchantId: Int,
        minimumCartValue: Double,
        discountPercentage: Double,
        profileName: String,
        isDefaultProfile: Int,
        status: String?,
        createdAt: String?
    ) {
        self.id = id
        self.merchantId = merchantId
        self.minimumCartValue = minimumCartValue
        self.discountPercentage = discountPercentage
        self.profileName = profileName
        self.isDefaultProfile = isDefaultProfile
        self.status = status
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        merchantId = try container.decode(Int.self, forKey: .merchantId)
        profileName = try container.decode(String.self, forKey: .profileName)
        isDefaultProfile = try container.decode(Int.self, forKey: .isDefaultProfile)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)

        minimumCartValue = Self.decodeFlexibleDouble(
            from: container,
            forKey: .minimumCartValue
        )

        discountPercentage = Self.decodeFlexibleDouble(
            from: container,
            forKey: .discountPercentage
        )
    }

    private static func decodeFlexibleDouble(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> Double {
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }

        if let value = try? container.decode(Int.self, forKey: key) {
            return Double(value)
        }

        if let value = try? container.decode(String.self, forKey: key),
           let doubleValue = Double(value) {
            return doubleValue
        }

        return 0
    }
}

struct DiscountAPIResponse: Codable {
    let status: Bool
    let message: String?
    let data: [DiscountRecord]?
}

struct DiscountProfile: Identifiable {
    let id: String
    var name: String
    var isDefaultProfile: Int
    var rules: [UIDiscountRule]
}

struct UIDiscountRule: Identifiable {
    let id = UUID()
    var apiId: Int?
    var cartThreshold: String
    var discountValue: String
}

// MARK: - Batch Payload

struct BatchPayload: Encodable {
    let merchantId: Int
    let profileName: String
    let updates: [UpdateRule]
    let newDiscounts: [NewRule]
    let isDefaultProfile: Int

    struct UpdateRule: Encodable {
        let id: Int
        let minimumCartValue: Double
        let discountPercentage: Double
    }

    struct NewRule: Encodable {
        let minimumCartValue: Double
        let discountPercentage: Double
    }
}

struct BatchResponse: Codable {
    let status: Bool
    let message: String?
    let data: [DiscountRecord]?
}

struct DeleteResponse: Codable {
    let status: Bool
    let message: String?
}

// MARK: - Helpers

func groupIntoProfiles(_ records: [DiscountRecord]) -> [DiscountProfile] {
    var map: [String: DiscountProfile] = [:]

    for rec in records {
        let key = rec.profileName

        let rule = UIDiscountRule(
            apiId: rec.id,
            cartThreshold: String(format: "%.0f", rec.minimumCartValue),
            discountValue: String(format: "%.0f", rec.discountPercentage)
        )

        if var existing = map[key] {
            existing.rules.append(rule)

            if rec.isDefaultProfile == 1 {
                existing.isDefaultProfile = 1
            }

            map[key] = existing
        } else {
            map[key] = DiscountProfile(
                id: key,
                name: rec.profileName,
                isDefaultProfile: rec.isDefaultProfile,
                rules: [rule]
            )
        }
    }

    return Array(map.values)
}

// MARK: - API Service

final class DiscountsService {
    static let shared = DiscountsService()
    private init() {}

    private let base = "https://service.hashcashconsultants.com/billbitcoins-v2/shopping"

    private func headers() -> [String: String] {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid = UserDefaults.standard.string(forKey: "Buuid") ?? ""

        return [
            "Authorization": "bearer \(token)",
            "UUID": uuid,
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Origin": "https://trade.paybito.com"
        ]
    }

    // MARK: Fetch All

    func fetchAll(merchantId: Int) async throws -> [DiscountProfile] {
        guard let url = URL(string: "\(base)/discounts?merchantId=\(merchantId)") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        headers().forEach {
            req.setValue($1, forHTTPHeaderField: $0)
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        print("STATUS CODE:", http.statusCode)

        guard http.statusCode == 200 else {
            print(String(data: data, encoding: .utf8) ?? "No response")
            throw URLError(.badServerResponse)
        }

        do {
            let decoded = try JSONDecoder().decode(DiscountAPIResponse.self, from: data)
            return groupIntoProfiles(decoded.data ?? [])
        } catch {
            print("RAW RESPONSE:")
            print(String(data: data, encoding: .utf8) ?? "No response")
            print("DECODING ERROR:", error)
            throw error
        }
    }

    // MARK: Batch Save

    func batch(payload: BatchPayload) async throws -> [DiscountRecord] {
        guard let url = URL(string: "\(base)/discounts/batch") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"

        headers().forEach {
            req.setValue($1, forHTTPHeaderField: $0)
        }

        req.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard http.statusCode == 200 else {
            print(String(data: data, encoding: .utf8) ?? "No response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(BatchResponse.self, from: data)

        guard decoded.status else {
            throw NSError(
                domain: "API",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        decoded.message ?? "Save failed"
                ]
            )
        }

        return decoded.data ?? []
    }

    // MARK: Delete Rule

    func deleteRule(merchantId: Int, ruleId: Int) async throws {
        guard let url = URL(string: "\(base)/discounts/\(merchantId)/\(ruleId)") else {
            throw URLError(.badURL)
        }

        var req = URLRequest(url: url)
        req.httpMethod = "DELETE"

        headers().forEach {
            req.setValue($1, forHTTPHeaderField: $0)
        }

        let (data, response) = try await URLSession.shared.data(for: req)

        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard http.statusCode == 200 else {
            print(String(data: data, encoding: .utf8) ?? "No response")
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(DeleteResponse.self, from: data)

        guard decoded.status else {
            throw NSError(
                domain: "API",
                code: 0,
                userInfo: [
                    NSLocalizedDescriptionKey:
                        decoded.message ?? "Delete failed"
                ]
            )
        }
    }
}
