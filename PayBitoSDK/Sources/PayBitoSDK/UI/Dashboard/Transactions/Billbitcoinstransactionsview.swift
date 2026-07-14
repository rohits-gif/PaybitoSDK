//
//  Billbitcoinstransactionsview.swift
//  Trading_Terminal
//
//  Billbitcoinstransactionsview.swift
//  Trading_Terminal
//

import SwiftUI

// MARK: - Root View

struct TransactionsView: View {
    @StateObject private var viewModel: TransactionsViewModel
    @State private var showExportSheet = false
    @State private var showFilterSheet = false
    @State private var showTransactionDetail: TransactionP?
    @State private var showDatePicker = false
    @State private var showPaymentMethodPicker = false
    @State private var showNetworkPicker = false
    @State private var showCurrencyPicker = false

    init(merchantId: Int) {
        _viewModel = StateObject(wrappedValue: TransactionsViewModel(merchantId: merchantId))
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.bbDarkBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerRow
                    filterTabsRow
                    searchBar
                    filterChipsRow
                    statCardsRow
                    bulkActionsBar      // NEW — matches web bulk bar

                    if viewModel.isLoading && viewModel.transactions.isEmpty {
                        loadingView
                    } else if viewModel.transactions.isEmpty {
                        emptyState
                    } else {
                        transactionsList
                    }
                }
            }
            .refreshable { viewModel.fetchTransactions() }

            // FAB
//            Button(action: {}) {
//                Image(systemName: "plus")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(width: 60, height: 60)
//                    .background(Color.bbAccentBlue)
//                    .clipShape(RoundedRectangle(cornerRadius: 18))
//                    .shadow(color: Color.bbAccentBlue.opacity(0.5), radius: 12, x: 0, y: 6)
//            }
//            .padding(.trailing, 20)
//            .padding(.bottom, 28)
        }
        .sheet(isPresented: $showExportSheet) {
            ExportSheet(viewModel: viewModel)
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(viewModel: viewModel)
        }
        .sheet(item: $showTransactionDetail) { transaction in
            TransactionDetailView(transaction: transaction, viewModel: viewModel)
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            if viewModel.transactions.isEmpty {
                viewModel.fetchTransactions()
            }
        }
    }

    // MARK: - Header

    private var headerRow: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.bbAccentBlue.opacity(0.20))
                    .frame(width: 52, height: 52)
                Image(systemName: "list.bullet.rectangle.fill")
                    .resizable().scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(Color.bbAccentBlue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Transactions")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("View and manage all payments")
                    .font(.system(size: 12))
                    .foregroundColor(Color.bbLabelGray)
            }

            Spacer()

            Button(action: { showExportSheet = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text").font(.system(size: 13))
                    Text("Export").font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .background(Color.bbCardBG)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.bbBorder, lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: - Filter Tabs
    // Matches web filterDefs + Test User tab

    private var filterTabsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Standard tabs
                ForEach(TxnFilter.allCases, id: \.self) { filter in
                    FilterTab(
                        title: filter.rawValue,
                        count: countForFilter(filter),
                        isSelected: viewModel.selectedFilter == filter && !viewModel.showTestOnly,
                        action: { viewModel.applyFilter(filter) }
                    )
                }

                // Test User tab — matches web "Test User" button
                FilterTab(
                    title: "Test User",
                    count: nil,
                    isSelected: viewModel.showTestOnly,
                    isTestTab: true,
                    action: { viewModel.toggleTestOnly() }
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 2)
        }
        .padding(.bottom, 12)
    }

    // Matches web tabCounts
    private func countForFilter(_ filter: TxnFilter) -> Int? {
        switch filter {
        case .all:        return viewModel.totalCount
        case .success:    return viewModel.succeededCount
        case .failed:     return viewModel.failedCount
        case .refunded:   return viewModel.refundedCount
        case .cancelled:  return viewModel.cancelledCount
        case .processing: return nil
//        case .testUser:   return nil
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color.bbLabelGray)
                .font(.system(size: 15))

            TextField("", text: $viewModel.searchText)
                .placeholder(when: viewModel.searchText.isEmpty) {
                    Text("Search by email, transaction ID...")
                        .foregroundColor(Color.bbLabelGray)
                        .font(.system(size: 13))
                }
                .foregroundColor(.white)
                .font(.system(size: 13))

            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.bbLabelGray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.bbCardBG)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.bbBorder, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Filter Chips
    // Matches web filter dropdowns
    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(
                    title: "Date: \(viewModel.selectedDateRange.rawValue)",
                    isActive: viewModel.selectedDateRange != .allTime
                ) { showDatePicker = true }

                FilterChip(
                    title: viewModel.selectedPaymentMethod.isEmpty
                        ? "Payment Method" : viewModel.selectedPaymentMethod,
                    isActive: !viewModel.selectedPaymentMethod.isEmpty
                ) { showPaymentMethodPicker = true }

                FilterChip(
                    title: viewModel.selectedNetwork.isEmpty
                        ? "Network" : viewModel.selectedNetwork,
                    isActive: !viewModel.selectedNetwork.isEmpty
                ) { showNetworkPicker = true }

                FilterChip(
                    title: viewModel.selectedCurrency.isEmpty
                        ? "Currency" : viewModel.selectedCurrency,
                    isActive: !viewModel.selectedCurrency.isEmpty
                ) { showCurrencyPicker = true }

                FilterChip(
                    title: "More",
                    icon: "slider.horizontal.3",
                    isActive: false
                ) { showFilterSheet = true }
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
        // Date picker
        .confirmationDialog("Select Date Range", isPresented: $showDatePicker, titleVisibility: .visible) {
            ForEach(DateRangeFilter.allCases, id: \.self) { range in
                Button(range.rawValue) {
                    viewModel.applyDateRange(range)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        // Payment Method picker — matches web options exactly
        .confirmationDialog("Payment Method", isPresented: $showPaymentMethodPicker, titleVisibility: .visible) {
            Button("All Methods") {
                viewModel.selectedPaymentMethod = ""
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("Stripe") {
                viewModel.selectedPaymentMethod = "STRIPE"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("PayPal") {
                viewModel.selectedPaymentMethod = "PAYPAL"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("Brand Wallet") {
                viewModel.selectedPaymentMethod = "Brand Wallet"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("Guest Checkout") {
                viewModel.selectedPaymentMethod = "Guest Checkout"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("Cancel", role: .cancel) {}
        }
        // Network picker — matches web options exactly
        .confirmationDialog("Network", isPresented: $showNetworkPicker, titleVisibility: .visible) {
            Button("All Networks") {
                viewModel.selectedNetwork = ""
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("Native") {
                viewModel.selectedNetwork = "NATIVE"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("ERC") {
                viewModel.selectedNetwork = "ERC"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("TRC") {
                viewModel.selectedNetwork = "TRC"
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("Cancel", role: .cancel) {}
        }
        // Currency picker — matches web options exactly
        .confirmationDialog("Currency", isPresented: $showCurrencyPicker, titleVisibility: .visible) {
            Button("All Currencies") {
                viewModel.selectedCurrency = ""
                viewModel.currentPage = 1
                viewModel.fetchTransactions()
            }
            Button("BTC") { viewModel.selectedCurrency = "BTC"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("ETH") { viewModel.selectedCurrency = "ETH"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("LTC") { viewModel.selectedCurrency = "LTC"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("BCH") { viewModel.selectedCurrency = "BCH"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("USDT") { viewModel.selectedCurrency = "USDT"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("USDC") { viewModel.selectedCurrency = "USDC"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("USD") { viewModel.selectedCurrency = "USD"; viewModel.currentPage = 1; viewModel.fetchTransactions() }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: - Stat Cards
    // Matches web summary cards — uses flat ViewModel properties now

    private var statCardsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                TxnStatCardView(
                    title: "Total Volume",
                    amount: viewModel.totalVolumeFormatted,
                    subtitle: "\(viewModel.totalCount) transactions",
                    borderColor: Color.bbAccentBlue
                )
                TxnStatCardView(
                    title: "Successful",
                    amount: viewModel.successVolumeFormatted,
                    subtitle: "\(viewModel.succeededCount) payments",
                    borderColor: Color.bbAccentGreen,
                    amountColor: Color.bbAccentGreen
                )
                TxnStatCardView(
                    title: "Failed",
                    amount: viewModel.failedVolumeFormatted,
                    subtitle: "\(viewModel.failedCount) payments",
                    borderColor: Color(red: 0.90, green: 0.20, blue: 0.20),
                    amountColor: Color(red: 0.90, green: 0.20, blue: 0.20)
                )
                TxnStatCardView(
                    title: "Refunded",
                    amount: viewModel.refundedVolumeFormatted,
                    subtitle: "\(viewModel.refundedCount) payments",
                    borderColor: Color(red: 0.95, green: 0.65, blue: 0.10),
                    amountColor: Color(red: 0.95, green: 0.65, blue: 0.10)
                )
            }
            .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }

    // MARK: - Bulk Actions Bar
    // Matches web .tx-bulk — shown when rows are selected

    @State private var selectedIds: Set<Int> = []
    @State private var isMarkingTest = false

    // MARK: - Bulk Actions Bar

    private var bulkActionsBar: some View {
        Group {
            if !selectedIds.isEmpty {
                bulkActionsContent
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.2), value: selectedIds.isEmpty)
            }
        }
    }

    private var bulkActionsContent: some View {
        HStack(spacing: 10) {
            bulkSelectionLabel
            Spacer()
            markTestButton
            clearSelectionButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.bbAccentBlue.opacity(0.06))
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.bbAccentBlue.opacity(0.18), lineWidth: 1))
        .padding(.bottom, 8)
    }

    private var bulkSelectionLabel: some View {
        Text("\(selectedIds.count) selected")
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(Color.bbAccentBlue)
    }

    private var markTestButton: some View {
        let label = isMarkingTest ? "Marking..." : (viewModel.showTestOnly ? "Mark as Regular" : "Mark as Test")
        let icon = viewModel.showTestOnly ? "checkmark.circle" : "testtube.2"

        return Button(action: handleMarkTest) {
            HStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 12))
                Text(label).font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(Color.bbAccentGreen)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.bbAccentGreen.opacity(0.1))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.bbAccentGreen.opacity(0.3), lineWidth: 1))
        }
        .disabled(isMarkingTest)
    }

    private var clearSelectionButton: some View {
        Button(action: { selectedIds.removeAll() }) {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Color.bbLabelGray)
                .padding(8)
                .background(Color.bbCardBG)
                .cornerRadius(8)
        }
    }

    private func handleMarkTest() {
        isMarkingTest = true
        let ids = selectedIds.map { String($0) }   // ← convert Int → String
        viewModel.markTransactions(ids: ids, asTest: !viewModel.showTestOnly) { _ in
            isMarkingTest = false
            selectedIds.removeAll()
        }
    }

    // MARK: - Transactions List

    private var transactionsList: some View {
        VStack(spacing: 0) {
            // Table header
            HStack {
                Text("Showing \(viewModel.totalRecords) transactions")
                    .font(.system(size: 12))
                    .foregroundColor(Color.bbLabelGray)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            LazyVStack(spacing: 10) {
                ForEach(viewModel.transactions) { transaction in
                    TransactionRow(
                        transaction: transaction,
                        isSelected: selectedIds.contains(transaction.id),
                        onSelect: {
                            if selectedIds.contains(transaction.id) {
                                selectedIds.remove(transaction.id)
                            } else {
                                selectedIds.insert(transaction.id)
                            }
                        }
                    )
                    .onTapGesture { showTransactionDetail = transaction }
                    .onAppear {
                        if transaction.id == viewModel.transactions.last?.id {
                            viewModel.loadNextPage()
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            // Pagination info
            if viewModel.totalPages > 1 {
                HStack {
                    Text("Page \(viewModel.currentPage) of \(viewModel.totalPages)")
                        .font(.system(size: 12))
                        .foregroundColor(Color.bbLabelGray)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
            }

            if viewModel.isLoading {
                ProgressView().tint(.white).padding()
            }
        }
        .padding(.bottom, 100)
    }

    // MARK: - Loading / Empty

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(.white).scaleEffect(1.5)
            Text("Loading transactions...")
                .font(.system(size: 14))
                .foregroundColor(Color.bbLabelGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 40)
            Image(systemName: "list.bullet.rectangle")
                .resizable().scaledToFit()
                .frame(width: 64, height: 64)
                .foregroundColor(Color.bbLabelGray.opacity(0.4))
            Text("No transactions found")
                .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Text("Try adjusting your filters or search")
                .font(.system(size: 14)).foregroundColor(Color.bbLabelGray)
            if viewModel.selectedFilter != .all || !viewModel.searchText.isEmpty {
                Button(action: { viewModel.clearFilters() }) {
                    Text("Clear Filters")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(Color.bbAccentBlue).cornerRadius(10)
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 120)
    }
}

// MARK: - Filter Tab

private struct FilterTab: View {
    let title: String
    let count: Int?
    let isSelected: Bool
    var isTestTab: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if isTestTab {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 11))
                }
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .bold : .medium))
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(isSelected
                            ? Color.white.opacity(0.25)
                            : Color.bbLabelGray.opacity(0.15))
                        .cornerRadius(10)
                }
            }
            .foregroundColor(isSelected ? .white : Color.bbLabelGray)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(isSelected
                ? (isTestTab ? Color.bbAccentGreen : Color.bbAccentBlue)
                : Color.bbCardBG)
            .cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .stroke(isSelected ? Color.clear : Color.bbBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    var icon: String?
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                if let icon = icon {
                    Image(systemName: icon).font(.system(size: 12))
                }
                Text(title).font(.system(size: 13, weight: .medium))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(isActive ? Color.bbAccentBlue.opacity(0.3) : Color.bbCardBG)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? Color.bbAccentBlue : Color.bbBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Card

private struct TxnStatCardView: View {
    let title: String
    let amount: String
    let subtitle: String
    let borderColor: Color
    var amountColor: Color = .white

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(Color.bbLabelGray)
            Text(amount)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(amountColor)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(Color.bbLabelGray)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(width: 160, alignment: .leading)
        .background(Color.bbCardBG)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14)
            .stroke(borderColor, lineWidth: 1.5))
    }
}

// MARK: - Placeholder helper

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder() }
            self
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bbDarkBG.ignoresSafeArea()
        TransactionsView(merchantId: 29738)
    }
}
