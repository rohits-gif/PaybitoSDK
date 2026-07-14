//
//  Editcatalogueviewmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  EditCatalogueViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

// ============================================================
// MARK: - Self-contained models (ECV-prefixed, no conflicts)
// ============================================================

struct ECVProductList: Decodable {
    let status: Bool
    let data:   ECVProductListData
}

struct ECVProductListData: Decodable {
    let total:    Int
    let products: [ECVProduct]
}

struct ECVProduct: Decodable, Identifiable {
    let productId: String
    let name:      String
    let status:    String
    let prices:    [ECVPrice]

    var id: String { productId }

    var oneTimePrices: [ECVPrice] {
        prices.filter { $0.priceType == "one-time" }
    }
}

struct ECVPrice: Decodable, Identifiable {
    let priceId:    Int
    let priceType:  String
    let currencies: [ECVCurrency]

    var id: Int { priceId }

    var displayLabel: String {
        let amounts = currencies
            .map { "\($0.currency) \(String(format: "%.2f", $0.amount))" }
            .joined(separator: " / ")
        return "Price #\(priceId)  ·  \(amounts)"
    }

    var currencyCodes: [String] {
        currencies.map { $0.currency }
    }
}

struct ECVCurrency: Decodable {
    let currency: String
    let amount:   Double
    let `default`: Bool
}

// ============================================================
// MARK: - EditCatalogueViewModel
// ============================================================

@MainActor
final class EditCatalogueViewModel: ObservableObject {

    // ── Published state ───────────────────────────────────────

    @Published var products: [ECVProduct] = []
    @Published var pricesForSelectedProduct: [ECVPrice] = []

    @Published var isLoading   = false   // products fetch
    @Published var isAdding    = false   // add-product-to-catalogue call
    @Published var isUpdating  = false   // PUT edit catalogue

    @Published var errorMessage:   String? = nil
    @Published var successMessage: String? = nil

    @Published var didUpdateSuccessfully = false

    // ── Private ───────────────────────────────────────────────

    private let service = EditCatalogueService.shared

    // ════════════════════════════════════════════════════════
    // MARK: Load Products  (GET)
    // ════════════════════════════════════════════════════════

    func loadProducts() {
        guard !isLoading else { return }
        isLoading    = true
        errorMessage = nil

        debugPrint("[EditCatalogueViewModel] loadProducts()")

        service.fetchProducts() { [weak self] (result: Swift.Result<[ECVProduct], Error>) in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let list):
                    self.products = list.filter {
                        $0.status == "ACTIVE" && !$0.oneTimePrices.isEmpty
                    }
                    debugPrint("[EditCatalogueViewModel] Products ready: \(self.products.count)")

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[EditCatalogueViewModel] ❌ loadProducts: \(error)")
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: Selection helpers
    // ════════════════════════════════════════════════════════

    func selectProduct(_ product: ECVProduct) {
        pricesForSelectedProduct = product.oneTimePrices
        debugPrint("[EditCatalogueViewModel] Product selected: \(product.name) — \(pricesForSelectedProduct.count) price(s)")
    }

    func clearProductSelection() {
        pricesForSelectedProduct = []
    }

    func product(for productId: String) -> ECVProduct? {
        products.first { $0.productId == productId }
    }

    func displayLabel(for price: ECVPrice) -> String { price.displayLabel }
    func currencyCodes(for price: ECVPrice) -> [String] { price.currencyCodes }

    func loadCatalogueProducts(
        catalogId: Int,
        onSuccess: @escaping ([PCCatalogProductSelection]) -> Void
    ) {
        isLoading = true
        errorMessage = nil
        
        PCCatalogueService.shared.getCatalogueProducts(catalogId: catalogId) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let selections):
                    onSuccess(selections)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[EditCatalogueViewModel] ❌ failed to load catalogue products: \(error)")
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: Add Product to Catalogue  (POST)
    // POST /shopping/catalogs/add-product-price
    //   ?catalogId=&productId=&priceId=&action=ADD
    // ════════════════════════════════════════════════════════

    /// Calls the API then invokes onSuccess with the confirmed row data
    /// so the view can append it to the table only after API confirmation.
    func addProductToCatalogue(
        catalogId:   Int,
        productId:   String,
        priceId:     Int,
        productName: String,
        priceLabel:  String,
        currencies:  [String],
        onSuccess:   @escaping (_ productName: String,
                                _ priceLabel:  String,
                                _ currencies:  [String]) -> Void
    ) {
        guard !isAdding else { return }
        isAdding     = true
        errorMessage = nil

        debugPrint("[EditCatalogueViewModel] addProductToCatalogue(catalogId:\(catalogId) productId:\(productId) priceId:\(priceId))")

        service.addProductToCatalogue(
            catalogId:  catalogId,
            productId:  productId,
            priceId:    priceId
        ) { [weak self] (result: Swift.Result<AddProductToCatalogueResponse, Error>) in
            guard let self else { return }
            Task { @MainActor in
                self.isAdding = false
                switch result {
                case .success(let response):
                    if response.success {
                        debugPrint("[EditCatalogueViewModel] ✅ Product added — returnId:\(response.returnId)")
                        self.successMessage = response.message
                        onSuccess(productName, priceLabel, currencies)
                    } else {
                        // API returned 200 but success=false (e.g. "already added")
                        debugPrint("[EditCatalogueViewModel] ⚠️ \(response.message)")
                        self.errorMessage = response.message
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[EditCatalogueViewModel] ❌ addProductToCatalogue: \(error)")
                }
            }
        }
    }

    func removeProductFromCatalogue(
        catalogId: Int,
        productId: String,
        priceId:   Int,
        onSuccess: @escaping () -> Void
    ) {
        guard !isAdding else { return }
        isAdding     = true
        errorMessage = nil

        debugPrint("[EditCatalogueViewModel] removeProductFromCatalogue(catalogId:\(catalogId) productId:\(productId) priceId:\(priceId))")

        service.addProductToCatalogue(
            catalogId: catalogId,
            productId: productId,
            priceId:   priceId,
            action:    "DELETE"
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isAdding = false
                switch result {
                case .success(let response):
                    if response.success {
                        debugPrint("[EditCatalogueViewModel] ✅ Product removed")
                        self.successMessage = response.message
                        onSuccess()
                    } else {
                        self.errorMessage = response.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[EditCatalogueViewModel] ❌ removeProductFromCatalogue: \(error)")
                }
            }
        }
    }
    // ════════════════════════════════════════════════════════
    // MARK: Update Catalogue  (PUT)
    // ════════════════════════════════════════════════════════

    func updateCatalogue(
        catalogId:   Int,
        name:        String,
        description: String,
        onSuccess:   @escaping () -> Void = {}
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Catalogue name cannot be empty."
            debugPrint("[EditCatalogueViewModel] ⚠️ Save blocked — name is empty")
            return
        }

        isUpdating   = true
        errorMessage = nil

        debugPrint("[EditCatalogueViewModel] updateCatalogue(catalogId:\(catalogId) name:\"\(trimmed)\")")

        service.editCatalogue(
            catalogId:   catalogId,
            name:        trimmed,
            description: description
        ) { [weak self] (result: Swift.Result<EditCatalogueData, Error>) in
            guard let self else { return }
            Task { @MainActor in
                self.isUpdating = false
                switch result {
                case .success(let data):
                    debugPrint("[EditCatalogueViewModel] ✅ Updated — id:\(data.id) name:\"\(data.catalogName)\"")
                    self.didUpdateSuccessfully = true
                    onSuccess()

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[EditCatalogueViewModel] ❌ updateCatalogue: \(error)")
                }
            }
        }
    }
}

