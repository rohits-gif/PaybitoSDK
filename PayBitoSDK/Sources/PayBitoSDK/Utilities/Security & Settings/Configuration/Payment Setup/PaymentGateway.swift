// MARK: - Models

import Foundation

struct PaymentGateway: Codable, Identifiable {
    let id: Int

      let gatewayName: String

      let clientId: String?

      let clientSecret: String?

      let isActive: Int

      let secretKeyV4: String?

      let accountId: String?

      let siteTag: String?

      let authorization: String?

      let controlKeyword: String?

      let userName: String?

      let password: String?

      let cashierKey: String?
    var isEnabled: Bool { isActive == 1 }
}

// MARK: - Gateway name constants (must match exact strings sent/received by API)
enum GatewayName {
    static let stripe = "Stripe"
    static let paypal = "Paypal"
    static let kurvPay = "KurvPay"                   // PayBito Nexus
    static let hms = "HostMerchantServices"           // PayBito Nova
    static let nmi = "NMI"                            // PayBito Zenith
    static let netbilling = "netbilling"              // PayBito Vertex (lowercase on the wire)
    static let cardflo = "cardflo"                    // PayBito Sovereign
}

// MARK: - API Response Models

struct GetAllGatewaysResponse: Codable {
    let error: Int
    let errorMsg: String?
    let paymentGateways: [PaymentGateway]?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
        case paymentGateways = "payment_gateways"
    }
}

struct AddGatewayResponse: Codable {
    let error: Int
    let errorMsg: String?
    let returnId: Int?

    enum CodingKeys: String, CodingKey {
        case error
        case errorMsg = "error_msg"
        case returnId
    }
}

//struct BaseResponse: Codable {
//    let error: Int
//    let errorMsg: String?
//
//    enum CodingKeys: String, CodingKey {
//        case error
//        case errorMsg = "error_msg"
//    }
//}

// MARK: - Request Models

struct AddGatewayRequest: Encodable {
    let merchantId: String
    let gatewayName: String
    let clientId: String
    let clientSecret: String

    // KurvPay / HMS / NMI
    var secretKeyV4: String? = nil

    // netbilling
    var accountId: String? = nil
    var siteTag: String? = nil
    var authorization: String? = nil
    var controlKeyword: String? = nil

    // cardflo
    var userName: String? = nil
    var password: String? = nil
    var cashierKey: String? = nil
}

struct UpdateGatewayRequest: Encodable {
    let merchantId: String
    let id: String
    let clientId: String
    let clientSecret: String
    let isActive: String

    // KurvPay / HMS / NMI
    var secretKeyV4: String? = nil

    // netbilling
    var accountId: String? = nil
    var siteTag: String? = nil
    var authorization: String? = nil
    var controlKeyword: String? = nil
}

// netbilling / cardflo send isActive as a JSON number (1/0) instead of a string.
struct UpdateGatewayRequestNumericActive: Encodable {
    let merchantId: String
    let id: String
    let gatewayName: String
    var clientId: String? = nil
    var clientSecret: String? = nil
    let isActive: Int

    // netbilling
    var accountId: String? = nil
    var siteTag: String? = nil
    var authorization: String? = nil
    var controlKeyword: String? = nil

    // cardflo
    var userName: String? = nil
    var password: String? = nil
    var cashierKey: String? = nil
}

struct DeleteGatewayRequest: Encodable {
    let merchantId: String
    let id: String

    // KurvPay / HMS / NMI must resend secretKeyV4 on delete
    var secretKeyV4: String? = nil
}

struct GetAllGatewaysRequest: Encodable {
    let merchantId: String
}
