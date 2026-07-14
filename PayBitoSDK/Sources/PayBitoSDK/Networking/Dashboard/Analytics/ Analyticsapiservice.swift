// AnalyticsAPIService.swift

import Foundation
import Alamofire

// MARK: - Constants

private enum API {
    static let base = "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard"

    static let keyMetrics            = "\(base)/getMerchantKeyMetrics"
    static let revenueOverTime       = "\(base)/getMerchantRevenueOverTime"
    static let transactionHealth     = "\(base)/getMerchantTransactionHealth"
    static let paymentSourcePerf     = "\(base)/getMerchantPaymentSourcePerformance"
    static let topProducts           = "\(base)/getMerchantTopProducts"
    static let txnSizeDistribution   = "\(base)/getMerchantTxnSizeDistribution"
    static let geographicDist        = "\(base)/getMerchantGeographicDistribution"
    static let failureTxnSummary     = "\(base)/getMerchantFailureTxnSummary"
    static let settlementOverview    = "\(base)/getMerchantSettlementOverview"
    static let reports               = "\(base)/getMerchantReports"
}

// MARK: - Headers

private func authHeaders() -> HTTPHeaders {
    let token = UserDefaults.standard.string(forKey: "Baccess_token") ?? ""
    let uuid  = UserDefaults.standard.string(forKey: "Buuid") ?? ""
    print("🔐 TOKEN:", token)
    print("🆔 UUID:", uuid)
    return [
        "Content-Type":  "application/json",
        "Authorization": "Bearer \(token)",
        "UUID":          uuid,
        "Origin": "https://trade.paybito.com",

        "Referer": "https://trade.paybito.com/"
    ]
    
}

// MARK: - Generic POST (SAFE)

private func post<T: Decodable>(
    url: String,
    payload: Encodable,
    completion: @escaping (Swift.Result<T, Error>) -> Void
) {
    guard let params = payload.asDictionary() else {
        print("🔴 Encoding FAILED")
        completion(.failure(NSError(domain: "Encoding", code: -1)))
        return
    }

    print("\n🟢 ===============================")
    print("🟢 API CALL:", url)
    print("🟢 PARAMS:", params)
    print("🟢 HEADERS:", authHeaders())

    Alamofire.request(
        url,
        method: .post,
        parameters: params,
        encoding: JSONEncoding.default,
        headers: authHeaders()
    )
    .validate()
    .responseJSON { response in

        print("🟡 STATUS CODE:", response.response?.statusCode ?? 0)

        if let data = response.data,
           let raw = String(data: data, encoding: .utf8) {
            print("🟡 RAW RESPONSE:\n", raw)
        }

        switch response.result {

        case .success(let value):
            do {
                let data = try JSONSerialization.data(withJSONObject: value)

                // TRY ARRAY
                if let arr = try? JSONDecoder().decode([T].self, from: data),
                   let first = arr.first {
                    print("🟢 DECODE SUCCESS (ARRAY)")
                    completion(.success(first))
                    return
                }

                // TRY OBJECT
                let obj = try JSONDecoder().decode(T.self, from: data)
                print("🟢 DECODE SUCCESS (OBJECT)")
                completion(.success(obj))

            } catch {
                print("🔴 DECODING ERROR:", error)
                completion(.failure(error))
            }

        case .failure(let error):
            print("🔴 REQUEST FAILED:", error)
            completion(.failure(error))
        }

        print("🟢 ===============================\n")
    }
}

// MARK: - Service

final class AnalyticsAPIService {

    static let shared = AnalyticsAPIService()
    private init() {}

    func fetchKeyMetrics(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<KeyMetricsResponse, Error>) -> Void
    ) {
        var p = payload
        p = AnalyticsPayload(
            merchantId: payload.merchantId,
            currency: payload.currency,
            startDate: payload.startDate,
            endDate: payload.endDate,
            timeDuration: "MONTHLY"
        )
        post(url: API.keyMetrics, payload: p, completion: completion)
    }

    func fetchRevenueOverTime(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<RevenueOverTimeResponse, Error>) -> Void
    ) {
        post(url: API.revenueOverTime, payload: payload, completion: completion)
    }

    func fetchTransactionHealth(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<TransactionHealthResponse, Error>) -> Void
    ) {
        post(url: API.transactionHealth, payload: payload, completion: completion)
    }

    func fetchPaymentSourcePerformance(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<PaymentSourcePerformanceResponse, Error>) -> Void
    ) {
        post(url: API.paymentSourcePerf, payload: payload, completion: completion)
    }

    func fetchTopProducts(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<TopProductsResponse, Error>) -> Void
    ) {
        post(url: API.topProducts, payload: payload, completion: completion)
    }

    func fetchTxnSizeDistribution(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<TxnSizeDistributionResponse, Error>) -> Void
    ) {
        post(url: API.txnSizeDistribution, payload: payload, completion: completion)
    }

    func fetchGeographicDistribution(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<GeographicDistributionResponse, Error>) -> Void
    ) {
        post(url: API.geographicDist, payload: payload, completion: completion)
    }

    func fetchFailureTxnSummary(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<FailureTxnSummaryResponse, Error>) -> Void
    ) {
        post(url: API.failureTxnSummary, payload: payload, completion: completion)
    }

    func fetchSettlementOverview(
        payload: AnalyticsPayload,
        completion: @escaping (Swift.Result<SettlementOverviewResponse, Error>) -> Void
    ) {
        post(url: API.settlementOverview, payload: payload, completion: completion)
    }

    func fetchReport(
        payload: ReportPayload,
        completion: @escaping (Swift.Result<ReportResponse, Error>) -> Void
    ) {
        post(url: API.reports, payload: payload, completion: completion)
    }
}

// MARK: - Helper

 extension Encodable {
    func asDictionary() -> [String: Any]? {
        guard
            let data = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return nil }
        return dict
    }
}
