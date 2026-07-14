//
//  ShippingService.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 19/05/26.
//

//  ShippingService.swift

import Foundation
import Alamofire

final class ShippingService {

    static let shared = ShippingService()
    private init() {}

    private let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // MARK: - Auth Headers (copied verbatim from LimitsAPIService)
    private func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        print("🔑 [ShippingService] token prefix: \(String(token.prefix(20)))... uuid: \(uuid)")
        return [
            "Authorization": "bearer \(token)",
            "UUID":          uuid,
            "Content-Type":  "application/json",
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/",
            "User-Agent":    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        ]
    }

    // MARK: - Extract merchantId (copied verbatim from LimitsAPIService)
    private func extractMerchantId() -> Int {
        if let mid = UserDefaults.standard.value(forKey: "merchantId")  as? Int { return mid }
        if let mid = UserDefaults.standard.value(forKey: "BMerchantId") as? Int { return mid }
        if let mid = Int(UserDefaults.standard.string(forKey: "merchantId")  ?? "") { return mid }
        if let mid = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") { return mid }

        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")
        if parts.count >= 2,
           let data = Data(base64Encoded: parts[1].paddedBase64),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sub  = json["sub"] as? String,
           let idStr = sub.components(separatedBy: "-").first,
           let id = Int(idStr) {
            return id
        }
        print("⚠️ [ShippingService] Could not extract merchantId, using 0")
        return 0
    }

    // MARK: - Fetch All
    // GET /api/merchants/{merchantId}/shipping-profiles
    func fetchAll(
        completion: @escaping (Swift.Result<Shipping.FetchAllResponse, Error>) -> Void
    ) {
        let mid = extractMerchantId()
        let url = "\(base)/api/merchants/\(mid)/shipping-profiles"
        print("📡 [ShippingService] fetchAll → \(url)")

        Alamofire.request(url,
                          method: .get,
                          headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [ShippingService] fetchAll status: \(response.response?.statusCode ?? -1)")
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 fetchAll: \(raw.prefix(500))")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Create
    // POST /api/merchants/{merchantId}/shipping-profiles
    func create(
        payload: Shipping.CreatePayload,
        completion: @escaping (Swift.Result<Shipping.MutateResponse, Error>) -> Void
    ) {
        let mid = extractMerchantId()
        let url = "\(base)/api/merchants/\(mid)/shipping-profiles"
        let params: [String: Any] = [
            "name":              payload.name,
            "shippingHandling":  payload.shippingHandling,
            "taxRate":           payload.taxRate,
            "isDefaultProfile":  payload.isDefaultProfile
        ]
        print("📡 [ShippingService] create → \(url)")
        print("📦 [ShippingService] create payload: \(params)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [ShippingService] create status: \(response.response?.statusCode ?? -1)")
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 create: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Update
    // POST /api/merchants/{merchantId}/shipping-profiles/update/{id}
    func update(
        payload: Shipping.UpdatePayload,
        completion: @escaping (Swift.Result<Shipping.MutateResponse, Error>) -> Void
    ) {
        let mid = extractMerchantId()
        let url = "\(base)/api/merchants/\(mid)/shipping-profiles/update/\(payload.id)"
        let params: [String: Any] = [
            "name":              payload.name,
            "shippingHandling":  payload.shippingHandling,
            "taxRate":           payload.taxRate,
            "isDefaultProfile":  payload.isDefaultProfile
        ]
        print("📡 [ShippingService] update → \(url)")
        print("📦 [ShippingService] update payload: \(params)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [ShippingService] update status: \(response.response?.statusCode ?? -1)")
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 update: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Delete
    // POST /api/merchants/{merchantId}/shipping-profiles/remove/{id}
    func delete(
        id: Int,
        completion: @escaping (Swift.Result<Shipping.DeleteResponse, Error>) -> Void
    ) {
        let mid = extractMerchantId()
        let url = "\(base)/api/merchants/\(mid)/shipping-profiles/remove/\(id)"
        print("📡 [ShippingService] delete → \(url)")

        Alamofire.request(url,
                          method: .post,
                          headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [ShippingService] delete status: \(response.response?.statusCode ?? -1)")
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 delete: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Generic decoder (mirrors LimitsAPIService pattern)
    private func decode<T: Decodable>(
        _ response: DataResponse<Data>,
        completion: @escaping (Swift.Result<T, Error>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            do {
                // Try array [{...}] first, then single object {...}
                if let list = try? JSONDecoder().decode([T].self, from: data),
                   let first = list.first {
                    print("✅ [ShippingService] decoded as array<\(T.self)>")
                    completion(.success(first))
                    return
                }
                let single = try JSONDecoder().decode(T.self, from: data)
                print("✅ [ShippingService] decoded as single<\(T.self)>")
                completion(.success(single))
            } catch {
                print("❌ [ShippingService] decode error \(T.self): \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("❌ [ShippingService] raw: \(raw)")
                }
                completion(.failure(error))
            }
        case .failure(let error):
            if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                print("❌ [ShippingService] failure body: \(raw)")
            }
            print("❌ [ShippingService] network error: \(error)")
            completion(.failure(error))
        }
    }
}

// MARK: - Base64 padding
private extension String {
    var paddedBase64: String {
        var s = self
        let r = s.count % 4
        if r != 0 { s += String(repeating: "=", count: 4 - r) }
        return s
    }
}
