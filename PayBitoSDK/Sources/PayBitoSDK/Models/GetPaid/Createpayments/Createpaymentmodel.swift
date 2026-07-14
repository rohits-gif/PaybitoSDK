// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//


import Foundation

// MARK: - API Response

struct ProductListResponse: Decodable {
    let status: Bool
    let data:   ProductListData
}

struct ProductListData: Decodable {
    let total:    Int
    let products: [CPProduct]
}

// MARK: - Product

struct CPProduct: Decodable, Identifiable, Hashable {
    let productId:   String
    let productType: String
    let catalogId:   Int
    let name:        String
    let description: String?
    let status:      String
    let createdAt:   String
    let updatedAt:   String
    let metadata:    CPMetadata
    let prices:      [CPPrice]

    var id: String { productId }

    static func == (lhs: CPProduct, rhs: CPProduct) -> Bool { lhs.productId == rhs.productId }
    func hash(into hasher: inout Hasher) { hasher.combine(productId) }

    var isQuickPayment: Bool { metadata.type == "quick_payment" }

    var defaultPrice: CPPrice? {
        prices.first(where: { $0.default == true }) ?? prices.first
    }

    var priceLabel: String {
        guard let price = defaultPrice,
              let cur = price.currencies.first(where: { $0.default }) ?? price.currencies.first
        else { return "—" }
        let amt = formatAmount(cur.amount)
        if price.priceType == "recurring", let iv = price.intervalType {
            return "\(cur.currency) \(amt) / \(iv)"
        }
        return "\(cur.currency) \(amt)"
    }

    var iconName: String {
        let lower = name.lowercased()
        if lower.contains("watch")      { return "applewatch" }
        if lower.contains("keyboard")   { return "keyboard" }
        if lower.contains("headphone")  { return "headphones" }
        if lower.contains("power")      { return "battery.100.bolt" }
        if lower.contains("usb") || lower.contains("hub") { return "cable.connector" }
        if lower.contains("webcam") || lower.contains("camera") { return "camera" }
        if lower.contains("subscription") || lower.contains("trial") { return "repeat.circle" }
        if isQuickPayment               { return "bolt.fill" }
        return "tag.fill"
    }

    private func formatAmount(_ amount: Double) -> String {
        amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", amount)
            : String(format: "%.2f", amount)
    }
}

// MARK: - Metadata

struct CPMetadata: Decodable {
    let type: String?
    enum CodingKeys: String, CodingKey { case type }
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.type = try? container?.decodeIfPresent(String.self, forKey: .type)
    }
}

// MARK: - Price

struct CPPrice: Decodable {
    let priceId:      Int
    let priceType:    String
    let intervalType: String?
    let intervalCount: Int
    let trialDays:    Int
    let trialEnabled: Int
    let currencies:   [CPCurrency]
    let `default`:    Bool

    enum CodingKeys: String, CodingKey {
        case priceId, priceType, intervalType, intervalCount
        case trialDays, trialEnabled, currencies
        case `default` = "default"
    }

    init(from decoder: Decoder) throws {
        let c         = try decoder.container(keyedBy: CodingKeys.self)
        priceId       = try c.decode(Int.self, forKey: .priceId)
        priceType     = try c.decode(String.self, forKey: .priceType)
        intervalType  = try? c.decodeIfPresent(String.self, forKey: .intervalType)
        intervalCount = (try? c.decodeIfPresent(Int.self, forKey: .intervalCount)) ?? 0
        trialDays     = (try? c.decodeIfPresent(Int.self, forKey: .trialDays)) ?? 0
        trialEnabled  = (try? c.decodeIfPresent(Int.self, forKey: .trialEnabled)) ?? 0
        currencies    = try c.decode([CPCurrency].self, forKey: .currencies)
        `default`     = (try? c.decodeIfPresent(Bool.self, forKey: .default)) ?? false
    }
}

// MARK: - Currency

struct CPCurrency: Decodable {
    let currency:  String
    let amount:    Double
    let `default`: Bool
    enum CodingKeys: String, CodingKey {
        case currency, amount
        case `default` = "default"
    }
}

// MARK: - Section

struct ProductSection: Identifiable {
    let id    = UUID()
    let title: String
    let items: [CPProduct]
}

// MARK: - Profiles

// MARK: - AnyCodable

struct CPAnyCodable: Decodable, Hashable {
    let value: Any
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) { value = intVal }
        else if let doubleVal = try? container.decode(Double.self) { value = doubleVal }
        else if let boolVal = try? container.decode(Bool.self) { value = boolVal }
        else if let stringVal = try? container.decode(String.self) { value = stringVal }
        else { value = "Unknown" }
    }
    
    static func == (lhs: CPAnyCodable, rhs: CPAnyCodable) -> Bool {
        String(describing: lhs.value) == String(describing: rhs.value)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }
    
    var stringValue: String {
        "\(value)"
    }
    
    var intValue: Int? {
        if let i = value as? Int { return i }
        if let s = value as? String { return Int(s) }
        return nil
    }
}

// MARK: - Profiles

struct CPMethod: Decodable, Hashable {
    let id: CPAnyCodable?
    let pmId: CPAnyCodable?
    let paymentMethodId: CPAnyCodable?
    let name: String?
    let status: CPAnyCodable?
}

struct CPProfile: Decodable, Identifiable, Hashable {
    let id: String
    let name: String
    
    let collectEmail: CPAnyCodable?
    let collectFullName: CPAnyCodable?
    let collectPhoneNumber: CPAnyCodable?
    let collectAddress: CPAnyCodable?
    let collectCompanyName: CPAnyCodable?
    let collectOrderNotes: CPAnyCodable?
    let collectTaxInfo: CPAnyCodable?
    let collectCryptoRefundAddress: CPAnyCodable?
    
    let handlingFeeValue: CPAnyCodable?
    let handlingFeeType: String?
    let shippingRate: CPAnyCodable?
    let rateValue: CPAnyCodable?
    let rateType: String?
    let taxRate: CPAnyCodable?
    let taxPercentage: CPAnyCodable?
    
    let discountPercentage: CPAnyCodable?
    let discountPercent: CPAnyCodable?
    let discountValue: CPAnyCodable?
    let minimumCartValue: CPAnyCodable?
    let minCartValue: CPAnyCodable?
    let minimumAmount: CPAnyCodable?
    let couponCode: String?
    
    let successUrl: String?
    let successRedirectUrl: String?
    let failureUrl: String?
    let failureRedirectUrl: String?
    
    let paymentMethods: [CPMethod]?
    let billingMethod: [CPMethod]?
    
    let isDefaultProfile: CPAnyCodable?
    
    enum CodingKeys: String, CodingKey {
        case profileId, profileName, profile_id, profile_name, id, name, campaignName
        case collectEmail, collectFullName, collectPhoneNumber, collectAddress, collectCompanyName, collectOrderNotes, collectTaxInfo, collectCryptoRefundAddress
        case handlingFeeValue, handlingFeeType, shippingRate, rateValue, rateType, taxRate, taxPercentage
        case discountPercentage, discountPercent, discountValue, minimumCartValue, minCartValue, minimumAmount, couponCode
        case successUrl, successRedirectUrl, failureUrl, failureRedirectUrl
        case paymentMethods, billingMethod
        case isDefaultProfile, isDefault
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let pid = try? container.decode(Int.self, forKey: .profileId) { id = String(pid) }
        else if let pid = try? container.decode(String.self, forKey: .profileId) { id = pid }
        else if let pid = try? container.decode(Int.self, forKey: .profile_id) { id = String(pid) }
        else if let pid = try? container.decode(String.self, forKey: .profile_id) { id = pid }
        else if let pid = try? container.decode(Int.self, forKey: .id) { id = String(pid) }
        else if let pid = try? container.decode(String.self, forKey: .id) { id = pid }
        else { id = UUID().uuidString }
        
        if let pname = try? container.decode(String.self, forKey: .profileName) { name = pname }
        else if let pname = try? container.decode(String.self, forKey: .profile_name) { name = pname }
        else if let pname = try? container.decode(String.self, forKey: .name) { name = pname }
        else if let pname = try? container.decode(String.self, forKey: .campaignName) { name = pname }
        else { name = "Unknown" }
        
        collectEmail = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectEmail)
        collectFullName = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectFullName)
        collectPhoneNumber = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectPhoneNumber)
        collectAddress = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectAddress)
        collectCompanyName = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectCompanyName)
        collectOrderNotes = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectOrderNotes)
        collectTaxInfo = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectTaxInfo)
        collectCryptoRefundAddress = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .collectCryptoRefundAddress)
        
        handlingFeeValue = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .handlingFeeValue)
        handlingFeeType = try? container.decodeIfPresent(String.self, forKey: .handlingFeeType)
        shippingRate = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .shippingRate)
        rateValue = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .rateValue)
        rateType = try? container.decodeIfPresent(String.self, forKey: .rateType)
        taxRate = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .taxRate)
        taxPercentage = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .taxPercentage)
        
        discountPercentage = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .discountPercentage)
        discountPercent = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .discountPercent)
        discountValue = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .discountValue)
        minimumCartValue = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .minimumCartValue)
        minCartValue = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .minCartValue)
        minimumAmount = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .minimumAmount)
        couponCode = try? container.decodeIfPresent(String.self, forKey: .couponCode)
        
        successUrl = try? container.decodeIfPresent(String.self, forKey: .successUrl)
        successRedirectUrl = try? container.decodeIfPresent(String.self, forKey: .successRedirectUrl)
        failureUrl = try? container.decodeIfPresent(String.self, forKey: .failureUrl)
        failureRedirectUrl = try? container.decodeIfPresent(String.self, forKey: .failureRedirectUrl)
        
        paymentMethods = try? container.decodeIfPresent([CPMethod].self, forKey: .paymentMethods)
        billingMethod = try? container.decodeIfPresent([CPMethod].self, forKey: .billingMethod)
        
        if let def = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .isDefaultProfile) {
            isDefaultProfile = def
        } else if let def = try? container.decodeIfPresent(CPAnyCodable.self, forKey: .isDefault) {
            isDefaultProfile = def
        } else {
            isDefaultProfile = nil
        }
    }
}

// MARK: - Catalog

struct CPCatalog: Decodable, Identifiable, Hashable {
    let id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case id, catalogId
        case name, catalogName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let idInt = try? container.decode(Int.self, forKey: .id) { id = idInt }
        else if let idInt = try? container.decode(Int.self, forKey: .catalogId) { id = idInt }
        else if let idString = try? container.decode(String.self, forKey: .id), let idInt = Int(idString) { id = idInt }
        else if let idString = try? container.decode(String.self, forKey: .catalogId), let idInt = Int(idString) { id = idInt }
        else { id = 0 }
        
        if let nameStr = try? container.decode(String.self, forKey: .name) { name = nameStr }
        else if let nameStr = try? container.decode(String.self, forKey: .catalogName) { name = nameStr }
        else { name = "Unknown Catalog" }
    }
}
