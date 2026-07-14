import Foundation
import Alamofire

// MARK: - API Constants

private enum PaymentDetailAPI {
    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    static var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
    }
}

// MARK: - ViewPaymentDetailService

final class ViewPaymentDetailService {

    static let shared = ViewPaymentDetailService()
    private init() {}

    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type":     "application/json",
            "Accept":           "*/*",
            "Origin":           "https://trade.paybito.com",
            "Referer":          "https://trade.paybito.com/",
            "X-Requested-With": "XMLHttpRequest"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
            debugPrint("🔑 Token:", token)
        } else {
            debugPrint("❌ Token missing")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["Uuid"] = uuid
            debugPrint("🆔 UUID:", uuid)
        } else {
            debugPrint("❌ UUID missing")
        }
        return h
    }

    // MARK: - Fetch Payment Detail

    func fetchPaymentDetail(
        id:         String,
        merchantId: Int,
        completion: @escaping (Swift.Result<ViewPaymentDetailResponse, Error>) -> Void
    ) {
        let url = "\(PaymentDetailAPI.base)/payment/profileDetailsById"

        // Resolve merchantId
        let resolvedMerchantId: Int
        if merchantId > 0 {
            resolvedMerchantId = merchantId
        } else if let stored = UserDefaults.standard.string(forKey: "Bmerchant_id"),
                  let parsed = Int(stored), parsed > 0 {
            resolvedMerchantId = parsed
        } else {
            debugPrint("❌ [ViewPaymentDetailService] merchantId is 0 or missing")
            let err = NSError(
                domain: "ViewPaymentDetailService", code: -2,
                userInfo: [NSLocalizedDescriptionKey: "Merchant ID not available. Please log in again."]
            )
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        // ── Send full PCN string as-is: "PCN3981" not "3981"
        let params: [String: Any] = [
            "id":         id,              // ← full "PCN3981"
            "merchantId": resolvedMerchantId
        ]

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [ViewPaymentDetailService] fetchPaymentDetail")
        debugPrint("   URL        : \(url)")
        debugPrint("   id         : \(id)")
        debugPrint("   merchantId : \(resolvedMerchantId)")
        debugPrint("   Params     : \(params)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                url,
                method:     .get,
                parameters: params,
                encoding:   URLEncoding.queryString,
                headers:    authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [ViewPaymentDetailService] HTTP \(response.response?.statusCode ?? -1)")

                guard let data = response.data else {
                    let err = NSError(
                        domain: "ViewPaymentDetailService", code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "No data received"]
                    )
                    DispatchQueue.main.async { completion(.failure(err)) }
                    return
                }

                if let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }

                switch response.result {

                case .success:
                    // Decode full response (ViewPaymentDetailResponse handles Optionals robustly)
                    do {
                        let decoded = try JSONDecoder().decode(ViewPaymentDetailResponse.self, from: data)
                        
                        // Check for explicit error code (exactly matching React logic)
                        if let errCode = decoded.error, errCode != 0 {
                            let msg = decoded.message?.isEmpty == false ? decoded.message! : "Server error"
                            debugPrint("❌ [ViewPaymentDetailService] API error (error:\(errCode)): \(msg)")
                            let err = NSError(
                                domain: "ViewPaymentDetailService", code: errCode,
                                userInfo: [NSLocalizedDescriptionKey: msg]
                            )
                            DispatchQueue.main.async { completion(.failure(err)) }
                            return
                        }

                        debugPrint("✅ [ViewPaymentDetailService] OK — products:\(decoded.products?.count ?? 0) billing:\(decoded.billingProfiles?.count ?? 0)")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ [ViewPaymentDetailService] decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [ViewPaymentDetailService] network: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - Fetch Broker Domain

    func fetchBrokerDomain(completion: @escaping (String?) -> Void) {
        let brokerId = PaymentsConstants.brokerID
        let url = "\(PaymentsConstants.baseURLPayBito)home/getBrokerWiseExchangeInfo"
        let params: [String: Any] = ["brokerId": brokerId]

        Alamofire
            .request(
                url,
                method: .get,
                parameters: params,
                encoding: URLEncoding.queryString
            )
            .responseJSON { response in
                if let dict = response.result.value as? [String: Any],
                   let domain = dict["domain"] as? String, !domain.isEmpty {
                    completion(domain)
                } else {
                    completion(nil)
                }
            }
    }
}
