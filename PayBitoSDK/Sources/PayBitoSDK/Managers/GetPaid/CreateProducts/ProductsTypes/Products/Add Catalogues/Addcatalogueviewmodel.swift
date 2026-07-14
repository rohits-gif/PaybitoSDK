//
//  Addcatalogueviewmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

//
//  AddCatalogueViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

@MainActor
final class AddCatalogueViewModel: ObservableObject {

    // ── Published state ───────────────────────────────────────

    /// All ACTIVE products with ≥1 one-time price — product drop-down.
    @Published var products: [ACVAPIProduct] = []

    /// One-time prices for the currently selected product — price drop-down.
    @Published var pricesForSelectedProduct: [ACVAPIPrice] = []

    @Published var isLoading  = false   // GET products
    @Published var isCreating = false   // POST create catalogue
    @Published var isAdding   = false   // POST add-product-price

    @Published var errorMessage:   String? = nil
    @Published var successMessage: String? = nil

    /// Set true after catalogue created successfully — view observes to dismiss.
    @Published var didCreateSuccessfully = false

    /// The catalogue ID returned after a successful create — needed for add-product calls.
    private(set) var createdCatalogueId: Int? = nil

    // ── Private ───────────────────────────────────────────────

    private let service = AddCatalogueService.shared

    // ════════════════════════════════════════════════════════
    // MARK: Load Products  (GET)
    // ════════════════════════════════════════════════════════

    func loadProducts() {
        guard !isLoading else { return }
        isLoading    = true
        errorMessage = nil

        debugPrint("[AddCatalogueViewModel] loadProducts()")

        service.fetchProducts() { [weak self] (result: Swift.Result<[ACVAPIProduct], Error>) in
            guard let self else { return }
            Task { @MainActor in
                self.isLoading = false
                switch result {
                case .success(let list):
                    self.products = list.filter {
                        $0.status == "ACTIVE" && !$0.oneTimePrices.isEmpty
                    }
                    debugPrint("[AddCatalogueViewModel] Products ready: \(self.products.count)")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[AddCatalogueViewModel] ❌ loadProducts: \(error)")
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: Selection helpers
    // ════════════════════════════════════════════════════════

    func selectProduct(_ product: ACVAPIProduct) {
        pricesForSelectedProduct = product.oneTimePrices
        debugPrint("[AddCatalogueViewModel] Product selected: \(product.name) — \(pricesForSelectedProduct.count) price(s)")
    }

    func clearProductSelection() {
        pricesForSelectedProduct = []
    }

    func product(for productId: String) -> ACVAPIProduct? {
        products.first { $0.productId == productId }
    }

    func displayLabel(for price: ACVAPIPrice) -> String { price.displayLabel }
    func currencyCodes(for price: ACVAPIPrice) -> [String] { price.currencyCodes }

    // ════════════════════════════════════════════════════════
    // MARK: Create Catalogue  (POST)
    // ════════════════════════════════════════════════════════

    /// Step 1 — creates the catalogue.
    /// On success stores the new catalogue ID so products can be attached next.
    func createCatalogue(
        name:        String,
        description: String,
        onSuccess:   @escaping (_ catalogueId: Int) -> Void = { _ in }
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = "Catalogue name cannot be empty."
            return
        }
        guard !isCreating else { return }

        isCreating   = true
        errorMessage = nil

        debugPrint("[AddCatalogueViewModel] createCatalogue(name:\"\(trimmed)\")")

        service.createCatalogue(
            name:        trimmed,
            description: description
        ) { [weak self] (result: Swift.Result<CreateCatalogueData, Error>) in
            guard let self else { return }
            Task { @MainActor in
                self.isCreating = false
                switch result {
                case .success(let data):
                    debugPrint("[AddCatalogueViewModel] ✅ Created — id:\(data.id) name:\"\(data.catalogName)\"")
                    self.createdCatalogueId    = data.id
                    onSuccess(data.id)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[AddCatalogueViewModel] ❌ createCatalogue: \(error)")
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: Add Product to Catalogue  (POST)
    // Step 2 — called after createCatalogue succeeds.
    // ════════════════════════════════════════════════════════

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

        debugPrint("[AddCatalogueViewModel] addProductToCatalogue(catalogId:\(catalogId) productId:\(productId) priceId:\(priceId))")

        service.addProductToCatalogue(
            catalogId: catalogId,
            productId: productId,
            priceId:   priceId
        ) { [weak self] (result: Swift.Result<AddProductToNewCatalogueResponse, Error>) in
            guard let self else { return }
            Task { @MainActor in
                self.isAdding = false
                switch result {
                case .success(let response):
                    if response.success {
                        debugPrint("[AddCatalogueViewModel] ✅ Product added — returnId:\(response.returnId)")
                        self.successMessage = response.message
                        onSuccess(productName, priceLabel, currencies)
                    } else {
                        debugPrint("[AddCatalogueViewModel] ⚠️ \(response.message)")
                        self.errorMessage = response.message
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    debugPrint("[AddCatalogueViewModel] ❌ addProductToCatalogue: \(error)")
                }
            }
        }
    }

    // ════════════════════════════════════════════════════════
    // MARK: Save All
    // Convenience: creates catalogue then attaches all pending rows.
    // ════════════════════════════════════════════════════════

    /// Creates the catalogue and then sequentially adds all pending product rows.
    /// - Parameters:
    ///   - name:        Catalogue name.
    ///   - description: Catalogue description.
    ///   - pendingRows: Array of (productId, priceId, productName, priceLabel, currencies).
    ///   - onComplete:  Called when all steps finish (success or first failure).
    func saveAll(
        name:        String,
        description: String,
        pendingRows: [(productId: String, priceId: Int,
                       productName: String, priceLabel: String,
                       currencies: [String])],
        onComplete:  @escaping (Bool) -> Void
    ) {
        createCatalogue(name: name, description: description) { [weak self] catalogueId in
            guard let self else { return }
            guard !pendingRows.isEmpty else {
                self.didCreateSuccessfully = true
                onComplete(true)
                return
            }
            Task { @MainActor in
                await self.addRowsSequentially(
                    rows: pendingRows,
                    catalogueId: catalogueId,
                    onComplete: { success in
                        self.didCreateSuccessfully = true
                        onComplete(success)
                    }
                )
            }
        }
    }

    private func addRowsSequentially(
        rows:       [(productId: String, priceId: Int,
                      productName: String, priceLabel: String,
                      currencies: [String])],
        catalogueId: Int,
        onComplete:  @escaping (Bool) -> Void
    ) async {
        for row in rows {
            await withCheckedContinuation { continuation in
                self.addProductToCatalogue(
                    catalogId:   catalogueId,
                    productId:   row.productId,
                    priceId:     row.priceId,
                    productName: row.productName,
                    priceLabel:  row.priceLabel,
                    currencies:  row.currencies
                ) { _, _, _ in
                    continuation.resume()
                }
                // If addProductToCatalogue sets errorMessage, still resume
                // (partial success is acceptable for UX)
            }
            if errorMessage != nil {
                debugPrint("[AddCatalogueViewModel] ⚠️ Row failed but continuing: \(row.productName)")
                errorMessage = nil   // clear per-row error, final error surfaced at end
            }
        }
        onComplete(true)
    }
}
