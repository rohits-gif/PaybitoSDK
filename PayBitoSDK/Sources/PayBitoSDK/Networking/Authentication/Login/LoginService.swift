// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//
////  LoginService.swift
////  Exact match of the React web login flow from billbitcoins Login.jsx
//
//import Foundation
//import Alamofire
//import SwiftyJSON
//
//// MARK: - Constants
//
//private let kBase    = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/"
//private let kPayBitoAPI = "https://accounts.paybito.com/api/home/"
//
//// BrokerId — same value used in DashboardViewController / txtBrokerId
//private let kBrokerId = UserDefaults.standard.string(forKey: "brokerId") ?? "PAYB18022021121103"
//
//
//
//
//
//
//// MARK: - Shared headers (matches web app exactly)
//
//private var webHeaders: [String: String] {
//    [
//        "Content-Type": "application/json",
//        "Accept":       "application/json, text/plain, */*",
//        "Origin":       "https://trade.paybito.com",
//        "Referer":      "https://trade.paybito.com/",
//        "User-Agent":   "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
//    ]
//}
//
//private func authHeaders() -> [String: String] {
//    var h = webHeaders
//    h["Authorization"] = "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? "")
//    h["UUID"]          = UserDefaults.standard.string(forKey: "Buuid") ?? ""
//    return h
//}
//
//// MARK: - Callback
//
//typealias LoginCallback = (_ success: Bool, _ json: JSON, _ errorMsg: String) -> Void
//
//// MARK: - LoginService
//
//final class LoginService {
//
//    static let shared = LoginService()
//    private init() {}
//    // ─────────────────────────────────────────────────────────
//    // STEP 1 — checkMgaStatus  (web: handleCaptchaSubmit)
//    //
//    // Web payload:
//    //   { email, password, gRecaptchaResponse, sessionId, brokerId }
//    //
//    // On success → check phone_auth_enabled, google_auth_enabled flags
//    // ─────────────────────────────────────────────────────────
//    func checkMgaStatus(email: String,
//                        password: String,
//                        completion: @escaping LoginCallback) {
//        let params: Parameters = [
//            "email":               email,
//            "password":            password,
//            "gRecaptchaResponse":  "",       // skipped on iOS (no captcha widget)
//            "brokerId":            kBrokerId
//        ]
//        post(kBase + "checkMGAStatus", params: params, completion: completion)
//    }
//
//    // ─────────────────────────────────────────────────────────
//    // STEP 2 — emailValidationAtLogin  (web: sendEmailOtp)
//    //
//    // Web payload:
//    //   { email, password, gRecaptchaResponse }
//    //
//    // Response: [{error:"0", error_msg:"OTP has been sent..."}]
//    // ─────────────────────────────────────────────────────────
//    func sendEmailOTP(email: String,
//                      password: String,
//                      completion: @escaping LoginCallback) {
//        let params: Parameters = [
//            "email":              email,
//            "password":           password,
//            "gRecaptchaResponse": ""
//        ]
//        post(kBase + "SendEmailOtp/EmailLogin", params: params, completion: completion)
//    }
//
//    // ─────────────────────────────────────────────────────────
//    // STEP 3 — loginDetails  (web: billbitCoinLogin)
//    //
//    // Web payload:
//    //   { email, password, email_otp, google_Factor_Otp? }
//    //
//    // Key facts from web source:
//    //   • OTP field = "email_otp"  (7-digit string)
//    //   • Access token = response.oauth2.access_token  (NESTED!)
//    //   • UUID         = response.uuid
//    //   • Error check  = response.error != "0"
//    // ─────────────────────────────────────────────────────────
//    func loginDetails(email: String,
//                      password: String,
//                      emailOTP: String,
//                      googleAuthOTP: String = "",
//                      completion: @escaping LoginCallback) {
//        var params: Parameters = [
//            "email":      email,
//            "password":   password,
//            "email_otp":  emailOTP          // ← correct field name from React source
//        ]
//        if !googleAuthOTP.isEmpty {
//            params["google_Factor_Otp"] = googleAuthOTP
//        }
//        post(kBase + "loginDetails", params: params, completion: completion)
//    }
//
//    // ─────────────────────────────────────────────────────────
//    // STEP 4 — FetchMerchantStatus  (web: handleMerchantStatus)
//    //
//    // Determines redirect:
//    //   transaction_status_flag == 0  →  /get-started
//    //   else                          →  /dashboard
//    // ─────────────────────────────────────────────────────────
//    func fetchMerchantStatus(merchantId: Int,
//                             completion: @escaping LoginCallback) {
//        let params: Parameters = ["merchant_id": merchantId]
//        Alamofire.request(kBase + "FetchMerchantStatus",
//                          method: .post,
//                          parameters: params,
//                          encoding: JSONEncoding.default,
//                          headers: authHeaders())
//            .responseString { r in Self.parse(r, label: "FetchMerchantStatus",
//                                              completion: completion) }
//    }
//
//    // ─────────────────────────────────────────────────────────
//    // STEP 5 — getBrokerWiseExchangeInfo
//    // ─────────────────────────────────────────────────────────
//    func getBrokerInfo(brokerId: String,
//                       completion: @escaping LoginCallback) {
//        let url = kPayBitoAPI + "getBrokerWiseExchangeInfo?brokerId=\(brokerId)"
//        Alamofire.request(url, method: .get, headers: authHeaders())
//            .responseString { r in Self.parse(r, label: "getBrokerInfo",
//                                              completion: completion) }
//    }
//
//    // ─────────────────────────────────────────────────────────
//    // STEP 6 — getProfilePicture
//    // ─────────────────────────────────────────────────────────
//    func getProfilePicture(uuid: String,
//                           completion: @escaping LoginCallback) {
//        let url = kBase + "getProfilePicture/\(uuid)"
//        Alamofire.request(url, method: .get, headers: authHeaders())
//            .responseString { r in Self.parse(r, label: "getProfilePicture",
//                                              completion: completion) }
//    }
//
//    // MARK: - Private helpers
//
//    private func post(_ url: String,
//                      params: Parameters,
//                      completion: @escaping LoginCallback) {
//        Alamofire.request(url,
//                          method: .post,
//                          parameters: params,
//                          encoding: JSONEncoding.default,
//                          headers: webHeaders)
//            .responseString { r in
//                let label = url.components(separatedBy: "/").last ?? url
//                Self.parse(r, label: label, completion: completion)
//            }
//    }
//
//    // MARK: - Universal parser
//    // Handles three server formats:
//    //   A) { status:bool, message:string, errorCode:string }
//    //   B) { error:"0"|"1", error_msg:string, ... }
//    //   C) [{ error:"0"|"1", error_msg:string }]  ← array
//
//    private static func parse(_ response: DataResponse<String>,
//                               label: String,
//                               completion: LoginCallback) {
//        let code = response.response?.statusCode ?? 0
//        let body = response.value ?? ""
//
//        #if DEBUG
//        print("─── [\(code)] \(label)")
//        print("    \(body.prefix(600))")
//        #endif
//
//        guard response.result.isSuccess,
//              let data = body.data(using: .utf8),
//              let json = try? JSON(data: data) else {
//            completion(false, JSON(), httpMsg(code))
//            return
//        }
//
//        // Format C — array
//        if let first = json.array?.first {
//            let err = first["error"].stringValue
//            let msg = first["error_msg"].stringValue
//            completion(err == "0", first, err == "0" ? "" : msg)
//            return
//        }
//
//        // Format A — {status, message, errorCode}
//        if json["status"].exists() && json["message"].exists() {
//            let ok  = json["status"].boolValue
//            let msg = json["message"].stringValue
//            completion(ok, json, ok ? "" : msg)
//            return
//        }
//
//        // Format B — {error, error_msg}
//        let err = json["error"].stringValue
//        let msg = json["error_msg"].stringValue
//        completion(err == "0", json, err == "0" ? "" : msg)
//    }
//
//    private static func httpMsg(_ code: Int) -> String {
//        switch code {
//        case 0:   return "Cannot reach server. Check your connection."
//        case 400: return "Bad request (400)."
//        case 401: return "Unauthorised (401)."
//        case 403: return "Access denied (403)."
//        case 415: return "Unsupported media type (415)."
//        case 502: return "Server gateway error (502)."
//        default:  return "Server error (\(code))."
//        }
//    }
//}
//
//// MARK: - Session persistence
//// Mirrors web's billbitCoinLogin localStorage keys, mapped to UserDefaults.
//
//extension LoginService {
//
//    func persistSession(from json: JSON) {
//        let ud = UserDefaults.standard
//
//        // ⚠️  Access token is NESTED: response.oauth2.access_token
//        let accessToken = json["oauth2"]["access_token"].stringValue
//        let uuid        = json["uuid"].stringValue
//
//        ud.set("1",                                              forKey: "Blogin")
//        ud.set(accessToken,                                      forKey: "Baccess_token")
//        ud.set(uuid,                                             forKey: "Buuid")
//        ud.set(json["merchant_id"].stringValue,                  forKey: "Bmerchant_id")
//        ud.set(uuid,                                             forKey: "Bmerchant_uuid")
//        ud.set(json["exchangeUserUuid"].stringValue,             forKey: "Bexchange_uuid")
//        ud.set(json["email"].stringValue,                        forKey: "Bemail")
//        ud.set(json["first_name"].stringValue,                   forKey: "Bfirst_name")
//        ud.set(json["last_name"].stringValue,                    forKey: "Blast_name")
//        ud.set(json["phone"].stringValue,                        forKey: "BuserPhone")
//        ud.set(json["email_confirmed"].stringValue,              forKey: "Bemail_confirmed")
//        ud.set(json["basic_verification_submitted"].stringValue, forKey: "Bbasic_verification_submitted")
//        ud.set(json["crypto_address_added"].stringValue,         forKey: "Bcrypto_address_added")
//        ud.set(json["account_status_id"].stringValue,            forKey: "Baccount_status_id")
//        ud.set(json["parent_merchant_id"].stringValue,           forKey: "Bparent_merchant_id")
//        ud.set(json["brokerId"].stringValue,                     forKey: "brokerId")
//        ud.set(json["homeCurrency"].stringValue,                 forKey: "BhomeCurrency")
//        ud.set(json["country"].stringValue,                      forKey: "Bcountry")
//        ud.set(json["two_factor_auth_enabled"].stringValue,      forKey: "BtwoFactorKey")
//        ud.set(json["google_auth_enabled"].stringValue,          forKey: "BgoogleEnable")
//        UserDefaults.standard.set(json["created_on"].stringValue, forKey: "Bcreated_on")
//        ud.synchronize()
//    }
//
//    static func clearSession() {
//        ["Blogin","Baccess_token","Buuid","Bmerchant_id","Bmerchant_uuid",
//         "Bexchange_uuid","Bemail","Bfirst_name","Blast_name","BuserPhone",
//         "Bemail_confirmed","Bbasic_verification_submitted","Bcrypto_address_added",
//         "Baccount_status_id","Bparent_merchant_id","brokerId","BhomeCurrency",
//         "Bcountry","BtwoFactorKey","BgoogleEnable","Blogingornot","BuserId"
//        ].forEach { UserDefaults.standard.removeObject(forKey: $0) }
//        UserDefaults.standard.synchronize()
//    }
//    static var isSessionActive: Bool {
//        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
//        let login = UserDefaults.standard.string(forKey: "Blogin") ?? ""
//        return !token.isEmpty && login == "1"
//    }
//
//}
//

//  LoginService.swift

import Foundation
import Alamofire
import SwiftyJSON

// MARK: - Constants

private let kBase             = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/"
private let kPayBitoAPI       = "https://accounts.paybito.com/api/home/"
private let kRecaptchaBase    = "https://recaptcha.paybito.com/v1/internal/"
private let kSiteKey          = "pbk_live_fb3223b4540ecc8f45c1fae4c582b8b0"
private let kParentOrigin     = "https://trade.paybito.com"
//private let kBrokerId         = UserDefaults.standard.string(forKey: "brokerId") ?? "PAYB18022021121103"

// MARK: - Shared headers

private var webHeaders: [String: String] {
    [
        "Content-Type": "application/json",
        "Accept":       "application/json, text/plain, */*",
        "Origin":       "https://trade.paybito.com",
        "Referer":      "https://trade.paybito.com/",
        "User-Agent":   "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    ]
}

private func authHeaders() -> [String: String] {
    var h = webHeaders
    h["Authorization"] = "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? "")
    h["UUID"]          = UserDefaults.standard.string(forKey: "Buuid") ?? ""
    return h
}

// MARK: - Callback

typealias LoginCallback = (_ success: Bool, _ json: JSON, _ errorMsg: String) -> Void

// MARK: - LoginService

final class LoginService {

    static let shared = LoginService()
    private init() {}

    // ─────────────────────────────────────────────────────────
    // STEP 0 — generateCaptcha
    // POST https://recaptcha.paybito.com/v1/internal/generate
    // Payload: { sitekey, parentOrigin }
    // ─────────────────────────────────────────────────────────
    func generateCaptcha(completion: @escaping LoginCallback) {
        let params: [String: Any] = [
            "sitekey":      kSiteKey,
            "parentOrigin": kParentOrigin
        ]
        post(kRecaptchaBase + "generate", params: params, completion: completion)
    }

    // ─────────────────────────────────────────────────────────
    // STEP 0b — solveCaptcha
    // POST https://recaptcha.paybito.com/v1/internal/solve
    // Payload: { sitekey, sessionId, signals: { dragMs }, userSliderX }
    // Returns JWT token → use as gRecaptchaResponse
    // ─────────────────────────────────────────────────────────
    func solveCaptcha(sessionId: String,
                      userSliderX: Int,
                      dragMs: Int = 1238,
                      completion: @escaping LoginCallback) {
        let params: [String: Any] = [
            "sitekey":     kSiteKey,
            "sessionId":   sessionId,
            "signals":     ["dragMs": dragMs],
            "userSliderX": userSliderX
        ]
        post(kRecaptchaBase + "solve", params: params, completion: completion)
    }

    // ─────────────────────────────────────────────────────────
    // STEP 1 — checkMGAStatus
    // Payload: { email, password, gRecaptchaResponse, brokerId }
    // ─────────────────────────────────────────────────────────
    func checkMgaStatus(email: String,
                        password: String,
                        gRecaptchaResponse: String,
                        completion: @escaping LoginCallback) {
        let params: [String: Any] = [
            "email":               email,
            "password":            password,
            "gRecaptchaResponse":  gRecaptchaResponse,
            "brokerId":            currentBrokerId
        ]
        post(kBase + "checkMGAStatus", params: params, completion: completion)
    }

    // ─────────────────────────────────────────────────────────
    // STEP 2 — sendEmailOTP
    // ─────────────────────────────────────────────────────────
    func sendEmailOTP(email: String,
                      password: String,
                      completion: @escaping LoginCallback) {
        let params: [String: Any] = [
            "email":              email,
            "password":           password,
            "gRecaptchaResponse": "",
            "brokerId": currentBrokerId
        ]
        post(kBase + "SendEmailOtp/EmailLogin", params: params, completion: completion)
    }
    private var currentBrokerId: String {
        UserDefaults.standard.string(forKey: "brokerId")
            ?? "PAYB18022021121103"
    }
    // ─────────────────────────────────────────────────────────
    // STEP 3 — loginDetails
    // ─────────────────────────────────────────────────────────
    func loginDetails(email: String,
                      password: String,
                      emailOTP: String,
                      googleAuthOTP: String = "",
                      completion: @escaping LoginCallback) {
        var params: [String: Any] = [
            "email":     email,
            "password":  password,
            "email_otp": emailOTP
        ]
        if !googleAuthOTP.isEmpty {
            params["google_Factor_Otp"] = googleAuthOTP
        }
        post(kBase + "loginDetails", params: params, completion: completion)
    }

    // ─────────────────────────────────────────────────────────
    // STEP 4 — fetchMerchantStatus
    // ─────────────────────────────────────────────────────────
    func fetchMerchantStatus(merchantId: Int,
                             completion: @escaping LoginCallback) {
        let params: [String: Any] = ["merchant_id": merchantId]
        Alamofire.request(kBase + "FetchMerchantStatus",
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: authHeaders())
            .responseString { r in
                Self.parse(r, label: "FetchMerchantStatus", completion: completion)
            }
    }
    
    
    func prefetchDomainAndBrokerId() {
        guard UserDefaults.standard.string(forKey: "Bdomain")?.isEmpty ?? true else {
            debugPrint("✅ [Service] domain already cached: \(UserDefaults.standard.string(forKey: "Bdomain") ?? "")")
            return
        }
       
    }
    
    
    

    // ─────────────────────────────────────────────────────────
    // STEP 5 — getBrokerInfo
    // ─────────────────────────────────────────────────────────
    func getBrokerInfo(brokerId: String,
                       completion: @escaping LoginCallback) {
        let url = kPayBitoAPI + "getBrokerWiseExchangeInfo?brokerId=\(brokerId)"
        Alamofire.request(url, method: .get, headers: authHeaders())
            .responseString { r in
                Self.parse(r, label: "getBrokerInfo", completion: completion)
            }
    }

    // ─────────────────────────────────────────────────────────
    // STEP 6 — getProfilePicture
    // ─────────────────────────────────────────────────────────
    func getProfilePicture(uuid: String,
                           completion: @escaping LoginCallback) {
        let url = kBase + "getProfilePicture/\(uuid)"
        Alamofire.request(url, method: .get, headers: authHeaders())
            .responseString { r in
                Self.parse(r, label: "getProfilePicture", completion: completion)
            }
    }

    // MARK: - Private helpers

    private func post(_ url: String,
                      params: [String: Any],
                      completion: @escaping LoginCallback) {
        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: webHeaders)
            .responseString { r in
                let label = url.components(separatedBy: "/").last ?? url
                Self.parse(r, label: label, completion: completion)
            }
    }

    // MARK: - Universal response parser

    private static func parse(_ response: DataResponse<String>,
                               label: String,
                               completion: LoginCallback) {
        let code = response.response?.statusCode ?? 0
        let body = response.value ?? ""

        #if DEBUG
        print("─── [\(code)] \(label)")
        print("    \(body.prefix(600))")
        #endif

        guard response.result.isSuccess,
              let data = body.data(using: .utf8),
              let json = try? JSON(data: data) else {
            completion(false, JSON(), httpMsg(code))
            return
        }

        // Format C — array
        if let first = json.array?.first {
            let err = first["error"].stringValue
            let msg = first["error_msg"].stringValue
            completion(err == "0", first, err == "0" ? "" : msg)
            return
        }

        // Format A — { status, message }
        if json["status"].exists() && json["message"].exists() {
            let ok  = json["status"].boolValue
            let msg = json["message"].stringValue
            completion(ok, json, ok ? "" : msg)
            return
        }

        // Format B — { error, error_msg }
        let err = json["error"].stringValue
        let msg = json["error_msg"].stringValue
        completion(err == "0", json, err == "0" ? "" : msg)
    }

    private static func httpMsg(_ code: Int) -> String {
        switch code {
        case 0:   return "Cannot reach server. Check your connection."
        case 400: return "Bad request (400)."
        case 401: return "Unauthorised (401)."
        case 403: return "Access denied (403)."
        case 415: return "Unsupported media type (415)."
        case 502: return "Server gateway error (502)."
        default:  return "Server error (\(code))."
        }
    }
}

// MARK: - Session persistence

extension LoginService {

    func persistSession(from json: JSON,  selectedBrokerId: String) {
        
        let returnedBrokerId = json["brokerId"].stringValue
          
          // ✅ Broker validation — reject if backend returned a different broker
          if !returnedBrokerId.isEmpty &&
             !selectedBrokerId.isEmpty &&
             returnedBrokerId != selectedBrokerId {
              // Don't persist — notify caller of mismatch
              NotificationCenter.default.post(
                  name: NSNotification.Name("brokerMismatch"), object: nil
              )
              return
          }
        let ud = UserDefaults.standard
        let accessToken = json["oauth2"]["access_token"].stringValue
        let uuid        = json["uuid"].stringValue

        ud.set("1",                                              forKey: "Blogin")
        ud.set(accessToken,                                      forKey: "Baccess_token")
        ud.set(uuid,                                             forKey: "Buuid")
        ud.set(json["merchant_id"].stringValue,                  forKey: "Bmerchant_id")
        ud.set(uuid,                                             forKey: "Bmerchant_uuid")
        ud.set(json["exchangeUserUuid"].stringValue,             forKey: "Bexchange_uuid")
        ud.set(json["email"].stringValue,                        forKey: "Bemail")
        ud.set(json["first_name"].stringValue,                   forKey: "Bfirst_name")
        ud.set(json["last_name"].stringValue,                    forKey: "Blast_name")
        ud.set(json["phone"].stringValue,                        forKey: "BuserPhone")
        ud.set(json["email_confirmed"].stringValue,              forKey: "Bemail_confirmed")
        ud.set(json["basic_verification_submitted"].stringValue, forKey: "Bbasic_verification_submitted")
        ud.set(json["crypto_address_added"].stringValue,         forKey: "Bcrypto_address_added")
        ud.set(json["account_status_id"].stringValue,            forKey: "Baccount_status_id")
        ud.set(json["parent_merchant_id"].stringValue,           forKey: "Bparent_merchant_id")
        ud.set(json["brokerId"].stringValue,                     forKey: "brokerId")
        ud.set(json["homeCurrency"].stringValue,                 forKey: "BhomeCurrency")
        ud.set(json["country"].stringValue,                      forKey: "Bcountry")
        ud.set(json["two_factor_auth_enabled"].stringValue,      forKey: "BtwoFactorKey")
        ud.set(json["google_auth_enabled"].stringValue,          forKey: "BgoogleEnable")
        ud.set(json["created_on"].stringValue,                   forKey: "Bcreated_on")
        ud.synchronize()
    }

    static func clearSession() {
        ["Blogin", "Baccess_token", "Buuid", "Bmerchant_id", "Bmerchant_uuid",
         "Bexchange_uuid", "Bemail", "Bfirst_name", "Blast_name", "BuserPhone",
         "Bemail_confirmed", "Bbasic_verification_submitted", "Bcrypto_address_added",
         "Baccount_status_id", "Bparent_merchant_id", "brokerId", "BhomeCurrency",
         "Bcountry", "BtwoFactorKey", "BgoogleEnable", "Blogingornot", "BuserId"
        ].forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.synchronize()
    }

    static var isSessionActive: Bool {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let login = UserDefaults.standard.string(forKey: "Blogin") ?? ""
        return !token.isEmpty && login == "1"
    }
}
