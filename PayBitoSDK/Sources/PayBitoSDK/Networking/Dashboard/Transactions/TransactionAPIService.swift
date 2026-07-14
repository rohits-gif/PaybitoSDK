//
//  TransactionAPIService.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 27/04/26.
//

import Foundation

// MARK: - Transaction API Service

class TransactionAPIService {
    static let shared = TransactionAPIService()
    
    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2"
    private let siteNameAlias = "BILLBITCOINS" // Adjust as needed
    
    private init() {}
    
    // MARK: - Helper Methods
    
    private func getAuthHeaders() -> [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",   // ✅ ADD THIS
            "Origin": "https://trade.paybito.com",
            "Referer": "https://trade.paybito.com/"
        ]

        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
               headers["Authorization"] = "bearer \(token)"
           }

           if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
               headers["UUID"] = uuid
           }
//        headers["Origin"] = "https://trade.paybito.com"
//        headers["Referer"] = "https://trade.paybito.com/"

        return headers
    }
    
    private func performRequest<T: Decodable>(

        url: URL,

        method: String = "POST",

        body: Data? = nil,

        completion: @escaping (Result<T, Error>) -> Void

    ) {

        var request = URLRequest(url: url)

        request.httpMethod = method

        request.allHTTPHeaderFields = getAuthHeaders()

        request.httpBody = body

        // ✅ ADD THIS

        print("🚀 REQUEST URL:", url)

        print("📤 HEADERS:", request.allHTTPHeaderFields ?? [:])

        if let body = body, let json = String(data: body, encoding: .utf8) {

            print("📦 REQUEST BODY:\n\(json)")

        }

        URLSession.shared.dataTask(with: request) { data, response, error in

            

            if let httpResponse = response as? HTTPURLResponse {

                print("🌐 STATUS CODE:", httpResponse.statusCode)

            }

            if let error = error {

                print("❌ NETWORK ERROR:", error)

                completion(.failure(error))

                return

            }

            guard let data = data else {

                completion(.failure(NSError(domain: "TransactionAPI", code: -1,

                    userInfo: [NSLocalizedDescriptionKey: "No data received"])))

                return

            }

           
            if let raw = String(data: data, encoding: .utf8) {

                print("📦 RAW RESPONSE:\n\(raw)")

            }

            do {

                let decoder = JSONDecoder()

                decoder.keyDecodingStrategy = .convertFromSnakeCase

              

                decoder.dateDecodingStrategy = .custom { decoder in

                    let container = try decoder.singleValueContainer()

                    let dateStr = try container.decode(String.self)

                    let formatter = DateFormatter()

                    formatter.locale = Locale(identifier: "en_US_POSIX")

                    formatter.timeZone = TimeZone(secondsFromGMT: 0)

                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

                    if let date = formatter.date(from: dateStr) {

                        return date

                    }

                    throw DecodingError.dataCorruptedError(

                        in: container,

                        debugDescription: "Invalid date: \(dateStr)"

                    )

                }

                let result = try decoder.decode(T.self, from: data)

                completion(.success(result))

            } catch {

                print("❌ DECODING ERROR:", error)

                completion(.failure(error))

            }

        }.resume()

    }
    
    // MARK: - API Methods
    
    /// Get transactions by filter (matches GetTransactionsByFilter from service.js)
    func getTransactionsByFilter(
        request: TransactionFilterRequest,
        completion: @escaping (Result<TransactionsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/transactions/byFilter") else {
            completion(.failure(NSError(domain: "TransactionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        do {
            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = try encoder.encode(request)
            
            performRequest(url: url, method: "POST", body: body, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Export transactions as CSV (matches ExportTransactionsCSV from service.js)
    func exportTransactionsCSV(
        request: ExportTransactionsRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/transactions/export") else {
            completion(.failure(NSError(domain: "TransactionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        do {
            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = try encoder.encode(request)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = getAuthHeaders()
            request.httpBody = body
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "TransactionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                    return
                }
                
                completion(.success(data))
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Mark transaction as test (matches MarkAsTestTransaction from service.js)
    func markAsTestTransaction(
        request: MarkAsTestRequest,
        completion: @escaping (Result<GenericResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/transactions/markAsTestTxn") else {
            completion(.failure(NSError(domain: "TransactionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        do {
            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
            let body = try encoder.encode(request)
            
            performRequest(url: url, method: "PUT", body: body, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Get all transactions (matches GetAllTransactions from service.js)
    func getAllTransactions(
        merchantId: Int,
        completion: @escaping (Result<TransactionsResponse, Error>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/merchant/GetAllTransactions") else {
            completion(.failure(NSError(domain: "TransactionAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        let payload = ["merchant_id": merchantId]
        
        do {
            let body = try JSONSerialization.data(withJSONObject: payload)
            performRequest(url: url, method: "POST", body: body, completion: completion)
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - Generic Response
//
//struct GenericResponse: Codable {
//    let success: Bool
//    let message: String?
//    let data: [String: AnyCodable]?
//}

// MARK: - AnyCodable Helper

//struct AnyCodable: Codable {
//    let value: Any
//    
//    init(_ value: Any) {
//        self.value = value
//    }
//    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        
//        if let int = try? container.decode(Int.self) {
//            value = int
//        } else if let double = try? container.decode(Double.self) {
//            value = double
//        } else if let string = try? container.decode(String.self) {
//            value = string
//        } else if let bool = try? container.decode(Bool.self) {
//            value = bool
//        } else {
//            value = ""
//        }
//    }
//    
//    func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        
//        if let int = value as? Int {
//            try container.encode(int)
//        } else if let double = value as? Double {
//            try container.encode(double)
//        } else if let string = value as? String {
//            try container.encode(string)
//        } else if let bool = value as? Bool {
//            try container.encode(bool)
//        }
//    }
//}
