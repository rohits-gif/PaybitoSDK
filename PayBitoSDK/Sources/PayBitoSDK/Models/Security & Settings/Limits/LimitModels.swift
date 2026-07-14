//
//  LimitModels.swift
//  Trading_Terminal
//

import Foundation

// MARK: - Merchant Settings Response
struct MerchantSettingsResponse: Codable {
    let txnCharges: String
    let industryID: Int
    let industryName: String
    let website: String
    let notificationEmail: String
    let errorMsg: String
    let volumeID: Int
    let organizationDesc: String
    let supportPhone: String
    let volumeName: String
    let merchantID: Int
    let organizationName: String
    let error: String
    let sendNotificationViaMail: Int
    let supportEmail: String
    let acceptUnderpayments: String
    let isProcessingFeeEnabled: String
    let plans: [VolumePlan]
    let dailyAmountCap: Int
    let acceptOverpayments: String
    let monthlyTransactionCap: Int

    enum CodingKeys: String, CodingKey {
        case txnCharges              = "TXN_CHARGES"
        case industryID              = "industry_id"
        case industryName            = "industry_name"
        case website
        case notificationEmail       = "notification_email"
        case errorMsg                = "error_msg"
        case volumeID                = "volume_id"
        case organizationDesc        = "organization_desc"
        case supportPhone            = "support_phone"
        case volumeName              = "volume_name"
        case merchantID              = "merchant_id"
        case organizationName        = "organization_name"
        case error
        case sendNotificationViaMail = "send_notification_via_mail"
        case supportEmail            = "support_email"
        case acceptUnderpayments     = "accept_underpayments"
        case isProcessingFeeEnabled  = "is_processing_fee_enabled"
        case plans
        case dailyAmountCap          = "daily_amount_cap"
        case acceptOverpayments      = "accept_overpayments"
        case monthlyTransactionCap   = "monthly_transaction_cap"
    }
}

// MARK: - Volume Plan
struct VolumePlan: Codable, Identifiable {
    let volumeID: String
    let volumeName: String
    let dailyAmountCap: String
    let monthlyTransactionCap: String

    var id: String { volumeID }

    var formattedDailyCap: String {
        guard let value = Double(dailyAmountCap) else { return dailyAmountCap }
        return NumberFormatter.currencyFormatter.string(from: NSNumber(value: value)) ?? dailyAmountCap
    }

    var formattedMonthlyCap: String {
        guard let value = Double(monthlyTransactionCap) else { return monthlyTransactionCap }
        return NumberFormatter.countFormatter.string(from: NSNumber(value: value)) ?? monthlyTransactionCap
    }

    enum CodingKeys: String, CodingKey {
        case volumeID              = "volume_id"
        case volumeName            = "volume_name"
        case dailyAmountCap        = "daily_amount_cap"
        case monthlyTransactionCap = "monthly_transaction_cap"
    }
}

// MARK: - Activated Volume
struct ActivatedVolume: Codable {
    let volumeId: Int
    let volumeName: String
    let dailyAmountCap: Int
    let percentInsentiveAfterCap: Int
    let merchantId: Int
    let monthlyTransactionCap: Int
    let requestedVolumeId: Int?
    let requestedVolumeStatus: String?
    let remarks: String?
    let errorMsg: String?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case volumeId                 = "volume_id"
        case volumeName               = "volume_name"
        case dailyAmountCap           = "daily_amount_cap"
        case percentInsentiveAfterCap = "percent_insentive_after_cap"
        case merchantId               = "merchant_id"
        case monthlyTransactionCap    = "monthly_transaction_cap"
        case requestedVolumeId        = "requested_volume_id"
        case requestedVolumeStatus    = "requested_volume_status"
        case remarks
        case errorMsg                 = "error_msg"
        case error
    }
}

// MARK: - Submit Volume Response
struct SubmitVolumeResponse: Codable {
    let error: String
    let errorMsg: String
    let requestedId: Int?
    let message: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg    = "error_msg"
        case requestedId = "requested_id"
        case message
    }

    var isSuccess: Bool { error == "0" }
}

// MARK: - Apply Plan Form
struct ApplyPlanForm {
    var taxId: String = ""
    var website: String = ""
    var file1Data: Data?
    var file1Name: String = ""
    var file2Data: Data?
    var file2Name: String = ""
    var file3Data: Data?
    var file3Name: String = ""
    var file4Data: Data?
    var file4Name: String = ""
}

// MARK: - Number Formatters
extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()

    static let countFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f
    }()
}
