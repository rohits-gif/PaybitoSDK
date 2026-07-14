//////
//////  WalletAsset.swift
//////  Trading_Terminal
//////
//////  Created by Sk Jasimuddin on 30/04/26.
//////
////
//////
//////  WalletModels.swift
//////  Trading_Terminal
//////
//////  Created for BillBitcoins Wallet — matches web API exactly.
//////
//////
////import Foundation
////
////// MARK: - Wallet Assets Response
////
////struct WalletAssetsResponse: Codable {
////
////    let rollingReserveBalance: [WalletAsset]?
////    let coinBalance: [WalletAsset]?
////    let error: String?
////
////    enum CodingKeys: String, CodingKey {
////        case rollingReserveBalance = "rolling_reserve_balance"
////        case coinBalance = "coin_balance"
////        case error
////    }
////}
////
////// MARK: - Wallet Asset
////
////struct WalletAsset: Identifiable, Codable {
////
////    let assetId: String
////    let assetName: String
////    let assetCode: String
////    let assetImage: String
////    let coinBalance: String
////    let currencyType: String
////    let network: [String]?
////
////    var id: String { assetId }
////
////    /// "1" = fiat
////    var isFiat: Bool {
////        currencyType == "1"
////    }
////
////    enum CodingKeys: String, CodingKey {
////
////        case assetId       = "currency_id"
////        case assetName     = "currency_name"
////        case assetCode     = "currency_code"
////        case assetImage    = "logo"
////        case coinBalance   = "balance"
////        case currencyType  = "currency_type"
////        case network
////    }
////
////    init(from decoder: Decoder) throws {
////
////        let container = try decoder.container(keyedBy: CodingKeys.self)
////
////        // currency_id can be Int or String
////        if let intId = try? container.decode(Int.self, forKey: .assetId) {
////            assetId = String(intId)
////        } else {
////            assetId = try container.decode(String.self, forKey: .assetId)
////        }
////
////        assetName = try container.decode(String.self, forKey: .assetName)
////        assetCode = try container.decode(String.self, forKey: .assetCode)
////        assetImage = try container.decode(String.self, forKey: .assetImage)
////        coinBalance = try container.decode(String.self, forKey: .coinBalance)
////        currencyType = try container.decode(String.self, forKey: .currencyType)
////        network = try? container.decode([String].self, forKey: .network)
////    }
////}
////
////// MARK: - User Transaction Model
////
////struct UserTransaction: Codable, Identifiable {
////
////    let id = UUID()
////
////    let transactionId: String?
////    let transactionTimestamp: String?
////    let description: String?
////    let debitAmount: String?
////    let creditAmount: String?
////    let status: String?
////
////    enum CodingKeys: String, CodingKey {
////
////        case transactionId        = "transaction_id"
////        case transactionTimestamp = "transaction_timestamp"
////        case description
////        case debitAmount          = "debit_amount"
////        case creditAmount         = "credit_amount"
////        case status
////    }
////}
////
////struct UserTransactionsWResponse: Codable {
////
////    let errorMsg: String?
////    let trxnList: [UserTransaction]?
////    let error: String?
////    let totalCount: Int?
////
////    enum CodingKeys: String, CodingKey {
////        case errorMsg  = "error_msg"
////        case trxnList
////        case error
////        case totalCount
////    }
////}
////
////
////// MARK: - Ledger Balance
////
////struct LedgerBalanceResponse: Codable {
////
////    let status: Bool?
////    let message: String?
////    let data: LedgerData?
////}
////
////struct LedgerData: Codable {
////
////    let btcBalance: String?
////    let usdBalance: String?
////}
////
////// MARK: - Withdraw Requests
////
////struct ExternalWithdrawRequest: Encodable {
////
////    let merchantId: Int
////    let assetId: String
////    let amount: Double
////    let walletAddress: String
////    let network: String?
////    let twoFACode: String?
////
////    enum CodingKeys: String, CodingKey {
////        case merchantId    = "merchant_id"
////        case assetId       = "asset_id"
////        case amount
////        case walletAddress = "wallet_address"
////        case network
////        case twoFACode     = "two_fa_code"
////    }
////}
////
////struct PayBitoTransferRequest: Encodable {
////
////    let merchantId: Int
////    let assetId: String
////    let amount: Double
////    let paybitoUserId: String
////
////    enum CodingKeys: String, CodingKey {
////        case merchantId    = "merchant_id"
////        case assetId       = "asset_id"
////        case amount
////        case paybitoUserId = "paybito_user_id"
////    }
////}
////
////struct BankWithdrawRequest: Encodable {
////
////    let merchantId: Int
////    let amount: Double
////    let bankAccountId: Int
////
////    enum CodingKeys: String, CodingKey {
////        case merchantId    = "merchant_id"
////        case amount
////        case bankAccountId = "bank_account_id"
////    }
////}
////
////// MARK: - Generic API Response
////
////struct GenericWalletResponse: Codable {
////
////    let status: Bool?
////    let message: String?
////    let data: String?
////}
////
////// MARK: - Withdraw Option
////
////enum WithdrawOption: String, CaseIterable, Identifiable {
////
////    case paybitoWallet   = "Transfer to PayBito Wallet"
////    case externalWallet  = "Transfer to an External Wallet"
////    case bankAccount     = "Withdraw to Bank Account"
////
////    var id: String { rawValue }
////
////    var icon: String {
////
////        switch self {
////
////        case .paybitoWallet:
////            return "arrow.left.arrow.right.circle.fill"
////
////        case .externalWallet:
////            return "externaldrive.connected.to.line.below.fill"
////
////        case .bankAccount:
////            return "building.columns.fill"
////        }
////    }
////}
//
//
//
//
//
//////
//////  WalletModels.swift
//////  Trading_Terminal
//////
//////  Full models — matches BillBitcoins web API exactly.
//////
//
//import Foundation
//
//// MARK: - Wallet Assets Response
//
//struct WalletAssetsResponse: Codable {
//    let rollingReserveBalance: [WalletAsset]?
//    let coinBalance: [WalletAsset]?
//    let error: String?
//
//    enum CodingKeys: String, CodingKey {
//        case rollingReserveBalance = "rolling_reserve_balance"
//        case coinBalance           = "coin_balance"
//        case error
//    }
//}
//
//// MARK: - Wallet Asset
//
//struct WalletAsset: Identifiable, Codable {
//    let assetId: String
//    let assetName: String
//    let assetCode: String
//    let assetImage: String
//    let coinBalance: String
//    let currencyType: String
//    let network: [String]?
//
//    var id: String { assetId }
//
//    /// "1" = fiat
//    var isFiat: Bool { currencyType == "1" }
//
//    enum CodingKeys: String, CodingKey {
//        case assetId      = "currency_id"
//        case assetName    = "currency_name"
//        case assetCode    = "currency_code"
//        case assetImage   = "logo"
//        case coinBalance  = "balance"
//        case currencyType = "currency_type"
//        case network
//    }
//
//    init(from decoder: Decoder) throws {
//        let c = try decoder.container(keyedBy: CodingKeys.self)
//        if let intId = try? c.decode(Int.self, forKey: .assetId) {
//            assetId = String(intId)
//        } else {
//            assetId = try c.decode(String.self, forKey: .assetId)
//        }
//        assetName    = try c.decode(String.self, forKey: .assetName)
//        assetCode    = try c.decode(String.self, forKey: .assetCode)
//        assetImage   = try c.decode(String.self, forKey: .assetImage)
//        coinBalance  = try c.decode(String.self, forKey: .coinBalance)
//        currencyType = try c.decode(String.self, forKey: .currencyType)
//        network      = try? c.decode([String].self, forKey: .network)
//    }
//}
//
//// MARK: - Crypto Address Response
//
//struct CryptoAddressResponse: Codable {
//    let isEnabledAutoWithdraw: Int?
//    let memo: String?
//    let merchantId: Int?
//    let networkType: String?
//    let currencyId: Int?
//    // The second element has error info
//    let errorMsg: String?
//    let error: String?
//
//    enum CodingKeys: String, CodingKey {
//        case isEnabledAutoWithdraw
//        case memo
//        case merchantId  = "merchant_id"
//        case networkType = "network_type"
//        case currencyId  = "currency_id"
//        case errorMsg    = "error_msg"
//        case error
//    }
//}
//
//// MARK: - Fees By Currency Response
//
//struct FeesByCurrencyResponse: Codable {
//    let currency: String?
//    let minFee: String?
//    let tdsRate: String?
//    let fromFee: String?
//    let errorMsg: String?
//    let feeRate: String?
//    let gstRate: String?
//    let currencyPrecision: String?
//    let error: String?
//    let toFee: String?
//
//    enum CodingKeys: String, CodingKey {
//        case currency          = "CURRENCY"
//        case minFee            = "MIN_FEE"
//        case tdsRate           = "TDS_RATE"
//        case fromFee           = "FROMFEE"
//        case errorMsg          = "error_msg"
//        case feeRate           = "FEE_RATE"
//        case gstRate           = "GST_RATE"
//        case currencyPrecision = "CURRENCY_PRECISION"
//        case error
//        case toFee             = "TOFEE"
//    }
//
//    /// Minimum transferable amount
//    var minAmount: Double { Double(fromFee ?? "0.01") ?? 0.01 }
//    /// Maximum transferable amount
//    var maxAmount: Double { Double(toFee ?? "200") ?? 200 }
//}
//
//// MARK: - User Transaction
//
//struct UserTransaction: Codable, Identifiable {
//    let id = UUID()
//    let transactionId: String?
//    let transactionTimestamp: String?
//    let description: String?
//    let debitAmount: String?      // kept as String — API returns string
//    let creditAmount: String?
//    let status: String?
//
//    enum CodingKeys: String, CodingKey {
//        case transactionId        = "transaction_id"
//        case transactionTimestamp = "transaction_timestamp"
//        case description
//        case debitAmount          = "debit_amount"
//        case creditAmount         = "credit_amount"
//        case status
//    }
//}
//
//struct UserTransactionsWResponse: Codable {
//    let errorMsg: String?
//    let trxnList: [UserTransaction]?
//    let error: String?
//    let totalCount: Int?
//
//    enum CodingKeys: String, CodingKey {
//        case errorMsg  = "error_msg"
//        case trxnList
//        case error
//        case totalCount
//    }
//}
//
//// MARK: - Ledger
//
//struct LedgerBalanceResponse: Codable {
//    let status: Bool?
//    let message: String?
//    let data: LedgerData?
//}
//
//struct LedgerData: Codable {
//    let btcBalance: String?
//    let usdBalance: String?
//}
//
//// MARK: - Withdraw Requests
//
//struct ExternalWithdrawRequest: Encodable {
//    let merchantId: Int
//    let assetId: String
//    let amount: Double
//    let walletAddress: String
//    let network: String?
//    let twoFACode: String?
//
//    enum CodingKeys: String, CodingKey {
//        case merchantId    = "merchant_id"
//        case assetId       = "asset_id"
//        case amount
//        case walletAddress = "wallet_address"
//        case network
//        case twoFACode     = "two_fa_code"
//    }
//}
//
//struct PayBitoTransferRequest: Encodable {
//    let merchantId: Int
//    let currencyId: String
//    let amount: Double
//
//    enum CodingKeys: String, CodingKey {
//        case merchantId = "merchant_id"
//        case currencyId = "currency_id"
//        case amount
//    }
//}
//
//struct BankWithdrawRequest: Encodable {
//    let merchantId: Int
//    let amount: Double
//    let bankAccountId: Int
//
//    enum CodingKeys: String, CodingKey {
//        case merchantId    = "merchant_id"
//        case amount
//        case bankAccountId = "bank_account_id"
//    }
//}
//
//// MARK: - Generic Response
//
//struct GenericWalletResponse: Codable {
//    let status: Bool?
//    let message: String?
//    let data: String?
//}
//
//// MARK: - Withdraw Option
//
//enum WithdrawOption: String, CaseIterable, Identifiable {
//    case paybitoWallet  = "Transfer to PayBito Wallet"
//    case externalWallet = "Transfer to an External Wallet"
//    case bankAccount    = "Withdraw to Bank Account"
//
//    var id: String { rawValue }
//
//    var icon: String {
//        switch self {
//        case .paybitoWallet:  return "arrow.left.arrow.right.circle.fill"
//        case .externalWallet: return "externaldrive.connected.to.line.below.fill"
//        case .bankAccount:    return "building.columns.fill"
//        }
//    }
//}
//
//// MARK: - Encodable → Dictionary helper
//
////extension Encodable {
////    func asDictionary() -> [String: Any]? {
////        guard let data = try? JSONEncoder().encode(self),
////              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
////        else { return nil }
////        return dict
////    }
////}


//
//  SettlementModels.swift
//  SettlementWallet
//
//  Full model layer — mirrors React Dashboard.jsx API contracts exactly.
//

import Foundation

// MARK: - ─────────────────────────────────────────
// MARK: Wallet Assets
// MARK: ─────────────────────────────────────────

/// Top-level object returned by FetchUsdBtcLedgerAmount (array index 0)
struct LedgerAmountResponse: Codable {
    let coinBalance: [SettlementAsset]?
    let rollingReserveBalance: [SettlementAsset]?
    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case coinBalance          = "coin_balance"
        case rollingReserveBalance = "rolling_reserve_balance"
        case error
        case errorMsg             = "error_msg"
    }
}

struct SettlementAsset: Identifiable, Codable {
    let currencyId: String       // currency_id — can be Int or String in API
    let currencyName: String
    let currencyCode: String
    let logo: String
    let balance: String
    let currencyType: String     // "1" = fiat
    let network: [String]?
    let isBrokerCurrency: Int?   // 1 = broker coin

    var id: String { currencyId }

    /// Mirrors React: iter.currency_type === "1"
    var isFiat: Bool { currencyType == "1" }

    /// Coins that need a Memo/Tag field
    /// Mirrors React: coinIdForTag == "8" || coinIdForTag == "14" || (isBrokerCurrency==1 && network[0]=="HCNET")
    var requiresMemoTag: Bool {
        if currencyId == "8" || currencyId == "14" { return true }
        if let bc = isBrokerCurrency, bc == 1,
           let nets = network, nets.first == "HCNET" { return true }
        return false
    }

    /// Label for the memo/tag field
    var memoTagLabel: String {
        if currencyId == "8" { return "HCX Tag" }
        if currencyId == "14" { return "XRP Tag" }
        return "\(currencyCode) Tag"
    }

    /// Mirrors React setNetworkCoin()
    var defaultNetworkLabel: String {
        let id = Int(currencyId) ?? 0
        let erc20Ids: Set<Int> = [25,27,37,16,159,150,157,162,167,145,146,148,155,156,158,151,152,153,154,160,161,3,731,782]
        if erc20Ids.contains(id) { return "ERC 20" }
        if id == 2  { return "BTC"  }
        if id == 8  { return "HCX"  }
        return currencyCode
    }

    enum CodingKeys: String, CodingKey {
        case currencyId       = "currency_id"
        case currencyName     = "currency_name"
        case currencyCode     = "currency_code"
        case logo
        case balance
        case currencyType     = "currency_type"
        case network
        case isBrokerCurrency = "is_broker_currency"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // currency_id arrives as Int or String
        if let intId = try? c.decode(Int.self, forKey: .currencyId) {
            currencyId = String(intId)
        } else {
            currencyId = try c.decode(String.self, forKey: .currencyId)
        }
        currencyName     = try c.decode(String.self, forKey: .currencyName)
        currencyCode     = try c.decode(String.self, forKey: .currencyCode)
        logo             = try c.decode(String.self, forKey: .logo)
        balance          = try c.decode(String.self, forKey: .balance)
        currencyType     = try c.decode(String.self, forKey: .currencyType)
        network          = try? c.decode([String].self, forKey: .network)
        // isBrokerCurrency can arrive as Int or String
        if let i = try? c.decode(Int.self, forKey: .isBrokerCurrency) {
            isBrokerCurrency = i
        } else if let s = try? c.decode(String.self, forKey: .isBrokerCurrency) {
            isBrokerCurrency = Int(s)
        } else {
            isBrokerCurrency = nil
        }
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: User Transactions
// MARK: ─────────────────────────────────────────

/// Mirrors React GetUserTransaction response[0]
struct UserTransactionResponse: Codable {
    let error: String?
    let errorMsg: String?
    let trxnList: [SettlementTransaction]?
    let totalCount: Int?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg  = "error_msg"
        case trxnList
        case totalCount
    }
}

struct SettlementTransaction: Identifiable, Codable {

    let id = UUID()

    let transactionId: String?
    let transactionTimestamp: String?
    let description: String?
    let debitAmount: String?
    let creditAmount: String?
    let status: String?
    let name: String?
    let withdrawalType: String?

    enum CodingKeys: String, CodingKey {
        case transactionId        = "transaction_id"
        case transactionTimestamp = "transaction_timestamp"
        case description
        case debitAmount          = "debit_amount"
        case creditAmount         = "credit_amount"
        case status
        case name
        case withdrawalType
    }

    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? c.decode(Int.self, forKey: .transactionId) {
            transactionId = String(intId)
        } else {
            transactionId = try? c.decode(String.self, forKey: .transactionId)
        }

        transactionTimestamp = try? c.decode(String.self, forKey: .transactionTimestamp)
        description          = try? c.decode(String.self, forKey: .description)
        debitAmount          = try? c.decode(String.self, forKey: .debitAmount)
        creditAmount         = try? c.decode(String.self, forKey: .creditAmount)
        status               = try? c.decode(String.self, forKey: .status)
        name                 = try? c.decode(String.self, forKey: .name)
        withdrawalType       = try? c.decode(String.self, forKey: .withdrawalType)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Crypto Address (getCryptoAddress)
// MARK: ─────────────────────────────────────────

//struct SavedCryptoAddress: Codable, Identifiable {
//
//    let id = UUID()
//
//    let bitcoinAddress: String?
//    let addressName: String?
//
//    let isEnabledAutoWithdraw: Int?
//    let memo: String?
//    let merchantId: Int?
//    let networkType: String?
//    let currencyId: Int?
//
//    let error: String?
//    let errorMsg: String?
//
//    enum CodingKeys: String, CodingKey {
//
//        case bitcoinAddress = "bitcoin_address"
//        case addressName = "address_name"
//
//        case isEnabledAutoWithdraw = "isEnabledAutoWithdraw"
//        case memo
//
//        case merchantId = "merchant_id"
//        case networkType = "network_type"
//        case currencyId = "currency_id"
//
//        case error
//        case errorMsg = "error_msg"
//    }
//}

struct SavedCryptoAddress: Codable, Identifiable {

    let id = UUID()

    let bitcoinAddress: String?
    let addressName: String?
    let networkType: String?

    let isEnabledAutoWithdraw: Int?
    let memo: String?
    let merchantId: Int?
    let currencyId: Int?

    enum CodingKeys: String, CodingKey {

        case bitcoinAddress = "bitcoin_address"
        case addressName = "address_name"
        case networkType = "network_type"

        case isEnabledAutoWithdraw
        case memo
        case merchantId = "merchant_id"
        case currencyId = "currency_id"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Address Validation (isCryptoAddrValid)
// MARK: ─────────────────────────────────────────

struct CryptoAddrValidResponse: Codable {
    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Fees (getFeesByCurrencyId / getFees)
// MARK: ─────────────────────────────────────────

struct CurrencyFeesResponse: Codable {
    let currency: String?
    let minFee: String?
    let fromFee: String?       // FROMFEE — minimum send amount
    let toFee: String?         // TOFEE   — maximum send amount
    let feeRate: String?       // FEE_RATE
    let currencyPrecision: String?
    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case currency          = "CURRENCY"
        case minFee            = "MIN_FEE"
        case fromFee           = "FROMFEE"
        case toFee             = "TOFEE"
        case feeRate           = "FEE_RATE"
        case currencyPrecision = "CURRENCY_PRECISION"
        case error
        case errorMsg          = "error_msg"
    }

    var minSendAmount: Double { Double(fromFee ?? "0") ?? 0 }
    var maxSendAmount: Double { Double(toFee  ?? "0") ?? 0 }
    var feeRateValue:  Double { Double(feeRate ?? "0") ?? 0 }
    var precisionInt:  Int    { Int(currencyPrecision ?? "8") ?? 8 }
}

/// Inner object from getFees response[0].feesList[0]
struct NetworkFeeEntry: Codable {
    let totalFees: Double?
    let currencyPrecision: Int?
    let fromFee: Double?
    let toFee: Double?
}

struct GetFeesResponse: Codable {
    let error: String?
    let errorMsg: String?
    let feesList: [NetworkFeeEntry]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
        case feesList
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: SendToOther (external wallet)
// MARK: ─────────────────────────────────────────

struct SendToOtherRequest: Encodable {
    let userId: String
    let currencyId: String
    let sendAmount: String
    let toAdd: String
    let otp: String           // email OTP
    let email: String
    let secureToken: String   // Google Auth code
    var memo: String?
    var tokenType: String?    // ERC20 / TRC20 for USDT

    enum CodingKeys: String, CodingKey {
        case userId      = "userId"
        case currencyId
        case sendAmount
        case toAdd
        case otp
        case email
        case secureToken = "secure_token"
        case memo
        case tokenType
    }
}

struct SendToOtherResponse: Codable {
    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: OTP / Email (coinSendToOther)
// MARK: ─────────────────────────────────────────

struct CoinSendToOtherResponse: Codable {
    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: PayBito / Exchange Transfer
// MARK: ─────────────────────────────────────────

/// Response from /merchant/auto-login/exchange
// MARK: - Response from /merchant/auto-login/exchange

struct ExchangeAutoLoginResponse: Codable {

    let token:  String?
    let uuid:   String?
    let userId: String?   // stored as String; decoded from Int or String (see init)
    let error:  ExchangeError?

    // NOTE: exchangeUuid field removed — it duplicates `uuid` with a wrong key
    // The API returns one uuid field, not two

    enum CodingKeys: String, CodingKey {
        case token
        case uuid               // "uuid" — the exchange session UUID
        case userId             // "userId" — may be Int or String in JSON
        case error
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        token = try? c.decode(String.self, forKey: .token)
        uuid  = try? c.decode(String.self, forKey: .uuid)
        error = try? c.decode(ExchangeError.self, forKey: .error)

        // Dual-decode: API returns userId as Int (158994) not String ("158994")
        if let intValue = try? c.decode(Int.self, forKey: .userId) {
            userId = String(intValue)           // "158994" — clean, no Optional()
        } else {
            userId = try? c.decode(String.self, forKey: .userId)
        }
    }
}

struct ExchangeError: Codable {

    let errorData: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case errorData = "error_data"
        case errorMessage = "error_message"
    }
}


struct UserAccountStatusResponse: Codable {

    let error: StatusError?

    let status: Int?
}

struct StatusError: Codable {

    let errorData: Int?

    let errorMsg: String?

    enum CodingKeys: String, CodingKey {

        case errorData = "error_data"

        case errorMsg = "error_msg"

    }

}

//struct UserAccountResult: Codable {
//
//    let userId: Int?
//
//    let uuid: String?
//
//    let status: Int?
//
//}

/// Response from FetchUserSettings (google_auth_enabled check)
struct UserSettingsResponse: Codable {

    let error: String?
    let errorMsg: String?
    let googleAuthEnabled: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
        case googleAuthEnabled = "google_auth_enabled"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        error = try? c.decode(String.self, forKey: .error)
        errorMsg = try? c.decode(String.self, forKey: .errorMsg)

        if let intValue = try? c.decode(Int.self, forKey: .googleAuthEnabled) {
            googleAuthEnabled = String(intValue)
        } else {
            googleAuthEnabled = try? c.decode(String.self, forKey: .googleAuthEnabled)
        }
    }
}

/// Request + Response for transferBalencetoPaybito
struct TransferToPaybitoRequest: Encodable {
    let merchantId: String
    let customerId: String
    let amount: String
    let currencyId: String
    let type: String            // "Transfer"
    let secureToken: String     // Google Auth TOTP

    enum CodingKeys: String, CodingKey {
        case merchantId  = "merchant_id"
        case customerId
        case amount
        case currencyId
        case type
        case secureToken = "secure_token"
    }
}

struct TransferToPaybitoResponse: Codable {

    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringValue = try? container.decode(String.self, forKey: .error) {
            error = stringValue
        } else if let intValue = try? container.decode(Int.self, forKey: .error) {
            error = String(intValue)
        } else {
            error = nil
        }

        errorMsg = try? container.decode(String.self, forKey: .errorMsg)
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Bank Withdrawal
// MARK: ─────────────────────────────────────────

/// GetUserDetails response (subset we use)
struct UserrDetailsResponse: Codable {

    let userDocsStatus: UserDocsStatus?
    let bankDetailsStatus: String?
    let userTierType: String?

    enum CodingKeys: String, CodingKey {
        case userDocsStatus
        case bankDetailsStatus
        case userTierType
    }

    init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)

        userDocsStatus = try? c.decode(UserDocsStatus.self, forKey: .userDocsStatus)

        // bankDetailsStatus can be null/int/string
        if let s = try? c.decode(String.self, forKey: .bankDetailsStatus) {
            bankDetailsStatus = s
        } else if let i = try? c.decode(Int.self, forKey: .bankDetailsStatus) {
            bankDetailsStatus = String(i)
        } else {
            bankDetailsStatus = nil
        }

        // userTierType can be int or string
        if let s = try? c.decode(String.self, forKey: .userTierType) {
            userTierType = s
        } else if let i = try? c.decode(Int.self, forKey: .userTierType) {
            userTierType = String(i)
        } else {
            userTierType = nil
        }
    }
}
/// userDocsStatus can arrive as Int, String, or null
enum UserDocsStatus {
    case submitted       // "1" — approved
    case pending         // "0" — under review
    case declined        // "2" or other
    case missing         // null / undefined

    var isApproved: Bool { self == .submitted }
}

extension UserDocsStatus: Codable {
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .missing; return }
        if let i = try? c.decode(Int.self) {
            switch i { case 1: self = .submitted; case 0: self = .pending; default: self = .declined }
            return
        }
        if let s = try? c.decode(String.self) {
            switch s { case "1": self = .submitted; case "0": self = .pending; default: self = .declined }
            return
        }
        self = .missing
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .submitted: try c.encode("1")
        case .pending:   try c.encode("0")
        case .declined:  try c.encode("2")
        case .missing:   try c.encodeNil()
        }
    }
}
//
struct BanksDetails: Codable {
    let bankDetailsId: String?
    let beneficiaryName: String?
    let bankName: String?
    let accountNo: String?
    let accountType: String?
    let ifscCode: String?
    let swiftCode: String?
    let routingNo: String?
    let bankAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case bankDetailsId   = "bankDetailsId"
        case beneficiaryName = "benificiary_name"
        case bankName        = "bank_name"
        case accountNo       = "account_no"
        case accountType
        case ifscCode
        case swiftCode
        case routingNo       = "routing_no"
        case bankAddress
    }
}
//
struct GetUserBankDetailsResponse: Codable {

    let error: BankError?

    let bankDetails: BanksDetails?

}
struct BankError: Codable {
    let errorData: Int?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case errorData = "error_data"
        case errorMsg  = "error_msg"
    }
}

/// ConvertPrice response
struct ConvertPriceResponse: Codable {
    let error: ConvertPriceError?
    let marketPrice: Double?
}

struct ConvertPriceError: Codable {
    let errorData: Int?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case errorData = "error_data"
        case errorMsg  = "error_msg"
    }
}

/// GetTransactionLimitByTier
struct TransactionLimitResponse: Codable {
    let error: BankError?
    let minLimit: Double?
    let dailySendLimit: Double?
}

/// CreateWithdrawalRequest body
struct CreateWithdrawalRequestBody: Encodable {
    let userUuid: String
    let merchantUuid: String
    let merchantId: String
    let securityCode: String      // Google Auth 6-digit
    let amount: String            // crypto amount
    let fiatAmount: String
    let currencyId: String
    let fiatCurrencyCode: String
    let bankId: String?
}

struct CreateWithdrawalResponse: Codable {
    let error: CreateWithdrawalError?
}

struct CreateWithdrawalError: Codable {
    let errorData: Int?
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case errorData    = "error_data"
        case errorMessage = "error_message"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: Generic / Shared
// MARK: ─────────────────────────────────────────

struct GenericServiceResponse: Codable {
    let error: String?
    let errorMsg: String?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
    }
}

// MARK: - ─────────────────────────────────────────
// MARK: UI State Enums
// MARK: ─────────────────────────────────────────

enum WithdrawType: String, Identifiable {
    case exchange = "exchange"
    case external = "external"
    case bank     = "bank"
    var id: String { rawValue }
}

enum AddressEntryMode {
    case manual, saved
}

enum WalletAddressValidationState: Equatable {
    case idle
    case valid(String)
    case invalid(String)

    var isValid: Bool {
        if case .valid = self { return true }
        return false
    }

    var message: String {
        switch self {
        case .idle:           return ""
        case .valid(let m):   return m
        case .invalid(let m): return m
        }
    }
}
