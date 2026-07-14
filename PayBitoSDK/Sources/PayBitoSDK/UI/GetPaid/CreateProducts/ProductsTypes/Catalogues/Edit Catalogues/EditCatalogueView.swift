//
//  EditCatalogueView.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//
// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  EditCatalogueView.swift
//  Trading_Terminal
//
//  Full-screen "Edit Catalogue" form — fully wired to real API.
//  Mirrors AddCatalogueView design — same focus behaviour, same card layout.
//

import SwiftUI

// ============================================================
// MARK: - Focus Fields
// ============================================================

private enum ECVField: Hashable {
    case catalogueName
    case catalogueDesc
    case productSearch
    case priceSearch
}

// ============================================================
// MARK: - Table Row Model  (local to this file only)
//         Renamed ECVTableRow to avoid clash with ECVProduct
//         in EditCatalogueViewModel.swift
// ============================================================

private struct ECVTableRow: Identifiable {
    let id         = UUID()
    var productId:   String
    var rawPriceId:  Int
    var productName: String
    var priceID:     String
    var priceDisplay: String?
    var quantity:    Int?
    var currencies:  [String]
}

// ============================================================
// MARK: - EditCatalogueView
// ============================================================

struct EditCatalogueView: View {

    @ObservedObject var catalogueVM: PCCatalogueViewModel
    let item:       PCCatalogueItem
    let merchantId: Int

    @Environment(\.dismiss) private var dismiss

    // ── Live API ViewModel ────────────────────────────────────
    @StateObject private var editVM = EditCatalogueViewModel()

    // ── Form state — pre-filled from item ────────────────────
    @State private var catalogueName:        String
    @State private var catalogueDescription: String

    // Drop-down selections (nil = nothing chosen yet)
    @State private var selectedProductId: String? = nil
    @State private var selectedPriceId:   Int?    = nil

    // Rows added to the table — uses the private ECVTableRow
    @State private var addedRows: [ECVTableRow] = []

    // Error alert
    @State private var showErrorAlert = false

    // Focus
    @FocusState private var focus: ECVField?

    // ── Init ──────────────────────────────────────────────────

    init(catalogueVM: PCCatalogueViewModel, item: PCCatalogueItem, merchantId: Int) {
        self.catalogueVM  = catalogueVM
        self.item         = item
        self.merchantId   = merchantId
        _catalogueName        = State(initialValue: item.name)
        _catalogueDescription = State(initialValue: item.description)
    }

    // ── Derived ───────────────────────────────────────────────

    private var activeCurrencies: [String] {
        Array(Set(addedRows.flatMap { $0.currencies })).sorted()
    }
    private var commonCurrencies: [String] {
        guard !addedRows.isEmpty else { return [] }
        let sets = addedRows.map { Set($0.currencies) }
        return Array(sets.dropFirst().reduce(sets.first ?? []) { $0.intersection($1) }).sorted()
    }
    private var canSave: Bool {
        !catalogueName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    private var canAddProduct: Bool {
        selectedProductId != nil && selectedPriceId != nil && !editVM.isAdding
    }

    // ── Body ──────────────────────────────────────────────────

    var body: some View {
        ZStack {
            PCTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 20)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        backLink
                        pageTitle
                        catalogueInfoCard
                        productsCard
                        actionButtons
                            .padding(.bottom, 40)
                    }
                    .padding(.horizontal, 16)
                }
                .scrollDismissesKeyboard(.interactively)
            }

            // Loading overlay
            if catalogueVM.isCreating || editVM.isUpdating || editVM.isLoading || editVM.isAdding {
                Color.black.opacity(0.45).ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: PCTheme.accentLight))
                        .scaleEffect(1.6)
                    Text(editVM.isLoading  ? "Loading products…"  :
                         editVM.isAdding   ? "Adding product…"    :
                                             "Updating catalogue…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(PCTheme.textSecondary)
                }
                .padding(32)
                .background(PCTheme.surfaceHigh)
                .cornerRadius(18)
            }
            // ── Success toast (product added) ─────────────────
            if let msg = editVM.successMessage {
                VStack {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(PCTheme.green)
                            .font(.system(size: 16))
                        Text(msg)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PCTheme.textPrimary)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    .background(PCTheme.surfaceHigh)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(PCTheme.green.opacity(0.3), lineWidth: 1))
                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: msg)
            }
        }   // end ZStack
        .onAppear {
            editVM.loadProducts()
            editVM.loadCatalogueProducts(catalogId: item.id) { selections in
                addedRows = selections.map { sel in
                    ECVTableRow(
                        productId:   sel.productId,
                        rawPriceId:  sel.rawPriceId,
                        productName: sel.productName,
                        priceID:     sel.priceID,
                        priceDisplay: sel.priceDisplay,
                        quantity:    sel.quantity,
                        currencies:  sel.currencies
                    )
                }
            }
        }
        .onChange(of: editVM.errorMessage) { msg in
            showErrorAlert = msg != nil
        }
        .onChange(of: editVM.successMessage) { msg in
            // auto-clear success toast after 2.5 s
            if msg != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    editVM.successMessage = nil
                }
            }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { editVM.errorMessage = nil }
        } message: {
            Text(editVM.errorMessage ?? "")
        }
    }

    // ── Nav Bar ───────────────────────────────────────────────

    private var navBar: some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PCTheme.textPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit Catalogue")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(PCTheme.textPrimary)
                Text("Manage products, pricing, and catalogues")
                    .font(.system(size: 12))
                    .foregroundColor(PCTheme.textSecondary)
            }
            .padding(.leading, 8)
            Spacer()
        }
    }

    // ── Back Link ─────────────────────────────────────────────

    private var backLink: some View {
        Button { dismiss() } label: {
            HStack(spacing: 5) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 13, weight: .semibold))
                Text("Back to Catalogues")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(PCTheme.accentLight)
        }
    }

    // ── Page Title ────────────────────────────────────────────

    private var pageTitle: some View {
        Text("Edit — \(catalogueName.trimmingCharacters(in: .whitespaces).isEmpty ? item.name : catalogueName)")
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(PCTheme.textPrimary)
            .lineLimit(1)
            .truncationMode(.tail)
            .padding(.horizontal, 0)
    }

    // ── Catalogue Info Card ───────────────────────────────────

    private var catalogueInfoCard: some View {
        ECVCard {
            VStack(alignment: .leading, spacing: 16) {

                ecvSectionTitle("CATALOGUE INFO")

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 3) {
                        Text("Catalogue Name")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(PCTheme.textSecondary)
                        Text("*")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(PCTheme.deleteRed)
                    }
                    ECVFocusTextField(
                        placeholder: "e.g. Summer Collection",
                        text: $catalogueName,
                        field: .catalogueName,
                        focus: $focus
                    )
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Description (optional)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(PCTheme.textSecondary)
                    ECVFocusTextEditor(
                        placeholder: "Describe your catalogue...",
                        text: $catalogueDescription,
                        field: .catalogueDesc,
                        focus: $focus
                    )
                }
            }
        }
    }

    // ── Products Card ─────────────────────────────────────────

    private var productsCard: some View {
        ECVCard {
            VStack(alignment: .leading, spacing: 16) {

                // Header
                HStack(spacing: 8) {
                    ecvSectionTitle("PRODUCTS")
                    Text("optional")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(PCTheme.textSecondary)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(PCTheme.border).clipShape(Capsule())
                    Spacer()
                    if !activeCurrencies.isEmpty {
                        HStack(spacing: 5) {
                            Text("Active currencies:")
                                .font(.system(size: 11))
                                .foregroundColor(PCTheme.textSecondary)
                            ForEach(activeCurrencies, id: \.self) { c in
                                ecvCurrencyBadge(c, style: .purple)
                            }
                        }
                    }
                }

                Text("Attach products to this catalogue. Only one-time prices are shown. All selected prices must share at least one common currency.")
                    .font(.system(size: 13))
                    .foregroundColor(PCTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                // ── Selectors ─────────────────────────────────
                HStack(spacing: 8) {

                    // Product drop-down
                    Menu {
                        if editVM.products.isEmpty {
                            Text("No products available")
                        } else {
                            ForEach(editVM.products) { product in
                                Button(product.name) {
                                    selectedProductId = product.productId
                                    editVM.selectProduct(product)
                                    selectedPriceId = nil
                                    debugPrint("[EditCatalogueView] Product: \(product.name)")
                                }
                            }
                        }
                    } label: {
                        let label = editVM.products
                            .first { $0.productId == selectedProductId }?.name
                            ?? "— Select product"
                        ecvDropdownLabel(label, isActive: focus == .productSearch)
                    }
                    .frame(maxWidth: .infinity)

                    // Price drop-down
                    Menu {
                        if editVM.pricesForSelectedProduct.isEmpty {
                            Text(selectedProductId == nil
                                 ? "Select a product first"
                                 : "No one-time prices")
                        } else {
                            ForEach(editVM.pricesForSelectedProduct) { price in
                                Button(editVM.displayLabel(for: price)) {
                                    selectedPriceId = price.priceId
                                    debugPrint("[EditCatalogueView] Price: #\(price.priceId)")
                                }
                            }
                        }
                    } label: {
                        let label = editVM.pricesForSelectedProduct
                            .first { $0.priceId == selectedPriceId }
                            .map { editVM.displayLabel(for: $0) }
                            ?? "— Select price"
                        ecvDropdownLabel(label, isActive: focus == .priceSearch)
                    }
                    .frame(maxWidth: .infinity)

                    // Add button
                    Button(action: addProductRow) {
                        Text("Add")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 13)
                            .frame(minHeight: 50)
                            .background(canAddProduct
                                        ? PCTheme.accent
                                        : PCTheme.accent.opacity(0.4))
                            .cornerRadius(10)
                    }
                    .disabled(!canAddProduct)
                }

                // ── Active currency pills ──────────────────────
                if !addedRows.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Currencies")
                            .font(.system(size: 13))
                            .foregroundColor(PCTheme.textSecondary)
                        HStack(spacing: 6) {
                            ForEach(activeCurrencies, id: \.self) { c in
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(PCTheme.green)
                                    Text(c)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(PCTheme.green)
                                }
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(PCTheme.green.opacity(0.12))
                                .cornerRadius(8)
                            }
                        }
                    }
                }

                // ── Product table ─────────────────────────────
                if !addedRows.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Product")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Quantity")
                                .frame(width: 60, alignment: .leading)
                            Text("Price ID")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Currencies")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("")
                                .frame(width: 30, alignment: .trailing)
                        }
                        .font(.system(size: 11, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(PCTheme.textSecondary)
                        .padding(.vertical, 10)

                        Divider().background(PCTheme.border)

                        ForEach(addedRows) { row in
                            HStack(alignment: .center, spacing: 0) {
                                Text(row.productName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(PCTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let q = row.quantity {
                                    Text("\(q)")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(PCTheme.textPrimary)
                                        .frame(width: 60, alignment: .leading)
                                } else {
                                    Text("—")
                                        .font(.system(size: 13))
                                        .foregroundColor(PCTheme.textSecondary)
                                        .frame(width: 60, alignment: .leading)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(row.priceID)
                                        .font(.system(size: 12, design: .monospaced))
                                        .foregroundColor(PCTheme.textSecondary)
                                    if let display = row.priceDisplay {
                                        Text(display)
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(PCTheme.accent)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                HStack(spacing: 4) {
                                    ForEach(row.currencies, id: \.self) { c in
                                        ecvCurrencyBadge(c, style: .purple)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    editVM.removeProductFromCatalogue(
                                        catalogId: item.id,
                                        productId: row.productId,
                                        priceId:   row.rawPriceId
                                    ) {
                                        addedRows.removeAll { $0.id == row.id }
                                        if let idx = catalogueVM.catalogues.firstIndex(where: { $0.id == item.id }) {
                                            catalogueVM.catalogues[idx].productCount -= 1
                                        }
                                        debugPrint("[EditCatalogueView] Removed: \(row.productName)")
                                    }
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.system(size: 14))
                                        .foregroundColor(PCTheme.deleteRed)
                                        .padding(6)
                                        .background(PCTheme.deleteRed.opacity(0.1))
                                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(PCTheme.deleteRed.opacity(0.3), lineWidth: 1))
                                        .cornerRadius(6)
                                }
                                .frame(width: 30, alignment: .trailing)
                            }
                            .padding(.vertical, 12)

                            if addedRows.last?.id != row.id {
                                Divider().background(PCTheme.border.opacity(0.5))
                            }
                        }
                    }
                }

                // ── Common currencies footer ───────────────────
                if !commonCurrencies.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 12))
                            .foregroundColor(PCTheme.textSecondary)
                        Text("Catalogue will operate on common currencies:")
                            .font(.system(size: 12))
                            .foregroundColor(PCTheme.textSecondary)
                        ForEach(commonCurrencies, id: \.self) { c in
                            ecvCurrencyBadge(c, style: .green)
                        }
                    }
                }
            }
        }
    }

    // ── Action Buttons ────────────────────────────────────────

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Text("CANCEL")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(PCTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PCTheme.surfaceHigh)
                    .cornerRadius(14)
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(PCTheme.border, lineWidth: 1))
            }

            Button(action: updateCatalogue) {
                Text("UPDATE CATALOGUE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        canSave
                            ? LinearGradient(colors: [PCTheme.orange, PCTheme.orangeLight],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [PCTheme.orange.opacity(0.4), PCTheme.orangeLight.opacity(0.4)],
                                             startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
            }
            .disabled(!canSave || catalogueVM.isCreating || editVM.isUpdating)
        }
    }

    // ── Logic ─────────────────────────────────────────────────

    private func addProductRow() {
        guard
            let pid     = selectedProductId,
            let priceId = selectedPriceId,
            let product = editVM.product(for: pid),
            let price   = editVM.pricesForSelectedProduct.first(where: { $0.priceId == priceId })
        else { return }

        let currencies = editVM.currencyCodes(for: price)
        let label      = "#\(price.priceId)"

        editVM.addProductToCatalogue(
            catalogId:   item.id,
            productId:   product.productId,
            priceId:     price.priceId,
            productName: product.name,
            priceLabel:  label,
            currencies:  currencies
        ) { confirmedName, confirmedLabel, confirmedCurrencies in
            
            var display: String? = nil
            if let defCur = price.currencies.first(where: { $0.`default` }) ?? price.currencies.first {
                display = "\(defCur.currency) \(String(format: "%.2f", defCur.amount))"
            }

            // Append row to local table
            addedRows.append(ECVTableRow(
                productId:   product.productId,
                rawPriceId:  price.priceId,
                productName: confirmedName,
                priceID:     confirmedLabel,
                priceDisplay: display,
                quantity:    nil,
                currencies:  confirmedCurrencies
            ))
            
            // ✅ UPDATE the catalogue card's product count in the parent VM
            if let idx = catalogueVM.catalogues.firstIndex(where: { $0.id == item.id }) {
                catalogueVM.catalogues[idx].productCount += 1
            }
            
            debugPrint("[EditCatalogueView] Row confirmed & added: \(confirmedName) \(confirmedLabel)")
        }

        selectedProductId = nil
        selectedPriceId   = nil
        editVM.clearProductSelection()
        focus = nil
    }

    private func updateCatalogue() {
        focus = nil
        editVM.updateCatalogue(
            catalogId:   item.id,
            name:        catalogueName,
            description: catalogueDescription
        ) {
            dismiss()
        }
    }

    // ── Atom builders ─────────────────────────────────────────

    @ViewBuilder
    private func ecvSectionTitle(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundColor(PCTheme.textSecondary)
            .tracking(1.5)
    }

    private enum ECVCurrencyStyle { case purple, green }

    @ViewBuilder
    private func ecvCurrencyBadge(_ label: String, style: ECVCurrencyStyle) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(style == .purple
                             ? Color(red: 0.73, green: 0.62, blue: 1.0)
                             : PCTheme.green)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(style == .purple
                        ? PCTheme.accent.opacity(0.18)
                        : PCTheme.green.opacity(0.12))
            .cornerRadius(6)
    }

    @ViewBuilder
    private func ecvDropdownLabel(_ label: String, isActive: Bool) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(label.hasPrefix("—") ? PCTheme.textMuted : PCTheme.textPrimary)
                .lineLimit(1)
            Spacer()
            Image(systemName: "chevron.down")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(PCTheme.textSecondary)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .frame(minHeight: 50)
        .background(PCTheme.surface)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? PCTheme.accentLight : PCTheme.border,
                        lineWidth: isActive ? 1.8 : 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// ============================================================
// MARK: - ECVFocusTextField
// ============================================================

private struct ECVFocusTextField: View {
    let placeholder: String
    @Binding var text: String
    let field: ECVField
    @FocusState.Binding var focus: ECVField?

    private var isActive: Bool { focus == field }

    var body: some View {
        TextField("", text: $text,
                  prompt: Text(placeholder).foregroundColor(PCTheme.textMuted))
            .font(.system(size: 14))
            .foregroundColor(PCTheme.textPrimary)
            .tint(PCTheme.accentLight)
            .focused($focus, equals: field)
            .padding(.horizontal, 14).padding(.vertical, 13)
            .frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(PCTheme.surface))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? PCTheme.accentLight : PCTheme.border,
                            lineWidth: isActive ? 1.8 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture { focus = field }
            .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// ============================================================
// MARK: - ECVFocusTextEditor
// ============================================================

private struct ECVFocusTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let field: ECVField
    @FocusState.Binding var focus: ECVField?

    private var isActive: Bool { focus == field }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14))
                    .foregroundColor(PCTheme.textMuted)
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .font(.system(size: 14))
                .foregroundColor(PCTheme.textPrimary)
                .tint(PCTheme.accentLight)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .focused($focus, equals: field)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(PCTheme.surface))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? PCTheme.accentLight : PCTheme.border,
                        lineWidth: isActive ? 1.8 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { focus = field }
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// ============================================================
// MARK: - Card Container
// ============================================================

private struct ECVCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ c: () -> Content) { content = c() }
    var body: some View {
        content
            .padding(16)
            .background(PCTheme.surfaceHigh)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(PCTheme.border, lineWidth: 1))
    }
}

// ============================================================
// MARK: - Preview
// ============================================================

struct EditCatalogueView_Previews: PreviewProvider {
    static var previews: some View {
        EditCatalogueView(
            catalogueVM: PCCatalogueViewModel(),
            item: PCCatalogueItem(id: 3122, name: "Summer Collection",
                                  description: "All summer products", productCount: 3),
            merchantId: 21758
        )
        .preferredColorScheme(.dark)
    }
}















////
////  EditCatalogueView.swift
////  Trading_Terminal
////
////  Full-screen "Edit Catalogue" form.
////  Mirrors AddCatalogueView design — same focus behaviour, same card layout.
////
//
//import SwiftUI
//
//// ============================================================
//// MARK: - Focus Fields
//// ============================================================
//
//private enum ECVField: Hashable {
//    case catalogueName
//    case catalogueDesc
//    case productSearch
//    case priceSearch
//}
//
//// ============================================================
//// MARK: - EditCatalogueView
//// ============================================================
//
//struct EditCatalogueView: View {
//
//    @ObservedObject var catalogueVM: PCCatalogueViewModel
//    let item: PCCatalogueItem
//    @Environment(\.dismiss) private var dismiss
//
//    // Form state — pre-filled from item
//    @State private var catalogueName:        String
//    @State private var catalogueDescription: String
//    @State private var selectedProduct       = ""
//    @State private var selectedPrice         = ""
//    @State private var addedProducts: [ECVProduct] = []
//
//    // Focus
//    @FocusState private var focus: ECVField?
//
//    // Mock lists — replace with real VM data
//    private let availableProducts = ["Dress", "Shirt", "Jacket", "Pants", "Shoes"]
//    private let availablePrices   = ["Price #1248", "Price #1249", "Price #1250", "Price #1251"]
//
//    // ── Init ──────────────────────────────────────────────────
//
//    init(catalogueVM: PCCatalogueViewModel, item: PCCatalogueItem) {
//        self.catalogueVM = catalogueVM
//        self.item        = item
//        _catalogueName        = State(initialValue: item.name)
//        _catalogueDescription = State(initialValue: item.description)
//    }
//
//    // ── Derived ───────────────────────────────────────────────
//
//    private var activeCurrencies: [String] {
//        Array(Set(addedProducts.flatMap { $0.currencies })).sorted()
//    }
//    private var commonCurrencies: [String] {
//        guard !addedProducts.isEmpty else { return [] }
//        let sets = addedProducts.map { Set($0.currencies) }
//        return Array(sets.dropFirst().reduce(sets.first ?? []) { $0.intersection($1) }).sorted()
//    }
//    private var canSave: Bool {
//        !catalogueName.trimmingCharacters(in: .whitespaces).isEmpty
//    }
//
//    // ── Body ──────────────────────────────────────────────────
//
//    var body: some View {
//        ZStack {
//            PCTheme.background.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                navBar
//                    .padding(.horizontal, 16)
//                    .padding(.top, 16)
//                    .padding(.bottom, 20)
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 16) {
//                        backLink
//                        pageTitle
//                        catalogueInfoCard
//                        productsCard
//                        actionButtons
//                            .padding(.bottom, 40)
//                    }
//                    .padding(.horizontal, 16)
//                }
//                .scrollDismissesKeyboard(.interactively)
//            }
//
//            // Loading overlay
//            if catalogueVM.isCreating {
//                Color.black.opacity(0.45).ignoresSafeArea()
//                VStack(spacing: 14) {
//                    ProgressView()
//                        .progressViewStyle(CircularProgressViewStyle(tint: PCTheme.accentLight))
//                        .scaleEffect(1.6)
//                    Text("Updating catalogue…")
//                        .font(.system(size: 14, weight: .medium))
//                        .foregroundColor(PCTheme.textSecondary)
//                }
//                .padding(32)
//                .background(PCTheme.surfaceHigh)
//                .cornerRadius(18)
//            }
//        }
//    }
//
//    // ── Nav Bar ───────────────────────────────────────────────
//
//    private var navBar: some View {
//        HStack(alignment: .top) {
//            Button { dismiss() } label: {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(PCTheme.textPrimary)
//            }
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Product Catalogue")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(PCTheme.textPrimary)
//                Text("Manage products, pricing, and catalogues")
//                    .font(.system(size: 12))
//                    .foregroundColor(PCTheme.textSecondary)
//            }
//            .padding(.leading, 8)
//            Spacer()
//        }
//    }
//
//    // ── Back Link ─────────────────────────────────────────────
//
//    private var backLink: some View {
//        Button { dismiss() } label: {
//            HStack(spacing: 5) {
//                Image(systemName: "arrow.left")
//                    .font(.system(size: 13, weight: .semibold))
//                Text("Back to Catalogues")
//                    .font(.system(size: 14, weight: .semibold))
//            }
//            .foregroundColor(PCTheme.accentLight)
//        }
//    }
//
//    // ── Page Title ────────────────────────────────────────────
//
//    private var pageTitle: some View {
//        Text("Edit Catalogue")
//            .font(.system(size: 22, weight: .bold))
//            .foregroundColor(PCTheme.textPrimary)
//    }
//
//    // ── Catalogue Info Card ───────────────────────────────────
//
//    private var catalogueInfoCard: some View {
//        ECVCard {
//            VStack(alignment: .leading, spacing: 16) {
//
//                ecvSectionTitle("CATALOGUE INFO")
//
//                // Name
//                VStack(alignment: .leading, spacing: 6) {
//                    HStack(spacing: 3) {
//                        Text("Catalogue Name")
//                            .font(.system(size: 13, weight: .medium))
//                            .foregroundColor(PCTheme.textSecondary)
//                        Text("*")
//                            .font(.system(size: 13, weight: .bold))
//                            .foregroundColor(PCTheme.deleteRed)
//                    }
//                    ECVFocusTextField(
//                        placeholder: "e.g. Summer Collection",
//                        text: $catalogueName,
//                        field: .catalogueName,
//                        focus: $focus
//                    )
//                }
//
//                // Description
//                VStack(alignment: .leading, spacing: 6) {
//                    Text("Description (optional)")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(PCTheme.textSecondary)
//                    ECVFocusTextEditor(
//                        placeholder: "Describe your catalogue...",
//                        text: $catalogueDescription,
//                        field: .catalogueDesc,
//                        focus: $focus
//                    )
//                }
//            }
//        }
//    }
//
//    // ── Products Card ─────────────────────────────────────────
//
//    private var productsCard: some View {
//        ECVCard {
//            VStack(alignment: .leading, spacing: 16) {
//
//                // Header
//                HStack(spacing: 8) {
//                    ecvSectionTitle("PRODUCTS")
//                    Text("optional")
//                        .font(.system(size: 11, weight: .medium))
//                        .foregroundColor(PCTheme.textSecondary)
//                        .padding(.horizontal, 8).padding(.vertical, 3)
//                        .background(PCTheme.border).clipShape(Capsule())
//                    Spacer()
//                    if !activeCurrencies.isEmpty {
//                        HStack(spacing: 5) {
//                            Text("Active currencies:")
//                                .font(.system(size: 11))
//                                .foregroundColor(PCTheme.textSecondary)
//                            ForEach(activeCurrencies, id: \.self) { c in
//                                ecvCurrencyBadge(c, style: .purple)
//                            }
//                        }
//                    }
//                }
//
//                Text("Attach products to this catalogue. Only one-time prices are shown. All selected prices must share at least one common currency.")
//                    .font(.system(size: 13))
//                    .foregroundColor(PCTheme.textSecondary)
//                    .fixedSize(horizontal: false, vertical: true)
//
//                // Selectors
//                HStack(spacing: 8) {
//                    Menu {
//                        ForEach(availableProducts, id: \.self) { p in
//                            Button(p) { selectedProduct = p }
//                        }
//                    } label: {
//                        ecvDropdownLabel(
//                            selectedProduct.isEmpty ? "— Select product" : selectedProduct,
//                            isActive: focus == .productSearch
//                        )
//                    }
//                    .frame(maxWidth: .infinity)
//
//                    Menu {
//                        ForEach(availablePrices, id: \.self) { p in
//                            Button(p) { selectedPrice = p }
//                        }
//                    } label: {
//                        ecvDropdownLabel(
//                            selectedPrice.isEmpty ? "— Select price" : selectedPrice,
//                            isActive: focus == .priceSearch
//                        )
//                    }
//                    .frame(maxWidth: .infinity)
//
//                    Button(action: addProduct) {
//                        Text("Add")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 18)
//                            .padding(.vertical, 13)
//                            .frame(minHeight: 50)
//                            .background(
//                                selectedProduct.isEmpty || selectedPrice.isEmpty
//                                    ? PCTheme.accent.opacity(0.4)
//                                    : PCTheme.accent
//                            )
//                            .cornerRadius(10)
//                    }
//                    .disabled(selectedProduct.isEmpty || selectedPrice.isEmpty)
//                }
//
//                // Active currencies pills
//                if !addedProducts.isEmpty {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Currencies")
//                            .font(.system(size: 13))
//                            .foregroundColor(PCTheme.textSecondary)
//                        HStack(spacing: 6) {
//                            ForEach(activeCurrencies, id: \.self) { c in
//                                HStack(spacing: 4) {
//                                    Image(systemName: "checkmark")
//                                        .font(.system(size: 10, weight: .bold))
//                                        .foregroundColor(PCTheme.green)
//                                    Text(c)
//                                        .font(.system(size: 12, weight: .bold))
//                                        .foregroundColor(PCTheme.green)
//                                }
//                                .padding(.horizontal, 10).padding(.vertical, 5)
//                                .background(PCTheme.green.opacity(0.12))
//                                .cornerRadius(8)
//                            }
//                        }
//                    }
//                }
//
//                // Product table
//                if !addedProducts.isEmpty {
//                    VStack(spacing: 0) {
//                        HStack {
//                            Text("Product")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text("Price ID")
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text("Currencies")
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                        }
//                        .font(.system(size: 12, weight: .semibold))
//                        .foregroundColor(PCTheme.textSecondary)
//                        .padding(.vertical, 10)
//
//                        Divider().background(PCTheme.border)
//
//                        ForEach(addedProducts) { item in
//                            HStack(alignment: .center, spacing: 0) {
//                                Text(item.productName)
//                                    .font(.system(size: 13, weight: .semibold))
//                                    .foregroundColor(PCTheme.textPrimary)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                Text(item.priceID)
//                                    .font(.system(size: 13))
//                                    .foregroundColor(PCTheme.textSecondary)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                HStack(spacing: 6) {
//                                    ForEach(item.currencies, id: \.self) { c in
//                                        ecvCurrencyBadge(c, style: .purple)
//                                    }
//                                    Button {
//                                        addedProducts.removeAll { $0.id == item.id }
//                                    } label: {
//                                        Image(systemName: "xmark")
//                                            .font(.system(size: 11, weight: .bold))
//                                            .foregroundColor(PCTheme.deleteRed)
//                                    }
//                                }
//                                .frame(maxWidth: .infinity, alignment: .trailing)
//                            }
//                            .padding(.vertical, 12)
//
//                            if addedProducts.last?.id != item.id {
//                                Divider().background(PCTheme.border.opacity(0.5))
//                            }
//                        }
//                    }
//                }
//
//                // Common currencies footer
//                if !commonCurrencies.isEmpty {
//                    HStack(spacing: 6) {
//                        Image(systemName: "info.circle")
//                            .font(.system(size: 12))
//                            .foregroundColor(PCTheme.textSecondary)
//                        Text("Catalogue will operate on common currencies:")
//                            .font(.system(size: 12))
//                            .foregroundColor(PCTheme.textSecondary)
//                        ForEach(commonCurrencies, id: \.self) { c in
//                            ecvCurrencyBadge(c, style: .green)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // ── Action Buttons ────────────────────────────────────────
//
//    private var actionButtons: some View {
//        HStack(spacing: 12) {
//            Button { dismiss() } label: {
//                Text("CANCEL")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(PCTheme.textSecondary)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(PCTheme.surfaceHigh)
//                    .cornerRadius(14)
//                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(PCTheme.border, lineWidth: 1))
//            }
//
//            Button(action: updateCatalogue) {
//                Text("UPDATE CATALOGUE")
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(
//                        canSave
//                            ? LinearGradient(colors: [PCTheme.orange, PCTheme.orangeLight],
//                                             startPoint: .leading, endPoint: .trailing)
//                            : LinearGradient(colors: [PCTheme.orange.opacity(0.4), PCTheme.orangeLight.opacity(0.4)],
//                                             startPoint: .leading, endPoint: .trailing)
//                    )
//                    .cornerRadius(14)
//            }
//            .disabled(!canSave || catalogueVM.isCreating)
//        }
//    }
//
//    // ── Logic ─────────────────────────────────────────────────
//
//    private func addProduct() {
//        guard !selectedProduct.isEmpty, !selectedPrice.isEmpty else { return }
//        let priceID = selectedPrice.replacingOccurrences(of: "Price ", with: "")
//        addedProducts.append(ECVProduct(productName: selectedProduct,
//                                        priceID: priceID,
//                                        currencies: ["USD"]))
//        selectedProduct = ""
//        selectedPrice   = ""
//        focus = nil
//    }
//
//    private func updateCatalogue() {
//        focus = nil
//        let name = catalogueName.trimmingCharacters(in: .whitespaces)
//        guard !name.isEmpty else { return }
//        // Call your VM update method here, e.g.:
//        // catalogueVM.updateCatalogue(id: item.id, name: name, description: catalogueDescription)
//        dismiss()
//    }
//
//    // ── Atom builders ─────────────────────────────────────────
//
//    @ViewBuilder
//    private func ecvSectionTitle(_ label: String) -> some View {
//        Text(label)
//            .font(.system(size: 11, weight: .semibold, design: .monospaced))
//            .foregroundColor(PCTheme.textSecondary)
//            .tracking(1.5)
//    }
//
//    private enum ECVCurrencyStyle { case purple, green }
//
//    @ViewBuilder
//    private func ecvCurrencyBadge(_ label: String, style: ECVCurrencyStyle) -> some View {
//        Text(label)
//            .font(.system(size: 11, weight: .bold))
//            .foregroundColor(style == .purple
//                             ? Color(red: 0.73, green: 0.62, blue: 1.0)
//                             : PCTheme.green)
//            .padding(.horizontal, 8).padding(.vertical, 4)
//            .background(style == .purple
//                        ? PCTheme.accent.opacity(0.18)
//                        : PCTheme.green.opacity(0.12))
//            .cornerRadius(6)
//    }
//
//    @ViewBuilder
//    private func ecvDropdownLabel(_ label: String, isActive: Bool) -> some View {
//        HStack {
//            Text(label)
//                .font(.system(size: 14, weight: .medium))
//                .foregroundColor(label.hasPrefix("—") ? PCTheme.textMuted : PCTheme.textPrimary)
//                .lineLimit(1)
//            Spacer()
//            Image(systemName: "chevron.down")
//                .font(.system(size: 11, weight: .semibold))
//                .foregroundColor(PCTheme.textSecondary)
//        }
//        .padding(.horizontal, 14).padding(.vertical, 13)
//        .frame(minHeight: 50)
//        .background(PCTheme.surface)
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(isActive ? PCTheme.accentLight : PCTheme.border,
//                        lineWidth: isActive ? 1.8 : 1)
//        )
//        .animation(.easeInOut(duration: 0.15), value: isActive)
//    }
//}
//
//// ============================================================
//// MARK: - ECVFocusTextField
//// ============================================================
//
//private struct ECVFocusTextField: View {
//    let placeholder: String
//    @Binding var text: String
//    let field: ECVField
//    @FocusState.Binding var focus: ECVField?
//
//    private var isActive: Bool { focus == field }
//
//    var body: some View {
//        TextField("", text: $text,
//                  prompt: Text(placeholder).foregroundColor(PCTheme.textMuted))
//            .font(.system(size: 14))
//            .foregroundColor(PCTheme.textPrimary)
//            .tint(PCTheme.accentLight)
//            .focused($focus, equals: field)
//            .padding(.horizontal, 14).padding(.vertical, 13)
//            .frame(minHeight: 50)
//            .background(RoundedRectangle(cornerRadius: 10).fill(PCTheme.surface))
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(isActive ? PCTheme.accentLight : PCTheme.border,
//                            lineWidth: isActive ? 1.8 : 1)
//            )
//            .contentShape(RoundedRectangle(cornerRadius: 10))
//            .onTapGesture { focus = field }
//            .animation(.easeInOut(duration: 0.15), value: isActive)
//    }
//}
//
//// ============================================================
//// MARK: - ECVFocusTextEditor
//// ============================================================
//
//private struct ECVFocusTextEditor: View {
//    let placeholder: String
//    @Binding var text: String
//    let field: ECVField
//    @FocusState.Binding var focus: ECVField?
//
//    private var isActive: Bool { focus == field }
//
//    var body: some View {
//        ZStack(alignment: .topLeading) {
//            if text.isEmpty {
//                Text(placeholder)
//                    .font(.system(size: 14))
//                    .foregroundColor(PCTheme.textMuted)
//                    .padding(.horizontal, 14)
//                    .padding(.top, 14)
//                    .allowsHitTesting(false)
//            }
//            TextEditor(text: $text)
//                .font(.system(size: 14))
//                .foregroundColor(PCTheme.textPrimary)
//                .tint(PCTheme.accentLight)
//                .frame(minHeight: 100)
//                .scrollContentBackground(.hidden)
//                .padding(.horizontal, 10).padding(.vertical, 8)
//                .focused($focus, equals: field)
//        }
//        .background(RoundedRectangle(cornerRadius: 10).fill(PCTheme.surface))
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(isActive ? PCTheme.accentLight : PCTheme.border,
//                        lineWidth: isActive ? 1.8 : 1)
//        )
//        .contentShape(RoundedRectangle(cornerRadius: 10))
//        .onTapGesture { focus = field }
//        .animation(.easeInOut(duration: 0.15), value: isActive)
//    }
//}
//
//// ============================================================
//// MARK: - Local Models
//// ============================================================
//
//private struct ECVProduct: Identifiable {
//    let id = UUID()
//    var productName: String
//    var priceID: String
//    var currencies: [String]
//}
//
//// ============================================================
//// MARK: - Card Container
//// ============================================================
//
//private struct ECVCard<Content: View>: View {
//    let content: Content
//    init(@ViewBuilder _ c: () -> Content) { content = c() }
//    var body: some View {
//        content
//            .padding(16)
//            .background(PCTheme.surfaceHigh)
//            .cornerRadius(14)
//            .overlay(RoundedRectangle(cornerRadius: 14).stroke(PCTheme.border, lineWidth: 1))
//    }
//}
//
//// ============================================================
//// MARK: - Preview
//// ============================================================
//
//struct EditCatalogueView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditCatalogueView(
//            catalogueVM: PCCatalogueViewModel(),
//            item: PCCatalogueItem(id: 1248, name: "Summer Collection",
//                                  description: "All summer products", productCount: 3)
//        )
//        .preferredColorScheme(.dark)
//    }
//}
