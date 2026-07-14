// MARK: - TwofaUserSettingsModel.swift

import Foundation

// MARK: - FetchUserSettings Response

struct TwofaUserSettingsResponse: Codable {
    let phoneNo:                String?
    let twoFactorAuthEnabled:   Int
    let countryCode:            String?
    let existTwoFAKey:          String?
    let publishableKey:         String?
    let errorMsg:               String?
    let enableMerchantReferral: Int?
    let lastName:               String?
    let error:                  String?
    let firstName:              String?
    let googleAuthEnabled:      Int     // 0 = OFF, 1 = fully ON
    let phoneAuthEnabled:       Int     // 0 = OFF, 1 = ON

    enum CodingKeys: String, CodingKey {
        case phoneNo                 = "phone_no"
        case twoFactorAuthEnabled    = "two_factor_auth_enabled"
        case countryCode             = "country_code"
        case existTwoFAKey           = "EXIST_2FA_KEY"
        case publishableKey          = "publishable_key"
        case errorMsg                = "error_msg"
        case enableMerchantReferral  = "enable_merchant_referral"
        case lastName                = "last_name"
        case error                   = "error"
        case firstName               = "first_name"
        case googleAuthEnabled       = "google_auth_enabled"
        case phoneAuthEnabled        = "phone_auth_enabled"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        phoneNo                 = try c.decodeIfPresent(String.self, forKey: .phoneNo)
        countryCode             = try c.decodeIfPresent(String.self, forKey: .countryCode)
        existTwoFAKey           = try c.decodeIfPresent(String.self, forKey: .existTwoFAKey)
        publishableKey          = try c.decodeIfPresent(String.self, forKey: .publishableKey)
        errorMsg                = try c.decodeIfPresent(String.self, forKey: .errorMsg)
        lastName                = try c.decodeIfPresent(String.self, forKey: .lastName)
        error                   = try c.decodeIfPresent(String.self, forKey: .error)
        firstName               = try c.decodeIfPresent(String.self, forKey: .firstName)
        enableMerchantReferral  = try Self.flexInt(c, key: .enableMerchantReferral)

        twoFactorAuthEnabled    = try Self.flexInt(c, key: .twoFactorAuthEnabled) ?? 0
        googleAuthEnabled       = try Self.flexInt(c, key: .googleAuthEnabled)    ?? 0
        phoneAuthEnabled        = try Self.flexInt(c, key: .phoneAuthEnabled)     ?? 0
    }

    private static func flexInt(
        _ c: KeyedDecodingContainer<CodingKeys>,
        key: CodingKeys
    ) throws -> Int? {
        if let intVal = try? c.decodeIfPresent(Int.self, forKey: key) { return intVal }
        if let strVal = try? c.decodeIfPresent(String.self, forKey: key) { return Int(strVal) }
        return nil
    }
}

// MARK: - GetTwoFactorykey Response
// Confirmed from screenshot 4:
// { "error_msg": "successful", "google_auth_key": "JVIGANXPEEOT6WBACZXSV5D3PFSTVNMB",
//   "error": "0", "GA_enabled_status": "1" }

struct GetTwoFactoryKeyResponse: Codable {
    let errorMsg:        String?
    let googleAuthKey:   String?   // The TOTP secret → used to build OTP Auth URL for QR
    let error:           String?
    let gaEnabledStatus: String?   // "1" = success

    enum CodingKeys: String, CodingKey {
        case errorMsg        = "error_msg"
        case googleAuthKey   = "google_auth_key"
        case error           = "error"
        case gaEnabledStatus = "GA_enabled_status"
    }

    var isSuccess: Bool {
        (error ?? "1") == "0"
    }
}

// MARK: - SaveTwoFactorSettings Response
// Confirmed from screenshot 5 (content-length 61)

struct SaveTwoFactorSettingsResponse: Codable {
    let error:    String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case error    = "error"
        case errorMsg = "error_msg"
    }

    var isSuccess: Bool { (error ?? "1") == "0" }
}

// MARK: - Request Payload

struct TwofaFetchUserSettingsRequest: Encodable {
    let merchantId: Int
    enum CodingKeys: String, CodingKey { case merchantId = "merchant_id" }
}

// MARK: - 2FA Toggle State

enum TwoFAState: CustomStringConvertible {
    /// google_auth_enabled == 1
    case fullyEnabled
    /// two_factor_auth_enabled == 1, google_auth_enabled == 0
    case partialSetup
    /// Both == 0
    case neverSetup

    init(twoFactorAuthEnabled: Int, googleAuthEnabled: Int) {
        switch (twoFactorAuthEnabled, googleAuthEnabled) {
        case (_, 1): self = .fullyEnabled
        case (1, 0): self = .partialSetup
        default:     self = .neverSetup
        }
    }

    var isToggleOn:       Bool    { self == .fullyEnabled }
    var showsPartialBadge: Bool   { self == .partialSetup }
    var statusLabel:      String? {
        switch self {
        case .partialSetup: return "⚠️ Setup incomplete — tap to complete"
        default:            return nil
        }
    }
    var description: String {
        switch self {
        case .fullyEnabled: return "fullyEnabled"
        case .partialSetup: return "partialSetup"
        case .neverSetup:   return "neverSetup"
        }
    }
}













//// MARK: - TwofaUserSettingsModel.swift
//// Trading_Terminal
//
//import Foundation
//
//// MARK: - Response Wrapper
//
//struct TwofaUserSettingsResponse: Codable {
//    let phoneNo:                String?
//    let twoFactorAuthEnabled:   Int
//    let countryCode:            String?
//    let existTwoFAKey:          String?
//    let publishableKey:         String?
//    let errorMsg:               String?
//    let enableMerchantReferral: Int?
//    let lastName:               String?
//    let error:                  String?
//    let firstName:              String?
//    let googleAuthEnabled:      Int     // 0 = OFF, 1 = fully ON
//    let phoneAuthEnabled:       Int     // 0 = OFF, 1 = ON
//
//    enum CodingKeys: String, CodingKey {
//        case phoneNo                 = "phone_no"
//        case twoFactorAuthEnabled    = "two_factor_auth_enabled"
//        case countryCode             = "country_code"
//        case existTwoFAKey           = "EXIST_2FA_KEY"
//        case publishableKey          = "publishable_key"
//        case errorMsg                = "error_msg"
//        case enableMerchantReferral  = "enable_merchant_referral"
//        case lastName                = "last_name"
//        case error                   = "error"
//        case firstName               = "first_name"
//        case googleAuthEnabled       = "google_auth_enabled"
//        case phoneAuthEnabled        = "phone_auth_enabled"
//    }
//
//    // MARK: - Flexible Int decoder
//    // The API inconsistently returns these fields as Int (1) or String ("1").
//    // This custom init handles both so JSONDecoder never throws a type mismatch.
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//
//        phoneNo                 = try c.decodeIfPresent(String.self, forKey: .phoneNo)
//        countryCode             = try c.decodeIfPresent(String.self, forKey: .countryCode)
//        existTwoFAKey           = try c.decodeIfPresent(String.self, forKey: .existTwoFAKey)
//        publishableKey          = try c.decodeIfPresent(String.self, forKey: .publishableKey)
//        errorMsg                = try c.decodeIfPresent(String.self, forKey: .errorMsg)
//        lastName                = try c.decodeIfPresent(String.self, forKey: .lastName)
//        error                   = try c.decodeIfPresent(String.self, forKey: .error)
//        firstName               = try c.decodeIfPresent(String.self, forKey: .firstName)
//        enableMerchantReferral  = try Self.flexInt(c, key: .enableMerchantReferral)
//
//        twoFactorAuthEnabled    = try Self.flexInt(c, key: .twoFactorAuthEnabled)  ?? 0
//        googleAuthEnabled       = try Self.flexInt(c, key: .googleAuthEnabled)     ?? 0
//        phoneAuthEnabled        = try Self.flexInt(c, key: .phoneAuthEnabled)      ?? 0
//    }
//
//    /// Decodes an Int field that the API may send as either Int or String.
//    private static func flexInt(
//        _ c: KeyedDecodingContainer<CodingKeys>,
//        key: CodingKeys
//    ) throws -> Int? {
//        if let intVal = try? c.decodeIfPresent(Int.self, forKey: key) {
//            return intVal
//        }
//        if let strVal = try? c.decodeIfPresent(String.self, forKey: key) {
//            return Int(strVal)
//        }
//        return nil
//    }
//}
//
//// MARK: - Request Payload
//// merchantId is sent as Int over the wire — matches TwofaUserSettingsService exactly.
//
//struct TwofaFetchUserSettingsRequest: Encodable {
//    let merchantId: Int
//
//    enum CodingKeys: String, CodingKey {
//        case merchantId = "merchant_id"
//    }
//}
//
//// MARK: - 2FA Toggle State
//
//enum TwoFAState: CustomStringConvertible {
//
//    /// google_auth_enabled == 1 — toggle ON, fully working
//    case fullyEnabled
//
//    /// two_factor_auth_enabled == 1, google_auth_enabled == 0
//    /// — user started setup but never finished; show recovery prompt
//    case partialSetup
//
//    /// Both == 0 — user has never touched 2FA
//    case neverSetup
//
//    init(twoFactorAuthEnabled: Int, googleAuthEnabled: Int) {
//        switch (twoFactorAuthEnabled, googleAuthEnabled) {
//        case (_, 1):    self = .fullyEnabled
//        case (1, 0):    self = .partialSetup
//        default:        self = .neverSetup
//        }
//    }
//
//    // MARK: Toggle visibility
//
//    /// Toggle should appear ON only when fully enabled.
//    var isToggleOn: Bool { self == .fullyEnabled }
//
//
//
//    // MARK: UI helpers consumed by TwofaSecuritySectionView
//
//    /// Show the warning badge for incomplete setup.
//    var showsPartialBadge: Bool { self == .partialSetup }
//
//    /// Human-readable label shown below the toggle when relevant.
//    var statusLabel: String? {
//        switch self {
//        case .fullyEnabled:  return nil
//        case .partialSetup:  return "⚠️ Setup incomplete — tap to complete"
//        case .neverSetup:    return nil
//        }
//    }
//
//    // MARK: CustomStringConvertible — cleaner debug logs
//    var description: String {
//        switch self {
//        case .fullyEnabled: return "fullyEnabled"
//        case .partialSetup: return "partialSetup"
//        case .neverSetup:   return "neverSetup"
//        }
//    }
//}
