//// MARK: - KYCEnterpriseViewModel.swift
//// ObservableObject ViewModel that bridges EnterpriseKycFormView ↔ KYCEnterpriseService
//
//import Foundation
//import Combine
//
//// MARK: - Submission State
//enum KYCSubmissionState: Equatable {
//    case idle
//    case loading
//    case success(message: String)
//    case failure(message: String)
//}
//
//// MARK: - ViewModel
//@MainActor
//final class KYCEnterpriseViewModel: ObservableObject {
//
//    // ── Published State ───────────────────────────────────────────
//    @Published var submissionState: KYCSubmissionState = .idle
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String? = nil
//    @Published var showSuccessAlert: Bool = false
//
//    // ── Dependencies ──────────────────────────────────────────────
//    private let service: KYCEnterpriseServiceProtocol
//
//    // ── Query params: set these from your session/auth manager ────
//    var adminUser: String = ""   // e.g. "32979"
//    var uuid: String      = ""   // e.g. "485000c1-4e0d-11f1-b593-6f2044fd31bd"
//
//    // MARK: Init
//    init(service: KYCEnterpriseServiceProtocol = KYCEnterpriseService.shared) {
//        self.service = service
//        print("🏗️  [KYCEnterpriseViewModel] Initialized")
//    }
//
//    // MARK: - Build Request from Form State
//    /// Maps all SwiftUI @State fields from EnterpriseKycFormView into the request model.
//    /// Call this right before submission — pass the view's current @State values.
//    func buildRequest(from form: KYCFormSnapshot) -> KYCEnterpriseRequest {
//        var req = KYCEnterpriseRequest()
//
//        // Company Info
//        req.companyName                     = form.companyName
//        req.companyRegNo                    = form.companyRegNo
//        req.incorporationCountry            = form.countryOfIncorp
//        req.companyWebsite                  = form.companyWebsite
//        req.dbaName                         = form.dbaName
//        req.businessPhoneNumber             = "\(form.phoneCode)\(form.businessPhone)"
//        req.businessEmailAddress            = form.businessEmail
//        req.yearsInBusiness                 = form.yearsInBusiness
//        req.businessDescription             = form.businessDesc
//        req.stockExchangeName               = form.stockExchange
//        req.stockTickerSymbol               = form.stockTicker
//        req.corporateStructure              = form.corporateStructure
//        req.businessActivity                = form.businessActivity
//
//        // Tax
//        req.identificationType              = form.taxIdType
//        req.identificationNumber            = form.tinNumber
//        req.isExemptPayee                   = form.exemptPayee == "Yes" ? "1" : "0"
//        req.isNpo                           = form.isNonprofit == "Yes" ? 1 : 0
//
//        // Registered Address
//        req.companyregAddress               = form.regAddress
//        req.companyregCity                  = form.regCity
//        req.companyregState                 = form.regState
//        req.companyregCountry               = form.regCountry
//        req.companyregZip                   = form.regZip
//        req.companyRegPremiseType           = form.premiseType
//        req.companyRegYearsInThisLocation   = form.yearsInLocation
//        req.premiseOwner                    = form.premiseOwner
//        req.areaZoned                       = form.areaZoned
//        req.squareFootage                   = form.squareFootage
//        req.numberOfLocations               = form.numLocations
//
//        // Office Address (same as registered if checkbox is on)
//        if form.officeSameAsReg {
//            req.companyOfficeAddress              = form.regAddress
//            req.companyOfficeCity                 = form.regCity
//            req.companyOfficeState                = form.regState
//            req.companyOfficeCountry              = form.regCountry
//            req.companyOfficeZip                  = form.regZip
//            req.companyOfficePremiseType          = form.premiseType
//            req.companyOfficeYearsInThisLocation  = form.yearsInLocation
//            req.officePremiseOwner                = form.premiseOwner
//            req.officeAreaZoned                   = form.areaZoned
//            req.officeSquareFootage               = form.squareFootage
//        } else {
//            // If you add separate office address fields later, map them here
//            req.companyOfficeAddress              = form.regAddress
//            req.companyOfficeCity                 = form.regCity
//            req.companyOfficeState                = form.regState
//            req.companyOfficeCountry              = form.regCountry
//            req.companyOfficeZip                  = form.regZip
//        }
//
//        // Financial
//        req.revenue                         = form.annualRevenue
//        req.profit                          = form.annualProfit
//        req.companyAssets                   = form.totalAssets
//        req.companyNetWorth                 = form.netWorth
//
//        // Banking
//        req.accountPurpose                  = form.accountPurpose
//        req.investmentSource                = form.sourceInvestment
//        req.transactionVolumes              = form.monthlyTxVol
//        req.transactionFrequency            = form.txFrequency
//        req.bankingPartner                  = form.bankingPartner
//        req.relationWithBank                = form.bankingDuration
//
//        // Processing
//        req.isProcessingCardTransaction     = form.processingCards == "Yes" ? "1" : "0"
//        req.onlineTxnPct                    = form.onlinePct
//        req.inPersonSwipeTxnPct             = form.inPersonPct
//        req.overThePhoneTxnPct              = form.phonePct
//        req.keyEnteredTxnPct                = form.keyedPct
//        req.amexMonthlyVolumeInUsd          = Double(form.monthlyCardAmt) ?? 0
//        req.amexAvgTicketInUsd              = Double(form.avgTxSize) ?? 0
//        req.amexHighestTicketInUsd          = Double(form.maxTxSize) ?? 0
//        req.acceptAmexPayment               = form.acceptAmex ? 1 : 0
//        req.transactionLimitInUsd           = form.monthlyCardAmt
//        req.averageTransactionSizeInUsd     = form.avgTxSize
//        req.highestTransactionSizeInUsd     = form.maxTxSize
//        req.acceptAchPayment                = form.acceptACH == "Yes" ? "1" : "0"
//
//        // Processing URLs
//        req.paymentProcessingWebsiteUrl     = form.processingURL
//        req.demoLoginUsername               = form.demoUser
//        req.demoLoginPassword               = form.demoPass
//
//        // Business Ops
//        req.advertiseType                   = form.adMethods.joined(separator: ",")
//        req.inboundPct                      = Int(form.inboundPct) ?? 0
//        req.outboundPct                     = Int(form.outboundPct) ?? 0
//        req.b2bPct                          = Int(form.b2bPct) ?? 0
//        req.retailPct                       = Int(form.b2cPct) ?? 0
//        req.isBusinessSeasonal              = form.isSeasonal == "Yes" ? 1 : 0
//        req.returnRefundPolicyLink          = form.refundPolicy
//        req.refundRequestWindow             = form.refundReqDays
//        req.refundProcessWindow             = form.refundProcDays
//
//        // Fulfillment
//        req.cardChargeTiming                = form.cardChargedWhen
//        req.usesThirdPartyFulfillment       = form.thirdPartyFulfill == "Yes" ? 1 : 0
//
//        // Risk
//        req.isPciCompliant                  = form.pciCompliant == "Yes" ? 1 : 0
//        req.previouslyTerminatedByCardNetwork = form.terminatedMerchant == "Yes" ? 1 : 0
//        req.dataCompromiseInvestigationHistory = form.dataCompromise == "Yes" ? 1 : 0
//        req.identifiedInVisaRiskPrograms    = form.visaRisk == "Yes" ? 1 : 0
//        req.thirdPartyPaymentParticipation  = form.thirdPartyPayment == "Yes" ? 1 : 0
//
//        // Bankruptcy
//        req.bankruptcyStatus                = form.filedBankruptcy
//
//        print("🔨 [KYCEnterpriseViewModel] Request built successfully")
//        debugPrintRequest(req)
//        return req
//    }
//
//    // MARK: - Submit
//    func submit(form: KYCFormSnapshot) {
//        guard !adminUser.isEmpty, !uuid.isEmpty else {
//            print("❌ [KYCEnterpriseViewModel] adminUser or uuid is empty")
//            submissionState = .failure(message: "Session expired. Please log in again.")
//            return
//        }
//
//        let request = buildRequest(from: form)
//        let params   = KYCEnterpriseQueryParams(adminUser: adminUser, uuid: uuid)
//
//        isLoading        = true
//        submissionState  = .loading
//        errorMessage     = nil
//
//        print("🚀 [KYCEnterpriseViewModel] Submitting KYC Enterprise form...")
//        print("🚀 [KYCEnterpriseViewModel] adminUser=\(adminUser) | uuid=\(uuid)")
//
//        service.saveEnterpriseUserInfo(queryParams: params, requestBody: request) { [weak self] result in
//            guard let self else { return }
//            Task { @MainActor in
//                self.isLoading = false
//                switch result {
//                case .success(let response):
//                    print("✅ [KYCEnterpriseViewModel] Submission successful")
//                    print("✅ [KYCEnterpriseViewModel] isSanctionPassed: \(response.isSanctionPassed ?? -1)")
//                    self.submissionState = .success(message: "KYC information saved successfully.")
//                    self.showSuccessAlert = true
//
//                case .failure(let error):
//                    print("❌ [KYCEnterpriseViewModel] Submission failed: \(error.localizedDescription)")
//                    self.submissionState = .failure(message: error.localizedDescription)
//                    self.errorMessage    = error.localizedDescription
//                }
//            }
//        }
//    }
//
//    // MARK: - Reset
//    func reset() {
//        submissionState = .idle
//        isLoading       = false
//        errorMessage    = nil
//        showSuccessAlert = false
//        print("🔄 [KYCEnterpriseViewModel] State reset")
//    }
//
//    // MARK: - Debug
//    private func debugPrintRequest(_ req: KYCEnterpriseRequest) {
//        print("\n🔍 ─────────────────────────────────────────────────────────")
//        print("🔍 [KYCEnterpriseViewModel] FORM SNAPSHOT → REQUEST MAPPING")
//        if let data = try? JSONEncoder().encode(req),
//           let obj  = try? JSONSerialization.jsonObject(with: data),
//           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
//           let str  = String(data: pretty, encoding: .utf8) {
//            print(str)
//        }
//        print("🔍 ─────────────────────────────────────────────────────────\n")
//    }
//}
//
//// MARK: - Form Snapshot
///// A value-type snapshot of all @State fields from EnterpriseKycFormView.
///// Create one inside the view just before calling viewModel.submit(form:).
//struct KYCFormSnapshot {
//    // Company Info
//    var companyName: String        = ""
//    var companyRegNo: String       = ""
//    var companyWebsite: String     = ""
//    var countryOfIncorp: String    = ""
//    var corporateStructure: String = ""
//    var businessActivity: String   = ""
//    var dbaName: String            = ""
//    var phoneCode: String          = ""
//    var businessPhone: String      = ""
//    var businessEmail: String      = ""
//    var yearsInBusiness: String    = ""
//    var businessDesc: String       = ""
//    var stockExchange: String      = ""
//    var stockTicker: String        = ""
//
//    // Tax
//    var taxIdType: String    = ""
//    var tinNumber: String    = ""
//    var exemptPayee: String  = ""
//    var isNonprofit: String  = ""
//
//    // Registered Address
//    var regAddress: String      = ""
//    var regCity: String         = ""
//    var regState: String        = ""
//    var regCountry: String      = ""
//    var regZip: String          = ""
//    var premiseType: String     = ""
//    var yearsInLocation: String = ""
//    var premiseOwner: String    = ""
//    var areaZoned: String       = ""
//    var squareFootage: String   = ""
//    var numLocations: String    = ""
//    var officeSameAsReg: Bool   = true
//
//    // Financial
//    var annualRevenue: String = ""
//    var annualProfit: String  = ""
//    var totalAssets: String   = ""
//    var netWorth: String      = ""
//
//    // Banking
//    var accountPurpose: String   = ""
//    var sourceInvestment: String = ""
//    var monthlyTxVol: String     = ""
//    var txFrequency: String      = ""
//    var bankingPartner: String   = ""
//    var bankingDuration: String  = ""
//
//    // Processing
//    var processingCards: String = ""
//    var onlinePct: String       = ""
//    var inPersonPct: String     = ""
//    var phonePct: String        = ""
//    var keyedPct: String        = ""
//    var monthlyCardAmt: String  = ""
//    var avgTxSize: String       = ""
//    var maxTxSize: String       = ""
//    var acceptACH: String       = ""
//    var acceptAmex: Bool        = false
//    var processingURL: String   = ""
//    var demoUser: String        = ""
//    var demoPass: String        = ""
//
//    // Business Ops
//    var adMethods: Set<String>  = []
//    var inboundPct: String      = ""
//    var outboundPct: String     = ""
//    var b2bPct: String          = ""
//    var b2cPct: String          = ""
//    var isSeasonal: String      = ""
//    var refundPolicy: String    = ""
//    var refundReqDays: String   = ""
//    var refundProcDays: String  = ""
//
//    // Fulfillment
//    var cardChargedWhen: String   = ""
//    var thirdPartyFulfill: String = ""
//
//    // Risk
//    var pciCompliant: String       = ""
//    var terminatedMerchant: String = ""
//    var dataCompromise: String     = ""
//    var visaRisk: String           = ""
//    var thirdPartyPayment: String  = ""
//
//    // Bankruptcy
//    var filedBankruptcy: String = ""
//}




// MARK: - KYCEnterpriseViewModel.swift
// ObservableObject ViewModel that bridges EnterpriseKycFormView ↔ KYCEnterpriseService.
// Contains:
//   1. KYCSubmissionState   — published state enum
//   2. KYCFormSnapshot      — value-type snapshot of all @State fields
//   3. KYCEnterpriseViewModel — maps snapshot → request → fires service

import Foundation
import Combine

// ════════════════════════════════════════════════════════════════════
// MARK: - 1. Submission State
// ════════════════════════════════════════════════════════════════════

enum KYCSubmissionState: Equatable {
    case idle
    case loading
    case success(message: String)
    case failure(message: String)
}

// ════════════════════════════════════════════════════════════════════
// MARK: - 2. KYCFormSnapshot
// Value-type snapshot of every @State field in EnterpriseKycFormView.
// Created just before submission and passed to KYCEnterpriseViewModel.submit(form:).
// ════════════════════════════════════════════════════════════════════

struct EnterpriseOwnerSnapshot: Identifiable {
    let id = UUID()
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var percentage: String = ""
    var phoneCode: String = ""
    var phone: String = ""
    var dob: String = ""
    var govId: URL?
    var selfie: URL?
}

struct KYCFormSnapshot {
    // Company Info
    var companyName:        String = ""
    var companyRegNo:       String = ""
    var companyWebsite:     String = ""
    var countryOfIncorp:    String = ""
    var corporateStructure: String = ""
    var businessActivity:   String = ""
    var dbaName:            String = ""
    var phoneCode:          String = ""
    var businessPhone:      String = ""
    var businessEmail:      String = ""
    var yearsInBusiness:    String = ""
    var businessDesc:       String = ""
    var stockExchange:      String = ""
    var stockTicker:        String = ""

    // Tax
    var taxIdType:   String = ""
    var tinNumber:   String = ""
    var exemptPayee: String = ""
    var isNonprofit: String = ""

    // Registered Address
    var regAddress:      String = ""
    var regCity:         String = ""
    var regState:        String = ""
    var regCountry:      String = ""
    var regZip:          String = ""
    var premiseType:     String = ""
    var yearsInLocation: String = ""
    var premiseOwner:    String = ""
    var areaZoned:       String = ""
    var squareFootage:   String = ""
    var numLocations:    String = ""
    var officeSameAsReg: Bool   = true

    // Financial
    var annualRevenue: String = ""
    var annualProfit:  String = ""
    var totalAssets:   String = ""
    var netWorth:      String = ""

    // Documents (Step 2 & 3)
    var incorporationCertificate: URL?
    var memorandum: URL?
    var associationArticles: URL?
    var incumbencyCertificate: URL?
    var directorsRegister: URL?
    var shareholdersRegister: URL?
    var boardResolution: URL?
    var addressProof: URL?
    var companyBankStatement: URL?
    var wolfsbergDoc: URL?
    var authorizationLetter: URL?
    var processingStatement: URL?
    
    // Owners (Step 4)
    var owners: [EnterpriseOwnerSnapshot] = []

    // Banking
    var accountPurpose:   String = ""
    var sourceInvestment: String = ""
    var monthlyTxVol:     String = ""
    var txFrequency:      String = ""
    var bankingPartner:   String = ""
    var bankingDuration:  String = ""

    // Processing
    var processingCards: String = ""
    var onlinePct:       String = ""
    var inPersonPct:     String = ""
    var phonePct:        String = ""
    var keyedPct:        String = ""
    var monthlyCardAmt:  String = ""
    var avgTxSize:       String = ""
    var maxTxSize:       String = ""
    var acceptACH:       String = ""
    var acceptAmex:      Bool   = false
    var processingURL:   String = ""
    var demoUser:        String = ""
    var demoPass:        String = ""

    // Business Ops
    var adMethods:     Set<String> = []
    var inboundPct:    String = ""
    var outboundPct:   String = ""
    var b2bPct:        String = ""
    var b2cPct:        String = ""
    var isSeasonal:    String = ""
    var refundPolicy:  String = ""
    var refundReqDays: String = ""
    var refundProcDays: String = ""

    // Fulfillment
    var cardChargedWhen:   String = ""
    var thirdPartyFulfill: String = ""

    // Risk
    var pciCompliant:       String = ""
    var terminatedMerchant: String = ""
    var dataCompromise:     String = ""
    var visaRisk:           String = ""
    var thirdPartyPayment:  String = ""

    // Bankruptcy
    var filedBankruptcy: String = ""
}

// ════════════════════════════════════════════════════════════════════
// MARK: - 3. KYCEnterpriseViewModel
// ════════════════════════════════════════════════════════════════════

@MainActor
final class KYCEnterpriseViewModel: ObservableObject {

    // ── Published ─────────────────────────────────────────────────
    @Published var submissionState: KYCSubmissionState = .idle
    @Published var isLoading:       Bool    = false
    @Published var errorMessage:    String? = nil
    @Published var showSuccessAlert: Bool   = false

    // ── Session params — set from EnterpriseKycFormView.onAppear ──
    var adminUser: String = ""
    var uuid:      String = ""

    // ── Dependency ────────────────────────────────────────────────
    private let service: KYCEnterpriseServiceProtocol

    // MARK: Init
    init(service: KYCEnterpriseServiceProtocol = KYCEnterpriseService.shared) {
        self.service = service
        print("🏗️  [KYCEnterpriseViewModel] Initialized")
    }

    // ════════════════════════════════════════════════════════════════
    // MARK: - Build Request
    // Maps every KYCFormSnapshot field → KYCEnterpriseRequest.
    // ════════════════════════════════════════════════════════════════

    func buildRequest(from form: KYCFormSnapshot) -> KYCEnterpriseRequest {
        var req = KYCEnterpriseRequest()

        // Company Info
        req.companyName             = form.companyName
        req.companyRegNo            = form.companyRegNo
        req.incorporationCountry    = form.countryOfIncorp
        req.companyWebsite          = form.companyWebsite
        req.dbaName                 = form.dbaName
        req.businessPhoneNumber     = "\(form.phoneCode)\(form.businessPhone)"
        req.businessEmailAddress    = form.businessEmail
        req.yearsInBusiness         = form.yearsInBusiness
        req.businessDescription     = form.businessDesc
        req.stockExchangeName       = form.stockExchange
        req.stockTickerSymbol       = form.stockTicker
        req.corporateStructure      = form.corporateStructure
        req.businessActivity        = form.businessActivity
        let bizParts = form.businessActivity.components(separatedBy: " - ")
        if bizParts.count >= 2 {
            req.businessActivityCode       = bizParts[0].trimmingCharacters(in: .whitespaces)
            req.businessActivitySearchTerm = bizParts[1...].joined(separator: " - ").trimmingCharacters(in: .whitespaces)
        } else {
            req.businessActivityCode       = ""
            req.businessActivitySearchTerm = form.businessActivity
        }

        // Tax
        req.identificationType      = form.taxIdType
        req.identificationNumber    = form.tinNumber
        req.isExemptPayee           = form.exemptPayee == "Yes" ? "1" : "0"
        req.isNpo                   = form.isNonprofit == "Yes" ? 1 : 0

        // Registered Address
        req.companyregAddress               = form.regAddress
        req.companyregCity                  = form.regCity
        req.companyregState                 = form.regState
        req.companyregCountry               = form.regCountry
        req.companyregZip                   = form.regZip
        req.companyRegPremiseType           = form.premiseType
        req.companyRegYearsInThisLocation   = form.yearsInLocation
        req.premiseOwner                    = form.premiseOwner
        req.areaZoned                       = form.areaZoned
        req.squareFootage                   = form.squareFootage
        req.numberOfLocations               = form.numLocations

        // Office Address (mirror registered when checkbox is on)
        if form.officeSameAsReg {
            req.companyOfficeAddress                 = form.regAddress
            req.companyOfficeCity                    = form.regCity
            req.companyOfficeState                   = form.regState
            req.companyOfficeCountry                 = form.regCountry
            req.companyOfficeZip                     = form.regZip
            req.companyOfficePremiseType             = form.premiseType
            req.companyOfficeYearsInThisLocation     = form.yearsInLocation
            req.officePremiseOwner                   = form.premiseOwner
            req.officeAreaZoned                      = form.areaZoned
            req.officeSquareFootage                  = form.squareFootage
        } else {
            req.companyOfficeAddress    = form.regAddress
            req.companyOfficeCity       = form.regCity
            req.companyOfficeState      = form.regState
            req.companyOfficeCountry    = form.regCountry
            req.companyOfficeZip        = form.regZip
        }

        // Financial
        req.revenue          = form.annualRevenue
        req.profit           = form.annualProfit
        req.companyAssets    = form.totalAssets
        req.companyNetWorth  = form.netWorth

        // Banking
        req.accountPurpose      = form.accountPurpose
        req.investmentSource    = form.sourceInvestment
        req.transactionVolumes  = form.monthlyTxVol
        req.transactionFrequency = form.txFrequency
        req.bankingPartner      = form.bankingPartner
        req.relationWithBank    = form.bankingDuration

        // Processing
        req.isProcessingCardTransaction = form.processingCards == "Yes" ? "1" : "0"
        req.onlineTxnPct                = form.onlinePct
        req.inPersonSwipeTxnPct         = form.inPersonPct
        req.overThePhoneTxnPct          = form.phonePct
        req.keyEnteredTxnPct            = form.keyedPct
        req.amexMonthlyVolumeInUsd      = Double(form.monthlyCardAmt) ?? 0
        req.amexAvgTicketInUsd          = Double(form.avgTxSize)      ?? 0
        req.amexHighestTicketInUsd      = Double(form.maxTxSize)      ?? 0
        req.acceptAmexPayment           = form.acceptAmex ? 1 : 0
        req.transactionLimitInUsd       = form.monthlyCardAmt
        req.averageTransactionSizeInUsd = form.avgTxSize
        req.highestTransactionSizeInUsd = form.maxTxSize
        req.acceptAchPayment            = form.acceptACH == "Yes" ? "1" : "0"

        // Processing URLs
        req.paymentProcessingWebsiteUrl = form.processingURL
        req.demoLoginUsername           = form.demoUser
        req.demoLoginPassword           = form.demoPass

        // Business Ops
        req.advertiseType           = form.adMethods.joined(separator: ",")
        req.inboundPct              = Int(form.inboundPct)  ?? 0
        req.outboundPct             = Int(form.outboundPct) ?? 0
        req.b2bPct                  = Int(form.b2bPct)      ?? 0
        req.retailPct               = Int(form.b2cPct)      ?? 0
        req.isBusinessSeasonal      = form.isSeasonal == "Yes" ? 1 : 0
        req.returnRefundPolicyLink  = form.refundPolicy
        req.refundRequestWindow     = form.refundReqDays
        req.refundProcessWindow     = form.refundProcDays

        // Fulfillment
        req.cardChargeTiming          = form.cardChargedWhen
        req.usesThirdPartyFulfillment = form.thirdPartyFulfill == "Yes" ? 1 : 0

        // Risk
        req.isPciCompliant                    = form.pciCompliant       == "Yes" ? 1 : 0
        req.previouslyTerminatedByCardNetwork = form.terminatedMerchant == "Yes" ? 1 : 0
        req.dataCompromiseInvestigationHistory = form.dataCompromise    == "Yes" ? 1 : 0
        req.identifiedInVisaRiskPrograms      = form.visaRisk           == "Yes" ? 1 : 0
        req.thirdPartyPaymentParticipation    = form.thirdPartyPayment  == "Yes" ? 1 : 0

        // Bankruptcy
        req.bankruptcyStatus = form.filedBankruptcy

        print("🔨 [KYCEnterpriseViewModel] Request built successfully")
        debugPrintRequest(req)
        return req
    }

    // ════════════════════════════════════════════════════════════════
    // MARK: - Submit
    // ════════════════════════════════════════════════════════════════

    func submit(form: KYCFormSnapshot) {
        guard !adminUser.isEmpty, !uuid.isEmpty else {
            print("❌ [KYCEnterpriseViewModel] adminUser or uuid is empty")
            submissionState = .failure(message: "Session expired. Please log in again.")
            errorMessage = "Session expired. Please log in again."
            return
        }

        let request = buildRequest(from: form)
        let params  = KYCEnterpriseQueryParams(adminUser: adminUser, uuid: uuid)

        isLoading       = true
        submissionState = .loading
        errorMessage    = nil

        print("🚀 [KYCEnterpriseViewModel] Submitting KYC Enterprise form…")
        print("🚀 [KYCEnterpriseViewModel] adminUser=\(adminUser) | uuid=\(uuid)")

        service.saveEnterpriseUserInfo(queryParams: params, requestBody: request) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                print("✅ [KYCEnterpriseViewModel] Company Info Saved: \(response.isSanctionPassed ?? -1)")
                
                // Step 2: Upload Documents
                var docsData: [String: Data] = [:]
                let readData = { (url: URL?) -> Data? in
                    guard let u = url else { return nil }
                    _ = u.startAccessingSecurityScopedResource()
                    defer { u.stopAccessingSecurityScopedResource() }
                    return try? Data(contentsOf: u)
                }
                
                if let d = readData(form.incorporationCertificate) { docsData["incorporationCertificate"] = d }
                if let d = readData(form.memorandum)               { docsData["memorandum"] = d }
                if let d = readData(form.associationArticles)      { docsData["associationArticles"] = d }
                if let d = readData(form.incumbencyCertificate)    { docsData["incumbencyCertificate"] = d }
                if let d = readData(form.directorsRegister)        { docsData["directorsRegister"] = d }
                if let d = readData(form.shareholdersRegister)     { docsData["shareholdersRegister"] = d }
                if let d = readData(form.boardResolution)          { docsData["boardResolution"] = d }
                if let d = readData(form.addressProof)             { docsData["addressProof"] = d }
                if let d = readData(form.companyBankStatement)     { docsData["bankStatement"] = d }
                if let d = readData(form.wolfsbergDoc)             { docsData["wolfsbergDoc"] = d }
                if let d = readData(form.authorizationLetter)      { docsData["authorizationLetter"] = d }
                if let d = readData(form.processingStatement)      { docsData["processingStatement"] = d }
                
                print("🚀 [KYCEnterpriseViewModel] Uploading Documents...")
                let encoder = JSONEncoder()
                var enterpriseUserJSON = "{}"
                if let reqData = try? encoder.encode(request),
                   let reqStr = String(data: reqData, encoding: .utf8) {
                    enterpriseUserJSON = reqStr
                }
                
                self.service.addUserEnterpriseDetails(merchantId: self.adminUser, uuid: self.uuid, enterpriseUser: enterpriseUserJSON, documents: docsData) { docResult in
                    switch docResult {
                    case .success:
                        print("✅ [KYCEnterpriseViewModel] Documents Uploaded")
                        
                        // Step 3: Finish KYC
                        print("🚀 [KYCEnterpriseViewModel] Finishing KYC...")
                        self.service.finishKyc(adminUser: self.adminUser, uuid: self.uuid) { finishResult in
                            Task { @MainActor in
                                self.isLoading = false
                                switch finishResult {
                                case .success:
                                    print("✅ [KYCEnterpriseViewModel] KYC Finished successfully")
                                    self.submissionState = .success(message: "KYC information submitted successfully.")
                                    self.showSuccessAlert = true
                                case .failure(let error):
                                    print("❌ [KYCEnterpriseViewModel] Finish failed: \(error.localizedDescription)")
                                    self.submissionState = .failure(message: "Company Info & Docs saved, but failed to finalize: \(error.localizedDescription)")
                                    self.errorMessage = error.localizedDescription
                                }
                            }
                        }
                    case .failure(let error):
                        Task { @MainActor in
                            self.isLoading = false
                            print("❌ [KYCEnterpriseViewModel] Documents Upload failed: \(error.localizedDescription)")
                            self.submissionState = .failure(message: "Company info saved, but document upload failed: \(error.localizedDescription)")
                            self.errorMessage = error.localizedDescription
                        }
                    }
                }
                
            case .failure(let error):
                Task { @MainActor in
                    self.isLoading = false
                    print("❌ [KYCEnterpriseViewModel] Submission failed: \(error.localizedDescription)")
                    self.submissionState = .failure(message: error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════════════
    // MARK: - Reset
    // ════════════════════════════════════════════════════════════════

    func reset() {
        submissionState  = .idle
        isLoading        = false
        errorMessage     = nil
        showSuccessAlert = false
        print("🔄 [KYCEnterpriseViewModel] State reset")
    }

    // ════════════════════════════════════════════════════════════════
    // MARK: - Debug
    // ════════════════════════════════════════════════════════════════

    private func debugPrintRequest(_ req: KYCEnterpriseRequest) {
        print("\n🔍 ─────────────────────────────────────────────────────────")
        print("🔍 [KYCEnterpriseViewModel] FORM SNAPSHOT → REQUEST MAPPING")
        if let data   = try? JSONEncoder().encode(req),
           let obj    = try? JSONSerialization.jsonObject(with: data),
           let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
           let str    = String(data: pretty, encoding: .utf8) {
            print(str)
        }
        print("🔍 ─────────────────────────────────────────────────────────\n")
    }
}
