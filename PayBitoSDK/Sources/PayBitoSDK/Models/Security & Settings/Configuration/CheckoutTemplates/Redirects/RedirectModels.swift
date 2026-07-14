// MARK: - RedirectModels.swift

import Foundation

// MARK: - Enums
enum RedirectMode: String {
    case url    = "url"
    case hosted = "hosted"
}

// MARK: - Domain Models
struct RedirectTemplate: Identifiable {
    let id:          Int
    var name:        String
    var successURL:  String
    var failureURL:  String
    var cancelURL:   String
    var successMode: RedirectMode
    var failureMode: RedirectMode
    var isDefault:   Bool
    var params:      RedirectQueryParams
}

struct RedirectQueryParams {
    var paymentId:     Bool
    var status:        Bool
    var customerEmail: Bool
    var amount:        Bool
}

struct DefaultRedirect {
    let id:         Int?
    var successURL: String
    var failureURL: String
    var cancelURL:  String
}

// MARK: - Toast / Confirm state
struct RedirectToast: Equatable {
    let message:   String
    let isSuccess: Bool
}

// MARK: - Raw API → Domain  (mirrors mapApiTemplate in React exactly)
extension RedirectTemplate {
    static func from(dict: [String: Any]) -> RedirectTemplate? {
        guard let id = dict["id"] as? Int else { return nil }

        // API returns successMode/failureMode as "0" (url) or "1" (hosted)
        let smRaw = dict["successMode"] as? String ?? "0"
        let fmRaw = dict["failureMode"] as? String ?? "0"

        return RedirectTemplate(
            id:          id,
            name:        dict["templateName"]    as? String ?? "",
            successURL:  dict["successUrl"]      as? String ?? "",
            failureURL:  dict["failureUrl"]      as? String ?? "",
            cancelURL:   dict["cancelUrl"]       as? String ?? "",
            successMode: smRaw == "0" ? .url : .hosted,
            failureMode: fmRaw == "0" ? .url : .hosted,
            isDefault:   (dict["isDefault"]      as? Int ?? 0) == 1,
            params: RedirectQueryParams(
                paymentId:     (dict["passPaymentId"]     as? Int ?? 1) == 1,
                status:        (dict["passStatus"]        as? Int ?? 1) == 1,
                customerEmail: (dict["passCustomerEmail"] as? Int ?? 1) == 1,
                amount:        (dict["passAmount"]        as? Int ?? 1) == 1
            )
        )
    }
}

extension DefaultRedirect {
    static func from(dict: [String: Any]) -> DefaultRedirect {
        DefaultRedirect(
            id:         dict["id"]         as? Int,
            successURL: dict["successUrl"] as? String ?? "",
            failureURL: dict["failureUrl"] as? String ?? "",
            cancelURL:  dict["cancelUrl"]  as? String ?? ""
        )
    }
}

// MARK: - Save Payload
// merchantId is set by RedirectService.extractMerchantId() — pass 0 from VM,
// service overrides it. Or pass it directly — both work since toDict() writes it.
struct RedirectSavePayload {
    let id:                Int?
    let merchantId:        Int     // filled by service's extractMerchantId()
    let templateName:      String
    let successUrl:        String
    let successMode:       Int     // 0 = url redirect, 1 = hosted page
    let failureUrl:        String
    let failureMode:       Int
    let cancelUrl:         String
    let passPaymentId:     Int
    let passStatus:        Int
    let passCustomerEmail: Int
    let passAmount:        Int
    let isDefault:         Int	

    func toDict() -> [String: Any] {
        var dict: [String: Any] = [
            "merchantId":         merchantId,
            "templateName":       templateName,
            "successUrl":         successUrl,
            "successMode":        successMode,
            "failureUrl":         failureUrl,
            "failureMode":        failureMode,
            "cancelUrl":          cancelUrl,
            "passPaymentId":      passPaymentId,
            "passStatus":         passStatus,
            "passCustomerEmail":  passCustomerEmail,
            "passAmount":         passAmount,
            "isDefault":          isDefault
        ]
        if let id = id { dict["id"] = id }
        return dict
    }
}
