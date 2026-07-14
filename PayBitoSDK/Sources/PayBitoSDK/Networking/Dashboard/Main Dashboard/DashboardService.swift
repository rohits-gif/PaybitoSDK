////
////  DashboardService.swift
////  Trading_Terminal
////

////
// Online Swift compiler to run Swift program online
// Print "Try programiz.pro" message
// DashboardService.swift
import Alamofire
import Foundation

struct ConfigurationD {
    static let API_BASE_URL = "https://service.hashcashconsultants.com/billbitcoins-v2"  // adjust if needed
    static let SITENAME_ALIAS = "billbitcoins"  // your sitename alias
}

// MARK: - Helper extension to convert Encodable to Dictionary
extension Encodable {
    func asDictionaryD() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw NSError(domain: "EncodingError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert to dictionary"])
        }
        return dictionary
    }
}

class DashboardService {
    
    private let baseURL = ConfigurationD.API_BASE_URL
    private let sitenameAlias = ConfigurationD.SITENAME_ALIAS
    
    private func getHeaders() -> HTTPHeaders {
        var headers = HTTPHeaders()
        headers["Content-Type"] = "application/json"
        headers["Origin"]  = "https://trade.paybito.com"
        headers["Referer"] = "https://trade.paybito.com/"
        
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            headers["Authorization"] = "bearer \(token)"
        }
        
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            headers["Uuid"] = uuid
        }
        
        return headers
    }
    
    // MARK: - Get Dashboard Payment History
    func getDashboardPaymentHistory(merchantId: Int, completion: @escaping (Swift.Result<DashboardPaymentHistoryResponse, Error>) -> Void) {
        let url = "\(baseURL)/payment/getPaymentHistory/\(merchantId)"
        print("📊 [Service] GET \(url)")
        
        Alamofire.request(url, method: .get, headers: getHeaders())
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let json):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                        let decoder = JSONDecoder()
                        let result = try decoder.decode(DashboardPaymentHistoryResponse.self, from: jsonData)
                        print(" [Service] Dashboard metrics received: \(result.status ?? "no status")")
                        completion(.success(result))
                    } catch {
                        print(" [Service] JSON decoding error: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print(" [Service] Dashboard metrics error: \(error)")
                    if let data = response.data, let body = String(data: data, encoding: .utf8) {
                        print("Response body: \(body)")
                    }
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Get Merchant Status
    // getMerchantStatus — only merchant_id in body
    func getMerchantStatus(merchantId: String, completion: @escaping (Swift.Result<MerchantStatResponse, Error>) -> Void) {
        let url = "\(baseURL)/merchant/FetchMerchantStatus"
        let params: [String: Any] = ["merchant_id": merchantId]  // ✅ NO uuid
        
        print("[Service] POST \(url)")
        
        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: getHeaders())
            .validate()
            .responseJSON { response in
                if let data = response.data, let body = String(data: data, encoding: .utf8) {
                    print("🏪 [Service] Raw: \(body)")
                }
                switch response.result {
                case .success(let json):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: json)
                        let array = try JSONDecoder().decode([MerchantStatResponse].self, from: jsonData)
                        if let first = array.first {
                            print("[Service] Merchant status: error=\(first.error ?? "nil"), verified=\(first.basic_verification_submitted ?? "0"), wallet=\(first.crypto_address_added ?? "0")")
                            completion(.success(first))
                        } else {
                            completion(.failure(NSError(domain: "", code: -1,
                                userInfo: [NSLocalizedDescriptionKey: "Empty response"])))
                        }
                    } catch {
                        print("[Service] Merchant decode error: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("[Service] Merchant status error: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    // MARK: - Get User Details
    func getUserDetails(completion: @escaping (Swift.Result<UserDetailsResponse, Error>) -> Void) {
        let url = "\(baseURL)/kyc/GetUserDetails"
        
        let exchangeUUIDKeys = ["Bexchange_uuid", "billbitcoins_exchange_uuid", "Buuid"]
        var uuid: String?
        for key in exchangeUUIDKeys {
            if let val = UserDefaults.standard.string(forKey: key), !val.isEmpty {
                uuid = val
                print("✅ [Service] Exchange UUID found at key: \(key) → \(val)")
                break
            }
        }
        
        guard let uuid = uuid else {
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing exchange UUID"])))
            return
        }
        
        let params: [String: Any] = ["uuid": uuid]
        print("👤 [Service] POST \(url) with uuid: \(uuid)")
        
        // ✅ THIS WAS MISSING — the actual API call
        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: getHeaders())
        .validate()
        .responseJSON { response in
            switch response.result {
            case .success(let json):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                    // ✅ Print raw response to see actual format
                    print("👤 [Service] Raw response:", String(data: jsonData, encoding: .utf8) ?? "nil")
                    let result = try JSONDecoder().decode(UserDetailsResponse.self, from: jsonData)
                    print("👤 [Service] User details decoded successfully")
                    completion(.success(result))
                } catch {
                    print("👤 [Service] Decode error: \(error)")
                    // ✅ Print raw data to diagnose format mismatch
                    if let data = response.data, let body = String(data: data, encoding: .utf8) {
                        print("👤 [Service] Raw body: \(body)")
                    }
                    completion(.failure(error))
                }
            case .failure(let error):
                print("👤 [Service] Request error: \(error)")
                if let data = response.data, let body = String(data: data, encoding: .utf8) {
                    print("👤 [Service] Error body: \(body)")
                }
                completion(.failure(error))
            }
        }
    }
    
    
    // MARK: - Get Transactions by Filter (FIXED)
    func getTransactionsByFilter(request: TransactionFilterRequest, completion: @escaping (Swift.Result<TransactionResponse, Error>) -> Void) {
        let url = "\(baseURL)/api/transactions/byFilter"
        print("📋 [Service] POST \(url) - page \(request.page), search: \(request.search)")
        
        do {
            let parameters = try request.asDictionary()
            Alamofire.request(url, method: .post, parameters: parameters,
                              encoding: JSONEncoding.default, headers: getHeaders())
            .validate()
            .responseJSON { response in
                // ✅ Always print raw body first
                if let data = response.data, let body = String(data: data, encoding: .utf8) {
                    print("📋 [Service] Raw body: \(body.prefix(500))")
                }
                switch response.result {
                case .success(let json):
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: json, options: [])
                        let result = try JSONDecoder().decode(TransactionResponse.self, from: jsonData)
                        print("📋 [Service] Transactions received: \(result.transactions?.count ?? 0) items")
                        completion(.success(result))
                    } catch {
                        print("📋 [Service] Decode error: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("📋 [Service] Request failed: \(error)")
                    if let data = response.data, let body = String(data: data, encoding: .utf8) {
                        print("📋 [Service] Error body: \(body)")
                    }
                    completion(.failure(error))
                }
            }
        } catch {
            print("📋 [Service] Encode error: \(error)")
            completion(.failure(error))
        }
    }
    
    // MARK: - Fetch Crypto Balances
    func fetchUsdBtcLedgerAmount(merchantId: String, completion: @escaping (Swift.Result<CryptoBalanceResponse, Error>) -> Void) {
        let url = "\(baseURL)/MerchantDashboard/FetchUsdBtcLedgerAmount"
        let params: [String: Any] = ["merchant_id": merchantId]
        print("💰 [Service] POST \(url) with merchantId: \(merchantId)")
        
        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: getHeaders())
        .responseData { response in  // ✅ use responseData — sees everything raw
            
            print("💰 Status: \(response.response?.statusCode ?? -1)")
            
            guard let data = response.data else {
                print("💰 NO DATA received at all")
                completion(.failure(NSError(domain: "", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            let rawString = String(data: data, encoding: .utf8) ?? "non-utf8"
            print("💰 Raw body: \(rawString)")
            
            // Try to parse as JSON
            guard let json = try? JSONSerialization.jsonObject(with: data) else {
                print("💰 Not valid JSON")
                completion(.failure(NSError(domain: "", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Not valid JSON"])))
                return
            }
            
            print("💰 JSON type: \(type(of: json))")  // Array or Dictionary?
            
            let jsonData = try! JSONSerialization.data(withJSONObject: json)
            
            // Try array
            if let array = try? JSONDecoder().decode([CryptoBalanceResponse].self, from: jsonData),
               let first = array.first {
                print("💰 Decoded as ARRAY ✅, assets: \(first.coin_balance?.count ?? 0)")
                completion(.success(first))
                return
            }
            
            // Try single object
            if let single = try? JSONDecoder().decode(CryptoBalanceResponse.self, from: jsonData) {
                print("💰 Decoded as OBJECT ✅, assets: \(single.coin_balance?.count ?? 0)")
                completion(.success(single))
                return
            }
            
            // Both failed — print exact decode errors
            do {
                _ = try JSONDecoder().decode([CryptoBalanceResponse].self, from: jsonData)
            } catch {
                print("💰 Array decode error: \(error)")
            }
            do {
                _ = try JSONDecoder().decode(CryptoBalanceResponse.self, from: jsonData)
            } catch {
                print("💰 Object decode error: \(error)")
            }
            
            completion(.failure(NSError(domain: "", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Unexpected crypto response format"])))
        }
    }
    
    
    
    // MARK: - Fetch Broker Info (domain + brokerId)
    // GET https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo?brokerId=PAYB...
    // Saves "Bdomain" and "BbrokerId" to UserDefaults for use across the app

    func fetchBrokerWiseExchangeInfo(completion: @escaping () -> Void = {}) {
        // ── Try to get brokerId from UserDefaults first ──────────────────
        let knownKeys = ["BbrokerId", "Bbroker_id", "BexchangeId", "BbrokerCode",
                         "Bpartner_id", "BpartnerId", "BexchangeCode"]
        var brokerId = ""
        for key in knownKeys {
            if let val = UserDefaults.standard.string(forKey: key),
               val.hasPrefix("PAYB"), !val.isEmpty {
                brokerId = val
                break
            }
        }
        // Fallback: scan all UserDefaults for PAYB-prefixed value
        if brokerId.isEmpty {
            let all = UserDefaults.standard.dictionaryRepresentation()
            brokerId = all.values
                .compactMap { $0 as? String }
                .first(where: { $0.hasPrefix("PAYB") && !$0.isEmpty }) ?? ""
        }

        let url = "https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo"
        var params: [String: Any] = [:]
        if !brokerId.isEmpty {
            params["brokerId"] = brokerId
        }

        print("📡 [DashboardService] getBrokerWiseExchangeInfo brokerId=\(brokerId)")

        Alamofire.request(url, method: .get, parameters: params,
                          encoding: URLEncoding.queryString, headers: getHeaders())
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("📥 [DashboardService] getBrokerWiseExchangeInfo raw: \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let json):
                    guard let dict = json as? [String: Any] else {
                        completion(); return
                    }

                    // ── Save domain ──────────────────────────────────────
                    if let domain = dict["domain"] as? String, !domain.isEmpty {
                        UserDefaults.standard.set(domain, forKey: "Bdomain")
                        print("✅ [DashboardService] domain cached: \(domain)")
                    }

                    // ── Save brokerId from value[0].broker_id ─────────────
                    if let valueArr = dict["value"] as? [[String: Any]],
                       let first = valueArr.first {
                        let bid = (first["broker_id"] as? String) ??
                                  (first["brokerId"]  as? String) ?? ""
                        if !bid.isEmpty {
                            UserDefaults.standard.set(bid, forKey: "BbrokerId")
                            print("✅ [DashboardService] brokerId cached: \(bid)")
                        }
                        // ── Save exchange info extras ──────────────────────
                        if let exchange = first["exchange"] as? String {
                            UserDefaults.standard.set(exchange, forKey: "BexchangeName")
                        }
                        if let logo = first["exchange_logo"] as? String {
                            UserDefaults.standard.set(logo, forKey: "BexchangeLogo")
                        }
                        if let company = first["company_name"] as? String {
                            UserDefaults.standard.set(company, forKey: "BcompanyName")
                        }
                    }

                    completion()

                case .failure(let error):
                    print("❌ [DashboardService] getBrokerWiseExchangeInfo failed: \(error.localizedDescription)")
                    completion()
                }
            }
    }
    
    
    
    
    
    
}
