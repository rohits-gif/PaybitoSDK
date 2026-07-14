//
//  Createproductviewmodel.swift
//  Trading_Terminal
//
//  Created by HashCash on 11/05/26.
//

import Foundation
import Combine

// MARK: - ViewModel

@MainActor
final class PCProductViewModel: ObservableObject {

    // MARK: Published State

    @Published var products: [PCAPIProduct] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var errorMessage: String? = nil
    @Published var searchText: String = ""
    @Published var selectedFilter: String = "All"
    @Published var selectedTab: Int = 0
    @Published var totalCount: Int = 0

    // MARK: Pagination

    private(set) var currentPage: Int = 1
    private let pageSize: Int = 10
    var hasMorePages: Bool { products.count < totalCount }

    // MARK: Filter Options

    let filterOptions = ["All", "Active", "Inactive"]

    // MARK: Computed — filtered list

    var filteredProducts: [PCAPIProduct] {
        let searched: [PCAPIProduct]
        if searchText.isEmpty {
            searched = products
        } else {
            searched = products.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.productId.localizedCaseInsensitiveContains(searchText)
            }
        }

        switch selectedFilter {
        case "Active":   return searched.filter { $0.isActive }
        case "Inactive": return searched.filter { !$0.isActive }
        default:         return searched
        }
    }

    // MARK: API status string for filter

    private var apiStatusFilter: String {
        switch selectedFilter {
        case "Active":   return "ACTIVE"
        case "Inactive": return "INACTIVE"
        default:         return "ALL"
        }
    }

    // MARK: - Load (initial / refresh)

    func loadProducts() {
        guard !isLoading else {
            debugPrint("⚠️ [PCViewModel] Already loading, skipping duplicate call")
            return
        }

        debugPrint("🔄 [PCViewModel] loadProducts() — page 1, filter: \(apiStatusFilter)")

        isLoading = true
        errorMessage = nil
        currentPage = 1

        PCProductService.shared.fetchProducts(
            page: 1,
            size: pageSize,
            status: apiStatusFilter
        ) { [weak self] (result: Swift.Result<PCProductData, Error>) in
            guard let self else { return }
            // Service already dispatches to main — safe to update directly
            self.isLoading = false

            switch result {
            case .success(let data):
                self.products = data.products
                self.totalCount = data.total
                debugPrint("✅ [PCViewModel] Loaded \(data.products.count) products (total: \(data.total))")

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                debugPrint("❌ [PCViewModel] Load failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Load More (pagination)

    func loadMoreIfNeeded(currentItem: PCAPIProduct) {
        guard hasMorePages, !isLoadingMore else { return }

        let thresholdIndex = products.index(
            products.endIndex,
            offsetBy: -2,
            limitedBy: products.startIndex
        ) ?? products.startIndex

        if let itemIndex = products.firstIndex(where: { $0.id == currentItem.id }),
           itemIndex >= thresholdIndex {
            loadNextPage()
        }
    }

    private func loadNextPage() {
        let nextPage = currentPage + 1
        debugPrint("📄 [PCViewModel] loadNextPage() — page \(nextPage)")

        isLoadingMore = true

        PCProductService.shared.fetchProducts(
            page: nextPage,
            size: pageSize,
            status: apiStatusFilter
        ) { [weak self] (result: Swift.Result<PCProductData, Error>) in
            guard let self else { return }
            self.isLoadingMore = false

            switch result {
            case .success(let data):
                let existingIDs = Set(self.products.map { $0.id })
                let unique = data.products.filter { !existingIDs.contains($0.id) }
                self.products.append(contentsOf: unique)
                self.totalCount = data.total
                self.currentPage = nextPage
                debugPrint("✅ [PCViewModel] Appended \(unique.count) products (page \(nextPage))")

            case .failure(let error):
                self.errorMessage = error.localizedDescription
                debugPrint("❌ [PCViewModel] Load more failed: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Delete (local + API)

    func deleteProduct(id: String) {
        debugPrint("🗑️ [PCViewModel] Deleting product: \(id)")

        // Optimistic local removal
        products.removeAll { $0.id == id }
        totalCount = max(0, totalCount - 1)
        debugPrint("   Remaining products: \(products.count)")

        // API call
        PCProductService.shared.deleteProduct(productId: id) { result in
            switch result {
            case .success:
                debugPrint("✅ [PCViewModel] Delete confirmed by API: \(id)")
            case .failure(let error):
                debugPrint("❌ [PCViewModel] Delete API error: \(error.localizedDescription)")
                // Optionally reload to restore state if API delete fails
            }
        }
    }

    // MARK: - Filter change

    func onFilterChanged() {
        debugPrint("🔍 [PCViewModel] Filter changed to: \(selectedFilter)")
        products = []
        totalCount = 0
        loadProducts()
    }
}
