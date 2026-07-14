//
//  Catalogueservice.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  CatalogueService.swift
//  Trading_Terminal
//
//  Alamofire 4 style — matches PCProductService exactly.
//  Fix: message field is Optional in all response models.
//  Fix: delete uses POST to /shopping/catalogs/delete/{id} (DELETE method returns 405)
//

import Foundation
import Alamofire

// MARK: - API Base

private enum PCCatalogAPI {
    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    static var merchantId: Int {
        UserDefaults.standard.integer(forKey: "Bmerchant_id")
    }
}

// MARK: - Service Errors

enum PCCatalogueServiceError: LocalizedError {
    case encodingFailed
    case serverMessage(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .encodingFailed:       return "Failed to encode request body."
        case .serverMessage(let m): return m
        case .unknown:              return "An unknown error occurred."
        }
    }
}

// MARK: - PCCatalogueService

final class PCCatalogueService {
    
    static let shared = PCCatalogueService()
    private init() {}
    
    // MARK: - Auth Headers
    
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
            debugPrint("🔑 [PCCatalogueService] Token attached")
        } else {
            debugPrint("❌ [PCCatalogueService] Token missing — key: Baccess_token")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
            debugPrint("🆔 [PCCatalogueService] UUID attached")
        } else {
            debugPrint("❌ [PCCatalogueService] UUID missing — key: Buuid")
        }
        return h
    }
    
    // ============================================================
    // MARK: - GET Catalogues
    // GET /shopping/catalogs/:merchantId
    // ============================================================
    
    func getCatalogues(
        completion: @escaping (Swift.Result<[PCCatalogueData], Error>) -> Void
    ) {
        let url = "\(PCCatalogAPI.base)/shopping/catalogs/\(PCCatalogAPI.merchantId)"
        
        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [PCCatalogueService] getCatalogues")
        debugPrint("   URL        : \(url)")
        debugPrint("   merchantId : \(PCCatalogAPI.merchantId)")
        debugPrint("   Headers    : \(authHeaders)")
        debugPrint("────────────────────────────────────────")
        
        Alamofire
            .request(url, method: .get, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [PCCatalogueService] getCatalogues HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(PCGetCataloguesResponse.self, from: data)
                        let count   = decoded.data?.count ?? 0
                        debugPrint("✅ [PCCatalogueService] getCatalogues — count: \(count)")
                        decoded.data?.enumerated().forEach { i, c in
                            debugPrint("   [\(i)] id=\(c.id) | name=\(c.catalogName) | desc=\(c.description)")
                        }
                        DispatchQueue.main.async { completion(.success(decoded.data ?? [])) }
                    } catch {
                        debugPrint("❌ [PCCatalogueService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ [PCCatalogueService] Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
    
    // ============================================================
    // MARK: - CREATE Catalogue
    // POST /shopping/catalogs
    // ============================================================
    
    func createCatalogue(
        catalogName: String,
        description: String,
        completion:  @escaping (Swift.Result<PCCatalogueData, Error>) -> Void
    ) {
        let url = "\(PCCatalogAPI.base)/shopping/catalogs"
        let params: [String: Any] = [
            "merchantId":  Int(PCCatalogAPI.merchantId) ?? 0,
            "catalogName": catalogName,
            "description": description
        ]
        
        debugPrint("────────────────────────────────────────")
        debugPrint("📤 [PCCatalogueService] createCatalogue")
        debugPrint("   URL         : \(url)")
        debugPrint("   merchantId  : \(PCCatalogAPI.merchantId)")
        debugPrint("   catalogName : \(catalogName)")
        debugPrint("   description : \(description)")
        if let pretty = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted),
           let str = String(data: pretty, encoding: .utf8) {
            debugPrint("📦 Body:\n\(str)")
        }
        debugPrint("   Headers     : \(authHeaders)")
        debugPrint("────────────────────────────────────────")
        
        Alamofire
            .request(url, method: .post, parameters: params,
                     encoding: JSONEncoding.default, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [PCCatalogueService] createCatalogue HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(PCCatalogueResponse.self, from: data)
                        let msg = decoded.message ?? "Success"
                        debugPrint(decoded.status
                                   ? "✅ [PCCatalogueService] Created — \(msg)"
                                   : "⚠️  [PCCatalogueService] status=false — \(msg)")
                        if decoded.status, let catalogData = decoded.data {
                            debugPrint("   🆔 id=\(catalogData.id)  name=\(catalogData.catalogName)")
                            DispatchQueue.main.async { completion(.success(catalogData)) }
                        } else {
                            let err = PCCatalogueServiceError.serverMessage(msg)
                            DispatchQueue.main.async { completion(.failure(err)) }
                        }
                    } catch {
                        debugPrint("❌ [PCCatalogueService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ [PCCatalogueService] Network error: \(error.localizedDescription)")
                    if let data = response.data,
                       let decoded = try? JSONDecoder().decode(PCCatalogueResponse.self, from: data) {
                        let err = PCCatalogueServiceError.serverMessage(decoded.message ?? error.localizedDescription)
                        DispatchQueue.main.async { completion(.failure(err)) }
                    } else {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
            }
    }
    
    // ============================================================
    // MARK: - DELETE Catalogue
    // DELETE /shopping/catalogs/deletecatalogs/{catalogueId}/{merchantId}
    // Response: { "status": true, "message": "Catalogue deleted successfully", "data": null }
    // Confirmed from Chrome DevTools network tab.
    // ============================================================
    
    func deleteCatalogue(
        catalogueId: Int,
        completion:  @escaping (Swift.Result<String, Error>) -> Void
    ) {
        let mid = PCCatalogAPI.merchantId
        let url = "\(PCCatalogAPI.base)/shopping/catalogs/deletecatalogs/\(catalogueId)/\(mid)"
        
        debugPrint("────────────────────────────────────────")
        debugPrint("🗑️ [PCCatalogueService] deleteCatalogue")
        debugPrint("   DELETE \(url)")
        debugPrint("   catalogueId : \(catalogueId)")
        debugPrint("   merchantId  : \(mid)")
        debugPrint("────────────────────────────────────────")
        
        Alamofire
            .request(url, method: .delete, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [PCCatalogueService] deleteCatalogue HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw: \(raw.prefix(300))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(PCCatalogueResponse.self, from: data)
                        let msg = decoded.message ?? "Catalogue deleted successfully"
                        debugPrint(decoded.status
                                   ? "✅ [PCCatalogueService] Deleted — \(msg)"
                                   : "⚠️  [PCCatalogueService] status=false — \(msg)")
                        if decoded.status {
                            DispatchQueue.main.async { completion(.success(msg)) }
                        } else {
                            let err = PCCatalogueServiceError.serverMessage(msg)
                            DispatchQueue.main.async { completion(.failure(err)) }
                        }
                    } catch {
                        debugPrint("❌ [PCCatalogueService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ [PCCatalogueService] Network error: \(error.localizedDescription)")
                    if let data = response.data,
                       let decoded = try? JSONDecoder().decode(PCCatalogueResponse.self, from: data) {
                        let err = PCCatalogueServiceError.serverMessage(decoded.message ?? error.localizedDescription)
                        DispatchQueue.main.async { completion(.failure(err)) }
                    } else {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
            }
    }
    

    // ============================================================
    // MARK: - GET Product Count for a Catalogue
    // GET /shopping/catalogs/products/{catalogId}
    // ============================================================

    func getCatalogueProductCount(
        catalogId:  Int,
        completion: @escaping (Swift.Result<Int, Error>) -> Void
    ) {
        let url = "\(PCCatalogAPI.base)/shopping/products/\(PCCatalogAPI.merchantId)/\(catalogId)"
        

        debugPrint("📡 [PCCatalogueService] getCatalogueProductCount id=\(catalogId)")
        debugPrint("   URL: \(url)")

        Alamofire
            .request(url, method: .get, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 getCatalogueProductCount(\(catalogId)) HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw: \(raw.prefix(300))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        let dataDict = json?["data"] as? [String: Any]
                        let catalogs = dataDict?["catalogs"] as? [[String: Any]]
                        let firstCatalog = catalogs?.first
                        let products = firstCatalog?["products"] as? [Any]
                        
                        let count = products?.count ?? 0
                        debugPrint("✅ catalogue \(catalogId) → \(count) products")
                        DispatchQueue.main.async { completion(.success(count)) }
                    } catch {
                        debugPrint("❌ json decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ network error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    func getCatalogueProducts(
        catalogId:  Int,
        completion: @escaping (Swift.Result<[PCCatalogProductSelection], Error>) -> Void
    ) {
        let url = "\(PCCatalogAPI.base)/shopping/products/\(PCCatalogAPI.merchantId)/\(catalogId)"
        
        debugPrint("📡 [PCCatalogueService] getCatalogueProducts id=\(catalogId)")

        Alamofire
            .request(url, method: .get, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let jsonStr = String(data: data, encoding: .utf8) {
                            debugPrint("📡 [PCCatalogueService] getCatalogueProducts JSON: \(jsonStr)")
                        }
                        let dataDict = json?["data"] as? [String: Any]
                        let catalogs = (dataDict?["catalogs"] as? [[String: Any]]) ?? (json?["catalogs"] as? [[String: Any]])
                        let firstCatalog = catalogs?.first
                        let products = firstCatalog?["products"] as? [[String: Any]] 
                            ?? dataDict?["products"] as? [[String: Any]]
                            ?? json?["products"] as? [[String: Any]] 
                            ?? []
                        
                        var selections: [PCCatalogProductSelection] = []
                        for p in products {
                            var productId = (p["productId"] as? String) ?? (p["productId"] as? Int).map(String.init) ?? ""
                            if productId.isEmpty {
                                productId = (p["id"] as? String) ?? (p["id"] as? Int).map(String.init) ?? ""
                            }
                            if productId.isEmpty { continue }
                            
                            let productName = (p["name"] as? String) ?? productId
                            
                            if let prices = p["prices"] as? [[String: Any]] {
                                for pr in prices {
                                    
                                    let rInt = pr["priceId"] as? Int
                                    let rStr = (pr["priceId"] as? String).flatMap(Int.init)
                                    let rId = pr["id"] as? Int
                                    let rIdStr = (pr["id"] as? String).flatMap(Int.init)
                                    guard let rawPriceId = rInt ?? rStr ?? rId ?? rIdStr else { continue }
                                    
                                    let priceLabel = "price_\(rawPriceId)"
                                    
                                    var currencyList: [String] = []
                                    var priceDisplay: String? = nil
                                    
                                    if let currencies = pr["currencies"] as? [[String: Any]] {
                                        currencyList = currencies.compactMap { $0["currency"] as? String }
                                        if let defaultCur = currencies.first(where: { ($0["isDefault"] as? Bool) == true }) ?? currencies.first {
                                            let curCode = defaultCur["currency"] as? String ?? ""
                                            let amt = defaultCur["amount"] as? Double ?? (defaultCur["amount"] as? String).flatMap(Double.init) ?? 0.0
                                            priceDisplay = "\(curCode) \(String(format: "%.2f", amt))"
                                        }
                                    }
                                    
                                    let quantity = p["itemQuantity"] as? Int ?? (p["itemQuantity"] as? String).flatMap(Int.init)
                                    
                                    selections.append(PCCatalogProductSelection(
                                        productId: productId,
                                        rawPriceId: rawPriceId,
                                        productName: productName,
                                        priceID: priceLabel,
                                        priceDisplay: priceDisplay,
                                        quantity: quantity,
                                        currencies: currencyList
                                    ))
                                }
                            }
                        }
                        
                        debugPrint("✅ catalogue \(catalogId) → \(selections.count) selections loaded")
                        DispatchQueue.main.async { completion(.success(selections)) }
                    } catch {
                        debugPrint("❌ json decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ network error: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
