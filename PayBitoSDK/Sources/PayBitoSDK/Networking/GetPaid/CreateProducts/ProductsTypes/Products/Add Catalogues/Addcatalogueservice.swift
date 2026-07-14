//
//  Addcatalogueservice.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

//
//  AddCatalogueService.swift
//  Trading_Terminal
//
//  Alamofire 4.x — mirrors PCCatalogueService auth exactly.
//  Keys: "Baccess_token", "Buuid", "Bmerchant_id"
//
//  APIs:
//    1. GET  /shopping/products               — product/price drop-downs
//    2. POST /shopping/catalogs               — create new catalogue
//    3. POST /shopping/catalogs/add-product-price — attach product+price
//

import Foundation
import Alamofire

final class AddCatalogueService {

    static let shared = AddCatalogueService()
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
            debugPrint("🔑 [AddCatalogueService] Token attached")
        } else {
            debugPrint("❌ [AddCatalogueService] Token missing — key: Baccess_token")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
            debugPrint("🆔 [AddCatalogueService] UUID attached")
        } else {
            debugPrint("❌ [AddCatalogueService] UUID missing — key: Buuid")
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
        completion: @escaping (Swift.Result<[ACVAPIProduct], Error>) -> Void
    ) {
        let mid = merchantId
        let url = "\(baseURL)/shopping/products"
        let params: Parameters = [
            "merchantId": mid,
            "page":       page,
            "size":       size,
            "status":     "ALL"
        ]

        debugPrint("╔══ [AddCatalogueService] fetchProducts ══")
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
                    let decoded = try JSONDecoder().decode(ACVProductList.self, from: data)
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
    // MARK: 2 · Create Catalogue  (POST)
    // POST /shopping/catalogs
    // Body: { merchantId, catalogName, description }
    // Response: { status, message, data: CreateCatalogueData }
    // ════════════════════════════════════════════════════════

    func createCatalogue(
        name:        String,
        description: String,
        completion:  @escaping (Swift.Result<CreateCatalogueData, Error>) -> Void
    ) {
        let mid = merchantId
        let url = "\(baseURL)/shopping/catalogs"
        let body: Parameters = [
            "merchantId":  Int(mid) ?? 0,
            "catalogName": name,
            "description": description
        ]

        debugPrint("╔══ [AddCatalogueService] createCatalogue ══")
        debugPrint("║  POST \(url)")
        debugPrint("║  merchantId:\(mid)  name:\"\(name)\"  desc:\"\(description)\"")

        Alamofire.request(
            url,
            method:     .post,
            parameters: body,
            encoding:   JSONEncoding.default,
            headers:    authHeaders
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            debugPrint("║  Status: \(response.response?.statusCode ?? -1)")
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                debugPrint("║  raw (500): \(raw.prefix(500))")
            }
            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(CreateCatalogueResponse.self, from: data)
                    debugPrint("║  ✅ \(decoded.message)  id:\(decoded.data.id)")
                    debugPrint("╚══════════════════════════════════════")
                    DispatchQueue.main.async { completion(.success(decoded.data)) }
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

    // ════════════════════════════════════════════════════════
    // MARK: 3 · Add Product+Price to Catalogue  (POST)
    // POST /shopping/catalogs/add-product-price
    //   ?catalogId=&productId=&priceId=&action=ADD
    // Response: { "success": bool, "returnId": int, "message": string }
    // ════════════════════════════════════════════════════════

    func addProductToCatalogue(
        catalogId:  Int,
        productId:  String,
        priceId:    Int,
        completion: @escaping (Swift.Result<AddProductToNewCatalogueResponse, Error>) -> Void
    ) {
        let url = "\(baseURL)/shopping/catalogs/add-product-price"
        let params: Parameters = [
            "catalogId": catalogId,
            "productId": productId,
            "priceId":   priceId,
            "action":    "ADD"
        ]

        debugPrint("╔══ [AddCatalogueService] addProductToCatalogue ══")
        debugPrint("║  POST \(url)")
        debugPrint("║  catalogId:\(catalogId)  productId:\(productId)  priceId:\(priceId)")

        Alamofire.request(
            url,
            method:     .post,
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
                    let decoded = try JSONDecoder().decode(AddProductToNewCatalogueResponse.self, from: data)
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

