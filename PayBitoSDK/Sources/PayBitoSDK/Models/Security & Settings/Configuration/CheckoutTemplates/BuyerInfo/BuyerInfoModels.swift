// MARK: - BuyerInfoModels.swift


import Foundation

struct BuyerInfoListResponse: Decodable {
    let status: Bool
    let error: String
    let message: String?
    let data: [BuyerInfoRaw]?
}

struct BuyerInfoSaveResponse: Decodable {
    let status: Bool
    let error: String
    let message: String?
}

// MARK: - Raw API Model (from GET)
struct BuyerInfoRaw: Decodable {
    let id: Int
    let merchantId: Int?
    let profileName: String?
    let isDefaultProfile: Int?
    let createdAt: String?

    let collectEmail: Int?
    let collectFullName: Int?
    let collectAddress: Int?
    let collectPhoneNumber: Int?
    let collectCompanyName: Int?
    let collectTaxInfo: Int?
    let collectCryptoRefundAddress: Int?
    let collectOrderNotes: Int?

    let customFields: [CustomFieldRaw]?
}

struct CustomFieldRaw: Decodable {
    let customFieldId: Int?
    let fieldLabel: String?
    let fieldType: String?
    let placeholderText: String?
    let helpText: String?
}

// MARK: - Domain Models (mirrors React's apiToProfile transform)
struct BuyerInfoProfile: Identifiable {
    let id: Int
    let merchantId: String
    var name: String
    var isDefaultProfile: Bool
    var createdAt: String?
    var stdFields: [StdField]
    var customFields: [CustomField]
}

struct StdField: Identifiable {
    let id = UUID()
    let key: String
    let apiKey: String
    let label: String
    let icon: String          // SF Symbol name
    let locked: Bool
    let helpText: String
    var enabled: Bool
    var required: Bool
}

struct CustomField: Identifiable {
    var id = UUID()
    var customFieldId: Int?
    var label: String = ""
    var type: String = "text"
    var required: Bool = false
    var placeholder: String = ""
    var helpText: String = ""
    var options: String = ""
}

// MARK: - Payloads

/// POST /buyer-information  — CustomFieldId capitalized
struct CreateBuyerInfoPayload: Encodable {
    let merchantId: String
    let profileName: String
    let isDefaultProfile: Int
    let collectEmail: Int
    let collectFullName: Int
    let collectAddress: Int
    let collectPhoneNumber: Int
    let collectCompanyName: Int
    let collectTaxInfo: Int
    let collectOrderNotes: Int
    let customFields: [CreateCustomFieldPayload]
}

struct CreateCustomFieldPayload: Encodable {
    let CustomFieldId: Int          // Capitalized for POST
    let fieldLabel: String
    let fieldType: String
    let placeholderText: String
    let helpText: String
}

/// PUT /buyer-information/update/:id  — customFieldId lowercase, includes createdAt
struct UpdateBuyerInfoPayload: Encodable {
    let merchantId: String
    let profileName: String
    let isDefaultProfile: Int
    let createdAt: String?
    let collectEmail: Int
    let collectFullName: Int
    let collectAddress: Int
    let collectPhoneNumber: Int
    let collectCompanyName: Int
    let collectTaxInfo: Int
    let collectOrderNotes: Int
    let customFields: [UpdateCustomFieldPayload]
}

struct UpdateCustomFieldPayload: Encodable {
    let customFieldId: Int          // lowercase for PUT
    let fieldLabel: String
    let fieldType: String
    let placeholderText: String
    let helpText: String
}

// MARK: - STD_FIELD_MAP (mirrors JS constant exactly)
extension StdField {
    static let defaultMap: [StdField] = [
        StdField(key: "email",    apiKey: "collectEmail",       label: "Email Address",     icon: "envelope",     locked: true,  helpText: "Used for order confirmation",        enabled: true,  required: true),
        StdField(key: "full_name",apiKey: "collectFullName",    label: "Full Name",          icon: "person",       locked: false, helpText: "Buyer's full legal name (optional)", enabled: false, required: false),
        StdField(key: "address",  apiKey: "collectAddress",     label: "Shipping Address",   icon: "location",     locked: false, helpText: "Street, city, state, country, ZIP",  enabled: false, required: false),
        StdField(key: "phone",    apiKey: "collectPhoneNumber", label: "Phone Number",       icon: "phone",        locked: false, helpText: "Contact number for delivery",        enabled: false, required: false),
        StdField(key: "company",  apiKey: "collectCompanyName", label: "Company Name",       icon: "building.2",   locked: false, helpText: "Business name (if applicable)",      enabled: false, required: false),
        StdField(key: "tax_id",   apiKey: "collectTaxInfo",     label: "Tax ID / VAT Number",icon: "doc.text",     locked: false, helpText: "For business invoicing",             enabled: false, required: false),
        StdField(key: "notes",    apiKey: "collectOrderNotes",  label: "Order Notes",        icon: "pencil",       locked: false, helpText: "Additional instructions from buyer", enabled: false, required: false),
    ]
}

// MARK: - Transformers (mirrors JS apiToProfile / profileToCreatePayload / profileToUpdatePayload)
extension BuyerInfoProfile {

    /// apiToProfile — converts raw API response → domain model
    static func from(raw: BuyerInfoRaw) -> BuyerInfoProfile {
        var stdFields = StdField.defaultMap
        let apiMap: [String: Int] = [
            "collectEmail":       raw.collectEmail ?? 0,
            "collectFullName":    raw.collectFullName ?? 0,
            "collectAddress":     raw.collectAddress ?? 0,
            "collectPhoneNumber": raw.collectPhoneNumber ?? 0,
            "collectCompanyName": raw.collectCompanyName ?? 0,
            "collectTaxInfo":     raw.collectTaxInfo ?? 0,
            "collectOrderNotes":  raw.collectOrderNotes ?? 0,
        ]
        for i in stdFields.indices {
            let f = stdFields[i]
            stdFields[i].enabled = f.locked ? true : (apiMap[f.apiKey] == 1)
            stdFields[i].required = f.locked
        }

        let customFields: [CustomField] = (raw.customFields ?? []).map { cf in
            CustomField(
                customFieldId: cf.customFieldId,
                label:         cf.fieldLabel ?? "",
                type:          cf.fieldType ?? "text",
                placeholder:   cf.placeholderText ?? "",
                helpText:      cf.helpText ?? ""
            )
        }

        return BuyerInfoProfile(
            id: raw.id,
            merchantId: String(raw.merchantId ?? 0),
            name: raw.profileName ?? "",
            isDefaultProfile: (raw.isDefaultProfile ?? 0) == 1,
            createdAt: raw.createdAt,
            stdFields: stdFields,
            customFields: customFields
        )
    }

    /// profileToCreatePayload — POST body
    func toCreatePayload(merchantId: String) -> CreateBuyerInfoPayload {
        func std(_ key: String) -> Int { (stdFields.first { $0.apiKey == key }?.enabled == true) ? 1 : 0 }
        let cf = customFields.enumerated().compactMap { (idx, c) -> CreateCustomFieldPayload? in
            guard !c.label.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
            return CreateCustomFieldPayload(
                CustomFieldId:   idx + 1,
                fieldLabel:      c.label.trimmingCharacters(in: .whitespaces),
                fieldType:       c.type,
                placeholderText: c.placeholder,
                helpText:        c.helpText
            )
        }
        return CreateBuyerInfoPayload(
            merchantId:         merchantId,
            profileName:        name,
            isDefaultProfile:   isDefaultProfile ? 1 : 0,
            collectEmail:       std("collectEmail"),
            collectFullName:    std("collectFullName"),
            collectAddress:     std("collectAddress"),
            collectPhoneNumber: std("collectPhoneNumber"),
            collectCompanyName: std("collectCompanyName"),
            collectTaxInfo:     std("collectTaxInfo"),
            collectOrderNotes:  std("collectOrderNotes"),
            customFields:       cf
        )
    }

    /// profileToUpdatePayload — PUT body
    func toUpdatePayload(merchantId: String) -> UpdateBuyerInfoPayload {
        func std(_ key: String) -> Int { (stdFields.first { $0.apiKey == key }?.enabled == true) ? 1 : 0 }
        let cf = customFields.enumerated().compactMap { (idx, c) -> UpdateCustomFieldPayload? in
            guard !c.label.trimmingCharacters(in: .whitespaces).isEmpty else { return nil }
            return UpdateCustomFieldPayload(
                customFieldId:   c.customFieldId ?? (idx + 1),
                fieldLabel:      c.label.trimmingCharacters(in: .whitespaces),
                fieldType:       c.type,
                placeholderText: c.placeholder,
                helpText:        c.helpText
            )
        }
        return UpdateBuyerInfoPayload(
            merchantId:         merchantId,
            profileName:        name,
            isDefaultProfile:   isDefaultProfile ? 1 : 0,
            createdAt:          createdAt,
            collectEmail:       std("collectEmail"),
            collectFullName:    std("collectFullName"),
            collectAddress:     std("collectAddress"),
            collectPhoneNumber: std("collectPhoneNumber"),
            collectCompanyName: std("collectCompanyName"),
            collectTaxInfo:     std("collectTaxInfo"),
            collectOrderNotes:  std("collectOrderNotes"),
            customFields:       cf
        )
    }
}
