//
//  RewardAnalyticsView.swift
//  PaymentsTerminsl
//
//  Created by HashCash on 21/05/26.
//

//
// Or standalone (e.g. pushed from a navigation stack):
//   NavigationLink("Reward Analytics") { RewardAnalyticsView() }

import SwiftUI

// MARK: - Colour helpers (scoped to this file)

private extension Color {
    static let raBG         = Color(raHex: "#0d1117")
    static let raSurface    = Color(raHex: "#161b22")
    static let raSurfaceAlt = Color(raHex: "#1c2430")
    static let raBorder     = Color(raHex: "#21262d")
    static let raText1      = Color(raHex: "#e6edf3")
    static let raText2      = Color(raHex: "#8b949e")
    static let raMuted      = Color(raHex: "#484f58")
    static let raGreen      = Color(raHex: "#10b981")   // issued today
    static let raBlue       = Color(raHex: "#58a6ff")   // issued month
    static let raPurple     = Color(raHex: "#8b5cf6")   // customers / cashback
    static let raAmber      = Color(raHex: "#f59e0b")   // avg reward
    static let raPink       = Color(raHex: "#ec4899")   // redemption
    static let raCyan       = Color(raHex: "#2dd4bf")   // store credit / active camps
    static let raViolet     = Color(raHex: "#818cf8")   // cashback bar

    init(raHex hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        self.init(
            red:   Double((int >> 16) & 0xFF) / 255,
            green: Double((int >> 8)  & 0xFF) / 255,
            blue:  Double( int        & 0xFF) / 255
        )
    }
}

// MARK: - Period

enum RAPeriod: String, CaseIterable, Identifiable {
    case today = "Today"
    case month = "This Month"
    case all   = "All Time"
    var id: String { rawValue }
}

// MARK: - Models (mirror web data shapes)

struct RAStats {
    var issuedToday:      Double = 0
    var issuedMonth:      Double = 0
    var customersTotal:   Int    = 0
    var avgReward:        Double = 0
    var redeemRate:       Double = 0   // 0–100
    var activeCampaigns:  Int    = 0
}

struct RACampaign: Identifiable {
    let id:           Int
    let name:         String
    let type:         String   // "cashback" | "store_credit"
    let rate:         Int
    let issued:       Double
    let customers:    Int
    let transactions: Int
}

struct RAHistoryItem: Identifiable {
    let id        = UUID()
    let date:     String
    let amount:   Double
    let customer: String
    let type:     String
    let campaign: String
}

struct RAChartPoint: Identifiable {
    let id    = UUID()
    let month: String
    let value: Double
}

struct RABreakdownItem: Identifiable {
    let id    = UUID()
    let label: String
    let value: Double
    let color: Color
}

// MARK: - ViewModel

@MainActor
final class RewardAnalyticsVM: ObservableObject {

    @Published var loading     = false
    @Published var period      = RAPeriod.month
    @Published var stats       = RAStats()
    @Published var campaigns   : [RACampaign]    = []
    @Published var history     : [RAHistoryItem] = []
    @Published var chartData   : [RAChartPoint]  = []
    @Published var breakdown   : [RABreakdownItem] = []
    @Published var toastMsg    : String? = nil
    @Published var toastError  = false

    // ── Call your real API here ──────────────────────────────────
    // Replace the contents of loadData() with actual URLSession / Alamofire
    // calls that match the web implementation's endpoints.
    // The mock data below mirrors MOCK_STATS / MOCK_TOP_CAMPAIGNS / MOCK_HISTORY
    // from the React file so you can swap them 1-for-1.

    func load() {
        guard !loading else { return }
        loading = true

        // TODO: replace with real API call filtered by `period`
        Task {
            try? await Task.sleep(nanoseconds: 700_000_000)   // simulate network

            // ── MOCK — mirrors web MOCK_STATS ────────────────────
            self.stats = RAStats(
                issuedToday:     0,
                issuedMonth:     0,
                customersTotal:  0,
                avgReward:       0,
                redeemRate:      0,
                activeCampaigns: 0
            )

            // ── MOCK — mirrors web MOCK_TOP_CAMPAIGNS ────────────
            self.campaigns = [
                // RACampaign(id:1, name:"Weekend Cashback",  type:"cashback",     rate:10, issued:324, customers:96,  transactions:128),
                // RACampaign(id:2, name:"Standard Rewards",  type:"cashback",     rate:3,  issued:212, customers:88,  transactions:201),
                // RACampaign(id:3, name:"Flash Sale Bonus",  type:"store_credit", rate:15, issued:540, customers:60,  transactions:72 ),
                // RACampaign(id:4, name:"New User Welcome",  type:"cashback",     rate:8,  issued:90,  customers:40,  transactions:45 ),
            ]

            // ── MOCK — mirrors web MOCK_HISTORY ─────────────────
            self.history = [
                // RAHistoryItem(date:"Today",     amount:42,  customer:"Alice M.", type:"cashback",     campaign:"Weekend Cashback"),
                // RAHistoryItem(date:"Today",     amount:8,   customer:"Raj S.",   type:"store_credit", campaign:"Standard Rewards"),
                // RAHistoryItem(date:"Yesterday", amount:15,  customer:"Bob K.",   type:"cashback",     campaign:"Weekend Cashback"),
            ]

            // ── MOCK — mirrors web CHART_DATA ───────────────────
            self.chartData = [
                RAChartPoint(month:"Oct", value:0),
                RAChartPoint(month:"Nov", value:0),
                RAChartPoint(month:"Dec", value:0),
                RAChartPoint(month:"Jan", value:0),
                RAChartPoint(month:"Feb", value:0),
                RAChartPoint(month:"Mar", value:0),
            ]

            // ── Breakdown (derived from campaigns) ───────────────
            let cashbackTotal    = self.campaigns.filter { $0.type == "cashback"     }.reduce(0) { $0 + $1.issued }
            let storeCreditTotal = self.campaigns.filter { $0.type == "store_credit" }.reduce(0) { $0 + $1.issued }
            self.breakdown = [
                RABreakdownItem(label:"Cashback",     value: cashbackTotal,    color: .raViolet),
                RABreakdownItem(label:"Credit",       value: storeCreditTotal, color: .raCyan),
            ]

            self.loading = false
        }
    }

    func changePeriod(_ p: RAPeriod) {
        period = p
        load()
    }
}

// MARK: - Root View

struct RewardAnalyticsView: View {

    @StateObject private var vm = RewardAnalyticsVM()

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.raBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    periodToggle
                    campaignOverviewSection
                    breakdownSection
                    chartSection
                    topCampaignsSection
                    recentHistorySection
                    campaignDetailsSection
                    Spacer().frame(height: 40)
                }
            }
        }
        .onAppear { vm.load() }
        .raToast(msg: vm.toastMsg, isError: vm.toastError) { vm.toastMsg = nil }
    }

    // MARK: Period Toggle (Today / This Month / All Time)

    private var periodToggle: some View {
        HStack(spacing: 0) {
            ForEach(RAPeriod.allCases) { p in
                let selected = vm.period == p
                Button {
                    vm.changePeriod(p)
                } label: {
                    Text(p.rawValue)
                        .font(.system(size: 13, weight: selected ? .bold : .regular))
                        .foregroundColor(selected ? .white : .raText2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selected
                                ? Color(raHex: "#6d28d9")   // vivid purple like Android
                                : Color.clear
                        )
                        .cornerRadius(9)
                }
            }
        }
        .padding(3)
        .background(Color.raSurface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.raBorder, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 20)
    }

    // MARK: Campaigns Overview — 6 KPI cards (2-column grid)

    private var campaignOverviewSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            raSectionLabel(icon: "waveform.path", title: "CAMPAIGNS OVERVIEW")

            let kpis: [(String, String, Color)] = [
                ("ISSUED TODAY",     fmtUSD(vm.stats.issuedToday),     .raGreen),
                ("ISSUED THIS MONTH",fmtUSD(vm.stats.issuedMonth),     .raBlue),
                ("CUSTOMERS",        "\(vm.stats.customersTotal)",      .raCyan),
                ("AVG REWARD",       fmtUSD(vm.stats.avgReward),        .raAmber),
                ("REDEMPTION",       fmtPct(vm.stats.redeemRate),       .raPurple),
                ("ACTIVE CAMP.",     "\(vm.stats.activeCampaigns)",     .raCyan),
            ]

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10),
                          GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(kpis, id: \.0) { title, value, color in
                    RAKPICard(title: title, value: value, color: color, loading: vm.loading)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
    }

    // MARK: Breakdown by Type

    private var breakdownSection: some View {
        RACard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Breakdown by Type")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.raText1)
                    let total = vm.breakdown.reduce(0) { $0 + $1.value }
                    Text(fmtUSD(total))
                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                        .foregroundColor(.raText1)
                }

                if vm.loading {
                    raLoadingRow
                } else {
                    let total = max(vm.breakdown.reduce(0) { $0 + $1.value }, 0.001)
                    VStack(spacing: 14) {
                        ForEach(vm.breakdown) { item in
                            VStack(spacing: 6) {
                                HStack {
                                    HStack(spacing: 8) {
                                        Circle().fill(item.color)
                                            .frame(width: 9, height: 9)
                                            .shadow(color: item.color.opacity(0.5), radius: 3)
                                        Text(item.label)
                                            .font(.system(size: 13))
                                            .foregroundColor(.raText2)
                                    }
                                    Spacer()
                                    Text(fmtUSD(item.value))
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(item.color)
                                    Text("\(Int((item.value / total) * 100))%")
                                        .font(.system(size: 11, design: .monospaced))
                                        .foregroundColor(.raMuted)
                                        .frame(width: 36, alignment: .trailing)
                                }
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.raBorder)
                                            .frame(height: 6)
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(item.color)
                                            .frame(width: geo.size.width * CGFloat(item.value / total),
                                                   height: 6)
                                            .shadow(color: item.color.opacity(0.4), radius: 4)
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                    }

                    Divider().background(Color.raBorder)

                    HStack {
                        Text("Total Issued")
                            .font(.system(size: 12))
                            .foregroundColor(.raText2)
                        Spacer()
                        Text(fmtUSD(vm.breakdown.reduce(0) { $0 + $1.value }))
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.raText1)
                    }
                }
            }
        }
    }

    // MARK: Bar Chart — Rewards Issued (Last 6 months)

    private var chartSection: some View {
        RACard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.raBlue)
                        Text("Rewards Issued (Last 6 months)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.raText2)
                    }
                    Spacer()
                    Text(fmtUSD(vm.stats.issuedMonth))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.raText1)
                }

                if vm.loading {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.raBorder)
                        .frame(height: 120)
                        .bbShimmer()
                } else {
                    RABarChart(data: vm.chartData)
                        .frame(height: 120)
                }
            }
        }
    }

    // MARK: Top Campaigns (progress bars like web)

    private var topCampaignsSection: some View {
        RACard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.raAmber)
                        Text("Top Campaigns")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.raText2)
                    }
                    Spacer()
                    // "View all →" — wire to your campaigns navigation
                    Button {} label: {
                        Text("View all →")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.raBlue)
                    }
                }

                if vm.loading {
                    VStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.raBorder)
                                .frame(height: 52)
                                .bbShimmer()
                        }
                    }
                } else if vm.campaigns.isEmpty {
                    raEmpty("No campaign data yet.")
                } else {
                    let maxIssued = vm.campaigns.map(\.issued).max() ?? 1
                    VStack(spacing: 0) {
                        ForEach(vm.campaigns) { c in
                            RACampaignProgressRow(campaign: c, maxIssued: maxIssued)
                        }
                    }
                }
            }
        }
    }

    // MARK: Recent Rewards History

    private var recentHistorySection: some View {
        RACard {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.raPurple)
                    Text("Recent Rewards Issued")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.raText2)
                }

                if vm.loading {
                    VStack(spacing: 8) {
                        ForEach(0..<3, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.raBorder)
                                .frame(height: 46)
                                .bbShimmer()
                        }
                    }
                } else if vm.history.isEmpty {
                    raEmpty("No recent rewards issued.")
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(vm.history.enumerated()), id: \.element.id) { idx, item in
                            RAHistoryRow(item: item)
                            if idx < vm.history.count - 1 {
                                Divider().background(Color.raBorder)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Campaign Details (per-row like web right panel)

    private var campaignDetailsSection: some View {
        RACard {
            VStack(alignment: .leading, spacing: 0) {
                Text("CAMPAIGN DETAILS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.raMuted)
                    .kerning(0.7)
                    .padding(.bottom, 14)

                if vm.loading {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.raBorder)
                        .frame(height: 120)
                        .bbShimmer()
                } else if vm.campaigns.isEmpty {
                    raEmpty("No campaigns found.")
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(vm.campaigns.enumerated()), id: \.element.id) { idx, c in
                            RACampaignDetailRow(campaign: c)
                            if idx < vm.campaigns.count - 1 {
                                Divider().background(Color.raBorder)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Shared helpers

    private func raSectionLabel(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(raHex: "#bc8cff"))
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(raHex: "#bc8cff"))
                .kerning(1.1)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    private var raLoadingRow: some View {
        HStack(spacing: 10) {
            ProgressView().tint(.raGreen)
            Text("Loading…").font(.system(size: 13)).foregroundColor(.raText2)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
    }

    private func raEmpty(_ msg: String) -> some View {
        VStack(spacing: 8) {
            Text("🎁").font(.system(size: 24)).opacity(0.4)
            Text(msg).font(.system(size: 13)).foregroundColor(.raMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
    }

    private func fmtUSD(_ v: Double) -> String { "$" + String(format: "%.2f", v) }
    private func fmtPct(_ v: Double) -> String { String(format: "%.2f%%", v) }
}

// MARK: - Card Container

private struct RACard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        content()
            .padding(16)
            .background(Color.raSurface)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.raBorder, lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
    }
}

// MARK: - KPI Card (matches Android colored-border tiles)

private struct RAKPICard: View {
    let title:   String
    let value:   String
    let color:   Color
    let loading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.raText2)
                .kerning(0.4)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            if loading {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.raBorder)
                    .frame(height: 24)
                    .bbShimmer()
            } else {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.raSurface)
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(color, lineWidth: 1.8)
        )
    }
}

// MARK: - Bar Chart (mirrors web BarChart component)

private struct RABarChart: View {
    let data: [RAChartPoint]

    var body: some View {
        GeometryReader { geo in
            let maxVal = data.map(\.value).max() ?? 1
            let slotW  = geo.size.width / CGFloat(data.count)
            let barW   = slotW * 0.55

            ZStack(alignment: .bottom) {
                // Grid lines
                ForEach(0..<4, id: \.self) { i in
                    let y = geo.size.height * 0.85 * CGFloat(i) / 3
                    Path { p in
                        p.move(to:    CGPoint(x: 0, y: y))
                        p.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                    .stroke(Color.raBorder, lineWidth: 0.5)
                }

                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.offset) { idx, point in
                        let isLast = idx == data.count - 1
                        let pct    = maxVal > 0 ? CGFloat(point.value / maxVal) : 0
                        let barH   = max(4, geo.size.height * 0.78 * pct)

                        VStack(spacing: 4) {
                            // Value label on top
                            Text("$\(Int(point.value))")
                                .font(.system(size: 9))
                                .foregroundColor(isLast ? .raText1 : .raMuted)
                                .fontWeight(isLast ? .bold : .regular)

                            Spacer(minLength: 0)

                            // Bar
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    isLast
                                        ? Color(raHex: "#58a6ff")
                                        : Color(raHex: "#58a6ff").opacity(0.35)
                                )
                                .frame(width: barW, height: barH)
                                .shadow(
                                    color: isLast ? Color(raHex: "#58a6ff").opacity(0.4) : .clear,
                                    radius: 6
                                )

                            // Month label
                            Text(point.month)
                                .font(.system(size: 10))
                                .foregroundColor(isLast ? .raText2 : .raMuted)
                                .fontWeight(isLast ? .semibold : .regular)
                        }
                        .frame(width: slotW)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

// MARK: - Campaign Progress Row (mirrors web ProgressBar component)

private struct RACampaignProgressRow: View {
    let campaign:  RACampaign
    let maxIssued: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(campaign.name)
                    .font(.system(size: 13))
                    .foregroundColor(.raText2)
                Spacer()
                Text("$\(Int(campaign.issued))")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(campaign.type == "cashback" ? .raViolet : .raCyan)
                Text("· \(campaign.customers) customers")
                    .font(.system(size: 10))
                    .foregroundColor(.raMuted)
            }
            GeometryReader { geo in
                let pct = maxIssued > 0 ? CGFloat(campaign.issued / maxIssued) : 0
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.raBorder)
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(campaign.type == "cashback" ? Color.raViolet : Color.raCyan)
                        .frame(width: geo.size.width * pct, height: 6)
                        .shadow(
                            color: (campaign.type == "cashback" ? Color.raViolet : Color.raCyan).opacity(0.4),
                            radius: 4
                        )
                }
            }
            .frame(height: 6)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - History Row (mirrors web recent-rewards list item)

private struct RAHistoryRow: View {
    let item: RAHistoryItem

    private var isCashback: Bool { item.type == "cashback" }
    private var accent: Color { isCashback ? .raViolet : .raCyan }
    private var iconName: String { isCashback ? "arrow.uturn.left.circle.fill" : "ticket.fill" }

    var body: some View {
        HStack(spacing: 12) {
            // Icon badge
            Image(systemName: iconName)
                .font(.system(size: 22))
                .foregroundColor(accent)
                .frame(width: 36, height: 36)
                .background(accent.opacity(0.12))
                .cornerRadius(9)

            // Name + campaign
            VStack(alignment: .leading, spacing: 2) {
                Text(item.customer)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.raText1)
                    .lineLimit(1)
                Text(item.campaign)
                    .font(.system(size: 11))
                    .foregroundColor(.raText2)
                    .lineLimit(1)
            }

            Spacer()

            // Amount + date
            VStack(alignment: .trailing, spacing: 2) {
                Text("+$\(Int(item.amount))")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(accent)
                Text(item.date)
                    .font(.system(size: 11))
                    .foregroundColor(.raMuted)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Campaign Detail Row (mirrors web right-panel Campaign Details)

private struct RACampaignDetailRow: View {
    let campaign: RACampaign

    private var isCashback: Bool { campaign.type == "cashback" }
    private var accent: Color { isCashback ? .raViolet : .raCyan }
    private var iconName: String { isCashback ? "arrow.uturn.left.circle.fill" : "ticket.fill" }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundColor(accent)
                .frame(width: 32, height: 32)
                .background(accent.opacity(0.12))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 2) {
                Text(campaign.name)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.raText1)
                    .lineLimit(1)
                Text("\(campaign.transactions) transactions · \(campaign.customers) customers")
                    .font(.system(size: 11))
                    .foregroundColor(.raText2)
            }

            Spacer()

            Text("$\(Int(campaign.issued))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.raText1)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.raMuted)
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Toast modifier (scoped to this file)

private struct RAToastModifier: ViewModifier {
    let msg:       String?
    let isError:   Bool
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let m = msg {
                Text(m)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(isError ? Color.raPink : Color.raGreen)
                    .cornerRadius(10)
                    .shadow(radius: 6)
                    .padding(.top, 12)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { onDismiss() }
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { onDismiss() }
                    }
            }
        }
        .animation(.spring(), value: msg)
    }
}

private extension View {
    func raToast(msg: String?, isError: Bool, onDismiss: @escaping () -> Void) -> some View {
        modifier(RAToastModifier(msg: msg, isError: isError, onDismiss: onDismiss))
    }
}

// MARK: - Preview

#Preview {
    RewardAnalyticsView()
}
