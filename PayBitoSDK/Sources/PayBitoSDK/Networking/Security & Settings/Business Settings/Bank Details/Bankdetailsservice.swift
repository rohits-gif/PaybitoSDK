//
//  BankDetailsService.swift
//  Trading_Terminal
//

import Foundation
import Alamofire

// MARK: - API Constants

private enum BDAPI {
    static let base               = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc"
    static let getUserBankDetails = "\(base)/GetUserBankDetails"
}

// MARK: - Service Protocol

protocol BankDetailsServiceProtocol {
    func fetchBankDetails(
        uuid: String,
        completion: @escaping (Swift.Result<BankDetailsResponse, Error>) -> Void
    )
}

// MARK: - Service Implementation

final class BankDetailsService: BankDetailsServiceProtocol {
    var currentUUID: String = ""
    
    static let shared = BankDetailsService()
    private init() {}
    
    // MARK: - Auth Headers — matches DashboardService.getHeaders() exactly
    
    private func getHeaders() -> [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Origin":       "https://trade.paybito.com",
            "Referer":      "https://trade.paybito.com/"
        ]
        
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "bearer \(token)"
            debugPrint("🔑 [BDService] Token attached")
        } else {
            debugPrint("❌ [BDService] Token missing — request may be rejected")
        }
        
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["Uuid"] = uuid
            debugPrint("🆔 [BDService] UUID header: \(uuid)")
        } else {
            debugPrint("❌ [BDService] UUID missing from headers")
        }
        
        return h
    }
    
    // MARK: - UUID Resolution — matches DashboardService.getUserDetails() exactly
    //
    // Priority: caller-supplied → Bexchange_uuid → billbitcoins_exchange_uuid → Buuid
    
        private func resolveUUID(callerUUID: String) -> String? {
            if !callerUUID.isEmpty {
                debugPrint("🆔 [BDService] UUID from caller: \(callerUUID)")
                return callerUUID
            }
            let keys = ["Bexchange_uuid", "billbitcoins_exchange_uuid", "Buuid"]
            for key in keys {
                if let val = UserDefaults.standard.string(forKey: key), !val.isEmpty {
                    debugPrint("🆔 [BDService] UUID resolved from key '\(key)': \(val)")
                    return val
                }
            }
            return nil
        }
    
    // MARK: - Fetch Bank Details
    
    func fetchBankDetails(
        uuid: String,
        completion: @escaping (Swift.Result<BankDetailsResponse, Error>) -> Void
    ) {
        guard let resolvedUUID = resolveUUID(callerUUID: uuid) else {
            debugPrint("❌ [BDService] UUID missing — aborting fetch")
            let err = NSError(
                domain: "BankDetailsService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing UUID — cannot fetch bank details"]
            )
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        let params: [String: Any] = ["uuid": resolvedUUID]

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [BDService] fetchBankDetails")
        debugPrint("   URL     : \(BDAPI.getUserBankDetails)")
        debugPrint("   Params  : \(params)")
        debugPrint("────────────────────────────────────────")

        // ✅ THE MISSING NETWORK CALL
        Alamofire
            .request(
                BDAPI.getUserBankDetails,
                method: .post,
                parameters: params,
                encoding: JSONEncoding.default,
                headers: getHeaders()
            )
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [BDService] HTTP \(response.response?.statusCode ?? -1)")

                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }

                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(BankDetailsResponse.self, from: data)
                        debugPrint("✅ [BDService] Decoded — bankDetailsId: \(decoded.bankDetails?.bankDetailsId ?? -1)")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ [BDService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [BDService] Network error: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
