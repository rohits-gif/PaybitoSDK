// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//   Registerservice.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 17/04/26.
//

//
//import Foundation
//import UIKit
//import Alamofire
//import SwiftyJSON
//
//private let kBase = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/"
//
//private var webHeaders: [String: String] {
//    ["Content-Type": "application/json",
//     "Accept":       "application/json, text/plain, */*",
//     "Origin":       "https://trade.paybito.com",
//     "Referer":      "https://trade.paybito.com/",
//     "User-Agent":   "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"]
//}
//
//typealias RegCallback = (_ success: Bool, _ json: JSON, _ errorMsg: String) -> Void
//
//final class RegisterService {
//
//    static let shared = RegisterService()
//    private init() {}
//
//    // MARK: - emailCheck (web: handleEmailCheck — called onBlur)
//    // Payload: { email }
//    func emailCheck(email: String, completion: @escaping RegCallback) {
//        post(kBase + "emailCheck", params: ["email": email], completion: completion)
//    }
//
//    // MARK: - checkPhoneNo (web: handlePhoneCheck — called onBlur)
//    // Payload: { phone, countryCode }
//    func checkPhoneNo(phone: String, countryCode: String, completion: @escaping RegCallback) {
//        post(kBase + "checkPhoneNo",
//             params: ["phone": phone, "countryCode": countryCode],
//             completion: completion)
//    }
//
//    // MARK: - ValidateRegistration (web: handleCaptchaSubmit)
//    //
//    // captchaToken → SHA256 hash produced by LoginCaptchaView after the user
//    //                solves the puzzle (= gRecaptchaResponse expected by backend)
//    // captchaSessionId → sessionId UUID returned by the captcha generate API
//    //
//    func validateRegistration(
//        orgName:          String,
//        firstName:        String,
//        lastName:         String,
//        email:            String,
//        password:         String,
//        retypePassword:   String,
//        phone:            String,
//        countryCode:      String,
//        gender:           String,
//        country:          String,
//        captchaToken:     String,       // ← real SHA256 hash from puzzle captcha
//        captchaSessionId: String,       // ← real sessionId from captcha generate API
//        brokerId:         String = "PAYB18022021121103",
//        completion:       @escaping RegCallback
//    ) {
//        let params: Parameters = [
//            "organization_name":  orgName,
//            "first_name":         firstName,
//            "last_name":          lastName,
//            "email":              email,
//            "password":           password,
//            "retype_password":    retypePassword,
//            "phone":              phone,
//            "countryCode":        countryCode,
//            "gender":             gender,
//            "country":            country,
//            "brokerId":           brokerId,
//            "gRecaptchaResponse": captchaToken,     // real hash — validated by backend
//            "sessionId":          captchaSessionId  // real UUID — paired with hash
//        ]
//        post(kBase + "ValidateRegistration", params: params, completion: completion)
//    }
//
//    // MARK: - getSignUpEmailOtp (web: sendEmailOtpForSignUp — after ValidateRegistration)
//    // Payload: { email, temp_merchant_id }
////    func getSignUpEmailOtp(email: String, tempMerchantId: String, completion: @escaping RegCallback) {
////        post(kBase + "getSignUpEmailOtp",
////             params: ["email": email, "temp_merchant_id": tempMerchantId],
////             completion: completion)
////    }
//    func sendEmailOtp(email: String, tempMerchantId: String, completion: @escaping RegCallback) {
//        post(kBase + "sendEmailOtp",
//             params: [
//                "email": email,
//                "temp_merchant_id": tempMerchantId
//             ],
//             completion: completion)
//    }
//    func completeRegistration(
//        orgName: String,
//        firstName: String,
//        lastName: String,
//        email: String,
//        password: String,
//        tempMerchantId: String,
//        emailOtp: String,
//        country: String,
//        completion: @escaping RegCallback
//    ) {
//
//        let params: Parameters = [
//            "organization_name": orgName,
//            "first_name": firstName,
//            "last_name": lastName,
//            "email": email,
//            "password": password,
//            "temp_merchant_id": tempMerchantId,
//            "email_otp": emailOtp,
//            "country": country
//        ]
//
//        post(kBase + "registration", params: params, completion: completion)
//    }
//
//    // MARK: - getSignUpPhoneOtp
//    func getSignUpPhoneOtp(phone: String, tempMerchantId: String, completion: @escaping RegCallback) {
//        post(kBase + "getSignUpPhoneOtp",
//             params: ["phone": phone, "temp_merchant_id": tempMerchantId],
//             completion: completion)
//    }
//
//    // MARK: - Internal
//
//    private func post(_ url: String, params: Parameters, completion: @escaping RegCallback) {
//        Alamofire.request(url,
//                          method: .post,
//                          parameters: params,
//                          encoding: JSONEncoding.default,
//                          headers: webHeaders)
//            .responseString { r in Self.parse(r, url: url, completion: completion) }
//    }
//
//    private static func parse(_ response: DataResponse<String>,
//                               url: String,
//                               completion: RegCallback) {
//        let code = response.response?.statusCode ?? 0
//        let body = response.value ?? ""
//
//        #if DEBUG
//        let label = url.components(separatedBy: "/").last ?? url
//        print("─── [\(code)] \(label)")
//        print("    \(body.prefix(400))")
//        #endif
//
//        guard response.result.isSuccess,
//              let data = body.data(using: .utf8),
//              let json  = try? JSON(data: data) else {
//            completion(false, JSON(), "Server error (\(code)).")
//            return
//        }
//
//        // Array format: [{error, error_msg}]
//        if let first = json.array?.first {
//            let err = first["error"].stringValue
//            let msg = first["error_msg"].stringValue
//            completion(err == "0", first, err == "0" ? "" : msg)
//            return
//        }
//
//        // Object format: {error, error_msg}
//        let err = json["error"].stringValue
//        let msg = json["error_msg"].stringValue
//        completion(err == "0", json, err == "0" ? "" : msg)
//    }
//}



//  RegisterService.swift
//  Trading_Terminal

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

private let kBase = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/"

private var webHeaders: [String: String] {
    [
        "Content-Type": "application/json",
        "Accept":       "application/json, text/plain, */*",
        "Origin":       "https://trade.paybito.com",
        "Referer":      "https://trade.paybito.com/",
        "User-Agent":   "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
    ]
}

typealias RegCallback = (_ success: Bool, _ json: JSON, _ errorMsg: String) -> Void

final class RegisterService {

    static let shared = RegisterService()
    private init() {}

    // MARK: - emailCheck
    func emailCheck(email: String, completion: @escaping RegCallback) {
        post(kBase + "emailCheck",
             params: ["email": email],
             completion: completion)
    }

    // MARK: - checkPhoneNo
    func checkPhoneNo(phone: String,
                      countryCode: String,
                      completion: @escaping RegCallback) {
        post(kBase + "checkPhoneNo",
             params: ["phone": phone, "countryCode": countryCode],
             completion: completion)
    }

    // MARK: - validateRegistration
    // captchaToken = JWT token returned by /solve endpoint
    // sent as gRecaptchaResponse to the backend
    func validateRegistration(
        orgName:        String,
        firstName:      String,
        lastName:       String,
        email:          String,
        password:       String,
        retypePassword: String,
        phone:          String,
        countryCode:    String,
        gender:         String,
        country:        String,
        captchaToken:   String,     // ← JWT from recaptcha /solve
        brokerId:       String,
        completion:     @escaping RegCallback
    ) {
        let cleanCountryCode = countryCode.hasPrefix("+")
             ? String(countryCode.dropFirst())
             : countryCode
         
         let params: [String: Any] = [
             "organization_name":  orgName,
             "first_name":         firstName,
             "last_name":          lastName,
             "email":              email,
             "password":           password,
             "retype_password":    retypePassword,
             "phone":              phone,
             "countryCode":        cleanCountryCode,  // ✅ "1" not "+1"
             "gender":             gender,
             "country":            country,
             "brokerId":           brokerId,
             "gRecaptchaResponse": captchaToken
         ]
        post(kBase + "ValidateRegistration", params: params, completion: completion)
    }

    // MARK: - sendEmailOtp
    func sendEmailOtp(email: String,
                      tempMerchantId: String,
                      completion: @escaping RegCallback) {
        post(kBase + "sendEmailOtp",
             params: [
                "email":            email,
                "temp_merchant_id": tempMerchantId
             ],
             completion: completion)
    }

    // MARK: - completeRegistration
    func completeRegistration(
        orgName:        String,
        firstName:      String,
        lastName:       String,
        email:          String,
        password:       String,
        tempMerchantId: String,
        emailOtp:       String,
        country:        String,
        completion:     @escaping RegCallback
    ) {
        let params: [String: Any] = [
            "organization_name": orgName,
            "first_name":        firstName,
            "last_name":         lastName,
            "email":             email,
            "password":          password,
            "temp_merchant_id":  tempMerchantId,
            "email_otp":         emailOtp,
            "country":           country
        ]
        post(kBase + "registration", params: params, completion: completion)
    }

    // MARK: - getSignUpPhoneOtp
    func getSignUpPhoneOtp(phone: String,
                           tempMerchantId: String,
                           completion: @escaping RegCallback) {
        post(kBase + "getSignUpPhoneOtp",
             params: ["phone": phone, "temp_merchant_id": tempMerchantId],
             completion: completion)
    }

    // MARK: - Private helpers

    private func post(_ url: String,
                      params: [String: Any],
                      completion: @escaping RegCallback) {
        Alamofire.request(url,
                          method: .post,
                          parameters: params,
                          encoding: JSONEncoding.default,
                          headers: webHeaders)
            .responseString { r in
                Self.parse(r, url: url, completion: completion)
            }
    }

    private static func parse(_ response: DataResponse<String>,
                               url: String,
                               completion: RegCallback) {
        let code = response.response?.statusCode ?? 0
        let body = response.value ?? ""

        #if DEBUG
        let label = url.components(separatedBy: "/").last ?? url
        print("─── [\(code)] \(label)")
        print("    \(body.prefix(400))")
        #endif

        guard response.result.isSuccess,
              let data = body.data(using: .utf8),
              let json = try? JSON(data: data) else {
            completion(false, JSON(), "Server error (\(code)).")
            return
        }

        // Array format: [{ error, error_msg }]
        if let first = json.array?.first {
            let err = first["error"].stringValue
            let msg = first["error_msg"].stringValue
            completion(err == "0", first, err == "0" ? "" : msg)
            return
        }

        // Object format: { error, error_msg }
        let err = json["error"].stringValue
        let msg = json["error_msg"].stringValue
        completion(err == "0", json, err == "0" ? "" : msg)
    }
}
