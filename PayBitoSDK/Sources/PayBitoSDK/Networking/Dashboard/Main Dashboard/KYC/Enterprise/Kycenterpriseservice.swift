// MARK: - KYCEnterpriseService.swift
// All Enterprise KYC networking — pure URLSession, no third-party dependencies.
// GetUserDetails uses POST (confirmed in network inspector screenshot).

import Foundation

// ════════════════════════════════════════════════════════════════════
// MARK: - Auth Token Manager
// ════════════════════════════════════════════════════════════════════

final class AuthTokenManager {
    static let shared = AuthTokenManager()
    private init() {}

    var bearerToken: String? {
        UserDefaults.standard.string(forKey: "Baccess_token") ?? UserDefaults.standard.string(forKey: "kSessionBearerToken")
    }

    func setToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "Baccess_token")
        UserDefaults.standard.set(token, forKey: "kSessionBearerToken")
    }
    func clearToken() {
        UserDefaults.standard.removeObject(forKey: "Baccess_token")
        UserDefaults.standard.removeObject(forKey: "kSessionBearerToken")
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - KYCEnterpriseQueryParams
// ════════════════════════════════════════════════════════════════════

struct KYCEnterpriseQueryParams {
    let adminUser: String
    let uuid:      String
}

// ════════════════════════════════════════════════════════════════════
// MARK: - KYCEnterpriseRequest
// ════════════════════════════════════════════════════════════════════

struct KYCEnterpriseRequest: Encodable {
    var companyName:                  String = ""
    var companyRegNo:                 String = ""
    var incorporationCountry:         String = ""
    var companyWebsite:               String = ""
    var dbaName:                      String = ""
    var businessPhoneNumber:          String = ""
    var businessEmailAddress:         String = ""
    var yearsInBusiness:              String = ""
    var businessDescription:          String = ""
    var businessActivity:             String = ""
    var businessActivityCode:         String = ""
    var businessActivitySearchTerm:   String = ""
    var stockExchangeName:            String = ""
    var stockTickerSymbol:            String = ""
    var identificationType:           String = ""
    var identificationNumber:         String = ""
    var isExemptPayee:                String = ""
    var isNpo:                        Int    = 0
    var companyregAddress:            String = ""
    var companyregCity:               String = ""
    var companyregState:              String = ""
    var companyregCountry:            String = ""
    var companyregZip:                String = ""
    var companyRegPremiseType:        String = ""
    var companyRegYearsInThisLocation: String = ""
    var premiseOwner:                 String = ""
    var areaZoned:                    String = ""
    var squareFootage:                String = ""
    var numberOfLocations:            String = ""
    var companyOfficeAddress:         String = ""
    var companyOfficeCity:            String = ""
    var companyOfficeState:           String = ""
    var companyOfficeCountry:         String = ""
    var companyOfficeZip:             String = ""
    var companyOfficePremiseType:     String = ""
    var companyOfficeYearsInThisLocation: String = ""
    var officePremiseOwner:           String = ""
    var officeAreaZoned:              String = ""
    var officeSquareFootage:          String = ""
    var revenue:                      String = ""
    var profit:                       String = ""
    var companyAssets:                String = ""
    var companyNetWorth:              String = ""
    var accountPurpose:               String = ""
    var investmentSource:             String = ""
    var transactionVolumes:           String = ""
    var transactionFrequency:         String = ""
    var bankingPartner:               String = ""
    var relationWithBank:             String = ""
    var isProcessingCardTransaction:  String = ""
    var onlineTxnPct:                 String = ""
    var inPersonSwipeTxnPct:          String = ""
    var overThePhoneTxnPct:           String = ""
    var keyEnteredTxnPct:             String = ""
    var amexMonthlyVolumeInUsd:       Double = 0
    var amexAvgTicketInUsd:           Double = 0
    var amexHighestTicketInUsd:       Double = 0
    var acceptAmexPayment:            Int    = 0
    var transactionLimitInUsd:        String = ""
    var averageTransactionSizeInUsd:  String = ""
    var highestTransactionSizeInUsd:  String = ""
    var acceptAchPayment:             String = ""
    var paymentProcessingWebsiteUrl:  String = ""
    var demoLoginUsername:            String = ""
    var demoLoginPassword:            String = ""
    var advertiseType:                String = ""
    var inboundPct:                   Int    = 0
    var outboundPct:                  Int    = 0
    var b2bPct:                       Int    = 0
    var retailPct:                    Int    = 0
    var isBusinessSeasonal:           Int    = 0
    var seasonalityDesc:              String = ""
    var returnRefundPolicyLink:       String = ""
    var refundRequestWindow:          String = ""
    var refundProcessWindow:          String = ""
    var cardChargeTiming:             String = ""
    var serviceDeliveryTimeDays:      String = ""
    var usesThirdPartyFulfillment:    Int    = 0
    var thirdPartyCompanyName:        String = ""
    var isPciCompliant:                     Int = 0
    var previouslyTerminatedByCardNetwork:  Int = 0
    var dataCompromiseInvestigationHistory: Int = 0
    var identifiedInVisaRiskPrograms:       Int = 0
    var thirdPartyPaymentParticipation:     Int = 0
    var thirdPartyPlatformName:       String = ""
    var bankruptcyStatus:             String = ""
    var bankruptcyFillingDate:        String = ""
    var incidentDetails:              String = ""
    var corporateStructure:           String = ""
}

// ════════════════════════════════════════════════════════════════════
// MARK: - KYCEnterpriseResponse
// ════════════════════════════════════════════════════════════════════

struct KYCEnterpriseResponse: Decodable {
    let error:             KYCEnterpriseError?
    let userListResult:    String?
    let userResult:        String?
    let chatMessageList:   String?
    let chatUserList:      String?
    let groupChatUserList: String?
    let groupChats:        String?
    let groupChat:         String?
    let totalcount:        Int?
    let isBlocked:         Int?
    let isSanctionPassed:  Int?
}

struct KYCEnterpriseError: Decodable {
    let errorData: AnyCodable?
    let errorMsg:  AnyCodable?
    enum CodingKeys: String, CodingKey {
        case errorData = "error_data"
        case errorMsg  = "error_msg"
    }
    var isSuccess: Bool {
        let msg = errorMsg?.stringValue ?? ""
        let code = errorData?.stringValue ?? ""
        return msg.isEmpty || code == "0"
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - MCC Response Models
// Mirrors the JSON shape returned by getMerchantCategoryCodes:
//   { "mccList": [ { "MCC": "0742", "DESCRIPTION": "Veterinary Services" }, … ] }
// ════════════════════════════════════════════════════════════════════

/// Top-level wrapper returned by GET /kyc/getMerchantCategoryCodes
struct MCCListResponse: Decodable {
    let mccList: [MCCItem]
}

/// A single MCC entry as returned by the API.
struct MCCItem: Decodable {
    let mcc:         String
    let description: String

    enum CodingKeys: String, CodingKey {
        case mcc         = "MCC"
        case description = "DESCRIPTION"
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Service Errors
// ════════════════════════════════════════════════════════════════════

enum KYCServiceError: LocalizedError {
    case invalidURL
    case missingAuthToken
    case encodingFailed
    case httpError(statusCode: Int, message: String)
    case emptyResponse
    case apiError(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "The request URL is invalid."
        case .missingAuthToken:        return "Authentication token is missing. Please log in again."
        case .encodingFailed:          return "Failed to encode the request. Please try again."
        case .httpError(let c, let m): return "Server returned HTTP \(c): \(m)"
        case .emptyResponse:           return "The server returned an empty response."
        case .apiError(let m):         return m
        }
    }
}

enum GetUserDetailsError: LocalizedError {
    case missingAuthToken
    case invalidURL
    case encodingFailed
    case httpError(statusCode: Int, message: String)
    case emptyResponse
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAuthToken:        return "Authentication token is missing. Please log in again."
        case .invalidURL:              return "The request URL is invalid."
        case .encodingFailed:          return "Failed to encode request body."
        case .httpError(let c, let m): return "Server returned HTTP \(c): \(m)"
        case .emptyResponse:           return "The server returned an empty response."
        case .decodingFailed(let m):   return "Failed to decode response: \(m)"
        }
    }
}

/// Errors specific to the getMerchantCategoryCodes endpoint.
enum MCCServiceError: LocalizedError {
    case missingAuthToken
    case missingUUID
    case invalidURL
    case httpError(statusCode: Int, message: String)
    case emptyResponse
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingAuthToken:        return "Authentication token is missing. Please log in again."
        case .missingUUID:             return "User UUID is missing. Please log in again."
        case .invalidURL:              return "The MCC request URL is invalid."
        case .httpError(let c, let m): return "Server returned HTTP \(c): \(m)"
        case .emptyResponse:           return "The server returned an empty MCC list."
        case .decodingFailed(let m):   return "Failed to decode MCC response: \(m)"
        }
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Protocols
// ════════════════════════════════════════════════════════════════════

protocol KYCEnterpriseServiceProtocol {
    func saveEnterpriseUserInfo(
        queryParams: KYCEnterpriseQueryParams,
        requestBody: KYCEnterpriseRequest,
        completion:  @escaping (Swift.Result<KYCEnterpriseResponse, Error>) -> Void
    )
    
    func addUserEnterpriseDetails(
        merchantId: String,
        uuid: String,
        enterpriseUser: String,
        documents: [String: Data],
        completion: @escaping (Swift.Result<[String: Any], Error>) -> Void
    )
    
    func finishKyc(
        adminUser: String,
        uuid: String,
        completion: @escaping (Swift.Result<[String: Any], Error>) -> Void
    )
}

protocol GetUserDetailsServiceProtocol {
    func fetchUserDetails(
        brokerId:   String,
        completion: @escaping (Swift.Result<GetUserDetailsResponse, Error>) -> Void
    )
}

/// Protocol for the MCC list endpoint — enables mocking in unit tests.
protocol GetMerchantCategoryServiceProtocol {
    func fetchMCCList(
        uuid:       String,
        completion: @escaping (Swift.Result<[MCCItem], MCCServiceError>) -> Void
    )
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Shared URLSession factory
// ════════════════════════════════════════════════════════════════════

private extension URLSession {
    static func kyc(timeout: TimeInterval = 60) -> URLSession {
        let cfg = URLSessionConfiguration.default
        cfg.timeoutIntervalForRequest  = timeout
        cfg.timeoutIntervalForResource = timeout * 2
        return URLSession(configuration: cfg)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - KYCEnterpriseService  (POST saveEnterpriseUserInfo)
// ════════════════════════════════════════════════════════════════════

final class KYCEnterpriseService: KYCEnterpriseServiceProtocol {

    static let shared = KYCEnterpriseService()
    private init() {}

    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/saveEnterpriseUserInfo"
    private lazy var session = URLSession.kyc(timeout: 60)

    func saveEnterpriseUserInfo(
        queryParams: KYCEnterpriseQueryParams,
        requestBody: KYCEnterpriseRequest,
        completion:  @escaping (Swift.Result<KYCEnterpriseResponse, Error>) -> Void
    ) {
        let urlString = "\(baseURL)?adminUser=\(queryParams.adminUser)&uuid=\(queryParams.uuid)"

        guard let url = URL(string: urlString) else {
            completion(.failure(KYCServiceError.invalidURL)); return
        }
        guard let token = AuthTokenManager.shared.bearerToken, !token.isEmpty else {
            completion(.failure(KYCServiceError.missingAuthToken)); return
        }
        let body: Data
        do { body = try JSONEncoder().encode(requestBody) }
        catch { completion(.failure(KYCServiceError.encodingFailed)); return }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody   = body
        req.setValue("application/json",                  forHTTPHeaderField: "Content-Type")
        req.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)",                   forHTTPHeaderField: "Authorization")
        req.setValue("https://trade.paybito.com",         forHTTPHeaderField: "Origin")
        req.setValue("https://trade.paybito.com/",        forHTTPHeaderField: "Referer")

        debugRequest(label: "KYCEnterpriseService", url: urlString, token: token, body: body)

        session.dataTask(with: req) { data, response, error in
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            debugResponse(label: "KYCEnterpriseService", status: status, data: data)

            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard (200..<300).contains(status) else {
                let msg = HTTPURLResponse.localizedString(forStatusCode: status)
                DispatchQueue.main.async {
                    completion(.failure(KYCServiceError.httpError(statusCode: status, message: msg)))
                }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(KYCServiceError.emptyResponse)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(KYCEnterpriseResponse.self, from: data)
                if let apiErr = decoded.error, !apiErr.isSuccess {
                    let msg = apiErr.errorMsg?.stringValue ?? "Unknown API error"
                    DispatchQueue.main.async { completion(.failure(KYCServiceError.apiError(message: msg))) }
                } else {
                    print("✅ [KYCEnterpriseService] Success — isSanctionPassed: \(decoded.isSanctionPassed ?? -1)")
                    DispatchQueue.main.async { completion(.success(decoded)) }
                }
            } catch {
                print("❌ [KYCEnterpriseService] Decode error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - GetUserDetailsService  (POST — confirmed in network inspector)
//
// Network inspector shows:
//   URL    : /billbitcoins-v2/kyc/GetUserDetails
//   Method : POST
//   Body   : JSON { "brokerId": "<value>" }
// ════════════════════════════════════════════════════════════════════

final class GetUserDetailsService: GetUserDetailsServiceProtocol {

    static let shared = GetUserDetailsService()
    private init() {}

    private let url = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/GetUserDetails"
    private lazy var session = URLSession.kyc(timeout: 30)

    func fetchUserDetails(
        brokerId:   String,
        completion: @escaping (Swift.Result<GetUserDetailsResponse, Error>) -> Void
    ) {
        guard let token = AuthTokenManager.shared.bearerToken, !token.isEmpty else {
            print("❌ [GetUserDetailsService] Missing bearer token")
            completion(.failure(GetUserDetailsError.missingAuthToken))
            return
        }
        guard let url = URL(string: self.url) else {
            completion(.failure(GetUserDetailsError.invalidURL))
            return
        }

        // Body: JSON { "brokerId": "<value>" }
        let bodyDict: [String: String] = ["brokerId": brokerId]
        let body: Data
        do { body = try JSONSerialization.data(withJSONObject: bodyDict, options: []) }
        catch {
            completion(.failure(GetUserDetailsError.encodingFailed))
            return
        }

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.httpBody   = body
        req.setValue("application/json",                  forHTTPHeaderField: "Content-Type")
        req.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)",                   forHTTPHeaderField: "Authorization")
        req.setValue("https://trade.paybito.com",         forHTTPHeaderField: "Origin")
        req.setValue("https://trade.paybito.com/",        forHTTPHeaderField: "Referer")

        debugRequest(label: "GetUserDetailsService", url: self.url, token: token, body: body)

        session.dataTask(with: req) { data, response, error in
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            debugResponse(label: "GetUserDetailsService", status: status, data: data)

            if let error = error {
                print("❌ [GetUserDetailsService] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard (200..<300).contains(status) else {
                let msg = HTTPURLResponse.localizedString(forStatusCode: status)
                print("❌ [GetUserDetailsService] HTTP \(status): \(msg)")
                DispatchQueue.main.async {
                    completion(.failure(GetUserDetailsError.httpError(statusCode: status, message: msg)))
                }
                return
            }
            guard let data = data else {
                print("❌ [GetUserDetailsService] Empty response body")
                DispatchQueue.main.async { completion(.failure(GetUserDetailsError.emptyResponse)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(GetUserDetailsResponse.self, from: data)
                print("✅ [GetUserDetailsService] Decoded OK")
                print("✅   userDocsStatus = \(decoded.userDocsStatus?.stringValue ?? "nil")")
                print("✅   uuid           = \(decoded.uuid ?? "nil")")
                print("✅   enterpriseUser = \(decoded.enterpriseUser != nil ? "present" : "nil")")
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                print("❌ [GetUserDetailsService] Decode error: \(error)")
                if let raw = String(data: data, encoding: .utf8) { print("❌ Raw: \(raw)") }
                DispatchQueue.main.async {
                    completion(.failure(GetUserDetailsError.decodingFailed(error.localizedDescription)))
                }
            }
        }.resume()
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - GetMerchantCategoryService
//
// GET https://service.hashcashconsultants.com/billbitcoins-v2/kyc/getMerchantCategoryCodes
//
// Observed headers (Postman + Network Inspector screenshots):
//   Authorization : Bearer <token>
//   uuid          : <user uuid>          ← confirmed in Postman header tab
//   Content-Type  : application/json
//   Accept        : application/json, text/plain, */*
//   origin        : https://trade.paybito.com
//
// Response shape:
//   { "mccList": [ { "MCC": "0742", "DESCRIPTION": "Veterinary Services" }, … ] }
// ════════════════════════════════════════════════════════════════════

final class GetMerchantCategoryService: GetMerchantCategoryServiceProtocol {

    static let shared = GetMerchantCategoryService()
    private init() {}

    private let endpoint = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/getMerchantCategoryCodes"
    private lazy var session = URLSession.kyc(timeout: 60)

    // ── Fetch ─────────────────────────────────────────────────────

    func fetchMCCList(
        uuid:       String,
        completion: @escaping (Swift.Result<[MCCItem], MCCServiceError>) -> Void
    ) {
        // 1. Guard: bearer token  ← reads from same UserDefaults key as all other services
        guard let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty else {
            print("❌ [GetMerchantCategoryService] Missing bearer token — aborting")
            DispatchQueue.main.async { completion(.failure(.missingAuthToken)) }
            return
        }

        // 2. Guard: UUID
        guard !uuid.isEmpty else {
            print("❌ [GetMerchantCategoryService] UUID is empty — aborting")
            DispatchQueue.main.async { completion(.failure(.missingUUID)) }
            return
        }

        // 3. Guard: URL
        guard let url = URL(string: endpoint) else {
            print("❌ [GetMerchantCategoryService] Invalid URL: \(endpoint)")
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }

        // 4. Build request
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json",                  forHTTPHeaderField: "Content-Type")
        req.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        req.setValue("Bearer \(token)",                   forHTTPHeaderField: "Authorization")
        req.setValue(uuid,                                forHTTPHeaderField: "uuid")
        req.setValue("https://trade.paybito.com",         forHTTPHeaderField: "origin")

        // 5. Debug — request (reuse shared printer, no body for GET)
        debugGETRequest(label: "GetMerchantCategoryService", url: endpoint, token: token, uuid: uuid)

        // 6. Fire
        session.dataTask(with: req) { data, response, error in
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1

            // 7. Debug — response
            debugResponse(label: "GetMerchantCategoryService", status: status, data: data)

            // 8. Network-level error
            if let error = error {
                print("❌ [GetMerchantCategoryService] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error.localizedDescription))) }
                return
            }

            // 9. HTTP status check
            guard (200..<300).contains(status) else {
                let msg = HTTPURLResponse.localizedString(forStatusCode: status)
                print("❌ [GetMerchantCategoryService] HTTP \(status): \(msg)")
                DispatchQueue.main.async { completion(.failure(.httpError(statusCode: status, message: msg))) }
                return
            }

            // 10. Empty body check
            guard let data = data, !data.isEmpty else {
                print("❌ [GetMerchantCategoryService] Empty response body")
                DispatchQueue.main.async { completion(.failure(.emptyResponse)) }
                return
            }

            // 11. Decode
            do {
                let decoded = try JSONDecoder().decode(MCCListResponse.self, from: data)

                guard !decoded.mccList.isEmpty else {
                    print("⚠️  [GetMerchantCategoryService] mccList decoded but is empty")
                    DispatchQueue.main.async { completion(.failure(.emptyResponse)) }
                    return
                }

                print("✅ [GetMerchantCategoryService] Decoded \(decoded.mccList.count) MCC entries")
                // Print first 5 as a sanity check
                decoded.mccList.prefix(5).forEach {
                    print("✅   MCC \($0.mcc) → \($0.description)")
                }

                DispatchQueue.main.async { completion(.success(decoded.mccList)) }

            } catch {
                print("❌ [GetMerchantCategoryService] Decode error: \(error)")
                if let raw = String(data: data, encoding: .utf8) {
                    print("❌ [GetMerchantCategoryService] Raw response: \(raw.prefix(500))")
                }
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error.localizedDescription)))
                }
            }
        }.resume()
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - GetCountriesService
// ════════════════════════════════════════════════════════════════════

protocol GetCountriesServiceProtocol {
    func fetchCountries(completion: @escaping (Swift.Result<[String], MCCServiceError>) -> Void)
}

struct KYCCountriesResponse: Decodable {
    let countries: [KYCCountry]?
}

struct KYCCountry: Decodable {
    let country: String
}

final class GetCountriesService: GetCountriesServiceProtocol {
    static let shared = GetCountriesService()
    private init() {}

    private let endpoint = "https://accounts.paybito.com/api/home/getExchangeCountries/PAYB18022021121103"
    private lazy var session = URLSession.kyc(timeout: 30)

    func fetchCountries(completion: @escaping (Swift.Result<[String], MCCServiceError>) -> Void) {
        guard let url = URL(string: endpoint) else {
            DispatchQueue.main.async { completion(.failure(.invalidURL)) }
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        req.setValue("https://trade.paybito.com", forHTTPHeaderField: "origin")

        session.dataTask(with: req) { data, response, error in
            let status = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("🌍 [GetCountriesService] HTTP Status: \(status)")

            if let error = error {
                print("❌ [GetCountriesService] Network error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error.localizedDescription))) }
                return
            }
            guard let data = data else {
                print("❌ [GetCountriesService] Empty response body")
                DispatchQueue.main.async { completion(.failure(.emptyResponse)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(KYCCountriesResponse.self, from: data)
                let names = (decoded.countries ?? []).map { $0.country }.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                print("✅ [GetCountriesService] Fetched \(names.count) countries")
                DispatchQueue.main.async { completion(.success(names)) }
            } catch {
                print("❌ [GetCountriesService] Decode error: \(error)")
                if let raw = String(data: data, encoding: .utf8) { print("❌ Raw: \(raw.prefix(500))") }
                DispatchQueue.main.async { completion(.failure(.decodingFailed(error.localizedDescription))) }
            }
        }.resume()
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Shared Debug Helpers
// ════════════════════════════════════════════════════════════════════

/// Used by POST services (prints request body).
private func debugRequest(label: String, url: String, token: String, body: Data) {
    print("\n📤 ─────────────────────────────────────────────────────────")
    print("📤 [\(label)] REQUEST")
    print("📤 URL    : \(url)")
    print("📤 Method : POST")
    print("📤 Auth   : Bearer \(token.prefix(20))…")
    if let obj    = try? JSONSerialization.jsonObject(with: body),
       let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
       let str    = String(data: pretty, encoding: .utf8) {
        print("📤 Body   :\n\(str)")
    }
    print("📤 ─────────────────────────────────────────────────────────\n")
}

/// Used by GET services (no body — prints headers instead).
private func debugGETRequest(label: String, url: String, token: String, uuid: String) {
    print("\n📤 ─────────────────────────────────────────────────────────")
    print("📤 [\(label)] REQUEST")
    print("📤 URL    : \(url)")
    print("📤 Method : GET")
    print("📤 Auth   : Bearer \(token.prefix(20))…")
    print("📤 uuid   : \(uuid)")
    print("📤 origin : https://trade.paybito.com")
    print("📤 ─────────────────────────────────────────────────────────\n")
}

/// Shared response printer used by all services.
private func debugResponse(label: String, status: Int, data: Data?) {
    print("\n📥 ─────────────────────────────────────────────────────────")
    print("📥 [\(label)] RESPONSE  Status: \(status)")
    if let data = data,
       let obj    = try? JSONSerialization.jsonObject(with: data),
       let pretty = try? JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted),
       let str    = String(data: pretty, encoding: .utf8) {
        // Cap at 2 000 chars so the MCC list (50 KB) doesn't flood the console
        let preview = str.count > 2_000 ? String(str.prefix(2_000)) + "\n… (truncated — \(str.count) chars total)" : str
        print(preview)
    }
    print("📥 ─────────────────────────────────────────────────────────\n")
}

import Alamofire

extension KYCEnterpriseService {
    // MARK: - Step 2: Upload Documents
    func addUserEnterpriseDetails(
        merchantId: String,
        uuid: String,
        enterpriseUser: String,
        documents: [String: Data],
        completion: @escaping (Swift.Result<[String: Any], Error>) -> Void
    ) {
        let url = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/addUserEnterpriseDetails"
        let headers: HTTPHeaders = [
            "Authorization": "bearer \(AuthTokenManager.shared.bearerToken ?? "")",
            "UUID": uuid,
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]
        
        Alamofire.upload(multipartFormData: { form in
            form.append(merchantId.data(using: .utf8)!, withName: "merchant_id")
            form.append(uuid.data(using: .utf8)!, withName: "uuid")
            form.append(enterpriseUser.data(using: .utf8)!, withName: "enterpriseUser")
            
            for (key, data) in documents {
                form.append(data, withName: key, fileName: "\(key).pdf", mimeType: "application/pdf")
            }
        }, to: url, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let json = response.result.value as? [String: Any],
                       let errorObj = json["error"] as? [String: Any],
                       let errorDataRaw = errorObj["error_data"],
                       ("\(errorDataRaw)" == "0" || "\(errorDataRaw)" == "0.0") {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(domain: "KYCEnterpriseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to upload documents"])))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Step 3: Add Owner
    func addEnterpriseOwner(
        adminUser: String,
        uuid: String,
        ownerData: [String: String],
        ownerFiles: [String: Data],
        completion: @escaping (Swift.Result<[String: Any], Error>) -> Void
    ) {
        let url = "https://service.hashcashconsultants.com/billbitcoins-v2/payment/addEnterpriseOwner"
        let headers: HTTPHeaders = [
            "Authorization": "bearer \(AuthTokenManager.shared.bearerToken ?? "")",
            "UUID": uuid,
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]
        
        Alamofire.upload(multipartFormData: { form in
            form.append(adminUser.data(using: .utf8)!, withName: "adminUser")
            form.append(uuid.data(using: .utf8)!, withName: "uuid")
            
            for (key, val) in ownerData {
                if let d = val.data(using: .utf8) { form.append(d, withName: key) }
            }
            for (key, data) in ownerFiles {
                form.append(data, withName: key, fileName: "\(key).jpg", mimeType: "image/jpeg")
            }
        }, to: url, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let json = response.result.value as? [String: Any],
                       let errorObj = json["error"] as? [String: Any],
                       let errorDataRaw = errorObj["error_data"],
                       ("\(errorDataRaw)" == "0" || "\(errorDataRaw)" == "0.0") {
                        completion(.success(json))
                    } else {
                        completion(.failure(NSError(domain: "KYCEnterpriseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add owner"])))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Step 4: Finish KYC
    func finishKyc(
        adminUser: String,
        uuid: String,
        completion: @escaping (Swift.Result<[String: Any], Error>) -> Void
    ) {
        let url = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/finishKyc?uuid=\(uuid)"
        let headers: HTTPHeaders = [
            "Authorization": "bearer \(AuthTokenManager.shared.bearerToken ?? "")",
            "UUID": uuid,
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]
        
        let params: [String: Any] = [
            "adminUser": adminUser
        ]
        
        Alamofire.request(url, method: .post, parameters: params, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            if let json = response.result.value as? [String: Any],
               let errorObj = json["error"] as? [String: Any],
               let errorDataRaw = errorObj["error_data"],
               ("\(errorDataRaw)" == "0" || "\(errorDataRaw)" == "0.0") {
                completion(.success(json))
            } else {
                completion(.failure(NSError(domain: "KYCEnterpriseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to finish KYC"])))
            }
        }
    }
}
