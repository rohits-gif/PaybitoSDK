
//
//  CreateProductView.swift
//  Trading_Terminal
//
//  Catalogue tab delegates entirely to:
//    CatalogueModel.swift      — data models
//    CatalogueService.swift    — Alamofire 5 network
//    CatalogueViewModel.swift  — business logic
//    CataloguesView.swift      — all catalogue UI
//

import SwiftUI

// ============================================================
// MARK: - Shared Theme  (internal — used by CataloguesView too)
// ============================================================

enum PCTheme {
    static let background    = Color(red: 0.059, green: 0.067, blue: 0.090)
    static let surface       = Color(red: 0.102, green: 0.114, blue: 0.153)
    static let surfaceHigh   = Color(red: 0.145, green: 0.157, blue: 0.216)
    static let border        = Color(red: 0.165, green: 0.176, blue: 0.243)
    static let accent        = Color(red: 0.486, green: 0.231, blue: 0.929)
    static let accentLight   = Color(red: 0.624, green: 0.373, blue: 0.961)
    static let deleteRed     = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let tagBg         = Color(red: 0.145, green: 0.157, blue: 0.216)
    static let textPrimary   = Color.white
    static let textSecondary = Color(red: 0.545, green: 0.561, blue: 0.659)
    static let textMuted     = Color(red: 0.300, green: 0.310, blue: 0.400)
    static let tabActive     = Color(red: 0.486, green: 0.231, blue: 0.929)
    static let tabInactive   = Color(red: 0.145, green: 0.157, blue: 0.216)
    static let green         = Color(red: 0.133, green: 0.773, blue: 0.369)
    static let blue          = Color(red: 0.231, green: 0.510, blue: 0.965)
    static let gold          = Color(red: 1.000, green: 0.843, blue: 0.000)
    static let orange        = Color(red: 1.000, green: 0.420, blue: 0.208)
    static let orangeLight   = Color(red: 1.000, green: 0.549, blue: 0.329)
}

// ============================================================
// MARK: - Edit Screen Models
// ============================================================

enum PCEDStatus: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case active = "Active"; case draft = "Draft"; case archived = "Archived"
}

enum PCEDPriceKind: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case oneTime = "One-time"; case subscription = "Subscription"
}

struct PCEDMeta:    Identifiable { let id = UUID(); var key = ""; var value = "" }
struct PCEDVariant: Identifiable { let id = UUID(); var name = "" }

struct PCEDPrice: Identifiable {
    let id = UUID()
    var kind = PCEDPriceKind.oneTime; var amount = ""; var currency = "CHF"
    var sku = ""; var trackInventory = false; var isDefault = false
}

struct PCEDProduct: Identifiable {
    let id = UUID(); var name = ""; var imageURL = ""; var status = PCEDStatus.active
    var desc = ""; var prices = [PCEDPrice()]; var variants = [PCEDVariant]()
    var meta = [PCEDMeta()]
}

// ============================================================
// MARK: - MAIN VIEW
// ============================================================

struct CreateProductView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm          = PCProductViewModel()
    @StateObject private var catalogueVM = PCCatalogueViewModel()
    
    @State private var productToEdit:   PCAPIProduct? = nil
    @State private var productToDelete: PCAPIProduct? = nil
    @State private var showDeleteAlert  = false
    @State private var showAddProduct   = false
    @State private var showAddCatalogue = false
    
    @State private var fabExpanded        = false
    @State private var showCreatePayment  = false
    @State private var showQuickPayment   = false
    
    private var isProductsTab: Bool { vm.selectedTab == 0 }
    
    // ── FIX: reads the merchant ID saved during login ─────────
    // Change "merchantId" to whatever key your app uses in
    // UserDefaults when it saves the merchant ID after login.
    private var merchantId: Int {
        UserDefaults.standard.integer(forKey: "merchantId")
    }
    
    var body: some View {
        ZStack {
            PCTheme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                    .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 20)
                tabBarView
                    .padding(.horizontal, 16).padding(.bottom, 16)
                if isProductsTab {
                    searchFilterRow.padding(.horizontal, 16).padding(.bottom, 14)
                }
                contentArea
            }
            fabButton
        }
        // AFTER:
        .fullScreenCover(item: $productToEdit, onDismiss: {
            vm.loadProducts()   // refresh list after edit
        }) { product in
            EditProductView(apiProduct: product)
        }
        .fullScreenCover(isPresented: $showAddProduct, onDismiss: {
            vm.loadProducts()
        }) {
            AddProductView()
        }
        .fullScreenCover(isPresented: $showAddCatalogue, onDismiss: {
            catalogueVM.loadCatalogues()
        }) {
            AddCatalogueView()
        }
        .toolbar(.hidden, for: .navigationBar)
        .alert("Delete Product", isPresented: $showDeleteAlert, presenting: productToDelete) { p in
            Button("Delete", role: .destructive) { vm.deleteProduct(id: p.id) }
            Button("Cancel", role: .cancel) {}
        } message: { p in Text("Delete \"\(p.name)\"?") }
            .onAppear {
                vm.loadProducts()
                catalogueVM.loadCatalogues()
            }
            .onChange(of: vm.selectedTab) { newTab in
                if newTab == 1 {
                    debugPrint("🔀 [CreateProductView] Catalogues tab — reloading")
                    catalogueVM.loadCatalogues()
                }
            }
    }
    
    // ── Header ────────────────────────────────────────────────
    
    private var headerView: some View {
        HStack(alignment: .top) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold)).foregroundColor(PCTheme.textPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(isProductsTab ? "Products" : "Catalogues")
                    .font(.system(size: 20, weight: .bold)).foregroundColor(PCTheme.textPrimary)
                Text("Manage products, pricing, and catalogues")
                    .font(.system(size: 12)).foregroundColor(PCTheme.textSecondary)
            }
            .padding(.leading, 8)
            Spacer()
            Button {
                if isProductsTab { showAddProduct = true } else { showAddCatalogue = true }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                    Text(isProductsTab ? "Add Product" : "Add Catalogue")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(LinearGradient(
                    colors: [Color(red: 0.659, green: 0.333, blue: 0.969), PCTheme.accent],
                    startPoint: .topLeading, endPoint: .bottomTrailing))
                .cornerRadius(24)
                .animation(.easeInOut(duration: 0.2), value: vm.selectedTab)
            }
        }
    }
    
    // ── Tab Bar ───────────────────────────────────────────────
    
    private var tabBarView: some View {
        HStack(spacing: 8) {
            pcTabBtn(title: "Products",   count: vm.totalCount,                index: 0)
            pcTabBtn(title: "Catalogues", count: catalogueVM.catalogues.count, index: 1)
            Spacer()
        }
    }
    
    @ViewBuilder
    private func pcTabBtn(title: String, count: Int, index: Int) -> some View {
        let sel = vm.selectedTab == index
        Button { withAnimation(.easeInOut(duration: 0.2)) { vm.selectedTab = index } } label: {
            HStack(spacing: 6) {
                Text(title).font(.system(size: 14, weight: .semibold))
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(sel ? Color.white.opacity(0.25) : PCTheme.border)
                    .clipShape(Capsule())
            }
            .foregroundColor(sel ? .white : PCTheme.textSecondary)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(sel ? PCTheme.tabActive : PCTheme.tabInactive)
            .cornerRadius(10)
        }
    }
    
    // ── Search + Filter ───────────────────────────────────────
    
    private var searchFilterRow: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(PCTheme.textSecondary).font(.system(size: 14))
                TextField("Search...", text: $vm.searchText)
                    .foregroundColor(PCTheme.textPrimary).font(.system(size: 14))
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(PCTheme.surface).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(PCTheme.border, lineWidth: 1))
            
            Menu {
                ForEach(vm.filterOptions, id: \.self) { opt in
                    Button(opt) { vm.selectedFilter = opt; vm.onFilterChanged() }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(vm.selectedFilter)
                        .font(.system(size: 14, weight: .medium)).foregroundColor(PCTheme.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold)).foregroundColor(PCTheme.textSecondary)
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
                .background(PCTheme.surface).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(PCTheme.border, lineWidth: 1))
            }
        }
    }
    
    // ── Content Area ──────────────────────────────────────────
    // FIX: pass merchantId to PCCataloguesTabView
    
    @ViewBuilder
    private var contentArea: some View {
        if isProductsTab { productsTab }
        else {
            PCCataloguesTabView(vm: catalogueVM, merchantId: merchantId)
        }
    }
    
    // ── Products Tab ──────────────────────────────────────────
    
    @ViewBuilder
    private var productsTab: some View {
        if vm.isLoading {
            Spacer()
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: PCTheme.accentLight)).scaleEffect(1.4)
            Spacer()
        } else if let error = vm.errorMessage {
            Spacer(); PCErrorView(message: error) { vm.loadProducts() }; Spacer()
        } else if vm.filteredProducts.isEmpty {
            Spacer(); PCEmptyStateView().padding(.horizontal, 16); Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.filteredProducts) { product in
                        PCProductCard(
                            product: product,
                            onEdit:   { productToEdit = product },
                            onDelete: { productToDelete = product; showDeleteAlert = true }
                        )
                        .onAppear { vm.loadMoreIfNeeded(currentItem: product) }
                    }
                    if vm.isLoadingMore {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: PCTheme.accentLight)).padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 100)
            }
        }
    }
    
    
    private var fabButton: some View {
        ZStack {
            // ── Dim backdrop ──────────────────────────────────────
            if fabExpanded {
                Color.black.opacity(0.45)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            fabExpanded = false
                        }
                    }
                    .transition(.opacity)
            }
            
            // ── Speed-dial + FAB ──────────────────────────────────
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 14) {
                        
                        if fabExpanded {
                            
                            // ── Create Payment ────────────────────
                            HStack(spacing: 12) {
                                Text("Create Payment")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(PCTheme.textPrimary)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(PCTheme.surfaceHigh)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        fabExpanded = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        showCreatePayment = true
                                    }
                                } label: {
                                    Image(systemName: "link")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 52, height: 52)
                                        .background(PCTheme.accent)
                                        .cornerRadius(14)
                                        .shadow(color: PCTheme.accent.opacity(0.4), radius: 10, x: 0, y: 5)
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal:   .move(edge: .bottom).combined(with: .opacity)
                            ))
                            
                            // ── Quick Payment ─────────────────────
                            HStack(spacing: 12) {
                                Text("Quick Payment")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(PCTheme.textPrimary)
                                    .padding(.horizontal, 16).padding(.vertical, 10)
                                    .background(PCTheme.surfaceHigh)
                                    .cornerRadius(10)
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                                
                                Button {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                        fabExpanded = false
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        showQuickPayment = true
                                    }
                                } label: {
                                    Image(systemName: "bolt.fill")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 52, height: 52)
                                        .background(Color(red: 0.96, green: 0.52, blue: 0.0))
                                        .cornerRadius(14)
                                        .shadow(color: Color.orange.opacity(0.4), radius: 10, x: 0, y: 5)
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal:   .move(edge: .bottom).combined(with: .opacity)
                            ))
                        }
                        
                        // ── Main FAB ──────────────────────────────
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                fabExpanded.toggle()
                            }
                        } label: {
                            Image(systemName: fabExpanded ? "xmark" : "plus")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .rotationEffect(.degrees(fabExpanded ? 90 : 0))
                                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: fabExpanded)
                                .frame(width: 56, height: 56)
                                .background(PCTheme.blue)
                                .cornerRadius(16)
                                .shadow(color: PCTheme.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        // ── Navigation ────────────────────────────────────────────
        .fullScreenCover(isPresented: $showCreatePayment) {
            CreatePaymentView()            // ← your existing CreatePaymentView
        }
        .fullScreenCover(isPresented: $showQuickPayment) {
            QuickPaymentsView()            // ← your existing QuickPaymentsView
        }
    }
}
    
// ============================================================
// MARK: - Product Card + helpers
// ============================================================

private struct PCProductCard: View {
    let product: PCAPIProduct; let onEdit: () -> Void; let onDelete: () -> Void
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // ── Thumbnail ──────────────────────────────────────
            Group {
                if let urlStr = product.imageUrl, !urlStr.isEmpty {
                    if urlStr.hasPrefix("data:image"),
                       let commaIdx = urlStr.firstIndex(of: ",") {
                        // ── Base64 data URI from mobile photo picker ──
                        let b64 = String(urlStr[urlStr.index(after: commaIdx)...])
                        if let data = Data(base64Encoded: b64),
                           let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable().scaledToFill()
                        } else {
                            imagePlaceholder
                        }
                    } else if let url = URL(string: urlStr) {
                        // ── Remote https:// URL ───────────────────────
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let img):
                                img.resizable().scaledToFill()
                            case .failure:
                                imagePlaceholder
                            default:
                                Color(PCTheme.surfaceHigh)
                                    .overlay(ProgressView().tint(PCTheme.accentLight))
                            }
                        }
                    } else {
                        imagePlaceholder
                    }
                } else {
                    imagePlaceholder
                }
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(PCTheme.border, lineWidth: 1))

            // ── Content ────────────────────────────────────────
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 8) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(product.name).font(.system(size: 15, weight: .semibold))
                            .foregroundColor(PCTheme.textPrimary).fixedSize(horizontal: false, vertical: true)
                        Text(product.productId).font(.system(size: 11)).foregroundColor(PCTheme.textSecondary)
                    }
                    Spacer(minLength: 8)
                    PCStatusBadge(isActive: product.isActive)
                }
                HStack(spacing: 6) {
                    Text("—").foregroundColor(PCTheme.textSecondary).font(.system(size: 13))
                    PCTagPill(label: product.isTracked ? "Tracked" : "Untracked")
                }
                Text("— | \(product.displayCurrency) \(String(format: "%.2f", product.displayAmount)) | \(product.displayBillingType) | SKU: \(product.skuCode ?? "—") | \(product.isTracked ? "Tracked" : "Untracked")")
                    .font(.system(size: 13)).foregroundColor(PCTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 10) {
                    Spacer()
                    Button { onEdit() } label: {
                        HStack(spacing: 5) { Image(systemName: "pencil"); Text("Edit") }
                            .font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.accentLight)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(PCTheme.accent, lineWidth: 1.5))
                    }
                    Button { onDelete() } label: {
                        HStack(spacing: 5) { Image(systemName: "trash"); Text("Delete") }
                            .font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.deleteRed)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(PCTheme.deleteRed, lineWidth: 1.5))
                    }
                }
            }
        }
        .padding(16).background(PCTheme.surface).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PCTheme.border, lineWidth: 1))
    }

    private var imagePlaceholder: some View {
        PCTheme.surfaceHigh
            .overlay(
                Image(systemName: "photo")
                    .font(.system(size: 22, weight: .light))
                    .foregroundColor(PCTheme.textMuted)
            )
    }
}

private struct PCStatusBadge: View {
    let isActive: Bool
    private var color: Color { isActive ? PCTheme.green : .gray }
    var body: some View {
        Text(isActive ? "Active" : "Inactive")
            .font(.system(size: 11, weight: .semibold)).foregroundColor(color)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(color.opacity(0.12)).clipShape(Capsule())
    }
}

private struct PCTagPill: View {
    let label: String
    var body: some View {
        Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(PCTheme.textSecondary)
            .padding(.horizontal, 10).padding(.vertical, 4)
            .background(PCTheme.tagBg).cornerRadius(6)
    }
}

private struct PCEmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "archivebox").font(.system(size: 52, weight: .light))
                .foregroundColor(PCTheme.textSecondary.opacity(0.4))
            Text("No Products Found").font(.system(size: 18, weight: .semibold)).foregroundColor(PCTheme.textPrimary)
            Text("Add your first product to get started.").font(.system(size: 14))
                .foregroundColor(PCTheme.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 80)
    }
}

private struct PCErrorView: View {
    let message: String; let onRetry: () -> Void
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle").font(.system(size: 48, weight: .light))
                .foregroundColor(PCTheme.deleteRed.opacity(0.8))
            Text("Something went wrong").font(.system(size: 17, weight: .semibold)).foregroundColor(PCTheme.textPrimary)
            Text(message).font(.system(size: 13)).foregroundColor(PCTheme.textSecondary)
                .multilineTextAlignment(.center).padding(.horizontal, 24)
            Button(action: onRetry) {
                Text("Retry").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 10)
                    .background(PCTheme.accent).cornerRadius(10)
            }
        }.frame(maxWidth: .infinity)
    }
}

// ============================================================
// MARK: - PCEditProductView
// ============================================================

struct PCEditProductView: View {
    @State var product: PCEDProduct
    let onBack: () -> Void; let onSave: (PCEDProduct) -> Void

    var body: some View {
        ZStack {
            PCTheme.background.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    topHeader.padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 20)
                    backBtn.padding(.horizontal, 16).padding(.bottom, 8)
                    Text("Edit — \(product.name)").font(.system(size: 20, weight: .bold))
                        .foregroundColor(PCTheme.textPrimary).padding(.horizontal, 16).padding(.bottom, 20)
                    PCEDBasicInfoSection(product: $product).padding(.horizontal, 16).padding(.bottom, 16)
                    PCEDVariantsSection(variants: $product.variants).padding(.horizontal, 16).padding(.bottom, 16)
                    PCEDPricingSection(prices: $product.prices).padding(.horizontal, 16).padding(.bottom, 16)
                    PCEDSummarySection(prices: product.prices).padding(.horizontal, 16).padding(.bottom, 16)
                    PCEDMetaSection(entries: $product.meta).padding(.horizontal, 16).padding(.bottom, 24)
                    actionBtns.padding(.horizontal, 16).padding(.bottom, 40)
                }
            }
        }
    }

    private var topHeader: some View {
        HStack(alignment: .top) {
            Button(action: onBack) {
                Image(systemName: "chevron.left").font(.system(size: 18, weight: .semibold)).foregroundColor(PCTheme.textPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit Product").font(.system(size: 20, weight: .bold)).foregroundColor(PCTheme.textPrimary)
                Text("Manage products, pricing, and catalogues").font(.system(size: 12)).foregroundColor(PCTheme.textSecondary)
            }.padding(.leading, 8)
            Spacer()
        }
    }

    private var backBtn: some View {
        Button(action: onBack) {
            HStack(spacing: 5) {
                Image(systemName: "arrow.left").font(.system(size: 13, weight: .semibold))
                Text("Back to Products").font(.system(size: 14, weight: .semibold))
            }.foregroundColor(PCTheme.accentLight)
        }
    }

    private var actionBtns: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Text("CANCEL").font(.system(size: 14, weight: .bold)).foregroundColor(PCTheme.textSecondary)
                    .frame(maxWidth: .infinity).padding(.vertical, 16).background(PCTheme.surfaceHigh).cornerRadius(14)
            }
            Button { onSave(product) } label: {
                Text("UPDATE PRODUCT").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(colors: [PCTheme.orange, PCTheme.orangeLight],
                                               startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(14)
            }
        }
    }
}

// ============================================================
// MARK: - Edit Sections
// ============================================================

private struct PCEDBasicInfoSection: View {
    @Binding var product: PCEDProduct
    var body: some View {
        PCEDCard {
            VStack(alignment: .leading, spacing: 16) {
                PCEDSectionTitle(label: "BASIC INFO")
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Text("Product Name").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                        Text("*").foregroundColor(PCTheme.deleteRed)
                    }
                    PCEDTextField(hint: "Product name", text: $product.name)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Image URL (optional)").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                    PCEDTextField(hint: "https://example.com/image.jpg", text: $product.imageURL)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Status").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                    HStack(spacing: 20) {
                        ForEach(PCEDStatus.allCases) { s in
                            PCEDRadio(label: s.rawValue, on: product.status == s) { product.status = s }
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description (optional)").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                    PCEDTextField(hint: "Product description...", text: $product.desc, tall: true)
                }
            }
        }
    }
}

private struct PCEDVariantsSection: View {
    @Binding var variants: [PCEDVariant]
    var body: some View {
        PCEDCard {
            VStack(alignment: .leading, spacing: 12) {
                PCEDSectionTitle(label: "ATTRIBUTES & VARIANTS", btnText: "Add Attribute") {
                    variants.append(PCEDVariant())
                }
                if variants.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Define attributes like size, color, etc.").font(.system(size: 13)).foregroundColor(PCTheme.textSecondary)
                        Text("No attributes yet.").font(.system(size: 13)).foregroundColor(PCTheme.textMuted)
                    }
                } else {
                    ForEach($variants) { $v in
                        HStack(spacing: 8) {
                            PCEDTextField(hint: "Attribute name (e.g. Size)", text: $v.name)
                            Button { variants.removeAll { $0.id == v.id } } label: {
                                Image(systemName: "xmark").font(.system(size: 12, weight: .bold)).foregroundColor(PCTheme.deleteRed)
                                    .frame(width: 32, height: 32).background(PCTheme.deleteRed.opacity(0.1)).clipShape(Circle())
                            }
                        }
                    }
                }
            }
        }
    }
}

private struct PCEDPricingSection: View {
    @Binding var prices: [PCEDPrice]
    var body: some View {
        PCEDCard {
            VStack(alignment: .leading, spacing: 16) {
                PCEDSectionTitle(label: "PRICING", btnText: "Add Price") { prices.append(PCEDPrice()) }
                ForEach(Array(prices.indices), id: \.self) { i in
                    if i < prices.count {
                        PCEDPriceCard(price: $prices[i], index: i,
                                      onRemove: { prices.remove(at: i) },
                                      onSetDefault: {
                            for j in prices.indices { prices[j].isDefault = false }
                            prices[i].isDefault = true
                        })
                        if i < prices.count - 1 { Divider().background(PCTheme.border) }
                    }
                }
            }
        }
    }
}

private struct PCEDPriceCard: View {
    @Binding var price: PCEDPrice
    let index: Int; let onRemove: () -> Void; let onSetDefault: () -> Void
    private let currencies = ["CHF","USD","EUR","GBP","JPY","CAD","AUD"]
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Price #\(index + 1)").font(.system(size: 15, weight: .bold)).foregroundColor(PCTheme.textPrimary)
                Spacer()
                let isD = price.isDefault; let col: Color = isD ? PCTheme.gold : PCTheme.accentLight
                Button(action: onSetDefault) {
                    HStack(spacing: 4) {
                        Image(systemName: isD ? "star.fill" : "star").font(.system(size: 11))
                        Text(isD ? "Default" : "Set Default").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(col).padding(.horizontal, 10).padding(.vertical, 6)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(col.opacity(0.5), lineWidth: 1))
                }
                Button(action: onRemove) {
                    Text("× Remove").font(.system(size: 12, weight: .semibold)).foregroundColor(PCTheme.deleteRed)
                }.padding(.leading, 4)
            }
            PCEDKindToggle(selected: $price.kind)
            VStack(alignment: .leading, spacing: 6) {
                Text("Amount").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                HStack(spacing: 8) {
                    TextField("0.00", text: $price.amount).keyboardType(.decimalPad)
                        .font(.system(size: 15)).foregroundColor(PCTheme.textPrimary)
                        .padding(.horizontal, 14).padding(.vertical, 12).background(PCTheme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PCTheme.border, lineWidth: 1)).cornerRadius(10)
                    Menu {
                        ForEach(currencies, id: \.self) { c in Button(c) { price.currency = c } }
                    } label: {
                        HStack(spacing: 4) {
                            Text(price.currency).font(.system(size: 15, weight: .semibold)).foregroundColor(PCTheme.textPrimary)
                            Image(systemName: "chevron.down").font(.system(size: 11)).foregroundColor(PCTheme.textSecondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 12).background(PCTheme.surface)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PCTheme.border, lineWidth: 1)).cornerRadius(10)
                    }
                    if price.isDefault {
                        HStack(spacing: 4) {
                            Text("⭐").font(.system(size: 12))
                            Text("Default").font(.system(size: 12, weight: .semibold)).foregroundColor(PCTheme.gold)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 12).background(PCTheme.gold.opacity(0.1)).cornerRadius(10)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text("SKU (optional)").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                PCEDTextField(hint: "e.g. TSHIRT-BLK-L", text: $price.sku)
            }
            HStack {
                Text("Additional Currencies").font(.system(size: 13, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                Spacer()
                Button(action: {}) { Text("+ Add Currency").font(.system(size: 13, weight: .semibold)).foregroundColor(PCTheme.accentLight) }
            }
            Button { price.trackInventory.toggle() } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(price.trackInventory ? PCTheme.accentLight : PCTheme.border, lineWidth: 2)
                            .frame(width: 20, height: 20)
                        if price.trackInventory {
                            RoundedRectangle(cornerRadius: 3).fill(PCTheme.accentLight).frame(width: 12, height: 12)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Track Inventory").font(.system(size: 14, weight: .medium)).foregroundColor(PCTheme.textPrimary)
                        Text("Enable to set a stock quantity for this price").font(.system(size: 12)).foregroundColor(PCTheme.textMuted)
                    }
                }
            }
        }
    }
}

private struct PCEDSummarySection: View {
    let prices: [PCEDPrice]
    var body: some View {
        PCEDCard {
            VStack(alignment: .leading, spacing: 12) {
                PCEDSectionTitle(label: "PRICE SUMMARY")
                VStack(spacing: 0) {
                    HStack {
                        ForEach(["Variant","Price","Type","SKU"], id: \.self) { h in
                            Text(h).font(.system(size: 12, weight: .semibold)).foregroundColor(PCTheme.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        Text("Inventory").font(.system(size: 12, weight: .semibold)).foregroundColor(PCTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }.padding(.bottom, 10)
                    Divider().background(PCTheme.border)
                    ForEach(prices) { p in
                        HStack {
                            Text("—").frame(maxWidth: .infinity, alignment: .leading)
                            Text(String(format: "%@ %.2f", p.currency, Double(p.amount) ?? 0)).frame(maxWidth: .infinity, alignment: .leading)
                            Text(p.kind.rawValue).frame(maxWidth: .infinity, alignment: .leading)
                            Text(p.sku.isEmpty ? "—" : p.sku).frame(maxWidth: .infinity, alignment: .leading)
                            Text(p.trackInventory ? "Tracked" : "Untracked").frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .font(.system(size: 13)).foregroundColor(PCTheme.textPrimary).padding(.top, 10)
                    }
                }
            }
        }
    }
}

private struct PCEDMetaSection: View {
    @Binding var entries: [PCEDMeta]
    var body: some View {
        PCEDCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("METADATA").font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(PCTheme.textSecondary).tracking(1.5)
                    Text("optional").font(.system(size: 11, weight: .medium)).foregroundColor(PCTheme.textSecondary)
                        .padding(.horizontal, 8).padding(.vertical, 3).background(PCTheme.border).clipShape(Capsule())
                    Spacer()
                }
                Text("Extra key-value pairs sent as the metadata field (e.g. brand, material).")
                    .font(.system(size: 13)).foregroundColor(PCTheme.textSecondary)
                ForEach($entries) { $e in
                    HStack(spacing: 8) {
                        TextField("Key", text: $e.key).font(.system(size: 14)).foregroundColor(PCTheme.textPrimary)
                            .padding(.horizontal, 12).padding(.vertical, 11).background(PCTheme.surface)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(PCTheme.border, lineWidth: 1)).cornerRadius(9)
                        TextField("Value", text: $e.value).font(.system(size: 14)).foregroundColor(PCTheme.textPrimary)
                            .padding(.horizontal, 12).padding(.vertical, 11).background(PCTheme.surface)
                            .overlay(RoundedRectangle(cornerRadius: 9).stroke(PCTheme.border, lineWidth: 1)).cornerRadius(9)
                        Button { entries.removeAll { $0.id == e.id } } label: {
                            Image(systemName: "xmark").font(.system(size: 11, weight: .bold)).foregroundColor(PCTheme.deleteRed)
                                .frame(width: 30, height: 30).background(PCTheme.deleteRed.opacity(0.1)).clipShape(Circle())
                        }
                    }
                }
                Button { entries.append(PCEDMeta()) } label: {
                    Text("+ Add Metadata").font(.system(size: 14, weight: .semibold)).foregroundColor(PCTheme.accentLight)
                }
            }
        }
    }
}

// ── Edit Reusables ─────────────────────────────────────────────

private struct PCEDCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ c: () -> Content) { content = c() }
    var body: some View {
        content.padding(16).background(PCTheme.surfaceHigh).cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(PCTheme.border, lineWidth: 1))
    }
}

private struct PCEDSectionTitle: View {
    let label: String; var btnText: String? = nil; var action: (() -> Void)? = nil
    var body: some View {
        HStack {
            Text(label).font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundColor(PCTheme.textSecondary).tracking(1.5)
            Spacer()
            if let t = btnText, let a = action {
                Button(action: a) { Text("+ \(t)").font(.system(size: 14, weight: .semibold)).foregroundColor(PCTheme.accentLight) }
            }
        }
    }
}

private struct PCEDTextField: View {
    let hint: String; @Binding var text: String; var tall = false
    var body: some View {
        Group {
            if tall {
                ZStack(alignment: .topLeading) {
                    if text.isEmpty { Text(hint).font(.system(size: 15)).foregroundColor(PCTheme.textMuted).padding(.top, 4) }
                    TextEditor(text: $text).font(.system(size: 15)).foregroundColor(PCTheme.textPrimary)
                        .frame(minHeight: 80).scrollContentBackground(.hidden)
                }
            } else {
                TextField(hint, text: $text).font(.system(size: 15)).foregroundColor(PCTheme.textPrimary)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12).background(PCTheme.surface)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PCTheme.border, lineWidth: 1)).cornerRadius(10)
    }
}

private struct PCEDRadio: View {
    let label: String; let on: Bool; let tap: () -> Void
    var body: some View {
        Button(action: tap) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().stroke(on ? PCTheme.accentLight : PCTheme.border, lineWidth: 2).frame(width: 20, height: 20)
                    if on { Circle().fill(PCTheme.accentLight).frame(width: 10, height: 10) }
                }
                Text(label).font(.system(size: 15)).foregroundColor(PCTheme.textPrimary)
            }
        }
    }
}

private struct PCEDKindToggle: View {
    @Binding var selected: PCEDPriceKind
    var body: some View {
        HStack(spacing: 0) {
            ForEach(PCEDPriceKind.allCases) { k in
                Button { withAnimation(.easeInOut(duration: 0.18)) { selected = k } } label: {
                    Text(k.rawValue).font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selected == k ? .white : PCTheme.textSecondary)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(selected == k ? PCTheme.accent : Color.clear))
                }
            }
        }
        .padding(4).background(PCTheme.surface).cornerRadius(10)
    }
}

// ============================================================
// MARK: - Preview
// ============================================================

struct CreateProductView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProductView().preferredColorScheme(.dark)
    }
}












