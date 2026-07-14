//
//  BankDetailsService.swift
//  Trading_Terminal
//

import Foundation
import Alamofire

// MARK: - API Endpoints

private enum BDAPI {
    static let base                 = "https://service.hashcashconsultants.com/billbitcoins-v2/kyc"
    static let fetchBankDetailsURL  = "\(base)/GetUserBankDetails"
    static let updateBankDetailsURL = "\(base)/UpdateUserBankDetails"
}

// MARK: - BankDetailsService

final class AddBankDetailsService {

    static let shared = AddBankDetailsService()
    private init() {}

    // MARK: - Headers

    private func buildRequestHeaders() -> [String: String] {
        var h: [String: String] = [
            "Content-Type": "application/json",
            "Origin":       "https://trade.paybito.com",
            "Referer":      "https://trade.paybito.com/"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "bearer \(token)"
            debugPrint("🔑 [BDService] token attached")
        } else {
            debugPrint("❌ [BDService] token missing")
        }
        if let uid = UserDefaults.standard.string(forKey: "Buuid"), !uid.isEmpty {
            h["Uuid"] = uid
            debugPrint("🆔 [BDService] Uuid: \(uid)")
        } else {
            debugPrint("❌ [BDService] Buuid missing")
        }
        return h
    }

    // MARK: - UUID Resolution

    private func resolveExchangeUUID(_ callerUUID: String) -> String? {
        if !callerUUID.isEmpty { return callerUUID }
        for key in ["Bexchange_uuid", "billbitcoins_exchange_uuid", "Buuid"] {
            if let v = UserDefaults.standard.string(forKey: key), !v.isEmpty {
                debugPrint("🆔 [BDService] UUID from '\(key)': \(v)")
                return v
            }
        }
        debugPrint("❌ [BDService] UUID not resolved")
        return nil
    }

    // MARK: - loadBankDetails

    func loadBankDetails(
        uuid: String,
        completion: @escaping (Swift.Result<BankDetailsResponse, Error>) -> Void
    ) {
        guard let uid = resolveExchangeUUID(uuid) else {
            let err = NSError(domain: "BankDetailsService", code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "Missing UUID"])
            DispatchQueue.main.async { completion(.failure(err)) }
            return
        }

        let body    : [String: Any] = ["uuid": uid]
        let headers                 = buildRequestHeaders()

        debugPrint("════════════════════════════════════════")
        debugPrint("📡 [BDService] loadBankDetails | URL: \(BDAPI.fetchBankDetailsURL)")
        debugPrint("   body: \(body)")
        debugPrint("════════════════════════════════════════")

        Alamofire
            .request(BDAPI.fetchBankDetailsURL,
                     method:     .post,
                     parameters: body,
                     encoding:   JSONEncoding.default,
                     headers:    headers)
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [BDService] loadBankDetails HTTP \(response.response?.statusCode ?? -1)")
                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
                    debugPrint("   raw: \(raw.prefix(500))")
                }
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(BankDetailsResponse.self, from: data)
                        debugPrint("✅ [BDService] loadBankDetails decoded id=\(decoded.bankDetails?.bankDetailsId ?? -1)")
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ [BDService] loadBankDetails decode: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                case .failure(let error):
                    debugPrint("❌ [BDService] loadBankDetails network: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }

    // MARK: - submitBankDetailsUpdate

//    func submitBankDetailsUpdate(
//        uuid: String,
//        params: [String: Any],
//        completion: @escaping (Swift.Result<UpdateBankDetailsResponse, Error>) -> Void
//    ) {
//        guard let uid = resolveExchangeUUID(uuid) else {
//            let err = NSError(domain: "BankDetailsService", code: -1,
//                              userInfo: [NSLocalizedDescriptionKey: "Missing UUID"])
//            DispatchQueue.main.async { completion(.failure(err)) }
//            return
//        }
//
//        var body        = params
//        body["uuid"]    = uid
//        let headers     = buildRequestHeaders()
//
//        debugPrint("════════════════════════════════════════")
//        debugPrint("📡 [BDService] submitBankDetailsUpdate | URL: \(BDAPI.updateBankDetailsURL)")
//        debugPrint("   body: \(body)")
//        debugPrint("════════════════════════════════════════")
//
//        Alamofire
//            .request(BDAPI.updateBankDetailsURL,
//                     method:     .post,
//                     parameters: body,
//                     encoding:   JSONEncoding.default,
//                     headers:    headers)
//            .validate(statusCode: 200..<300)
//            .responseData { response in
//                debugPrint("📥 [BDService] submitBankDetailsUpdate HTTP \(response.response?.statusCode ?? -1)")
//                if let raw = response.data.flatMap({ String(data: $0, encoding: .utf8) }) {
//                    debugPrint("   raw: \(raw.prefix(500))")
//                }
//                switch response.result {
//                case .success(let data):
//                    do {
//                        let decoded = try JSONDecoder().decode(UpdateBankDetailsResponse.self, from: data)
//                        debugPrint("✅ [BDService] submitBankDetailsUpdate decoded")
//                        DispatchQueue.main.async { completion(.success(decoded)) }
//                    } catch {
//                        debugPrint("❌ [BDService] submitBankDetailsUpdate decode: \(error)")
//                        DispatchQueue.main.async { completion(.failure(error)) }
//                    }
//                case .failure(let error):
//                    debugPrint("❌ [BDService] submitBankDetailsUpdate network: \(error)")
//                    DispatchQueue.main.async { completion(.failure(error)) }
//                }
//            }
//    }
    
    
    func submitBankDetailsUpdate(
        uuid: String,
        params: [String: Any],
        documentURL: URL?,
        completion: @escaping (Swift.Result<UpdateBankDetailsResponse, Error>) -> Void
    ) {

        guard let uid = resolveExchangeUUID(uuid) else {

            let err = NSError(
                domain: "BankDetailsService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Missing UUID"]
            )

            DispatchQueue.main.async {
                completion(.failure(err))
            }

            return
        }

        var body = params
        body["uuid"] = uid

        // ✅ Updated v2 endpoint
        let url = "\(BDAPI.base)/UpdateUserBankDetails-v2"

        // ✅ Multipart headers
        var headers: HTTPHeaders = [
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"),
           !token.isEmpty {

            headers["Authorization"] = "bearer \(token)"
        }

        if let uuid = UserDefaults.standard.string(forKey: "Buuid"),
           !uuid.isEmpty {

            headers["UUID"] = uuid
        }

        debugPrint("═══════════════════════════════════════")
        debugPrint("📡 UpdateUserBankDetails-v2")
        debugPrint("URL: \(url)")
        debugPrint("BODY: \(body)")
        debugPrint("FILE: \(documentURL?.lastPathComponent ?? "NONE")")
        debugPrint("═══════════════════════════════════════")

        Alamofire.upload(

            multipartFormData: { multipartFormData in

                // MARK: - Form fields
                for (key, value) in body {

                    let stringValue = "\(value)"

                    multipartFormData.append(
                        stringValue.data(using: .utf8)!,
                        withName: key
                    )
                }

                // MARK: - File Upload
                if let fileURL = documentURL {

                    multipartFormData.append(
                        fileURL,
                        withName: "bankVerificationDocument",
                        fileName: fileURL.lastPathComponent,
                        mimeType: self.mimeType(for: fileURL)
                    )
                }

            },

            to: url,
            method: .post,
            headers: headers,

            encodingCompletion: { encodingResult in

                switch encodingResult {

                case .success(let upload, _, _):

                    upload
                        .validate(statusCode: 200..<300)
                        .responseJSON { response in

                            debugPrint("📥 HTTP \(response.response?.statusCode ?? -1)")

                            if let data = response.data {

                                if let raw = String(data: data, encoding: .utf8) {

                                    debugPrint("RAW RESPONSE:")
                                    debugPrint(raw)
                                }

                                do {

                                    let decoded = try JSONDecoder().decode(
                                        UpdateBankDetailsResponse.self,
                                        from: data
                                    )

                                    DispatchQueue.main.async {
                                        completion(.success(decoded))
                                    }

                                } catch {

                                    debugPrint("❌ Decode Error: \(error)")

                                    DispatchQueue.main.async {
                                        completion(.failure(error))
                                    }
                                }

                            } else {

                                let err = NSError(
                                    domain: "BankDetailsService",
                                    code: -2,
                                    userInfo: [NSLocalizedDescriptionKey: "Empty response"]
                                )

                                DispatchQueue.main.async {
                                    completion(.failure(err))
                                }
                            }
                        }

                case .failure(let error):

                    debugPrint("❌ Upload Encoding Error: \(error)")

                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        )
    }
    private func mimeType(for url: URL) -> String {

        switch url.pathExtension.lowercased() {

        case "pdf":
            return "application/pdf"

        case "jpg", "jpeg":
            return "image/jpeg"

        case "png":
            return "image/png"

        default:
            return "application/octet-stream"
        }
    }
}
