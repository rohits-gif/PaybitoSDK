//
//  DeleteEnterpriseOwnerService.swift
//  PaymentsTerminsl
//
//  Created by HashCash.
//

import Foundation
import Alamofire

struct DeleteEnterpriseOwnerPayload: Codable {
    let ownerUuid:    String
    let enterpriseId: String
    let action:       String // "DELETE"
}

struct DeleteEnterpriseOwnerResponse: Decodable {
    let error: AddOwnerAPIError?
}

final class DeleteEnterpriseOwnerService {
    static let shared = DeleteEnterpriseOwnerService()
    private init() {}

    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc/deleteEnterpriseOwner"

    func deleteOwner(
        userUuid:     String,
        ownerUuid:    String,
        enterpriseId: String,
        completion:   @escaping (Swift.Result<DeleteEnterpriseOwnerResponse, Swift.Error>) -> Void
    ) {
        guard let token = AuthTokenManager.shared.bearerToken, !token.isEmpty else {
            completion(.failure(AddOwnerServiceError.missingAuthToken))
            return
        }
        guard let url = URL(string: baseURL) else {
            completion(.failure(AddOwnerServiceError.invalidURL))
            return
        }

        let payload = DeleteEnterpriseOwnerPayload(ownerUuid: ownerUuid, enterpriseId: enterpriseId, action: "DELETE")
        guard let ownerJSON = try? JSONEncoder().encode(payload),
              let ownerString = String(data: ownerJSON, encoding: .utf8) else {
            completion(.failure(AddOwnerServiceError.encodingFailed))
            return
        }

        print("🚀 [DeleteEnterpriseOwnerService] request payload ownerString: \(ownerString)")
        print("🚀 [DeleteEnterpriseOwnerService] request userUuid: \(userUuid)")

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/",
            "UUID": userUuid
        ]

        Alamofire.upload(multipartFormData: { form in
            if let d = userUuid.data(using: .utf8) { form.append(d, withName: "userUuid") }
            if let d = ownerString.data(using: .utf8) { form.append(d, withName: "owner") }
        }, to: baseURL, method: .post, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    guard let data = response.data else {
                        DispatchQueue.main.async { completion(.failure(AddOwnerServiceError.emptyResponse)) }
                        return
                    }
                    do {
                        let decoded = try JSONDecoder().decode(DeleteEnterpriseOwnerResponse.self, from: data)
                        if let apiErr = decoded.error, !apiErr.isSuccess {
                            let msg = apiErr.errorMsg?.stringValue ?? "Unknown API error"
                            DispatchQueue.main.async { completion(.failure(AddOwnerServiceError.apiError(message: msg))) }
                            return
                        }
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
