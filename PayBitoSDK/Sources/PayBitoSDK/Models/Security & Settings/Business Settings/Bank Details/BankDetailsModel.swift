//
//  BankDetailsModels.swift
//  PaymentsTerminal
//
//  Created by HashCash on 25/05/26.
//
//  Fixed to match actual API response:
//    • "has_error" key absent  → derived from error_data != 0 || !error_msg.isEmpty
//    • "error_data" is Int     → changed from String to Int
//    • "bank_details" is null  → BankDetails? (Optional)

import Foundation

// MARK: - BankDetails

struct BankDetailsModel: Codable {
    
    let bankDetailsId:        Int?
    let userId:               Int?
    let uuid:                 String?
    let benificiaryName:      String?   // API key: benificiary_name (intentional API typo)
    let bankName:             String?   // API key: bank_name
    let accountNo:            String?   // API key: account_no
    let accountType:          String?   // API key: accountType (camelCase)
    let routingNo:            String?   // API key: routing_no
    let swiftCode:            String?   // API key: swiftCode (camelCase)
    let ifscCode:             String?   // API key: ifscCode (camelCase)
    let verificationAmount:   Double?   // API key: verification_amount
    let bankUserName:         String?   // API key: bank_user_name
    let bankAddress:          String?   // API key: bankAddress (camelCase)
    let bankCheque:           String?   // API key: bank_cheque
    let isSubmitted:          Bool?     // NOT in current API response → Optional
    let bankVerificationDocType: String?  
 
    // MARK: Computed
 
    /// True only when API explicitly sends true; nil/absent → false
    var isSubmittedSafe: Bool {
        guard let id = bankDetailsId else { return false }
        return id > 0
    }
    
    
 
    /// IFSC → SWIFT → routing, first non-empty wins
    var displayBankCode: String {
        if let v = ifscCode,  !v.isEmpty { return v }
        if let v = swiftCode, !v.isEmpty { return v }
        return routingNo ?? "N/A"
    }
    
 
    // MARK: CodingKeys — mirrors actual API field names exactly
 
    enum CodingKeys: String, CodingKey {
        case bankDetailsId      = "bankDetailsId"       // camelCase
        case userId             = "userId"              // camelCase
        case uuid               = "uuid"
        case benificiaryName    = "benificiary_name"    // snake_case
        case bankName           = "bank_name"           // snake_case
        case accountNo          = "account_no"          // snake_case
        case accountType        = "accountType"         // camelCase
        case routingNo          = "routing_no"          // snake_case
        case swiftCode          = "swiftCode"           // camelCase
        case ifscCode           = "ifscCode"            // camelCase
        case verificationAmount = "verification_amount" // snake_case
        case bankUserName       = "bank_user_name"      // snake_case
        case bankAddress        = "bankAddress"         // camelCase
        case bankCheque         = "bank_cheque"         // snake_case
        case isSubmitted        = "is_submitted"        // absent → Optional handles it
        case bankVerificationDocType = "bankVerificationDocType"
    }
}
 
// MARK: - BankDetailsError
//
// { "error_data": 0, "error_msg": "" }
// "has_error" never present → derived
 
struct BankDetailsError: Codable {
    let errorData: Int
    let errorMsg:  String
 
    var hasError: Bool { errorData != 0 || !errorMsg.isEmpty }
 
    enum CodingKeys: String, CodingKey {
        case errorData = "error_data"
        case errorMsg  = "error_msg"
    }
}
 
// MARK: - BankDetailsResponse
//
// { "bankDetails": { … } | null, "error": { … } }
 
struct BankDetailsResponse: Codable {
    let bankDetails: BankDetailsModel?   // null when user has no bank on file
    let error:       BankDetailsError
 
    enum CodingKeys: String, CodingKey {
        case bankDetails = "bankDetails"  // camelCase in API envelope
        case error       = "error"
    }
}
