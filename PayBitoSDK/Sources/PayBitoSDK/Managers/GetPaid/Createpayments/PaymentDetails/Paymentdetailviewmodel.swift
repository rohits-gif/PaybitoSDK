
import Foundation

// MARK: - View State

enum ViewPaymentDetailState: Equatable {
    case idle
    case loading
    case success
    case failure(String)

    static func == (lhs: ViewPaymentDetailState, rhs: ViewPaymentDetailState) -> Bool {
        switch (lhs, rhs) {
        case (.idle,    .idle),
             (.loading, .loading),
             (.success, .success):               return true
        case (.failure(let a), .failure(let b)): return a == b
        default:                                 return false
        }
    }
}

// MARK: - Flat Display Model (UI-ready, no optionals)

struct PaymentDetailDisplayModel {
    let paymentId:            String   // e.g. "PAY_pcn2942"
    let pcn:                  String   // e.g. "PCN2942"
    let date:                 String   // today formatted
    let paymentLink:          String   // checkout URL

    let productName:            String?
    let productAmountFormatted: String?
    let isSubscription:         Bool
    let subscriptionInterval:   String?

    var hasProduct: Bool { productName != nil }

    let billingProfileName: String?
    let billingType:        String?
    let paymentMethods:     [String]
    let paymentCurrencies:  [String]

    let feeHandling: String

    let buyerProfileName: String?
    let collectedFields:  [String]

    let shippingProfileName: String?
    let shippingHandlingFee: Double?
    let shippingTaxRate:     Double?

    let discountProfileName: String?
    let discountPercentage:  Double?
    let discountMinCartValue: Double?

    let redirectTemplateName: String?
    let successURL:           String?
    let failureURL:           String?

    var hasBilling:  Bool { billingProfileName != nil }
    var hasBuyer:    Bool { buyerProfileName != nil }
    var hasShipping: Bool { shippingProfileName != nil }
    var hasDiscount: Bool { discountProfileName != nil }
    var hasRedirect: Bool { redirectTemplateName != nil }
}

// MARK: - ViewModel

@MainActor
final class ViewPaymentDetailViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var state:        ViewPaymentDetailState      = .idle
    @Published private(set) var displayModel: PaymentDetailDisplayModel?  = nil

    // MARK: - Raw response (available if needed)
    private(set) var rawResponse: ViewPaymentDetailResponse? = nil

    // MARK: - Fetch

    func fetchDetail(pcn: String, merchantId: Int) {
        guard state != .loading else { return }
        state = .loading

        // Resolve merchantId — prefer passed value, fall back to UserDefaults
        let resolvedMerchantId: Int
        if merchantId > 0 {
            resolvedMerchantId = merchantId
        } else if let stored = UserDefaults.standard.string(forKey: "Bmerchant_id"),
                  let parsed = Int(stored), parsed > 0 {
            resolvedMerchantId = parsed
        } else {
            debugPrint("🔴 [ViewPaymentDetailViewModel] merchantId unavailable")
            state = .failure("Merchant ID not available. Please log in again.")
            return
        }

        debugPrint("🔷 [ViewPaymentDetailViewModel] fetchDetail pcn:\(pcn) merchantId:\(resolvedMerchantId)")

        ViewPaymentDetailService.shared.fetchPaymentDetail(
            id:         pcn,
            merchantId: resolvedMerchantId
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let response):
                    self.rawResponse  = response
                    self.displayModel = self.map(response: response, pcn: pcn)
                    self.state        = .success
                    self.logDisplayModel()
                    
                    // Fetch broker domain asynchronously and update the link
                    ViewPaymentDetailService.shared.fetchBrokerDomain { [weak self] domain in
                        guard let self = self, let domain = domain else { return }
                        Task { @MainActor in
                            if let old = self.displayModel {
                                let cleanDomain = domain.hasSuffix("/") ? domain : domain + "/"
                                let checkoutBase = "\(cleanDomain)payments/merchant/checkout/"
                                let newLink = "\(checkoutBase)\(pcn)"
                                
                                self.displayModel = PaymentDetailDisplayModel(
                                    paymentId: old.paymentId,
                                    pcn: old.pcn,
                                    date: old.date,
                                    paymentLink: newLink,
                                    productName: old.productName,
                                    productAmountFormatted: old.productAmountFormatted,
                                    isSubscription: old.isSubscription,
                                    subscriptionInterval: old.subscriptionInterval,
                                    billingProfileName: old.billingProfileName,
                                    billingType: old.billingType,
                                    paymentMethods: old.paymentMethods,
                                    paymentCurrencies: old.paymentCurrencies,
                                    feeHandling: old.feeHandling,
                                    buyerProfileName: old.buyerProfileName,
                                    collectedFields: old.collectedFields,
                                    shippingProfileName: old.shippingProfileName,
                                    shippingHandlingFee: old.shippingHandlingFee,
                                    shippingTaxRate: old.shippingTaxRate,
                                    discountProfileName: old.discountProfileName,
                                    discountPercentage: old.discountPercentage,
                                    discountMinCartValue: old.discountMinCartValue,
                                    redirectTemplateName: old.redirectTemplateName,
                                    successURL: old.successURL,
                                    failureURL: old.failureURL
                                )
                            }
                        }
                    }
                case .failure(let error):
                    debugPrint("🔴 [ViewPaymentDetailViewModel] error: \(error.localizedDescription)")
                    self.state = .failure(error.localizedDescription)
                }
            }
        }
    }
    // MARK: - Reset (call on sheet dismiss)

    func reset() {
        debugPrint("🔷 [ViewPaymentDetailViewModel] reset")
        state        = .idle
        displayModel = nil
        rawResponse  = nil
    }

    // MARK: - Map Response → DisplayModel

    private func map(response: ViewPaymentDetailResponse, pcn: String) -> PaymentDetailDisplayModel {
        let product  = response.primaryProduct
        let billing  = response.defaultBilling
        let buyer    = response.defaultBuyer
        let shipping = response.shippingProfiles?.first
        let discount = response.discounts?.first
        let redirect = response.defaultRedirect

        let df = DateFormatter()
        df.dateFormat = "MMM dd, yyyy"
        let dateStr = df.string(from: Date())

        let rawDomain = UserDefaults.standard.string(forKey: "paybitoURL") ?? ""
        let domain = rawDomain.isEmpty ? "https://trade.paybito.com" : rawDomain
        let base = domain.hasSuffix("/") ? domain : domain + "/"
        let link = base + "payments/merchant/checkout/\(pcn)"
        let payId = "PAY_\(pcn.lowercased().replacingOccurrences(of: "pcn", with: ""))"

        return PaymentDetailDisplayModel(
            paymentId:            payId,
            pcn:                  pcn,
            date:                 dateStr,
            paymentLink:          link,
            productName:          product?.name,
            productAmountFormatted: product?.formattedAmount,
            isSubscription:       product?.isSubscription ?? false,
            subscriptionInterval: product?.intervalLabel,
            billingProfileName:   billing?.profileName,
            billingType:          billing?.billingType,
            paymentMethods:       billing?.billingMethod?.compactMap { $0.methodName } ?? [],
            paymentCurrencies:    billing?.currencies?.compactMap { $0.currency }     ?? [],
            feeHandling:          response.feeHandlingText,
            buyerProfileName:     buyer?.profileName,
            collectedFields:      buyer?.collectedFields ?? [],
            shippingProfileName:  shipping?.profileName,
            shippingHandlingFee:  shipping?.handlingFeeValue,
            shippingTaxRate:      shipping?.taxRate,
            discountProfileName:  discount?.profileName,
            discountPercentage:   discount?.discountPercentage,
            discountMinCartValue: discount?.minimumCartValue,
            redirectTemplateName: redirect?.templateName,
            successURL:           redirect?.successUrl,
            failureURL:           redirect?.failureUrl
        )
    }

    // MARK: - Debug Log

    private func logDisplayModel() {
        guard let m = displayModel else { return }
        debugPrint("✅ [ViewPaymentDetailViewModel] ── DisplayModel ──")
        debugPrint("   paymentId   : \(m.paymentId)")
        debugPrint("   pcn         : \(m.pcn)")
        debugPrint("   product     : \(m.productName) \(m.productAmountFormatted)")
        debugPrint("   subscription: \(m.isSubscription) \(m.subscriptionInterval ?? "—")")
        debugPrint("   billing     : \(m.billingProfileName) | \(m.billingType)")
        debugPrint("   methods     : \(m.paymentMethods)")
        debugPrint("   currencies  : \(m.paymentCurrencies)")
        debugPrint("   fee         : \(m.feeHandling)")
        debugPrint("   buyer       : \(m.buyerProfileName) collects:\(m.collectedFields)")
        debugPrint("   shipping    : \(m.hasShipping) | discount: \(m.hasDiscount)")
        debugPrint("   redirect    : \(m.redirectTemplateName)")
        debugPrint("   successURL  : \(m.successURL)")
        debugPrint("   failureURL  : \(m.failureURL)")
        debugPrint("✅ ─────────────────────────────────────────────")
    }
}
