import SwiftUI

// MARK: - Color Palette

extension Color {
    static let bbDarkBG       = Color(red: 0.08, green: 0.10, blue: 0.16)
    static let bbCardBG       = Color(red: 0.12, green: 0.15, blue: 0.22)
    static let bbAccentBlue   = Color(red: 0.20, green: 0.40, blue: 0.95)
    static let bbAccentGreen  = Color(red: 0.10, green: 0.72, blue: 0.45)
    static let bbAccentOrange = Color(red: 0.90, green: 0.55, blue: 0.10)
    static let bbBorder       = Color.white.opacity(0.10)
    static let bbLabelGray    = Color.white.opacity(0.55)
}

// MARK: - Root View

struct BillBitcoinsDashboardView: View {
    @State private var showWalletDashboard = false

    @StateObject private var vm = PaymentDashboardViewModel()

    private var dateBadge: String {
        let f = DateFormatter()
        f.dateFormat = "EEE, MMM dd, yyyy"
        return f.string(from: Date())
    }

    var body: some View {
        ZStack {
            Color.bbDarkBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    TitleRow(dateBadge: dateBadge)

                    StattCard(
                        icon: "chart.line.uptrend.xyaxis",
                        iconColor: .bbAccentBlue,
                        title: vm.uiData.totalProcessedLabel,
                        value: vm.formatCurrency(vm.uiData.totalProcessed),
                        badge: vm.uiData.successfulTransactions == 0 ? "0" : "Live",
                        badgeColor: .white,
                        rightText: "Change in last 24H"
                    )

                    StattCard(
                        icon: "checkmark.circle.fill",
                        iconColor: .bbAccentGreen,
                        title: vm.uiData.successLabel,
                        value: "\(vm.uiData.successfulTransactions)",
                        badge: vm.uiData.successfulTransactions == 0 ? "No transactions" : "Live",
                        badgeColor: .bbAccentGreen,
                        rightText: "\(vm.uiData.successRate)% success"
                    )

                    StattCard(
                        icon: "building.columns.fill",
                        iconColor: .bbAccentBlue,
                        title: vm.uiData.availableLabel,
                        value: vm.formatCurrency(vm.uiData.availableBalance),
                        badge: "Ready to withdraw",
                        badgeColor: .bbAccentBlue,
                        rightText: "Settled balance"
                    )
                    .contentShape(Rectangle())

                    .onTapGesture {

                        showWalletDashboard = true

                    }

                    QuickActionsSection()
                    AccountStatusSection(vm: vm)
                    RecentTransactionsSection(vm: vm)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .task {
            print("🚀 Dashboard Loaded")
            print("🔍 Merchant ID:", UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "nil")
            await vm.fetchAllDashboardData()
        }
        .alert("Error",
               isPresented: $vm.showError,
               actions: { Button("OK", role: .cancel) {} },
               message: { Text(vm.errorMessage ?? "") })
        .sheet(isPresented: $showWalletDashboard) {

            WalletDashboardView()

        }
        
    }
}

// MARK: - Title Row

private struct TitleRow: View {
    let dateBadge: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Dashboard")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text("Track revenue, manage actions, and monitor activity.")
                    .font(.system(size: 12))
                    .foregroundColor(.bbLabelGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            HStack(spacing: 6) {
                Circle()
                    .fill(Color.bbAccentGreen)
                    .frame(width: 8, height: 8)
                Text(dateBadge)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .fixedSize()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.bbCardBG)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.bbBorder, lineWidth: 1))
        }
    }
}

// MARK: - Stat Card

private struct StattCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    var badge: String?     = nil
    var badgeColor: Color? = nil
    let rightText: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.bbCardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(iconColor.opacity(0.6), lineWidth: 1.5)
                )

            RoundedRectangle(cornerRadius: 2)
                .fill(iconColor)
                .frame(width: 4)
                .padding(.vertical, 14)
                .frame(maxHeight: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(iconColor.opacity(0.20))
                            .frame(width: 48, height: 48)
                        Image(systemName: icon)
                            .resizable().scaledToFit()
                            .frame(width: 22, height: 22)
                            .foregroundColor(iconColor)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text(title)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.bbLabelGray)
                        Text(value)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 16)
                .padding(.trailing, 16)
                .padding(.leading, 20)

                Rectangle()
                    .fill(Color.bbBorder)
                    .frame(height: 0.5)
                    .padding(.horizontal, 12)
                    .padding(.top, 14)

                HStack {
                    if let badge = badge, let badgeColor = badgeColor {
                        BBBadge(text: badge, color: badgeColor)
                    }
                    Spacer()
                    Text(rightText)
                        .font(.system(size: 11))
                        .foregroundColor(.bbLabelGray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
    }
}

// MARK: - Quick Actions

private struct QuickActionsSection: View {
    @State private var showCreatePayment = false
    @State private var showCreateProduct = false
    @State private var showWithdrawFunds = false

    var body: some View {
        BBCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("⚡ Quick Actions")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Text("Click to proceed")
                        .font(.system(size: 12))
                        .foregroundColor(.bbLabelGray)
                }
                .padding([.top, .horizontal], 16)

                BBDivider().padding(.top, 14)

                HStack(spacing: 12) {
                    ActionTile(icon: "creditcard.fill",
                               title: "Create Payment",
                               subtitle: "Payment button / link",
                               color: .bbAccentBlue)
                        .onTapGesture { showCreatePayment = true }

                    ActionTile(icon: "arrow.2.squarepath",
                               title: "Create Product",
                               subtitle: "Recurring billing",
                               color: .bbAccentGreen)
                        .onTapGesture { showCreateProduct = true }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)

                ActionTile(icon: "arrow.up.circle.fill",
                           title: "Withdraw Funds",
                           subtitle: "To wallet or bank",
                           color: .bbAccentOrange)
                    .onTapGesture { showWithdrawFunds = true }
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 14)

            }
            // ✅ Full screen sheets for each action
            .sheet(isPresented: $showCreatePayment) {
                CreatePaymentView()
            }
            .sheet(isPresented: $showCreateProduct) {
                CreateProductView()
            }
            .sheet(isPresented: $showWithdrawFunds) {
                WalletDashboardView()

            }
        }
        .sheet(isPresented: $showCreatePayment) { CreatePaymentView() }
        .sheet(isPresented: $showCreateProduct) { CreateProductView() }
        .sheet(isPresented: $showWithdrawFunds) { WalletDashboardView() }
    }
}

private struct ActionTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .resizable().scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(.bbLabelGray)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 80, alignment: .leading)
        .background(color.opacity(0.12))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.30), lineWidth: 1))
    }
}



// MARK: - Account Status

private struct AccountStatusSection: View {
    @ObservedObject var vm: PaymentDashboardViewModel
    @State private var showBankDetails      = false
    @State private var showWithdrawalTier   = false

    var body: some View {
        BBCard {
            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Text("Account Status")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)

                BBDivider()

                VStack(spacing: 0) {

                    StatusRow(title: "Account Status") {
                        BBBadge(
                            text: vm.uiData.accountStatus == .active ? "Active" : "Not Active",
                            color: vm.uiData.accountStatus == .active ? .bbAccentGreen : .bbAccentOrange
                        )
                    }
                    BBDivider()

                    StatusRow(title: "Withdrawal Tier") {
                        HStack(spacing: 8) {
                            BBBadge(text: "Tier \(vm.uiData.withdrawalTier)", color: .bbAccentBlue)
                            if vm.uiData.withdrawalTier < 3 {
                                Button { showWithdrawalTier = true } label: {
                                    Text("Complete Tier \(vm.uiData.withdrawalTier + 1)")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.bbAccentBlue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    BBDivider()

                    StatusRow(title: "Withdrawable Limit") {
                        let amt = vm.uiData.remainingBeforeKyc
                        let currency = UserDefaults.standard.string(forKey: "BhomeCurrency") ?? "USD"
                        BBBadge(
                            text: "\(amt) \(currency)",
                            color: .bbAccentOrange
                        )
                    }
                    BBDivider()

                    StatusRow(title: "Settlement Bank") {
                        switch vm.uiData.bankDetailsStatus {
                        case .notSubmitted:
                            Button { showBankDetails = true } label: {    // ✅ triggers sheet
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill").font(.system(size: 12))
                                    Text("Add Bank").font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Color.bbAccentBlue).cornerRadius(8)
                            }
                        case .submitted:
                            Button { showBankDetails = true } label: {
                                Text("+ Submitted")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.bbAccentBlue).clipShape(Capsule())
                            }
                        case .completed:
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 12)).foregroundColor(.white)
                                Text("✓ Completed")
                                    .font(.system(size: 11, weight: .semibold)).foregroundColor(.white)
                            }
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Color.bbAccentGreen).cornerRadius(8)
                        case .rejected:
                            Button { showBankDetails = true } label: {
                                BBBadge(text: "✗ Rejected — Resubmit", color: .red)
                            }
                        }
                    }
                    BBDivider()

                    StatusRow(title: "Settlement Wallet") {
                        if vm.uiData.walletAddressAdded {
                            BBBadge(text: "✓ Completed", color: .bbAccentGreen)
                        } else {
                            Button { } label: {
                                Text("Completed")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .background(Color.bbAccentGreen).cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
        // ✅ "Add Bank" and all bank-related taps → AddBankDetailsView
        .sheet(isPresented: $showBankDetails) { AddBankDetailsView() }
        .sheet(isPresented: $showWithdrawalTier) { EnterpriseKycFormView() }
    }
}

private struct StatusRow<Right: View>: View {
    let title: String
    @ViewBuilder let right: () -> Right

    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.75))
                .frame(maxWidth: .infinity, alignment: .leading)
            right()
        }
        .frame(minHeight: 52)
    }
}

// MARK: - Recent Transactions Section

private struct RecentTransactionsSection: View {
    @ObservedObject var vm: PaymentDashboardViewModel
    @State private var localSearch: String = ""
    // ✅ Selected transaction drives the detail sheet
    @State private var selectedTransaction: PaymentTransaction? = nil

    var body: some View {
        BBCard {
            VStack(alignment: .leading, spacing: 0) {

                // Header
                HStack(spacing: 12) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.bbAccentBlue)
                    Text("Recent Transactions")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 14)

                // Tab Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(PaymentDashboardViewModel.TransactionTab.allCases, id: \.self) { tab in
                            let isSelected = vm.selectedTab == tab
                            Button { vm.selectedTab = tab } label: {
                                Text(tabLabel(tab))
                                    .font(.system(size: 13, weight: isSelected ? .bold : .regular))
                                    .foregroundColor(isSelected ? .white : .bbLabelGray)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(isSelected ? Color.bbAccentBlue : Color.white.opacity(0.07))
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(isSelected ? Color.clear : Color.white.opacity(0.15), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                }

                // Search Bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.bbLabelGray)
                        .font(.system(size: 14))
                    TextField("", text: $localSearch, prompt:
                        Text("Search by name, email or TXN ID")
                            .foregroundColor(.bbLabelGray)
                            .font(.system(size: 13))
                    )
                    .foregroundColor(.white)
                    .font(.system(size: 13))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: localSearch) { newValue in
                        vm.searchText = newValue
                    }
                    if !localSearch.isEmpty {
                        Button {
                            localSearch = ""
                            vm.searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.bbLabelGray)
                                .font(.system(size: 14))
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.06))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.10), lineWidth: 1))
                .padding(.horizontal, 16)
                .padding(.bottom, 12)

                BBDivider()

                if vm.recentTransactions.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: localSearch.isEmpty ? "tray" : "magnifyingglass")
                            .font(.system(size: 32))
                            .foregroundColor(.bbLabelGray)
                        Text(localSearch.isEmpty ? "No transactions yet" : "No results for \"\(localSearch)\"")
                            .font(.system(size: 14))
                            .foregroundColor(.bbLabelGray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)

                } else {
                    VStack(spacing: 10) {
                        ForEach(Array(vm.recentTransactions.prefix(5))) { txn in
                            // ✅ Each row is tappable → opens PaymentDetailsView
                            TransactionRowD(txn: txn, vm: vm)
                                .contentShape(Rectangle())
                                .onTapGesture { selectedTransaction = txn }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 12)

                    if vm.totalTransactionCount > 5 {
                        BBDivider()
                        Text("Showing 5 of \(vm.totalTransactionCount) entries")
                            .font(.system(size: 11))
                            .foregroundColor(.bbLabelGray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 10)
                    }
                }
            }
        }
        // ✅ Sheet opens PaymentDetailsView with full API-driven detail
        .sheet(item: $selectedTransaction) { txn in
            PaymentDetailsView(transaction: txn, dashboardVM: vm)
        }
    }

    private func tabLabel(_ tab: PaymentDashboardViewModel.TransactionTab) -> String {
        switch tab {
        case .all:        return "All"
        case .succeeded:  return "Success"
        case .failed:     return "Failed"
        case .processing: return "Processing"
        case .refunded:   return "Refunded"
        case .test:       return "Test User"
        }
    }
}

// MARK: - Transaction Card Row

private struct TransactionRowD: View {
    let txn: PaymentTransaction
    @ObservedObject var vm: PaymentDashboardViewModel

    private var productName: String {
        txn.productDetails?.first?.productName ?? "—"
    }
    private var productType: String {
        txn.catalogueName != nil ? "RECURRING" : "ONE-TIME"
    }
    private var productTypeColor: Color {
        productType == "RECURRING" ? .bbAccentBlue : .bbAccentGreen
    }
    private var amountDisplay: String {
        let base = txn.baseAmount ?? 0
        let cur  = txn.currency ?? ""
        if base > 0 {
            if cur == "USD" { return String(format: "$%.2f", base) }
            return String(format: "%.4f %@", base, cur)
        }
        return vm.formatCurrency(txn.amount ?? 0)
    }
    private var feeDisplay: String? {
        guard let fee = txn.feeAmount, fee > 0 else { return nil }
        let cur = txn.currency ?? ""
        return String(format: "Fee: %.6f %@", fee, cur)
    }

    var body: some View {
        VStack(spacing: 0) {

            // Row 1: TXN ID + Status + Arrow
            HStack(alignment: .center) {
                Text("#\(String(txn.transactionId ?? 0))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.bbAccentBlue)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Color.bbAccentBlue.opacity(0.15))
                    .cornerRadius(6)

                Spacer()

                HStack(spacing: 5) {
                    Circle()
                        .fill(vm.statusColor(txn.status))
                        .frame(width: 7, height: 7)
                    Text(vm.statusLabel(txn.status))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(vm.statusColor(txn.status))
                        .lineLimit(1)
                }

                // ✅ Arrow — signals tappability
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.bbLabelGray)
                    .padding(.leading, 8)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)

            // Row 2: Product Name
            Text(productName)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 8)

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5)
                .padding(.horizontal, 12)
                .padding(.top, 10)

            // Row 3: Type + Amount + Date
            HStack(alignment: .center) {
                Text(productType)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(productTypeColor)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(productTypeColor.opacity(0.15))
                    .cornerRadius(5)

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(amountDisplay)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    if let fee = feeDisplay {
                        Text(fee)
                            .font(.system(size: 10))
                            .foregroundColor(.bbLabelGray)
                    }
                }

                Text(vm.formatDate(txn.createdAt))
                    .font(.system(size: 10))
                    .foregroundColor(.bbLabelGray)
                    .padding(.leading, 12)
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(Color.white.opacity(0.04))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
    }
}

// MARK: - Shared Atoms

struct BBBadge: View {
    let text: String
    let color: Color
    var body: some View {
        Text("  \(text)  ")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(color)
            .background(color.opacity(0.18))
            .clipShape(Capsule())
    }
}

struct BBActionButton: View {
    let title: String
    let color: Color
    var body: some View {
        Text(title)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 14).padding(.vertical, 6)
            .background(color).cornerRadius(10)
    }
}

struct BBDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.bbBorder)
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
    }
}

struct BBCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.bbCardBG)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bbBorder, lineWidth: 1))
            VStack(alignment: .leading, spacing: 0) { content() }
        }
    }
}

// MARK: - Preview

#Preview {
    BillBitcoinsDashboardView()
}
