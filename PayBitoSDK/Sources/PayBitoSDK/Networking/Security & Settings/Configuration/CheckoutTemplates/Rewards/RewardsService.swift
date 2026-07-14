import Foundation
import Alamofire

typealias ServiceResult<T> = Swift.Result<T, RewardsServiceError>

enum RewardsServiceError: Error, LocalizedError {
    case requestFailed(String)
    case serverError(String)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .requestFailed(let msg):
            return msg
        case .serverError(let msg):
            return msg
        case .decodingFailed:
            return "Failed to decode response"
        }
    }
}

protocol RewardsServiceProtocol {
    func fetchCampaigns(
        merchantId: Int,
        status: String,
        completion: @escaping (ServiceResult<[Campaign]>) -> Void
    )

    func togglePause(
        campaignId: Int,
        isPaused: Bool,
        completion: @escaping (ServiceResult<String>) -> Void
    )

    func deleteCampaign(
        merchantId: Int,
        campaign: Campaign,
        completion: @escaping (ServiceResult<String>) -> Void
    )
    func saveCampaign(
        payload: CreateCampaignPayload,
        action: String,
        completion: @escaping (ServiceResult<String>) -> Void
    )
}

final class RewardsService: RewardsServiceProtocol {
  

    static let shared = RewardsService()
    private init() {}

    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/campaigns"

    // MARK: Headers

    private func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid = UserDefaults.standard.string(forKey: "Buuid") ?? ""

        print("========== AUTH DEBUG ==========")
        print("TOKEN EXISTS:", !token.isEmpty)
        print("TOKEN PREFIX:", String(token.prefix(25)))
        print("UUID:", uuid)
        print("================================")

        return [
            "Authorization": "Bearer \(token)",
            "UUID": uuid,
            "Content-Type": "application/json",
            "Accept": "application/json, text/plain, */*",
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/",
            "User-Agent": "Mozilla/5.0"
        ]
    }

    // MARK: Merchant ID

    func extractMerchantId() -> Int {

        print("========== MERCHANT ID DEBUG ==========")

        if let mid = UserDefaults.standard.value(forKey: "merchantId") as? Int {
            print("merchantId found:", mid)
            return mid
        }

        if let mid = UserDefaults.standard.value(forKey: "BMerchantId") as? Int {
            print("BMerchantId found:", mid)
            return mid
        }

        if let mid = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") {
            print("merchantId string found:", mid)
            return mid
        }

        if let mid = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") {
            print("BMerchantId string found:", mid)
            return mid
        }

        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")

        if parts.count >= 2,
           let data = Data(base64Encoded: parts[1].paddedBase64),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
           let sub = json["sub"] as? String,
           let idStr = sub.components(separatedBy: "-").first,
           let id = Int(idStr) {

            print("Merchant ID extracted from JWT:", id)
            return id
        }

        print("FAILED TO EXTRACT MERCHANT ID")
        print("================================")
        return 0
    }

    // MARK: Generic GET

    private func get<T: Decodable>(
        _ url: String,
        params: Parameters = [:],
        completion: @escaping (ServiceResult<T>) -> Void
    ) {
        print("\n========== GET REQUEST ==========")
        print("URL:", url)
        print("PARAMS:", params)
        print("HEADERS:", authHeaders())
        print("=================================\n")

        Alamofire.request(
            url,
            method: .get,
            parameters: params,
            encoding: URLEncoding.default,
            headers: authHeaders()
        )
        .validate()
        .responseJSON { response in

            print("\n========== GET RESPONSE ==========")
            print("STATUS CODE:", response.response?.statusCode ?? 0)

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("RAW RESPONSE:")
                print(raw)
            }

            switch response.result {

            case .success(let json):
                print("JSON SUCCESS:", json)

                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: [])
                    let decoded = try JSONDecoder().decode(T.self, from: data)

                    print("DECODE SUCCESS")
                    print("=================================\n")

                    completion(.success(decoded))

                } catch {
                    print("DECODE ERROR:", error)
                    print("=================================\n")
                    completion(.failure(.decodingFailed))
                }

            case .failure(let error):
                print("GET ERROR:", error.localizedDescription)
                print("=================================\n")
                completion(.failure(.requestFailed(error.localizedDescription)))
            }
        }
    }

    // MARK: Generic POST

    private func post<T: Decodable>(
        _ url: String,
        params: Parameters = [:],
        completion: @escaping (ServiceResult<T>) -> Void
    ) {
        print("\n========== POST REQUEST ==========")
        print("URL:", url)
        print("PARAMS:", params)
        print("HEADERS:", authHeaders())
        print("==================================\n")

        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: authHeaders()
        )
        .validate()
        .responseJSON { response in

            print("\n========== POST RESPONSE ==========")
            print("STATUS CODE:", response.response?.statusCode ?? 0)

            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                print("RAW RESPONSE:")
                print(raw)
            }

            switch response.result {

            case .success(let json):
                print("JSON SUCCESS:", json)

                do {
                    let data = try JSONSerialization.data(withJSONObject: json, options: [])
                    let decoded = try JSONDecoder().decode(T.self, from: data)

                    print("DECODE SUCCESS")
                    print("==================================\n")

                    completion(.success(decoded))

                } catch {
                    print("DECODE ERROR:", error)
                    print("==================================\n")
                    completion(.failure(.decodingFailed))
                }

            case .failure(let error):
                print("POST ERROR:", error.localizedDescription)
                print("==================================\n")
                completion(.failure(.requestFailed(error.localizedDescription)))
            }
        }
    }

    // MARK: Fetch Campaigns

    func fetchCampaigns(
        merchantId: Int,
        status: String,
        completion: @escaping (ServiceResult<[Campaign]>) -> Void
    ) {
        let url = "\(baseURL)/merchant"

        let params: Parameters = [
            "merchantId": merchantId,
            "status": status
        ]

        print("FETCH CAMPAIGNS CALLED")

        get(url, params: params) { (result: ServiceResult<CampaignListResponse>) in
            switch result {

            case .success(let res):
                print("FETCH SUCCESS")
                print("STATUS:", res.status)
                print("MESSAGE:", res.message ?? "nil")
                print("CAMPAIGN COUNT:", res.data?.count ?? 0)

                if res.status, let data = res.data {
                    completion(.success(data.map(Campaign.from)))
                } else {
                    completion(.failure(.serverError(res.message ?? "Failed to load campaigns")))
                }

            case .failure(let error):
                print("FETCH FAILURE:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    // MARK: Pause / Activate

    func togglePause(
        campaignId: Int,
        isPaused: Bool,
        completion: @escaping (ServiceResult<String>) -> Void
    ) {
        let endpoint = isPaused ? "activate" : "pause"
        let url = "\(baseURL)/\(campaignId)/\(endpoint)"

        print("TOGGLE PAUSE CALLED")
        print("Campaign ID:", campaignId)
        print("Is Paused:", isPaused)
        print("Endpoint:", endpoint)

        post(url, params: [:]) { (result: ServiceResult<CampaignActionResponse>) in
            switch result {

            case .success(let res):
                print("TOGGLE SUCCESS:", res.message ?? "")

                if res.status {
                    completion(.success(res.message ?? "Success"))
                } else {
                    completion(.failure(.serverError(res.message ?? "Operation failed")))
                }

            case .failure(let error):
                print("TOGGLE FAILURE:", error.localizedDescription)
                completion(.failure(error))
            }
        }
    }

    // MARK: Delete Campaign

    func deleteCampaign(
        merchantId: Int,
        campaign: Campaign,
        completion: @escaping (ServiceResult<String>) -> Void
    ) {

        let url =
        "\(baseURL)/createreward?action=DELETE"

        var params: Parameters = [
            "merchantId": merchantId,
            "campaignId": campaign.id
        ]

        if let scheduleId = campaign.scheduleId {
            params["scheduleId"] = scheduleId
        }

        print("DELETE URL:", url)
        print("DELETE PARAMS:", params)

        post(
            url,
            params: params
        ) { (result: ServiceResult<CampaignActionResponse>) in

            switch result {

            case .success(let response):

                if response.status {

                    completion(
                        .success(
                            response.message ?? "DELETE SUCCESS"
                        )
                    )

                } else {

                    completion(
                        .failure(
                            .serverError(
                                response.message ?? "Delete Failed"
                            )
                        )
                    )
                }

            case .failure(let error):

                completion(
                    .failure(error)
                )
            }
        }
    }
    func saveCampaign(
        payload: CreateCampaignPayload,
        action: String,
        completion: @escaping (ServiceResult<String>) -> Void
    ) {
        
        let url = "\(baseURL)/createreward?action=\(action)"

        guard let params = payload.asDictionary() else {
            completion(
                .failure(
                    .requestFailed("Invalid Payload")
                )
            )
            return
        }

        print("\n========== SAVE CAMPAIGN ==========")
        print("ACTION:", action)
        print("URL:", url)
        print("PARAMS:", params)
        print("===================================\n")

        post(
            url,
            params: params
        ) { (result: ServiceResult<CampaignActionResponse>) in

            switch result {

            case .success(let response):

                if response.status {

                    completion(
                        .success(
                            response.message ?? "Success"
                        )
                    )

                } else {

                    completion(
                        .failure(
                            .serverError(
                                response.message ??
                                "Campaign save failed"
                            )
                        )
                    )
                }

            case .failure(let error):

                completion(
                    .failure(error)
                )
            }
        }
    }
}

private extension String {
    var paddedBase64: String {
        let remainder = count % 4
        return remainder == 0
            ? self
            : self + String(repeating: "=", count: 4 - remainder)
    }
}
