//
//  PaymentToleranceModel.swift
//

import Foundation

// MARK: - Namespaced under PTolerance to avoid redeclaration conflicts
enum PTolerance {

    // MARK: - Coin Balance Model
    struct CoinBalance: Codable {
        let currency_id: Int
        let currency_name: String
        let currency_code: String
        let currency_type: Int
        let balance: String
        let logo: String?
        let network: [String]?
        let is_broker_currency: Int?

        enum CodingKeys: String, CodingKey {
            case currency_id
            case currency_name
            case currency_code
            case currency_type
            case balance
            case logo
            case network
            case is_broker_currency
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            currency_name = try container.decode(String.self, forKey: .currency_name)
            currency_code = try container.decode(String.self, forKey: .currency_code)
            balance = try container.decode(String.self, forKey: .balance)
            logo = try container.decodeIfPresent(String.self, forKey: .logo)
            network = try container.decodeIfPresent([String].self, forKey: .network)
            is_broker_currency = try container.decodeIfPresent(Int.self, forKey: .is_broker_currency)

            // currency_id may be Int OR String
            if let intValue = try? container.decode(Int.self, forKey: .currency_id) {
                currency_id = intValue
            } else if let stringValue = try? container.decode(String.self, forKey: .currency_id),
                      let intValue = Int(stringValue) {
                currency_id = intValue
            } else {
                currency_id = 0
            }

            // currency_type may be Int OR String
            if let intType = try? container.decode(Int.self, forKey: .currency_type) {
                currency_type = intType
            } else if let stringType = try? container.decode(String.self, forKey: .currency_type),
                      let intType = Int(stringType) {
                currency_type = intType
            } else {
                currency_type = 0
            }
        }
    }

    // MARK: - Ledger API Response
    struct LedgerResponse: Codable {
        let error: String
        let error_msg: String?
        let coin_balance: [CoinBalance]?
        let rolling_reserve_balance: [CoinBalance]?
    }

    // MARK: - UI Asset Model
    struct AssetItem {
        let assetId: Int
        let assetName: String
        let assetCode: String
        let assetImage: String?
        let network: [String]?
    }

    // MARK: - Merchant Settings Response
    struct MerchantSettingsResponse: Codable {
        let error: String
        let error_msg: String?
        let underpayment_tolerance: String?
        let overpayment_tolerance: String?
        let accept_underpayments: String?
        let accept_overpayments: String?

        enum CodingKeys: String, CodingKey {
            case error, error_msg
            case underpayment_tolerance, overpayment_tolerance
            case accept_underpayments, accept_overpayments
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            error     = try c.decode(String.self, forKey: .error)
            error_msg = try c.decodeIfPresent(String.self, forKey: .error_msg)
            accept_underpayments = try c.decodeIfPresent(String.self, forKey: .accept_underpayments)
            accept_overpayments  = try c.decodeIfPresent(String.self, forKey: .accept_overpayments)

            // tolerance fields arrive as Int OR String from the API
            func decodeFlexibleString(_ key: CodingKeys) -> String? {
                if let s = try? c.decodeIfPresent(String.self, forKey: key) { return s }
                if let i = try? c.decodeIfPresent(Int.self,    forKey: key) { return String(i) }
                if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return String(d) }
                return nil
            }
            underpayment_tolerance = decodeFlexibleString(.underpayment_tolerance)
            overpayment_tolerance  = decodeFlexibleString(.overpayment_tolerance)
        }
    }

    // MARK: - Save Settings Response
    struct SetSettingsResponse: Codable {
        let error: String
        let error_msg: String?
    }

    // MARK: - Request Payloads
    struct LedgerPayload: Encodable {
        let merchant_id: String
    }

    struct GetSettingsPayload: Encodable {
        let merchant_id: String
        let currency_id: String
    }

    struct SetSettingsPayload: Encodable {
        let currency_id: String
        let overpayment_tolerance: String
        let underpayment_tolerance: String
        let accept_underpayments: String
        let accept_overpayments: String
    }

    // MARK: - Error Type
    enum PTServiceError: Error {
        case apiError(String)
        case unknown
    }
}
