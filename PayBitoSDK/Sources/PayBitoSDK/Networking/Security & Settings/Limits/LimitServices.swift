//
//  LimitsAPIService.swift
//  Trading_Terminal
//
//  Alamofire 4.x compatible
//

import Foundation
import Alamofire

// MARK: - Limits API Service
final class LimitsAPIService {

    static let shared = LimitsAPIService()
    private init() {}

    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/merchant"

    // MARK: - Fetch Merchant Settings
    func fetchMerchantSettings(completion: @escaping (Result<MerchantSettingsResponse>) -> Void) {
        let url = "\(baseURL)/FetchMerchantsettings"
        let merchantId = extractMerchantId()
        let parameters: [String: Any] = ["merchant_id": merchantId]

        print("🌐 [LimitsAPI] FetchMerchantsettings — merchantId: \(merchantId)")

        Alamofire.request(url, method: .post, parameters: parameters,
                          encoding: JSONEncoding.default, headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [LimitsAPI] FetchMerchantsettings status: \(response.response?.statusCode ?? -1)")
                if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                    print("📥 [LimitsAPI] FetchMerchantsettings response: \(raw)")
                }
                switch response.result {
                case .success(let data):
                    do {
                        if let errs = try? JSONDecoder().decode([ServerErrorResponse].self, from: data),
                           let first = errs.first, first.error == "1" {
                            completion(.failure(LimitsAPIError.serverError(first.errorMsg)))
                            return
                        }
                        let list = try JSONDecoder().decode([MerchantSettingsResponse].self, from: data)
                        if let first = list.first {
                            completion(.success(first))
                        } else {
                            completion(.failure(LimitsAPIError.emptyResponse))
                        }
                    } catch {
                        print("❌ [LimitsAPI] Decode error: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    if let data = response.data,
                       let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
                       !serverError.errorMsg.isEmpty {
                        completion(.failure(LimitsAPIError.serverError(serverError.errorMsg)))
                    } else {
                        completion(.failure(error))
                    }
                }
            }
    }

    // MARK: - Fetch Activated Volume
    func fetchActivatedVolume(completion: @escaping (Result<ActivatedVolume>) -> Void) {
        let url = "\(baseURL)/FetchActivatedVolume"
        let merchantId = extractMerchantId()
        let parameters: [String: Any] = ["merchant_id": merchantId]

        print("🌐 [LimitsAPI] FetchActivatedVolume — merchantId: \(merchantId)")

        Alamofire.request(url, method: .post, parameters: parameters,
                          encoding: JSONEncoding.default, headers: authHeaders())
            .validate(statusCode: 200..<300)
            .responseData { response in
                print("📡 [LimitsAPI] FetchActivatedVolume status: \(response.response?.statusCode ?? -1)")
                if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                    print("📥 [LimitsAPI] FetchActivatedVolume response: \(raw)")
                }
                switch response.result {
                case .success(let data):

                    do {

                        // Decode loosely

                        if let jsonArray =

                            try JSONSerialization.jsonObject(with: data)

                            as? [[String: Any]] {

                            // Find first valid object

                            if let validObject = jsonArray.first(where: {

                                ($0["volume_id"] as? Int ?? 0) > 0

                            }) {

                                let cleanData =

                                try JSONSerialization.data(withJSONObject: validObject)

                                let activated =

                                try JSONDecoder().decode(

                                    ActivatedVolume.self,

                                    from: cleanData

                                )

                                completion(.success(activated))

                                return

                            }

                        }

                        completion(.failure(LimitsAPIError.emptyResponse))

                    } catch {

                        print("❌ Decode error:", error)

                        completion(.failure(error))

                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Submit Volume Request
    func submitVolumeRequest(
        volumeId: Int,
        taxId: String,
        website: String?,
        file1: Data?,
        file1Name: String,
        file2: Data? = nil,
        file2Name: String? = nil,
        file3: Data? = nil,
        file3Name: String? = nil,
        file4: Data? = nil,
        file4Name: String? = nil,
        completion: @escaping (Result<SubmitVolumeResponse>) -> Void
    ) {
        let url = "\(baseURL)/submitVolumeRequest"
        let merchantId = extractMerchantId()

        print("========== SUBMIT VOLUME DEBUG ==========")
        print("URL: \(url)")
        print("merchantId: \(merchantId)")
        print("volumeId: \(volumeId)")
        print("taxId: \(taxId)")
        print("website: \(website ?? "nil")")
        print("file1: \(file1 != nil ? "\(file1!.count) bytes, name=\(file1Name)" : "nil")")
        print("file2: \(file2 != nil ? "\(file2!.count) bytes, name=\(file2Name ?? "nil")" : "nil")")
        print("file3: \(file3 != nil ? "\(file3!.count) bytes, name=\(file3Name ?? "nil")" : "nil")")
        print("file4: \(file4 != nil ? "\(file4!.count) bytes, name=\(file4Name ?? "nil")" : "nil")")
        print("=========================================")

        let headers: HTTPHeaders = [
            "Authorization": "bearer \(UserDefaults.standard.string(forKey: "Baccess_token") ?? "")",
            "UUID":          UserDefaults.standard.string(forKey: "Buuid") ?? "",
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/"
        ]

        print("Headers being sent: \(headers)")

        Alamofire.upload(
            multipartFormData: { form in

                // ── Always required ──────────────────────────────────
                form.append(Data("\(merchantId)".utf8), withName: "merchant_id")
                form.append(Data("\(volumeId)".utf8),   withName: "volume_id")
                form.append(Data(taxId.utf8),            withName: "tax_id")

                // website — always send (empty string for Basic)
                form.append(Data((website ?? "").utf8), withName: "website")

                // ── file_1 — EIN doc (both plans) ────────────────────
                if let data = file1 {
                    form.append(data, withName: "file_1",
                                fileName: file1Name,
                                mimeType: self.mimeType(for: file1Name))
                } else {
                    // send null as empty string so field is always present
                    form.append(Data("null".utf8), withName: "file_1")
                }
                form.append(Data("1".utf8), withName: "file_type_1")

                // ── file_2 — Owner Photo (business) / null (basic) ───
                if let data = file2, let name = file2Name, !name.isEmpty {
                    form.append(data, withName: "file_2",
                                fileName: name,
                                mimeType: self.mimeType(for: name))
                } else {
                    form.append(Data("null".utf8), withName: "file_2")
                }
                form.append(Data("3".utf8), withName: "file_type_2")

                // ── file_3 — Biz Registration (business) / null ──────
                if let data = file3, let name = file3Name, !name.isEmpty {
                    form.append(data, withName: "file_3",
                                fileName: name,
                                mimeType: self.mimeType(for: name))
                } else {
                    form.append(Data("null".utf8), withName: "file_3")
                }
                form.append(Data("4".utf8), withName: "file_type_3")

                // ── file_4 — Proof of Address (business) / null ──────
                if let data = file4, let name = file4Name, !name.isEmpty {
                    form.append(data, withName: "file_4",
                                fileName: name,
                                mimeType: self.mimeType(for: name))
                } else {
                    form.append(Data("null".utf8), withName: "file_4")
                }
                form.append(Data("5".utf8), withName: "file_type_4")
            },
            to: url,
            method: .post,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .failure(let error):
                    print("❌ Encoding error: \(error)")
                    completion(.failure(error))

                case .success(let request, _, _):
                    // Print the actual request headers Alamofire built
                    print("📤 Actual request headers: \(request.request?.allHTTPHeaderFields ?? [:])")
                    print("📤 Content-Type: \(request.request?.value(forHTTPHeaderField: "Content-Type") ?? "NOT SET")")

                    request
                        .validate(statusCode: 200..<300)
                        .responseData { response in
                            print("📡 Status: \(response.response?.statusCode ?? -1)")
                            print("📥 Response headers: \(response.response?.allHeaderFields ?? [:])")
                            if let data = response.data, let raw = String(data: data, encoding: .utf8) {
                                print("📥 Body: \(raw)")
                            }
                            switch response.result {
                            case .success(let data):
                                do {
                                    if let errs = try? JSONDecoder().decode([ServerErrorResponse].self, from: data),
                                       let first = errs.first, first.error == "1" {
                                        completion(.failure(LimitsAPIError.serverError(first.errorMsg)))
                                        return
                                    }
                                    if let list = try? JSONDecoder().decode([SubmitVolumeResponse].self, from: data),
                                       let first = list.first {
                                        completion(.success(first))
                                        return
                                    }
                                    let single = try JSONDecoder().decode(SubmitVolumeResponse.self, from: data)
                                    completion(.success(single))
                                } catch {
                                    completion(.failure(error))
                                }
                            case .failure(let error):
                                if let data = response.data,
                                   let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data),
                                   !serverError.errorMsg.isEmpty {
                                    completion(.failure(LimitsAPIError.serverError(serverError.errorMsg)))
                                } else {
                                    completion(.failure(error))
                                }
                            }
                        }
                }
            }
        )
    }
    private func multipartHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        return [
            "Authorization": "bearer \(token)",
            "UUID":          uuid,
            // ← NO Content-Type here — Alamofire sets it automatically with the boundary
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/",
            "User-Agent":    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        ]
    }

    // MARK: - Extract merchantId
    private func extractMerchantId() -> Int {
        if let mid = UserDefaults.standard.value(forKey: "merchantId") as? Int { return mid }
        if let mid = UserDefaults.standard.value(forKey: "BMerchantId") as? Int { return mid }
        if let mid = Int(UserDefaults.standard.string(forKey: "merchantId") ?? "") { return mid }
        if let mid = Int(UserDefaults.standard.string(forKey: "BMerchantId") ?? "") { return mid }

        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")
        if parts.count >= 2,
           let data = Data(base64Encoded: parts[1].paddedBase64),
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let sub  = json["sub"] as? String,
           let idStr = sub.components(separatedBy: "-").first,
           let id = Int(idStr) {
            return id
        }
        print("⚠️ [LimitsAPI] Could not extract merchantId, using 0")
        return 0
    }

    // MARK: - Auth Headers
    private func authHeaders() -> HTTPHeaders {
        let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
        let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        return [
            "Authorization": "bearer \(token)",
            "UUID":          uuid,
            "Content-Type":  "application/json",
            "Accept":        "application/json, text/plain, */*",
            "Origin":        "https://trade.paybito.com",
            "Referer":       "https://trade.paybito.com/",
            "User-Agent":    "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148"
        ]
    }

    // MARK: - MIME helper
    private func mimeType(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf":         return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png":         return "image/png"
        default:            return "application/octet-stream"
        }
    }
}

// MARK: - Custom Errors
enum LimitsAPIError: Error, LocalizedError {
    case emptyResponse
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .emptyResponse:         return "No data received from the server."
        case .serverError(let msg):  return msg.isEmpty ? "An unknown server error occurred." : msg
        }
    }
}

// MARK: - Server Error Response
private struct ServerErrorResponse: Decodable {
    let error: String
    let errorMsg: String
    enum CodingKeys: String, CodingKey {
        case error    = "error"
        case errorMsg = "error_msg"
    }
}

// MARK: - Base64 padding
private extension String {
    var paddedBase64: String {
        var s = self
        let r = s.count % 4
        if r != 0 { s += String(repeating: "=", count: 4 - r) }
        return s
    }
}
