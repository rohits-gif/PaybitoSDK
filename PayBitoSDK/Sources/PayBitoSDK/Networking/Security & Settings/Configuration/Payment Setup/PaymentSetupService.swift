// MARK: - NetworkService (Alamofire 4)

import Foundation
import Alamofire

// MARK: - Token / Auth Helpers
enum AuthManager {
    static var token: String { UserDefaults.standard.string(forKey: "Baccess_token") ?? "" }
    static var uuid: String  { UserDefaults.standard.string(forKey: "Buuid") ?? "" }
    static var merchantId: String { String(extractMerchantId()) }

    static func extractMerchantId() -> Int {
        let ud = UserDefaults.standard

        // 1. Stored as Int under "merchantId"
        if let mid = ud.value(forKey: "merchantId") as? Int { return mid }

        // 2. Stored as Int under "BMerchantId"
        if let mid = ud.value(forKey: "BMerchantId") as? Int { return mid }

        // 3. Stored as String under "merchantId"
        // NOTE: call object(forKey:) and cast — never call .string(forKey:) inside
        // a UserDefaults extension or it recurses infinitely → EXC_BAD_ACCESS
        if let str = ud.object(forKey: "merchantId") as? String, let mid = Int(str) { return mid }

        // 4. Stored as String under "BMerchantId"
        if let str = ud.object(forKey: "BMerchantId") as? String, let mid = Int(str) { return mid }

        // 5. JWT sub claim fallback
        let parts = token.components(separatedBy: ".")
        if parts.count >= 2,
           let data = Data(base64Encoded: parts[1].paddedBase64),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sub  = json["sub"] as? String,
           let idStr = sub.components(separatedBy: "-").first,
           let id   = Int(idStr) {
            return id
        }

        print("⚠️ PaymentGatewayService: Could not extract merchant ID")
        return 0
    }
}

// MARK: - Base64 padding helper
private extension String {
    var paddedBase64: String {
        var s = self
        let rem = s.count % 4
        if rem != 0 { s += String(repeating: "=", count: 4 - rem) }
        return s
    }
}

// MARK: - API Constants
enum APIConstants {
    static let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2"
}

// MARK: - Auth Headers (mirrors BuyerInfoService.authHeaders())
private func makeAuthHeaders() -> HTTPHeaders {
    let token = AuthManager.token
    let uuid  = AuthManager.uuid

    print("========== PAYMENT GATEWAY AUTH ==========")
    print("TOKEN PREFIX: \(String(token.prefix(30)))")
    print("UUID: \(uuid)")
    print("==========================================")

    return [
        "Authorization": "bearer \(token)",
        "UUID":          uuid,
        "Content-Type":  "application/json",
        "Accept":        "application/json, text/plain, */*",
        "Origin":        "https://trade.paybito.com",
        "Referer":       "https://trade.paybito.com/",
        "User-Agent":    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15"
    ]
}

// MARK: - PaymentGatewayService
final class PaymentGatewayService {

    static let shared = PaymentGatewayService()
    private init() {}

    private let base = APIConstants.baseURL

    // MARK: getAllGateways
    func getAllGateways(
        merchantId: String,
        completion: @escaping (Swift.Result<GetAllGatewaysResponse, Error>) -> Void
    ) {
        let params: [String: Any] = ["merchantId": merchantId]
        let url = "\(base)/merchant/getAllPaymentGateway"

        print("📡 getAllGateways URL: \(url), merchantId: \(merchantId)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: makeAuthHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("getAllGateways STATUS: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("getAllGateways RESPONSE: \(raw)")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(GetAllGatewaysResponse.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: addGateway
    func addGateway(
        request: AddGatewayRequest,
        completion: @escaping (Swift.Result<AddGatewayResponse, Error>) -> Void
    ) {
        guard let params = request.toRequestDictionary() else {
            completion(.failure(NSError(domain: "EncodingError", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }
        let url = "\(base)/merchant/addPaymentGateway"
        print("📡 addGateway URL: \(url)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: makeAuthHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("addGateway STATUS: \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("addGateway RESPONSE: \(raw)")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(AddGatewayResponse.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: updateGateway (Stripe / Paypal / KurvPay / HMS / NMI — string isActive)
    func updateGateway(
        request: UpdateGatewayRequest,
        completion: @escaping (Swift.Result<BaseResponse, Error>) -> Void
    ) {
        guard let params = request.toRequestDictionary() else {
            completion(.failure(NSError(domain: "EncodingError", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }
        let url = "\(base)/merchant/updatePaymentGateway"
        print("📡 updateGateway URL: \(url)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: makeAuthHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("updateGateway STATUS: \(response.response?.statusCode ?? -1)")
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(BaseResponse.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: updateGateway (netbilling / cardflo — numeric isActive)
    func updateGateway(
        request: UpdateGatewayRequestNumericActive,
        completion: @escaping (Swift.Result<BaseResponse, Error>) -> Void
    ) {
        guard let params = request.toRequestDictionary() else {
            completion(.failure(NSError(domain: "EncodingError", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }
        let url = "\(base)/merchant/updatePaymentGateway"
        print("📡 updateGateway(numeric) URL: \(url)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: makeAuthHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("updateGateway(numeric) STATUS: \(response.response?.statusCode ?? -1)")
                if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                    print("updateGateway(numeric) RESPONSE: \(raw)")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(BaseResponse.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: deleteGateway (secretKeyV4 optional — required for KurvPay / HMS / NMI)
    func deleteGateway(
        merchantId: String,
        gatewayId: Int,
        secretKeyV4: String? = nil,
        completion: @escaping (Swift.Result<BaseResponse, Error>) -> Void
    ) {
        let req = DeleteGatewayRequest(
            merchantId: merchantId,
            id: String(gatewayId),
            secretKeyV4: secretKeyV4
        )
        guard let params = req.toRequestDictionary() else {
            completion(.failure(NSError(domain: "EncodingError", code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Failed to encode request"])))
            return
        }
        let url = "\(base)/merchant/deletePaymentGateway"
        print("📡 deleteGateway URL: \(url)")

        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: makeAuthHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in

                print("deleteGateway STATUS: \(response.response?.statusCode ?? -1)")

                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    print("deleteGateway RESPONSE: \(raw)")
                }

                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(BaseResponse.self, from: data)
                        completion(.success(decoded))
                    } catch {
                        completion(.failure(error))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - Encodable → Dictionary
// Named toRequestDictionary() to avoid conflict with any other extensions in the project
extension Encodable {
    func toRequestDictionary() -> [String: Any]? {
        guard
            let data = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return dict
    }
}
