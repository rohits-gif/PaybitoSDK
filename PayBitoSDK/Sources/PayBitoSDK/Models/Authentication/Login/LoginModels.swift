////
////  LoginModels.swift
////  Trading_Terminal
////
////  Created by Sk Jasimuddin on 09/04/26.
////
//
//import Foundation
//
//import Foundation
//
//struct LoginResponse: Codable {
//    let error: Int
//    let error_msg: String?
//    let merchant_id: Int?
//    let email: String?
//    let first_name: String?
//    let last_name: String?
//    let phone: String?
//    let google_auth_enabled: String?
//    let phone_auth_enabled: String?
//    let oauth2: OAuth?
//    let uuid: String?
//}
//
//struct OAuth: Codable {
//    let access_token: String?
//    let refresh_token: String?
//}

//  LoginModels.swift
//  Request + Response models for the BillBitcoins login flow.

////  LoginModels.swift
////  Trading_Terminal
////
////  Created by Sk Jasimuddin on 09/04/26.
////
//
//import Foundation
//
//import Foundation
//
//struct LoginResponse: Codable {
//    let error: Int
//    let error_msg: String?
//    let merchant_id: Int?
//    let email: String?
//    let first_name: String?
//    let last_name: String?
//    let phone: String?
//    let google_auth_enabled: String?
//    let phone_auth_enabled: String?
//    let oauth2: OAuth?
//    let uuid: String?
//}
//
//struct OAuth: Codable {
//    let access_token: String?
//    let refresh_token: String?
//}

//  LoginModels.swift
//  Request + Response models for the BillBitcoins login flow.

import Foundation

// MARK: - Request Models

struct CheckMGAStatusRequest: Encodable {
    let email: String
    let password: String
}

struct SendEmailOTPRequest: Encodable {
    let email: String
}

struct LoginDetailsRequest: Encodable {
    let email: String
    let password: String
    let emailOtp: String
    let deviceType: String = "ios"

    enum CodingKeys: String, CodingKey {
        case email, password, deviceType
        case emailOtp = "emailOtp"
    }
}

struct FetchMerchantStatusRequest: Encodable {
    let merchant_id: Int
}

// MARK: - Response Models

struct MGAStatusResponse: Decodable {
    let error: Int?
    let error_msg: String?
    let mgaStatus: String?       // "1" = active
    let twoFactorEnabled: String?
    let googleAuthEnabled: String?
    let phoneNo: String?

    // Fallback flat keys some endpoints use
    private enum CodingKeys: String, CodingKey {
        case error, error_msg
        case mgaStatus        = "mga_status"
        case twoFactorEnabled = "two_factor_auth_enabled"
        case googleAuthEnabled = "google_auth_enabled"
        case phoneNo          = "phone_no"
    }
}

struct LoginDetailsResponse: Decodable {
    let error: Int?
    let error_msg: String?
    let access_token: String?
    let uuid: String?
    let merchant_id: String?
    let email: String?
    let first_name: String?
    let last_name: String?
    let phone_no: String?
    let two_factor_auth_enabled: String?
    let google_auth_enabled: String?
    let profile_image: String?
}

struct MerchantStatusResponse: Decodable {
    let error: Int?
    let error_msg: String?
    let merchant_status: String?
}

struct BrokerInfoResponse: Decodable {
    let error: Int?
    let brokerId: String?
    let brokerName: String?
}





// MARK: - Generic API Error

enum LoginError: LocalizedError {
    case serverMessage(String)
    case networkFailure
    case sessionExpired
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverMessage(let msg): return msg
        case .networkFailure:  return "Network error. Please check your connection."
        case .sessionExpired:  return "Session expired. Please log in again."
        case .unknown:         return "Something went wrong. Please try again."
        }
    }
}
