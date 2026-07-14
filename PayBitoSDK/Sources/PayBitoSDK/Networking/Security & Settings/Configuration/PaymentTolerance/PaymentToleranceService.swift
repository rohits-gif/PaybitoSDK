//  PaymentToleranceService.swift

import Foundation
import Alamofire

class PaymentToleranceService {

    static let shared = PaymentToleranceService()
    private init() {}

    private let webService = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // MARK: - Auth Headers (copied exactly from LimitsAPIService.authHeaders)
    private func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        print("🔑 [PT] token prefix: \(String(token.prefix(20)))... uuid: \(uuid)")
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

    // MARK: - Extract merchantId (copied exactly from LimitsAPIService.extractMerchantId)
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

    // MARK: - FetchUsdBtcLedgerAmount
    func fetchLedgerAmount(
        completion: @escaping (Swift.Result<PTolerance.LedgerResponse, PTolerance.PTServiceError>) -> Void
    ) {
        let url        = "\(webService)/MerchantDashboard/FetchUsdBtcLedgerAmount"
        let merchantId = extractMerchantId()
        let params: [String: Any] = ["merchant_id": merchantId]

        print("📡 [PT] fetchLedgerAmount → merchantId: \(merchantId)")

        Alamofire
            .request(url,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.default,
                     headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [PT] fetchLedgerAmount status: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("📥 [PT] fetchLedgerAmount response: \(raw)")
                }
                self.handleResponseData(response, completion: completion)
            }
    }

    // MARK: - GetMerchant_settings
    func getMerchantSettings(
        currencyId: String,
        completion: @escaping (Swift.Result<PTolerance.MerchantSettingsResponse, PTolerance.PTServiceError>) -> Void
    ) {
        let url        = "\(webService)/merchant/GetMerchant_settings"
        let merchantId = extractMerchantId()
        let params: [String: Any] = [
            "merchant_id": merchantId,
            "currency_id": currencyId
        ]

        print("📡 [PT] getMerchantSettings → merchantId: \(merchantId) currencyId: \(currencyId)")

        Alamofire
            .request(url,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.default,
                     headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [PT] getMerchantSettings status: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("📥 [PT] getMerchantSettings response: \(raw)")
                }
                self.handleResponseData(response, completion: completion)
            }
    }

    // MARK: - SetMerchant_settings
    func setMerchantSettings(
        payload: PTolerance.SetSettingsPayload,
        completion: @escaping (Swift.Result<PTolerance.SetSettingsResponse, PTolerance.PTServiceError>) -> Void
    ) {
        let url        = "\(webService)/merchant/SetMerchant_settings"
        let merchantId = extractMerchantId()
        let params: [String: Any] = [
            "merchant_id"            : merchantId,
            "currency_id"            : payload.currency_id,
            "overpayment_tolerance"  : payload.overpayment_tolerance,
            "underpayment_tolerance" : payload.underpayment_tolerance,
            "accept_underpayments"   : payload.accept_underpayments,
            "accept_overpayments"    : payload.accept_overpayments
        ]

        print("📡 [PT] setMerchantSettings → merchantId: \(merchantId) payload: \(params)")

        Alamofire
            .request(url,
                     method: .post,
                     parameters: params,
                     encoding: JSONEncoding.default,
                     headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [PT] setMerchantSettings status: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("📥 [PT] setMerchantSettings response: \(raw)")
                }
                self.handleResponseData(response, completion: completion)
            }
    }

    // MARK: - Generic response handler (mirrors LimitsAPIService pattern)
    private func handleResponseData<T: Decodable>(
        _ response: DataResponse<Data>,
        completion: @escaping (Swift.Result<T, PTolerance.PTServiceError>) -> Void
    ) {
        switch response.result {
        case .success(let data):
            do {
                // Try array shape first
                if let list = try? JSONDecoder().decode([T].self, from: data),
                   let first = list.first {
                    print("✅ [PT] Decoded as array[\(T.self)]")
                    completion(.success(first))
                    return
                }
                // Fallback: single object
                let single = try JSONDecoder().decode(T.self, from: data)
                print("✅ [PT] Decoded as single[\(T.self)]")
                completion(.success(single))
            } catch {
                print("❌ [PT] Decode error for \(T.self): \(error)")
                completion(.failure(.apiError(error.localizedDescription)))
            }
        case .failure(let error):
            completion(.failure(.apiError(error.localizedDescription)))
        }
    }
}

// MARK: - Base64 padding (same helper as LimitsAPIService)
private extension String {
    var paddedBase64: String {
        var s = self
        let r = s.count % 4
        if r != 0 { s += String(repeating: "=", count: 4 - r) }
        return s
    }
}
