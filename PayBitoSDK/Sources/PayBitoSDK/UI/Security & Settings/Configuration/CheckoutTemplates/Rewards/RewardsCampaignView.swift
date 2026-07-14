//
//  RewardsCampaignView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 21/04/26.
//
//
//import SwiftUI
//
//struct RewardCampaignsView: View {
//
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var vm = RewardCampaignsViewModel()
//
//    @State private var campaignToDelete: Campaign? = nil
//    @State private var isDeleting = false
//    @State private var expandedId: Int? = nil
//
//    private let bg = LinearGradient(
//        colors: [
//            Color(red: 0.05, green: 0.07, blue: 0.12),
//            Color(red: 0.02, green: 0.04, blue: 0.08)
//        ],
//        startPoint: .topLeading,
//        endPoint: .bottomTrailing
//    )
//
//    private let card = Color(red: 0.12, green: 0.14, blue: 0.20)
//    private let bord = Color.white.opacity(0.08)
//    private let purple = Color(red: 0.60, green: 0.35, blue: 0.95)
//    private let blue = Color(red: 0.30, green: 0.60, blue: 1.00)
//    private let subtle = Color.gray.opacity(0.55)
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            bg.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                headerBar
//                Divider().background(Color.white.opacity(0.08))
//                filterBar
//                Divider().background(Color.white.opacity(0.05))
//                searchBar
//                campaignList
//            }
//
//            if let t = vm.toast {
//                ToastView(
//                    message: t.message,
//                    isSuccess: t.style == .success
//                )
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//                .padding(.bottom, 16)
//            }
//        }
//        .navigationBarHidden(true)
//        .onAppear {
//            vm.fetchCampaigns()
//        }
//        .onChange(of: vm.filter) { _ in
//            expandedId = nil
//            vm.fetchCampaigns()
//        }
//        .sheet(item: $campaignToDelete) { campaign in
//            DeleteConfirmSheet(
//                campaign: campaign,
//                isDeleting: isDeleting,
//                onCancel: {
//                    campaignToDelete = nil
//                },
//                onConfirm: {
//                    isDeleting = true
//                    vm.deleteCampaign(campaign) { success in
//                        isDeleting = false
//                        if success {
//                            if expandedId == campaign.id {
//                                expandedId = nil
//                            }
//                            campaignToDelete = nil
//                        }
//                    }
//                }
//            )
//            .presentationDetents([.fraction(0.45)])
//            .presentationDragIndicator(.visible)
//        }
//    }
//
//    private var headerBar: some View {
//        HStack(spacing: 12) {
//            Button {
//                dismiss()
//            } label: {
//                Image(systemName: "arrow.left")
//                    .foregroundColor(.white)
//                    .frame(width: 32, height: 32)
//                    .background(Color.white.opacity(0.07))
//                    .clipShape(RoundedRectangle(cornerRadius: 9))
//            }
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Reward Campaigns")
//                    .font(.system(size: 19, weight: .bold))
//                    .foregroundColor(.white)
//
//                Text("Manage all your reward campaigns in one place")
//                    .font(.system(size: 11))
//                    .foregroundColor(subtle)
//            }
//
//            Spacer()
//
//            Button {} label: {
//                HStack(spacing: 4) {
//                    Image(systemName: "plus")
//                    Text("Create")
//                }
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(.white)
//                .padding(.horizontal, 14)
//                .padding(.vertical, 8)
//                .background(
//                    LinearGradient(
//                        colors: [purple, blue],
//                        startPoint: .leading,
//                        endPoint: .trailing
//                    )
//                )
//                .cornerRadius(20)
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//    }
//
//    private var filterBar: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack(spacing: 6) {
//                ForEach(CampaignFilter.allCases) { f in
//                    CampaignFilterTab(
//                        label: f.label,
//                        count: vm.isLoading ? nil : vm.count(for: f),
//                        isActive: vm.filter == f,
//                        purple: purple
//                    ) {
//                        vm.filter = f
//                        vm.searchText = ""
//                    }
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//        }
//    }
//
//    private var searchBar: some View {
//        HStack(spacing: 8) {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(.white.opacity(0.35))
//
//            TextField("Search campaigns…", text: $vm.searchText)
//                .foregroundColor(.white)
//
//            if !vm.searchText.isEmpty {
//                Button {
//                    vm.searchText = ""
//                } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.white.opacity(0.3))
//                }
//            }
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 8)
//        .background(Color.white.opacity(0.05))
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(bord)
//        )
//        .padding(.horizontal, 16)
//        .padding(.vertical, 8)
//    }
//
//    private var campaignList: some View {
//        ScrollView {
//            VStack(spacing: 4) {
//                if vm.isLoading {
//                    ForEach(0..<3, id: \.self) { _ in
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(Color.white.opacity(0.07))
//                            .frame(height: 62)
//                    }
//                } else {
//                    ForEach(vm.filtered) { campaign in
//                        CampaignTableRow(
//                            campaign: campaign,
//                            isExpanded: expandedId == campaign.id,
//                            purple: purple,
//                            blue: blue,
//                            onToggle: {
//                                expandedId = expandedId == campaign.id ? nil : campaign.id
//                            },
//                            onEdit: {},
//                            onPause: {
//                                vm.togglePause(campaign)
//                            },
//                            onDelete: {
//                                campaignToDelete = campaign
//                            }
//                        )
//                    }
//                }
//            }
//            .padding()
//        }
//    }
//}
//
//struct CampaignTableRow: View {
//    let campaign: Campaign
//    let isExpanded: Bool
//    let purple: Color
//    let blue: Color
//    let onToggle: () -> Void
//    let onEdit: () -> Void
//    let onPause: () -> Void
//    let onDelete: () -> Void
//
//    private let card = Color(red: 0.12, green: 0.14, blue: 0.20)
//    private let bord = Color.white.opacity(0.08)
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 3) {
//                Text(campaign.name)
//                    .foregroundColor(.white)
//
//                Text("\(campaign.transactionCount) txns")
//                    .font(.caption)
//                    .foregroundColor(.gray)
//            }
//
//            Spacer()
//
//            RewardTypePill(isCashback: campaign.isCashback)
//
//            CampaignStatusBadge(status: campaign.status)
//
//            Button(action: onToggle) {
//                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                    .foregroundColor(.white)
//            }
//        }
//        .padding()
//        .background(card)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(bord)
//        )
//        .cornerRadius(10)
//    }
//}
//
//struct CampaignFilterTab: View {
//    let label: String
//    let count: Int?
//    let isActive: Bool
//    let purple: Color
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text(label)
//
//                if let count {
//                    Text("\(count)")
//                }
//            }
//            .foregroundColor(isActive ? purple : .white)
//            .padding()
//        }
//    }
//}
//
//struct CampaignStatusBadge: View {
//    let status: String
//
//    private var fgColor: Color {
//        switch status {
//        case "active":
//            return Color(hexValue: "#10b981")
//        case "scheduled":
//            return Color(hexValue: "#f59e0b")
//        case "ended", "expired":
//            return Color(hexValue: "#ef4444")
//        case "draft":
//            return Color(hexValue: "#94a3b8")
//        default:
//            return Color(hexValue: "#64748b")
//        }
//    }
//
//    private var bgColor: Color {
//        fgColor.opacity(0.12)
//    }
//
//    var body: some View {
//        Text(status.capitalized)
//            .font(.caption)
//            .foregroundColor(fgColor)
//            .padding(.horizontal, 8)
//            .padding(.vertical, 4)
//            .background(bgColor)
//            .clipShape(Capsule())
//    }
//}
//
//struct RewardTypePill: View {
//    let isCashback: Bool
//
//    var body: some View {
//        Text(isCashback ? "Cashback" : "Store Credit")
//            .font(.caption)
//            .padding(6)
//            .background(Color.white.opacity(0.08))
//            .cornerRadius(6)
//    }
//}
//
//struct DeleteConfirmSheet: View {
//    let campaign: Campaign
//    let isDeleting: Bool
//    let onCancel: () -> Void
//    let onConfirm: () -> Void
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Delete \(campaign.name)?")
//                .foregroundColor(.white)
//
//            HStack {
//                Button("Cancel", action: onCancel)
//                Button("Delete", action: onConfirm)
//            }
//        }
//        .padding()
//        .background(Color.black)
//    }
//}
//
//extension Color {
//    init(hexValue: String) {
//        let hex = hexValue.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//
//        let r = Double((int >> 16) & 0xff) / 255
//        let g = Double((int >> 8) & 0xff) / 255
//        let b = Double(int & 0xff) / 255
//
//        self.init(red: r, green: g, blue: b)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    RewardCampaignsView()
//}





//
//  RewardCampaignsView.swift
//  Trading_Terminal
//

import SwiftUI

struct RewardCampaignsView: View {
    @State private var selectedCampaign: Campaign?

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RewardCampaignsViewModel()

    @State private var showCreateCampaign = false
    @State private var showAnalytics = false
    @State private var showAllCampaigns = false

    @State private var campaignToDelete: Campaign?
    @State private var isDeleting = false
    @State private var expandedId: Int?

    private let bg = LinearGradient(
        colors: [
            Color(hex: "#090d18")!,
            Color(hex: "#0b1120")!,
            Color(hex: "#101827")!
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

//    private let card = Color(hex: "#141b2d")
//    private let border = Color.white.opacity(0.07)
//    private let purple = Color(hex: "#8b5cf6")
//    private let blue = Color(hex: "#3b82f6")
//    private let green = Color(hex: "#10b981")
//    private let amber = Color(hex: "#f59e0b")
//    private let red = Color(hex: "#ef4444")
    private let subtle = Color.white.opacity(0.55)

    var body: some View {
        NavigationStack {

             ZStack(alignment: .bottom) {

                 bg

                     .ignoresSafeArea()

                 ScrollView(showsIndicators: false) {

                     VStack(spacing: 20) {

                         headerBar

                         if vm.isLoading {

                             loadingDashboard

                         } else if vm.campaigns.isEmpty {

                             emptyDashboard

                         } else {

                             populatedDashboard

                         }

                     }

                     .padding(.bottom, 40)

                 }

                 if let t = vm.toast {

                     ToastView(

                         message: t.message,

                         isSuccess: t.style == .success

                     )

                     .padding(.bottom, 16)

                     .transition(.move(edge: .bottom).combined(with: .opacity))

                 }

             }

             .toolbar(.hidden)

             .background(Color.clear)

             .onAppear {

                 vm.fetchCampaigns()

             }

             .sheet(item: $campaignToDelete) { campaign in

                 DeleteConfirmSheet(

                     campaign: campaign,

                     isDeleting: isDeleting,

                     onCancel: {

                         campaignToDelete = nil

                     },

                     onConfirm: {

                         isDeleting = true

                         vm.deleteCampaign(campaign) { success in

                             isDeleting = false

                             if success {

                                 campaignToDelete = nil

                                 expandedId = nil

                             }

                         }

                     }

                 )

                 .presentationDetents([.fraction(0.42)])

             }
             .sheet(item: $selectedCampaign) { _ in

                 CreateCampaignView()

             }

             .navigationDestination(isPresented: $showCreateCampaign) {

                CreateCampaignView()

             }
             .navigationDestination(isPresented: $showAnalytics) {

                RewardAnalyticsView()

             }

         }

     }

    // MARK: Header

    private var headerBar: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 38, height: 38)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Reward Campaigns")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Manage all your reward campaigns in one place")
                    .font(.system(size: 12))
                    .foregroundColor(subtle)
            }

            Spacer()

            Button {
                showCreateCampaign = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Create")
                }
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [
                            Color(hex: "#8b5cf6")!,
                            Color(hex: "#3b82f6")!
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
//                .shadow(color: purple.opacity(0.35), radius: 12)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    // MARK: Loading

    private var loadingDashboard: some View {
        VStack(spacing: 16) {
            ForEach(0..<4, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 160)
//                    .shimmer()
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: Empty Dashboard

    private var emptyDashboard: some View {
        VStack(spacing: 18) {
            ActiveCampaignsEmptyCard()
            CampaignOverviewEmptyCard()
            QuickLinksCard(
                onCreate: {
                    showCreateCampaign = true
                },
                onAnalytics: {
                    showAnalytics = true
                },
                onAllCampaigns: {
                    showAllCampaigns = true
                }
            )
            RewardRulesCard()
        }
    }

    // MARK: Populated Dashboard

    private var populatedDashboard: some View {
        VStack(spacing: 18) {
            ActiveCampaignsLiveCard(
                campaigns: vm.filtered,
                expandedId: $expandedId,
                onEdit: { campaign in

                      selectedCampaign = campaign

                  },
                onPause: { vm.togglePause($0) },
                onDelete: { campaignToDelete = $0 }
            )

            CampaignOverviewLiveCard(campaigns: vm.campaigns)

            QuickLinksCard(
                onCreate: {
                    showCreateCampaign = true
                },
                onAnalytics: {
                    showAnalytics = true
                },
                onAllCampaigns: {
                    showAllCampaigns = true
                }
            )

            RewardRulesCard()
        }
    }
}

// MARK: - Active Campaigns Empty Card

struct ActiveCampaignsEmptyCard: View {

    private let border = Color.white.opacity(0.08)
    private let purple = Color(hex: "#8b5cf6")
    private let blue = Color(hex: "#3b82f6")

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Campaigns")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("Your currently running reward campaigns")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Text("0 Active")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#10b981"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#10b981").opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(spacing: 14) {
                Image(systemName: "gift")
                    .font(.system(size: 34))
                    .foregroundColor(.white.opacity(0.18))

                Text("No active campaigns")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Text("Create your first reward campaign to start engaging customers and boosting sales.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.45))
                    .multilineTextAlignment(.center)

//                Button {} label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "plus")
//                        Text("Create First Campaign")
//                    }
//                    .font(.system(size: 13, weight: .bold))
//                    .foregroundColor(.black)
//                    .padding(.horizontal, 18)
//                    .padding(.vertical, 10)
//                    .background(
//                        LinearGradient(
//                            colors: [
//                                purple ?? .purple,
//                                blue ?? .blue
//                            ],
//                            startPoint: .leading,
//                            endPoint: .trailing
//                        )
//                    )
//                    .clipShape(Capsule())
//                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [6]))
                    .foregroundColor(border)
            )
        }
        .padding(18)
        .background(Color(hex: "#141b2d"))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(border)
        )
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }
}

// MARK: - Campaign Overview Empty

struct CampaignOverviewEmptyCard: View {

    private let border = Color.white.opacity(0.08)

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Campaign Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                overviewBox(title: "Total", value: "0", color: "#8b5cf6")
                overviewBox(title: "Active", value: "0", color: "#10b981")
                overviewBox(title: "Scheduled", value: "0", color: "#f59e0b")
            }
        }
        .padding(18)
        .background(Color(hex: "#141b2d"))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(border)
        )
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }

    private func overviewBox(title: String, value: String, color: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: color))

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }
}

// MARK: - Campaign Overview Live

struct CampaignOverviewLiveCard: View {

    let campaigns: [Campaign]
    private let border = Color.white.opacity(0.08)

    private var activeCount: Int {
        campaigns.filter { $0.status == "active" }.count
    }

    private var scheduledCount: Int {
        campaigns.filter { $0.status == "scheduled" }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Campaign Overview")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            HStack(spacing: 10) {
                stat("Total", "\(campaigns.count)", "#8b5cf6")
                stat("Active", "\(activeCount)", "#10b981")
                stat("Scheduled", "\(scheduledCount)", "#f59e0b")
            }
        }
        .padding(18)
        .background(Color(hex: "#141b2d"))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(border)
        )
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }

    private func stat(_ title: String, _ value: String, _ color: String) -> some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: color))

            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }
}

// MARK: - Quick Links

struct QuickLinksCard: View {

    let onCreate: () -> Void
    let onAnalytics: () -> Void
    let onAllCampaigns: () -> Void

    private let border = Color.white.opacity(0.08)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Links")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            quickLink("Create Campaign", "plus.circle.fill", "#8b5cf6", onCreate)
            quickLink("Rewards Analytics", "chart.bar.fill", "#3b82f6", onAnalytics)
            quickLink("View All Campaigns", "list.bullet.rectangle", "#10b981", onAllCampaigns)
        }
        .padding(18)
        .background(Color(hex: "#141b2d"))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(border)
        )
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }

    private func quickLink(
        _ title: String,
        _ icon: String,
        _ color: String,
        _ action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(Color(hex: color))
                        .frame(width: 34, height: 34)
                        .background(Color(hex: color).opacity(0.12))
                        .clipShape(Circle())

                    Text(title)
                        .foregroundColor(.white)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding()
            .background(Color.white.opacity(0.04))
            .cornerRadius(14)
        }
    }
}

// MARK: - Reward Rules Card

struct RewardRulesCard: View {

    private let border = Color.white.opacity(0.08)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reward Rules")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)

            ruleRow(
                icon: "gift.fill",
                title: "Cashback Rewards",
                subtitle: "Customers earn percentage cashback"
            )

            ruleRow(
                icon: "clock.fill",
                title: "Scheduled Campaigns",
                subtitle: "Launch campaigns automatically"
            )

            ruleRow(
                icon: "chart.line.uptrend.xyaxis",
                title: "Performance Tracking",
                subtitle: "Monitor reward usage and ROI"
            )
        }
        .padding(18)
        .background(Color(hex: "#141b2d"))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(border)
        )
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }

    private func ruleRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(hex: "#8b5cf6"))
                .frame(width: 36, height: 36)
                .background(Color(hex: "#8b5cf6").opacity(0.12))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold))

                Text(subtitle)
                    .foregroundColor(.white.opacity(0.45))
                    .font(.system(size: 11))
            }

            Spacer()
        }
    }
}

// MARK: - Live Active Campaigns

struct ActiveCampaignsLiveCard: View {
    let campaigns: [Campaign]
    @Binding var expandedId: Int?
    let onEdit: (Campaign) -> Void
    let onPause: (Campaign) -> Void
    let onDelete: (Campaign) -> Void

    private let border = Color.white.opacity(0.08)

    private var activeCampaigns: [Campaign] {
        campaigns.filter { $0.status == "active" || $0.status == "scheduled" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Campaigns")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("Your currently running reward campaigns")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Text("\(activeCampaigns.count) Active")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(hex: "#10b981"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#10b981").opacity(0.12))
                    .clipShape(Capsule())
            }

            VStack(spacing: 10) {
                ForEach(activeCampaigns.prefix(3)) { campaign in

                    CampaignRow(

                        campaign: campaign,

                        onEdit: {
                            onEdit(campaign)
                        },

                        onPause: {
                            onPause(campaign)
                        },

                        onDelete: {
                            onDelete(campaign)
                        }
                    )
                }
            }
        }
        .padding(18)
        .background(Color(hex: "#141b2d"))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(border)
        )
        .cornerRadius(18)
        .padding(.horizontal, 16)
    }
}

// MARK: - Campaign Row

struct CampaignRow: View {

    let campaign: Campaign
    
    let onEdit: () -> Void
    let onPause: () -> Void
    let onDelete: () -> Void

    var body: some View {

        VStack(spacing: 12) {

            HStack(spacing: 14) {

                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        (Color(hex: "#8b5cf6") ?? .purple)
                            .opacity(0.15)
                    )
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "gift.fill")
                            .foregroundColor(
                                Color(hex: "#8b5cf6")
                            )
                    )

                VStack(alignment: .leading, spacing: 4) {

                    Text(campaign.name)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))

                    Text("\(campaign.rate, specifier: "%.0f")% reward")
                        .foregroundColor(.white.opacity(0.45))
                        .font(.system(size: 11))
                }

                Spacer()

                CampaignStatusBadge(
                    status: campaign.status
                )
            }

            Divider()
                .background(Color.white.opacity(0.1))

            HStack(spacing: 10) {

                Button(action: onEdit) {

                    Label(
                        "Edit",
                        systemImage: "pencil"
                    )
                }
                .buttonStyle(.bordered)

                Button(action: onPause) {

                    Label(
                        campaign.isPaused
                        ? "Activate"
                        : "Pause",
                        systemImage:
                            campaign.isPaused
                            ? "play.fill"
                            : "pause.fill"
                    )
                }
                .buttonStyle(.bordered)

                Button(action: onDelete) {

                    Label(
                        "Delete",
                        systemImage: "trash"
                    )
                }
                .tint(.red)
                .buttonStyle(.bordered)

                Spacer()
            }
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }
}

// MARK: - Delete Sheet

struct DeleteConfirmSheet: View {

    let campaign: Campaign
    let isDeleting: Bool
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "#0b1220").ignoresSafeArea()

            VStack(spacing: 22) {
                Circle()
                    .fill(Color.red.opacity(0.12))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "trash.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.red)
                    )

                VStack(spacing: 8) {
                    Text("Delete Campaign?")
                        .foregroundColor(.white)
                        .font(.system(size: 20, weight: .bold))

                    Text("Are you sure you want to delete \(campaign.name)?")
                        .foregroundColor(.white.opacity(0.55))
                        .multilineTextAlignment(.center)
                }

                HStack(spacing: 12) {
                    Button(action: onCancel) {
                        Text("Cancel")
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(14)
                    }

                    Button(action: onConfirm) {
                        Group {
                            if isDeleting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Delete")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.red)
                        .cornerRadius(14)
                    }
                }
            }
            .padding(24)
        }
    }
}

struct CampaignStatusBadge: View {
    let status: String

    private var color: Color {
        switch status.lowercased() {
        case "active":
            return Color(hex: "#10b981")!

        case "scheduled":
            return Color(hex: "#f59e0b")!

        case "paused":
            return Color(hex: "#ef4444")!

        default:
            return Color(hex: "#64748b")!
        }
    }

    var body: some View {
        Text(status.capitalized)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    RewardCampaignsView()
}
