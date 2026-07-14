//
//  CreatePaymentView.swift
//  Trading_Terminal
//

import SwiftUI

private enum CreatePaymentFocus: Hashable {
    case paymentName
}

struct CreatePaymentView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @FocusState private var focusedField: CreatePaymentFocus?
    
    @StateObject private var vm = CreatePaymentViewModel()
    
    @State private var dropdownSearch = ""
    
    @State private var showSellingDropdown             = false
    @State private var showPriceSection                = false
    @State private var selectedOutput: OutputType      = .link
    @State private var customizeExpanded               = false
    @State private var navigateToQuickPayment          = false
    @State private var navigateToViewPaymentsLinksView = false
    @State private var navigateToCreatePaymentLinkView = false
    
    enum CustomizeDestination: String, Identifiable {
        case paymentOptions, feeHandling, buyerInfo, shipping, discounts, redirects
        var id: String { rawValue }
    }
    
    @State private var navigateToCustomize: CustomizeDestination?
    
    @State private var configItems: [ConfigItem]         = ConfigItem.defaultList()

    
    private let darkBG  = Color(red: 0.07, green: 0.09, blue: 0.14)
    private let cardBG  = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let purple  = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let blue    = Color(red: 0.36, green: 0.49, blue: 0.96)
    private let cyan    = Color(red: 0.36, green: 0.82, blue: 1.0)
    private let inputBG = Color(red: 0.12, green: 0.14, blue: 0.20)
    private let border  = Color.white.opacity(0.09)
    private let green   = Color(red: 0.10, green: 0.72, blue: 0.45)
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                darkBG.ignoresSafeArea()
                    .onTapGesture { focusedField = nil }   // ← moved here, only hits background

                if showSellingDropdown {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.22)) { showSellingDropdown = false }
                        }
                }

                VStack(spacing: 0) {
                    headerBar
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            sellingAndPriceCard
                            paymentNameCard
                            customizeCard
                            configCard
                            readyCard
                            Spacer(minLength: 100)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 120)
                    }
                }

                bottomBar

                NavigationLink(destination: QuickPaymentsView(), isActive: $navigateToQuickPayment) {
                    EmptyView()
                }.hidden()

                NavigationLink(destination: paymentLinkDestination, isActive: $navigateToCreatePaymentLinkView) {
                    EmptyView()
                }.hidden()
            }
            .navigationBarHidden(true)
        }
        // ← .simultaneousGesture REMOVED from here
        .onAppear { vm.fetchProducts() }

    }
    
    // MARK: - Navigation Destination
    
    @ViewBuilder
    private var paymentLinkDestination: some View {
        CreatepaymentlinkView(
            paymentID:    vm.createdPaymentID  ?? "",
            paymentURL:   vm.createdPaymentURL ?? "",
            vm:           vm,
            initialEmail: UserDefaults.standard.string(forKey: "Bemail") ?? ""
        )
    }
    
    // MARK: - Header
    
    private var headerBar: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
            
            Text("Create Payment")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            Button { navigateToViewPaymentsLinksView = true } label: {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet.rectangle").font(.system(size: 13))
                    Text("View Payment Links").font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.12), lineWidth: 1))
                )
                
                NavigationLink(destination: ViewPaymentLinksView(), isActive: $navigateToViewPaymentsLinksView) {
                    EmptyView()
                }
            }
            .background(
                Group {
                    NavigationLink(destination: PaymentOptionsView(), tag: .paymentOptions, selection: $navigateToCustomize) { EmptyView() }
                    NavigationLink(destination: FeeHandlingView(), tag: .feeHandling, selection: $navigateToCustomize) { EmptyView() }
                    NavigationLink(destination: BuyerInfoView(), tag: .buyerInfo, selection: $navigateToCustomize) { EmptyView() }
                    NavigationLink(destination: ShippingView(), tag: .shipping, selection: $navigateToCustomize) { EmptyView() }
                    NavigationLink(destination: DiscountsView(), tag: .discounts, selection: $navigateToCustomize) { EmptyView() }
                    NavigationLink(destination: RedirectsView(), tag: .redirects, selection: $navigateToCustomize) { EmptyView() }
                }
            )
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .overlay(Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1), alignment: .bottom)
    }
    
    // MARK: - Selling + Price Card
    
    private var sellingAndPriceCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            sellingSection
            if showPriceSection, let product = vm.selectedProduct {
                priceSection(for: product)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal:   .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
        .background(cardBG)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
        .animation(.spring(response: 0.4, dampingFraction: 0.78), value: showPriceSection)
        .zIndex(showSellingDropdown ? 20 : 1)
    }
    
    private var sellingSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 13)).foregroundColor(Color.gray.opacity(0.55))
                Text("What are you selling?")
                    .foregroundColor(.white).font(.system(size: 15, weight: .semibold))
            }
            ZStack(alignment: .top) {
                dropdownTrigger
                if showSellingDropdown {
                    dropdownList.offset(y: 58).zIndex(10)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(height: showSellingDropdown ? 54 + dropdownContentHeight + 8 : 54, alignment: .top)
        }
        .padding(16)
        .animation(.easeInOut(duration: 0.22), value: showSellingDropdown)
    }
    
    private var dropdownTrigger: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.22)) { showSellingDropdown.toggle() }
        } label: {
            HStack {
                dropdownTriggerLabel
                Spacer()
                dropdownTriggerChevron
            }
            .padding(.horizontal, 16).frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: 12).fill(inputBG)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                        showSellingDropdown ? purple.opacity(0.6) : border,
                        lineWidth: showSellingDropdown ? 1.5 : 1))
            )
        }
        .buttonStyle(.plain)
    }
    
    private var dropdownTriggerLabel: some View {
        Group {
            if let product = vm.selectedProduct {
                HStack(spacing: 8) {
                    Image(systemName: product.iconName).font(.system(size: 13))
                        .foregroundColor(product.isQuickPayment ? cyan : purple)
                    Text(product.name).foregroundColor(.white).font(.system(size: 15)).lineLimit(1)
                }
            } else if let catalog = vm.selectedCatalog {
                HStack(spacing: 8) {
                    Image(systemName: "folder.fill").font(.system(size: 13))
                        .foregroundColor(purple)
                    Text(catalog.name).foregroundColor(.white).font(.system(size: 15)).lineLimit(1)
                }
            } else {
                Text("What are you selling?")
                    .foregroundColor(Color.gray.opacity(0.55)).font(.system(size: 15))
            }
        }
    }
    
    private var dropdownTriggerChevron: some View {
        Group {
            if vm.loadingState == .loading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color.gray.opacity(0.6)))
                    .scaleEffect(0.75)
            } else {
                Image(systemName: showSellingDropdown ? "chevron.up" : "chevron.down")
                    .foregroundColor(Color.gray.opacity(0.6)).font(.system(size: 13))
            }
        }
    }
    
    private var dropdownContentHeight: CGFloat {
        switch vm.loadingState {
        case .loading, .failure: return 80
        case .idle, .success:
            let rows = vm.sections.reduce(0) { $0 + $1.items.count } + vm.sections.count + 1
            return min(CGFloat(rows) * 52 + CGFloat(vm.sections.count) * 28, 360)
        }
    }
    
    private var dropdownList: some View {
        VStack(spacing: 0) { dropdownContent }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(red: 0.10, green: 0.13, blue: 0.20))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.13), lineWidth: 1))
                    .shadow(color: Color.black.opacity(0.45), radius: 20, x: 0, y: 8)
            )
    }
    
    @ViewBuilder
    private var dropdownContent: some View {
        switch vm.loadingState {
        case .loading:          dropdownLoading
        case .failure(let msg): dropdownError(msg)
        case .idle, .success:   dropdownProducts
        }
    }
    
    private var dropdownLoading: some View {
        HStack(spacing: 10) {
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: cyan))
            Text("Loading products…").foregroundColor(Color.gray.opacity(0.6)).font(.system(size: 14))
        }
        .frame(height: 80).frame(maxWidth: .infinity)
    }
    
    private func dropdownError(_ msg: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle").foregroundColor(.orange).font(.system(size: 22))
            Text(msg).foregroundColor(Color.gray.opacity(0.6)).font(.system(size: 12))
                .multilineTextAlignment(.center).lineLimit(3)
            Button { vm.fetchProducts() } label: {
                Text("Retry").foregroundColor(cyan).font(.system(size: 13, weight: .semibold))
            }.buttonStyle(.plain)
        }
        .padding(.vertical, 16).frame(maxWidth: .infinity)
    }
    
    private var dropdownProducts: some View {
        VStack(spacing: 0) {
            // ── Search bar ────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundColor(Color.gray.opacity(0.5))
                TextField("", text: $dropdownSearch, prompt: Text("Search product or catalogue name").foregroundColor(.white.opacity(0.4)))
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .tint(.white)                        // ← change purple to .white
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                if !dropdownSearch.isEmpty {
                    Button { dropdownSearch = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(Color.gray.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(Color(red: 0.08, green: 0.10, blue: 0.16))
            .overlay(
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // ── Results list ──────────────────────────────────────
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    let filteredSections = filteredDropdownSections
                    let filteredCats = filteredCatalogs
                    
                    if filteredSections.isEmpty && filteredCats.isEmpty && !dropdownSearch.isEmpty {
                        // Empty state
                        VStack(spacing: 10) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(Color.gray.opacity(0.35))
                            Text("No results for \"\(dropdownSearch)\"")
                                .font(.system(size: 14))
                                .foregroundColor(Color.gray.opacity(0.55))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        ForEach(filteredSections) { section in
                            sectionHeader(section)
                            ForEach(section.items) { product in
                                productRow(product)
                                if product.id != section.items.last?.id {
                                    Divider().background(Color.white.opacity(0.06))
                                        .padding(.horizontal, 12)
                                }
                            }
                            if section.id != filteredSections.last?.id || !filteredCats.isEmpty {
                                Divider().background(Color.white.opacity(0.06))
                            }
                        }
                        
                        if !filteredCats.isEmpty {
                            catalogSectionHeader
                            ForEach(filteredCats) { catalog in
                                catalogRow(catalog)
                                if catalog.id != filteredCats.last?.id {
                                    Divider().background(Color.white.opacity(0.06))
                                        .padding(.horizontal, 12)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxHeight: 260)
            
            if filteredDropdownSections.isEmpty && filteredCatalogs.isEmpty && !dropdownSearch.isEmpty {
                // Do not show quickPaymentRow if search has no results
            } else {
                Divider().background(Color.white.opacity(0.06))
                quickPaymentRow
            }
        }
    }
    
    private var filteredCatalogs: [CPCatalog] {
        guard !dropdownSearch.isEmpty else { return vm.allCatalogs }
        return vm.allCatalogs.filter {
            $0.name.localizedCaseInsensitiveContains(dropdownSearch)
        }
    }
    
    private var filteredDropdownSections: [ProductSection] {
        guard !dropdownSearch.isEmpty else { return vm.sections }
        return vm.sections.compactMap { section in
            let matched = section.items.filter {
                $0.name.localizedCaseInsensitiveContains(dropdownSearch) ||
                $0.priceLabel.localizedCaseInsensitiveContains(dropdownSearch)
            }
            return matched.isEmpty ? nil : ProductSection(title: section.title, items: matched)
        }
    }
    
    private var catalogSectionHeader: some View {
        HStack {
            Text("CATALOGUES")
                .foregroundColor(Color.gray.opacity(0.45))
                .font(.system(size: 10, weight: .bold)).tracking(1.1)
            Spacer()
            Text("\(filteredCatalogs.count)").foregroundColor(Color.gray.opacity(0.35)).font(.system(size: 10))
        }
        .padding(.horizontal, 16).frame(height: 28).background(Color.white.opacity(0.03))
    }
    
    private func sectionHeader(_ section: ProductSection) -> some View {
        HStack {
            Text(section.title)
                .foregroundColor(Color.gray.opacity(0.45))
                .font(.system(size: 10, weight: .bold)).tracking(1.1)
            Spacer()
            Text("\(section.items.count)").foregroundColor(Color.gray.opacity(0.35)).font(.system(size: 10))
        }
        .padding(.horizontal, 16).frame(height: 28).background(Color.white.opacity(0.03))
    }
    
    private func productRow(_ product: CPProduct) -> some View {
        let isSelected = vm.selectedProduct?.id == product.id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                vm.selectProduct(product)
                showPriceSection    = true
                showSellingDropdown = false
                
                
                dropdownSearch      = ""
            }
        } label: {
            HStack(spacing: 12) {
                productIcon(product)
                productText(product, isSelected: isSelected)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(purple).font(.system(size: 16))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16).frame(height: 52)
            .background(isSelected ? purple.opacity(0.08) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func catalogRow(_ catalog: CPCatalog) -> some View {
        let isSelected = vm.selectedCatalog?.id == catalog.id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                vm.selectCatalog(catalog)
                showPriceSection    = false
                showSellingDropdown = false
                
                dropdownSearch      = ""
            }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(purple.opacity(0.10))
                        .frame(width: 32, height: 32)
                    Image(systemName: "folder.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(purple)
                }
                
                Text(catalog.name).foregroundColor(.white)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .regular)).lineLimit(1)
                
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(purple).font(.system(size: 16))
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16).frame(height: 52)
            .background(isSelected ? purple.opacity(0.08) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func productIcon(_ product: CPProduct) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(product.isQuickPayment ? cyan.opacity(0.12) : purple.opacity(0.10))
                .frame(width: 32, height: 32)
            Image(systemName: product.iconName)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(product.isQuickPayment ? cyan : purple)
        }
    }
    
    private func productText(_ product: CPProduct, isSelected: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(product.name).foregroundColor(.white)
                .font(.system(size: 14, weight: isSelected ? .semibold : .regular)).lineLimit(1)
            Text(product.priceLabel).foregroundColor(Color.gray.opacity(0.55)).font(.system(size: 11))
        }
    }
    
    private var quickPaymentRow: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.18)) { showSellingDropdown = false }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { navigateToQuickPayment = true }
        } label: {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(cyan.opacity(0.12)).frame(width: 32, height: 32)
                    Image(systemName: "bolt.fill").font(.system(size: 13, weight: .semibold)).foregroundColor(cyan)
                }
                Text("Quick Payment").foregroundColor(cyan).font(.system(size: 15, weight: .medium)).italic()
                Spacer()
                Image(systemName: "arrow.right").font(.system(size: 12, weight: .semibold)).foregroundColor(cyan.opacity(0.7))
            }
            .padding(.horizontal, 16).frame(height: 52).background(cyan.opacity(0.06))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Price Section
    
    private func priceSection(for product: CPProduct) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)
            pricePicker
            selectedPriceBadge
        }
    }
    
    private var pricePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PRICE")
                .foregroundColor(Color.gray.opacity(0.55))
                .font(.system(size: 11, weight: .semibold)).tracking(1.1)
                .padding(.horizontal, 16)
            Menu {
                Button { withAnimation { vm.selectedPrice = nil } } label: {
                    Label("— Select price —", systemImage: vm.selectedPrice == nil ? "checkmark" : "")
                }
                Divider()
                ForEach(vm.availablePrices, id: \.priceId) { price in
                    Button { withAnimation { vm.selectedPrice = price } } label: {
                        Label(buildPriceLabel(price),
                              systemImage: vm.selectedPrice?.priceId == price.priceId ? "checkmark" : "")
                    }
                }
            } label: { pricePickerLabel }
                .padding(.horizontal, 16)
        }
        .padding(.bottom, 16)
    }
    
    private var pricePickerLabel: some View {
        HStack {
            if let price = vm.selectedPrice {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark").font(.system(size: 12, weight: .bold)).foregroundColor(purple)
                    Text(buildPriceLabel(price)).foregroundColor(.white).font(.system(size: 15))
                }
            } else {
                Text("— Select price —").foregroundColor(Color.gray.opacity(0.55)).font(.system(size: 15))
            }
            Spacer()
            Image(systemName: "chevron.down").foregroundColor(Color.gray.opacity(0.6)).font(.system(size: 13))
        }
        .padding(.horizontal, 16).frame(height: 54)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(inputBG)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(
                    vm.selectedPrice != nil ? purple.opacity(0.45) : border,
                    lineWidth: vm.selectedPrice != nil ? 1.5 : 1))
        )
    }
    
    @ViewBuilder
    private var selectedPriceBadge: some View {
        if let price = vm.selectedPrice, let cur = price.currencies.first {
            HStack(spacing: 6) {
                Text(cur.currency).foregroundColor(Color.gray.opacity(0.6)).font(.system(size: 11))
                Text(formatAmount(cur.amount)).foregroundColor(.white).font(.system(size: 13, weight: .semibold))
                if price.priceType == "recurring", let iv = price.intervalType {
                    Text("/ \(iv)").foregroundColor(Color.gray.opacity(0.5)).font(.system(size: 11))
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.08))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.14), lineWidth: 1))
            )
            .padding(.horizontal, 16).padding(.bottom, 16)
            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .leading)))
        }
    }
    
    private func buildPriceLabel(_ price: CPPrice) -> String {
        guard let cur = price.currencies.first(where: { $0.default }) ?? price.currencies.first else { return "—" }
        let amt = formatAmount(cur.amount)
        if price.priceType == "recurring", let iv = price.intervalType { return "\(cur.currency) \(amt) / \(iv)" }
        return "\(cur.currency) \(amt)"
    }
    
    private func formatAmount(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0
        ? String(format: "%.0f", v) : String(format: "%.2f", v)
    }
    
    // MARK: - Payment Name Card
    
    private var paymentNameCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Payment Name").foregroundColor(.white).font(.system(size: 16, weight: .bold))
                Spacer()
                Text("optional").foregroundColor(.gray).font(.system(size: 12))
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().stroke(Color.gray.opacity(0.35), lineWidth: 1))
            }
            TextField("", text: $vm.paymentName,
                      prompt: Text("e.g. Summer Sale Checkout").foregroundColor(.gray.opacity(0.55)))
            .focused($focusedField, equals: .paymentName)
            .foregroundColor(.white).tint(purple).font(.system(size: 15))
            .autocorrectionDisabled().textInputAutocapitalization(.words)
            .submitLabel(.done).onSubmit { focusedField = nil }
            .padding(.horizontal, 16).frame(height: 54).frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 12).fill(inputBG))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(focusedField == .paymentName ? purple : border, lineWidth: 1.5)
                    .animation(.easeInOut(duration: 0.15), value: focusedField == .paymentName)
            )
        }
        .padding(16).background(cardBG).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
    }
    
    // MARK: - Customize Card
    
    private var customizeCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            customizeHeader
            if customizeExpanded {
                VStack(spacing: 0) {
                    ForEach(vm.customizeRows.indices, id: \.self) { idx in
                        customizeRow(at: idx)
                        if idx < vm.customizeRows.count - 1 { Divider().background(Color.white.opacity(0.07)) }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16).background(cardBG).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
        .animation(.easeInOut(duration: 0.25), value: customizeExpanded)
    }
    
    private var customizeHeader: some View {
        HStack(spacing: 10) {
            Text("Customize Checkout").foregroundColor(.white).font(.system(size: 15, weight: .bold))
            Text("optional").foregroundColor(.gray).font(.system(size: 11))
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background(Capsule().stroke(Color.gray.opacity(0.35), lineWidth: 1))
            Spacer()
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { customizeExpanded.toggle() }
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: customizeExpanded ? "chevron.up" : "slider.horizontal.3")
                        .font(.system(size: 11, weight: .semibold))
                    Text(customizeExpanded ? "Hide" : "Customize").font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(purple).padding(.horizontal, 12).padding(.vertical, 7)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(purple.opacity(customizeExpanded ? 0.10 : 0))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(purple.opacity(0.45), lineWidth: 1.5))
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, customizeExpanded ? 14 : 0)
    }
    
    @ViewBuilder
    private func customizeRow(at index: Int) -> some View {
        let row = vm.customizeRows[index]
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(row.label).foregroundColor(.white).font(.system(size: 14, weight: .semibold))
                    Text("optional").foregroundColor(.gray.opacity(0.6)).font(.system(size: 11))
                }
                .frame(minWidth: 90, alignment: .leading)
                Spacer()
                let placeholder = row.key == "rewards" ? "— No Campaign —" : "— Sys Default —"
                Menu {
                    ForEach(row.options, id: \.self) { opt in
                        Button(opt) {
                            let selected = opt.hasPrefix("—") ? nil : opt
                            vm.updateCustomizeRowSelection(at: index, option: selected)
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(row.selectedOption ?? placeholder)
                            .foregroundColor(row.selectedOption == nil ? Color.gray.opacity(0.5) : .white)
                            .font(.system(size: 13)).lineLimit(1).truncationMode(.tail)
                        Image(systemName: "chevron.down").font(.system(size: 11)).foregroundColor(.gray)
                    }
                    .padding(.horizontal, 12).frame(height: 44).frame(minWidth: 130)
                    .background(
                        RoundedRectangle(cornerRadius: 10).fill(inputBG)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(border, lineWidth: 1))
                    )
                }
                .buttonStyle(.plain)
                
                if let _ = row.redirectPath {
                    Button {
                        if row.key == "paymentOptions" { navigateToCustomize = .paymentOptions }
                        else if row.key == "feeHandling" { navigateToCustomize = .feeHandling }
                        else if row.key == "buyerInfo" { navigateToCustomize = .buyerInfo }
                        else if row.key == "shipping" { navigateToCustomize = .shipping }
                        else if row.key == "discounts" { navigateToCustomize = .discounts }
                        else if row.key == "redirects" { navigateToCustomize = .redirects }
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.08))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                                )
                            Image(systemName: row.useRedirectIcon ? "arrow.up.forward" : "plus")
                                .foregroundColor(color(for: row.key))
                                .font(.system(size: 16, weight: row.useRedirectIcon ? .regular : .semibold))
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(row.btnLabel ?? "Configure")
                } else {
                    Color.clear.frame(width: 36, height: 36)
                }
            }
            if !row.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) { ForEach(row.tags) { tag in tagPill(tag) } }.padding(.horizontal, 2)
                }
            }
        }
        .padding(.vertical, 12)
    }
    
    private func tagPill(_ tag: CTag) -> some View {
        Text(tag.label).foregroundColor(tag.color).font(.system(size: 11, weight: .semibold))
            .padding(.horizontal, 10).padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(tag.bg)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(tag.border, lineWidth: 1))
            )
    }
    
    // MARK: - Config Card
    // ✅ All rows always show green tick — matching web app layout
    
    // Each static config row: title + optional right-side badge/value
    private struct ConfigRow {
        let title:  String
        var badge:  String? = nil   // purple badge e.g. "Merchant Pays"
        var isFeeHandling: Bool = false
    }
    
    // MARK: - Config Card
    
    private var configCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CONFIGURATION")
                .foregroundColor(.gray)
                .font(.system(size: 11, weight: .semibold))
                .tracking(1.2)
                .padding(.bottom, 14)
            
            VStack(spacing: 0) {
                
                // ── Payment Options ─────────────
                dynamicConfigRow(key: "paymentOptions", title: "Payment Options")
                divider
                
                // ── Fee Handling ────────────────────
                dynamicConfigRow(key: "feeHandling", title: "Fee Handling")
                divider
                
                // ── Buyer Information ─────────────
                dynamicConfigRow(key: "buyerInfo", title: "Buyer Information")
                divider
                
                // ── Shipping ──────────────────────
                dynamicConfigRow(key: "shipping", title: "Shipping")
                divider
                
                // ── Discounts ─────────────────────
                dynamicConfigRow(key: "discounts", title: "Discounts")
                divider
                
                // ── Redirects ─────────────────────
                dynamicConfigRow(key: "redirects", title: "Redirects")
                
                // ── Product — visible after user picks a product ──────────────
                if let product = vm.selectedProduct {
                    divider
                    HStack(spacing: 10) {
                        greenTick
                        Text("Product")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        badgePill(product.name, color: purple)
                    }
                    .padding(.vertical, 13)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal:   .opacity.combined(with: .move(edge: .top))
                    ))
                }
                
                // ── Price — visible after user picks a price ──────────────────
                if let price = vm.selectedPrice,
                   let cur = price.currencies.first(where: { $0.default }) ?? price.currencies.first {
                    divider
                    let orange = Color(red: 0.90, green: 0.55, blue: 0.10)
                    HStack(spacing: 10) {
                        greenTick
                        Text("Price")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        Text("\(cur.currency) \(formatAmount(cur.amount))")
                            .foregroundColor(orange)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(orange.opacity(0.12))
                                    .overlay(RoundedRectangle(cornerRadius: 20)
                                        .stroke(orange.opacity(0.4), lineWidth: 1))
                            )
                    }
                    .padding(.vertical, 13)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal:   .opacity.combined(with: .move(edge: .top))
                    ))
                }
                
                // ── Payment Name — visible after user types a name ────────────
                if !vm.paymentName.isEmpty {
                    divider
                    HStack(spacing: 10) {
                        greenTick
                        Text("Payment Name")
                            .foregroundColor(.white)
                            .font(.system(size: 15, weight: .semibold))
                        Spacer()
                        badgePill(vm.paymentName, color: Color(red: 0.36, green: 0.82, blue: 1.0))
                    }
                    .padding(.vertical, 13)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal:   .opacity.combined(with: .move(edge: .top))
                    ))
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.78), value: vm.selectedProduct?.id)
            .animation(.spring(response: 0.4, dampingFraction: 0.78), value: vm.selectedPrice?.priceId)
            .animation(.spring(response: 0.4, dampingFraction: 0.78), value: vm.paymentName)
        }
        .padding(16).background(cardBG).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
    }
    
    // ── Reusable green tick icon ─────────────────────────────────────────────
    private var greenTick: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 15, weight: .bold))
            .foregroundColor(green)
            .frame(width: 18)
    }
    
    // ── Divider between rows ─────────────────────────────────────────────────
    private var divider: some View {
        Divider().background(Color.white.opacity(0.06)).padding(.leading, 28)
    }
    
    // ── Colors for different configurations matching the web ─────────────────
    private func color(for key: String) -> Color {
        switch key {
        case "paymentOptions": return Color(red: 99/255, green: 102/255, blue: 241/255) // #6366f1
        case "feeHandling":    return Color(red: 236/255, green: 72/255, blue: 153/255) // #ec4899
        case "buyerInfo":      return Color(red: 139/255, green: 92/255, blue: 246/255) // #8b5cf6
        case "shipping":       return Color(red: 59/255, green: 130/255, blue: 246/255) // #3b82f6
        case "discounts":      return Color(red: 34/255, green: 197/255, blue: 94/255)  // #22c55e
        case "rewards":        return Color(red: 234/255, green: 179/255, blue: 8/255)  // #eab308
        case "redirects":      return Color(red: 20/255, green: 184/255, blue: 166/255) // #14b8a6
        default:               return Color(red: 0.55, green: 0.36, blue: 0.96)         // fallback
        }
    }
    
    // ── Dynamic row: matches web's tick mark and value badging ───────────────
    private func dynamicConfigRow(key: String, title: String) -> some View {
        let row = vm.customizeRows.first(where: { $0.key == key })
        
        let fallbackOptions = ["— Sys Default —", "— Sys Default —", "— No Campaign —", "None"]
        let selectedValue = row?.selectedOption
        let isSelected = selectedValue != nil && !fallbackOptions.contains(selectedValue!)
        
        let cfgColor = color(for: key)
        let greenColor = Color(red: 16/255, green: 185/255, blue: 129/255) // #10b981
        
        return HStack(spacing: 8) {
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 15))
                    .foregroundColor(greenColor)
                    .frame(width: 18)
            } else {
                Image(systemName: "circle")
                    .font(.system(size: 15))
                    .foregroundColor(Color.white.opacity(0.2))
                    .frame(width: 18)
            }
            
            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 13, weight: .regular))
                .opacity(isSelected ? 1.0 : 0.4)
            
            Spacer()
            
            if isSelected, let text = selectedValue {
                badgePill(text, color: cfgColor)
            } else {
                let fallbackText = key == "rewards" ? "No Campaign" : "Sys Default"
                badgePill(fallbackText, color: Color.gray.opacity(0.8))
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }
    
    // ── Colored badge pill ────────────────────────────────────────────────────
    private func badgePill(_ text: String, color: Color) -> some View {
        Text(text)
            .foregroundColor(color)
            .font(.system(size: 11, weight: .semibold))
            .lineLimit(1)
            .padding(.horizontal, 7).padding(.vertical, 2)
            .background(color.opacity(0.12))
            .cornerRadius(5)
    }
    
    
    // MARK: - Ready Card
    
    private var readyCard: some View {
        VStack(spacing: 0) {
            
            // ── Plus / Check circle icon ───────────────────────────
            ZStack {
                Circle()
                    .fill(vm.isReadyToCreate ? purple.opacity(0.22) : purple.opacity(0.12))
                    .frame(width: 68, height: 68)
                Circle()
                    .stroke(
                        vm.isReadyToCreate ? purple.opacity(0.55) : purple.opacity(0.30),
                        lineWidth: 1.5
                    )
                    .frame(width: 68, height: 68)
                Image(systemName: vm.isReadyToCreate ? "checkmark" : "plus.circle")
                    .foregroundColor(vm.isReadyToCreate ? purple : purple.opacity(0.85))
                    .font(.system(size: 28, weight: vm.isReadyToCreate ? .bold : .light))
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.isReadyToCreate)
            .padding(.bottom, 18)
            
            // ── Title ──────────────────────────────────────────────
            Text(vm.isReadyToCreate ? "Ready!" : "Ready to generate")
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 10)
            
            // ── Subtitle ───────────────────────────────────────────
            Text(
                vm.isReadyToCreate
                ? "Hit Create Payment Link to generate your link."
                : "Configure your checkout options above, then use the\nbutton below to generate your payment link."
            )
            .foregroundColor(Color.gray.opacity(0.65))
            .font(.system(size: 13))
            .multilineTextAlignment(.center)
            .lineSpacing(4)
            .padding(.horizontal, 8)
            .padding(.bottom, 22)
            .animation(.easeInOut(duration: 0.2), value: vm.isReadyToCreate)
            
            // ── Output type pills ──────────────────────────────────
            
            HStack(spacing: 8) {
                ForEach(OutputType.allCases, id: \.self) { type in
                    outputPill(type)
                }
            }
            .allowsHitTesting(false)   // ← blocks all touches on the entire pill row
          //  .simultaneousGesture(TapGesture())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 16)
        .background(cardBG)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
    }
    
    
    private func outputPill(_ type: OutputType) -> some View {
        let isSelected = selectedOutput == type
        return Text(type.rawValue)
            .foregroundColor(isSelected ? .white : purple.opacity(0.85))
            .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? purple.opacity(0.35) : purple.opacity(0.10))
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected ? purple.opacity(0.75) : purple.opacity(0.30),
                            lineWidth: 1.2
                        )
                }
            )
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) { createLinkButton }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(
                darkBG
                    .overlay(Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1), alignment: .top)
                    .ignoresSafeArea(edges: .bottom)
            )
    }

    private var createLinkButton: some View {
        Button {
            if vm.isReadyToCreate {
                vm.createPaymentLink {
                    navigateToCreatePaymentLinkView = true
                }
            } else {
                withAnimation(.easeInOut(duration: 0.22)) {
                    showSellingDropdown = true
                }
            }
        } label: {
            ZStack {
                if vm.isCreatingLink {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    Text("Create Payment Link")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity).frame(height: 56)
            .background(
                LinearGradient(
                    colors: [Color(red: 0.45, green: 0.35, blue: 0.90),
                             Color(red: 0.30, green: 0.22, blue: 0.70)],
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
        .disabled(vm.isCreatingLink)
    }
}

#Preview {
    CreatePaymentView().preferredColorScheme(.dark)
}






