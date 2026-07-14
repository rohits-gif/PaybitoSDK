//
//  WebhookEndpointModel.swift
//  Trading_Terminal  /  PaymentsTerminal
//
//  Single source of truth — remove Webhooksendpointmodel.swift entirely.
//

import Foundation

// MARK: - Fetch Response

struct WHEndpointListResponse: Decodable {
    let data: [WHEndpointAPIModel]
}

// MARK: - Core API Model

struct WHEndpointAPIModel: Decodable, Identifiable {
    let epId:         Int
    let merchantId:   Int
    let url:          String
    let description:  String?
    let eventsMode:   String      // "all" or specific mode
    let secret:       String?
    let retryEnabled: String      // "Y" / "N"
    let maxRetries:   Int
    let timeoutSec:   Int
    let status:       String      // "Active" / "Inactive"
    let lastDelivery: String?
    let eventCount:   Int
    let events:       [String]

    var id: Int { epId }

    var isActiveEndpoint: Bool   { status.lowercased() == "active" }
    var isRetryOn:        Bool   { retryEnabled.uppercased() == "Y" }
    var displayEventType: String { eventsMode == "all" ? "All events" : eventsMode }
    var safeDescription:  String { description ?? "" }
}

// MARK: - UI Display Item

struct WHEndpointDisplayItem: Identifiable {
    let id:           Int        // epId
    let merchantId:   Int
    let url:          String
    let description:  String
    let eventsMode:   String
    let secret:       String?
    let retryEnabled: Bool
    let maxRetries:   Int
    let timeoutSec:   Int
    let isActive:     Bool
    let lastDelivery: String?
    let eventCount:   Int
    let events:       [String]

    var eventType: String { eventsMode == "all" ? "All events" : eventsMode }

    init(from api: WHEndpointAPIModel) {
        self.id           = api.epId
        self.merchantId   = api.merchantId
        self.url          = api.url
        self.description  = api.safeDescription
        self.eventsMode   = api.eventsMode
        self.secret       = api.secret
        self.retryEnabled = api.isRetryOn
        self.maxRetries   = api.maxRetries
        self.timeoutSec   = api.timeoutSec
        self.isActive     = api.isActiveEndpoint
        self.lastDelivery = api.lastDelivery
        self.eventCount   = api.eventCount
        self.events       = api.events
    }
}

// MARK: - Add / Update / Delete Responses

// ✅ matches actual API response pattern
struct WHAddEndpointResponse: Decodable {
    let data:         Int?      // epId may come here
    let status:       Bool?     // true / false  ← was String, now Bool
    let error:        String?
    let message:      String?
    let epId:         Int?      // may also be top-level
    let totalRecords: Int?
    let page:         Int?
    let size:         Int?
}

struct WHUpdateEndpointResponse: Decodable {
    let data:         String?   // null
    let status:       Bool?     // true / false
    let error:        String?   // "0"
    let message:      String?   // "SUCCESS"
    let totalRecords: Int?      // null
    let page:         Int?      // null
    let size:         Int?      // null

    var isSuccess: Bool { status == true && message?.uppercased() == "SUCCESS" }
}

struct WHDeleteEndpointResponse: Decodable {
    let message: String?
    let status:  String?
}

// MARK: - API Error

struct WHAPIErrorResponse: Decodable {
    let message: String?
    let error:   String?
    var resolvedMessage: String { message ?? error ?? "Unknown error occurred." }
}

// MARK: - Network Error Enum

enum WHNetworkError: LocalizedError {
    case invalidEndpointURL
    case missingAuthCredentials
    case serverError(statusCode: Int, message: String)
    case decodingFailure(underlying: Error)
    case noInternetConnection
    case requestTimedOut
    case unknown(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .invalidEndpointURL:              return "The webhook endpoint URL is malformed."
        case .missingAuthCredentials:          return "Authorization credentials are missing."
        case .serverError(let code, let msg):  return "Server returned \(code): \(msg)"
        case .decodingFailure(let err):        return "Failed to parse response: \(err.localizedDescription)"
        case .noInternetConnection:            return "No internet connection. Please try again."
        case .requestTimedOut:                 return "Request timed out. Please try again."
        case .unknown(let err):               return err.localizedDescription
        }
    }
}
