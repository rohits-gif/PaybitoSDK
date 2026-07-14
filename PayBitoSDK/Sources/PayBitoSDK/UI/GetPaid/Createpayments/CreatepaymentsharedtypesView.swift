//
//  CreatepaymentsharedtypesView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 06/05/26.
//

import SwiftUI

// MARK: - CTag  (public — used in CreatePaymentView + any customize row)

public struct CTag: Identifiable {
    public let id     = UUID()
    public let label:  String
    public let color:  Color
    public let bg:     Color
    public let border: Color

    public init(label: String, color: Color, bg: Color, border: Color) {
        self.label  = label
        self.color  = color
        self.bg     = bg
        self.border = border
    }
}

// MARK: - OutputType  (public — used in ReadyCard)

public enum OutputType: String, CaseIterable {
    case link      = "Link"
    case button    = "Button"
    case qrCode    = "QR Code"
    case hyperlink = "Hyperlink"
}

// MARK: - ConfigItem  (public — used in ConfigCard)

public struct ConfigItem: Identifiable {
    public let id    = UUID()
    public let title: String
    public var isChecked: Bool
    public var badge: String?

    public init(title: String, isChecked: Bool, badge: String? = nil) {
        self.title     = title
        self.isChecked = isChecked
        self.badge     = badge
    }
}

// MARK: - CustomizeRowItem  (public — used in CustomizeCard)

public struct CustomizeRowItem: Identifiable {
    public let id      = UUID()
    public let key:    String
    public let label:  String
    public var options: [String]
    public var selectedOption: String?
    public var tags:   [CTag]
    public var redirectPath: String?
    public var btnLabel: String?
    public var useRedirectIcon: Bool

    public init(key: String, label: String, options: [String],
                selectedOption: String? = nil, tags: [CTag] = [],
                redirectPath: String? = nil, btnLabel: String? = nil, useRedirectIcon: Bool = false) {
        self.key            = key
        self.label          = label
        self.options        = options
        self.selectedOption = selectedOption
        self.tags           = tags
        self.redirectPath   = redirectPath
        self.btnLabel       = btnLabel
        self.useRedirectIcon = useRedirectIcon
    }
}

// MARK: - Default Data Factories
//  Using static factory methods keeps the compiler happy —
//  avoids "expression too complex" on @State inline array literals.

extension ConfigItem {
    /// Default configuration checklist for Create Payment
    static func defaultList() -> [ConfigItem] {
        [
            ConfigItem(title: "Product Catalogue", isChecked: false),
            ConfigItem(title: "Payment Options",   isChecked: false),
            ConfigItem(title: "Fee Handling",      isChecked: true, badge: "Merchant Pays"),
            ConfigItem(title: "Buyer Information", isChecked: false),
            ConfigItem(title: "Shipping",          isChecked: false),
            ConfigItem(title: "Discounts",         isChecked: false),
            ConfigItem(title: "Rewards",           isChecked: false),
            ConfigItem(title: "Redirects",         isChecked: false),
        ]
    }
}

extension CustomizeRowItem {
    /// Default customize rows for Create Payment
    static func defaultList() -> [CustomizeRowItem] {
        let purple = Color(red: 0.45, green: 0.35, blue: 0.90)
        let violet = Color(red: 0.55, green: 0.36, blue: 0.96)
        let blue   = Color(red: 0.23, green: 0.51, blue: 0.95)
        let yellow = Color(red: 0.85, green: 0.65, blue: 0.15)
        let green  = Color(red: 0.06, green: 0.73, blue: 0.51)
        let red    = Color(red: 0.94, green: 0.27, blue: 0.27)

        func tag(_ label: String, _ c: Color) -> CTag {
            CTag(label: label, color: c, bg: c.opacity(0.12), border: c.opacity(0.35))
        }

        return [
            CustomizeRowItem(
                key: "paymentOptions", label: "Payment Options",
                options: ["— Sys Default —", "Stripe", "PayPal", "Crypto"],
                redirectPath: "/payments/billing", btnLabel: "Add Payment Option"
            ),
            CustomizeRowItem(
                key: "feeHandling", label: "Fee Handling",
                options: ["None", "Customer Pays", "Merchant Pays"],
                selectedOption: "Customer Pays",
                tags: [tag("Customer Pays", purple)],
                redirectPath: "/payments/fees-handling", btnLabel: "Configure Fees", useRedirectIcon: true
            ),
            CustomizeRowItem(
                key: "buyerInfo", label: "Buyer Info",
                options: ["— Sys Default —", "Profile A", "Profile B"],
                tags: [tag("Collect Email", violet)],
                redirectPath: "/payments/buyer-information", btnLabel: "Add Buyer Info"
            ),
            CustomizeRowItem(
                key: "shipping", label: "Shipping",
                options: ["— Sys Default —", "Standard", "Express"],
                tags: [tag("No Shipping Rate", blue), tag("No Tax Rate", blue)],
                redirectPath: "/payments/shipping-handling", btnLabel: "Add Shipping"
            ),
            CustomizeRowItem(
                key: "discounts", label: "Discounts",
                options: ["— Sys Default —", "10% Off", "20% Off"],
                redirectPath: "/payments/discounting-profile", btnLabel: "Add Discount"
            ),
            CustomizeRowItem(
                key: "redirects", label: "Redirects",
                options: ["— Sys Default —", "Test", "Production"],
                selectedOption: "Test",
                tags: [tag("✓ test.com/success", green), tag("✗ test.com/failure", red)],
                redirectPath: "/payments/redirects-management", btnLabel: "Add Redirect"
            ),
        ]
    }
}
