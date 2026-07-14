// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  AddCatalogueView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 21/04/26.
//
//
//  AddCatalogueView.swift
//  Trading_Terminal
//
//  Full-screen "New Catalogue" form — fully wired to real API.
//  Mirrors EditCatalogueView design — same focus behaviour, same card layout.
//

import SwiftUI

// ============================================================
// MARK: - Focus Fields
// ============================================================

private enum ACVField: Hashable {
    case catalogueName
    case catalogueDesc
    case productSearch
    case priceSearch
}

// ============================================================
// MARK: - Table Row Model  (local to this file only)
// ============================================================

private struct ACVTableRow: Identifiable {
    let id          = UUID()
    let productId:  String
    let priceId:    Int
    var productName: String
    var priceLabel:  String
    var currencies:  [String]
}

// ============================================================
// MARK: - AddCatalogueView
// ============================================================

struct AddCatalogueView: View {

    @Environment(\.dismiss) private var dismiss

    // ── Live API ViewModel ────────────────────────────────────
    @StateObject private var addVM = AddCatalogueViewModel()

    // ── Form state ────────────────────────────────────────────
    @State private var catalogueName        = ""
    @State private var catalogueDescription = ""

    @State private var selectedProductId: String? = nil
    @State private var selectedPriceId:   Int?    = nil

    @State private var pendingRows: [ACVTableRow] = []

    @State private var showErrorAlert   = false
    @State private var showSuccessToast = false

    @FocusState private var focus: ACVField?

    // ── Derived ───────────────────────────────────────────────

    private var activeCurrencies: [String] {
        Array(Set(pendingRows.flatMap { $0.currencies })).sorted()
    }
    private var commonCurrencies: [String] {
        guard !pendingRows.isEmpty else { return [] }
        let sets = pendingRows.map { Set($0.currencies) }
        return Array(sets.dropFirst().reduce(sets.first ?? []) { $0.intersection($1) }).sorted()
    }
    private var canSave: Bool {
        !catalogueName.trimmingCharacters(in: .whitespaces).isEmpty
    }
    private var canAddProduct: Bool {
        selectedProductId != nil && selectedPriceId != nil && !addVM.isAdding
    }
    private var isBusy: Bool {
        addVM.isLoading || addVM.isCreating || addVM.isAdding
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
            if isBusy {
                Color.black.opacity(0.45).ignoresSafeArea()
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: PCTheme.accentLight))
                        .scaleEffect(1.6)
                    Text(addVM.isLoading  ? "Loading products…"   :
                         addVM.isAdding   ? "Adding product…"     :
                                            "Creating catalogue…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(PCTheme.textSecondary)
                }
                .padding(32)
                .background(PCTheme.surfaceHigh)
                .cornerRadius(18)
            }

            // Success toast
            if let msg = addVM.successMessage {
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
            addVM.loadProducts()
        }
        .onChange(of: addVM.errorMessage) { msg in
            showErrorAlert = msg != nil
        }
        .onChange(of: addVM.successMessage) { msg in
            if msg != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    addVM.successMessage = nil
                }
            }
        }
        .onChange(of: addVM.didCreateSuccessfully) { success in
            if success { dismiss() }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { addVM.errorMessage = nil }
        } message: {
            Text(addVM.errorMessage ?? "")
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
                Text("Product Catalogue")
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
        Text("New Catalogue")
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(PCTheme.textPrimary)
    }

    // ── Catalogue Info Card ───────────────────────────────────

    private var catalogueInfoCard: some View {
        ACVCard {
            VStack(alignment: .leading, spacing: 16) {

                acvSectionTitle("CATALOGUE INFO")

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 3) {
                        Text("Catalogue Name")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(PCTheme.textSecondary)
                        Text("*")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(PCTheme.deleteRed)
                    }
                    ACVFocusTextField(
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
                    ACVFocusTextEditor(
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
        ACVCard {
            VStack(alignment: .leading, spacing: 16) {

                HStack(spacing: 8) {
                    acvSectionTitle("PRODUCTS")
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
                                acvCurrencyBadge(c, style: .purple)
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

                    Menu {
                        if addVM.products.isEmpty {
                            Text("No products available")
                        } else {
                            ForEach(addVM.products) { product in
                                Button(product.name) {
                                    selectedProductId = product.productId
                                    addVM.selectProduct(product)
                                    selectedPriceId = nil
                                }
                            }
                        }
                    } label: {
                        let label = addVM.products
                            .first { $0.productId == selectedProductId }?.name
                            ?? "— Select product"
                        acvDropdownLabel(label, isActive: focus == .productSearch)
                    }
                    .frame(maxWidth: .infinity)

                    Menu {
                        if addVM.pricesForSelectedProduct.isEmpty {
                            Text(selectedProductId == nil
                                 ? "Select a product first"
                                 : "No one-time prices")
                        } else {
                            ForEach(addVM.pricesForSelectedProduct) { price in
                                Button(addVM.displayLabel(for: price)) {
                                    selectedPriceId = price.priceId
                                }
                            }
                        }
                    } label: {
                        let label = addVM.pricesForSelectedProduct
                            .first { $0.priceId == selectedPriceId }
                            .map { addVM.displayLabel(for: $0) }
                            ?? "— Select price"
                        acvDropdownLabel(label, isActive: focus == .priceSearch)
                    }
                    .frame(maxWidth: .infinity)

                    Button(action: stagePendingRow) {
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
                if !pendingRows.isEmpty {
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

                // ── Pending product table ──────────────────────
                if !pendingRows.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Product")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Price ID")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Currencies")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(PCTheme.textSecondary)
                        .padding(.vertical, 10)

                        Divider().background(PCTheme.border)

                        ForEach(pendingRows) { row in
                            HStack(alignment: .center, spacing: 0) {
                                Text(row.productName)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(PCTheme.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(row.priceLabel)
                                    .font(.system(size: 13))
                                    .foregroundColor(PCTheme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack(spacing: 6) {
                                    ForEach(row.currencies, id: \.self) { c in
                                        acvCurrencyBadge(c, style: .purple)
                                    }
                                    Button {
                                        pendingRows.removeAll { $0.id == row.id }
                                    } label: {
                                        Image(systemName: "xmark")
                                            .font(.system(size: 11, weight: .bold))
                                            .foregroundColor(PCTheme.deleteRed)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(.vertical, 12)

                            if pendingRows.last?.id != row.id {
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
                            acvCurrencyBadge(c, style: .green)
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

            Button(action: saveCatalogue) {
                Text("SAVE CATALOGUE")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        canSave
                            ? LinearGradient(colors: [PCTheme.orange, PCTheme.orangeLight],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [PCTheme.orange.opacity(0.4),
                                                      PCTheme.orangeLight.opacity(0.4)],
                                             startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
            }
            .disabled(!canSave || isBusy)
        }
    }

    // ── Logic ─────────────────────────────────────────────────

    /// Stages a row in the pending table (no API call yet — happens on Save).
    private func stagePendingRow() {
        guard
            let pid     = selectedProductId,
            let priceId = selectedPriceId,
            let product = addVM.product(for: pid),
            let price   = addVM.pricesForSelectedProduct.first(where: { $0.priceId == priceId })
        else { return }

        pendingRows.append(ACVTableRow(
            productId:   product.productId,
            priceId:     price.priceId,
            productName: product.name,
            priceLabel:  "#\(price.priceId)",
            currencies:  addVM.currencyCodes(for: price)
        ))
        debugPrint("[AddCatalogueView] Staged: \(product.name) #\(price.priceId)")

        selectedProductId = nil
        selectedPriceId   = nil
        addVM.clearProductSelection()
        focus = nil
    }

    /// Creates the catalogue, then sequentially adds all pending rows.
    private func saveCatalogue() {
        focus = nil
        let name = catalogueName.trimmingCharacters(in: .whitespaces)
        
        if name.isEmpty {
            addVM.errorMessage = "Catalogue name is required"
            return
        }
        
        if pendingRows.isEmpty {
            addVM.errorMessage = "At least one product must be added to the catalogue"
            return
        }

        let rows = pendingRows.map { row in (
            productId:   row.productId,
            priceId:     row.priceId,
            productName: row.productName,
            priceLabel:  row.priceLabel,
            currencies:  row.currencies
        )}

        addVM.saveAll(
            name:        name,
            description: catalogueDescription,
            pendingRows: rows
        ) { _ in
            // dismiss handled by .onChange(of: addVM.didCreateSuccessfully)
        }
    }

    // ── Atom builders ─────────────────────────────────────────

    @ViewBuilder
    private func acvSectionTitle(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 11, weight: .semibold, design: .monospaced))
            .foregroundColor(PCTheme.textSecondary)
            .tracking(1.5)
    }

    private enum ACVCurrencyStyle { case purple, green }

    @ViewBuilder
    private func acvCurrencyBadge(_ label: String, style: ACVCurrencyStyle) -> some View {
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
    private func acvDropdownLabel(_ label: String, isActive: Bool) -> some View {
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
// MARK: - ACVFocusTextField
// ============================================================

private struct ACVFocusTextField: View {
    let placeholder: String
    @Binding var text: String
    let field: ACVField
    @FocusState.Binding var focus: ACVField?

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
// MARK: - ACVFocusTextEditor
// ============================================================

private struct ACVFocusTextEditor: View {
    let placeholder: String
    @Binding var text: String
    let field: ACVField
    @FocusState.Binding var focus: ACVField?

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

private struct ACVCard<Content: View>: View {
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

struct AddCatalogueView_Previews: PreviewProvider {
    static var previews: some View {
        AddCatalogueView()
            .preferredColorScheme(.dark)
    }
}
