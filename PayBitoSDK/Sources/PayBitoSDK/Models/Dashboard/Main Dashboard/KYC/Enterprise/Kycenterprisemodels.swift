//// MARK: - KYCEnterpriseModels.swift
//// Models for Enterprise KYC Form API Integration
//
//import Foundation
//
//// MARK: - Request Model
//struct KYCEnterpriseRequest: Encodable {
//    // Company Info
//    var companyName: String = ""
//    var companyRegNo: String = ""
//    var incorporationCountry: String = ""
//    var companyWebsite: String = ""
//    var dbaName: String = ""
//    var businessPhoneNumber: String = ""
//    var businessEmailAddress: String = ""
//    var yearsInBusiness: String = ""
//    var businessDescription: String = ""
//    var stockExchangeName: String = ""
//    var stockTickerSymbol: String = ""
//
//    // Tax
//    var identificationType: String = ""
//    var identificationNumber: String = ""
//    var isExemptPayee: String = ""
//    var isNpo: Int = 0
//
//    // Registered Address
//    var companyregAddress: String = ""
//    var companyregCity: String = ""
//    var companyregState: String = ""
//    var companyregCountry: String = ""
//    var companyregZip: String = ""
//    var companyRegPremiseType: String = ""
//    var companyRegYearsInThisLocation: String = ""
//    var premiseOwner: String = ""
//    var areaZoned: String = ""
//    var squareFootage: String = ""
//    var numberOfLocations: String = ""
//
//    // Office Address
//    var companyOfficeAddress: String = ""
//    var companyOfficeCity: String = ""
//    var companyOfficeState: String = ""
//    var companyOfficeCountry: String = ""
//    var companyOfficeZip: String = ""
//    var companyOfficePremiseType: String = ""
//    var companyOfficeYearsInThisLocation: String = ""
//    var officePremiseOwner: String = ""
//    var officeAreaZoned: String = ""
//    var officeSquareFootage: String = ""
//
//    // Financial
//    var revenue: String = ""
//    var profit: String = ""
//    var companyAssets: String = ""
//    var companyNetWorth: String = ""
//
//    // Banking
//    var accountPurpose: String = ""
//    var investmentSource: String = ""
//    var transactionVolumes: String = ""
//    var transactionFrequency: String = ""
//    var bankingPartner: String = ""
//    var relationWithBank: String = ""
//
//    // Processing
//    var isProcessingCardTransaction: String = ""
//    var onlineTxnPct: String = ""
//    var inPersonSwipeTxnPct: String = ""
//    var overThePhoneTxnPct: String = ""
//    var keyEnteredTxnPct: String = ""
//    var amexMonthlyVolumeInUsd: Double = 0
//    var amexAvgTicketInUsd: Double = 0
//    var amexHighestTicketInUsd: Double = 0
//    var acceptAmexPayment: Int = 0
//    var transactionLimitInUsd: String = ""
//    var averageTransactionSizeInUsd: String = ""
//    var highestTransactionSizeInUsd: String = ""
//    var acceptAchPayment: String = ""
//
//    // Processing URLs
//    var paymentProcessingWebsiteUrl: String = ""
//    var demoLoginUsername: String = ""
//    var demoLoginPassword: String = ""
//
//    // Business Ops
//    var advertiseType: String = ""
//    var inboundPct: Int = 0
//    var outboundPct: Int = 0
//    var b2bPct: Int = 0
//    var retailPct: Int = 0
//    var isBusinessSeasonal: Int = 0
//    var seasonalityDesc: String = ""
//    var returnRefundPolicyLink: String = ""
//    var refundRequestWindow: String = ""
//    var refundProcessWindow: String = ""
//
//    // Fulfillment
//    var cardChargeTiming: String = ""
//    var serviceDeliveryTimeDays: String = ""
//    var usesThirdPartyFulfillment: Int = 0
//    var thirdPartyCompanyName: String = ""
//
//    // Risk
//    var isPciCompliant: Int = 0
//    var previouslyTerminatedByCardNetwork: Int = 0
//    var dataCompromiseInvestigationHistory: Int = 0
//    var identifiedInVisaRiskPrograms: Int = 0
//    var thirdPartyPaymentParticipation: Int = 0
//    var thirdPartyPlatformName: String = ""
//
//    // Bankruptcy
//    var bankruptcyStatus: String = ""
//    var bankruptcyFillingDate: String = ""
//    var incidentDetails: String = ""
//
//    // Additional
//    var businessActivity: String = ""
//    var corporateStructure: String = ""
//}
//
//// MARK: - Response Model
//struct KYCEnterpriseResponse: Decodable {
//    let error: KYCEnterpriseError?
//    let userListResult: String?
//    let userResult: String?
//    let chatMessageList: String?
//    let chatUserList: String?
//    let groupChatUserList: String?
//    let groupChats: String?
//    let groupChat: String?
//    let totalcount: Int?
//    let isBlocked: Int?
//    let isSanctionPassed: Int?
//}
//
//struct KYCEnterpriseError: Decodable {
//    let errorData: Int?
//    let errorMsg: String?
//
//    enum CodingKeys: String, CodingKey {
//        case errorData = "error_data"
//        case errorMsg  = "error_msg"
//    }
//
//    /// Returns true when the API call succeeded (no error message)
//    var isSuccess: Bool {
//        return (errorMsg ?? "").isEmpty
//    }
//}
//
//// MARK: - Query Params Model
//struct KYCEnterpriseQueryParams {
//    let adminUser: String
//    let uuid: String
//}




// MARK: - GetUserDetailsModels.swift
import Foundation

// MARK: - Top-level Response
struct GetUserDetailsResponse: Decodable {
    let userDocsStatus: AnyCodable?
    let isKycFinished:  AnyCodable?
    let userId:         Int?
    let uuid:           String?
    let brokerId:       String?
    let firstName:      String?
    let lastName:       String?
    let email:          String?
    let enterpriseUser: EnterpriseUserData?
    
    let userResult: UserResultWrapper?
    
    struct UserResultWrapper: Decodable {
        let userDocsStatus: AnyCodable?
        let isKycFinished:  AnyCodable?
        let enterpriseUser: EnterpriseUserData?
    }
}

// MARK: - Enterprise User Data
struct EnterpriseUserData: Decodable {
    let companyName:                        AnyCodable?
    let companyRegNo:                       AnyCodable?
    let corporateStructure:                 AnyCodable?
    let incorporationCountry:               AnyCodable?
    let companyWebsite:                     AnyCodable?
    let businessActivity:                   AnyCodable?
    let dbaName:                            AnyCodable?
    let businessPhoneNumber:                AnyCodable?
    let businessEmailAddress:               AnyCodable?
    let yearsInBusiness:                    AnyCodable?
    let businessDescription:                AnyCodable?
    let stockExchangeName:                  AnyCodable?
    let stockTickerSymbol:                  AnyCodable?
    let identificationType:                 AnyCodable?
    let identificationNumber:               AnyCodable?
    let isExemptPayee:                      AnyCodable?
    let isNpo:                              AnyCodable?
    let companyregAddress:                  AnyCodable?
    let companyregCity:                     AnyCodable?
    let companyregState:                    AnyCodable?
    let companyregCountry:                  AnyCodable?
    let companyregZip:                      AnyCodable?
    let companyRegPremiseType:              AnyCodable?
    let companyRegYearsInThisLocation:      AnyCodable?
    let premiseOwner:                       AnyCodable?
    let areaZoned:                          AnyCodable?
    let squareFootage:                      AnyCodable?
    let numberOfLocations:                  AnyCodable?
    let companyOfficeAddress:               AnyCodable?
    let companyOfficeCity:                  AnyCodable?
    let companyOfficeState:                 AnyCodable?
    let companyOfficeCountry:               AnyCodable?
    let companyOfficeZip:                   AnyCodable?
    let companyOfficePremiseType:           AnyCodable?
    let companyOfficeYearsInThisLocation:   AnyCodable?
    let officePremiseOwner:                 AnyCodable?
    let officeAreaZoned:                    AnyCodable?
    let officeSquareFootage:                AnyCodable?
    let revenue:                            AnyCodable?
    let profit:                             AnyCodable?
    let companyAssets:                      AnyCodable?
    let companyNetWorth:                    AnyCodable?
    let accountPurpose:                     AnyCodable?
    let investmentSource:                   AnyCodable?
    let transactionVolumes:                 AnyCodable?
    let transactionFrequency:               AnyCodable?
    let bankingPartner:                     AnyCodable?
    let relationWithBank:                   AnyCodable?
    let isProcessingCardTransaction:        AnyCodable?
    let onlineTxnPct:                       AnyCodable?
    let inPersonSwipeTxnPct:                AnyCodable?
    let overThePhoneTxnPct:                 AnyCodable?
    let keyEnteredTxnPct:                   AnyCodable?
    let transactionLimitInUsd:              AnyCodable?
    let averageTransactionSizeInUsd:        AnyCodable?
    let highestTransactionSizeInUsd:        AnyCodable?
    let acceptAchPayment:                   AnyCodable?
    let acceptAmexPayment:                  AnyCodable?
    let amexMonthlyVolumeInUsd:             AnyCodable?
    let amexAvgTicketInUsd:                 AnyCodable?
    let amexHighestTicketInUsd:             AnyCodable?
    let paymentProcessingWebsiteUrl:        AnyCodable?
    let demoLoginUsername:                  AnyCodable?
    let demoLoginPassword:                  AnyCodable?
    let advertiseType:                      AnyCodable?
    let inboundPct:                         AnyCodable?
    let outboundPct:                        AnyCodable?
    let b2bPct:                             AnyCodable?
    let retailPct:                          AnyCodable?
    let isBusinessSeasonal:                 AnyCodable?
    let seasonalityDesc:                    AnyCodable?
    let returnRefundPolicyLink:             AnyCodable?
    let refundRequestWindow:                AnyCodable?
    let refundProcessWindow:                AnyCodable?
    let cardChargeTiming:                   AnyCodable?
    let serviceDeliveryTimeDays:            AnyCodable?
    let usesThirdPartyFulfillment:          AnyCodable?
    let thirdPartyCompanyName:              AnyCodable?
    let isPciCompliant:                     AnyCodable?
    let previouslyTerminatedByCardNetwork:  AnyCodable?
    let dataCompromiseInvestigationHistory: AnyCodable?
    let identifiedInVisaRiskPrograms:       AnyCodable?
    let thirdPartyPaymentParticipation:     AnyCodable?
    let thirdPartyPlatformName:             AnyCodable?
    let bankruptcyStatus:                   AnyCodable?
    let bankruptcyFillingDate:              AnyCodable?
    let incidentDetails:                    AnyCodable?
    let identityScore:                      AnyCodable?
    let watchlistScore:                     AnyCodable?
    let watchlistDetails:                   AnyCodable?
    let negativeNewsScore:                  AnyCodable?
    let riskScore:                          AnyCodable?
    let isSanctionedPassed:                 AnyCodable?
    let enterpriseOwners:                   [APIOwner]?
    let incorporationCertificate:           AnyCodable?
    let memorandum:                         AnyCodable?
    let associationArticles:                AnyCodable?
    let incumbencyCertificate:              AnyCodable?
    let directorsRegister:                  AnyCodable?
    let shareholdersRegister:               AnyCodable?
    let boardResolution:                    AnyCodable?
    let addressProof:                       AnyCodable?
    let bankStatement:                      AnyCodable?
    let wolfsbergDoc:                       AnyCodable?
    let authorizationLetter:                AnyCodable?
    let processingStatement:                AnyCodable?
}

// MARK: - APIOwner
struct APIOwner: Decodable {
    let ownerUuid: AnyCodable?
    let enterpriseId: AnyCodable?
    let ownerType: AnyCodable?
    let ownershipPer: AnyCodable?
    let firstName: AnyCodable?
    let middleName: AnyCodable?
    let lastName: AnyCodable?
    let email: AnyCodable?
    let phone: AnyCodable?
    let dob: AnyCodable?
    let birthPlace: AnyCodable?
    let ssn: AnyCodable?
    let address: AnyCodable?
    let city: AnyCodable?
    let state: AnyCodable?
    let country: AnyCodable?
    let zip: AnyCodable?
    let pep: AnyCodable?
    let idType: AnyCodable?
    let idCountry: AnyCodable?
    let idState: AnyCodable?
    let frontIdName: AnyCodable?
    let backIdName: AnyCodable?
    let poaType: AnyCodable?
    let addressProofName: AnyCodable?
    let selfieName: AnyCodable?
    let investingFundName: AnyCodable?
}

// MARK: - AnyCodable
struct AnyCodable: Decodable {
    let stringValue: String
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if      let i = try? c.decode(Int.self)    { stringValue = "\(i)" }
        else if let d = try? c.decode(Double.self)  {
            stringValue = d.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(d))" : "\(d)"
        }
        else if let s = try? c.decode(String.self)  { stringValue = s }
        else if let b = try? c.decode(Bool.self)    { stringValue = b ? "1" : "0" }
        else                                         { stringValue = "" }
    }
}

// MARK: - KYC Status
enum EnterpriseKYCStatus {
    case notSubmitted, pendingReview, approved, rejected
    init(rawValue: Int?) {
        switch rawValue {
        case 0:  self = .pendingReview
        case 1:  self = .approved
        case 2:  self = .rejected
        default: self = .notSubmitted
        }
    }
    var displayName: String {
        switch self {
        case .notSubmitted:  return "Not Submitted"
        case .pendingReview: return "Pending Review"
        case .approved:      return "Approved"
        case .rejected:      return "Rejected"
        }
    }
}

// MARK: - KYCPrefillData
struct KYCPrefillData: Codable, Equatable {
    var companyName = "";        var companyRegNo = ""
    var companyWebsite = "";     var countryOfIncorp = ""
    var corporateStructure = ""; var businessActivity = ""
    var dbaName = "";            var businessPhone = ""
    var businessEmail = "";      var yearsInBusiness = ""
    var businessDesc = "";       var stockExchange = ""
    var stockTicker = ""
    var taxIdType = "";   var tinNumber = ""
    var exemptPayee = ""; var isNonprofit = ""
    var regAddress = "";      var regCity = ""
    var regState = "";        var regCountry = ""
    var regZip = "";          var premiseType = ""
    var yearsInLocation = ""; var premiseOwner = ""
    var areaZoned = "";       var squareFootage = ""
    var numLocations = ""
    var annualRevenue = ""; var annualProfit = ""
    var totalAssets = "";   var netWorth = ""
    var accountPurpose = "";   var sourceInvestment = ""
    var monthlyTxVol = "";     var txFrequency = ""
    var bankingPartner = "";   var bankingDuration = ""
    var processingCards = ""; var onlinePct = ""
    var inPersonPct = "";     var phonePct = ""
    var keyedPct = "";        var monthlyCardAmt = ""
    var avgTxSize = "";       var maxTxSize = ""
    var acceptACH = "";       var acceptAmex = false
    var processingURL = "";   var demoUser = ""
    var demoPass = ""
    var adMethods: Set<String> = []
    var inboundPct = "";    var outboundPct = ""
    var b2bPct = "";        var b2cPct = ""
    var isSeasonal = "";    var seasonalityDesc = ""
    var refundPolicy = "";  var refundReqDays = ""
    var refundProcDays = ""
    var cardChargedWhen = "";   var thirdPartyFulfill = ""
    var pciCompliant = "";       var terminatedMerchant = ""
    var dataCompromise = "";     var visaRisk = ""
    var thirdPartyPayment = "";  var filedBankruptcy = ""
    var uboOwners: [UBOOwner] = []
    var companyBankStatement: URL?

    var incorporationCertificateName = ""
    var memorandumName = ""
    var associationArticlesName = ""
    var incumbencyCertificateName = ""
    var directorsRegisterName = ""
    var shareholdersRegisterName = ""
    var boardResolutionName = ""
    var addressProofName = ""
    var companyBankStatementName = ""
    var wolfsbergDocName = ""
    var authorizationLetterName = ""
    var processingStatementName = ""

    private static func filename(from path: String?) -> String {
        guard let path = path, !path.isEmpty else { return "" }
        return path.components(separatedBy: "/").last ?? path
    }

    // MARK: - Build (split into sections to avoid type-check timeout)
    static func build(from e: EnterpriseUserData) -> KYCPrefillData {
        var d = KYCPrefillData()
        buildCompanyFields(into: &d, from: e)
        buildTaxFields(into: &d, from: e)
        buildAddressFields(into: &d, from: e)
        buildFinancialFields(into: &d, from: e)
        buildBankingFields(into: &d, from: e)
        buildProcessingFields(into: &d, from: e)
        buildBizOpsFields(into: &d, from: e)
        buildFulfillmentRiskBankruptcy(into: &d, from: e)
        buildDocumentAndUBOFields(into: &d, from: e)
        debugLog(d)
        return d
    }

    private static func buildDocumentAndUBOFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.incorporationCertificateName = filename(from: e.incorporationCertificate?.stringValue)
        d.memorandumName               = filename(from: e.memorandum?.stringValue)
        d.associationArticlesName      = filename(from: e.associationArticles?.stringValue)
        d.incumbencyCertificateName    = filename(from: e.incumbencyCertificate?.stringValue)
        d.directorsRegisterName        = filename(from: e.directorsRegister?.stringValue)
        d.shareholdersRegisterName     = filename(from: e.shareholdersRegister?.stringValue)
        d.boardResolutionName          = filename(from: e.boardResolution?.stringValue)
        d.addressProofName             = filename(from: e.addressProof?.stringValue)
        d.companyBankStatementName     = filename(from: e.bankStatement?.stringValue)
        d.wolfsbergDocName             = filename(from: e.wolfsbergDoc?.stringValue)
        d.authorizationLetterName      = filename(from: e.authorizationLetter?.stringValue)
        d.processingStatementName      = filename(from: e.processingStatement?.stringValue)

        d.uboOwners = (e.enterpriseOwners ?? []).map { api in
            var u = UBOOwner()
            u.ownerUuid = api.ownerUuid?.stringValue ?? ""
            u.enterpriseId = api.enterpriseId?.stringValue ?? ""
            u.ownerType = api.ownerType?.stringValue ?? "Authorized signatory"
            u.ownershipPct = api.ownershipPer?.stringValue ?? ""
            u.firstName = api.firstName?.stringValue ?? ""
            u.middleName = api.middleName?.stringValue ?? ""
            u.lastName = api.lastName?.stringValue ?? ""
            u.email = api.email?.stringValue ?? ""
            u.phone = api.phone?.stringValue ?? ""
            u.dob = api.dob?.stringValue ?? ""
            u.placeOfBirth = api.birthPlace?.stringValue ?? ""
            u.ssnPassport = api.ssn?.stringValue ?? ""
            u.street = api.address?.stringValue ?? ""
            u.city = api.city?.stringValue ?? ""
            u.addrState = api.state?.stringValue ?? ""
            u.country = api.country?.stringValue ?? ""
            u.zip = api.zip?.stringValue ?? ""
            u.isPEP = (api.pep?.stringValue == "1") ? "Yes" : "No"
            u.idDocType = api.idType?.stringValue ?? ""
            u.idCountry = api.idCountry?.stringValue ?? ""
            u.idState = api.idState?.stringValue ?? ""
            u.govIdFront = filename(from: api.frontIdName?.stringValue)
            u.govIdBack = filename(from: api.backIdName?.stringValue)
            u.poaType = api.poaType?.stringValue ?? ""
            u.proofOfAddress = filename(from: api.addressProofName?.stringValue)
            u.selfieFile = filename(from: api.selfieName?.stringValue)
            u.investmentFile = filename(from: api.investingFundName?.stringValue)
            return u
        }
    }

    private static func buildCompanyFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.companyName        = e.companyName?.stringValue         ?? ""
        d.companyRegNo       = e.companyRegNo?.stringValue        ?? ""
        d.companyWebsite     = e.companyWebsite?.stringValue      ?? ""
        d.countryOfIncorp    = e.incorporationCountry?.stringValue ?? ""
        d.corporateStructure = mapCorporateStructure(e.corporateStructure?.stringValue ?? "")
        d.businessActivity   = e.businessActivity?.stringValue    ?? ""
        d.dbaName            = e.dbaName?.stringValue             ?? ""
        d.businessPhone      = e.businessPhoneNumber?.stringValue ?? ""
        d.businessEmail      = e.businessEmailAddress?.stringValue ?? ""
        d.yearsInBusiness    = mapYearsInBusiness(e.yearsInBusiness?.stringValue ?? "")
        d.businessDesc       = e.businessDescription?.stringValue ?? ""
        d.stockExchange      = e.stockExchangeName?.stringValue   ?? ""
        d.stockTicker        = e.stockTickerSymbol?.stringValue   ?? ""
    }

    private static func buildTaxFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.taxIdType   = mapTaxIdType(e.identificationType?.stringValue ?? "")
        d.tinNumber   = e.identificationNumber?.stringValue ?? ""
        d.exemptPayee = yesNo(e.isExemptPayee?.stringValue)
        d.isNonprofit = yesNo(e.isNpo?.stringValue)
    }

    private static func buildAddressFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.regAddress      = e.companyregAddress?.stringValue  ?? ""
        d.regCity         = e.companyregCity?.stringValue     ?? ""
        d.regState        = e.companyregState?.stringValue    ?? ""
        d.regCountry      = e.companyregCountry?.stringValue  ?? ""
        d.regZip          = e.companyregZip?.stringValue      ?? ""
        d.premiseType     = mapPremiseType(e.companyRegPremiseType?.stringValue ?? "")
        d.yearsInLocation = mapYearsInBusiness(e.companyRegYearsInThisLocation?.stringValue ?? "")
        d.premiseOwner    = mapPremiseOwner(e.premiseOwner?.stringValue ?? "")
        d.areaZoned       = e.areaZoned?.stringValue ?? ""
        d.squareFootage   = e.squareFootage?.stringValue    ?? ""
        d.numLocations    = e.numberOfLocations?.stringValue ?? ""
    }

    private static func buildFinancialFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.annualRevenue = mapRevenueRange(e.revenue?.stringValue      ?? "")
        d.annualProfit  = mapRevenueRange(e.profit?.stringValue       ?? "")
        d.totalAssets   = mapRevenueRange(e.companyAssets?.stringValue  ?? "")
        d.netWorth      = mapRevenueRange(e.companyNetWorth?.stringValue ?? "")
    }

    private static func buildBankingFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.accountPurpose   = e.accountPurpose?.stringValue    ?? ""
        d.sourceInvestment = e.investmentSource?.stringValue  ?? ""
        d.monthlyTxVol     = mapTxVolume(e.transactionVolumes?.stringValue   ?? "")
        d.txFrequency      = mapTxFrequency(e.transactionFrequency?.stringValue ?? "")
        d.bankingPartner   = e.bankingPartner?.stringValue    ?? ""
        d.bankingDuration  = mapBankingDuration(e.relationWithBank?.stringValue ?? "")
    }

    private static func buildProcessingFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.processingCards = yesNo(e.isProcessingCardTransaction?.stringValue)
        d.onlinePct       = e.onlineTxnPct?.stringValue            ?? ""
        d.inPersonPct     = e.inPersonSwipeTxnPct?.stringValue     ?? ""
        d.phonePct        = e.overThePhoneTxnPct?.stringValue      ?? ""
        d.keyedPct        = e.keyEnteredTxnPct?.stringValue        ?? ""
        d.monthlyCardAmt  = e.transactionLimitInUsd?.stringValue        ?? ""
        d.avgTxSize       = e.averageTransactionSizeInUsd?.stringValue  ?? ""
        d.maxTxSize       = e.highestTransactionSizeInUsd?.stringValue  ?? ""
        d.acceptACH       = yesNo(e.acceptAchPayment?.stringValue)
        d.acceptAmex      = (e.acceptAmexPayment?.stringValue ?? "0") == "1"
        d.processingURL   = e.paymentProcessingWebsiteUrl?.stringValue ?? ""
        d.demoUser        = e.demoLoginUsername?.stringValue ?? ""
        d.demoPass        = e.demoLoginPassword?.stringValue ?? ""
    }

    private static func buildBizOpsFields(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        if let adStr = e.advertiseType?.stringValue, !adStr.isEmpty {
            d.adMethods = Set(adStr.split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty })
        }
        d.inboundPct      = e.inboundPct?.stringValue   ?? ""
        d.outboundPct     = e.outboundPct?.stringValue  ?? ""
        d.b2bPct          = e.b2bPct?.stringValue       ?? ""
        d.b2cPct          = e.retailPct?.stringValue    ?? ""
        d.isSeasonal      = yesNo(e.isBusinessSeasonal?.stringValue)
        d.seasonalityDesc = e.seasonalityDesc?.stringValue          ?? ""
        d.refundPolicy    = e.returnRefundPolicyLink?.stringValue   ?? ""
        d.refundReqDays   = mapRefundDays(e.refundRequestWindow?.stringValue  ?? "")
        d.refundProcDays  = mapRefundProcDays(e.refundProcessWindow?.stringValue ?? "")
    }

    private static func buildFulfillmentRiskBankruptcy(into d: inout KYCPrefillData, from e: EnterpriseUserData) {
        d.cardChargedWhen   = mapCardChargeTiming(e.cardChargeTiming?.stringValue ?? "")
        d.thirdPartyFulfill = yesNo(e.usesThirdPartyFulfillment?.stringValue)
        d.pciCompliant       = yesNo(e.isPciCompliant?.stringValue)
        d.terminatedMerchant = yesNo(e.previouslyTerminatedByCardNetwork?.stringValue)
        d.dataCompromise     = yesNo(e.dataCompromiseInvestigationHistory?.stringValue)
        d.visaRisk           = yesNo(e.identifiedInVisaRiskPrograms?.stringValue)
        d.thirdPartyPayment  = yesNo(e.thirdPartyPaymentParticipation?.stringValue)
        d.filedBankruptcy    = mapBankruptcyStatus(e.bankruptcyStatus?.stringValue ?? "")
    }

    // MARK: - Mapping Helpers
    private static func yesNo(_ s: String?) -> String {
        guard let s else { return "" }
        if s == "1" { return "Yes" }
        if s == "0" { return "No"  }
        return s
    }

    private static func mapTaxIdType(_ s: String) -> String {
        switch s.uppercased() {
        case "EIN":  return "EIN (Employer Identification Number)"
        case "SSN":  return "SSN (Social Security Number)"
        case "ITIN": return "ITIN (Individual Taxpayer Identification Number)"
        default:     return s
        }
    }

    private static func mapCorporateStructure(_ s: String) -> String {
        switch s.trimmingCharacters(in: .whitespaces).lowercased() {
        case "corporation", "c-corp", "c corp": return "Corporation (C-Corp)"
        case "s-corp", "s corp":                return "Corporation (S-Corp)"
        case "llc":                              return "LLC"
        case "sole proprietorship":              return "Sole Proprietorship"
        case "partnership":                      return "Partnership"
        case "non-profit", "nonprofit":          return "Non-Profit"
        default:                                 return s.trimmingCharacters(in: .whitespaces)
        }
    }

    private static func mapYearsInBusiness(_ s: String) -> String {
        switch s.trimmingCharacters(in: .whitespaces).lowercased() {
        case "less than 1 year", "< 1 year", "0-1 year", "0 - 1 year": return "Less than 1 year"
        case "1-2 years", "1 - 2 years", "1-2 year", "1 - 2 year":    return "1-2 years"
        case "2-5 years", "2 - 5 years", "2-5 year", "2 - 5 year":    return "2-5 years"
        case "5-10 years", "5 - 10 years":                             return "5-10 years"
        case "10+ years", "10+ year", "10 + years":                    return "10+ years"
        default:                                                         return s.trimmingCharacters(in: .whitespaces)
        }
    }

    private static func mapPremiseType(_ s: String) -> String {
        let valid = ["Office","Retail Store","Warehouse","Home/Residential","Co-working Space","Other"]
        if valid.contains(s) { return s }
        switch s.lowercased() {
        case "kiosk", "mailbox":              return "Other"
        case "home", "residential":           return "Home/Residential"
        case "retail":                        return "Retail Store"
        case "warehouse":                     return "Warehouse"
        case "co-working", "coworking":       return "Co-working Space"
        default:                              return "Other"
        }
    }

    private static func mapPremiseOwner(_ s: String) -> String {
        switch s.lowercased() {
        case "rental", "tenant", "rented": return "Tenant"
        case "owned", "owner":             return "Owner"
        case "shared":                     return "Shared"
        default:                           return s
        }
    }

    private static func mapRevenueRange(_ s: String) -> String {
        switch s.trimmingCharacters(in: .whitespaces) {
        case "1": return "Under $100K"
        case "2": return "$100K–$500K"
        case "3": return "$500K–$1M"
        case "4": return "$1M–$5M"
        case "5": return "$5M–$10M"
        case "6": return "$10M+"
        default:  return s
        }
    }

    private static func mapTxVolume(_ s: String) -> String {
        switch s.trimmingCharacters(in: .whitespaces) {
        case "1": return "$0–$10,000"
        case "2": return "$10,000–$25,000"
        case "3": return "$25,000–$50,000"
        case "4": return "$50,000–$100,000"
        case "5": return "$100,000–$250,000"
        case "6": return "$250,000–$1,000,000"
        case "7": return "$1,000,000+"
        default:  return s
        }
    }

    private static func mapTxFrequency(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespaces)
        let display = ["Daily","Weekly","Bi-Weekly","Monthly","Quarterly","Annually"]
        if display.contains(t) { return t }
        switch t.lowercased() {
        case "1", "daily":           return "Daily"
        case "2", "weekly":          return "Weekly"
        case "3", "bi-weekly":       return "Bi-Weekly"
        case "4", "monthly":         return "Monthly"
        case "5", "quarterly":       return "Quarterly"
        case "6", "annually","annual": return "Annually"
        case "1-10":                 return "Daily"
        case "10-100":               return "Weekly"
        case "100-1000":             return "Monthly"
        case "1000+":                return "Annually"
        default:                     return t
        }
    }

    private static func mapBankingDuration(_ s: String) -> String {
        switch s.trimmingCharacters(in: .whitespaces).lowercased() {
        case "0-1 year", "0-1 years", "< 1 year": return "0-1 year"
        case "1-2 year", "1-2 years":              return "1-2 years"
        case "2+ year", "2+ years", "2 + years":   return "2+ years"
        default:                                    return s
        }
    }

    private static func mapRefundDays(_ s: String) -> String {
        return s.trimmingCharacters(in: .whitespaces)
    }

    private static func mapRefundProcDays(_ s: String) -> String {
        return s.trimmingCharacters(in: .whitespaces)
    }

    private static func mapCardChargeTiming(_ s: String) -> String {
        return s.trimmingCharacters(in: .whitespaces)
    }

    private static func mapBankruptcyStatus(_ s: String) -> String {
        let t = s.trimmingCharacters(in: .whitespaces).lowercased()
        if t.isEmpty || t == "none" || t == "no" { return "No"  }
        if t == "yes"                             { return "Yes" }
        if t.contains("bankrupt")                { return "Yes" }
        return s
    }

    // MARK: - Debug
    private static func debugLog(_ d: KYCPrefillData) {
        print("\n🔧 KYCPrefillData BUILD COMPLETE")
        print("🔧 Company: \(d.companyName) | \(d.countryOfIncorp) | \(d.corporateStructure)")
        print("🔧 Tax: \(d.taxIdType) | tin=\(d.tinNumber) | exempt=\(d.exemptPayee) | npo=\(d.isNonprofit)")
        print("🔧 Address: \(d.regAddress), \(d.regCity), \(d.regState), \(d.regCountry) \(d.regZip)")
        print("🔧 Financial: rev=\(d.annualRevenue) profit=\(d.annualProfit) assets=\(d.totalAssets) worth=\(d.netWorth)")
        print("🔧 Banking: purpose=\(d.accountPurpose) vol=\(d.monthlyTxVol) freq=\(d.txFrequency) dur=\(d.bankingDuration)")
        print("🔧 Processing: cards=\(d.processingCards) ACH=\(d.acceptACH) Amex=\(d.acceptAmex)")
        print("🔧 BizOps: adMethods=\(d.adMethods) seasonal=\(d.isSeasonal)")
        print("🔧 Risk: pci=\(d.pciCompliant) bankrupt=\(d.filedBankruptcy)\n")
    }
}
