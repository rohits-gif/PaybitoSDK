
//
//  CreatePaymentViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

// MARK: - Loading State

enum LoadingState: Equatable {
    case idle
    case loading
    case success
    case failure(String)
}

// MARK: - ViewModel

@MainActor
final class CreatePaymentViewModel: ObservableObject {

    // ── Products & Catalogs
    @Published var sections:     [ProductSection] = []
    @Published var allProducts:  [CPProduct]      = []
    @Published var allCatalogs:  [CPCatalog]      = []
    @Published var loadingState: LoadingState     = .idle
    @Published var errorMessage: String?          = nil

    // ── Selection
    @Published var selectedProduct: CPProduct? = nil
    @Published var selectedCatalog: CPCatalog? = nil
    @Published var selectedPrice:   CPPrice?   = nil
    @Published var paymentName:     String     = ""

    // ── Link creation
    @Published var isCreatingLink:   Bool    = false
    @Published var generatedLink:    String? = nil
    @Published var linkError:        String? = nil
    @Published var createdPaymentID: String? = nil
    @Published var createdPaymentURL: String? = nil

    // ── Send email
    @Published var isSendingEmail:  Bool    = false
    @Published var emailSentSuccess: Bool   = false
    @Published var emailError:       String? = nil

    // ── Profiles
    @Published var paymentOptionProfiles: [CPProfile] = []
    @Published var buyerInfoProfiles:     [CPProfile] = []
    @Published var shippingProfiles:      [CPProfile] = []
    @Published var discountProfiles:      [CPProfile] = []
    @Published var redirectProfiles:      [CPProfile] = []
    @Published var rewardsProfiles:       [CPProfile] = []
    
    @Published var customizeRows: [CustomizeRowItem] = CustomizeRowItem.defaultList()

    // MARK: Computed

    var isReadyToCreate: Bool {
        (selectedProduct != nil && selectedPrice != nil) || (selectedCatalog != nil)
    }

    var selectedPriceLabel: String {
        guard let price = selectedPrice,
              let cur = price.currencies.first(where: { $0.default }) ?? price.currencies.first
        else { return "— Select price —" }
        let amt = cur.amount.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", cur.amount)
            : String(format: "%.2f", cur.amount)

        if price.priceType == "recurring", let iv = price.intervalType {
            return "\(cur.currency) \(amt) / \(iv)"
        }
        return "\(cur.currency) \(amt)"
    }

    var availablePrices: [CPPrice] {
        selectedProduct?.prices ?? []
    }

    // MARK: - Fetch Products

    func fetchProducts() {
        guard loadingState != .loading else { return }
        loadingState = .loading
        errorMessage = nil
        debugPrint("🔄 [ViewModel] fetchProducts")

        CreatePaymentService.shared.fetchProducts { [weak self] (productResult: Result<ProductListData, Error>) in
            guard let self else { return }
            switch productResult {
            case .success(let data):
                CreatePaymentService.shared.fetchCatalogs { (catalogResult: Result<[CPCatalog], Error>) in
                    switch catalogResult {
                    case .success(let catalogs):
                        self.allProducts  = data.products
                        self.allCatalogs  = catalogs
                        self.sections     = self.buildSections(from: data.products, catalogs: catalogs)
                        self.loadingState = .success
                        debugPrint("✅ [ViewModel] \(data.products.count) products, \(catalogs.count) catalogs")
                        self.fetchAllProfiles()
                    case .failure(let error):
                        self.allProducts  = data.products
                        self.allCatalogs  = []
                        self.sections     = self.buildSections(from: data.products, catalogs: [])
                        self.loadingState = .success
                        debugPrint("⚠️ [ViewModel] Catalogs error: \(error.localizedDescription)")
                        self.fetchAllProfiles()
                    }
                }
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.loadingState = .failure(error.localizedDescription)
                debugPrint("❌ [ViewModel] \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Fetch Profiles
    
    private func fetchAllProfiles() {
        let mid = UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
        let base = "https://service.hashcashconsultants.com/billbitcoins-v2"
        
        let service = CreatePaymentService.shared
        
        service.fetchProfiles(url: "\(base)/billing-profile/\(mid)") { [weak self] res in
            if case .success(let data) = res { self?.paymentOptionProfiles = data; self?.syncCustomizeRows(&(self!.customizeRows)) }
        }
        service.fetchProfiles(url: "\(base)/buyer-information/\(mid)") { [weak self] res in
            if case .success(let data) = res { self?.buyerInfoProfiles = data; self?.syncCustomizeRows(&(self!.customizeRows)) }
        }

        service.fetchProfiles(url: "\(base)/api/merchants/\(mid)/shipping-profiles") { [weak self] res in
            if case .success(let data) = res { self?.shippingProfiles = data; self?.syncCustomizeRows(&(self!.customizeRows)) }
        }
        service.fetchProfiles(url: "\(base)/shopping/discounts?merchantId=\(mid)") { [weak self] res in
            if case .success(let data) = res { self?.discountProfiles = data; self?.syncCustomizeRows(&(self!.customizeRows)) }
        }
        service.fetchProfiles(url: "\(base)/redirect-templates?merchantId=\(mid)") { [weak self] res in
            if case .success(let data) = res { self?.redirectProfiles = data; self?.syncCustomizeRows(&(self!.customizeRows)) }
        }
        service.fetchProfiles(url: "\(base)/campaigns/merchant?merchantId=\(mid)&status=active") { [weak self] res in
            if case .success(let data) = res { self?.rewardsProfiles = data; self?.syncCustomizeRows(&(self!.customizeRows)) }
        }
    }

    func syncCustomizeRows(_ rows: inout [CustomizeRowItem]) {
        func defaultProfileName(for profiles: [CPProfile]) -> String? {
            return profiles.first(where: { 
                $0.isDefaultProfile?.intValue == 1 || $0.isDefaultProfile?.stringValue == "true" 
            })?.name
        }

        for i in rows.indices {
            switch rows[i].key {
            case "paymentOptions":
                rows[i].options = ["— Sys Default —"] + paymentOptionProfiles.map { $0.name }
                if rows[i].selectedOption == nil, let def = defaultProfileName(for: paymentOptionProfiles) {
                    rows[i].selectedOption = def
                }
            case "buyerInfo":
                rows[i].options = ["— Sys Default —"] + buyerInfoProfiles.map { $0.name }
                if rows[i].selectedOption == nil, let def = defaultProfileName(for: buyerInfoProfiles) {
                    rows[i].selectedOption = def
                }
            case "shipping":
                rows[i].options = ["— Sys Default —"] + shippingProfiles.map { $0.name }
                if rows[i].selectedOption == nil, let def = defaultProfileName(for: shippingProfiles) {
                    rows[i].selectedOption = def
                }
            case "discounts":
                rows[i].options = ["— Sys Default —"] + discountProfiles.map { $0.name }
                if rows[i].selectedOption == nil, let def = defaultProfileName(for: discountProfiles) {
                    rows[i].selectedOption = def
                }
            case "redirects":
                rows[i].options = ["— Sys Default —"] + redirectProfiles.map { $0.name }
                if rows[i].selectedOption == nil, let def = defaultProfileName(for: redirectProfiles) {
                    rows[i].selectedOption = def
                }
            case "rewards":
                rows[i].options = ["— No Campaign —"] + rewardsProfiles.map { $0.name }
                if rows[i].selectedOption == nil, let def = defaultProfileName(for: rewardsProfiles) {
                    rows[i].selectedOption = def
                }
            default: break
            }
            
            // Re-trigger tags update if we auto-selected something
            if rows[i].selectedOption != nil {
                updateCustomizeRowSelection(at: i, option: rows[i].selectedOption)
            }
        }
    }
    
    func updateCustomizeRowSelection(at index: Int, option: String?) {
        customizeRows[index].selectedOption = option
        let key = customizeRows[index].key
        
        guard let opt = option else {
            // Reset to default tags if cleared
            customizeRows[index].tags = CustomizeRowItem.defaultList().first(where: { $0.key == key })?.tags ?? []
            return
        }
        
        switch key {
        case "paymentOptions":
            customizeRows[index].tags = CPProfileTagsHelper.buildPaymentOptionTags(profileName: opt, profiles: paymentOptionProfiles)
        case "buyerInfo":
            customizeRows[index].tags = CPProfileTagsHelper.buildBuyerInfoTags(profileName: opt, profiles: buyerInfoProfiles)
        case "shipping":
            customizeRows[index].tags = CPProfileTagsHelper.buildShippingTags(profileName: opt, profiles: shippingProfiles)
        case "discounts":
            customizeRows[index].tags = CPProfileTagsHelper.buildDiscountTags(profileName: opt, profiles: discountProfiles)
        case "redirects":
            customizeRows[index].tags = CPProfileTagsHelper.buildRedirectTags(profileName: opt, profiles: redirectProfiles)
        case "rewards":
            customizeRows[index].tags = CPProfileTagsHelper.buildRewardsTags(profileName: opt, profiles: rewardsProfiles)
        default: break
        }
    }

    // MARK: - Select Product

    func selectProduct(_ product: CPProduct) {
        debugPrint("👆 [ViewModel] select: \(product.name)")
        selectedCatalog = nil
        selectedProduct = product
        selectedPrice   = product.prices.first(where: { $0.default }) ?? product.prices.first
    }

    func selectCatalog(_ catalog: CPCatalog) {
        debugPrint("👆 [ViewModel] select catalog: \(catalog.name)")
        selectedProduct = nil
        selectedPrice = nil
        selectedCatalog = catalog
    }

    func clearSelection() {
        selectedProduct = nil
        selectedPrice   = nil
        selectedCatalog = nil
    }

    // MARK: - Create Link
    // onSuccess fires on the main thread once ID + URL are ready

    func createPaymentLink(onSuccess: @escaping () -> Void) {
        guard (selectedProduct != nil && selectedPrice != nil) || selectedCatalog != nil else {
            debugPrint("⚠️ [ViewModel] createPaymentLink — missing product/price/catalog")
            return
        }
        isCreatingLink    = true
        linkError         = nil
        generatedLink     = nil
        createdPaymentID  = nil
        createdPaymentURL = nil
        
        let paymentOptionName = customizeRows.first(where: { $0.key == "paymentOptions" })?.selectedOption
        let feeHandlingName   = customizeRows.first(where: { $0.key == "feeHandling" })?.selectedOption
        let buyerInfoName     = customizeRows.first(where: { $0.key == "buyerInfo" })?.selectedOption
        let shippingName      = customizeRows.first(where: { $0.key == "shipping" })?.selectedOption
        let discountName      = customizeRows.first(where: { $0.key == "discounts" })?.selectedOption
        let redirectName      = customizeRows.first(where: { $0.key == "redirects" })?.selectedOption
        
        let billingId = paymentOptionProfiles.first(where: { $0.name == paymentOptionName })?.id ?? "0"
        let buyerProfileId = buyerInfoProfiles.first(where: { $0.name == buyerInfoName })?.id ?? "0"
        let shippingProfileId = shippingProfiles.first(where: { $0.name == shippingName })?.id ?? "0"
        let redirectId = redirectProfiles.first(where: { $0.name == redirectName })?.id ?? "0"
        let discountProfileName = discountProfiles.first(where: { $0.name == discountName })?.name ?? ""
        
        var isProcessingFeeApplied = 0
        if feeHandlingName == "Merchant Pays" { isProcessingFeeApplied = 1 }
        else if feeHandlingName == "Customer Pays" { isProcessingFeeApplied = 2 }

        debugPrint("🔗 [ViewModel] create → product: \(selectedProduct?.productId ?? "nil"), catalog: \(selectedCatalog?.id ?? 0)")

        CreatePaymentService.shared.createPaymentLink(
            productId: selectedProduct?.productId,
            priceId:   selectedPrice?.priceId,
            catalogId: selectedCatalog?.id,
            name:      paymentName.isEmpty ? nil : paymentName,
            shippingProfileId: Int(shippingProfileId) ?? 0,
            buyerProfileId: Int(buyerProfileId) ?? 0,
            discountProfileName: discountProfileName,
            billingId: Int(billingId) ?? 0,
            isProcessingFeeApplied: isProcessingFeeApplied,
            redirectId: Int(redirectId) ?? 0
        ) { [weak self] (result: Result<CreatePaymentResult, Error>) in
            guard let self else { return }
            self.isCreatingLink = false
            switch result {
            case .success(let res):
                self.createdPaymentID  = res.id
                self.createdPaymentURL = res.url
                self.generatedLink     = res.url
                debugPrint("✅ [ViewModel] id=\(res.id)  url=\(res.url)")
                onSuccess()          // ← navigate NOW, no arbitrary delay
            case .failure(let error):
                self.linkError = error.localizedDescription
                debugPrint("❌ [ViewModel] \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Regenerate Link (re-uses same product/price)

    func regeneratePaymentLink(onSuccess: @escaping () -> Void) {
        createPaymentLink(onSuccess: onSuccess)
    }

    // MARK: - Send Email

    /// Parses a comma-separated email string and calls the send-payment-link API.
    func sendPaymentLink(emailsRaw: String, onSuccess: @escaping () -> Void, onFailure: @escaping (String) -> Void) {
        // Parse + validate emails
        let emails = emailsRaw
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !emails.isEmpty else {
            onFailure("Enter at least one email address.")
            return
        }

        guard let paymentId  = createdPaymentID,
              let paymentURL = createdPaymentURL else {
            onFailure("No payment link available. Create a link first.")
            return
        }

        isSendingEmail  = true
        emailSentSuccess = false
        emailError       = nil

        CreatePaymentService.shared.sendPaymentLink(
            paymentOrderId: paymentId,
            paymentLink:    paymentURL,
            emails:         emails
        ) { [weak self] result in
            guard let self else { return }
            self.isSendingEmail = false
            switch result {
            case .success:
                self.emailSentSuccess = true
                debugPrint("✅ [ViewModel] email sent to \(emails)")
                onSuccess()
            case .failure(let error):
                self.emailError = error.localizedDescription
                debugPrint("❌ [ViewModel] sendEmail: \(error.localizedDescription)")
                onFailure(error.localizedDescription)
            }
        }
    }

    // MARK: - Retry

    func retry() { fetchProducts() }

    // MARK: - Private

    private func buildSections(from products: [CPProduct], catalogs: [CPCatalog]) -> [ProductSection] {
        var bycat: [Int: [CPProduct]] = [:]
        
        for p in products {
            bycat[p.catalogId, default: []].append(p)
        }
        
        var result: [ProductSection] = []
        for (cid, items) in bycat {
            var catalogName = "Products"
            if cid != 0 {
                catalogName = catalogs.first(where: { $0.id == cid })?.name ?? "Products"
            }
            result.append(ProductSection(title: catalogName.uppercased(), items: items))
        }
        
        // Sort sections alphabetically so order is consistent
        result.sort { $0.title < $1.title }
        
        return result
    }
}









