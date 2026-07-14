//
//  Paymentlinksservice.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/05/26.
//

////  ViewPaymentLinksService.swift
////  Trading_Terminal
////

//  ViewPaymentLinksService.swift
//  Trading_Terminal

import Foundation
import Alamofire

// MARK: - API Constants

private enum PaymentLinksAPI {
    static let base     = "https://service.hashcashconsultants.com/billbitcoins-v2"
    static let pageSize = 10

    // ✅ Dynamic — reads from UserDefaults, falls back to "21758"
    static var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
    }
}

// MARK: - ViewPaymentLinksService  (Alamofire 4.x)

final class ViewPaymentLinksService {

    static let shared = ViewPaymentLinksService()
    private init() {}

    private var authHeaders: [String: String] {
        var h: [String: String] = [
            "Content-Type":     "application/json",
            "Accept":           "*/*",
            "Origin":           "https://trade.paybito.com",
            "Referer":          "https://trade.paybito.com/",
            "X-Requested-With": "XMLHttpRequest"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            h["Authorization"] = "Bearer \(token)"
            print("🔑 Token:", token)
        } else {
            print("❌ Token missing")
        }

        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            h["Uuid"] = uuid
            print("🆔 UUID:", uuid)
        } else {
            print("❌ UUID missing")
        }

        return h
    }

    // MARK: - Fetch Payment Links

    func fetchPayments(
        merchantId: Int = Int(PaymentLinksAPI.merchantId) ?? 0,  // ✅ dynamic default
        offset:     Int = 1,
        limit:      Int = PaymentLinksAPI.pageSize,
        completion: @escaping (Swift.Result<PaymentLinksResponse, Error>) -> Void
    ) {
        let url = "\(PaymentLinksAPI.base)/payment/payment-details"

        let params: [String: Any] = [
            "merchantId": merchantId,
            "offset":     offset,
            "limit":      limit
        ]

        debugPrint("────────────────────────────────────────")
        debugPrint("📡 [ViewPaymentLinksService] fetchPayments")
        debugPrint("   URL    : \(url)")
        debugPrint("   Params : \(params)")
        debugPrint("   Headers: \(authHeaders)")
        debugPrint("────────────────────────────────────────")

        Alamofire
            .request(
                url,
                method:     .get,
                parameters: params,
                encoding:   URLEncoding.queryString,
                headers:    authHeaders
            )
            .validate(statusCode: 200..<300)
            .responseData { response in

                debugPrint("📥 [ViewPaymentLinksService] HTTP \(response.response?.statusCode ?? -1)")

                if let data = response.data,
                   let raw = String(data: data, encoding: .utf8) {
                    debugPrint("   raw (500): \(raw.prefix(500))")
                }

                switch response.result {

                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(PaymentLinksResponse.self, from: data)
                        debugPrint("✅ [ViewPaymentLinksService] totalCount: \(decoded.totalCount)")
                        decoded.payments.enumerated().forEach { i, p in
                            debugPrint("   [\(i)] \(p.id) | \(p.paymentName) | \(p.formattedDate)")
                        }
                        DispatchQueue.main.async { completion(.success(decoded)) }
                    } catch {
                        debugPrint("❌ [ViewPaymentLinksService] decode error: \(error)")
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }

                case .failure(let error):
                    debugPrint("❌ [ViewPaymentLinksService] network: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(.failure(error)) }
                }
            }
    }
}
