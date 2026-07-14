//
//  DiscountsView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 14/04/26.
//

//
//import SwiftUI
//
//// MARK: - Color Extensions
extension Color {
    static let appBackground = Color(red: 0.08, green: 0.09, blue: 0.12)
    static let appCardBackground = Color(red: 0.11, green: 0.13, blue: 0.17)
    static let appNavBackground = Color(red: 0.06, green: 0.07, blue: 0.10)
    static let appPurple = Color(red: 0.56, green: 0.27, blue: 0.90)
    static let appGreen = Color(red: 0.20, green: 0.85, blue: 0.55)
    static let appCyan = Color(red: 0.25, green: 0.75, blue: 0.95)
    static let appBlue = Color(red: 0.23, green: 0.55, blue: 0.98)
    static let tabSelected = Color(red: 0.45, green: 0.35, blue: 0.95)
    static let tabUnselected = Color(red: 0.55, green: 0.58, blue: 0.65)
    static let subtitleText = Color(red: 0.55, green: 0.58, blue: 0.65)
}
//
//// MARK: - Tab Items
//enum TabItem: CaseIterable {
//    case dashboard, getPaid, transactions, wallets, analytics
//
//    var title: String {
//        switch self {
//        case .dashboard: return "Dashboard"
//        case .getPaid: return "Get Paid"
//        case .transactions: return "Transactions"
//        case .wallets: return "Wallets"
//        case .analytics: return "Analytics"
//        }
//    }
//
//    var iconName: String {
//        switch self {
//        case .dashboard: return "square.grid.2x2.fill"
//        case .getPaid: return "house"
//        case .transactions: return "list.bullet.rectangle"
//        case .wallets: return "wallet.pass"
//        case .analytics: return "chart.bar"
//        }
//    }
//}
//
//
//
//// MARK: - Discounts Page Header
//struct DiscountsPageHeader: View {
//    @Environment(\.dismiss) private var dismiss
//    var body: some View {
//        HStack(alignment: .top, spacing: 14) {
//            // Back Button
//            Button(action: {dismiss() })  {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(.white)
//            }
//
//            VStack(alignment: .leading, spacing: 3) {
//                Text("Discounts")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.white)
//
//                Text("Create rule-based cart discounts — up to\n50 rules per profile")
//                    .font(.system(size: 12.5, weight: .regular))
//                    .foregroundColor(Color.subtitleText)
//                    .lineLimit(2)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//
//            Spacer()
//
//            // Add Profile Button
//            Button(action: {}) {
//                HStack(spacing: 5) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 13, weight: .bold))
//                    Text("Add Profile")
//                        .font(.system(size: 14, weight: .semibold))
//                }
//                .foregroundColor(.white)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 10)
//                .background(Color.appPurple)
//                .cornerRadius(22)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 14)
//        .background(Color.appNavBackground)
//    }
//}
//
//// MARK: - Empty State View
//struct DiscountsEmptyState: View {
//    var body: some View {
//        VStack(spacing: 16) {
//            Spacer()
//
//            // Tag icon
//            Image(systemName: "tag.fill")
//                .font(.system(size: 44, weight: .regular))
//                .foregroundColor(Color.appGreen)
//                .padding(.bottom, 4)
//
//            VStack(spacing: 8) {
//                Text("No discounts profiles")
//                    .font(.system(size: 18, weight: .semibold))
//                    .foregroundColor(.white)
//
//                Text("Create a profile and add rules like\n\"If cart > $100 → 10% off\"")
//                    .font(.system(size: 14, weight: .regular))
//                    .foregroundColor(Color.subtitleText)
//                    .multilineTextAlignment(.center)
//                    .lineSpacing(3)
//            }
//
//            Spacer()
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal, 32)
//    }
//}
//
//// MARK: - Floating Action Button
//struct FloatingActionButton: View {
//    var body: some View {
//        VStack {
//            Spacer()
//            HStack {
//                Spacer()
//                Button(action: {}) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 24, weight: .semibold))
//                        .foregroundColor(.white)
//                        .frame(width: 60, height: 60)
//                        .background(Color.appCyan)
//                        .clipShape(RoundedRectangle(cornerRadius: 18))
//                        .shadow(color: Color.appCyan.opacity(0.4), radius: 12, x: 0, y: 6)
//                }
//                .padding(.trailing, 20)
//                .padding(.bottom, 16)
//            }
//        }
//    }
//}
//
//
//
//// MARK: - Main Discounts View
//struct DiscountsView: View {
//    @State private var selectedTab: TabItem = .dashboard
//
//    var body: some View {
//        ZStack {
//            Color.appBackground.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // Top Navigation Bar
//             //   TopHeaderBar()
//
//                // Page Header
//                DiscountsPageHeader()
//
//                // Thin divider
//                Rectangle()
//                    .fill(Color.white.opacity(0.06))
//                    .frame(height: 0.5)
//
//                // Empty State Content
//                DiscountsEmptyState()
//
//                // Bottom Tab Bar
//                //BottomTabBar(selectedTab: $selectedTab)
//            }
//
//            // Floating + Button
//            FloatingActionButton()
//        }
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    DiscountsView()
//}
import SwiftUI

// MARK: - ViewModel

@MainActor
final class DiscountsViewModel: ObservableObject {
    @Published var profiles: [DiscountProfile] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var deletingProfileId: String?

    var merchantId: Int {
        UserDefaults.standard.integer(forKey: "Bmerchant_id")
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            profiles = try await DiscountsService.shared.fetchAll(merchantId: merchantId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func deleteProfile(_ profile: DiscountProfile) async {
        deletingProfileId = profile.id
        do {
            for rule in profile.rules {
                if let apiId = rule.apiId {
                    try await DiscountsService.shared.deleteRule(
                        merchantId: merchantId, ruleId: apiId
                    )
                }
            }
            await load()
        } catch {
            errorMessage = error.localizedDescription
        }
        deletingProfileId = nil
    }
}

// MARK: - Rule Color helpers

private let ruleColors: [Color] = [
    Color(red: 0.13, green: 0.77, blue: 0.37),
    Color(red: 0.23, green: 0.51, blue: 0.96),
    Color(red: 0.55, green: 0.36, blue: 0.96),
    Color(red: 0.96, green: 0.62, blue: 0.04),
    Color(red: 0.94, green: 0.27, blue: 0.27),
    Color(red: 0.02, green: 0.71, blue: 0.83),
]
private func ruleColor(_ idx: Int) -> Color { ruleColors[idx % ruleColors.count] }

// MARK: - Profile Card

struct ProfileCard: View {
    let profile: DiscountProfile
    let isDeleting: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    var sortedRules: [UIDiscountRule] {
        profile.rules.sorted {
            (Double($0.cartThreshold) ?? 0) < (Double($1.cartThreshold) ?? 0)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Card Header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appGreen.opacity(0.13))
                        .frame(width: 36, height: 36)
                    Image(systemName: "tag.fill")
                        .font(.system(size: 15))
                        .foregroundColor(Color.appGreen)
                }

                Text(profile.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)

                // Rule count badge
                HStack(spacing: 3) {
                    Text("\(profile.rules.count)")
                        .foregroundColor(Color.appGreen)
                    Text(profile.rules.count == 1 ? "rule" : "rules")
                        .foregroundColor(Color.subtitleText)
                }
                .font(.system(size: 11, weight: .semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color.appGreen.opacity(0.1))
                .cornerRadius(20)

                Spacer()

                // Default badge
                if profile.isDefaultProfile == 1 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("Default")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(Color.appBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.appBlue.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.appBlue.opacity(0.25), lineWidth: 1)
                    )
                    .cornerRadius(20)
                }

                // Edit button
                Button(action: onEdit) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 11))
                        Text("Edit")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color.appPurple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.appPurple, lineWidth: 1)
                    )
                }
                .disabled(isDeleting)

                // Delete button
                Button(action: onDelete) {
                    if isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.94, green: 0.27, blue: 0.27)))
                            .frame(width: 28, height: 28)
                    } else {
                        Image(systemName: "trash")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.94, green: 0.27, blue: 0.27))
                            .frame(width: 32, height: 28)
                    }
                }
                .disabled(isDeleting)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.appCardBackground)

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 0.5)

            // Rules list
            VStack(spacing: 8) {
                ForEach(Array(sortedRules.enumerated()), id: \.element.id) { idx, rule in
                    let color = ruleColor(idx)
                    HStack(spacing: 10) {
                        Circle()
                            .fill(color)
                            .frame(width: 8, height: 8)

                        Text("If cart >")
                            .font(.system(size: 13))
                            .foregroundColor(Color.subtitleText)

                        Text("$\(formatCurrency(rule.cartThreshold))")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)

                        Text("→")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(color)

                        Text("\(rule.discountValue)% off")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(color)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.appBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.18), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
            }
            .padding(16)
            .background(Color.appCardBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
        .opacity(isDeleting ? 0.6 : 1)
        .animation(.easeInOut(duration: 0.2), value: isDeleting)
    }

    private func formatCurrency(_ s: String) -> String {
        guard let d = Double(s) else { return s }
        return String(format: "%.2f", d)
    }
}

// MARK: - Empty State

struct DiscountsListEmptyState: View {
    let onAdd: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appGreen.opacity(0.1))
                        .frame(width: 56, height: 56)
                    Image(systemName: "tag.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color.appGreen)
                }

                VStack(spacing: 6) {
                    Text("No discounts profiles")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Create a profile and add rules like\n\"If cart > $100 → 10% off\"")
                        .font(.system(size: 13))
                        .foregroundColor(Color.subtitleText)
                        .multilineTextAlignment(.center)
                }

                Button(action: onAdd) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.system(size: 13, weight: .bold))
                        Text("Add Discount Profile")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(Color.appPurple)
                    .cornerRadius(22)
                }
                .padding(.top, 4)
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity)
        .background(Color.appCardBackground)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

// MARK: - Loading Skeleton

struct LoadingSkeleton: View {
    @State private var animate = false
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<2, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.appCardBackground)
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.07), lineWidth: 1)
                    )
                    .opacity(animate ? 0.5 : 1)
                    .animation(.easeInOut(duration: 0.9).repeatForever(), value: animate)
            }
        }
        .onAppear { animate = true }
    }
}

// MARK: - DiscountsView

struct DiscountsView: View {
    @StateObject private var vm = DiscountsViewModel()
    @State private var showAdd = false
    @State private var editingProfile: DiscountProfile?
    @State private var showDeleteAlert = false
    @State private var profileToDelete: DiscountProfile?

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                // Page Header
                DiscountsPageHeader(onAddProfile: { showAdd = true })

                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 0.5)

                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        if vm.isLoading {
                            LoadingSkeleton()

                        } else if let err = vm.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.system(size: 28))
                                    .foregroundColor(.orange)
                                Text(err)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.subtitleText)
                                    .multilineTextAlignment(.center)
                                Button("Retry") {
                                    Task { await vm.load() }
                                }
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.appPurple)
                            }
                            .padding(32)

                        } else if vm.profiles.isEmpty {
                            DiscountsListEmptyState(onAdd: { showAdd = true })

                        } else {
                            ForEach(vm.profiles) { profile in
                                ProfileCard(
                                    profile: profile,
                                    isDeleting: vm.deletingProfileId == profile.id,
                                    onEdit: { editingProfile = profile },
                                    onDelete: {
                                        profileToDelete = profile
                                        showDeleteAlert = true
                                    }
                                )
                            }
                        }
                    }
                    .padding(16)
                }
            }

            // FAB
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showAdd = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 58, height: 58)
                            .background(Color.appCyan)
                            .clipShape(RoundedRectangle(cornerRadius: 17))
                            .shadow(color: Color.appCyan.opacity(0.4), radius: 12, x: 0, y: 6)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .task { await vm.load() }
        .sheet(isPresented: $showAdd, onDismiss: {
            Task { await vm.load() }
        }) {
            AddDiscountsProfileView(existingProfile: nil)
        }
        .sheet(item: $editingProfile, onDismiss: {
            Task { await vm.load() }
        }) { profile in
            AddDiscountsProfileView(existingProfile: profile)
        }
        .alert("Delete Profile", isPresented: $showDeleteAlert, presenting: profileToDelete) { profile in
            Button("Delete", role: .destructive) {
                Task { await vm.deleteProfile(profile) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { profile in
            Text("Delete \"\(profile.name)\" and all its rules? This cannot be undone.")
        }
    }
}

// MARK: - Updated Page Header

struct DiscountsPageHeader: View {
    @Environment(\.dismiss) private var dismiss
    let onAddProfile: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Discounts")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Create rule-based cart discounts — up to\n50 rules per profile")
                    .font(.system(size: 12.5))
                    .foregroundColor(Color.subtitleText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Button(action: onAddProfile) {
                HStack(spacing: 5) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Add Profile")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.appPurple)
                .cornerRadius(22)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.appNavBackground)
    }
}

#Preview {
    DiscountsView()
}
