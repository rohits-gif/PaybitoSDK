import Foundation
import Alamofire

// MARK: - AddProductService
// ✅ Alamofire 4.x — auth headers read from UserDefaults,
//    same keys (Baccess_token, Buuid) as rest of the project.

final class AddProductService {

    // ── Singleton ──────────────────────────────────────────────────────────
    static let shared = AddProductService()
    private init() {}

    // ── Endpoints ──────────────────────────────────────────────────────────
    private let registerEndpoint = "https://service.hashcashconsultants.com/billbitcoins-v2/shopping/products/register"
    private let imageEndpoint    = "https://service.hashcashconsultants.com/billbitcoins-v2/shopping/products/image"

    // ── Auth Headers ───────────────────────────────────────────────────────
    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type":     "application/json",
            "Accept":           "application/json",
            "Origin":           "https://trade.paybito.com",
            "Referer":          "https://trade.paybito.com/",
            "X-Requested-With": "XMLHttpRequest"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
            debugPrint("🔑 [AddProductService] Token attached")
        } else {
            debugPrint("❌ [AddProductService] Token missing")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
            debugPrint("🆔 [AddProductService] UUID attached")
        } else {
            debugPrint("❌ [AddProductService] UUID missing")
        }
        return h
    }

    // ── Multipart headers (no Content-Type — Alamofire sets it) ───────────
    private var multipartHeaders: [String: String] {
        var h = authHeaders
        h.removeValue(forKey: "Content-Type")
        return h
    }

    // ============================================================
    // MARK: - 1. Upload Product Image
    // POST /shopping/products/image  (multipart/form-data)
    // Fields: merchantId, productId, image (binary JPEG)
    // Returns: { "status": true, "message": "Image uploaded",
    //            "data": "https://s3.amazonaws.com/..." }
    // ============================================================

    func uploadImage(
        productId:  String,
        imageData:  Data,
        completion: @escaping (Swift.Result<String, Error>) -> Void
    ) {
        let merchantId = UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"

        debugPrint("────────────────────────────────────────")
        debugPrint("🖼️  [AddProductService] uploadImage")
        debugPrint("   URL        : \(imageEndpoint)")
        debugPrint("   productId  : \(productId)")
        debugPrint("   merchantId : \(merchantId)")
        debugPrint("   imageSize  : \(imageData.count) bytes")
        debugPrint("────────────────────────────────────────")

        Alamofire.upload(
            multipartFormData: { form in
                // ── Text fields ────────────────────────────────────────────
                if let mid = merchantId.data(using: .utf8) {
                    form.append(mid, withName: "merchantId")
                }
                if let pid = productId.data(using: .utf8) {
                    form.append(pid, withName: "productId")
                }
                // ── Image binary ───────────────────────────────────────────
                form.append(
                    imageData,
                    withName: "image",
                    fileName: "\(productId).jpg",
                    mimeType: "image/jpeg"
                )
            },
            to:      imageEndpoint,
            headers: multipartHeaders,
            encodingCompletion: { result in
                switch result {
                case .failure(let error):
                    debugPrint("❌ [AddProductService] Multipart encoding failed: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }

                case .success(let request, _, _):
                    request
                        .validate(statusCode: 200..<300)
                        .responseData { response in
                            debugPrint("📥 [AddProductService] uploadImage HTTP \(response.response?.statusCode ?? -1)")
                            if let data = response.data,
                               let raw = String(data: data, encoding: .utf8) {
                                debugPrint("   raw: \(raw.prefix(300))")
                            }

                            switch response.result {
                            case .success(let data):
                                do {
                                    let decoded = try JSONDecoder().decode(
                                        ImageUploadResponse.self, from: data
                                    )
                                    if decoded.status, let s3URL = decoded.data, !s3URL.isEmpty {
                                        debugPrint("✅ [AddProductService] Image uploaded → \(s3URL)")
                                        DispatchQueue.main.async { completion(.success(s3URL)) }
                                    } else {
                                        let err = NSError(
                                            domain: "AddProductService",
                                            code:   -2,
                                            userInfo: [NSLocalizedDescriptionKey: decoded.message]
                                        )
                                        debugPrint("⚠️  [AddProductService] Image upload status=false: \(decoded.message)")
                                        DispatchQueue.main.async { completion(.failure(err)) }
                                    }
                                } catch {
                                    debugPrint("❌ [AddProductService] Image decode error: \(error)")
                                    DispatchQueue.main.async { completion(.failure(error)) }
                                }

                            case .failure(let error):
                                debugPrint("❌ [AddProductService] Image upload network error: \(error.localizedDescription)")
                                DispatchQueue.main.async { completion(.failure(error)) }
                            }
                        }
                }
            }
        )
    }

    // ============================================================
    // MARK: - 2. Register Product
    // POST /shopping/products/register  (application/json)
    // ============================================================

    func registerProduct(
        request:    AddProductRequest,
        completion: @escaping (Swift.Result<AddProductResponse, Error>) -> Void
    ) {
        guard
            let jsonData   = try? JSONEncoder().encode(request),
            let parameters = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
        else {
            let err = NSError(
                domain: "AddProductService",
                code:   -1,
                userInfo: [NSLocalizedDescriptionKey: "Failed to encode request payload"]
            )
            debugPrint("❌ [AddProductService] Encoding failed")
            completion(.failure(err))
            return
        }

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [AddProductService] registerProduct")
        debugPrint("   URL     : \(registerEndpoint)")
        if let pretty = try? JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted),
           let str = String(data: pretty, encoding: .utf8) {
            debugPrint("   Payload : \(str)")
        }
        debugPrint("────────────────────────────────────────")

        Alamofire.request(
            registerEndpoint,
            method:     .post,
            parameters: parameters,
            encoding:   JSONEncoding.default,
            headers:    authHeaders
        )
        .validate(statusCode: 200..<300)
        .responseData { response in
            debugPrint("📥 [AddProductService] registerProduct HTTP \(response.response?.statusCode ?? -1)")
            if let data = response.data,
               let raw = String(data: data, encoding: .utf8) {
                debugPrint("   raw: \(raw.prefix(500))")
            }

            switch response.result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(AddProductResponse.self, from: data)
                    debugPrint("✅ [AddProductService] status=\(decoded.status) message=\(decoded.message)")

                    if let d = decoded.data {
                        debugPrint("   registered=\(d.registered)")
                        d.products.forEach { p in
                            debugPrint("   product → id=\(p.productId ?? "null") status=\(p.status)")
                            p.priceStatuses?.forEach { ps in
                                debugPrint("     price → id=\(ps.priceId) status=\(ps.status)")
                            }
                        }
                        // Server returns HTTP 200 even on DB errors
                        if d.registered == 0,
                           let firstStatus = d.products.first?.status,
                           firstStatus.lowercased().hasPrefix("error") {
                            let serverError = NSError(
                                domain: "AddProductService",
                                code:   -3,
                                userInfo: [NSLocalizedDescriptionKey: firstStatus]
                            )
                            debugPrint("❌ [AddProductService] Server DB error: \(firstStatus)")
                            DispatchQueue.main.async { completion(.failure(serverError)) }
                            return
                        }
                    }
                    DispatchQueue.main.async { completion(.success(decoded)) }
                } catch {
                    debugPrint("❌ [AddProductService] Decode error: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }

            case .failure(let error):
                debugPrint("❌ [AddProductService] Network error: \(error.localizedDescription)")
                if let data = response.data,
                   let body = String(data: data, encoding: .utf8) {
                    debugPrint("   error body: \(body)")
                }
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }
}
