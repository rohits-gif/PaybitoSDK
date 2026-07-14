//
//  CreatePaymentService.swift
//  Trading_Terminal
//

import Foundation
import Alamofire

// MARK: - Result type returned to ViewModel

struct CreatePaymentResult {
    let id:  String
    let url: String

    private static func checkoutURL(for id: String) -> String {
        let raw    = UserDefaults.standard.string(forKey: "paybitoURL") ?? ""
        let domain = raw.isEmpty ? "https://trade.paybito.com" : raw
        let base   = domain.hasSuffix("/") ? domain : domain + "/"
        let url    = base + "payments/merchant/checkout/" + id
        debugPrint("🔗 [CreatePaymentResult] domain=\(domain)  url=\(url)")
        return url
    }

    // Standard — builds checkout URL from dynamic domain + ID
    init(id: String) {
        self.id  = id
        self.url = Self.checkoutURL(for: id)
    }

    // Custom — uses URL exactly as returned by API
    init(id: String, customURL: String) {
        self.id  = id
        self.url = customURL
    }
}

// MARK: - API Constants

private enum API {
    static let base     = "https://service.hashcashconsultants.com/billbitcoins-v2"
    static let pageSize = 100

    static var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
    }
}

// MARK: - Service

final class CreatePaymentService {

    static let shared = CreatePaymentService()
    private init() {}

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
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
        }
        return h
    }

    // MARK: - Fetch Profiles
    
    func fetchProfiles(url: String, completion: @escaping (Swift.Result<[CPProfile], Error>) -> Void) {
        Alamofire
            .request(url, method: .get, parameters: nil,
                     encoding: URLEncoding.default, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
                switch response.result {
                case .success(let data):
                    do {
                        // Some endpoints return a dictionary with "data" or "value", others return an array directly
                        let json = try JSONSerialization.jsonObject(with: data)
                        var arrayToDecode: Any?
                        
                        if let dict = json as? [String: Any] {
                            arrayToDecode = (dict["data"] as? [[String: Any]]) ?? (dict["value"] as? [[String: Any]])
                        } else if let arr = json as? [[String: Any]] {
                            arrayToDecode = arr
                        }
                        
                        guard let validArray = arrayToDecode as? [[String: Any]] else {
                            throw NSError(domain: "Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid profile format"])
                        }
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: validArray)
                        let decoded = try JSONDecoder().decode([CPProfile].self, from: jsonData)
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - Fetch Products

    func fetchProducts(
        page: Int = 1,
        completion: @escaping (Swift.Result<ProductListData, Error>) -> Void
    ) {
        let url    = "\(API.base)/shopping/products"
        let params: [String: Any] = [
            "merchantId": API.merchantId,
            "page":       page,
            "size":       API.pageSize,
            "status":     "ACTIVE"
        ]

        debugPrint("📡 [Service] fetchProducts → \(url)")

        Alamofire
            .request(url, method: .get, parameters: params,
                     encoding: URLEncoding.queryString, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
                debugPrint("📥 [Service] HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(ProductListResponse.self, from: data)
                        DispatchQueue.main.async { completion(.success(decoded.data)) }
                        self.fetchBrokerIdFromUserSettings { _ in }
                    } catch {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - Fetch Catalogs

    func fetchCatalogs(
        completion: @escaping (Swift.Result<[CPCatalog], Error>) -> Void
    ) {
        let url = "\(API.base)/shopping/catalogs/\(API.merchantId)"
        debugPrint("📡 [Service] fetchCatalogs → \(url)")

        Alamofire
            .request(url, method: .get, parameters: nil,
                     encoding: URLEncoding.default, headers: authHeaders)
            .validate(statusCode: 200..<300)
            .responseData(queue: DispatchQueue.global(qos: .userInitiated)) { response in
                switch response.result {
                case .success(let data):
                    do {
                        let json = try JSONSerialization.jsonObject(with: data)
                        var arrayToDecode: Any?
                        if let dict = json as? [String: Any] {
                            arrayToDecode = (dict["data"] as? [[String: Any]]) ?? (dict["value"] as? [[String: Any]])
                        } else if let arr = json as? [[String: Any]] {
                            arrayToDecode = arr
                        }
                        
                        guard let validArray = arrayToDecode as? [[String: Any]] else {
                            throw NSError(domain: "Service", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid catalog format"])
                        }
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: validArray)
                        let decoded = try JSONDecoder().decode([CPCatalog].self, from: jsonData)
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }


    // MARK: - Create Payment Link (regular products)

    func createPaymentLink(
        productId: String?,
        priceId:   Int?,
        catalogId: Int?,
        name:      String?,
        shippingProfileId: Int = 0,
        buyerProfileId: Int = 0,
        discountProfileName: String = "",
        billingId: Int = 0,
        isProcessingFeeApplied: Int = 0,
        redirectId: Int = 0,
        completion: @escaping (Swift.Result<CreatePaymentResult, Error>) -> Void
    ) {
        let url = "\(API.base)/payment/create"

        var body: [String: Any] = [
            "merchantId":             API.merchantId,
            "paymentName":            name ?? "",
            "paymentType":            "CHECKOUT",
            "shippingProfileId":      shippingProfileId,
            "buyerProfileId":         buyerProfileId,
            "discountProfileName":    discountProfileName,
            "billingId":              billingId,
            "isProcessingFeeApplied": isProcessingFeeApplied,
            "redirectId":             redirectId
        ]
        
        if let pId = productId, let pPrice = priceId {
            body["productId"] = pId
            body["priceId"] = pPrice
        } else if let cId = catalogId {
            body["catalogId"] = cId
        }

        debugPrint("────────────────────────────────────")
        debugPrint("📡 [Service] createPaymentLink")
        debugPrint("   URL : \(url)")
        debugPrint("   Body: \(body)")
        debugPrint("────────────────────────────────────")

        Alamofire
            .request(url, method: .post, parameters: body,
                     encoding: JSONEncoding.default, headers: authHeaders)
            .validate()
            .responseData { response in
                debugPrint("📥 [Service] createPaymentLink HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }

                switch response.result {
                case .success(let data):
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            throw NSError(domain: "Service", code: -3,
                                          userInfo: [NSLocalizedDescriptionKey: "Response is not a JSON object"])
                        }
                        debugPrint("✅ [Service] json: \(json)")

                        if let paymentId = json["id"] as? String, !paymentId.isEmpty {
                            let result = CreatePaymentResult(id: paymentId)
                            DispatchQueue.main.async { completion(.success(result)) }

                        } else if let fullLink = json["link"] as? String, !fullLink.isEmpty {
                            let id = URL(string: fullLink)?.lastPathComponent ?? fullLink
                            let result = CreatePaymentResult(id: id)
                            DispatchQueue.main.async { completion(.success(result)) }

                        } else {
                            let msg = (json["message"] as? String) ?? "Missing 'id' in response"
                            throw NSError(domain: "Service", code: -2,
                                          userInfo: [NSLocalizedDescriptionKey: msg])
                        }
                    } catch {
                        debugPrint("❌ [Service] parse: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [Service] network: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - Create Quick Payment Link
    //
    // ─────────────────────────────────────────────────────────────────────────
    // CONFIRMED from web app network inspector (screenshots):
    //
    // The web app does TWO calls for a quick payment:
    //
    // STEP 1 — POST /shopping/register
    //   Registers a one-time product with paymentType "QUICK_PAYMENT".
    //   Response → productId: "QUICK_<timestamp>", priceId: <int>
    //
    //   Payload (from network inspector Image 1):
    //   {
    //     "merchantId": 29584,
    //     "products": [{
    //       "productId": "QUICK_1781877086619",
    //       "productType": "QUICK_PAYMENT",
    //       "name": "Quick Payment 19/06/2026, 19:21:26",
    //       "description": "Quick payment product",
    //       "imageUrl": "",
    //       "attributes": {},
    //       "metadata": { "type": "quick_payment", "created_at": "2026-06-19T13:51:26.620Z" },
    //       "prices": [{
    //         "isDefault": true,
    //         "priceType": "one-time",
    //         "intervalType": null,
    //         "intervalCount": 0,
    //         "trialDays": 0,
    //         "variant": {},
    //         "sku": "",
    //         "inventory": { "track": false, "quantity": 0 },
    //         "currencies": [{ "currency": "USD", "amount": 80, "isDefault": true }]
    //       }]
    //     }]
    //   }
    //
    // STEP 2 — POST /payment/create
    //   Creates a CHECKOUT link using the productId + priceId from Step 1.
    //   paymentType is "CHECKOUT" (NOT "QUICK_PAYMENT").
    //   Response → id: "PCN4585"
    //   URL built as: <domain>/payments/merchant/checkout/PCN4585
    //
    //   Payload (from network inspector Image 2):
    //   {
    //     "merchantId": 29584,
    //     "paymentName": "Quick Payment 19/06/2026, 19:21:26",
    //     "paymentType": "CHECKOUT",
    //     "productId": "QUICK_1781877086619",
    //     "priceId": 1709,
    //     "billingId": 0,
    //     "buyerProfileId": 0,
    //     "discountProfileName": "",
    //     "isProcessingFeeApplied": 0,
    //     "redirectId": 0,
    //     "shippingProfileId": 0
    //   }
    // ─────────────────────────────────────────────────────────────────────────

    func createQuickPaymentLink(
        amount:   String,
        currency: String,
        name:     String?,
        completion: @escaping (Swift.Result<CreatePaymentResult, Error>) -> Void
    ) {
        guard let amountDouble = Double(amount), amountDouble > 0 else {
            let err = NSError(domain: "Service", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Invalid amount"])
            completion(.failure(err))
            return
        }

        // ── Generate a timestamp-based product ID matching the web app format ──
        let timestampMs = Int64(Date().timeIntervalSince1970 * 1000)
        let productId   = "QUICK_\(timestampMs)"

        // ── Human-readable date label matching the web app format ──────────────
        let dateFormatter      = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy, HH:mm:ss"
        let dateLabel          = dateFormatter.string(from: Date())
        let paymentName        = name?.isEmpty == false ? name! : "Quick Payment \(dateLabel)"

        // ── ISO timestamp for metadata ─────────────────────────────────────────
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoNow = isoFormatter.string(from: Date())

        // STEP 1: Register the quick-payment product
        registerQuickProduct(
            productId:   productId,
            paymentName: paymentName,
            amount:      amountDouble,
            currency:    currency,
            isoNow:      isoNow
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }

            case .success(let priceId):
                // STEP 2: Create a CHECKOUT payment link using the registered product
                self.createCheckoutFromQuickProduct(
                    productId:   productId,
                    priceId:     priceId,
                    paymentName: paymentName,
                    completion:  completion
                )
            }
        }
    }

    // MARK: - Step 1: Register quick-payment product

    private func registerQuickProduct(
        productId:   String,
        paymentName: String,
        amount:      Double,
        currency:    String,
        isoNow:      String,
        completion:  @escaping (Swift.Result<Int, Error>) -> Void
    ) {
        let url = "\(API.base)/shopping/products/register"

        let product: [String: Any] = [
            "productId":   productId,
            "productType": "QUICK_PAYMENT",
            "name":        paymentName,
            "description": "Quick payment product",
            "imageUrl":    "",
            "attributes":  [String: Any](),
            "metadata":    [
                "type":       "quick_payment",
                "created_at": isoNow
            ],
            "prices": [[
                "isDefault":     true,
                "priceType":     "one-time",
                "intervalType":  NSNull(),
                "intervalCount": NSNull(),
                "trialDays":     0,
                "variant":       [String: Any](),
                "sku":           "",
                "inventory":     ["track": false, "quantity": 0],
                "currencies":    [[
                    "currency":  currency,
                    "amount":    amount,
                    "isDefault": true
                ]]
            ]]
        ]

        let body: [String: Any] = [
            "merchantId": Int(API.merchantId) ?? 0,
            "products":   [product]
        ]

        debugPrint("────────────────────────────────────")
        debugPrint("📡 [Service] registerQuickProduct STEP 1")
        debugPrint("   URL       : \(url)")
        debugPrint("   productId : \(productId)")
        debugPrint("   amount    : \(amount) \(currency)")
        debugPrint("────────────────────────────────────")

        Alamofire
            .request(url, method: .post, parameters: body,
                     encoding: JSONEncoding.default, headers: authHeaders)
            .validate()
            .responseData { response in
                debugPrint("📥 [Service] register HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   FULL raw: \(raw)")
                }

                switch response.result {
                case .success(let data):
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            throw NSError(domain: "Service", code: -3,
                                          userInfo: [NSLocalizedDescriptionKey: "Register: not a JSON object"])
                        }
                        debugPrint("✅ [Service] register json keys: \(json.keys.sorted())")
                        debugPrint("✅ [Service] register full json: \(json)")

                        // Extract priceId from response
                        // Expected shapes:
                        //   { "products": [{ "prices": [{ "priceId": 1709 }] }] }
                        //   { "data": [{ "prices": [{ "priceId": 1709 }] }] }
                        //   { "priceId": 1709 }
                        let priceId = Self.extractPriceId(from: json)

                        if let pid = priceId {
                            debugPrint("✅ [Service] register priceId=\(pid)")
                            completion(.success(pid))
                        } else {
                            // If we can't parse priceId, try fetching from products list
                            // The product was registered — try to find its priceId via products API
                            debugPrint("⚠️ [Service] priceId not in register response — fetching from products")
                            completion(.failure(NSError(
                                domain: "Service", code: -4,
                                userInfo: [NSLocalizedDescriptionKey: "Could not extract priceId from register response. Raw: \(String(data: data, encoding: .utf8) ?? "")"]
                            )))
                        }
                    } catch {
                        debugPrint("❌ [Service] register parse: \(error)")
                        completion(.failure(error))
                    }

                case .failure(let error):
                    debugPrint("❌ [Service] register network: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Step 2: Create CHECKOUT link from registered quick-payment product

    private func createCheckoutFromQuickProduct(
        productId:   String,
        priceId:     Int,
        paymentName: String,
        completion:  @escaping (Swift.Result<CreatePaymentResult, Error>) -> Void
    ) {
        let url = "\(API.base)/payment/create"

        // Payload confirmed from web app network inspector (Image 2):
        // paymentType is "CHECKOUT" — same as a regular product payment
        let body: [String: Any] = [
            "merchantId":             API.merchantId,
            "paymentName":            paymentName,
            "paymentType":            "CHECKOUT",
            "productId":              productId,
            "priceId":                priceId,
            "shippingProfileId":      0,
            "buyerProfileId":         0,
            "discountProfileName":    "",
            "billingId":              0,
            "isProcessingFeeApplied": 0,
            "redirectId":             0
        ]

        debugPrint("────────────────────────────────────")
        debugPrint("📡 [Service] createCheckoutFromQuickProduct STEP 2")
        debugPrint("   URL       : \(url)")
        debugPrint("   productId : \(productId)")
        debugPrint("   priceId   : \(priceId)")
        debugPrint("────────────────────────────────────")

        Alamofire
            .request(url, method: .post, parameters: body,
                     encoding: JSONEncoding.default, headers: authHeaders)
            .validate()
            .responseData { response in
                debugPrint("📥 [Service] createCheckout HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   FULL raw: \(raw)")
                }

                switch response.result {
                case .success(let data):
                    do {
                        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                            throw NSError(domain: "Service", code: -3,
                                          userInfo: [NSLocalizedDescriptionKey: "Create: not a JSON object"])
                        }
                        debugPrint("✅ [Service] createCheckout json: \(json)")

                        // Same ID extraction as regular createPaymentLink
                        if let paymentId = json["id"] as? String, !paymentId.isEmpty {
                            let result = CreatePaymentResult(id: paymentId)
                            debugPrint("✅ [Service] quick payment URL: \(result.url)")
                            DispatchQueue.main.async { completion(.success(result)) }

                        } else if let fullLink = json["link"] as? String, !fullLink.isEmpty {
                            let id = URL(string: fullLink)?.lastPathComponent ?? fullLink
                            let result = CreatePaymentResult(id: id, customURL: fullLink)
                            DispatchQueue.main.async { completion(.success(result)) }

                        } else {
                            let msg = (json["message"] as? String) ?? "Missing 'id' in create response"
                            throw NSError(domain: "Service", code: -2,
                                          userInfo: [NSLocalizedDescriptionKey: msg])
                        }
                    } catch {
                        debugPrint("❌ [Service] createCheckout parse: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [Service] createCheckout network: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - Extract priceId from register response
    //
    // The register endpoint may return priceId in various shapes.
    // We try multiple paths to be resilient.

    private static func extractPriceId(from json: [String: Any]) -> Int? {
        // Shape 1: { "products": [{ "prices": [{ "priceId": 1709 }] }] }
        if let products = json["products"] as? [[String: Any]],
           let first = products.first,
           let prices = first["prices"] as? [[String: Any]],
           let firstPrice = prices.first,
           let pid = firstPrice["priceId"] as? Int {
            return pid
        }

        // Shape 2: { "data": [{ "prices": [{ "priceId": 1709 }] }] }
        if let data = json["data"] as? [[String: Any]],
           let first = data.first,
           let prices = first["prices"] as? [[String: Any]],
           let firstPrice = prices.first,
           let pid = firstPrice["priceId"] as? Int {
            return pid
        }

        // Shape 3: { "data": { "prices": [{ "priceId": 1709 }] } }
        if let data = json["data"] as? [String: Any],
           let prices = data["prices"] as? [[String: Any]],
           let firstPrice = prices.first,
           let pid = firstPrice["priceId"] as? Int {
            return pid
        }

        // Shape 4: top-level priceId
        if let pid = json["priceId"] as? Int { return pid }

        // Shape 5: deep recursive search for "priceId" key
        return findPriceId(in: json)
    }

    private static func findPriceId(in dict: [String: Any]) -> Int? {
        for (key, value) in dict {
            if key == "priceId", let pid = value as? Int { return pid }
            if let nested = value as? [String: Any], let found = findPriceId(in: nested) { return found }
            if let arr = value as? [[String: Any]] {
                for item in arr {
                    if let found = findPriceId(in: item) { return found }
                }
            }
        }
        return nil
    }

    // MARK: - Send Payment Link

    func sendPaymentLink(
        paymentOrderId: String,
        paymentLink:    String,
        emails:         [String],
        completion:     @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        resolveBrokerId { [weak self] brokerId in
            guard let self else { return }
            self.fireSendPaymentLink(
                paymentOrderId: paymentOrderId,
                paymentLink:    paymentLink,
                emails:         emails,
                brokerId:       brokerId,
                completion:     completion
            )
        }
    }

    private func resolveBrokerId(then handler: @escaping (String) -> Void) {
        fetchBrokerIdFromUserSettings { brokerId in
            guard !brokerId.isEmpty else {
                debugPrint("⚠️ [Service] Could not resolve brokerId — sending with empty string")
                handler("")
                return
            }
            debugPrint("✅ [Service] brokerId resolved: \(brokerId)")
            handler(brokerId)
        }
    }

    func fetchBrokerIdFromUserSettings(completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let knownKeys = ["BbrokerId", "Bbroker_id", "BexchangeId", "Bexchange_id",
                             "BbrokerCode", "Bpartner_id", "BpartnerId", "Bbroker",
                             "BexchangeCode", "BpartnerCode", "BbrokerName"]

            let allDefaults = UserDefaults.standard.dictionaryRepresentation()

            var existingBrokerId = knownKeys
                .compactMap({ UserDefaults.standard.string(forKey: $0) })
                .first(where: { $0.hasPrefix("PAYB") && !$0.isEmpty })
                ?? allDefaults.values
                    .compactMap({ $0 as? String })
                    .first(where: { $0.hasPrefix("PAYB") && !$0.isEmpty })
                ?? ""

            let url = "https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo"
            var params: [String: Any] = [:]
            if !existingBrokerId.isEmpty {
                params["brokerId"] = existingBrokerId
            } else {
                params["merchantId"] = API.merchantId
            }

            debugPrint("📡 [Service] getBrokerWiseExchangeInfo → \(url)")

            DispatchQueue.main.async {
                Alamofire
                    .request(url, method: .get, parameters: params,
                             encoding: URLEncoding.queryString, headers: self.authHeaders)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [Service] getBrokerWiseExchangeInfo HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(800))")
                }

                var resolved = existingBrokerId

                if case .success(let data) = response.result,
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

                    if let valueArr = json["value"] as? [[String: Any]],
                       let first = valueArr.first {
                        let bid = (first["broker_id"]  as? String) ??
                                  (first["brokerId"]   as? String) ??
                                  (first["brokerCode"] as? String) ?? ""
                        if !bid.isEmpty { resolved = bid }
                    }
                    if resolved.isEmpty {
                        resolved = (json["broker_id"] as? String) ??
                                   (json["brokerId"]  as? String) ?? ""
                    }
                    if resolved.isEmpty, let dataObj = json["data"] as? [String: Any] {
                        resolved = (dataObj["broker_id"] as? String) ??
                                   (dataObj["brokerId"]  as? String) ?? ""
                    }
                    if resolved.isEmpty {
                        resolved = Self.findPAYBValue(in: json) ?? ""
                    }

                    if !resolved.isEmpty {
                        UserDefaults.standard.set(resolved, forKey: "BbrokerId")
                        debugPrint("✅ [Service] brokerId cached: \(resolved)")
                    }

                    if let domain = json["domain"] as? String, !domain.isEmpty {
                        UserDefaults.standard.set(domain, forKey: "Bdomain")
                        debugPrint("✅ [Service] domain cached: \(domain)")
                    }

                    if let valueArr = json["value"] as? [[String: Any]],
                       let first = valueArr.first {
                        if let exchange = first["exchange"] as? String {
                            UserDefaults.standard.set(exchange, forKey: "BexchangeName")
                        }
                        if let company = first["company_name"] as? String {
                            UserDefaults.standard.set(company, forKey: "BcompanyName")
                        }
                        if let logo = first["exchange_logo"] as? String {
                            UserDefaults.standard.set(logo, forKey: "BexchangeLogo")
                        }
                    }
                }

                DispatchQueue.main.async { completion(resolved) }
            }
            } // end main.async
        } // end global.async
    }

    private static func findPAYBValue(in dict: [String: Any]) -> String? {
        for value in dict.values {
            if let str = value as? String, str.hasPrefix("PAYB"), !str.isEmpty { return str }
            if let nested = value as? [String: Any], let found = findPAYBValue(in: nested) { return found }
            if let arr = value as? [[String: Any]] {
                for item in arr {
                    if let found = findPAYBValue(in: item) { return found }
                }
            }
        }
        return nil
    }

    private func fireSendPaymentLink(
        paymentOrderId: String,
        paymentLink:    String,
        emails:         [String],
        brokerId:       String,
        completion:     @escaping (Swift.Result<Void, Error>) -> Void
    ) {
        let url = "\(API.base)/payment/send-payment-link"

        let body: [String: Any] = [
            "merchantId":     API.merchantId,
            "emails":         emails,
            "paymentLink":    paymentLink,
            "paymentOrderId": paymentOrderId,
            "brokerId":       brokerId
        ]

        debugPrint("────────────────────────────────────")
        debugPrint("📡 [Service] fireSendPaymentLink")
        debugPrint("   URL     : \(url)")
        debugPrint("   brokerId: \(brokerId)")
        debugPrint("   emails  : \(emails)")
        debugPrint("────────────────────────────────────")

        Alamofire
            .request(url, method: .post, parameters: body,
                     encoding: JSONEncoding.default, headers: authHeaders)
            .validate()
            .responseData { response in
                debugPrint("📥 [Service] sendPaymentLink HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(300))")
                }
                switch response.result {
                case .success:
                    DispatchQueue.main.async { completion(.success(())) }
                case .failure(let error):
                    debugPrint("❌ [Service] sendPaymentLink: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
