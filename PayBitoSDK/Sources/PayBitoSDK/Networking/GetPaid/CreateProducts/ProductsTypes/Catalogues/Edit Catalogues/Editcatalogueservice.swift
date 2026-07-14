//
//  Editcatalogueservice.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  EditCatalogueService.swift
//  Trading_Terminal
//
//  Alamofire 4.x — mirrors PCCatalogueService auth exactly.
//  Keys: "Baccess_token", "Buuid", "Bmerchant_id"
//
//  APIs:
//    1. GET  /shopping/products               — product/price drop-downs
//    2. AUTO  /shopping/catalogs/... — probes candidates until 2xx
//    3. POST /shopping/catalogs/add-product-price — attach product+price to catalogue
//

import Foundation
import Alamofire

final class EditCatalogueService {

    static let shared = EditCatalogueService()
    private init() {}

    // ── Base URL ──────────────────────────────────────────────
    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // ── Auth — same keys as PCCatalogueService ────────────────
    private var merchantId: Int {
        UserDefaults.standard.integer(forKey: "Bmerchant_id")
    }

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
            debugPrint("🔑 [EditCatalogueService] Token attached")
        } else {
            debugPrint("❌ [EditCatalogueService] Token missing — key: Baccess_token")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
            debugPrint("🆔 [EditCatalogueService] UUID attached")
        } else {
            debugPrint("❌ [EditCatalogueService] UUID missing — key: Buuid")
        }
        return h
    }

    // ════════════════════════════════════════════════════════
    // MARK: 1 · Fetch Products  (GET)
    // GET /shopping/products?merchantId=&page=&size=&status=ALL
    // ════════════════════════════════════════════════════════

    func fetchProducts(
        page:       Int = 1,
        size:       Int = 10,
        completion: @escaping (Swift.Result<[ECVProduct], Error>) -> Void
    ) {
        let mid = merchantId
        let url = "\(baseURL)/shopping/products"
        let params: Parameters = [
            "merchantId": mid,
            "page":       page,
            "size":       size,
            "status":     "ALL"
        ]

        debugPrint("╔══ [EditCatalogueService] fetchProducts ══")
        debugPrint("║  GET \(url)")
        debugPrint("║  merchantId : \(mid)")

        Alamofire.request(
            url,
            method:     .get,
            parameters: params,
            encoding:   URLEncoding.queryString,
            headers:    authHeaders
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            debugPrint("║  Status: \(response.response?.statusCode ?? -1)")
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                debugPrint("║  raw (300): \(raw.prefix(300))")
            }
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(ECVProductList.self, from: data)
                    debugPrint("║  ✅ Products: \(decoded.data.products.count) / \(decoded.data.total)")
                    decoded.data.products.forEach {
                        debugPrint("║    · \($0.name) (\($0.productId)) one-time:\($0.oneTimePrices.count)")
                    }
                    debugPrint("╚══════════════════════════════════════")
                    DispatchQueue.main.async { completion(.success(decoded.data.products)) }
                } catch {
                    debugPrint("║  ❌ Decode error: \(error)")
                    debugPrint("╚══════════════════════════════════════")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            case .failure(let error):
                debugPrint("║  ❌ \(error.localizedDescription)")
                debugPrint("╚══════════════════════════════════════")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: 2 · Edit Catalogue
    // Allow header on /catalogs/{id} = GET only.
    // The edit endpoint must use a different URL pattern.
    // Probing all known variants of the API.
    // ════════════════════════════════════════════════════════

    func editCatalogue(
        catalogId:   Int,
        name:        String,
        description: String,
        completion:  @escaping (Swift.Result<EditCatalogueData, Error>) -> Void
    ) {
        let mid = merchantId

        // Body variants — some endpoints want id in body, some don't
        let bodyWithId: Parameters = [
            "id":          catalogId,
            "merchantId":  mid,
            "catalogName": name,
            "description": description
        ]
        let bodyNoId: Parameters = [
            "merchantId":  mid,
            "catalogName": name,
            "description": description
        ]

        // Based on confirmed delete URL pattern:
        //   DELETE /shopping/catalogs/deletecatalogs/{id}/{merchantId}
        // Edit likely follows same pattern:
        //   POST/PUT /shopping/catalogs/updatecatalogs/{id}/{merchantId}
        let candidates: [(String, HTTPMethod, Parameters)] = [
            // Most likely — mirrors deletecatalogs pattern
            ("\(baseURL)/shopping/catalogs/updatecatalogs/\(catalogId)/\(mid)", .post, bodyNoId),
            ("\(baseURL)/shopping/catalogs/updatecatalogs/\(catalogId)/\(mid)", .put,  bodyNoId),
            ("\(baseURL)/shopping/catalogs/updatecatalogs/\(catalogId)",        .post, bodyNoId),
            ("\(baseURL)/shopping/catalogs/updatecatalogs/\(catalogId)",        .put,  bodyNoId),
            // id in body variants
            ("\(baseURL)/shopping/catalogs",                         .put,  bodyWithId),
            ("\(baseURL)/shopping/catalogs",                         .post, bodyWithId),
            // Other sub-paths
            ("\(baseURL)/shopping/catalogs/\(catalogId)/update",     .post, bodyNoId),
            ("\(baseURL)/shopping/catalogs/update",                  .post, bodyWithId),
            ("\(baseURL)/shopping/catalogs/update",                  .put,  bodyWithId),
            ("\(baseURL)/shopping/catalogue/\(catalogId)",           .post, bodyNoId),
        ]

        debugPrint("╔══ [EditCatalogueService] editCatalogue ══")
        debugPrint("║  catalogId:\(catalogId)  name:\"\(name)\"  merchantId:\(mid)")
        debugPrint("║  Probing \(candidates.count) candidates...")

        tryNextEditCandidate(
            candidates: candidates, index: 0,
            catalogId: catalogId, mid: mid,
            name: name, description: description,
            completion: completion
        )
    }

    private func tryNextEditCandidate(
        candidates:  [(String, HTTPMethod, Parameters)],
        index:       Int,
        catalogId:   Int,
        mid:         Int,
        name:        String,
        description: String,
        completion:  @escaping (Swift.Result<EditCatalogueData, Error>) -> Void
    ) {
        guard index < candidates.count else {
            debugPrint("║  ❌ All \(candidates.count) candidates exhausted.")
            debugPrint("║  👉 ACTION REQUIRED: Open Chrome DevTools on trade.paybito.com")
            debugPrint("║     → Catalogues tab → Edit any catalogue → change name → Save")
            debugPrint("║     → Network tab → find the XHR/Fetch request that fired")
            debugPrint("║     → Share: Request URL + Request Method + Request Body")
            debugPrint("╚══════════════════════════════════════")
            let err = NSError(domain: "EditCatalogueService", code: -1,
                              userInfo: [NSLocalizedDescriptionKey:
                                "Edit endpoint not found. Check Xcode logs for next steps."])
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        let (url, method, body) = candidates[index]
        debugPrint("║  [\(index + 1)/\(candidates.count)] \(method.rawValue.uppercased()) \(url)")

        Alamofire.request(
            url, method: method,
            parameters: body,
            encoding:   JSONEncoding.default,
            headers:    authHeaders
        )
        .responseData { response in
            let status = response.response?.statusCode ?? -1
            let allow  = response.response?.allHeaderFields["Allow"] as? String ?? ""
            debugPrint("║  → HTTP \(status)\(allow.isEmpty ? "" : "  Allow:\(allow)")")
            if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                debugPrint("║  → \(raw.prefix(150))")
            }

            // ✅ 2xx — found it
            if (200..<300).contains(status), let data = response.data {
                debugPrint("║")
                debugPrint("║  ✅ ✅ ✅  WORKING ENDPOINT FOUND  ✅ ✅ ✅")
                debugPrint("║  Method : \(method.rawValue.uppercased())")
                debugPrint("║  URL    : \(url)")
                debugPrint("║  Body   : \(body.keys.sorted())")
                debugPrint("║  👉 Hardcode this and remove the probe loop")
                debugPrint("╚══════════════════════════════════════")

                if let decoded = try? JSONDecoder().decode(EditCatalogueResponse.self, from: data) {
                    DispatchQueue.main.async { completion(.success(decoded.data)) }
                    return
                }
                // Synthetic fallback for non-standard response shape
                let synthetic = EditCatalogueData(
                    id: catalogId, merchantId: mid,
                    catalogName: name, description: description, createdAt: "")
                DispatchQueue.main.async { completion(.success(synthetic)) }
                return
            }

            // Skip 404 / 405 — wrong path or method, try next
            // Skip 403 CORS — server doesn't allow this method from this origin
            if [403, 404, 405].contains(status) {
                self.tryNextEditCandidate(
                    candidates: candidates, index: index + 1,
                    catalogId: catalogId, mid: mid,
                    name: name, description: description,
                    completion: completion)
                return
            }

            // 401 / 500 etc — real error, stop
            let err = response.error ?? NSError(
                domain: "EditCatalogueService", code: status,
                userInfo: [NSLocalizedDescriptionKey: "HTTP \(status)"])
            debugPrint("║  ❌ Non-retryable \(status)")
            debugPrint("╚══════════════════════════════════════")
            DispatchQueue.main.async { completion(.failure(err)) }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: 3 · Add Product+Price to Catalogue  (POST)
    // POST /shopping/catalogs/add-product-price
    //   ?catalogId=3124&productId=PROD_xxx&priceId=1384&action=ADD
    // Response: { "success": bool, "returnId": int, "message": string }
    // ════════════════════════════════════════════════════════

    func addProductToCatalogue(
        catalogId:  Int,
        productId:  String,
        priceId:    Int,
        action:     String = "ADD",
        completion: @escaping (Swift.Result<AddProductToCatalogueResponse, Error>) -> Void
    ) {
        let url = "\(baseURL)/shopping/catalogs/add-product-price"
        let params: Parameters = [
            "catalogId": catalogId,
            "productId": productId,
            "priceId":   priceId,
            "action":    action
        ]

        debugPrint("╔══ [EditCatalogueService] addProductToCatalogue ══")
        debugPrint("║  POST \(url)")
        debugPrint("║  catalogId:\(catalogId)  productId:\(productId)  priceId:\(priceId)")

        Alamofire.request(
            url,
            method:     .post,
            parameters: params,
            encoding:   URLEncoding.queryString,   // sent as query params, not JSON body
            headers:    authHeaders
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            debugPrint("║  Status: \(response.response?.statusCode ?? -1)")
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                debugPrint("║  raw (300): \(raw.prefix(300))")
            }
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(AddProductToCatalogueResponse.self, from: data)
                    if decoded.success {
                        debugPrint("║  ✅ \(decoded.message)  returnId:\(decoded.returnId)")
                    } else {
                        debugPrint("║  ⚠️  success=false — \(decoded.message)")
                    }
                    debugPrint("╚══════════════════════════════════════")
                    DispatchQueue.main.async { completion(.success(decoded)) }
                } catch {
                    debugPrint("║  ❌ Decode error: \(error)")
                    debugPrint("╚══════════════════════════════════════")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            case .failure(let error):
                debugPrint("║  ❌ \(error.localizedDescription)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("║  Raw: \(raw)")
                }
                debugPrint("╚══════════════════════════════════════")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}

// ── Local error type ──────────────────────────────────────────
private enum ECVServiceError: LocalizedError {
    case decodingFailed
    var errorDescription: String? { "Failed to decode server response." }
}
