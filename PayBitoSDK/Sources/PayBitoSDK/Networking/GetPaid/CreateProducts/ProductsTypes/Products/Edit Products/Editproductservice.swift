import Foundation
import Alamofire

final class EditProductService {

    static let shared = EditProductService()
    private init() {}

    // MARK: - Endpoints
    private let updateEndpoint = "https://service.hashcashconsultants.com/billbitcoins-v2/shopping/products"
    private let imageEndpoint  = "https://service.hashcashconsultants.com/billbitcoins-v2/shopping/products/image"

    // MARK: - Auth Headers
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
            debugPrint("🔑 [EditProductService] Token attached")
        } else {
            debugPrint("❌ [EditProductService] Token missing")
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["UUID"] = uuid
            debugPrint("🆔 [EditProductService] UUID attached")
        } else {
            debugPrint("❌ [EditProductService] UUID missing")
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
    // Must be called AFTER product exists on server
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
        debugPrint("🖼️  [EditProductService] uploadImage")
        debugPrint("   URL        : \(imageEndpoint)")
        debugPrint("   productId  : \(productId)")
        debugPrint("   merchantId : \(merchantId)")
        debugPrint("   imageSize  : \(imageData.count) bytes")
        debugPrint("────────────────────────────────────────")

        Alamofire.upload(
            multipartFormData: { form in
                if let mid = merchantId.data(using: .utf8) {
                    form.append(mid, withName: "merchantId")
                }
                if let pid = productId.data(using: .utf8) {
                    form.append(pid, withName: "productId")
                }
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
                    debugPrint("❌ [EditProductService] Multipart encoding failed: \(error)")
                    DispatchQueue.main.async { completion(.failure(error)) }

                case .success(let request, _, _):
                    request
                        .validate(statusCode: 200..<300)
                        .responseData { response in
                            debugPrint("📥 [EditProductService] uploadImage HTTP \(response.response?.statusCode ?? -1)")
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
                                        debugPrint("✅ [EditProductService] Image uploaded → \(s3URL)")
                                        DispatchQueue.main.async { completion(.success(s3URL)) }
                                    } else {
                                        let err = NSError(
                                            domain: "EditProductService",
                                            code:   -2,
                                            userInfo: [NSLocalizedDescriptionKey: decoded.message]
                                        )
                                        debugPrint("⚠️  [EditProductService] status=false: \(decoded.message)")
                                        DispatchQueue.main.async { completion(.failure(err)) }
                                    }
                                } catch {
                                    debugPrint("❌ [EditProductService] Image decode error: \(error)")
                                    DispatchQueue.main.async { completion(.failure(error)) }
                                }

                            case .failure(let error):
                                debugPrint("❌ [EditProductService] Image upload network error: \(error)")
                                DispatchQueue.main.async { completion(.failure(error)) }
                            }
                        }
                }
            }
        )
    }

    // ============================================================
    // MARK: - 2. PUT Update Product
    // PUT /shopping/products?productId=PROD_xxx
    // ============================================================

    func updateProduct(
        productId:  String,
        request:    EditProductRequest,
        completion: @escaping (Swift.Result<EditProductResponse, Error>) -> Void
    ) {
        let url = "\(updateEndpoint)?productId=\(productId)"

        guard
            let bodyData   = try? JSONEncoder().encode(request),
            let bodyParams = try? JSONSerialization.jsonObject(with: bodyData) as? [String: Any]
        else {
            debugPrint("❌ [EditProductService] JSON encoding failed")
            completion(.failure(EditProductServiceError.encodingFailed))
            return
        }

        debugPrint("────────────────────────────────────────")
        debugPrint("✏️  [EditProductService] updateProduct")
        debugPrint("   URL        : \(url)")
        debugPrint("   productId  : \(productId)")
        debugPrint("   merchantId : \(request.merchantId)")
        debugPrint("   name       : \(request.name)")
        debugPrint("   description: \(request.description)")
        debugPrint("   imageUrl   : \(request.imageUrl)")
        debugPrint("   status     : \(request.status)")
        debugPrint("   prices     : \(request.addPrices.count)")
        debugPrint("   metadata   : \(request.metadata)")
        if let pretty = try? JSONSerialization.data(withJSONObject: bodyParams, options: .prettyPrinted),
           let str = String(data: pretty, encoding: .utf8) {
            debugPrint("📤 Full Body:\n\(str)")
        }
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                url,
                method:     .put,
                parameters: bodyParams,
                encoding:   JSONEncoding.default,
                headers:    authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in
                debugPrint("📥 [EditProductService] updateProduct HTTP \(response.response?.statusCode ?? -1)")
                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }

                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(EditProductResponse.self, from: data)
                        debugPrint(decoded.status
                            ? "✅ [EditProductService] \(decoded.message)"
                            : "⚠️  [EditProductService] status=false — \(decoded.message)")

                        if decoded.status {
                            DispatchQueue.main.async { completion(.success(decoded)) }
                        } else {
                            let err = EditProductServiceError.serverMessage(decoded.message)
                            DispatchQueue.main.async { completion(.failure(err)) }
                        }
                    } catch {
                        debugPrint("❌ [EditProductService] Decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [EditProductService] Network error: \(error.localizedDescription)")
                    if let data = response.data,
                       let decoded = try? JSONDecoder().decode(EditProductResponse.self, from: data) {
                        let err = EditProductServiceError.serverMessage(decoded.message)
                        DispatchQueue.main.async { completion(.failure(err)) }
                    } else {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
            }
    }
}

// MARK: - Errors

enum EditProductServiceError: LocalizedError {
    case encodingFailed
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:        return "Failed to encode request body."
        case .serverMessage(let m):  return m
        }
    }
}
