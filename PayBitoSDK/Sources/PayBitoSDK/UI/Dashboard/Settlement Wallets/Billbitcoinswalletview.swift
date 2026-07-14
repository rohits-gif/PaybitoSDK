//////
//////  Billbitcoinswalletview.swift
//////  Trading_Terminal
//////
//////  Created by Sk Jasimuddin on 13/04/26.
//////

//

import SwiftUI

// MARK: - Root Dashboard

public struct WalletDashboardView: View {
    
    @StateObject private var vm = SettlementViewModel()
    @State private var showKYCVerification = false
    @State private var showAutoWithdrawal = false
    
    // Accent palette — matches existing bbAccentBlue / bbDarkBG
    private let accent   = Color(red: 0.55, green: 0.35, blue: 0.95)
    private let darkBG   = Color(red: 0.07, green: 0.08, blue: 0.13)
    private let cardBG   = Color(red: 0.10, green: 0.12, blue: 0.19)
    private let labelGray = Color(white: 0.48)
    
    public var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    pageHeader
                    
                    // ── Asset grid ──
                    assetsSection
                    
                    // ── Transaction table ──
                    transactionsSection
                    
                    // ── Automatic Withdrawal ──
                    autoWithdrawalSection
                    
                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
            
            // ── Toast layer ──
            toastLayer
        }
        .onAppear { vm.loadAll() }
        
        // ── Network picker (for USDT ERC20/TRC20) ──
        .sheet(isPresented: $vm.showNetworkSelectSheet) {
            NetworkSelectSheet(
                coinName: vm.selectedAsset?.currencyCode ?? "",
                networks: vm.availableNetworks,
                onSelect: { vm.onNetworkSelected($0) },
                onDismiss: { vm.showNetworkSelectSheet = false }
            )
        }
        
        // ── Withdraw type picker ──
        .fullScreenCover(isPresented: $vm.showWithdrawTypeSheet) {
            WithdrawalOptionsModal(
                coinCode: vm.selectedAsset?.currencyCode ?? "",
                onSelect: { vm.onWithdrawTypeSelected($0) },
                onDismiss: { vm.showWithdrawTypeSheet = false }
            )
            .environmentObject(vm)
        }
        
        // ── Exchange transfer form ──
        .fullScreenCover(isPresented: $vm.showExchangeTransferForm) {
            ExchangeTransferView().environmentObject(vm)
        }
        
        // ── Exchange Google Auth gate ──
        .sheet(isPresented: $vm.showExchangeAuthModal) {
            SecurityVerificationView(
                mode: .exchangeAuth,
                onConfirm: { vm.confirmExchangeTransfer() },
                onDismiss: { vm.showExchangeAuthModal = false }
            )
            .environmentObject(vm)
        }
        
        // ── External wallet form ──
        .fullScreenCover(isPresented: $vm.showExternalAddressForm) {
            ExternalWithdrawForm().environmentObject(vm)
        }
        
        // ── External wallet OTP + Google Auth ──
        .fullScreenCover(isPresented: $vm.showExternalAuthModal) {
            
            SecurityVerificationView(
                mode: .externalTransfer,
                onConfirm: {},
                onDismiss: {
                    vm.showExternalAuthModal = false
                }
            )
            .environmentObject(vm)
        }
        
        // ── Bank withdrawal form ──
        .fullScreenCover(isPresented: $vm.showBankTransferForm) {
            BankWithdrawForm().environmentObject(vm)
        }
        
        // ── KYC gate modal ──
        .fullScreenCover(isPresented: $vm.showKycStatusModal) {
            
            KycStatusModal(
                
                onSubmitKYC: {
                    
                    vm.showKycStatusModal = false
                    
                    // Navigate to KYC screen here
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        
                        showKYCVerification = true
                        
                    }
                    
                },
                
                onDismiss: {
                    
                    vm.showKycStatusModal = false
                    
                }
            )
        }
        .fullScreenCover(isPresented: $showKYCVerification) {
            
            KYCVerificationView()
            
        }
        
        // ── Global loader ──
        .overlay {
            if vm.isLoading {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.4)
                        .padding(24)
                        .background(Color(red: 0.12, green: 0.14, blue: 0.21))
                        .cornerRadius(16)
                }
            }
        }
    }
    
    // MARK: Page Header
    
    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settlement Wallets")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(.white)
            Text("Manage your crypto assets and transactions")
                .font(.system(size: 13))
                .foregroundColor(labelGray)
        }
    }
    
    // MARK: Assets Section
    // Mirrors React asset card grid
    
    @ViewBuilder
    private var assetsSection: some View {
        if vm.isLoadingAssets {
            ProgressView().tint(.white).frame(maxWidth: .infinity).padding(.vertical, 40)
        } else if vm.assets.isEmpty {
            emptyAssetsState
        } else {
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 14
            ) {
                ForEach(vm.assets) { asset in
                    AssetCard(asset: asset) {
                        vm.handleWithdrawTapped(asset: asset)
                    }
                }
            }
        }
    }
    
    private var emptyAssetsState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 40))
                .foregroundColor(Color(white: 0.30))
            Text("No assets found")
                .font(.system(size: 14))
                .foregroundColor(labelGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 50)
        .background(cardBG)
        .cornerRadius(16)
    }
    
    // MARK: Transactions Section
    // Mirrors React user transactions table
    
    @ViewBuilder
    private var transactionsSection: some View {
        VStack(spacing: 0) {
            // Header row
            HStack {
                Label("User Transactions", systemImage: "arrow.left.arrow.right")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if vm.totalTransactionCount > 0 {
                    Text("\(vm.totalTransactionCount)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(accent)
                        .cornerRadius(12)
                }
            }
            .padding(16)
            
            Divider().background(Color(white: 0.20))
            
            if vm.isLoadingTransactions {
                ProgressView().tint(.white).frame(maxWidth: .infinity).padding(32)
            } else if vm.transactions.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "doc.text")
                        .font(.system(size: 32))
                        .foregroundColor(Color(white: 0.25))
                    Text("No Transactions Yet")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(labelGray)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.transactions) { txn in
                        SettlementTransactionRow(txn: txn)
                    }
                }
                // Pagination
                if vm.totalTransactionCount > vm.pageSize {
                    paginationBar
                }
            }
        }
        .background(cardBG)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.15), lineWidth: 1)
        )
    }
    
    private var paginationBar: some View {
        let totalPages = Int(ceil(Double(vm.totalTransactionCount) / Double(vm.pageSize)))
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(1...max(1, totalPages), id: \.self) { page in
                    Button {
                        Task { await vm.fetchTransactions(page: page) }
                    } label: {
                        Text("\(page)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(vm.currentPage == page ? .white : labelGray)
                            .frame(width: 36, height: 36)
                            .background(
                                vm.currentPage == page
                                ? accent
                                : Color(white: 0.15)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: Toast Layer
    
    private var toastLayer: some View {
        VStack {
            if let msg = vm.successMessage {
                ToastView(message: msg, isSuccess: true)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            if let msg = vm.errorMessage {
                ToastView(message: msg, isSuccess: false)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .padding(.top, 8)
        .animation(.easeInOut(duration: 0.3), value: vm.successMessage)
        .animation(.easeInOut(duration: 0.3), value: vm.errorMessage)
    }
    
    
    // MARK: - Asset Card
    // Mirrors React asset card with currency_type guard
    
    private struct AssetCard: View {
        let asset: SettlementAsset
        let onWithdraw: () -> Void
        
        private let gradient = LinearGradient(
            colors: [Color(red: 0.55, green: 0.35, blue: 0.95),
                     Color(red: 0.70, green: 0.50, blue: 0.98)],
            startPoint: .leading, endPoint: .trailing
        )
        
        var body: some View {
            VStack(spacing: 0) {
                
                // Coin header
                HStack(spacing: 10) {
                    CoinIconView(url: asset.logo, code: asset.currencyCode)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(asset.currencyName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(asset.currencyCode)
                            .font(.system(size: 11))
                            .foregroundColor(Color(white: 0.48))
                    }
                    Spacer()
                }
                .padding(12)
                
                Divider().background(Color(white: 0.15))
                
                // Balance
                VStack(alignment: .leading, spacing: 2) {
                    Text("Balance")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(white: 0.45))
                        .textCase(.uppercase)
                    Text(asset.balance)
                        .font(.system(size: 15, weight: .bold).monospacedDigit())
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(asset.currencyCode)
                        .font(.system(size: 10))
                        .foregroundColor(Color(white: 0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                
                // Withdraw button — mirrors React currency_type === "1" guard
                Button(action: onWithdraw) {
                    Text(asset.isFiat ? "Withdraw via processor" : "Withdraw")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 38)
                        .background(asset.isFiat ? AnyShapeStyle(Color(white: 0.22)) : AnyShapeStyle(gradient))
                        .cornerRadius(10)
                        .opacity(asset.isFiat ? 0.55 : 1)
                }
                .disabled(asset.isFiat)
                .buttonStyle(.plain)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
            .background(Color(red: 0.10, green: 0.12, blue: 0.19))
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(white: 0.14), lineWidth: 1))
        }
    }
    
    // MARK: - Transaction Row
    // Mirrors React transaction table row with status badge
    
    private struct SettlementTransactionRow: View {
        let txn: SettlementTransaction
        
        private var statusStyle: (Color, Color) {
            switch txn.status {
            case "Confirmed": return (Color(red: 0.10, green: 0.75, blue: 0.45), Color(red: 0.10, green: 0.75, blue: 0.45).opacity(0.12))
            case "Pending":   return (Color(red: 0.95, green: 0.65, blue: 0.10), Color(red: 0.95, green: 0.65, blue: 0.10).opacity(0.12))
            default:          return (Color(red: 0.90, green: 0.30, blue: 0.30), Color(red: 0.90, green: 0.30, blue: 0.30).opacity(0.12))
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Left: ID + desc + timestamp
                    VStack(alignment: .leading, spacing: 3) {
                        Text("#\(txn.transactionId ?? "–")")
                            .font(.system(size: 12, weight: .semibold).monospaced())
                            .foregroundColor(Color(red: 0.55, green: 0.35, blue: 0.95))
                        if let desc = txn.description {
                            Text(desc)
                                .font(.system(size: 12))
                                .foregroundColor(Color(white: 0.55))
                                .lineLimit(1)
                        }
                        if let ts = txn.transactionTimestamp {
                            Text(formattedTimestamp(ts))
                                .font(.system(size: 10))
                                .foregroundColor(Color(white: 0.38))
                        }
                    }
                    Spacer()
                    // Right: amount + asset + status
                    VStack(alignment: .trailing, spacing: 4) {
                        if let amt = txn.debitAmount, !amt.isEmpty {
                            Text(amt)
                                .font(.system(size: 13, weight: .bold).monospacedDigit())
                                .foregroundColor(Color(red: 0.10, green: 0.75, blue: 0.45))
                        }
                        if let name = txn.name {
                            Text(name)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(Color(white: 0.48))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(white: 0.15))
                                .cornerRadius(4)
                        }
                        // Status badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusStyle.0)
                                .frame(width: 5, height: 5)
                            Text(txn.status ?? "–")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(statusStyle.0)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(statusStyle.1)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(statusStyle.0.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                Divider().background(Color(white: 0.12)).padding(.horizontal, 16)
            }
        }
        
        private func formattedTimestamp(_ raw: String) -> String {
            let parser = DateFormatter()
            parser.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let display = DateFormatter()
            display.dateFormat = "MMM d, yyyy h:mm a"
            if let date = parser.date(from: raw) {
                return display.string(from: date)
            }
            return raw
        }
    }
    
    // MARK: - Network Select Sheet
    // Mirrors React showNetworkPopup modal for USDT ERC20/TRC20
    
    private struct NetworkSelectSheet: View {
        let coinName: String
        let networks: [String]
        let onSelect: (String) -> Void
        let onDismiss: () -> Void
        
        var body: some View {
            ZStack(alignment: .bottom) {
                Color.black.opacity(0.5).ignoresSafeArea().onTapGesture { onDismiss() }
                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color(white: 0.3))
                        .frame(width: 36, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    Text("Select Network")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.bottom, 20)
                    VStack(spacing: 10) {
                        ForEach(networks, id: \.self) { net in
                            Button {
                                onSelect(net)
                            } label: {
                                Text("\(coinName) \(net)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(Color(red: 0.12, green: 0.14, blue: 0.21))
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(white: 0.18), lineWidth: 1))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    Button("Cancel") { onDismiss() }
                        .foregroundColor(Color(white: 0.6))
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
                .background(
                    Color(red: 0.09, green: 0.10, blue: 0.16)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24))
                )
            }
            .ignoresSafeArea()
        }
    }
    
    // MARK: - Coin Icon (AsyncImage + letter fallback)
    
    struct CoinIconView: View {
        let url: String
        let code: String
        
        private var fallbackColor: Color {
            let palette: [Color] = [
                Color(red: 0.80, green: 0.65, blue: 0.10),
                Color(red: 0.10, green: 0.65, blue: 0.45),
                Color(red: 0.35, green: 0.45, blue: 0.85),
                Color(red: 0.55, green: 0.35, blue: 0.95),
                Color(red: 0.95, green: 0.50, blue: 0.10),
            ]
            return palette[abs(code.hashValue) % palette.count]
        }
        
        var body: some View {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .success(let img):
                    img.resizable().scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                default:
                    ZStack {
                        Circle().fill(fallbackColor).frame(width: 36, height: 36)
                        Text(String(code.prefix(1)))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .frame(width: 36, height: 36)
        }
    }
    private var autoWithdrawalSection: some View {
        VStack(spacing: 0) {
            // Header / toggle button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showAutoWithdrawal.toggle()
                }
            } label: {
                HStack {
                    Label("Automatic Withdrawal", systemImage: "arrow.clockwise.circle")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: showAutoWithdrawal ? "chevron.up" : "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(white: 0.48))
                }
                .padding(16)
            }
            .buttonStyle(.plain)
            
            if showAutoWithdrawal {
                Divider().background(Color(white: 0.20))
                AutoWithdrawalView()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(cardBG)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(white: 0.15), lineWidth: 1)
        )
    }
}
// MARK: - Toast
//
//struct ToastView: View {
//    let message: String
//    let isSuccess: Bool
//    let onDismiss: () -> Void
//
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
//                .foregroundColor(.white)
//            Text(message)
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(.white)
//                .lineLimit(2)
//            Spacer()
//            Button(action: onDismiss) {
//                Image(systemName: "xmark")
//                    .font(.system(size: 11, weight: .bold))
//                    .foregroundColor(.white.opacity(0.6))
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(isSuccess
//                    ? Color(red: 0.10, green: 0.60, blue: 0.35)
//                    : Color(red: 0.75, green: 0.20, blue: 0.20)
//                )
//        )
//        .padding(.horizontal, 16)
//    }
//}

// MARK: - Preview

#Preview {
    WalletDashboardView()
}
