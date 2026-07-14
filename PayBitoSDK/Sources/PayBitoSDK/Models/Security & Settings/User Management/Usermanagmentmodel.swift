//
//  Usermanagmentmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  UserManagementModel.swift
//  Trading_Terminal
//

import Foundation

// MARK: - Account Status

enum UserAccountStatus: Int {
    case accountUnlocked              = 0
    case accountDisabled              = 1
    case accountOpened                = 2
    case emailConfirmed               = 3
    case bankVerificationPending      = 4
    case bankVerified                 = 5
    case basicVerificationRequested   = 6
    case basicVerificationSuccess     = 7
    case businessPlanRequested        = 8
    case businessPlanActivated        = 9
    case enterprisePlanRequested      = 10
    case enterprisePlanActivated      = 11
    case accountDeleted               = 40

    var displayName: String {
        switch self {
        case .accountUnlocked:              return "Account Unlocked"
        case .accountDisabled:              return "Account Disabled"
        case .accountOpened:                return "Account Opened"
        case .emailConfirmed:               return "Email Confirmed"
        case .bankVerificationPending:      return "Bank Verification Pending"
        case .bankVerified:                 return "Bank Verified"
        case .basicVerificationRequested:   return "Basic Verification Requested"
        case .basicVerificationSuccess:     return "Basic Verification Success"
        case .businessPlanRequested:        return "Business Plan Requested"
        case .businessPlanActivated:        return "Business Plan Activated"
        case .enterprisePlanRequested:      return "Enterprise Plan Requested"
        case .enterprisePlanActivated:      return "Enterprise Plan Activated"
        case .accountDeleted:               return "Account Deleted"
        }
    }

    static func from(_ id: Int) -> String {
        return UserAccountStatus(rawValue: id)?.displayName ?? "Unknown (\(id))"
    }
}

// MARK: - API Response Models

struct SubMerchantListResponse: Codable {
    let errorMsg: String
    let error:    Int
    let list:     [SubMerchantAPIModel]

    enum CodingKeys: String, CodingKey {
        case errorMsg = "error_msg"
        case error
        case list
    }
}

struct SubMerchantAPIModel: Codable {
    let merchantStatusId:  Int
    let phone:             String
    let brokerId:          String
    let accountStatusId:   Int
    let lastName:          String
    let parentMerchantId:  Int
    let accessList:        [MenuAccess]
    let merchantId:        Int
    let firstName:         String
    let uuid:              String
    let email:             String

    enum CodingKeys: String, CodingKey {
        case merchantStatusId  = "merchant_status_id"
        case phone
        case brokerId          = "broker_id"
        case accountStatusId   = "account_status_id"
        case lastName          = "last_name"
        case parentMerchantId  = "parent_merchant_id"
        case accessList        = "access_list"
        case merchantId        = "merchant_id"
        case firstName         = "first_name"
        case uuid
        case email
    }

    /// Convenience: human-readable status
    var accountStatusDisplay: String {
        UserAccountStatus.from(accountStatusId)
    }

    /// Convenience: full name
    var fullName: String { "\(firstName) \(lastName)" }

    /// Convenience: avatar initials
    var initials: String {
        [firstName.first, lastName.first]
            .compactMap { $0 }
            .map(String.init)
            .joined()
            .uppercased()
    }
}

struct MenuAccess: Codable {
    let access:                 String   // "READ" or "WRITE"
    let name:                   String
    let merchantId:             Int
    let merchantMenuMappingId:  Int
    let menuId:                 Int

    enum CodingKeys: String, CodingKey {
        case access
        case name
        case merchantId             = "merchant_id"
        case merchantMenuMappingId  = "merchant_menu_mapping_id"
        case menuId                 = "menu_id"
    }
}

// MARK: - Request Model

struct SubMerchantListRequest: Encodable {
    let merchantId: String

    enum CodingKeys: String, CodingKey {
        case merchantId = "merchant_id"
    }
}

