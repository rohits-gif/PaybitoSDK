//
//  Addenterpriseownermodels.swift
//  PaymentsTerminsl
//
//  Created by HashCash on 15/06/26.
//

// MARK: - AddEnterpriseOwnerModels.swift

import Foundation

// ════════════════════════════════════════════════════════════════════
// MARK: - UBO Owner Model
// ════════════════════════════════════════════════════════════════════

struct UBOOwner: Identifiable, Codable, Equatable {
    var id             = UUID()
    var ownerUuid      = ""
    var enterpriseId   = ""
    var ownerType      = "Authorized signatory"
    var ownershipPct   = ""
    var firstName      = ""
    var middleName     = ""
    var lastName       = ""
    var email          = ""
    var phoneCode      = "+1"
    var phone          = ""
    var dob            = ""
    var placeOfBirth   = ""
    var ssnPassport    = ""
    var street         = ""
    var city           = ""
    var addrState      = ""
    var country        = ""
    var zip            = ""
    var isPEP          = "No"
    var idDocType      = ""
    var idCountry      = ""
    var idState        = ""
    var govIdFront     = ""
    var govIdBack      = ""
    var poaType        = ""
    var proofOfAddress = ""
    var selfieFile     = ""
    var investmentFile = ""

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - API Request Models
// ════════════════════════════════════════════════════════════════════

struct AddOwnerPayload: Encodable {
    var firstName:           String = ""
    var middleName:          String = ""
    var lastName:            String = ""
    var email:               String = ""
    var phone:               String = ""
    var address:             String = ""
    var city:                String = ""
    var state:               String = ""
    var country:             String = ""
    var zip:                 String = ""
    var dob:                 String = ""
    var birthPlace:          String = ""
    var ssn:                 String = ""
    var ownerShipPer:        String = ""
    var pep:                 Int    = 0
    var action:              String = "INSERT"
    var ownerType:           String = ""
    var ownerUuid:           String = ""
    var identityDocType:     String = ""
    var identityDocCountry:  String = ""
    var identityDocState:    String = ""
    var addressProofDocType: String = ""

    enum CodingKeys: String, CodingKey {
        case firstName, middleName, lastName, email, phone
        case address, city, state, country, zip
        case dob, birthPlace, ssn
        case ownerShipPer = "ownershipPer"
        case pep
        case action, ownerType, ownerUuid
        case identityDocType, identityDocCountry, identityDocState
        case addressProofDocType = "addrssProofDocType"
    }
}

struct AddOwnerDocAttachment {
    let fieldName: String  // "idProofFront" | "idProofBack" | "addressProofDoc" | "selfieDoc" | "investmentProofDoc"
    let fileData:  Data
    let fileName:  String
    let mimeType:  String
}

struct AddOwnerQueryParams {
    let merchantId: String
    let userUuid:   String
    
    
}


// ════════════════════════════════════════════════════════════════════
// MARK: - API Response Models
// ════════════════════════════════════════════════════════════════════

struct AddEnterpriseOwnerResponse: Decodable {
    let error:            AddOwnerAPIError?
    let isSanctionPassed: AnyCodable?
    let isBlocked:        AnyCodable?
    let totalcount:       AnyCodable?
}

struct AddOwnerAPIError: Decodable {
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
// MARK: - Service Errors
// ════════════════════════════════════════════════════════════════════

enum AddOwnerServiceError: LocalizedError {
    case invalidURL, missingAuthToken, encodingFailed, emptyResponse
    case httpError(statusCode: Int, message: String)
    case apiError(message: String)
    case sanctionFailed
    case ownerBlocked

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return "The request URL is invalid."
        case .missingAuthToken:        return "Authentication token is missing."
        case .encodingFailed:          return "Failed to encode the request."
        case .httpError(let c, let m): return "Server returned HTTP \(c): \(m)"
        case .emptyResponse:           return "The server returned an empty response."
        case .apiError(let m):         return m
        case .sanctionFailed:
            return "This owner did not pass sanction screening. Please verify the details and try again, or contact support."
        case .ownerBlocked:
            return "This owner is blocked and cannot be added. Please contact support for assistance."
        }
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - File Validation Helper
// ════════════════════════════════════════════════════════════════════

import UniformTypeIdentifiers

enum UBOFileValidation {
    static let maxBytes: Int64 = 6 * 1024 * 1024 // 6MB
    static let allowedExtensions: Set<String> = ["jpg", "jpeg", "png", "pdf", "doc", "docx", "jfif", "heic"]

    static let allowedContentTypes: [UTType] = [
        .pdf, .png, .jpeg, .heic,
        UTType(filenameExtension: "jfif") ?? .image,
        UTType(filenameExtension: "doc") ?? .data,
        UTType(filenameExtension: "docx") ?? .data
    ]

    /// Returns nil if valid, or an error message string if invalid.
    static func validate(_ url: URL) -> String? {
        let ext = url.pathExtension.lowercased()
        guard allowedExtensions.contains(ext) else {
            return "Unsupported file type \".\(ext)\". Accepted: JPG, PNG, PDF, DOC, DOCX, JFIF, HEIC."
        }
        let needsSecurityScope = url.startAccessingSecurityScopedResource()
        defer { if needsSecurityScope { url.stopAccessingSecurityScopedResource() } }

        if let values = try? url.resourceValues(forKeys: [.fileSizeKey]),
           let size = values.fileSize {
            if Int64(size) > maxBytes {
                return "File is too large (max 6MB)."
            }
        }
        return nil
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Helpers
// ════════════════════════════════════════════════════════════════════

extension Data {
    mutating func addString(_ s: String) {
        if let d = s.data(using: .utf8) { append(d) }
    }
}

extension URL {
    var mimeType: String {
        switch pathExtension.lowercased() {
        case "jpg", "jpeg", "jfif": return "image/jpeg"
        case "png":                  return "image/png"
        case "heic":                 return "image/heic"
        case "pdf":                  return "application/pdf"
        case "doc":                  return "application/msword"
        case "docx":                 return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default:                     return "application/octet-stream"
        }
    }
}
