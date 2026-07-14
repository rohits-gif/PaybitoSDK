// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  Forgotpasswordservice.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 23/04/26.
//

//import Foundation
//
//// MARK: - Base URL
//// Replace with your real backend origin or read from Info.plist / environment.
//private let kBaseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/ForgotPassword"
//
//// MARK: - Generic API response wrapper  (matches {error, error_msg} shape)
//
//struct APIBaseResponse: Decodable {
//    let error:    String
//    let error_msg: String
//}
//
//// MARK: - Request payloads
//
//struct ForgotPasswordPayload: Encodable {
//    let email:              String
//    let gRecaptchaResponse: String
//    let sessionId:          String
//}
//
//struct VerifyOTPPayload: Encodable {
//    let email: String
//    let otp:   String
//}
//
//struct ResetPasswordPayload: Encodable {
//    let email:       String
//    let otp:         String
//    let newPassword: String
//}
//
//struct ResendOTPPayload: Encodable {
//    let email: String
//}
//
//// MARK: - Errors
//
//enum ServiceError: LocalizedError {
//    case badURL
//    case invalidResponse
//    case apiError(String)
//
//    var errorDescription: String? {
//        switch self {
//        case .badURL:             return "Invalid URL."
//        case .invalidResponse:   return "The server returned an unexpected response."
//        case .apiError(let msg): return msg
//        }
//    }
//}
//
//// MARK: - MerchantForgotPasswordService
//
//enum MerchantForgotPasswordService {
//
//    // ── 1. Send reset e-mail (triggers captcha payload) ──────────────────────
//    /// Mirrors: MerchantForgotPassword(payload) in ForgotPassword.jsx
//    static func sendResetEmail(_ payload: ForgotPasswordPayload) async throws {
//        let url = try makeURL(path: "/merchant/forgot-password")
//        let response: [APIBaseResponse] = try await post(url: url, body: payload)
//        guard let first = response.first else { throw ServiceError.invalidResponse }
//        if first.error != "0" { throw ServiceError.apiError(first.error_msg) }
//    }
//
//    // ── 2. Verify OTP ─────────────────────────────────────────────────────────
//    /// Mirrors: POST /merchant/verify-forgot-otp in ForgotPasswordOTPView
//    static func verifyOTP(_ payload: VerifyOTPPayload) async throws {
//        let url = try makeURL(path: "/merchant/verify-forgot-otp")
//        let response: APIBaseResponse = try await post(url: url, body: payload)
//        if response.error != "0" { throw ServiceError.apiError(response.error_msg) }
//    }
//
//    // ── 3. Reset password ─────────────────────────────────────────────────────
//    /// Mirrors: POST /merchant/reset-password in ResetPasswordView
//    static func resetPassword(_ payload: ResetPasswordPayload) async throws {
//        let url = try makeURL(path: "/merchant/reset-password")
//        let response: APIBaseResponse = try await post(url: url, body: payload)
//        if response.error != "0" { throw ServiceError.apiError(response.error_msg) }
//    }
//
//    // ── 4. Resend OTP ─────────────────────────────────────────────────────────
//    /// Mirrors: POST /merchant/forgot-password/resend in ForgotPasswordOTPView
//    static func resendOTP(_ payload: ResendOTPPayload) async throws {
//        let url = try makeURL(path: "/merchant/forgot-password/resend")
//        let _: APIBaseResponse = try await post(url: url, body: payload)
//        // No error check needed — caller can ignore silently
//    }
//
//    // MARK: - Helpers
//
//    private static func makeURL(path: String) throws -> URL {
//        guard let url = URL(string: kBaseURL + path) else { throw ServiceError.badURL }
//        return url
//    }
//
//    /// Generic POST that encodes `body` as JSON and decodes `T` from the response.
//    @discardableResult
//    private static func post<Body: Encodable, Response: Decodable>(
//        url: URL,
//        body: Body
//    ) async throws -> Response {
//        var request       = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody  = try JSONEncoder().encode(body)
//
//        let (data, urlResponse) = try await URLSession.shared.data(for: request)
//
//        guard let http = urlResponse as? HTTPURLResponse,
//              (200...299).contains(http.statusCode) else {
//            throw ServiceError.invalidResponse
//        }
//
//        // The API sometimes wraps the item in an array — try both shapes.
//        if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
//            return decoded
//        }
//        if let array = try? JSONDecoder().decode([Response].self, from: data),
//           let first = array.first {
//            return first
//        }
//        throw ServiceError.invalidResponse
//    }
//}



//  Forgotpasswordservice.swift
//  Trading_Terminal

import Foundation

// MARK: - Base URL
private let kBaseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant"

// MARK: - Generic API response wrapper

struct APIBaseResponse: Decodable {
    let error:     String
    let error_msg: String
}

// Public alias so other files can use ForgotPasswordResponse
// without redeclaring the struct
//typealias ForgotPasswordResponse = APIBaseResponse

// MARK: - Request payloads

struct ForgotPasswordPayload: Encodable {
    let email:              String
    let gRecaptchaResponse: String  // ← JWT from /solve, no sessionId needed
}

struct VerifyOTPPayload: Encodable {
    let email: String
    let otp:   String
}

struct ResetPasswordPayload: Encodable {
    let email:       String
    let otp:         String
    let newPassword: String
}

struct ResendOTPPayload: Encodable {
    let email: String
}

// MARK: - Errors

enum ServiceError: LocalizedError {
    case badURL
    case invalidResponse
    case emptyResponse
    case encodingFailed
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .badURL:             return "Invalid URL."
        case .invalidResponse:   return "The server returned an unexpected response."
        case .emptyResponse:  return "Empty Response"
        case .encodingFailed:    return "Failed to encode request payload." 
            
        case .apiError(let msg): return msg
        }
    }
}

// MARK: - MerchantForgotPasswordService

enum MerchantForgotPasswordService {

    // ── 1. Send reset email
    static func sendResetEmail(_ payload: ForgotPasswordPayload) async throws {
        let url = try makeURL(path: "/ForgotPassword")
        let response: [APIBaseResponse] = try await post(url: url, body: payload)
        guard let first = response.first else { throw ServiceError.invalidResponse }
        if first.error != "0" { throw ServiceError.apiError(first.error_msg) }
    }

    // ── 2. Verify OTP
    static func verifyOTP(_ payload: VerifyOTPPayload) async throws {
        let url = try makeURL(path: "/verify-forgot-otp")
        let response: APIBaseResponse = try await post(url: url, body: payload)
        if response.error != "0" { throw ServiceError.apiError(response.error_msg) }
    }

    // ── 3. Reset password
    static func resetPassword(_ payload: ResetPasswordPayload) async throws {
        let url = try makeURL(path: "/reset-password")
        let response: APIBaseResponse = try await post(url: url, body: payload)
        if response.error != "0" { throw ServiceError.apiError(response.error_msg) }
    }

    // ── 4. Resend OTP
    static func resendOTP(_ payload: ResendOTPPayload) async throws {
        let url = try makeURL(path: "/forgot-password/resend")
        let _: APIBaseResponse = try await post(url: url, body: payload)
    }

    // MARK: - Helpers

    private static func makeURL(path: String) throws -> URL {
        guard let url = URL(string: kBaseURL + path) else { throw ServiceError.badURL }
        return url
    }

    @discardableResult
    private static func post<Body: Encodable, Response: Decodable>(
        url: URL,
        body: Body
    ) async throws -> Response {
        var request        = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json",           forHTTPHeaderField: "Content-Type")
        request.setValue("https://trade.paybito.com",  forHTTPHeaderField: "Origin")
        request.setValue("https://trade.paybito.com/", forHTTPHeaderField: "Referer")
        request.setValue(
            "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
            forHTTPHeaderField: "User-Agent"
        )
        request.httpBody = try JSONEncoder().encode(body)

        #if DEBUG
        print("\n🚀 REQUEST URL:", url.absoluteString)
        print("📤 REQUEST BODY:", String(data: request.httpBody!, encoding: .utf8) ?? "nil")
        #endif

        let (data, urlResponse) = try await URLSession.shared.data(for: request)

        #if DEBUG
        if let http = urlResponse as? HTTPURLResponse {
            print("📥 STATUS CODE:", http.statusCode)
        }
        print("📥 RAW RESPONSE:", String(data: data, encoding: .utf8) ?? "nil")
        #endif

        guard let http = urlResponse as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw ServiceError.invalidResponse
        }

        if let decoded = try? JSONDecoder().decode(Response.self, from: data) {
            return decoded
        }
        if let array = try? JSONDecoder().decode([Response].self, from: data),
           let first  = array.first {
            return first
        }
        throw ServiceError.invalidResponse
    }
}
