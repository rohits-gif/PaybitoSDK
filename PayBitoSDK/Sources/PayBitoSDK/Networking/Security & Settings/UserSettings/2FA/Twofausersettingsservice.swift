// MARK: - TwofaUserSettingsService.swift
//
// Confirmed endpoints (from network inspector screenshots):
//
//  1. Send Email OTP       POST /merchant/SendOtp/2faemailotp
//     Payload : { "merchant_id": <String> }
//     Response: { "error": "0", "error_msg": "OTP has been send to your register email successfully." }
//
//  2. Get Two Factory Key  POST /merchant/GetTwoFactorykey
//     Payload : { "merchant_id": "<String>", "email": "<email>", "email_otp": emailOTP }
//     Response: { "error": "0", "error_msg": "successful",
//                 "google_auth_key": "JVIGANXPEEOT6WBACZXSV5D3PFSTVNMB",
//                 "GA_enabled_status": "1" }
//
//  3. Save Two Factor Settings  POST /MerchantDashboard/SaveTwoFactorSettings
//     Payload : { "merchant_id": "32979", "google_auth_enabled": "1", "google_factor_otp": "147912" }
//     Response: { "error": "0", "error_msg": "..." }
//
// ✅ FIXES (confirmed from network inspector screenshot 2026-06-01):
//   - Origin  → https://trade.paybito.com        (was portal.paybito.com — WRONG)
//   - Referer → https://trade.paybito.com/        (was portal.paybito.com/ — WRONG)
//   - Authorization header key casing → "bearer " (lowercase, matches live traffic)
//   - merchant_id sent as String everywhere       (matches live payload Content-Length)
//

import Foundation
import Alamofire

// ✅ FIX: Disambiguate Alamofire's SessionManager from the app's custom SessionManager.
// Without this alias, Swift resolves "SessionManager" to the app's singleton (private init),
// causing: "initializer is inaccessible", "has no member 'request'", etc.
private typealias AlamofireSession = Alamofire.SessionManager

// MARK: - API Constants

enum TwofaAPIConfig {
    static let dashboardBaseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard"
    static let merchantBaseURL  = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant"

    enum Endpoints {
        static let fetchUserSettings     = "\(TwofaAPIConfig.dashboardBaseURL)/FetchUserSettings"
        static let disableGoogleAuth     = "\(TwofaAPIConfig.dashboardBaseURL)/DisableGoogleAuth"
        static let saveTwoFactorSettings = "\(TwofaAPIConfig.dashboardBaseURL)/SaveTwoFactorSettings"
        static let sendGmailOTP          = "\(TwofaAPIConfig.merchantBaseURL)/SendOtp/2faemailotp"
        static let getTwoFactoryKey      = "\(TwofaAPIConfig.merchantBaseURL)/GetTwoFactorykey"
    }
}

// MARK: - Service Protocol

protocol TwofaUserSettingsServiceProtocol {
    func fetchUserSettings(
        merchantId: String,
        completion: @escaping (Swift.Result<TwofaUserSettingsResponse, Error>) -> Void
    )
    func sendGmailOTP(
        merchantId: String,
        email: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    )
    func getTwoFactoryKey(
        merchantId: String,
        email: String,
        emailOTP: String,
        googleAuthCode: String,
        completion: @escaping (Swift.Result<GetTwoFactoryKeyResponse, Error>) -> Void
    )
    func saveTwoFactorSettings(
        merchantId: String,
        googleAuthEnabled: String,
        googleFactorOTP: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    )
    func disableGoogleAuth(
        merchantId: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    )
}

// MARK: - Alamofire 4.x Implementation

final class TwofaUserSettingsService: TwofaUserSettingsServiceProtocol {

    static let shared = TwofaUserSettingsService()
    private init() {}

    // ✅ Uses AlamofireSession (= Alamofire.SessionManager), NOT the app's SessionManager
    private let session: AlamofireSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = 30
        config.timeoutIntervalForResource = 60
        return AlamofireSession(configuration: config)
    }()

    // MARK: - Auth Headers
    // ✅ FIX: Origin and Referer corrected to trade.paybito.com (confirmed from network inspector)

    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Accept":       "application/json",
            "Origin":       "https://trade.paybito.com",   // ✅ FIXED (was portal.paybito.com)
            "Referer":      "https://trade.paybito.com/"   // ✅ FIXED (was portal.paybito.com/)
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "bearer \(token)"         // lowercase "bearer" — matches live traffic
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["Uuid"] = uuid
        }
        return h
    }

    // MARK: - POST Helper

    private func postRequest(
        url: String,
        parameters: [String: Any],
        completion: @escaping (Swift.Result<Data, Error>) -> Void
    ) {
        debugPrint("📡 [TwofaService] POST → \(url)")
        debugPrint("📦 Parameters : \(parameters)")

        session.request(
            url,
            method:     .post,
            parameters: parameters,
            encoding:   JSONEncoding.default,
            headers:    authHeaders
        )
        .validate()
        .responseData { (response: DataResponse<Data>) in
            switch response.result {
            case .success(let data):
                debugPrint("✅ [TwofaService] \(url) — bytes: \(data.count)")
                if let raw = String(data: data, encoding: .utf8) { debugPrint("📄 Raw: \(raw)") }
                completion(.success(data))
            case .failure(let error):
                debugPrint("❌ [TwofaService] \(url) — \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }

    // MARK: - Shared error-field check

    private func apiError(from data: Data, fallback: String) -> Error? {
        guard let raw = try? JSONSerialization.jsonObject(with: data) else { return nil }

        let dict: [String: Any]
        if let arr = raw as? [[String: Any]], let first = arr.first {
            dict = first
        } else if let obj = raw as? [String: Any] {
            dict = obj
        } else {
            return nil
        }

        let errorVal = dict["error"] as? String ?? "0"
        guard errorVal != "0" else { return nil }
        let msg = dict["error_msg"] as? String ?? fallback
        return NSError(domain: "TwofaService", code: -1,
                       userInfo: [NSLocalizedDescriptionKey: msg])
    }

    // MARK: 1. Fetch User Settings

    func fetchUserSettings(
        merchantId: String,
        completion: @escaping (Swift.Result<TwofaUserSettingsResponse, Error>) -> Void
    ) {
        let params: [String: Any] = ["merchant_id": merchantId]
        postRequest(url: TwofaAPIConfig.Endpoints.fetchUserSettings, parameters: params) { result in
            switch result {
            case .success(let data):
                do {
                    let items = try JSONDecoder().decode([TwofaUserSettingsResponse].self, from: data)
                    guard let first = items.first else {
                        throw NSError(domain: "TwofaService", code: -1,
                                      userInfo: [NSLocalizedDescriptionKey: "Empty response"])
                    }
                    DispatchQueue.main.async { completion(.success(first)) }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: 2. Send Gmail OTP
    // POST /merchant/SendOtp/2faemailotp
    // Payload: { "merchant_id": "<String>", "email": "<email>" }

    func sendGmailOTP(
        merchantId: String,
        email: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    ) {
        let params: [String: Any] = [
            "merchant_id": merchantId,  // String — matches live payload
            "email":       email
        ]
        postRequest(url: TwofaAPIConfig.Endpoints.sendGmailOTP, parameters: params) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                if let err = self.apiError(from: data, fallback: "Failed to send OTP") {
                    DispatchQueue.main.async { completion(.failure(err)) }
                } else {
                    DispatchQueue.main.async { completion(.success(true)) }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: 3. Get Two Factory Key  ← returns google_auth_key for QR
    // POST /merchant/GetTwoFactorykey
    // ✅ Payload confirmed from Postman: { "merchant_id": "32979", "email_otp": "4542668" }

    func getTwoFactoryKey(
        merchantId: String,
        email: String,
        emailOTP: String,
        googleAuthCode: String,
        completion: @escaping (Swift.Result<GetTwoFactoryKeyResponse, Error>) -> Void
    ) {
        var params: [String: Any] = [
            "merchant_id": merchantId,
            "email_otp":   emailOTP     // ✅ FIXED (was "otp" — caused "Wrong credential." error)
        ]
        if !googleAuthCode.isEmpty {
            params["google_auth_otp"] = googleAuthCode
        }

        postRequest(url: TwofaAPIConfig.Endpoints.getTwoFactoryKey, parameters: params) { result in
            switch result {
            case .success(let data):
                do {
                    let decoded: GetTwoFactoryKeyResponse
                    if let arr = try? JSONDecoder().decode([GetTwoFactoryKeyResponse].self, from: data),
                       let first = arr.first {
                        decoded = first
                    } else {
                        decoded = try JSONDecoder().decode(GetTwoFactoryKeyResponse.self, from: data)
                    }
                    if !decoded.isSuccess {
                        let msg = decoded.errorMsg ?? "Verification failed"
                        let err = NSError(domain: "TwofaService", code: -2,
                                          userInfo: [NSLocalizedDescriptionKey: msg])
                        DispatchQueue.main.async { completion(.failure(err)) }
                    } else {
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    }
                } catch {
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: 4. Save Two Factor Settings
    // POST /MerchantDashboard/SaveTwoFactorSettings
    // Payload (all strings): { "merchant_id": "32979", "google_auth_enabled": "1",
    //                          "google_factor_otp": "147912" }

    func saveTwoFactorSettings(
        merchantId: String,
        googleAuthEnabled: String,
        googleFactorOTP: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    ) {
        let params: [String: Any] = [
            "merchant_id":         merchantId,
            "google_auth_enabled": googleAuthEnabled,
            "google_factor_otp":   googleFactorOTP
        ]
        debugPrint("📡 [SaveTwoFactorSettings] merchantId=\(merchantId) enabled=\(googleAuthEnabled) otp=\(googleFactorOTP)")

        postRequest(url: TwofaAPIConfig.Endpoints.saveTwoFactorSettings, parameters: params) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                if let err = self.apiError(from: data, fallback: "Failed to save 2FA settings") {
                    DispatchQueue.main.async { completion(.failure(err)) }
                } else {
                    DispatchQueue.main.async { completion(.success(true)) }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    // MARK: 5. Disable Google Auth
    // POST /MerchantDashboard/DisableGoogleAuth
    // Payload: { "merchant_id": "<String>" }

    func disableGoogleAuth(
        merchantId: String,
        completion: @escaping (Swift.Result<Bool, Error>) -> Void
    ) {
        let params: [String: Any] = ["merchant_id": merchantId]
        postRequest(url: TwofaAPIConfig.Endpoints.disableGoogleAuth, parameters: params) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let data):
                if let err = self.apiError(from: data, fallback: "Failed to disable 2FA") {
                    DispatchQueue.main.async { completion(.failure(err)) }
                } else {
                    DispatchQueue.main.async { completion(.success(true)) }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
