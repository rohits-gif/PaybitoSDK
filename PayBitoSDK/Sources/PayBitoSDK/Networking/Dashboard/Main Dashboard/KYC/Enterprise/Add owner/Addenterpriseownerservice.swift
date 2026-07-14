
//
//  Addenterpriseownerservice.swift
//  PaymentsTerminsl
//
//  Created by HashCash on 15/06/26.
//

// MARK: - AddEnterpriseOwnerService.swift
// POST multipart/form-data → /kyc/addEnterpriseOwner

import Foundation
import Alamofire

final class AddEnterpriseOwnerService {

    static let shared = AddEnterpriseOwnerService()
    private init() {}

    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/addEnterpriseOwner"

    func addOwner(
        queryParams:  AddOwnerQueryParams,
        ownerPayload: AddOwnerPayload,
        attachments:  [AddOwnerDocAttachment],
        completion:   @escaping (Swift.Result<AddEnterpriseOwnerResponse, Swift.Error>) -> Void
    ) {
        // Auth token
        guard let token = AuthTokenManager.shared.bearerToken, !token.isEmpty else {
            print("❌ [AddEnterpriseOwnerService] Missing bearer token")
            completion(.failure(AddOwnerServiceError.missingAuthToken)); return
        }

        // Defensive copy + sanitize: the backend rejects a leading "+" (or any
        // non-digit character) in the phone field with
        // {"error_data":1,"error_msg":"Invalid input."}. Enforce digits-only
        // here as a last line of defense, regardless of what the caller passed in.
        var sanitizedPayload = ownerPayload
        sanitizedPayload.phone = sanitizedPayload.phone.filter { $0.isNumber }

        // Encode owner → JSON string
        let ownerJSON: String
        let encoder = JSONEncoder()
        if #available(iOS 13.0, *) {
            encoder.outputFormatting = .withoutEscapingSlashes
        }
        do {
            let d = try encoder.encode(sanitizedPayload)
            ownerJSON = String(data: d, encoding: .utf8) ?? "{}"
        } catch {
            print("❌ [AddEnterpriseOwnerService] Encode failed: \(error)")
            completion(.failure(AddOwnerServiceError.encodingFailed)); return
        }

        // Headers
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/",
            "Accept": "application/json, text/plain, */*",
            "UUID": queryParams.userUuid
        ]

        print("🚀 [AddEnterpriseOwnerService] request payload ownerJSON: \(ownerJSON)")
        print("🚀 [AddEnterpriseOwnerService] request UUID: \(queryParams.userUuid)")
        print("🚀 [AddEnterpriseOwnerService] request merchant_id: \(queryParams.merchantId)")
        print("🚀 [AddEnterpriseOwnerService] request attachments: \(attachments.map { "\($0.fieldName): \($0.fileName) (\($0.fileData.count) bytes)" })")

        Alamofire.upload(multipartFormData: { form in
            // Text fields
            if let d = ownerJSON.data(using: .utf8) { form.append(d, withName: "owner") }
            if let d = queryParams.merchantId.data(using: .utf8) { form.append(d, withName: "merchant_id") }
            if let d = queryParams.userUuid.data(using: .utf8) { form.append(d, withName: "userUuid") }

            // File fields — each becomes a proper multipart file part with filename + Content-Type
            for att in attachments {
                form.append(att.fileData, withName: att.fieldName, fileName: att.fileName, mimeType: att.mimeType)
            }
        }, to: baseURL, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard let data = response.data else {
                        completion(.failure(AddOwnerServiceError.emptyResponse))
                        return
                    }
                    if let str = String(data: data, encoding: .utf8) {
                        print("✅ [AddEnterpriseOwnerService] Response: \(str)")
                    }
                    do {
                        let decoded = try JSONDecoder().decode(AddEnterpriseOwnerResponse.self, from: data)

                        if let apiErr = decoded.error, !apiErr.isSuccess {
                            let msg = apiErr.errorMsg?.stringValue ?? "Unknown API error"
                            completion(.failure(AddOwnerServiceError.apiError(message: msg)))
                            return
                        }

                        // Check sanction / block flags
                        if decoded.isBlocked?.stringValue == "1" {
                            completion(.failure(AddOwnerServiceError.ownerBlocked))
                            return
                        }
                        if decoded.isSanctionPassed?.stringValue == "0" {
                            completion(.failure(AddOwnerServiceError.sanctionFailed))
                            return
                        }

                        completion(.success(decoded))
                    } catch {
                        print("❌ [AddEnterpriseOwnerService] Decode failed: \(error)")
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                print("❌ [AddEnterpriseOwnerService] Alamofire upload failed: \(error)")
                completion(.failure(error))
            }
        }
    }
}
