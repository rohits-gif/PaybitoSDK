// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  UserManagementView.swift
//  Trading_Terminal
//
//  Integrated with UserManagementViewModel + Alamofire API
//

import SwiftUI

// MARK: - All menu names (for Add flow)

fileprivate let allMenus = [
    "Get Started","Dashboard","Create Payment","Products","Transactions",
    "Settlement Wallets","Add Crypto Address","Add Bank","Insights",
    "User Management","Payment Setup","Payment Options","Fee Handling",
    "Buyer Info","Shipping","Discounts","Rewards","Redirects","Limits",
    "Payment Tolerance","API Keys","API","Domain Whitelisting",
    "Webhooks","Profile","User Settings","Business Settings"
]

// MARK: - Main View

struct UserManagementView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = UserManagementViewModel()

    @State private var showAddUser = false

    // ── Dynamic merchant ID — same UserDefaults key used across the project ──
    private var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    pageHeader
                    statsRow
                    subMerchantTableCard
                    Spacer().frame(height: 80)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }

            // FAB
            Button(action: { showAddUser = true }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(red: 0.20, green: 0.40, blue: 0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.blue.opacity(0.5), radius: 12, x: 0, y: 6)
            }
            .padding(.trailing, 20).padding(.bottom, 28)

            // Loading overlay
            if viewModel.isLoading {
                Color.black.opacity(0.35).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.4)
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
            Button("Retry") { viewModel.loadSubMerchants(merchantId: merchantId) }
        } message: {
            Text(viewModel.errorMessage ?? "Unknown error")
        }
        .fullScreenCover(isPresented: $showAddUser) {
            AddSubMerchantView { _ in
                // After creation, refresh the list
                viewModel.loadSubMerchants(merchantId: merchantId)
            }
        }
        .onAppear {
            debugPrint("[UserManagementView] onAppear — merchantId: \(merchantId)")
            viewModel.loadSubMerchants(merchantId: merchantId)
        }
    }

    // MARK: – Header

    private var pageHeader: some View {
        HStack(alignment: .top) {
            HStack(spacing: 12) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("User Management")
                        .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                    Text("Manage sub-accounts and access permissions")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.50))
                }
            }
            Spacer()
            Button(action: { showAddUser = true }) {
                Text("Add User")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(Color(red: 0.20, green: 0.40, blue: 0.95))
                    .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: – Stats Row

    private var statsRow: some View {
        HStack(spacing: 10) {
            UMStatCard(label: "Total Users",   value: "\(viewModel.totalUsers)",        valueColor: .white)
            UMStatCard(label: "Active Users",  value: "\(viewModel.activeUsers)",       valueColor: Color(red: 0.10, green: 0.75, blue: 0.50))
            UMStatCard(label: "Access Menus",  value: "\(viewModel.totalAccessMenus)", valueColor: Color(red: 0.45, green: 0.35, blue: 0.90))
        }
    }

    // MARK: – Sub-Merchant Card List

    private var subMerchantTableCard: some View {
        VStack(spacing: 12) {
            // ── Section Header ──────────────────────────────────────
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sub-Merchant Accounts")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text("\(viewModel.merchants.count) user\(viewModel.merchants.count == 1 ? "" : "s") registered")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.45))
                }
                Spacer()
                Button(action: { viewModel.refresh() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.60))
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }

            // ── Empty State ─────────────────────────────────────────
            if viewModel.merchants.isEmpty && !viewModel.isLoading {
                VStack(spacing: 10) {
                    Image(systemName: "person.2.slash")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.20))
                    Text("No sub-merchants found")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.35))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 44)
                .background(Color(red: 0.10, green: 0.12, blue: 0.19))
                .cornerRadius(14)
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                }
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.merchants, id: \.merchantId) { merchant in
                        MerchantCard(merchant: merchant)
                    }
                }
            }
        }
    }
}

// MARK: - Merchant Card  (mobile-first, full-width)

fileprivate struct MerchantCard: View {
    let merchant: SubMerchantAPIModel

    private let purple  = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let cardBg  = Color(red: 0.10, green: 0.12, blue: 0.19)
    private let rowBg   = Color(red: 0.12, green: 0.15, blue: 0.22)

    var body: some View {
        VStack(spacing: 0) {

            // ── Top Row: Avatar + Name/Email + Details btn ───────────
            HStack(spacing: 12) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [purple, Color(red: 0.20, green: 0.40, blue: 0.95)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                    Text(merchant.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }

                // Name + Email
                VStack(alignment: .leading, spacing: 3) {
                    Text(merchant.fullName)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(merchant.email)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Details button
                Button(action: {
                    debugPrint("[UMView] Details tapped: \(merchant.fullName) id=\(merchant.merchantId)")
                }) {
                    HStack(spacing: 4) {
                        Text("Details")
                            .font(.system(size: 12, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(purple)
                    .padding(.horizontal, 12).padding(.vertical, 7)
                    .background(purple.opacity(0.12))
                    .cornerRadius(8)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(purple.opacity(0.40), lineWidth: 1)
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 14).padding(.top, 14).padding(.bottom, 10)

            // ── Divider ──────────────────────────────────────────────
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
                .padding(.horizontal, 14)

            // ── Bottom Row: Phone pill + Status badge ────────────────
            HStack(spacing: 8) {
                // Phone
                HStack(spacing: 6) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.45))
                    Text(merchant.phone)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.70))
                        .lineLimit(1)
                }
                .padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color.white.opacity(0.06))
                .cornerRadius(20)

                Spacer()

                // Status badge
                StatusBadge(statusId: merchant.accountStatusId, label: merchant.accountStatusDisplay)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
        }
        .background(cardBg)
        .cornerRadius(14)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.09), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.18), radius: 6, x: 0, y: 3)
    }
}


// MARK: - Status Badge

fileprivate struct StatusBadge: View {
    let statusId: Int
    let label:    String

    private var badgeColor: Color {
        switch statusId {
        case 0:  return Color(red: 0.10, green: 0.75, blue: 0.50)   // Unlocked – green
        case 1:  return Color(red: 0.85, green: 0.25, blue: 0.25)   // Disabled – red
        case 2:  return Color(red: 0.20, green: 0.60, blue: 0.95)   // Opened – blue
        case 3:  return Color(red: 0.10, green: 0.75, blue: 0.50)   // Email Confirmed – green
        case 4:  return Color(red: 0.95, green: 0.65, blue: 0.10)   // Bank Pending – amber
        case 5:  return Color(red: 0.10, green: 0.75, blue: 0.50)   // Bank Verified – green
        case 6:  return Color(red: 0.95, green: 0.65, blue: 0.10)   // Basic Requested – amber
        case 7:  return Color(red: 0.10, green: 0.75, blue: 0.50)   // Basic Success – green
        case 8:  return Color(red: 0.45, green: 0.35, blue: 0.90)   // Biz Requested – purple
        case 9:  return Color(red: 0.10, green: 0.75, blue: 0.50)   // Biz Activated – green
        case 10: return Color(red: 0.45, green: 0.35, blue: 0.90)   // Enterprise Requested – purple
        case 11: return Color(red: 0.10, green: 0.75, blue: 0.50)   // Enterprise Activated – green
        case 40: return Color(red: 0.50, green: 0.50, blue: 0.55)   // Deleted – grey
        default: return Color(red: 0.50, green: 0.50, blue: 0.55)
        }
    }

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .padding(.horizontal, 8).padding(.vertical, 4)
            .background(badgeColor.opacity(0.25))
            .overlay {
                RoundedRectangle(cornerRadius: 6).stroke(badgeColor, lineWidth: 1)
            }
            .cornerRadius(6)
    }
}

// MARK: - Stat Card

fileprivate struct UMStatCard: View {
    let label: String
    let value: String
    let valueColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11)).foregroundColor(.white.opacity(0.50))
            Text(value)
                .font(.system(size: 22, weight: .bold)).foregroundColor(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
    }
}
//// MARK: - Previews
//
#Preview("List") { UserManagementView() }
