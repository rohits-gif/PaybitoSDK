//  AddUserManagementService.swift
//  Trading_Terminal

import Foundation
import Alamofire

// MARK: - API Constants
private enum AddUMAPI {
    static let base              = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant"
    static let allMenus          = "\(base)/getAllMenus"
    static let createSubMerchant = "\(base)/createSubMerchant"
}

// MARK: - Protocol
protocol SubMerchantServiceProtocol {
    func getAllMenus(
        completion: @escaping (Swift.Result<GetAllMenusResponse, Error>) -> Void
    )
    func createSubMerchant(
        request:    CreateSubMerchantRequest,
        completion: @escaping (Swift.Result<CreateSubMerchantResponse, Error>) -> Void
    )
}

// MARK: - Service
final class AddUserManagementService: SubMerchantServiceProtocol {

    static let shared = AddUserManagementService()
    private init() {}

    // MARK: Auth Headers
    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Accept":       "application/json",
            "Origin":       "https://trade.paybito.com",
            "Referer":      "https://trade.paybito.com/"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["authorization"] = "Bearer \(token)"
            debugPrint("🔑 [AddUMService] Token: \(token.prefix(30))…")
        } else {
            debugPrint("❌ [AddUMService] Token missing")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["uuid"] = uuid
            debugPrint("🆔 [AddUMService] UUID: \(uuid)")
        } else {
            debugPrint("❌ [AddUMService] UUID missing")
        }
        return h
    }

    // MARK: Get All Menus
    func getAllMenus(
        completion: @escaping (Swift.Result<GetAllMenusResponse, Error>) -> Void
    ) {
        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [AddUMService] getAllMenus")
        debugPrint("   URL     : \(AddUMAPI.allMenus)")
        debugPrint("   Headers : \(authHeaders)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                AddUMAPI.allMenus,
                method:   .get,
                encoding: JSONEncoding.default,
                headers:  authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [AddUMService] getAllMenus HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }

                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(GetAllMenusResponse.self, from: data)
                        debugPrint("✅ [AddUMService] getAllMenus — error=\(decoded.error) count=\(decoded.list.count)")
                        decoded.list.forEach { debugPrint("   📋 [\($0.id)] \($0.name)") }
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ [AddUMService] getAllMenus decode: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [AddUMService] getAllMenus network: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: Create Sub Merchant
    func createSubMerchant(
        request:    CreateSubMerchantRequest,
        completion: @escaping (Swift.Result<CreateSubMerchantResponse, Error>) -> Void
    ) {
        // ✅ Use the shared EncodableExtensions helper directly
        guard let bodyDict = request.asDictionary() else {
            debugPrint("❌ [AddUMService] createSubMerchant — encoding failed")
            let err = NSError(
                domain: "AddUMService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Request encoding failed"]
            )
            completion(.failure(err))
            return
        }

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [AddUMService] createSubMerchant")
        debugPrint("   URL     : \(AddUMAPI.createSubMerchant)")
        debugPrint("   Headers : \(authHeaders)")
        debugPrint("   Body    : \(bodyDict)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                AddUMAPI.createSubMerchant,
                method:     .post,
                parameters: bodyDict,
                encoding:   JSONEncoding.default,
                headers:    authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [AddUMService] createSubMerchant HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }

                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(CreateSubMerchantResponse.self, from: data)
                        debugPrint("✅ [AddUMService] createSubMerchant — error=\(decoded.error) msg=\(decoded.errorMsg)")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ [AddUMService] createSubMerchant decode: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [AddUMService] createSubMerchant network: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
// ✅ asDictionary() REMOVED from here — lives only in EncodableExtensions.swift
