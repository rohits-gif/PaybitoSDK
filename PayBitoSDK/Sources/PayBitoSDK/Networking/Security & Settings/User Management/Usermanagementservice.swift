// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  UserManagementService.swift
//  Trading_Terminal
//

import Foundation
import Alamofire

// MARK: - API Constants

private enum UMAPI {
    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant"
    static let subMerchantList = "\(base)/getSubMerchantList"

    static var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
    }
}

// MARK: - Service Protocol

protocol UserManagementServiceProtocol {
    func fetchSubMerchantList(
        merchantId: String,
        completion: @escaping (Swift.Result<SubMerchantListResponse, Error>) -> Void
    )
}

// MARK: - Service Implementation

final class UserManagementService: UserManagementServiceProtocol {

    static let shared = UserManagementService()
    private init() {}

    // MARK: - Auth Headers  ([String: String] — Alamofire 4.x style)

    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Accept":       "application/json",
            "Origin":       "https://trade.paybito.com",
            "Referer":      "https://trade.paybito.com/"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["authorization"] = "Bearer \(token)"
            debugPrint("🔑 [UMService] Token: \(token)")
        } else {
            debugPrint("❌ [UMService] Token missing")
        }

        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["uuid"] = uuid
            debugPrint("🆔 [UMService] UUID: \(uuid)")
        } else {
            debugPrint("❌ [UMService] UUID missing")
        }

        return h
    }

    // MARK: - Fetch Sub-Merchant List

    func fetchSubMerchantList(
        merchantId: String,
        completion: @escaping (Swift.Result<SubMerchantListResponse, Error>) -> Void
    ) {
        let params: [String: Any] = ["merchant_id": merchantId]

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [UMService] fetchSubMerchantList")
        debugPrint("   URL        : \(UMAPI.subMerchantList)")
        debugPrint("   Params     : \(params)")
        debugPrint("   merchantId : \(merchantId)")
        debugPrint("   Headers    : \(authHeaders)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                UMAPI.subMerchantList,
                method:     .post,
                parameters: params,
                encoding:   JSONEncoding.default,
                headers:    authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [UMService] HTTP \(response.response?.statusCode ?? -1)")

                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }

                switch response.result {

                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(SubMerchantListResponse.self, from: data)
                        debugPrint("✅ [UMService] Decoded — error=\(decoded.error), count=\(decoded.list.count)")
                        decoded.list.enumerated().forEach { idx, m in
                            debugPrint("   [\(idx)] \(m.fullName) | \(m.email) | \(m.phone) | status=\(m.accountStatusDisplay)")
                        }
                        DispatchQueue.main.async { completion(.success(decoded)) }

                    } catch {
                        debugPrint("❌ [UMService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [UMService] Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
