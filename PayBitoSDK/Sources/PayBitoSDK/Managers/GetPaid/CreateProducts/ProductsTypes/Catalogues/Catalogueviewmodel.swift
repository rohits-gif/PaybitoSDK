//
//  Catalogueviewmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//
// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  CatalogueViewModel.swift
//  Trading_Terminal
//
//  ObservableObject — bridges PCCatalogueService ↔ SwiftUI.
//  merchantId / token / uuid are all read inside PCCatalogueService
//  from UserDefaults, so nothing is passed from here.
//

import Foundation
import SwiftUI

@MainActor
final class PCCatalogueViewModel: ObservableObject {

    // MARK: - Published State

    @Published var catalogues:     [PCCatalogueItem] = []
    @Published var isLoading:      Bool   = false
    @Published var isCreating:     Bool   = false
    @Published var isDeleting:     Bool   = false
    @Published var errorMessage:   String? = nil
    @Published var successMessage: String? = nil

    // MARK: - Load Catalogues

    func loadCatalogues() {
        isLoading    = true
        errorMessage = nil

        debugPrint("🔄 [CatalogueVM] loadCatalogues()")

        PCCatalogueService.shared.getCatalogues { [weak self] result in
            guard let self else { return }
            self.isLoading = false

            switch result {
            case .success(let items):
                self.catalogues = items.map { PCCatalogueItem(from: $0) }
                debugPrint("✅ [CatalogueVM] Loaded \(self.catalogues.count) catalogues")
                // ── Now fetch product counts ──────────────────────
                self.loadProductCounts()

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                debugPrint("❌ [CatalogueVM] Load failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Fetch product counts per catalogue

    // MARK: - Fetch product counts per catalogue

    func loadProductCounts() {
        let ids = catalogues.map { $0.id }
        guard !ids.isEmpty else { return }

        debugPrint("📊 [CatalogueVM] loadProductCounts for \(ids.count) catalogue(s): \(ids)")

        for catalogId in ids {
            PCCatalogueService.shared.getCatalogueProductCount(catalogId: catalogId) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let count):
                    if let idx = self.catalogues.firstIndex(where: { $0.id == catalogId }) {
                        self.catalogues[idx].productCount = count
                        debugPrint("✅ [CatalogueVM] catalogue \(catalogId) → \(count) products")
                    }
                case .failure(let error):
                    // Non-fatal — count stays 0
                    debugPrint("⚠️ [CatalogueVM] count failed for \(catalogId): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Create Catalogue

    func createCatalogue(
        name:        String,
        description: String,
        onSuccess:   @escaping (PCCatalogueItem) -> Void = { _ in }
    ) {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            debugPrint("⚠️ [CatalogueVM] Empty name — aborting create")
            return
        }

        isCreating   = true
        errorMessage = nil

        debugPrint("🔄 [CatalogueVM] createCatalogue() name='\(trimmed)'")

        PCCatalogueService.shared.createCatalogue(
            catalogName: trimmed,
            description: description
        ) { [weak self] result in
            guard let self else { return }
            self.isCreating = false

            switch result {
            case .success(let data):
                let item = PCCatalogueItem(from: data)
                self.catalogues.append(item)
                self.successMessage = "Catalogue \"\(item.name)\" created!"
                debugPrint("✅ [CatalogueVM] Created id=\(item.id) name=\(item.name)")
                onSuccess(item)

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                debugPrint("❌ [CatalogueVM] Create failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete Catalogue

    func deleteCatalogue(item: PCCatalogueItem) {
        isDeleting   = true
        errorMessage = nil

        debugPrint("🔄 [CatalogueVM] deleteCatalogue() id=\(item.id) name=\(item.name)")

        PCCatalogueService.shared.deleteCatalogue(catalogueId: item.id) { [weak self] result in
            guard let self else { return }
            self.isDeleting = false

            switch result {
            case .success(let message):
                self.catalogues.removeAll { $0.id == item.id }
                self.successMessage = message
                debugPrint("✅ [CatalogueVM] Deleted id=\(item.id)")

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                debugPrint("❌ [CatalogueVM] Delete failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Utility

    func clearMessages() {
        errorMessage   = nil
        successMessage = nil
    }
}
