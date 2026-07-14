//
//  Autowithdrawalmodels .swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 10/06/26.
//

import Foundation

enum AutoWithdrawal {

    // MARK: - Destination
    enum Destination: String, CaseIterable {
        case platformWallet = "PLATFORM_WALLET"
        case externalWallet = "EXTERNAL_WALLET"
        case bankAccount    = "BANK_ACCOUNT"

        var label: String {
            switch self {
            case .platformWallet: return "Platform Wallet"
            case .externalWallet: return "External Wallet"
            case .bankAccount:    return "Bank Account"
            }
        }

        var icon: String {
            switch self {
            case .platformWallet: return "wallet.pass"
            case .externalWallet: return "bitcoinsign.circle"
            case .bankAccount:    return "building.columns"
            }
        }
    }

    // MARK: - Coin
    struct Coin: Identifiable, Equatable {
        let id: Int
        let currencyCode: String
        let currencyName: String
        let logo: String
    }

    // MARK: - Crypto Address
    struct CryptoAddressEntry: Decodable {
        let bitcoinAddress: String?
        let isEnabledAutoWithdraw: Int?

        enum CodingKeys: String, CodingKey {
            case bitcoinAddress      = "bitcoin_address"
            case isEnabledAutoWithdraw
        }
    }

    // MARK: - Resolved address for display
    struct ResolvedAddress: Identifiable {
        var id: String { code }
        let code: String
        let name: String
        let logo: String
        let address: String
    }

    // MARK: - Bank status
    enum BankStatus {
        case notSubmitted
        case pending
        case verified
        case rejected

        init(raw: Int?) {
            switch raw {
            case 2:  self = .verified
            case 0:  self = .pending
            case 3:  self = .rejected
            default: self = .notSubmitted
            }
        }
    }

    // MARK: - Rule from API
    struct Rule: Identifiable, Decodable {
        let id: Int
        let withdrawType: String
        let amountInUsd: Double
        let frequencyInDays: Int
        let currencies: [RuleCurrency]

        var destination: Destination {
            Destination(rawValue: withdrawType) ?? .platformWallet
        }
    }

    struct RuleCurrency: Decodable, Identifiable {
        var id: Int { currencyId }
        let currencyId: Int
        let currency: String
    }

    // MARK: - API Responses
    struct LedgerResponse: Decodable {
        let error: String?
        let errorMsg: String?
        let coinBalance: [CoinBalance]?

        enum CodingKeys: String, CodingKey {
            case error
            case errorMsg    = "error_msg"
            case coinBalance = "coin_balance"
        }
    }

    struct CoinBalance: Decodable {
        let currencyId: Int
        let currencyCode: String
        let currencyName: String
        let logo: String
        let currencyType: String

        enum CodingKeys: String, CodingKey {
            case currencyId   = "currency_id"
            case currencyCode = "currency_code"
            case currencyName = "currency_name"
            case logo
            case currencyType = "currency_type"
        }
    }

    struct SaveResponse: Decodable {
        let status: Bool
        let message: String?
    }

    struct GetRulesResponse: Decodable {
        let status: Bool
        let data: RulesData?

        struct RulesData: Decodable {
            let autoWithdrawalDetails: [Rule]?
        }
    }

    struct DeleteResponse: Decodable {
        let status: Bool
        let message: String?
    }

    struct UserDetailsResponse: Decodable {
        let bankDetailsStatus: Int?
    }
}
