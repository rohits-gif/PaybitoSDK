//
//  Createproductservice.swift
//  Trading_Terminal
//
//  Created by HashCash on 11/05/26.
//

import Foundation
import Alamofire

// MARK: - API Constants

private enum PCAPI {
    static let base     = "https://service.hashcashconsultants.com/billbitcoins-v2"
    static let pageSize = 10

    // ✅ Dynamic — reads from UserDefaults, same keys as rest of the project
    static var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
    }
}

// MARK: - Service Errors

enum PCServiceError: LocalizedError {
    case decodingFailed(String)
    case serverError(Int)
    case networkError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .decodingFailed(let msg):  return "Decoding failed: \(msg)"
        case .serverError(let code):    return "Server error \(code)."
        case .networkError(let msg):    return "Network error: \(msg)"
        case .unknown:                  return "An unknown error occurred."
        }
    }
}

// MARK: - PCProductService  (Alamofire 4.x style — matches project convention)

final class PCProductService {

    static let shared = PCProductService()
    private init() {}

    // MARK: Headers — [String: String] (Alamofire 4 style)

    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type":     "application/json",
            "Accept":           "application/json",
            "Origin":           "https://trade.paybito.com",
            "Referer":          "https://trade.paybito.com/",
            "X-Requested-With": "XMLHttpRequest"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
            debugPrint("🔑 [PCService] Token: \(token)")
        } else {
            debugPrint("❌ [PCService] Token missing")
        }

        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
            debugPrint("🆔 [PCService] UUID: \(uuid)")
        } else {
            debugPrint("❌ [PCService] UUID missing")
        }

        return h
    }

    // MARK: - Fetch Products

    func fetchProducts(
        page: Int = 1,
        size: Int = PCAPI.pageSize,
        status: String = "ALL",
        completion: @escaping (Swift.Result<PCProductData, Error>) -> Void
    ) {
        let url = "\(PCAPI.base)/shopping/products"

        let params: [String: Any] = [
            "merchantId": PCAPI.merchantId,
            "page":       page,
            "size":       size,
            "status":     status
        ]

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [PCService] fetchProducts")
        debugPrint("   URL        : \(url)")
        debugPrint("   Params     : \(params)")
        debugPrint("   merchantId : \(PCAPI.merchantId)")
        debugPrint("   Headers    : \(authHeaders)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                url,
                method:     .get,
                parameters: params,
                encoding:   URLEncoding.queryString,
                headers:    authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [PCService] HTTP \(response.response?.statusCode ?? -1)")

                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }

                switch response.result {

                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(PCAPIResponse.self, from: data)
                        debugPrint("✅ [PCService] Decoded — total: \(decoded.data?.total ?? 0), count: \(decoded.data?.products.count ?? 0)")
                        decoded.data?.products.enumerated().forEach { i, p in
                            debugPrint("   [\(i)] \(p.productId) | \(p.name) | \(p.displayCurrency) \(p.displayAmount) | active=\(p.isActive)")
                        }

                        if let productData = decoded.data {
                            DispatchQueue.main.async { completion(.success(productData)) }
                        } else {
                            debugPrint("⚠️ [PCService] data field is nil")
                            DispatchQueue.main.async { completion(.failure(PCServiceError.unknown)) }
                        }
                    } catch {
                        debugPrint("❌ [PCService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [PCService] Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - Delete Product

    func deleteProduct(
        productId: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    ) {
        let url = "\(PCAPI.base)/shopping/products?merchantId=\(PCAPI.merchantId)&productId=\(productId)"

        debugPrint("────────────────────────────────────────")
        debugPrint("🗑️ [PCService] deleteProduct")
        debugPrint("   URL       : \(url)")
        debugPrint("   ProductId : \(productId)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                url,
                method:  .delete,
                headers: authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [PCService] deleteProduct HTTP \(response.response?.statusCode ?? -1)")

                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw: \(raw.prefix(300))")
                }

                switch response.result {
                case .success:
                    debugPrint("✅ [PCService] Product deleted: \(productId)")
                    DispatchQueue.main.async { completion(.success(true)) }
                case .failure(let error):
                    debugPrint("❌ [PCService] Delete failed: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
