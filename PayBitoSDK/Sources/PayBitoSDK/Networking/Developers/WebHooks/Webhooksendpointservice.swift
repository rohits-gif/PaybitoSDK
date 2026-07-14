//
//  WebhookEndpointService.swift
//

import Foundation
import Alamofire

// MARK: - API Endpoints

private enum WHAPI {
    static let base              = "https://service.hashcashconsultants.com/billbitcoins-v2/merchantwebhooks"
    static let fetchEndpointsURL = "\(base)/endpoints"
    static let addEndpointURL    = "\(base)/endpoints"
    static let deleteEndpointURL = "\(base)/deleteEndpoint"

    static func updateEndpointURL(epId: Int) -> String { "\(base)/updateEndpoints/\(epId)" }
}

// MARK: - WebhookEndpointService

final class WebhookEndpointService {

    static let shared = WebhookEndpointService()
    private init() {}

    // MARK: - Headers

    private func buildWebhookRequestHeaders() -> [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Origin":       "https://trade.paybito.com",
            "Referer":      "https://trade.paybito.com/"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "bearer \(token)"
            debugPrint("🔑 [WHService] token attached")
        } else {
            debugPrint("❌ [WHService] token missing")
        }
        if let uid = UserDefaults.standard.string(forKey: "Buuid"), !uid.isEmpty {
            h["Uuid"] = uid
            debugPrint("🆔 [WHService] Uuid: \(uid)")
        } else {
            debugPrint("❌ [WHService] Buuid missing")
        }
        return h
    }

    // MARK: - UUID Resolution

    private func resolveWebhookUUID(_ callerUUID: String) -> String? {
        if !callerUUID.isEmpty { return callerUUID }
        for key in ["Bexchange_uuid", "billbitcoins_exchange_uuid", "Buuid"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty {
                debugPrint("🆔 [WHService] UUID from '\(key)': \(v)")
                return v
            }
        }
        debugPrint("❌ [WHService] UUID not resolved")
        return nil
    }

    // MARK: - fetchMerchantWebhookEndpoints

    func fetchMerchantWebhookEndpoints(
        merchantId: Int,
        completion: @escaping (Swift.Result<WHEndpointListResponse, Error>) -> Void
    ) {
        let headers    = buildWebhookRequestHeaders()
        // ✅ dynamic merchantId — no hardcoded value
        let parameters: Parameters = ["merchantId": merchantId]

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [WHService] fetchEndpoints | URL: \(WHAPI.fetchEndpointsURL)?merchantId=\(merchantId)")
        debugPrint("════════════════════════════════════════")

        Alamofire
            .request(WHAPI.fetchEndpointsURL,
                     method:     .get,
                     parameters: parameters,
                     encoding:   URLEncoding.queryString,
                     headers:    headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [WHService] fetch HTTP \(response.response?.statusCode ?? -1)")
                debugPrint("   sent URL: \(response.request?.url?.absoluteString ?? "nil")")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(WHEndpointListResponse.self, from: data)
                        debugPrint("✅ decoded \(decoded.data.count) endpoint(s)")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ decode: \(error)")
                        if let raw = response.data,
                           let json = try? JSONSerialization.jsonObject(with: raw),
                           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                           let str = String(data: pretty, encoding: .utf8) {
                            debugPrint("   server JSON:\n\(str)")
                        }
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ network: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - addMerchantWebhookEndpoint

    func addMerchantWebhookEndpoint(
        uuid: String,
        merchantId: Int,
        endpointURL: String,
        description: String,
        eventsMode: String,
        completion: @escaping (Swift.Result<WHAddEndpointResponse, Error>) -> Void
    ) {
        guard let uid = resolveWebhookUUID(uuid) else {
            let err = NSError(domain: "WebhookEndpointService", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Missing UUID"])
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        // ✅ merchantId at root, endpoint fields nested, uid used in header (already set)
        let body: [String: Any] = [
            "merchantId": merchantId,       // ✅ dynamic
            "endpoint": [
                "url":          endpointURL,
                "description":  description,
                "eventsMode":   eventsMode,
                "secret":       uid,        // ✅ uuid used as secret token
                "retryEnabled": "Y",
                "maxRetries":   5,
                "timeoutSec":   5,
                "status":       "Active",
                "events":       [] as [String]
            ]
        ]
        let headers = buildWebhookRequestHeaders()

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [WHService] addEndpoint | URL: \(WHAPI.addEndpointURL)")
        debugPrint("   merchantId: \(merchantId)")
        debugPrint("   body: \(body)")
        debugPrint("════════════════════════════════════════")

        Alamofire
            .request(WHAPI.addEndpointURL,
                     method:     .post,
                     parameters: body,
                     encoding:   JSONEncoding.default,
                     headers:    headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [WHService] addEndpoint HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(800))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(WHAddEndpointResponse.self, from: data)
                        debugPrint("✅ addEndpoint success")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ addEndpoint decode: \(error)")
                        if let raw = response.data,
                           let json = try? JSONSerialization.jsonObject(with: raw),
                           let pretty = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
                           let str = String(data: pretty, encoding: .utf8) {
                            debugPrint("   server JSON:\n\(str)")
                        }
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ addEndpoint network: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - updateMerchantWebhookEndpoint

    func updateMerchantWebhookEndpoint(
        uuid: String,
        epId: Int,
        merchantId: Int,
        params: [String: Any],
        completion: @escaping (Swift.Result<WHUpdateEndpointResponse, Error>) -> Void
    ) {
        guard let _ = resolveWebhookUUID(uuid) else {
            let err = NSError(domain: "WebhookEndpointService", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Missing UUID"])
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        // ✅ merchantId at root, params nested under "endpoint"
        let body: [String: Any] = [
            "merchantId": merchantId,       // ✅ dynamic
            "endpoint":   params
        ]
        let headers = buildWebhookRequestHeaders()
        let url     = WHAPI.updateEndpointURL(epId: epId)

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [WHService] updateEndpoint | URL: \(url)")
        debugPrint("   merchantId: \(merchantId)")
        debugPrint("   body: \(body)")
        debugPrint("════════════════════════════════════════")

        Alamofire
            .request(url,
                     method:     .post,
                     parameters: body,
                     encoding:   JSONEncoding.default,
                     headers:    headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [WHService] updateEndpoint HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(WHUpdateEndpointResponse.self, from: data)
                        debugPrint("✅ updateEndpoint success=\(decoded.isSuccess) message=\(decoded.message ?? "?")")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ updateEndpoint decode: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ updateEndpoint network: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - deleteMerchantWebhookEndpoint

    func deleteMerchantWebhookEndpoint(
        uuid: String,
        epId: Int,
        completion: @escaping (Swift.Result<WHDeleteEndpointResponse, Error>) -> Void
    ) {
        guard let uid = resolveWebhookUUID(uuid) else {
            let err = NSError(domain: "WebhookEndpointService", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Missing UUID"])
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        let body: [String: Any] = [
            "uuid": uid,
            "epId": epId
        ]
        let headers = buildWebhookRequestHeaders()

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [WHService] deleteEndpoint | URL: \(WHAPI.deleteEndpointURL)")
        debugPrint("   body: \(body)")
        debugPrint("════════════════════════════════════════")

        Alamofire
            .request(WHAPI.deleteEndpointURL,
                     method:     .post,
                     parameters: body,
                     encoding:   JSONEncoding.default,
                     headers:    headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [WHService] deleteEndpoint HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(WHDeleteEndpointResponse.self, from: data)
                        debugPrint("✅ deleteEndpoint status=\(decoded.status ?? "?")")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ deleteEndpoint decode: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ deleteEndpoint network: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
