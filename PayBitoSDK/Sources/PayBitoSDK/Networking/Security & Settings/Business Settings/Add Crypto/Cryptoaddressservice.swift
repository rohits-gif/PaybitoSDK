//
//  Cryptoaddressservice.swift
//  PaymentsTerminal
//

import Foundation
import Alamofire

// MARK: - Disambiguate Swift.Result from Alamofire's Result
 typealias SResult<S> = Swift.Result<S, Error>

// MARK: - Base URL

enum AppConstants {
    static let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard"
    static let merchantBaseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant"
}

private let kBaseURL = AppConstants.baseURL
private let kMBaseURL = AppConstants.merchantBaseURL


// MARK: - Shared Headers

private func commonHeaders() -> [String: String] {
    var headers: [String: String] = [
        "Content-Type": "application/json",
        "Accept":       "application/json",
        "Origin": "https://trade.paybito.com",
        "Referer": "https://trade.paybito.com/"
    ]
    if let token = UserDefaults.standard.string(forKey: "Baccess_token"),
       !token.isEmpty {

        headers["Authorization"] = "bearer \(token)"
    }
    if let uuid = UserDefaults.standard.string(forKey: "Buuid") {
        headers["UUID"] = uuid
    }
    return headers
}

// MARK: - CryptoAddressService

final class CryptoAddressService {
    
    static let shared = CryptoAddressService()
    private init() {}
    
    // MARK: - FetchUsdBtcLedgerAmount
    
    func fetchLedgerAssets(
        merchantId: String,
        completion: @escaping (SResult<LedgerResponse>) -> Void
    ) {
        let url = "\(kBaseURL)/FetchUsdBtcLedgerAmount"
        let params: [String: Any] = ["merchant_id": merchantId]
        print("========== FETCH LEDGER ==========")
        
        print("URL =", url)
        
        print("PARAMS =", params)
        
        print("HEADERS =", commonHeaders())
        
        Alamofire.request(url, method: .post, parameters: params,
                          encoding: JSONEncoding.default, headers: commonHeaders())
        .validate()
        .responseJSON { response in
            
            switch response.result {
                
            case .success(let value):
                
                do {
                    
                    let data = try JSONSerialization.data(withJSONObject: value)
                    
                    if let json = String(data: data, encoding: .utf8) {
                        print("RAW JSON =")
                        print(json)
                    }
                    
                    let result = try JSONDecoder().decode(
                        [LedgerResponse].self,
                        from: data
                    )

                    guard let first = result.first else {
                        completion(.failure(ServiceError.emptyResponse))
                        return
                    }

                    completion(.success(first))
                    
                } catch {
                    print("❌ DECODE ERROR =", error)
                    completion(.failure(error))
                }
                
            case .failure(let error):
                
                print("❌ REQUEST ERROR =", error)
                completion(.failure(error))
            }
            
        }
        }
        // MARK: - GetCryptoAddress
        
    func fetchCryptoAddress(
        currencyId: String,
        merchantId: String,
        completion: @escaping (SResult<[GetCryptoAddressResponse]>) -> Void
    ) {
        let url = "\(kMBaseURL)/getCryptoAddress"

        let params: [String: Any] = [
            "currency_id": currencyId,
            "merchant_id": merchantId
        ]

        print("========== GET CRYPTO ADDRESS ==========")
        print("URL =", url)
        print("PARAMS =", params)
        print("HEADERS =", commonHeaders())

        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: commonHeaders()
        )
        .responseJSON { response in

            print("STATUS =", response.response?.statusCode ?? 0)

            if let data = response.data,
               let str = String(data: data, encoding: .utf8) {
                print("RESPONSE =", str)
            }

            switch response.result {
            case .success(let value):
                do {
                    let data = try JSONSerialization.data(withJSONObject: value)
                    let result = try JSONDecoder().decode([GetCryptoAddressResponse].self, from: data)
                    completion(.success(result))
                } catch {
                    print("DECODE ERROR =", error)
                    completion(.failure(error))
                }

            case .failure(let error):
                print("REQUEST ERROR =", error)
                completion(.failure(error))
            }
        }
    }
        
        // MARK: - AddCryptoAddress
        
    func saveCryptoAddresses(
        _ payloads: [AddCryptoAddressPayload],
        completion: @escaping (SResult<GenericApiResult>) -> Void
    ) {
        let url = "\(kMBaseURL)/AddCryptoAddress"

        do {

            let bodyData = try JSONEncoder().encode(payloads)

            print("========== SAVE CRYPTO ADDRESS ==========")
            print("URL =", url)

            if let jsonString = String(data: bodyData, encoding: .utf8) {
                print("PAYLOAD =", jsonString)
            }

            print("HEADERS =", commonHeaders())

            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"

            commonHeaders().forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }

            request.httpBody = bodyData

            Alamofire.request(request)
                .responseData { response in

                    print("========== RESPONSE ==========")

                    if let statusCode = response.response?.statusCode {
                        print("STATUS =", statusCode)
                    }

                    if let data = response.data,
                       let responseString = String(data: data, encoding: .utf8) {

                        print("RAW RESPONSE =")
                        print(responseString)
                    }

                    if let error = response.error {
                        print("REQUEST ERROR =", error)
                    }

                    switch response.result {

                    case .success(let data):

                        do {

                            let result = try JSONDecoder().decode(
                                [GenericApiResult].self,
                                from: data
                            )

                            print("DECODE SUCCESS =", result)

                            guard let first = result.first else {
                                completion(.failure(ServiceError.emptyResponse))
                                return
                            }

                            completion(.success(first))

                        } catch {

                            print("DECODE ERROR =", error)
                            completion(.failure(error))
                        }

                    case .failure(let error):

                        print("FAILURE =", error)
                        completion(.failure(error))
                    }
                }

        } catch {

            print("ENCODING ERROR =", error)
            completion(.failure(ServiceError.encodingFailed))
        }
    }
        
        // MARK: - Validate Crypto Address
        
    func validateCryptoAddress(
        address: String,
        currency: String,
        currencyId: String,
        tokenType: String,
        memo: String,
        completion: @escaping (SResult<ValidateAddressResponse>) -> Void
    ) {
        let url = "\(kMBaseURL)/addressValidate"

        let params: [String: Any] = [
            "address": address,
            "currency": currency,
            "currencyId": currencyId,
            "tokenType": tokenType,
            "memo": memo
        ]

        print("========== VALIDATE ADDRESS ==========")
        print("URL =", url)
        print("PARAMS =", params)

        Alamofire.request(
            url,
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: commonHeaders()
        )
        .responseData { response in

            print("========== VALIDATION RESPONSE ==========")

            if let status = response.response?.statusCode {
                print("STATUS =", status)
            }

            if let data = response.data,
               let json = String(data: data, encoding: .utf8) {

                print("RAW RESPONSE =")
                print(json)
            }

            if let error = response.error {
                print("REQUEST ERROR =", error)
            }

            switch response.result {

            case .success(let data):

                do {

                    let result = try JSONDecoder().decode(
                        [ValidateAddressResponse].self,
                        from: data
                    )

                    print("DECODED =", result)

                    guard let first = result.first else {
                        completion(.failure(ServiceError.emptyResponse))
                        return
                    }

                    completion(.success(first))

                } catch {

                    print("DECODE ERROR =", error)
                    completion(.failure(error))
                }

            case .failure(let error):

                print("FAILURE =", error)
                completion(.failure(error))
            }
        }
    }
    
}
