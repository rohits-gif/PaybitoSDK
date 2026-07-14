// MARK: - RedirectService.swift
// Alamofire 4 — follows BuyerInfoService pattern exactly:
// same base URL, same authHeaders(), same extractMerchantId(), same responseData pattern.

import Foundation
import Alamofire

// MARK: - Error
enum RedirectError: Error {
    case serverError(String)
    case unknown

    var localizedDescription: String {
        switch self {
        case .serverError(let msg): return msg
        case .unknown:              return "An unknown error occurred"
        }
    }
}

// MARK: - RedirectService
final class RedirectService {

    static let shared = RedirectService()
    private init() {}

    private let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // MARK: AUTH HEADERS — mirrors BuyerInfoService.authHeaders() exactly
    private func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""

        print("========== REDIRECT AUTH ==========")
        print("TOKEN PREFIX: \(String(token.prefix(30)))")
        print("UUID: \(uuid)")
        print("===================================")

        return [
            "Authorization": "bearer \(token)",
            "UUID":          uuid,
            "Content-Type":  "application/json",
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/",
            "User-Agent":    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15"
        ]
    }

    // MARK: MERCHANT ID — mirrors BuyerInfoService.extractMerchantId() exactly
    private func extractMerchantId() -> Int {
        if let mid = UserDefaults.standard.value(forKey: "merchantId") as? Int {
            return mid
        }
        if let mid = UserDefaults.standard.value(forKey: "BMerchantId") as? Int {
            return mid
        }
        if let mid = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") {
            return mid
        }
        if let mid = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") {
            return mid
        }

        // JWT fallback — decode sub claim from token
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")
        if parts.count >= 2,
           let data = Data(base64Encoded: parts[1].paddedBase64),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sub  = json["sub"] as? String,
           let idStr = sub.components(separatedBy: "-").first,
           let id   = Int(idStr) {
            return id
        }

        print("⚠️ Could not extract merchant ID")
        return 0
    }

    // MARK: 1 — GET /redirect-templates?merchantId=:id
    // Mirrors: loadTemplates() in React
    func fetchAll(
        completion: @escaping (Result<[RedirectTemplate]>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let url = "\(base)/redirect-templates?merchantId=\(merchantId)"

        print("📡 REDIRECT FETCH URL: \(url)")

        Alamofire.request(url, method: .get, headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("REDIRECT FETCH STATUS: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("REDIRECT FETCH RESPONSE: \(raw)")
                }

                switch response.result {
                case .success(let data):
                    guard
                        let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                        let errCode = json["error"] as? String,
                        errCode == "0",
                        let arr     = json["data"] as? [[String: Any]]
                    else {
                        let json    = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
                        let msg     = json?["message"] as? String ?? "Failed to load templates"
                        completion(.failure(NSError(domain: "API", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: msg])))
                        return
                    }
                    let templates = arr.compactMap { RedirectTemplate.from(dict: $0) }
                    completion(.success(templates))

                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: 2 — GET /redirect-templates/default?merchantId=:id
    // Mirrors: loadDefaultRedirect() in React — silently ignores errors
    func fetchDefault(
        completion: @escaping (DefaultRedirect?) -> Void
    ) {
        let merchantId = extractMerchantId()
        let url = "\(base)/redirect-templates/default?merchantId=\(merchantId)"

        print("📡 REDIRECT DEFAULT URL: \(url)")

        Alamofire.request(url, method: .get, headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("REDIRECT DEFAULT STATUS: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("REDIRECT DEFAULT RESPONSE: \(raw)")
                }

                guard
                    case .success(let data) = response.result,
                    let json    = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let errCode = json["error"] as? String,
                    errCode == "0",
                    let dict    = json["data"] as? [String: Any]
                else {
                    completion(nil)   // silently ignore — same as React
                    return
                }
                completion(DefaultRedirect.from(dict: dict))
            }
    }

    // MARK: 3 — POST /redirect-templates/create
    // Mirrors: saveTemplate() in React — same endpoint for create AND update (id in payload = update)
    func save(
        payload: RedirectSavePayload,
        completion: @escaping (Result<Void>) -> Void
    ) {
        let url        = "\(base)/redirect-templates/create"
        var dict = payload.toDict()
        dict["merchantId"] = extractMerchantId()
        let parameters = dict

        print("📡 REDIRECT SAVE URL: \(url)")
        print("📦 REDIRECT SAVE PAYLOAD: \(parameters)")

        Alamofire.request(
            url,
            method:     .post,
            parameters: parameters,
            encoding:   JSONEncoding.default,
            headers:    authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print("REDIRECT SAVE STATUS: \(response.response?.statusCode ?? -1)")
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("REDIRECT SAVE RESPONSE: \(raw)")
            }

            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: 4 — POST /redirect-templates/:id?merchantId=:merchantId
    // Mirrors: deleteTemplate(id) in React
    func delete(
        id: Int,
        completion: @escaping (Result<Void>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let url = "\(base)/redirect-templates/\(id)?merchantId=\(merchantId)"

        print("📡 REDIRECT DELETE URL: \(url)")

        Alamofire.request(
            url,
            method:  .post,
            headers: authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print("REDIRECT DELETE STATUS: \(response.response?.statusCode ?? -1)")

            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: 5 — POST /redirect-templates/:id/set-default?mackDefault=:flag&merchantId=:id
    // Mirrors: setTemplateDefault(id) [mackDefault=0] and makeDefaultCard() [mackDefault=1]
    func setDefault(
        id:          Int,
        mackDefault: Int,   // 0 = template default, 1 = global default card
        completion: @escaping (Result<Void>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let url = "\(base)/redirect-templates/\(id)/set-default?mackDefault=\(mackDefault)&merchantId=\(merchantId)"

        print("📡 REDIRECT SET-DEFAULT URL: \(url)")

        Alamofire.request(
            url,
            method:  .post,
            headers: authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            print("REDIRECT SET-DEFAULT STATUS: \(response.response?.statusCode ?? -1)")

            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - String helper — mirrors BuyerInfoService.paddedBase64
private extension String {
    var paddedBase64: String {
        var s   = self
        let rem = s.count % 4
        if rem != 0 { s += String(repeating: "=", count: 4 - rem) }
        return s
    }
}
