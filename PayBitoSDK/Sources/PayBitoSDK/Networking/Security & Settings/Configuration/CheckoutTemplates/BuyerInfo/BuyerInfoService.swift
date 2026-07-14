import Foundation
import Alamofire

final class BuyerInfoService {

    static let shared = BuyerInfoService()
    private init() {}

    private let base = "https://service.hashcashconsultants.com/billbitcoins-v2"

    // MARK: AUTH HEADERS
    private func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid = UserDefaults.standard.string(forKey: "Buuid") ?? ""

        print("========== BUYER INFO AUTH ==========")
        print("TOKEN PREFIX: \(String(token.prefix(30)))")
        print("UUID: \(uuid)")
        print("====================================")

        return [
            "Authorization": "bearer \(token)",
            "UUID": uuid,
            "Content-Type": "application/json",
            "Accept": "application/json, text/plain, */*",
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15"
        ]
    }

    // MARK: MERCHANT ID
    private func extractMerchantId() -> Int {
        if let mid = UserDefaults.standard.value(forKey: "merchantId") as? Int {
            return mid
        }

        if let mid = UserDefaults.standard.value(forKey: "BMerchantId") as? Int {
            return mid
        }

        if let mid = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") {
            return mid
        }

        if let mid = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") {
            return mid
        }

        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")

        if parts.count >= 2,
           let data = Data(base64Encoded: parts[1].paddedBase64),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sub = json["sub"] as? String,
           let idStr = sub.components(separatedBy: "-").first,
           let id = Int(idStr) {
            return id
        }

        print("⚠️ Could not extract merchant ID")
        return 0
    }

    // MARK: FETCH
    func fetchAll(
        completion: @escaping (Result<[BuyerInfoProfile]>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let url = "\(base)/buyer-information/\(merchantId)"

        print("📡 FETCH URL: \(url)")

        Alamofire.request(
            url,
            method: .get,
            headers: authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in

            print("FETCH STATUS: \(response.response?.statusCode ?? -1)")

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("FETCH RESPONSE: \(raw)")
            }

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(
                        BuyerInfoListResponse.self,
                        from: data
                    )

                    if decoded.error != "0" {
                        let err = NSError(
                            domain: "API",
                            code: 0,
                            userInfo: [
                                NSLocalizedDescriptionKey:
                                    decoded.message ?? "Fetch failed"
                            ]
                        )
                        completion(.failure(err))
                        return
                    }

                    let profiles = (decoded.data ?? []).map {
                        BuyerInfoProfile.from(raw: $0)
                    }

                    completion(.success(profiles))

                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: CREATE
    func save(
        profile: BuyerInfoProfile,
        completion: @escaping (Result<Void>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let payload = profile.toCreatePayload(merchantId: "\(merchantId)")
        let url = "\(base)/buyer-information"

        print("📡 CREATE URL: \(url)")
        print("📦 CREATE PAYLOAD: \(payload)")

        Alamofire.request(
            url,
            method: .post,
            parameters: payload.toDictionary(),
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in

            print("CREATE STATUS: \(response.response?.statusCode ?? -1)")

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("CREATE RESPONSE: \(raw)")
            }

            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: UPDATE
    func update(
        id: Int,
        profile: BuyerInfoProfile,
        completion: @escaping (Result<Void>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let payload = profile.toUpdatePayload(merchantId: "\(merchantId)")
        let url = "\(base)/buyer-information/update/\(id)"

        print("📡 UPDATE URL: \(url)")

        Alamofire.request(
            url,
            method: .post,
            parameters: payload.toDictionary(),
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in

            print("UPDATE STATUS: \(response.response?.statusCode ?? -1)")

            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: DELETE
    func delete(
        id: Int,
        completion: @escaping (Result<Void>) -> Void
    ) {
        let merchantId = extractMerchantId()
        let url = "\(base)/buyer-information/delete/\(id)?merchantId=\(merchantId)"

        print("📡 DELETE URL: \(url)")

        Alamofire.request(
            url,
            method: .post,
            headers: authHeaders()
        )
        .validate(statusCode: 200..<300)
        .responseData { response in

            print("DELETE STATUS: \(response.response?.statusCode ?? -1)")

            switch response.result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: HELPERS
private extension Encodable {
    func toDictionary() -> [String: Any] {
        guard
            let data = try? JSONEncoder().encode(self),
            let json = try? JSONSerialization.jsonObject(with: data),
            let dict = json as? [String: Any]
        else {
            return [:]
        }
        return dict
    }
}

private extension String {
    var paddedBase64: String {
        var s = self
        let rem = s.count % 4
        if rem != 0 {
            s += String(repeating: "=", count: 4 - rem)
        }
        return s
    }
}
