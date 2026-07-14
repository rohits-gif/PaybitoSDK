//
//  Cryptoaddressmodel.swift

//

// CryptoAddressModels.swift
// Mirrors the exact API contract used in the React web implementation.

import Foundation

// MARK: - Asset (from FetchUsdBtcLedgerAmount → coin_balance)

struct CryptoAsset: Identifiable {
    let id: String          // currency_id as String
    let assetName: String   // currency_name
    let assetCode: String   // currency_code
    let assetId: String     // currency_id
    let assetImage: String  // logo URL
    let network: [String]   // network array
    let coinBalance: String
    let isBrokerCurrency: Int
}

// MARK: - Ledger API Response

struct LedgerResponse: Decodable {
    let error: String?
    let error_msg: String?
    let coin_balance: [CryptoCoinBalance]?
    let rolling_reserve_balance: [CryptoCoinBalance]?
}

struct CryptoCoinBalance: Decodable {

    let currency_name: String
    let currency_code: String
    let currency_id: String
    let logo: String
    let network: NetworkField?
    let balance: String
    let is_broker_currency: Int?
    let currency_type: String?

    enum CodingKeys: String, CodingKey {
        case currency_name
        case currency_code
        case currency_id
        case logo
        case network
        case balance
        case is_broker_currency
        case currency_type
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        currency_name = try container.decode(String.self, forKey: .currency_name)
        currency_code = try container.decode(String.self, forKey: .currency_code)
        logo = try container.decode(String.self, forKey: .logo)
        network = try container.decodeIfPresent(NetworkField.self, forKey: .network)
        balance = try container.decode(String.self, forKey: .balance)
        is_broker_currency = try container.decodeIfPresent(Int.self, forKey: .is_broker_currency)
        currency_type = try container.decodeIfPresent(String.self, forKey: .currency_type)

        if let str = try? container.decode(String.self, forKey: .currency_id) {
            currency_id = str
        } else if let int = try? container.decode(Int.self, forKey: .currency_id) {
            currency_id = String(int)
        } else {
            currency_id = ""
        }
    }
}

/// The `network` field sometimes arrives as a plain string ("NATIVE"),
/// sometimes as an array (["ERC","TRC"]). This custom type handles both.
enum NetworkField: Decodable {
    case single(String)
    case multiple([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let arr = try? container.decode([String].self) {
            self = .multiple(arr)
        } else if let str = try? container.decode(String.self) {
            self = .single(str)
        } else {
            self = .single("")
        }
    }

    var values: [String] {
        switch self {
        case .single(let s): return s.isEmpty ? [] : [s]
        case .multiple(let a): return a
        }
    }
}

// MARK: - Get Crypto Address Response

struct GetCryptoAddressResponse: Decodable {
    let bitcoin_address: String?
    let address_name: String?
    let memo: String?
    let network_type: String?          // "ERC", "TRC", "NATIVE" or nil
    let isEnabledAutoWithdraw: Int?
    let error: String?
    let error_msg: String?
}

// MARK: - Existing address data bundled for the modal

struct ExistingAddressData {
    var nativeAddress: String = ""
    var ercAddress: String = ""
    var trcAddress: String = ""
    var addressName: String = ""
    var memo: String = ""
    var autoWithdrawNetwork: String = "ERC"   // which network is selected for auto-withdraw
    var isEnabledAutoWithdraw: Int = 1

    // Track which addresses were already set (cannot be removed once set)
    var hadInitialNativeAddress: Bool = false
    var hadInitialERCAddress: Bool = false
    var hadInitialTRCAddress: Bool = false
}

// MARK: - Add/Save Crypto Address payload item

struct AddCryptoAddressPayload: Encodable {
    let crypto_address: String
    let address_name: String
    let currency_id: Int
    let merchant_id: String
    let networkType: String
    let isEnabledAutoWithdraw: Int
    let memo: String
}

// MARK: - Generic API result

struct GenericApiResult: Decodable {
    let error: String
    let error_msg: String?
}

// MARK: - Validate Address Response

struct ValidateAddressResponse: Decodable {
    let error: String
    let error_msg: String?

    init(error: String, error_msg: String?) {
        self.error = error
        self.error_msg = error_msg
    }
}
// MARK: - Address Validation State (per field)

enum AddressValidationState: Equatable {
    case idle
    case validating
    case valid
    case invalid
}
