// MARK: - PaymentOptionsModel.swift

import Foundation

enum BillingProfile {

    // MARK: - Currency
    struct Currency {
        let id: Int
        let code: String
        let name: String
        let logo: String?
    }

    // MARK: - Gateway config
    // Mirrors the web's gatewayConfig state object — one flag per configured gateway
    struct GatewayConfig {
        var stripeConfigured: Bool = false      // Stripe → PayBito Apex      (id 1)
        var paypalConfigured: Bool = false      // PayPal → PayBito Titan     (id 2)
        var kurvPayConfigured: Bool = false     // KurvPay → PayBito Nexus   (id 7)
        var netbillingConfigured: Bool = false  // netbilling → PayBito Vertex (id 8)
        var hmsConfigured: Bool = false         // HMS → PayBito Nova         (id 9)
        var cardFloConfigured: Bool = false     // cardflo → PayBito Sovereign (id 10)
        var nmiConfigured: Bool = false         // NMI → PayBito Zenith       (id 11)
    }

    // MARK: - Payment method IDs
    // 1=Stripe, 2=PayPal, 3=BrandWallet, 4=ExtWallet, 5=GuestCheckout
    // 7=KurvPay, 8=netbilling, 9=HMS, 10=cardflo, 11=NMI
    struct PaymentMethod: Decodable {
        let id: Int
        let name: String?
    }

    // MARK: - Profile (UI model)
    struct Profile: Identifiable {
        var id: Int
        var name: String
        var customerEmail: String
        var isDefault: Bool
        var billingType: String

        // Card gateways
        var stripeEnabled: Bool
        var paypalEnabled: Bool
        var kurvPayEnabled: Bool
        var netbillingEnabled: Bool
        var hmsEnabled: Bool
        var cardFloEnabled: Bool
        var nmiEnabled: Bool

        // Crypto
        var cryptoEnabled: Bool
        var brandWallet: Bool
        var externalWalletEnabled: Bool
        var guestCheckout: Bool
        var selectedCryptoCodes: [String]
    }

    // MARK: - API Response Models
    struct ProfileRecord: Decodable {
        let id: Int
        let profileName: String
        let billingType: String
        let customerEmail: String?
        let currencyIds: String?
        let isDefaultProfile: Int?
        let paymentMethods: [PaymentMethodRef]?
        let currencies: [CurrencyRef]?

        struct PaymentMethodRef: Decodable {
            let id: Int
        }

        struct CurrencyRef: Decodable {
            let currencyId: Int
            let currency: String
        }
    }

    struct FetchAllResponse: Decodable {
        let error: Int
        let message: String?
        let data: [ProfileRecord]?
    }

    struct MutateResponse: Decodable {
        let error: String
        let message: String?
    }

    struct DeleteResponse: Decodable {
        let error: Int
        let message: String?
    }

    struct DefaultResponse: Decodable {
        let error: IntOrString
        let message: String?

        enum IntOrString: Decodable {
            case int(Int), string(String)
            init(from decoder: Decoder) throws {
                let c = try decoder.singleValueContainer()
                if let i = try? c.decode(Int.self)    { self = .int(i);    return }
                if let s = try? c.decode(String.self) { self = .string(s); return }
                self = .int(-1)
            }
            var isSuccess: Bool {
                switch self {
                case .int(let i):    return i == 0
                case .string(let s): return s == "0"
                }
            }
        }
    }

    // Matches the PaymentGateway model used by PaymentGatewayService —
    // extended with fields for all gateway types.
    struct GatewayItem: Decodable {
        let gatewayName: String?
        let clientId: String?
        let clientSecret: String?
        // netbilling
        let accountId: String?
        let siteTag: String?
        // cardflo
        let userName: String?
        let password: String?
        let cashierKey: String?
    }

    struct GatewayResponse: Decodable {
        let error: Int?
        let payment_gateways: [GatewayItem]?
    }

    struct MethodsResponse: Decodable {
        let status: Bool?
        let data: [PaymentMethod]?
    }

    struct LedgerCoin: Decodable {
        let currency_id: Int
        let currency_code: String
        let currency_name: String
        let currency_type: String
        let logo: String?
        let balance: String?
        let is_broker_currency: Int?
        let network: [String]?

        enum CodingKeys: String, CodingKey {
            case currency_id, currency_code, currency_name, currency_type
            case logo, balance, is_broker_currency, network
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            if let intId = try? c.decode(Int.self, forKey: .currency_id) {
                currency_id = intId
            } else if let stringId = try? c.decode(String.self, forKey: .currency_id),
                      let intId = Int(stringId) {
                currency_id = intId
            } else {
                currency_id = 0
            }
            currency_code = try c.decode(String.self, forKey: .currency_code)
            currency_name = try c.decode(String.self, forKey: .currency_name)
            currency_type = try c.decode(String.self, forKey: .currency_type)
            logo = try? c.decode(String.self, forKey: .logo)
            balance = try? c.decode(String.self, forKey: .balance)
            is_broker_currency = try? c.decode(Int.self, forKey: .is_broker_currency)
            network = try? c.decode([String].self, forKey: .network)
        }
    }

    struct LedgerData: Decodable {
        let error: String?
        let coin_balance: [LedgerCoin]?
        let rolling_reserve_balance: [LedgerCoin]?
    }

    // MARK: - Create/Update payloads
    struct CreatePayload: Encodable {
        let merchantId: Int
        let billingType: String
        let profileName: String
        let paymentMethodIds: String   // "1:1:1,2:2:0,7:3:0,..." triples
        let redirectUrl: String
        let customerEmail: String
        let isDefaultProfile: Int
        let currencyIds: String
    }

    struct UpdatePayload: Encodable {
        let id: Int
        let merchantId: Int
        let billingType: String
        let profileName: String
        let paymentMethodIds: String
        let customerEmail: String
        let isDefaultProfile: Int
        let currencyIds: String
    }
}
