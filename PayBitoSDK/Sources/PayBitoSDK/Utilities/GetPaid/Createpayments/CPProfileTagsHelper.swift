import SwiftUI

struct CPProfileTagsHelper {
    static func tag(_ label: String, _ c: Color, _ bg: Color, _ border: Color) -> CTag {
        CTag(label: label, color: c, bg: bg, border: border)
    }
    
    static func tag(_ label: String, _ c: Color) -> CTag {
        CTag(label: label, color: c, bg: c.opacity(0.12), border: c.opacity(0.35))
    }
    
    static let purple = Color(red: 0.55, green: 0.36, blue: 0.96)
    static let indigo = Color(red: 0.39, green: 0.40, blue: 0.95)
    static let green = Color(red: 0.06, green: 0.73, blue: 0.51)
    static let blue = Color(red: 0.23, green: 0.51, blue: 0.95)
    
    static func buildPaymentOptionTags(profileName: String, profiles: [CPProfile]) -> [CTag] {
        guard let profile = profiles.first(where: { $0.name == profileName }) else { return [] }
        let methods = profile.paymentMethods ?? profile.billingMethod ?? []
        let enabled = methods.filter { $0.status?.intValue == 1 }
        
        var tags: [CTag] = []
        for m in enabled {
            let pmId = m.pmId?.intValue ?? m.paymentMethodId?.intValue ?? m.id?.intValue ?? 0
            switch pmId {
            case 1, 7, 8, 9:
                tags.append(tag("Card", indigo, indigo.opacity(0.10), indigo.opacity(0.22)))
            case 2:
                let orange = Color.orange
                tags.append(tag("PayBito Titan", orange, orange.opacity(0.10), orange.opacity(0.22)))
            case 3:
                let em = Color(red: 0.06, green: 0.73, blue: 0.51)
                tags.append(tag("Crypto - Brand", em, em.opacity(0.10), em.opacity(0.22)))
            case 4:
                let teal = Color.teal
                tags.append(tag("Crypto - External", teal, teal.opacity(0.10), teal.opacity(0.22)))
            case 5:
                tags.append(tag("Crypto - Guest", purple, purple.opacity(0.10), purple.opacity(0.22)))
            case 11:
                let purp = Color.purple
                tags.append(tag("PayBito Zenith", purp, purp.opacity(0.10), purp.opacity(0.22)))
            default:
                tags.append(tag(m.name ?? "Method \(pmId)", indigo, indigo.opacity(0.10), indigo.opacity(0.22)))
            }
        }
        return tags
    }
    
    static func buildBuyerInfoTags(profileName: String, profiles: [CPProfile]) -> [CTag] {
        guard let profile = profiles.first(where: { $0.name == profileName }) else { return [] }
        var tags: [CTag] = []
        
        let c = Color(red: 0.55, green: 0.36, blue: 0.96)
        let bg = c.opacity(0.10)
        let border = c.opacity(0.22)
        
        if profile.collectEmail?.intValue == 1 { tags.append(tag("Email", c, bg, border)) }
        if profile.collectFullName?.intValue == 1 { tags.append(tag("Full Name", c, bg, border)) }
        if profile.collectPhoneNumber?.intValue == 1 { tags.append(tag("Phone Number", c, bg, border)) }
        if profile.collectAddress?.intValue == 1 { tags.append(tag("Address", c, bg, border)) }
        if profile.collectCompanyName?.intValue == 1 { tags.append(tag("Company Name", c, bg, border)) }
        if profile.collectOrderNotes?.intValue == 1 { tags.append(tag("Order Notes", c, bg, border)) }
        if profile.collectTaxInfo?.intValue == 1 { tags.append(tag("Tax Info", c, bg, border)) }
        if profile.collectCryptoRefundAddress?.intValue == 1 { tags.append(tag("Crypto Refund Address", c, bg, border)) }
        
        if tags.isEmpty {
            tags.append(tag(profile.name, c, bg, border))
        }
        return tags
    }
    
    static func buildShippingTags(profileName: String, profiles: [CPProfile]) -> [CTag] {
        guard let profile = profiles.first(where: { $0.name == profileName }) else { return [] }
        var tags: [CTag] = []
        
        let c = Color.blue
        let bg = c.opacity(0.10)
        let border = c.opacity(0.22)
        
        let fee = profile.handlingFeeValue?.stringValue ?? profile.shippingRate?.stringValue ?? profile.rateValue?.stringValue
        let type = profile.handlingFeeType ?? profile.rateType ?? "percentage"
        
        if let f = fee, !f.isEmpty {
            let label = type == "percentage" ? "\(f)% Handling Fee" : "$\(f) Shipping"
            tags.append(tag(label, c, bg, border))
        }
        
        let tax = profile.taxRate?.stringValue ?? profile.taxPercentage?.stringValue
        if let t = tax, let val = Double(t), val > 0 {
            tags.append(tag("Tax: \(t)%", Color(red: 0.38, green: 0.65, blue: 0.98), Color.blue.opacity(0.08), Color.blue.opacity(0.18)))
        }
        
        if tags.isEmpty {
            tags.append(tag(profile.name, c, bg, border))
        }
        return tags
    }
    
    static func buildDiscountTags(profileName: String, profiles: [CPProfile]) -> [CTag] {
        guard let profile = profiles.first(where: { $0.name == profileName }) else { return [] }
        let allRules = profiles.filter { $0.name == profile.name }
        
        var tags: [CTag] = []
        let c = Color.green
        
        for rule in allRules {
            let pct = rule.discountPercentage?.stringValue ?? rule.discountPercent?.stringValue ?? rule.discountValue?.stringValue
            let minC = rule.minimumCartValue?.stringValue ?? rule.minCartValue?.stringValue ?? rule.minimumAmount?.stringValue
            
            if let p = pct {
                var lbl = "\(p)% Off"
                if let m = minC, let md = Double(m), md > 0 {
                    lbl += " (Min. $\(m))"
                }
                tags.append(tag(lbl, c, c.opacity(0.10), c.opacity(0.22)))
            }
            if let cc = rule.couponCode, !cc.isEmpty {
                tags.append(tag("Code: \(cc)", Color(red: 0.29, green: 0.87, blue: 0.50), c.opacity(0.08), c.opacity(0.18)))
            }
        }
        
        if tags.isEmpty {
            tags.append(tag(profile.name, c, c.opacity(0.10), c.opacity(0.22)))
        }
        return tags
    }
    
    static func buildRedirectTags(profileName: String, profiles: [CPProfile]) -> [CTag] {
        guard let profile = profiles.first(where: { $0.name == profileName }) else { return [] }
        var tags: [CTag] = []
        
        let s = profile.successUrl ?? profile.successRedirectUrl
        if let s = s, !s.isEmpty {
            let short = String(s.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "").prefix(30))
            let green = Color.green
            tags.append(tag("✓ \(short)\(s.count > 30 ? "…" : "")", green, green.opacity(0.10), green.opacity(0.22)))
        }
        
        let f = profile.failureUrl ?? profile.failureRedirectUrl
        if let f = f, !f.isEmpty {
            let short = String(f.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "").prefix(30))
            let red = Color.red
            tags.append(tag("✗ \(short)\(f.count > 30 ? "…" : "")", red, red.opacity(0.10), red.opacity(0.22)))
        }
        
        if tags.isEmpty {
            let c = Color.gray
            tags.append(tag(profile.name, c, c.opacity(0.10), c.opacity(0.22)))
        }
        return tags
    }
    
    static func buildRewardsTags(profileName: String, profiles: [CPProfile]) -> [CTag] {
        guard let profile = profiles.first(where: { $0.name == profileName }) else { return [] }
        return [tag(profile.name, Color.yellow, Color.yellow.opacity(0.10), Color.yellow.opacity(0.22))]
    }
}
