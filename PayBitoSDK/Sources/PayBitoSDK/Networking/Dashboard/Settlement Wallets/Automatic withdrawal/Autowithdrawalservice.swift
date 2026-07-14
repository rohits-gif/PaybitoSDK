//
//  Autowithdrawalservice.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 10/06/26.
//

import Foundation
import Alamofire

final class AutoWithdrawalService {

    static let shared = AutoWithdrawalService()
    private init() {}

    private let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    private var authHeaders: [String: String] {

        var headers: [String: String] = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"),
           !token.isEmpty {
            headers["Authorization"] = "bearer \(token)"
        }

        if let uuid = UserDefaults.standard.string(forKey: "Buuid"),
           !uuid.isEmpty {
            headers["UUID"] = uuid
        }

        return headers
    }
    private func extractMerchantId() -> Int {
        if let mid = UserDefaults.standard.value(forKey: "merchantId") as? Int { return mid }
        if let mid = UserDefaults.standard.value(forKey: "BMerchantId") as? Int { return mid }
        if let mid = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") { return mid }
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
        print("⚠️ [PT] Could not extract merchantId, using 0")
        return 0
    }

    // MARK: - Fetch coins (ledger)
    // MARK: - Fetch coins (ledger)
    func fetchCoins(
        merchantId: String,
        completion: @escaping (Swift.Result<[AutoWithdrawal.Coin], Error>) -> Void
    ) {

        let url = "\(base)/MerchantDashboard/FetchUsdBtcLedgerAmount"

        let params: [String: Any] = [
            "merchant_id": String(extractMerchantId())
        ]

        print("📡 AutoWithdrawal fetchCoins")
        print("📡 URL:", url)
        print("📡 Params:", params)

        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders
        )
        .validate(statusCode: 200..<300)
        .responseData { response in

            print("📡 Status:", response.response?.statusCode ?? -1)

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("📥 fetchCoins:", raw.prefix(500))
            }

            switch response.result {

            case .failure(let error):
                completion(.failure(error))

            case .success(let data):

                do {

                    let arr = try JSONDecoder().decode(
                        [BillingProfile.LedgerData].self,
                        from: data
                    )

                    guard let first = arr.first else {
                        completion(.success([]))
                        return
                    }

                    let allCoins =
                        (first.coin_balance ?? []) +
                        (first.rolling_reserve_balance ?? [])

                    let uniqueCoins = Dictionary(
                        allCoins.map { ($0.currency_id, $0) },
                        uniquingKeysWith: { first, _ in first }
                    ).values

                    let coins = Array(uniqueCoins)
                        .filter { $0.currency_type == "2" }
                        .map {
                            AutoWithdrawal.Coin(
                                id: $0.currency_id,
                                currencyCode: $0.currency_code,
                                currencyName: $0.currency_name,
                                logo: $0.logo ?? ""
                            )
                        }
                        .sorted { $0.currencyCode < $1.currencyCode }

                    print("✅ AutoWithdrawal coins:", coins.count)

                    completion(.success(coins))

                } catch {

                    print("❌ Decode failed:", error)

                    if let raw = String(data: data, encoding: .utf8) {
                        print(raw)
                    }

                    completion(.failure(error))
                }
            }
        }
    }
    // MARK: - Get crypto address
    func getCryptoAddress(currencyId: Int, merchantId: String,
                          completion: @escaping (Swift.Result<[AutoWithdrawal.CryptoAddressEntry], Error>) -> Void) {
        let url = "\(base)/merchant/getCryptoAddress"
        let params: [String: Any] = ["currency_id": currencyId, "merchant_id": merchantId]

        Alamofire.request(url, method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: authHeaders)
            .responseData { response in
                switch response.result {
                case .failure(let e): completion(.failure(e))
                case .success(let data):
                    let entries = (try? JSONDecoder().decode([AutoWithdrawal.CryptoAddressEntry].self, from: data)) ?? []
                    completion(.success(entries))
                }
            }
    }

    // MARK: - Get user details (bank status)
    func getUserDetails(completion: @escaping (Swift.Result<AutoWithdrawal.UserDetailsResponse, Error>) -> Void) {
        let url = "\(base)/kyc/GetUserDetails"

        Alamofire.request(url, method: .get,
                          headers: authHeaders)
            .responseData { response in
                switch response.result {
                case .failure(let e): completion(.failure(e))
                case .success(let data):
                    if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let status = obj["bankDetailsStatus"] as? Int
                        completion(.success(.init(bankDetailsStatus: status)))
                    } else {
                        completion(.failure(NSError(domain: "Parse", code: 0)))
                    }
                }
            }
    }

    // MARK: - Save / update rule
    func saveRule(id: Int,
                  merchantId: Int,
                  withdrawalType: String,
                  amountInUSD: Double,
                  frequencyDays: Int,
                  currencyIds: String,
                  completion: @escaping (Swift.Result<AutoWithdrawal.SaveResponse, Error>) -> Void) {
        let url = "\(base)/merchant/auto-withdrawal"
        let params: [String: Any] = [
            "id": id,
            "merchantId": merchantId,
            "withdrawalType": withdrawalType,
            "amountInUSD": amountInUSD,
            "frequencyDays": frequencyDays,
            "currencyIds": currencyIds
        ]

        Alamofire.request(url, method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: authHeaders)
        .responseData { response in

            switch response.result {

            case .failure(let e):
                completion(.failure(e))

            case .success(let data):

                print("SAVE RULE RESPONSE:")
                print(String(data: data, encoding: .utf8) ?? "nil")

                if let res = try? JSONDecoder().decode(
                    AutoWithdrawal.SaveResponse.self,
                    from: data
                ) {

                    completion(.success(res))

                } else {

                    completion(.failure(
                        NSError(domain: "Parse", code: 0)
                    ))
                }
            }
        }
    }

    // MARK: - Get rules
    func getRules(
        merchantId: String,
        completion: @escaping (Swift.Result<[AutoWithdrawal.Rule], Error>) -> Void
    ) {

        let url = "\(base)/merchant/auto-withdrawal?merchantId=\(merchantId)"

        print("📡 getRules URL:", url)

        Alamofire.request(
            url,
            method: .get,
            headers: authHeaders
        )
        .responseData { response in

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {

                print("📥 getRules response:")
                print(raw)
            }

            switch response.result {

            case .failure(let error):
                completion(.failure(error))

            case .success(let data):

                do {

                    let res = try JSONDecoder().decode(
                        AutoWithdrawal.GetRulesResponse.self,
                        from: data
                    )

                    completion(
                        .success(
                            res.data?.autoWithdrawalDetails ?? []
                        )
                    )

                } catch {

                    print("❌ getRules decode failed:", error)

                    if let raw = String(data: data, encoding: .utf8) {
                        print(raw)
                    }

                    completion(.failure(error))
                }
            }
        }
    }

    // MARK: - Delete rule
    func deleteRule(id: Int, merchantId: Int,
                    completion: @escaping (Swift.Result<AutoWithdrawal.DeleteResponse, Error>) -> Void) {
        let url = "\(base)/api/v1/merchant/auto-withdrawal/delete"
        let params: [String: Any] = ["id": id, "merchantId": merchantId]

        Alamofire.request(url, method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: authHeaders)
            .responseData { response in
                switch response.result {
                case .failure(let e): completion(.failure(e))
                case .success(let data):
                    if let res = try? JSONDecoder().decode(AutoWithdrawal.DeleteResponse.self, from: data) {
                        completion(.success(res))
                    } else {
                        completion(.failure(NSError(domain: "Parse", code: 0)))
                    }
                }
            }
    }
}
private extension String {
    var paddedBase64: String {
        var s = self
        let r = s.count % 4
        if r != 0 { s += String(repeating: "=", count: 4 - r) }
        return s
    }
}
