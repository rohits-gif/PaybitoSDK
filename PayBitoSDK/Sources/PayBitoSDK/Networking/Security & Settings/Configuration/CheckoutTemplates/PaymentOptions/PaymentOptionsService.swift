//
//  PaymentOptionsService.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 18/05/26.
//

//  PaymentOptionsService.swift

import Foundation
import Alamofire

final class PaymentOptionsService {

    static let shared = PaymentOptionsService()
    private init() {}

    private let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // MARK: - Auth (same as LimitsAPIService)
    private func headers() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        return [
            "Authorization": "bearer \(token)",
            "UUID":          uuid,
            "Content-Type":  "application/json",
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/"
        ]
    }

    private func merchantId() -> Int {
        if let v = UserDefaults.standard.value(forKey: "merchantId") as? Int {
            return v
        }

        if let v = UserDefaults.standard.value(forKey: "BMerchantId") as? Int {
            return v
        }

        if let v = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") {
            return v
        }

        if let v = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") {
            return v
        }

        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")

        if parts.count >= 2 {
            var payload = parts[1]
            let remainder = payload.count % 4
            if remainder != 0 {
                payload += String(repeating: "=", count: 4 - remainder)
            }

            if let data = Data(base64Encoded: payload),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let sub = json["sub"] as? String,
               let idString = sub.components(separatedBy: "-").first,
               let id = Int(idString) {
                print("✅ merchantId from JWT: \(id)")
                return id
            }
        }

        print("❌ merchantId fallback failed")
        return 0
    }

    // MARK: - Fetch All Profiles
    func fetchProfiles(
        completion: @escaping (Swift.Result<BillingProfile.FetchAllResponse, Error>) -> Void
    ) {
        let mid = merchantId()
        let url = "\(base)/billing-profile/\(mid)"
        print("📡 [BillingOptions] fetchProfiles → \(url)")

        Alamofire.request(url, method: .get, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 Status: \(response.response?.statusCode ?? -1)")
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 fetchProfiles: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Fetch Currencies
    func fetchCurrencies(
        completion: @escaping (Swift.Result<[BillingProfile.LedgerCoin], Error>) -> Void
    ) {
        let url    = "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"
        let params: [String: Any] = ["merchant_id": String(merchantId())]
        print("📡 [BillingOptions] fetchCurrencies")

        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 fetchCurrencies: \(raw.prefix(300))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let arr = try JSONDecoder().decode([BillingProfile.LedgerData].self, from: data)

                        if let first = arr.first {
                            let allCoins = (first.coin_balance ?? []) + (first.rolling_reserve_balance ?? [])

                            let uniqueCoins = Dictionary(
                                allCoins.map { ($0.currency_id, $0) },
                                uniquingKeysWith: { first, _ in first }
                            ).values

                            let coins = Array(uniqueCoins)
                                .filter { $0.currency_type == "2" }
                                .sorted { $0.currency_code < $1.currency_code }

                            print("✅ decoded currencies: \(coins.count)")
                            completion(.success(coins))
                        } else {
                            completion(.success([]))
                        }

                    } catch {
                        print("❌ currency decode failed: \(error)")
                        if let raw = String(data: data, encoding: .utf8) {
                            print(raw)
                        }
                        completion(.success([]))
                    }
                case .failure(let err):
                    completion(.failure(err))
                }
            }
    }

    // MARK: - Fetch Gateways
    func fetchGateways(
        completion: @escaping (Swift.Result<BillingProfile.GatewayResponse, Error>) -> Void
    ) {
        let url    = "\(base)/merchant/getAllPaymentGateway"
        let params: [String: Any] = ["merchantId": String(merchantId())]
        print("📡 [BillingOptions] fetchGateways")

        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 fetchGateways: \(raw.prefix(300))")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Fetch Payment Methods
    func fetchPaymentMethods(
        completion: @escaping (Swift.Result<BillingProfile.MethodsResponse, Error>) -> Void
    ) {
        let url = "\(base)/payment/getPaymentMethods"
        print("📡 [BillingOptions] fetchPaymentMethods")

        Alamofire.request(url, method: .get, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 fetchPaymentMethods: \(raw.prefix(300))")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Create Profile
    func createProfile(
        payload: BillingProfile.CreatePayload,
        completion: @escaping (Swift.Result<BillingProfile.MutateResponse, Error>) -> Void
    ) {
        let url = "\(base)/billing-profile/create"
        guard let params = try? payload.asDictionary() else { return }
        print("📡 [BillingOptions] createProfile → \(params)")

        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 createProfile: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Update Profile
    func updateProfile(
        payload: BillingProfile.UpdatePayload,
        completion: @escaping (Swift.Result<BillingProfile.MutateResponse, Error>) -> Void
    ) {
        let url = "\(base)/billing-profile/update"
        guard let params = try? payload.asDictionary() else { return }
        print("📡 [BillingOptions] updateProfile → \(params)")

        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 updateProfile: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Delete Profile
    func deleteProfile(
        id: Int,
        completion: @escaping (Swift.Result<BillingProfile.DeleteResponse, Error>) -> Void
    ) {
        let mid = merchantId()
        let url = "\(base)/billing-profile/delete/\(id)/\(mid)"
        print("📡 [BillingOptions] deleteProfile → \(url)")

        Alamofire.request(url, method: .post, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 deleteProfile: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Mark as Default
    func markAsDefault(
        profileId: Int,
        completion: @escaping (Swift.Result<BillingProfile.DefaultResponse, Error>) -> Void
    ) {
        let url    = "\(base)/billing-profile/markAsDefaultProfile"
        let params: [String: Any] = [
            "merchantId": String(merchantId()),
            "profileId":  String(profileId),
            "value":      1
        ]
        print("📡 [BillingOptions] markAsDefault profileId:\(profileId)")

        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: headers())
            .validate(statusCode: 200..<300)
            .responseData { response in
                if let d = response.data, let raw = String(data: d, encoding: .utf8) {
                    print("📥 markAsDefault: \(raw)")
                }
                self.decode(response, completion: completion)
            }
    }

    // MARK: - Generic decoder
    private func decode<T: Decodable>(
        _ response: DataResponse<Data>,
        completion: @escaping (Swift.Result<T, Error>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            do {
                // Try array first, then single object
                if let arr = try? JSONDecoder().decode([T].self, from: data),
                   let first = arr.first {
                    completion(.success(first)); return
                }
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            } catch {
                print("❌ [BillingOptions] Decode error: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("❌ Raw: \(raw)")
                }
                completion(.failure(error))
            }
        case .failure(let error):
            print("❌ [BillingOptions] Network error: \(error)")
            completion(.failure(error))
        }
    }
}

// MARK: - Encodable helper
private extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "Encode", code: -1)
        }
        return dict
    }
}
