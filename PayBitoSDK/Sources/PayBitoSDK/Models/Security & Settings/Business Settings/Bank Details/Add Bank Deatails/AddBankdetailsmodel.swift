//
//  BankDetailsModel.swift
//  Trading_Terminal
//

import Foundation

// MARK: - AccountType

enum AccountType: String, CaseIterable {
    case personalSavings = "Personal Savings"
    case business        = "Business"
    case current         = "Current"
    case businessSavings = "Business Savings"
}

// MARK: - CodeType

enum CodeType: String, CaseIterable {
    case ifsc  = "IFSC CODE"
    case swift = "SWIFT CODE"
}

// MARK: - APIError

struct APIError: Decodable {
    let error_data: Int?
    let error_msg:  String?

    var errorData: Int   { error_data ?? 0 }
    var errorMsg: String { error_msg  ?? "" }
    var hasError: Bool   { errorData != 0 && !errorMsg.isEmpty }
}

// MARK: - BankDetail

struct AddBankDetail: Decodable {
    let bankDetailsId:       Int?
    let userId:              Int?
    let uuid:                String?
    let benificiary_name:    String?
    let bank_name:           String?
    let account_no:          String?
    let accountType:         String?
    let routing_no:          String?
    let swiftCode:           String?
    let ifscCode:            String?
    let verification_amount: Double?
    let bank_user_name:      String?
    let bankAddress:         String?
    let bank_cheque:         String?

    var benificiaryName: String? { benificiary_name }
    var accountNo:       String? { account_no }
    var bankName:        String? { bank_name }
    var routingNo:       String? { routing_no }
}

// MARK: - BankDetailsResponse (fetch)

struct AddBankDetailsResponse: Decodable {
    let bankDetails: AddBankDetail?
    let error: APIError
}

// MARK: - UpdateBankDetailsResponse (save)

struct UpdateBankDetailsResponse: Decodable {
    let bankDetails: AddBankDetail?
    let error: APIError
}
