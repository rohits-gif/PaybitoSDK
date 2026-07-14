// BillbitcoinsAnalyticsview.swift
// Trading_Terminal
// Fixed version — uses only SwiftUI (no Charts framework required).
// All chart types are drawn with native SwiftUI shapes.

//import SwiftUI
//
//// MARK: - Colour palette
//
//private extension Color {
//    static let bbBG         = Color(bbHex: "#0d1117")
//    static let bbSurface    = Color(bbHex: "#161b22")
//    static let bbSurfaceAlt = Color(bbHex: "#1c2430")
////    static let bbBorder     = Color(bbHex: "#21262d")
//    static let bbText1      = Color(bbHex: "#e6edf3")
//    static let bbText2      = Color(bbHex: "#8b949e")
//    static let bbMuted      = Color(bbHex: "#484f58")
//    static let bbAccent     = Color(bbHex: "#3fb950")
//    static let bbBlue       = Color(bbHex: "#58a6ff")
//    static let bbAmber      = Color(bbHex: "#d29922")
//    static let bbRed        = Color(bbHex: "#f85149")
//    static let bbPurple     = Color(bbHex: "#bc8cff")
//    static let bbCyan       = Color(bbHex: "#39c5cf")
//
//    init(bbHex hex: String) {
//        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: h).scanHexInt64(&int)
//        self.init(
//            red:   Double((int >> 16) & 0xFF) / 255,
//            green: Double((int >> 8)  & 0xFF) / 255,
//            blue:  Double( int        & 0xFF) / 255
//        )
//    }
//}
//
//private let bbPalette: [Color] = [.bbAccent, .bbBlue, .bbCyan, .bbAmber, .bbPurple, .bbRed]
//private func bbPaletteColor(_ i: Int) -> Color { bbPalette[i % bbPalette.count] }
//
//// MARK: - Root View
//
//struct AnalyticsView: View {
//
//    @StateObject private var vm = AnalyticsViewModel()
//    @State private var showDatePicker = false
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            Color.bbBG.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(alignment: .leading, spacing: 0) {
//                    headerSection
//                    bbSectionLabel("KEY METRICS");              keyMetricsGrid
//                    bbSectionLabel("REVENUE TREND");            revenueTrendCard
//                    bbSectionLabel("TRANSACTION HEALTH");       transactionHealthRow
//                    bbSectionLabel("PAYMENT TYPE PERFORMANCE"); paymentTypeCard
//                    bbSectionLabel("TOP PRODUCTS");             topProductsCard
//                    bbSectionLabel("DISTRIBUTION & GEOGRAPHY"); distributionRow
//                    bbSectionLabel("FAILURE ANALYSIS");         failureCard
//                    bbSectionLabel("SETTLEMENT OVERVIEW");      settlementCard
//                    bbSectionLabel("DOWNLOAD REPORTS");         downloadReportsCard
//                    Spacer().frame(height: 120)
//                }
//            }
//
//            // FAB
//            Button { vm.refreshAll() } label: {
//                Image(systemName: "arrow.clockwise")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(width: 58, height: 58)
//                    .background(Color.bbAccent)
//                    .clipShape(RoundedRectangle(cornerRadius: 16))
//                    .shadow(color: Color.bbAccent.opacity(0.45), radius: 12, x: 0, y: 6)
//            }
//            .padding(.trailing, 20)
//            .padding(.bottom, 32)
//        }
//        .onAppear { vm.refreshAll() }
//        .onChange(of: vm.revenueGranularity) { _ in vm.fetchRevenueOverTime() }
//        .bbToast(message: vm.toastMessage, isError: vm.toastIsError) { vm.toastMessage = nil }
//    }
//
//    // MARK: Header
//
//    private var headerSection: some View {
//        VStack(alignment: .leading, spacing: 14) {
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Insights")
//                    .font(.system(size: 26, weight: .bold))
//                    .foregroundColor(.bbText1)
//                Text("Payment performance, revenue trends & activity")
//                    .font(.system(size: 13))
//                    .foregroundColor(.bbText2)
//            }
//
//            HStack(spacing: 10) {
//                // Date range
//                Button { showDatePicker.toggle() } label: {
//                    HStack(spacing: 8) {
//                        Image(systemName: "calendar").foregroundColor(.bbAccent).font(.system(size: 13))
//                        Text(dateRangeLabel).font(.system(size: 12, weight: .semibold)).foregroundColor(.bbText1)
//                        Image(systemName: "chevron.down").font(.system(size: 10)).foregroundColor(.bbText2)
//                    }
//                    .padding(.horizontal, 12).padding(.vertical, 9)
//                    .background(Color.bbSurface)
//                    .cornerRadius(9)
//                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.bbBorder, lineWidth: 1))
//                }
//
//                // Currency
//                Menu {
//                    ForEach(["ALL","BTC","ETH","USDT","USDC","BCH"], id: \.self) { c in
//                        Button(c) { vm.selectedCurrency = c; vm.refreshAll() }
//                    }
//                } label: {
//                    HStack(spacing: 4) {
//                        Text(vm.selectedCurrency).font(.system(size: 13, weight: .bold)).foregroundColor(.bbText1)
//                        Image(systemName: "chevron.down").font(.system(size: 10)).foregroundColor(.bbText2)
//                    }
//                    .padding(.horizontal, 14).padding(.vertical, 9)
//                    .background(Color.bbSurface)
//                    .cornerRadius(9)
//                    .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.bbBorder, lineWidth: 1))
//                }
//
//                Spacer()
//
//                Button {} label: {
//                    HStack(spacing: 6) {
//                        Image(systemName: "arrow.down.to.line").font(.system(size: 12, weight: .semibold))
//                        Text("Export").font(.system(size: 13, weight: .semibold))
//                    }
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 14).padding(.vertical, 9)
//                    .background(Color.bbAccent).cornerRadius(9)
//                }
//            }
//        }
//        .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 20)
//        .sheet(isPresented: $showDatePicker) {
//            BBDateRangeSheet(start: $vm.startDate, end: $vm.endDate) { vm.refreshAll() }
//                .background(Color.bbSurface.ignoresSafeArea())
//        }
//    }
//
//    private var dateRangeLabel: String {
//        let f = DateFormatter(); f.dateFormat = "MMM d"
//        return "\(f.string(from: vm.startDate)) → \(f.string(from: vm.endDate))"
//    }
//
//    // MARK: Section label helper
//
//    private func bbSectionLabel(_ title: String) -> some View {
//        HStack(spacing: 12) {
//            Text(title)
//                .font(.system(size: 10, weight: .bold))
//                .foregroundColor(.bbMuted)
//                .kerning(1.4)
//            Rectangle().fill(Color.bbBorder).frame(height: 0.5)
//        }
//        .padding(.horizontal, 16).padding(.top, 10).padding(.bottom, 14)
//    }
//
//    // MARK: KPI Grid
//
//    private var keyMetricsGrid: some View {
//        let cards: [(String, String, Color)] = [
//            ("TOTAL VOLUME",  vm.totalVolume,   .bbAccent),
//            ("TRANSACTIONS",  vm.totalTxn,      .bbBlue),
//            ("SUCCESS RATE",  vm.successRate,   .bbCyan),
//            ("AVG PAYMENT",   vm.avgPayment,    .bbAmber),
//            ("PROC. FEES",    vm.processingFee, .bbPurple),
//            ("CUST. FEES",    vm.customerFee,   .bbRed),
//        ]
//        return LazyVGrid(
//            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
//            spacing: 12
//        ) {
//            ForEach(cards, id: \.0) { title, value, color in
//                BBMetricCard(title: title, value: value, color: color, loading: vm.kpiLoading)
//            }
//        }
//        .padding(.horizontal, 16).padding(.bottom, 20)
//    }
//
//    // MARK: Revenue Trend
//
//    private var revenueTrendCard: some View {
//        BBAnalyticsCard {
//            VStack(alignment: .leading, spacing: 14) {
//                HStack(alignment: .top) {
//                    VStack(alignment: .leading, spacing: 3) {
//                        Text("Revenue Over Time")
//                            .font(.system(size: 16, weight: .bold)).foregroundColor(.bbText1)
//                        Text("Track volume and payment count over the selected period")
//                            .font(.system(size: 12)).foregroundColor(.bbText2)
//                    }
//                    Spacer()
//                    Picker("", selection: $vm.revenueGranularity) {
//                        ForEach(RevenueGranularity.allCases) { g in
//                            Text(String(g.rawValue.prefix(1))).tag(g)
//                        }
//                    }
//                    .pickerStyle(.segmented).frame(width: 100)
//                }
//
//                Picker("Show", selection: $vm.revenueOverlay) {
//                    ForEach(RevenueOverlay.allCases) { o in Text(o.rawValue).tag(o) }
//                }
//                .pickerStyle(.segmented)
//
//                if vm.revenueLoading {
//                    bbLoadingRow
//                } else if vm.chartPoints.isEmpty {
//                    bbEmptyState("No chart data available.")
//                } else {
//                    BBLineChartView(
//                        points: vm.chartPoints,
//                        overlay: vm.revenueOverlay
//                    )
//                    .frame(height: 200)
//                }
//
//                HStack(spacing: 16) {
//                    BBLegendDot(color: .bbAccent, label: "Revenue ($)")
//                    BBLegendDot(color: .bbBlue,   label: "Payments")
//                    BBLegendDot(color: .bbPurple,  label: "Fees ($)")
//                }
//            }
//        }
//    }
//
//    // MARK: Transaction Health
//
//    private var transactionHealthRow: some View {
//        HStack(alignment: .top, spacing: 12) {
//            BBAnalyticsCard {
//                VStack(alignment: .leading, spacing: 10) {
//                    bbCardTitle("Payment Status Breakdown", sub: "Distribution of transaction outcomes")
//                    if vm.healthLoading { bbLoadingRow }
//                    else if vm.statusSlices.isEmpty { bbEmptyState("No status data.") }
//                    else {
//                        BBDonutChart(slices: vm.statusSlices).frame(height: 160)
//                        VStack(alignment: .leading, spacing: 6) {
//                            ForEach(vm.statusSlices) { s in
//                                HStack(spacing: 8) {
//                                    Circle().fill(Color(bbHex: s.color)).frame(width: 8, height: 8)
//                                    Text(s.label).font(.system(size: 11)).foregroundColor(.bbText2)
//                                    Spacer()
//                                    Text("\(s.value)").font(.system(size: 11, weight: .semibold)).foregroundColor(.bbText1)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//
//            BBAnalyticsCard {
//                VStack(alignment: .leading, spacing: 10) {
//                    bbCardTitle("Payment Method Distribution", sub: "Crypto customers pay with")
//                    if vm.healthLoading { bbLoadingRow }
//                    else if vm.methodBars.isEmpty { bbEmptyState("No method data.") }
//                    else {
//                        BBHorizontalBarChart(bars: vm.methodBars.map {
//                            BBBarItem(label: $0.label, value: Double($0.value), color: Color(bbHex: $0.color))
//                        })
//                        .frame(height: 160)
//                    }
//                }
//            }
//        }
//        .padding(.horizontal, 16).padding(.bottom, 16)
//    }
//
//    // MARK: Payment Type Performance
//
//    private var paymentTypeCard: some View {
//        BBAnalyticsCard {
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    bbCardTitle("Payment Type Performance", sub: "Which sources are driving revenue")
//                    Spacer()
//                    if !vm.paymentSourceLoading && !vm.paymentSourceData.isEmpty {
//                        Text("\(vm.totalPaymentSourceTxn) txns")
//                            .font(.system(size: 11, design: .monospaced)).foregroundColor(.bbMuted)
//                    }
//                }
//                Divider().background(Color.bbBorder)
//                if vm.paymentSourceLoading { bbLoadingRow }
//                else if vm.paymentSourceData.isEmpty { bbEmptyState("No payment type data for this period.") }
//                else {
//                    HStack {
//                        Text("TYPE").frame(maxWidth: .infinity, alignment: .leading)
//                        Text("TXN").frame(width: 55, alignment: .trailing)
//                        Text("REVENUE").frame(width: 85, alignment: .trailing)
//                        Text("SHARE").frame(width: 70, alignment: .trailing)
//                    }
//                    .font(.system(size: 10, weight: .bold)).foregroundColor(.bbMuted)
//
//                    ForEach(Array(vm.paymentSourceData.enumerated()), id: \.offset) { idx, row in
//                        Divider().background(Color.bbBorder)
//                        HStack {
//                            Text(row.displayName)
//                                .font(.system(size: 13)).foregroundColor(.bbText1)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text("\(row.count)")
//                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbText2)
//                                .frame(width: 55, alignment: .trailing)
//                            Text(bbFmtUSD(row.revenueVal))
//                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbAccent)
//                                .frame(width: 85, alignment: .trailing)
//                            VStack(alignment: .trailing, spacing: 3) {
//                                let pct: CGFloat = vm.totalPaymentSourceTxn > 0
//                                    ? CGFloat(row.count) / CGFloat(vm.totalPaymentSourceTxn) : 0
//                                GeometryReader { geo in
//                                    ZStack(alignment: .leading) {
//                                        RoundedRectangle(cornerRadius: 2).fill(Color.bbBorder).frame(height: 4)
//                                        RoundedRectangle(cornerRadius: 2).fill(bbPaletteColor(idx))
//                                            .frame(width: geo.size.width * pct, height: 4)
//                                    }
//                                }
//                                .frame(height: 4)
//                                Text("\(Int(pct * 100))%")
//                                    .font(.system(size: 10, design: .monospaced)).foregroundColor(.bbMuted)
//                            }
//                            .frame(width: 70)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: Top Products
//
//    private var topProductsCard: some View {
//        BBAnalyticsCard {
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    bbCardTitle("Top Payment Links / Products", sub: "Best-performing offerings by revenue")
//                    Spacer()
//                    if !vm.topProductsLoading && !vm.topProductsData.isEmpty {
//                        Text("\(vm.topProductsData.count) products")
//                            .font(.system(size: 11, design: .monospaced)).foregroundColor(.bbMuted)
//                    }
//                }
//                Divider().background(Color.bbBorder)
//                if vm.topProductsLoading { bbLoadingRow }
//                else if vm.topProductsData.isEmpty { bbEmptyState("No product data for this period.") }
//                else {
//                    HStack {
//                        Text("#").frame(width: 24, alignment: .leading)
//                        Text("PRODUCT").frame(maxWidth: .infinity, alignment: .leading)
//                        Text("TXN").frame(width: 55, alignment: .trailing)
//                        Text("REVENUE").frame(width: 85, alignment: .trailing)
//                    }
//                    .font(.system(size: 10, weight: .bold)).foregroundColor(.bbMuted)
//
//                    ForEach(Array(vm.topProductsData.enumerated()), id: \.offset) { idx, row in
//                        Divider().background(Color.bbBorder)
//                        HStack(alignment: .top) {
//                            Text("\(idx + 1)")
//                                .font(.system(size: 12, design: .monospaced)).foregroundColor(.bbMuted)
//                                .frame(width: 24, alignment: .leading)
//                            Text(row.productDescription ?? "—")
//                                .font(.system(size: 13)).foregroundColor(.bbText1)
//                                .lineLimit(1)
//                                .frame(maxWidth: .infinity, alignment: .leading)
//                            Text("\(row.count)")
//                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbText2)
//                                .frame(width: 55, alignment: .trailing)
//                            Text(bbFmtUSD(row.revenueVal))
//                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbAccent)
//                                .frame(width: 85, alignment: .trailing)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: Distribution & Geography
//
//    private var distributionRow: some View {
//        HStack(alignment: .top, spacing: 12) {
//            BBAnalyticsCard {
//                VStack(alignment: .leading, spacing: 10) {
//                    bbCardTitle("Txn Size Distribution", sub: "Spending by payment size")
//                    if vm.txnSizeLoading { bbLoadingRow }
//                    else if vm.txnSizeData.isEmpty { bbEmptyState("No size data.") }
//                    else {
//                        BBVerticalBarChart(bars: vm.txnSizeData.map {
//                            BBBarItem(label: $0.bucket ?? "", value: Double($0.count), color: .bbBlue)
//                        })
//                        .frame(height: 140)
//                    }
//                }
//            }
//
//            BBAnalyticsCard {
//                VStack(alignment: .leading, spacing: 10) {
//                    HStack {
//                        bbCardTitle("Top Countries", sub: "Geographic distribution")
//                        Spacer()
//                        if !vm.geoLoading && !vm.geoData.isEmpty {
//                            Text("\(vm.geoData.count) countries")
//                                .font(.system(size: 10, design: .monospaced)).foregroundColor(.bbMuted)
//                        }
//                    }
//                    if vm.geoLoading { bbLoadingRow }
//                    else if vm.geoData.isEmpty { bbEmptyState("No geographic data.") }
//                    else {
//                        ForEach(Array(vm.geoData.enumerated()), id: \.offset) { idx, g in
//                            VStack(spacing: 4) {
//                                HStack {
//                                    Text(g.country ?? "Unknown")
//                                        .font(.system(size: 13)).foregroundColor(.bbText1)
//                                    Spacer()
//                                    Text("\(g.count)")
//                                        .font(.system(size: 12, design: .monospaced)).foregroundColor(.bbText2)
//                                }
//                                GeometryReader { geo in
//                                    let pct: CGFloat = vm.maxGeoTxn > 0
//                                        ? CGFloat(g.count) / CGFloat(vm.maxGeoTxn) : 0
//                                    ZStack(alignment: .leading) {
//                                        RoundedRectangle(cornerRadius: 2).fill(Color.bbBorder).frame(height: 4)
//                                        RoundedRectangle(cornerRadius: 2).fill(bbPaletteColor(idx))
//                                            .frame(width: geo.size.width * pct, height: 4)
//                                    }
//                                }
//                                .frame(height: 4)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        .padding(.horizontal, 16).padding(.bottom, 16)
//    }
//
//    // MARK: Failure Analysis
//
//    private var failureCard: some View {
//        BBAnalyticsCard {
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    bbCardTitle("Payment Failures", sub: "What's causing checkout drop-offs")
//                    Spacer()
//                    if !vm.failureLoading && !vm.failureData.isEmpty {
//                        let total = vm.failureData.reduce(0) { $0 + $1.count }
//                        Text("\(total) failures")
//                            .font(.system(size: 11, design: .monospaced)).foregroundColor(.bbRed)
//                    }
//                }
//                Divider().background(Color.bbBorder)
//                if vm.failureLoading { bbLoadingRow }
//                else if vm.failureData.isEmpty { bbEmptyState("No failure data for this period.") }
//                else {
//                    HStack {
//                        Text("REASON").frame(maxWidth: .infinity, alignment: .leading)
//                        Text("COUNT").frame(width: 70, alignment: .trailing)
//                    }
//                    .font(.system(size: 10, weight: .bold)).foregroundColor(.bbMuted)
//
//                    ForEach(Array(vm.failureData.enumerated()), id: \.offset) { _, r in
//                        Divider().background(Color.bbBorder)
//                        VStack(spacing: 6) {
//                            HStack {
//                                Circle().fill(Color.bbRed).frame(width: 7, height: 7)
//                                Text(r.reason ?? "—")
//                                    .font(.system(size: 13)).foregroundColor(.bbText1)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                Text("\(r.count)")
//                                    .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbRed)
//                                    .frame(width: 70, alignment: .trailing)
//                            }
//                            GeometryReader { geo in
//                                let pct: CGFloat = vm.maxFailCount > 0
//                                    ? CGFloat(r.count) / CGFloat(vm.maxFailCount) : 0
//                                ZStack(alignment: .leading) {
//                                    RoundedRectangle(cornerRadius: 2).fill(Color.bbBorder).frame(height: 4)
//                                    RoundedRectangle(cornerRadius: 2).fill(Color.bbRed)
//                                        .frame(width: geo.size.width * pct, height: 4)
//                                }
//                            }
//                            .frame(height: 4)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: Settlement
//
//    private var settlementCard: some View {
//        BBAnalyticsCard {
//            VStack(alignment: .leading, spacing: 14) {
//                bbCardTitle("Settlement Summary", sub: "Finance team overview of funds movement")
//                if vm.settlementLoading { bbLoadingRow }
//                else {
//                    HStack(spacing: 12) {
//                        bbSettleTile("SETTLED",  vm.totalSettled,      .bbAccent)
//                        bbSettleTile("PENDING",  vm.pendingSettlement, .bbAmber)
//                        bbSettleTile("AVG TIME", vm.avgSettlementTime, .bbBlue)
//                    }
//                }
//            }
//        }
//    }
//
//    private func bbSettleTile(_ label: String, _ value: String, _ color: Color) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(.bbText2).kerning(0.5)
//            Text(value).font(.system(size: 20, weight: .bold, design: .monospaced)).foregroundColor(color)
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(14)
//        .background(Color.bbSurfaceAlt)
//        .cornerRadius(12)
//        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1.5))
//    }
//
//    // MARK: Download Reports
//
//    private var downloadReportsCard: some View {
//        BBAnalyticsCard {
//            VStack(alignment: .leading, spacing: 14) {
//                bbCardTitle("Downloadable Reports", sub: "Export data for accounting and analysis")
//                let items: [(String, String, Color)] = [
//                    ("Transactions",    "doc.text.fill",               .bbCyan),
//                    ("Fees",            "banknote.fill",               .bbAmber),
//                    ("Revenue Summary", "chart.line.uptrend.xyaxis",   .bbBlue),
//                    ("Subscriptions",   "arrow.triangle.2.circlepath", .bbAccent),
//                ]
//                LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
//                    ForEach(items, id: \.0) { label, icon, color in
//                        Button {} label: {
//                            VStack(spacing: 10) {
//                                Image(systemName: icon).font(.system(size: 26)).foregroundColor(.white)
//                                Text(label).font(.system(size: 12, weight: .bold)).foregroundColor(.white)
//                                    .multilineTextAlignment(.center)
//                                Text("↓  CSV")
//                                    .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
//                                    .padding(.horizontal, 14).padding(.vertical, 6)
//                                    .background(Color.bbAccent).cornerRadius(7)
//                            }
//                            .frame(maxWidth: .infinity)
//                            .padding(14)
//                            .background(Color.bbSurfaceAlt)
//                            .cornerRadius(14)
//                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(color, lineWidth: 1.5))
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    // MARK: Shared micro-helpers
//
//    private func bbCardTitle(_ title: String, sub: String) -> some View {
//        VStack(alignment: .leading, spacing: 3) {
//            Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.bbText1)
//            Text(sub).font(.system(size: 11)).foregroundColor(.bbText2)
//        }
//    }
//
//    private var bbLoadingRow: some View {
//        HStack(spacing: 10) {
//            ProgressView().tint(.bbAccent)
//            Text("Loading…").font(.system(size: 13)).foregroundColor(.bbText2)
//        }
//        .frame(maxWidth: .infinity).padding(.vertical, 20)
//    }
//
//    private func bbEmptyState(_ msg: String) -> some View {
//        VStack(spacing: 8) {
//            Text("📭").font(.system(size: 26)).opacity(0.4)
//            Text(msg).font(.system(size: 13)).foregroundColor(.bbMuted).multilineTextAlignment(.center)
//        }
//        .frame(maxWidth: .infinity).padding(.vertical, 22)
//    }
//
//    private func bbFmtUSD(_ v: Double) -> String { "$" + String(format: "%.2f", v) }
//}
//
//// MARK: - Card Container
//
//struct BBAnalyticsCard<Content: View>: View {
//    @ViewBuilder let content: () -> Content
//    var body: some View {
//        content()
//            .padding(16)
//            .background(Color.bbSurface)
//            .cornerRadius(14)
//            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bbBorder, lineWidth: 1))
//            .padding(.horizontal, 16)
//            .padding(.bottom, 16)
//    }
//}
//
//// MARK: - Legend Dot
//
//struct BBLegendDot: View {
//    let color: Color; let label: String
//    var body: some View {
//        HStack(spacing: 5) {
//            Circle().fill(color).frame(width: 9, height: 9)
//            Text(label).font(.system(size: 11)).foregroundColor(.bbText2)
//        }
//    }
//}
//
//// MARK: - Metric Card
//
//struct BBMetricCard: View {
//    let title: String; let value: String; let color: Color; let loading: Bool
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text(title).font(.system(size: 10, weight: .semibold)).foregroundColor(.bbText2).kerning(0.5)
//            if loading {
//                RoundedRectangle(cornerRadius: 4).fill(Color.bbBorder).frame(height: 26).bbShimmer()
//            } else {
//                Text(value).font(.system(size: 22, weight: .bold, design: .monospaced)).foregroundColor(color)
//            }
//        }
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .padding(14)
//        .background(Color.bbSurface)
//        .cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color, lineWidth: 1.5))
//    }
//}
//
//// MARK: - Date Range Sheet
//
//struct BBDateRangeSheet: View {
//    @Binding var start: Date
//    @Binding var end: Date
//    var onApply: () -> Void
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Text("Select Date Range")
//                .font(.system(size: 17, weight: .bold)).foregroundColor(.bbText1)
//                .padding(.top, 24)
//
//            DatePicker("Start", selection: $start, displayedComponents: .date)
//                .datePickerStyle(.compact).colorScheme(.dark).padding(.horizontal)
//
//            DatePicker("End", selection: $end, in: start..., displayedComponents: .date)
//                .datePickerStyle(.compact).colorScheme(.dark).padding(.horizontal)
//
//            Button("Apply") { onApply(); dismiss() }
//                .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
//                .frame(maxWidth: .infinity).padding(.vertical, 14)
//                .background(Color.bbAccent).cornerRadius(12).padding(.horizontal)
//
//            Spacer()
//        }
//        .background(Color.bbSurface.ignoresSafeArea())
//    }
//}
//
//// MARK: - Pure-SwiftUI Line Chart
//
//struct BBLineChartView: View {
//    let points: [ChartDataPoint]
//    let overlay: RevenueOverlay
//
//    var body: some View {
//        GeometryReader { geo in
//            let w = geo.size.width
//            let h = geo.size.height
//
//            ZStack {
//                // Grid lines
//                ForEach(0..<5) { i in
//                    let y = h * CGFloat(i) / 4
//                    Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: w, y: y)) }
//                        .stroke(Color.bbBorder, lineWidth: 0.5)
//                }
//
//                if !points.isEmpty {
//                    let revMax  = points.map(\.revenue).max() ?? 1
//                    let cntMax  = Double(points.map(\.count).max() ?? 1)
//                    let feesMax = points.map(\.fees).max() ?? 1
//
//                    if overlay == .revenue || overlay == .all {
//                        bbLine(points: points, value: \.revenue, max: revMax, size: geo.size, color: .bbAccent)
//                        bbArea(points: points, value: \.revenue, max: revMax, size: geo.size, color: Color.bbAccent.opacity(0.09))
//                    }
//                    if overlay == .payments || overlay == .all {
//                        bbLine(points: points, value: { Double($0.count) }, max: cntMax, size: geo.size, color: .bbBlue)
//                    }
//                    if overlay == .fees || overlay == .all {
//                        bbLine(points: points, value: \.fees, max: feesMax, size: geo.size, color: .bbPurple)
//                        bbArea(points: points, value: \.fees, max: feesMax, size: geo.size, color: Color.bbPurple.opacity(0.09))
//                    }
//                }
//            }
//        }
//    }
//
//    private func xPos(_ i: Int, width: CGFloat) -> CGFloat {
//        guard points.count > 1 else { return width / 2 }
//        return width * CGFloat(i) / CGFloat(points.count - 1)
//    }
//
//    private func yPos(_ val: Double, max: Double, height: CGFloat) -> CGFloat {
//        let safe = max == 0 ? 1 : max
//        return height - height * CGFloat(val / safe) * 0.9 - height * 0.05
//    }
//
//    private func bbLine(points: [ChartDataPoint], value: (ChartDataPoint) -> Double, max: Double, size: CGSize, color: Color) -> some View {
//        Path { p in
//            for (i, pt) in points.enumerated() {
//                let x = xPos(i, width: size.width)
//                let y = yPos(value(pt), max: max, height: size.height)
//                if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
//                else       { p.addLine(to: CGPoint(x: x, y: y)) }
//            }
//        }
//        .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
//    }
//
//    private func bbArea(points: [ChartDataPoint], value: (ChartDataPoint) -> Double, max: Double, size: CGSize, color: Color) -> some View {
//        Path { p in
//            guard let first = points.first else { return }
//            p.move(to: CGPoint(x: 0, y: size.height))
//            for (i, pt) in points.enumerated() {
//                let x = xPos(i, width: size.width)
//                let y = yPos(value(pt), max: max, height: size.height)
//                if i == 0 { p.addLine(to: CGPoint(x: x, y: y)) }
//                else       { p.addLine(to: CGPoint(x: x, y: y)) }
//            }
//            p.addLine(to: CGPoint(x: xPos(points.count - 1, width: size.width), y: size.height))
//            p.closeSubpath()
//        }
//        .fill(color)
//    }
//}
//
//// MARK: - Bar chart item
//
//struct BBBarItem: Identifiable {
//    let id    = UUID()
//    let label: String
//    let value: Double
//    let color: Color
//}
//
//// MARK: - Vertical Bar Chart (Txn Size)
//
//struct BBVerticalBarChart: View {
//    let bars: [BBBarItem]
//    var body: some View {
//        GeometryReader { geo in
//            let maxVal = bars.map(\.value).max() ?? 1
//            let barW   = (geo.size.width / CGFloat(bars.count)) * 0.6
//            let gap    = geo.size.width / CGFloat(bars.count)
//
//            ZStack(alignment: .bottom) {
//                // Grid
//                ForEach(0..<4) { i in
//                    let y = geo.size.height * CGFloat(i) / 3
//                    Path { p in p.move(to: CGPoint(x: 0, y: y)); p.addLine(to: CGPoint(x: geo.size.width, y: y)) }
//                        .stroke(Color.bbBorder, lineWidth: 0.5)
//                }
//
//                HStack(alignment: .bottom, spacing: 0) {
//                    ForEach(Array(bars.enumerated()), id: \.offset) { idx, bar in
//                        VStack(spacing: 4) {
//                            Spacer(minLength: 0)
//                            RoundedRectangle(cornerRadius: 3)
//                                .fill(bar.color)
//                                .frame(
//                                    width: barW,
//                                    height: max(2, geo.size.height * 0.85 * CGFloat(bar.value / maxVal))
//                                )
//                            Text(bar.label)
//                                .font(.system(size: 8)).foregroundColor(.bbMuted)
//                                .lineLimit(1).frame(width: gap)
//                        }
//                        .frame(width: gap)
//                    }
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Horizontal Bar Chart (Payment Method)
//
//struct BBHorizontalBarChart: View {
//    let bars: [BBBarItem]
//    var body: some View {
//        let maxVal = bars.map(\.value).max() ?? 1
//        VStack(alignment: .leading, spacing: 10) {
//            ForEach(bars) { bar in
//                HStack(spacing: 10) {
//                    Text(bar.label)
//                        .font(.system(size: 11, design: .monospaced))
//                        .foregroundColor(.bbText2)
//                        .frame(width: 38, alignment: .trailing)
//                    GeometryReader { geo in
//                        ZStack(alignment: .leading) {
//                            RoundedRectangle(cornerRadius: 3).fill(Color.bbBorder).frame(height: 12)
//                            RoundedRectangle(cornerRadius: 3).fill(bar.color)
//                                .frame(width: geo.size.width * CGFloat(bar.value / maxVal), height: 12)
//                        }
//                    }
//                    .frame(height: 12)
//                    Text("\(Int(bar.value))")
//                        .font(.system(size: 11, design: .monospaced))
//                        .foregroundColor(.bbText2)
//                        .frame(width: 36, alignment: .leading)
//                }
//            }
//        }
//    }
//}
//
//// MARK: - Donut Chart (pure SwiftUI)
//
//struct BBDonutChart: View {
//    let slices: [StatusSlice]
//
//    var body: some View {
//        GeometryReader { geo in
//            let total  = Double(slices.reduce(0) { $0 + $1.value })
//            let size   = min(geo.size.width, geo.size.height)
//            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
//            let outer  = size / 2
//            let inner  = outer * 0.62
//
//            ZStack {
//                var startAngle = Angle(degrees: -90)
//                ForEach(slices) { s in
//                    let sweep = Angle(degrees: total > 0 ? 360 * Double(s.value) / total : 0)
//                    let end   = startAngle + sweep
//                    let slice = BBDonutSlicePath(center: center, inner: inner, outer: outer,
//                                                 start: startAngle, end: end)
//                    Path(slice).fill(Color(bbHex: s.color))
//                    let _ = { startAngle = end }()
//                }
//            }
//        }
//    }
//}
//
//private func BBDonutSlicePath(center: CGPoint, inner: CGFloat, outer: CGFloat,
//                               start: Angle, end: Angle) -> CGPath {
//    let path = CGMutablePath()
//    path.addArc(center: center, radius: outer, startAngle: CGFloat(start.radians),
//                endAngle: CGFloat(end.radians), clockwise: false)
//    path.addArc(center: center, radius: inner, startAngle: CGFloat(end.radians),
//                endAngle: CGFloat(start.radians), clockwise: true)
//    path.closeSubpath()
//    return path
//}
//
//// MARK: - Shimmer
//
//struct BBShimmerModifier: ViewModifier {
//    @State private var phase: CGFloat = -1
//    func body(content: Content) -> some View {
//        content.overlay(
//            GeometryReader { geo in
//                LinearGradient(
//                    stops: [
//                        .init(color: .clear, location: 0),
//                        .init(color: Color.bbText2.opacity(0.2), location: 0.4),
//                        .init(color: .clear, location: 1),
//                    ],
//                    startPoint: .leading, endPoint: .trailing
//                )
//                .frame(width: geo.size.width * 3)
//                .offset(x: phase * geo.size.width * 3)
//                .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: phase)
//                .onAppear { phase = 1 }
//            }
//            .clipped()
//        )
//    }
//}
//extension View {
//    func bbShimmer() -> some View { modifier(BBShimmerModifier()) }
//}
//
//// MARK: - Toast
//
//struct BBToastModifier: ViewModifier {
//    let message: String?
//    let isError: Bool
//    let onDismiss: () -> Void
//
//    func body(content: Content) -> some View {
//        ZStack(alignment: .top) {
//            content
//            if let msg = message {
//                Text(msg)
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 16).padding(.vertical, 10)
//                    .background(isError ? Color.bbRed : Color.bbAccent)
//                    .cornerRadius(10)
//                    .shadow(radius: 6)
//                    .padding(.top, 12)
//                    .transition(.move(edge: .top).combined(with: .opacity))
//                    .onTapGesture { onDismiss() }
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { onDismiss() }
//                    }
//            }
//        }
//        .animation(.spring(), value: message)
//    }
//}
//extension View {
//    func bbToast(message: String?, isError: Bool, onDismiss: @escaping () -> Void) -> some View {
//        modifier(BBToastModifier(message: message, isError: isError, onDismiss: onDismiss))
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    AnalyticsView()
//}



// BillbitcoinsAnalyticsView.swift
// Trading_Terminal
// Redesigned to match Android layout:
//   • Purple/blue accent section headers
//   • Dual-axis line chart with Y-axis labels on both sides + X-axis date labels
//   • Vertical bar chart with labeled Y-axis grid + X-axis bucket labels
//   • Horizontal bar chart with Y-axis grid labels + X-axis labels
//   • Full-width cards for Transaction Health (no side-by-side)
//   • Full-width cards for Distribution & Geography (no side-by-side)

// BillbitcoinsAnalyticsView.swift
// Trading_Terminal
// Redesigned to match Android layout:
//   • Purple/blue accent section headers
//   • Dual-axis line chart with Y-axis labels on both sides + X-axis date labels
//   • Vertical bar chart with labeled Y-axis grid + X-axis bucket labels
//   • Horizontal bar chart with Y-axis grid labels + X-axis labels
//   • Full-width cards for Transaction Health (no side-by-side)
//   • Full-width cards for Distribution & Geography (no side-by-side)

// BillbitcoinsAnalyticsView.swift
// Trading_Terminal
// Redesigned to match Android layout:
//   • Purple/blue accent section headers
//   • Dual-axis line chart with Y-axis labels on both sides + X-axis date labels
//   • Vertical bar chart with labeled Y-axis grid + X-axis bucket labels
//   • Horizontal bar chart with Y-axis grid labels + X-axis labels
//   • Full-width cards for Transaction Health (no side-by-side)
//   • Full-width cards for Distribution & Geography (no side-by-side)

import SwiftUI

// MARK: - Colour palette

private extension Color {
    static let bbBG         = Color(bbHex: "#0d1117")
    static let bbSurface    = Color(bbHex: "#161b22")
    static let bbSurfaceAlt = Color(bbHex: "#1c2430")
    static let bbText1      = Color(bbHex: "#e6edf3")
    static let bbText2      = Color(bbHex: "#8b949e")
    static let bbMuted      = Color(bbHex: "#484f58")
    static let bbAccent     = Color(bbHex: "#3fb950")
    static let bbBlue       = Color(bbHex: "#58a6ff")
    static let bbAmber      = Color(bbHex: "#d29922")
    static let bbRed        = Color(bbHex: "#f85149")
    static let bbPurple     = Color(bbHex: "#bc8cff")
    static let bbCyan       = Color(bbHex: "#39c5cf")
//    static let bbBorder     = Color(bbHex: "#21262d")

    init(bbHex hex: String) {
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

private let bbPalette: [Color] = [.bbAccent, .bbBlue, .bbCyan, .bbAmber, .bbPurple, .bbRed]
private func bbPaletteColor(_ i: Int) -> Color { bbPalette[i % bbPalette.count] }

// MARK: - Root View

struct AnalyticsView: View {

    @StateObject private var vm = AnalyticsViewModel()
    @State private var showDatePicker = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.bbBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    bbSectionLabel("KEY METRICS");               keyMetricsGrid
                    bbSectionLabel("REVENUE TREND");             revenueTrendCard
                    bbSectionLabel("TRANSACTION HEALTH");        paymentStatusCard
                                                                 paymentMethodCard
                    bbSectionLabel("PAYMENT TYPE PERFORMANCE");  paymentTypeCard
                    bbSectionLabel("TOP PRODUCTS");              topProductsCard
                    bbSectionLabel("DISTRIBUTION & GEOGRAPHY");  txnSizeCard
                                                                 geoCard
                    bbSectionLabel("FAILURE ANALYSIS");          failureCard
                    bbSectionLabel("SETTLEMENT OVERVIEW");       settlementCard
                    bbSectionLabel("DOWNLOAD REPORTS");          downloadReportsCard
                    Spacer().frame(height: 120)
                }
            }

            // FAB
            Button { vm.refreshAll() } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 58, height: 58)
                    .background(Color.bbAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.bbAccent.opacity(0.45), radius: 12, x: 0, y: 6)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 32)
        }
        .onAppear { vm.refreshAll() }
        .onChange(of: vm.revenueGranularity) { _ in vm.fetchRevenueOverTime() }
        
        // In AnalyticsView body, alongside existing .onChange modifiers:
        .onChange(of: vm.exportTrigger?.type) { _ in

            guard let trigger = vm.exportTrigger else { return }

            guard let data = ReportExporter.buildXLSX(
                rows: trigger.rows,
                reportType: trigger.type
            ) else {
                return
            }

            let filename = "\(trigger.type.lowercased())_report.csv"

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(filename)

            do {
                try data.write(to: url)

                vm.exportURL = url

            } catch {
                print("Export write error:", error)
            }

            vm.exportTrigger = nil
        }
        .bbToast(message: vm.toastMessage, isError: vm.toastIsError) { vm.toastMessage = nil }
    
        .sheet(item: $vm.exportURL) { url in
            
            ShareSheett(items: [url])
        }
        }

    // MARK: Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
//                Image(systemName: "chart.bar.fill")
//                    .font(.system(size: 20))
//                    .foregroundColor(.bbPurple)
//                    .frame(width: 40, height: 40)
//                    .background(Color.bbPurple.opacity(0.15))
//                    .cornerRadius(10)

//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Insights")
//                        .font(.system(size: 20, weight: .bold))
//                        .foregroundColor(.bbText1)
//                    Text("Business performance and revenue trends")
//                        .font(.system(size: 12))
//                        .foregroundColor(.bbText2)
//                }
//                Spacer()
            }

            // Controls row —
            
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 10) {
                    // Date range
                    Button { showDatePicker.toggle() } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(.bbText2)
                                .font(.system(size: 12))
                            Text(dateRangeLabel)
                                .font(.system(size: 12))
                                .foregroundColor(.bbText1)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .background(Color.bbSurface)
                        .cornerRadius(9)
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.bbBorder, lineWidth: 1))
                    }
                    
                    // Divider line like Android
                    Rectangle().fill(Color.bbBorder).frame(width: 1, height: 30)
                    
                    // Currency
                    Menu {
                        ForEach(["ALL","BTC","ETH","USDT","USDC","BCH"], id: \.self) { c in
                            Button(c) { vm.selectedCurrency = c; vm.refreshAll() }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "cube.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.bbText2)
                            Text(vm.selectedCurrency)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.bbText1)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10))
                                .foregroundColor(.bbText2)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 9)
                        .background(Color.bbSurface)
                        .cornerRadius(9)
                        .overlay(RoundedRectangle(cornerRadius: 9).stroke(Color.bbBorder, lineWidth: 1))
                    }
                    
                    Spacer()
                    
                    Button {} label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.down.to.line")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Export")
                                .font(.system(size: 13, weight: .semibold))
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(Color.bbAccent).cornerRadius(9)
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 16)
        .background(Color.bbSurface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bbBorder, lineWidth: 1))
        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 4)
        .sheet(isPresented: $showDatePicker) {
            BBDateRangeSheet(start: $vm.startDate, end: $vm.endDate) { vm.refreshAll() }
                .background(Color.bbSurface.ignoresSafeArea())
        }
    }

    private var dateRangeLabel: String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"
        return "\(f.string(from: vm.startDate)) → \(f.string(from: vm.endDate))"
    }

    // MARK: Section label (Android style — purple/blue accent)

    private func bbSectionLabel(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(.bbPurple)
            .kerning(1.2)
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 10)
    }

    // MARK: KPI Grid

    private var keyMetricsGrid: some View {
        let cards: [(String, String, Color)] = [
            ("TOTAL VOLUME",  vm.totalVolume,   .bbAccent),
            ("TRANSACTIONS",  vm.totalTxn,      .bbBlue),
            ("SUCCESS RATE",  vm.successRate,   .bbCyan),
            ("AVG PAYMENT",   vm.avgPayment,    .bbAmber),
            ("PROC. FEE",     vm.processingFee, .bbPurple),
            ("CUST. FEE",     vm.customerFee,   .bbBlue),
        ]
        return LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
            spacing: 10
        ) {
            ForEach(cards, id: \.0) { title, value, color in
                BBMetricCard(title: title, value: value, color: color, loading: vm.kpiLoading)
            }
        }
        .padding(.horizontal, 16).padding(.bottom, 4)
    }

    // MARK: Revenue Trend (Dual-axis line chart matching Android)

    private var revenueTrendCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 14) {
                bbCardTitle("Revenue Over Time",
                            sub: "Track volume and payment count across your selected period")

                // Granularity + overlay pickers in one row like Android
                HStack(spacing: 10) {
                    // D / W / M
                    HStack(spacing: 0) {
                        ForEach(RevenueGranularity.allCases) { g in
                            let selected = vm.revenueGranularity == g
                            Button {
                                vm.revenueGranularity = g
                            } label: {
                                Text(String(g.rawValue.prefix(1)))
                                    .font(.system(size: 13, weight: selected ? .bold : .regular))
                                    .foregroundColor(selected ? .bbText1 : .bbText2)
                                    .frame(width: 36, height: 32)
                                    .background(selected ? Color.bbSurfaceAlt : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .background(Color.bbBorder.opacity(0.4))
                    .cornerRadius(8)

                    Spacer()

                    // Rev / Pay / Fee / All
                    HStack(spacing: 0) {
                        ForEach(RevenueOverlay.allCases) { o in
                            let selected = vm.revenueOverlay == o
                            Button {
                                vm.revenueOverlay = o
                            } label: {
                                Text(o == .all ? "All" : overlayShortLabel(o))
                                    .font(.system(size: 12, weight: selected ? .bold : .regular))
                                    .foregroundColor(selected ? .bbText1 : .bbText2)
                                    .frame(width: 40, height: 30)
                                    .background(selected ? Color.bbSurfaceAlt : Color.clear)
                                    .cornerRadius(7)
                            }
                        }
                    }
                    .background(Color.bbBorder.opacity(0.4))
                    .cornerRadius(7)
                }

                if vm.revenueLoading {
                    bbLoadingRow
                } else if vm.chartPoints.isEmpty {
                    bbEmptyState("No chart data available.")
                } else {
                    // Dual-axis chart
                    BBDualAxisLineChart(
                        points: vm.chartPoints,
                        overlay: vm.revenueOverlay
                    )
                    .frame(height: 220)
                }

                // Legend
                HStack(spacing: 16) {
                    BBLegendDot(color: .bbAccent, label: "Revenue ($)")
                    BBLegendDot(color: .bbBlue,   label: "Payments")
                    BBLegendDot(color: .bbPurple,  label: "Fees ($)")
                }
                .padding(.top, 4)
            }
        }
    }

    private func overlayShortLabel(_ o: RevenueOverlay) -> String {
        switch o {
        case .revenue:  return "Rev"
        case .payments: return "Pay"
        case .fees:     return "Fee"
        case .all:      return "All"
        }
    }

    // MARK: Transaction Health — full-width cards like Android

    private var paymentStatusCard: some View {
        // Always show all 4 statuses like Android, even when count is 0
        let allStatuses: [(label: String, color: String)] = [
            ("SUCCESS", "#3fb950"),
            ("PENDING", "#d29922"),
            ("EXPIRED", "#8b949e"),
            ("FAILED",  "#f85149"),
        ]
        // Build a flexible lookup: matches "SUCCESS", "Successful", "success", "SUCCESSFUL" etc.
        func normalize(_ s: String) -> String {
            let up = s.uppercased()
            if up.hasPrefix("SUCC") { return "SUCCESS" }
            if up.hasPrefix("PEND") { return "PENDING" }
            if up.hasPrefix("EXP")  { return "EXPIRED" }
            if up.hasPrefix("FAIL") { return "FAILED" }
            return up
        }
        let lookup: [String: Int] = Dictionary(
            uniqueKeysWithValues: vm.statusSlices.map { (normalize($0.label), $0.value) }
        )
        let displaySlices: [StatusSlice] = {
            let mapped = allStatuses.map { s in
                StatusSlice(label: s.label, value: lookup[s.label] ?? 0, color: s.color)
            }
            // Filter to only non-zero for the donut drawing; if all zero show grey ring
            let nonZero = mapped.filter { $0.value > 0 }
            if nonZero.isEmpty {
                return [StatusSlice(label: "NONE", value: 1, color: "#2d3540")]
            }
            return nonZero  // donut only draws the slices that have value
        }()

        return BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 12) {
                bbCardTitle("Payment Status Breakdown",
                            sub: "Distribution of all transaction outcomes")
                if vm.healthLoading {
                    bbLoadingRow
                } else {
                    BBDonutChart(slices: displaySlices)
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(allStatuses, id: \.label) { s in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(Color(bbHex: s.color))
                                    .frame(width: 10, height: 10)
                                Text(s.label)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.bbText2)
                                Text(":")
                                    .foregroundColor(.bbText2)
                                Text("\(lookup[s.label] ?? 0)")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.bbText1)
                                Spacer()
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    private var paymentMethodCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 12) {
                bbCardTitle("Payment Method Distribution",
                            sub: "Which crypto customers actually pay with")
                if vm.healthLoading { bbLoadingRow }
                else if vm.methodBars.isEmpty { bbEmptyState("No method data.") }
                else {
                    // Vertical bar chart like Android (not horizontal)
                    BBLabeledVerticalBarChart(
                        bars: vm.methodBars.map {
                            BBBarItem(label: $0.label, value: Double($0.value),
                                      color: Color(bbHex: $0.color))
                        },
                        legendItems: vm.methodBars.enumerated().map { idx, b in
                            (Color(bbHex: b.color), "\(b.label): \(b.value) (\(vm.methodBars.reduce(0){$0+$1.value} > 0 ? Int(Double(b.value)/Double(vm.methodBars.reduce(0){$0+$1.value})*100) : 0)%)")
                        }
                    )
                    .frame(height: 180)
                }
            }
        }
    }

    // MARK: Payment Type Performance

    private var paymentTypeCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    bbCardTitle("Payment Type Performance",
                                sub: "Which payment sources are driving revenue")
                    Spacer()
                    if !vm.paymentSourceLoading && !vm.paymentSourceData.isEmpty {
                        Text("\(vm.totalPaymentSourceTxn) total txn · Total: \(bbFmtUSD(vm.paymentSourceData.reduce(0){$0+$1.revenueVal}))")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.bbMuted)
                    }
                }
                Divider().background(Color.bbBorder)

                if vm.paymentSourceLoading { bbLoadingRow }
                else if vm.paymentSourceData.isEmpty { bbEmptyState("No payment type data for this period.") }
                else {
                    HStack {
                        Text("Type").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Txn").frame(width: 50, alignment: .trailing)
                        Text("Revenue").frame(width: 80, alignment: .trailing)
                        Text("Share").frame(width: 80, alignment: .trailing)
                    }
                    .font(.system(size: 10)).foregroundColor(.bbText2)

                    ForEach(Array(vm.paymentSourceData.enumerated()), id: \.offset) { idx, row in
                        Divider().background(Color.bbBorder)
                        HStack {
                            Text(row.displayName)
                                .font(.system(size: 13)).foregroundColor(.bbText1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(row.count)")
                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbText2)
                                .frame(width: 50, alignment: .trailing)
                            Text(bbFmtUSD(row.revenueVal))
                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbAccent)
                                .frame(width: 80, alignment: .trailing)
                            // Share bar + pct
                            VStack(alignment: .trailing, spacing: 3) {
                                let pct: CGFloat = vm.totalPaymentSourceTxn > 0
                                    ? CGFloat(row.count) / CGFloat(vm.totalPaymentSourceTxn) : 0
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 2).fill(Color.bbBorder).frame(height: 5)
                                        RoundedRectangle(cornerRadius: 2).fill(bbPaletteColor(idx))
                                            .frame(width: geo.size.width * pct, height: 5)
                                    }
                                }
                                .frame(height: 5)
                                Text("\(Int(pct * 100))%")
                                    .font(.system(size: 10, design: .monospaced)).foregroundColor(.bbMuted)
                            }
                            .frame(width: 80)
                        }
                    }
                }
            }
        }
    }

    // MARK: Top Products

    private var topProductsCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    bbCardTitle("Top Payment Links / Products",
                                sub: "Your best-performing offerings by revenue")
                    Spacer()
                    if !vm.topProductsLoading && !vm.topProductsData.isEmpty {
                        Text("\(vm.topProductsData.count) items")
                            .font(.system(size: 11, design: .monospaced)).foregroundColor(.bbMuted)
                    }
                }
                Divider().background(Color.bbBorder)
                if vm.topProductsLoading { bbLoadingRow }
                else if vm.topProductsData.isEmpty { bbEmptyState("No product data for this period.") }
                else {
                    HStack {
                        Text("#").frame(width: 24, alignment: .leading)
                        Text("Product / Description").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Txn").frame(width: 50, alignment: .trailing)
                        Text("Revenue").frame(width: 80, alignment: .trailing)
                    }
                    .font(.system(size: 10)).foregroundColor(.bbText2)

                    ForEach(Array(vm.topProductsData.enumerated()), id: \.offset) { idx, row in
                        Divider().background(Color.bbBorder)
                        HStack(alignment: .top) {
                            Text("\(idx + 1)")
                                .font(.system(size: 12, design: .monospaced)).foregroundColor(.bbMuted)
                                .frame(width: 24, alignment: .leading)
                            Text(row.productDescription ?? "—")
                                .font(.system(size: 13)).foregroundColor(.bbText1)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(row.count)")
                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbText2)
                                .frame(width: 50, alignment: .trailing)
                            Text(bbFmtUSD(row.revenueVal))
                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbAccent)
                                .frame(width: 80, alignment: .trailing)
                        }
                    }
                }
            }
        }
    }

    // MARK: Distribution — full-width cards like Android

    private var txnSizeCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 10) {
                bbCardTitle("Transaction Size Distribution",
                            sub: "Customer spending behaviour by payment size")
                if vm.txnSizeLoading { bbLoadingRow }
                else if vm.txnSizeData.isEmpty { bbEmptyState("No size data.") }
                else {
                    BBLabeledVerticalBarChart(
                        bars: vm.txnSizeData.map {
                            BBBarItem(label: $0.bucket ?? "", value: Double($0.count), color: .bbBlue)
                        },
                        legendItems: []
                    )
                    .frame(height: 170)
                }
            }
        }
    }

    private var geoCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    bbCardTitle("Top Countries Paying",
                                sub: "Geographic distribution of transactions")
                    Spacer()
                    if !vm.geoLoading && !vm.geoData.isEmpty {
                        Text("\(vm.geoData.count) countries")
                            .font(.system(size: 10, design: .monospaced)).foregroundColor(.bbMuted)
                    }
                }
                if vm.geoLoading { bbLoadingRow }
                else if vm.geoData.isEmpty { bbEmptyState("No geographic data found.") }
                else {
                    VStack(spacing: 10) {
                        ForEach(Array(vm.geoData.enumerated()), id: \.offset) { idx, g in
                            HStack(spacing: 10) {
                                Text(g.country ?? "Unknown")
                                    .font(.system(size: 13)).foregroundColor(.bbText1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                GeometryReader { geo in
                                    let pct: CGFloat = vm.maxGeoTxn > 0
                                        ? CGFloat(g.count) / CGFloat(vm.maxGeoTxn) : 0
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3).fill(Color.bbBorder).frame(height: 8)
                                        RoundedRectangle(cornerRadius: 3).fill(bbPaletteColor(idx))
                                            .frame(width: geo.size.width * pct, height: 8)
                                    }
                                }
                                .frame(height: 8)
                                Text("\(g.count)")
                                    .font(.system(size: 12, design: .monospaced)).foregroundColor(.bbText2)
                                    .frame(width: 36, alignment: .trailing)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Failure Analysis

    private var failureCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    bbCardTitle("Payment Failures",
                                sub: "Understand what's causing checkout drop-offs")
                    Spacer()
                    if !vm.failureLoading && !vm.failureData.isEmpty {
                        let total = vm.failureData.reduce(0) { $0 + $1.count }
                        Text("\(total) failures")
                            .font(.system(size: 11, design: .monospaced)).foregroundColor(.bbRed)
                    }
                }
                Divider().background(Color.bbBorder)
                if vm.failureLoading { bbLoadingRow }
                else if vm.failureData.isEmpty { bbEmptyState("No failure data available.") }
                else {
                    HStack {
                        Text("Reason").frame(maxWidth: .infinity, alignment: .leading)
                        Text("Count").frame(width: 60, alignment: .trailing)
                        Text("Visual").frame(width: 80, alignment: .trailing)
                    }
                    .font(.system(size: 10)).foregroundColor(.bbText2)

                    ForEach(Array(vm.failureData.enumerated()), id: \.offset) { _, r in
                        Divider().background(Color.bbBorder)
                        HStack(spacing: 10) {
                            Text(r.reason ?? "—")
                                .font(.system(size: 13)).foregroundColor(.bbText1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("\(r.count)")
                                .font(.system(size: 13, design: .monospaced)).foregroundColor(.bbRed)
                                .frame(width: 60, alignment: .trailing)
                            GeometryReader { geo in
                                let pct: CGFloat = vm.maxFailCount > 0
                                    ? CGFloat(r.count) / CGFloat(vm.maxFailCount) : 0
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 3).fill(Color.bbBorder).frame(height: 8)
                                    RoundedRectangle(cornerRadius: 3).fill(Color.bbRed)
                                        .frame(width: geo.size.width * pct, height: 8)
                                }
                            }
                            .frame(width: 80, height: 8)
                        }
                    }
                }
            }
        }
    }

    // MARK: Settlement

    private var settlementCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 14) {
                bbCardTitle("Settlement Summary", sub: "Finance team overview of funds movement")
                if vm.settlementLoading { bbLoadingRow }
                else {
                    HStack(spacing: 12) {
                        bbSettleTile("SETTLED",  vm.totalSettled,      .bbAccent)
                        bbSettleTile("PENDING",  vm.pendingSettlement, .bbAmber)
                        bbSettleTile("AVG TIME", vm.avgSettlementTime, .bbBlue)
                    }
                }
            }
        }
    }

    private func bbSettleTile(_ label: String, _ value: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label).font(.system(size: 10, weight: .semibold)).foregroundColor(.bbText2).kerning(0.5)
            Text(value).font(.system(size: 18, weight: .bold, design: .monospaced)).foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.bbSurfaceAlt)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color, lineWidth: 1.5))
    }

    // MARK: Download Reports

    private var downloadReportsCard: some View {
        BBAnalyticsCard {
            VStack(alignment: .leading, spacing: 14) {
                bbCardTitle("Downloadable Reports",
                            sub: "Export your data for accounting and analysis")

                // Mirrors web ins-dl-grid
                let items: [(String, String, Color, String)] = [
                    ("📋", "Export Transactions",    .bbCyan,   "TRANSACTIONS"),
                    ("💸", "Export Fees",            .bbAmber,  "FEES"),
                    ("📈", "Export Revenue Summary", .bbBlue,   "REVENUE_SUMMARY"),
                    ("🔁", "Export Subscriptions",   .bbAccent, "SUBSCRIPTIONS"),
                ]

                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12),
                              GridItem(.flexible(), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(items, id: \.1) { emoji, label, color, reportType in
                        Button {
                            vm.downloadReport(type: reportType)
                        } label: {
                            VStack(spacing: 10) {
                                // Spinner when THIS button is loading
                                if vm.reportLoading && vm.reportType == reportType {
                                    ProgressView()
                                        .tint(.white)
                                        .frame(width: 28, height: 28)
                                } else {
                                    Text(emoji)
                                        .font(.system(size: 28))
                                }
                                Text(label)
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                Text("↓  xlsx")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14).padding(.vertical, 6)
                                    .background(Color.bbAccent)
                                    .cornerRadius(7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(14)
                            .background(Color.bbSurfaceAlt)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(color, lineWidth: 1.5)
                            )
                            .opacity(vm.reportLoading && vm.reportType != reportType ? 0.5 : 1)
                        }
                        .disabled(vm.reportLoading)  // disable all while one is loading
                    }
                }
            }
        }
    }

    // MARK: Shared micro-helpers

    private func bbCardTitle(_ title: String, sub: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.bbText1)
            Text(sub).font(.system(size: 11)).foregroundColor(.bbText2)
        }
    }

    private var bbLoadingRow: some View {
        HStack(spacing: 10) {
            ProgressView().tint(.bbAccent)
            Text("Loading…").font(.system(size: 13)).foregroundColor(.bbText2)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
    }

    private func bbEmptyState(_ msg: String) -> some View {
        VStack(spacing: 8) {
            Text("📭").font(.system(size: 26)).opacity(0.4)
            Text(msg).font(.system(size: 13)).foregroundColor(.bbMuted).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 22)
    }

    private func bbFmtUSD(_ v: Double) -> String { "$" + String(format: "%.2f", v) }
}

// MARK: - Card Container

struct BBAnalyticsCard<Content: View>: View {
    @ViewBuilder let content: () -> Content
    var body: some View {
        content()
            .padding(16)
            .background(Color.bbSurface)
            .cornerRadius(14)
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.bbBorder, lineWidth: 1))
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
    }
}

// MARK: - Legend Dot

struct BBLegendDot: View {
    let color: Color; let label: String
    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 9, height: 9)
            Text(label).font(.system(size: 11)).foregroundColor(.bbText2)
        }
    }
}

// MARK: - Metric Card

struct BBMetricCard: View {
    let title: String; let value: String; let color: Color; let loading: Bool
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 10, weight: .semibold)).foregroundColor(.bbText2).kerning(0.5)
            if loading {
                RoundedRectangle(cornerRadius: 4).fill(Color.bbBorder).frame(height: 26).bbShimmer()
            } else {
                Text(value).font(.system(size: 20, weight: .bold, design: .monospaced)).foregroundColor(color)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.bbSurface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color, lineWidth: 1.5))
    }
}

// MARK: - Date Range Sheet

struct BBDateRangeSheet: View {
    @Binding var start: Date
    @Binding var end: Date
    var onApply: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Select Date Range")
                .font(.system(size: 17, weight: .bold)).foregroundColor(.bbText1)
                .padding(.top, 24)

            DatePicker("Start", selection: $start, displayedComponents: .date)
                .datePickerStyle(.compact).colorScheme(.dark).padding(.horizontal)

            DatePicker("End", selection: $end, in: start..., displayedComponents: .date)
                .datePickerStyle(.compact).colorScheme(.dark).padding(.horizontal)

            Button("Apply") { onApply(); dismiss() }
                .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 14)
                .background(Color.bbAccent).cornerRadius(12).padding(.horizontal)

            Spacer()
        }
        .background(Color.bbSurface.ignoresSafeArea())
    }
}

// MARK: - Dual-Axis Line Chart (Android style)
// Left Y-axis (white) = revenue/$fees, Right Y-axis (blue) = payment count
// Horizontal grid lines with labels on both sides
// Vertical orange crosshair at each data point
// X-axis date labels below plot

struct BBDualAxisLineChart: View {
    let points: [ChartDataPoint]
    let overlay: RevenueOverlay

    // Layout constants — match Android spacing
    private let leftPad:   CGFloat = 48  // white Y-labels
    private let rightPad:  CGFloat = 40  // blue Y-labels
    private let bottomPad: CGFloat = 26  // X-labels
    private let gridLines  = 6           // 0.0 … max, 6 steps like Android

    var body: some View {
        GeometryReader { geo in
            let plotW = geo.size.width  - leftPad - rightPad
            let plotH = geo.size.height - bottomPad

            // Scale maxima — always at least 1 so we don't divide by zero
            let revMax  = max(points.map(\.revenue).max() ?? 0, 0.001)
            let cntMax  = max(Double(points.map(\.count).max() ?? 0), 0.001)
            let feesMax = max(points.map(\.fees).max()   ?? 0, 0.001)

            // Left axis uses revenue when showing Rev or All; fees when only Fees
            let leftMax: Double = (overlay == .fees) ? feesMax : revMax

            ZStack(alignment: .topLeading) {

                // ── LEFT Y-axis labels + horizontal grid lines ─────────
                ForEach(0..<gridLines, id: \.self) { i in
                    // i=0 → bottom (0.0), i=gridLines-1 → top (max)
                    let fraction = CGFloat(i) / CGFloat(gridLines - 1)
                    let val      = leftMax * Double(fraction)
                    // y=0 is top in SwiftUI, so invert
                    let y        = plotH * (1.0 - fraction)

                    // label (left side)
                    Text(bbShortNum(val))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.bbText2)
                        .frame(width: leftPad - 6, alignment: .trailing)
                        .position(x: (leftPad - 6) / 2, y: y)

                    // horizontal grid line across plot area
                    Path { p in
                        p.move(to:    CGPoint(x: leftPad, y: y))
                        p.addLine(to: CGPoint(x: leftPad + plotW, y: y))
                    }
                    .stroke(Color(bbHex: "#2d3540"), lineWidth: 0.6)
                }

                // ── RIGHT Y-axis labels (blue, payments count) ─────────
                // Always draw right axis so it mirrors Android even on Rev-only
                ForEach(0..<gridLines, id: \.self) { i in
                    let fraction = CGFloat(i) / CGFloat(gridLines - 1)
                    let val      = cntMax * Double(fraction)
                    let y        = plotH * (1.0 - fraction)

                    Text(bbShortNum(val))
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.bbBlue)
                        .frame(width: rightPad - 4, alignment: .leading)
                        .position(x: leftPad + plotW + (rightPad - 4) / 2 + 2, y: y)
                }

                // ── PLOT AREA ──────────────────────────────────────────
                ZStack(alignment: .topLeading) {

                    // Vertical crosshair lines at every data point (orange, like Android)
                    ForEach(0..<points.count, id: \.self) { i in
                        let x = xFrac(i) * plotW
                        Path { p in
                            p.move(to:    CGPoint(x: x, y: 0))
                            p.addLine(to: CGPoint(x: x, y: plotH))
                        }
                        .stroke(
                            Color.bbAmber.opacity(0.35),
                            style: StrokeStyle(lineWidth: 0.8, dash: [3, 5])
                        )
                    }

                    // Revenue line + fill
                    if overlay == .revenue || overlay == .all {
                        areaPath(points, val: \.revenue, max: revMax, w: plotW, h: plotH)
                            .fill(Color.bbAccent.opacity(0.12))
                        linePath(points, val: \.revenue, max: revMax, w: plotW, h: plotH)
                            .stroke(Color.bbAccent,
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }

                    // Payments line (scaled against right axis / cntMax)
                    if overlay == .payments || overlay == .all {
                        linePath(points, val: { Double($0.count) }, max: cntMax, w: plotW, h: plotH)
                            .stroke(Color.bbBlue,
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }

                    // Fees line + fill
                    if overlay == .fees || overlay == .all {
                        areaPath(points, val: \.fees, max: feesMax, w: plotW, h: plotH)
                            .fill(Color.bbPurple.opacity(0.08))
                        linePath(points, val: \.fees, max: feesMax, w: plotW, h: plotH)
                            .stroke(Color.bbPurple,
                                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    }
                }
                .frame(width: plotW, height: plotH)
                .offset(x: leftPad, y: 0)
                .clipped()

                // ── X-axis date labels ─────────────────────────────────
                // Show at most 4 evenly-spaced labels (like Android "15 Apr … 15 Apr")
                let xStep = max(1, (points.count - 1) / 3)
                ForEach(0..<points.count, id: \.self) { i in
                    if i % xStep == 0 || i == points.count - 1 {
                        let x = leftPad + xFrac(i) * plotW
                        Text(xLabel(points[i]))
                            .font(.system(size: 9))
                            .foregroundColor(.bbText2)
                            .fixedSize()
                            .position(x: x, y: plotH + bottomPad * 0.55)
                    }
                }

                // Left axis border line
                Path { p in
                    p.move(to:    CGPoint(x: leftPad, y: 0))
                    p.addLine(to: CGPoint(x: leftPad, y: plotH))
                }
                .stroke(Color(bbHex: "#2d3540"), lineWidth: 0.8)

                // Bottom axis border line
                Path { p in
                    p.move(to:    CGPoint(x: leftPad,          y: plotH))
                    p.addLine(to: CGPoint(x: leftPad + plotW,  y: plotH))
                }
                .stroke(Color(bbHex: "#2d3540"), lineWidth: 0.8)
            }
        }
    }

    // MARK: Helpers

    /// Fractional X position for index i (0…1)
    private func xFrac(_ i: Int) -> CGFloat {
        guard points.count > 1 else { return 0.5 }
        return CGFloat(i) / CGFloat(points.count - 1)
    }

    /// Y coordinate inside plot (0 = top, h = bottom)
    private func yCoord(_ val: Double, max: Double, h: CGFloat) -> CGFloat {
        let safe = max == 0 ? 1 : max
        // 4% top padding so the line never touches the very top edge
        return h - h * CGFloat(val / safe) * 0.92 - h * 0.04
    }

    private func linePath(_ pts: [ChartDataPoint],
                          val: (ChartDataPoint) -> Double,
                          max: Double, w: CGFloat, h: CGFloat) -> Path {
        Path { p in
            for (i, pt) in pts.enumerated() {
                let x = xFrac(i) * w
                let y = yCoord(val(pt), max: max, h: h)
                if i == 0 { p.move(to: .init(x: x, y: y)) }
                else       { p.addLine(to: .init(x: x, y: y)) }
            }
        }
    }

    private func areaPath(_ pts: [ChartDataPoint],
                          val: (ChartDataPoint) -> Double,
                          max: Double, w: CGFloat, h: CGFloat) -> Path {
        Path { p in
            guard !pts.isEmpty else { return }
            // Start at bottom-left
            p.move(to: .init(x: 0, y: h))
            for (i, pt) in pts.enumerated() {
                let x = xFrac(i) * w
                let y = yCoord(val(pt), max: max, h: h)
                p.addLine(to: .init(x: x, y: y))
            }
            // Close back along bottom
            p.addLine(to: .init(x: xFrac(pts.count - 1) * w, y: h))
            p.closeSubpath()
        }
    }

    private func xLabel(_ p: ChartDataPoint) -> String {
        let raw = p.label   // "2026-04-01 00:00:00.0" from API
        let parsers: [DateFormatter] = {
            let f1 = DateFormatter(); f1.dateFormat = "yyyy-MM-dd HH:mm:ss.S"
            let f2 = DateFormatter(); f2.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let f3 = DateFormatter(); f3.dateFormat = "yyyy-MM-dd"
            return [f1, f2, f3]
        }()
        let display = DateFormatter(); display.dateFormat = "d MMM"
        for f in parsers {
            if let d = f.date(from: raw) { return display.string(from: d) }
        }
        let datePart = raw.components(separatedBy: " ").first ?? raw
        return datePart.count >= 10 ? String(datePart.suffix(5)) : raw
    }

    private func bbShortNum(_ v: Double) -> String {
        if v >= 1_000_000 { return String(format: "%.1fM", v / 1_000_000) }
        if v >= 1_000     { return String(format: "%.1fk", v / 1_000) }
        if v == 0         { return "0.0" }
        // Show 1 decimal for small values like Android (0.4, 0.8, 1.2…)
        return String(format: "%.1f", v)
    }
}

// MARK: - Labeled Vertical Bar Chart (Android style with Y-axis grid + labels)

struct BBLabeledVerticalBarChart: View {
    let bars: [BBBarItem]
    let legendItems: [(Color, String)]   // color + label string for legend

    private let gridCount  = 5
    private let leftPad: CGFloat  = 36  // Y-axis labels width
    private let bottomPad: CGFloat = 20 // X-axis labels height

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                let plotW  = geo.size.width - leftPad
                let plotH  = geo.size.height - bottomPad
                let maxVal = bars.map(\.value).max() ?? 1

                ZStack(alignment: .topLeading) {
                    // Y-axis labels + grid lines
                    ForEach(0..<gridCount, id: \.self) { i in
                        let fraction = CGFloat(gridCount - 1 - i) / CGFloat(gridCount - 1)
                        let val      = maxVal * Double(fraction)
                        let y        = plotH * (1 - fraction)

                        // label
                        Text(bbShortNum(val))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.bbText2)
                            .frame(width: leftPad - 4, alignment: .trailing)
                            .position(x: (leftPad - 4) / 2, y: y)

                        // grid line
                        Path { p in
                            p.move(to: CGPoint(x: leftPad, y: y))
                            p.addLine(to: CGPoint(x: geo.size.width, y: y))
                        }
                        .stroke(Color.bbBorder, lineWidth: 0.5)
                        .offset(x: 0, y: 0)
                    }

                    // Bars + X labels
                    let barSlotW = plotW / CGFloat(bars.count)
                    let barW     = barSlotW * 0.55

                    ForEach(Array(bars.enumerated()), id: \.offset) { idx, bar in
                        let x     = leftPad + barSlotW * CGFloat(idx) + barSlotW / 2
                        let bh    = max(2, plotH * CGFloat(bar.value / maxVal))
                        let barY  = plotH - bh / 2

                        // bar
                        RoundedRectangle(cornerRadius: 4)
                            .fill(bar.color)
                            .frame(width: barW, height: bh)
                            .position(x: x, y: barY)

                        // X label
                        Text(bar.label)
                            .font(.system(size: 9))
                            .foregroundColor(.bbText2)
                            .lineLimit(1)
                            .frame(width: barSlotW - 4)
                            .position(x: x, y: plotH + bottomPad / 2)
                    }
                }
            }

            // Legend
            if !legendItems.isEmpty {
                HStack(spacing: 12) {
                    ForEach(Array(legendItems.enumerated()), id: \.offset) { _, item in
                        HStack(spacing: 5) {
                            Circle().fill(item.0).frame(width: 8, height: 8)
                            Text(item.1)
                                .font(.system(size: 10))
                                .foregroundColor(.bbText2)
                        }
                    }
                }
            }
        }
    }

    private func bbShortNum(_ v: Double) -> String {
        if v >= 1000 { return String(format: "%.1fk", v / 1000) }
        if v == v.rounded() { return String(Int(v)) }
        return String(format: "%.1f", v)
    }
}

// MARK: - Bar chart item

struct BBBarItem: Identifiable {
    let id    = UUID()
    let label: String
    let value: Double
    let color: Color
}

// MARK: - Horizontal Bar Chart (kept for backward compat)

struct BBHorizontalBarChart: View {
    let bars: [BBBarItem]
    var body: some View {
        let maxVal = bars.map(\.value).max() ?? 1
        VStack(alignment: .leading, spacing: 10) {
            ForEach(bars) { bar in
                HStack(spacing: 10) {
                    Text(bar.label)
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.bbText2)
                        .frame(width: 38, alignment: .trailing)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3).fill(Color.bbBorder).frame(height: 12)
                            RoundedRectangle(cornerRadius: 3).fill(bar.color)
                                .frame(width: geo.size.width * CGFloat(bar.value / maxVal), height: 12)
                        }
                    }
                    .frame(height: 12)
                    Text("\(Int(bar.value))")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.bbText2)
                        .frame(width: 36, alignment: .leading)
                }
            }
        }
    }
}

// MARK: - Donut Chart (pure SwiftUI, larger for full-width)

struct BBDonutChart: View {
    let slices: [StatusSlice]

    var body: some View {
        GeometryReader { geo in
            let total  = Double(slices.reduce(0) { $0 + $1.value })
            let size   = min(geo.size.width, geo.size.height)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let outer  = size / 2
            let inner  = outer * 0.60

            ZStack {
                var startAngle = Angle(degrees: -90)
                ForEach(slices) { s in
                    let sweep = Angle(degrees: total > 0 ? 360 * Double(s.value) / total : 0)
                    let end   = startAngle + sweep
                    let slice = BBDonutSlicePath(center: center, inner: inner, outer: outer,
                                                 start: startAngle, end: end)
                    Path(slice).fill(Color(bbHex: s.color))
                    let _ = { startAngle = end }()
                }
            }
        }
    }
}

private func BBDonutSlicePath(center: CGPoint, inner: CGFloat, outer: CGFloat,
                               start: Angle, end: Angle) -> CGPath {
    let path = CGMutablePath()
    path.addArc(center: center, radius: outer, startAngle: CGFloat(start.radians),
                endAngle: CGFloat(end.radians), clockwise: false)
    path.addArc(center: center, radius: inner, startAngle: CGFloat(end.radians),
                endAngle: CGFloat(start.radians), clockwise: true)
    path.closeSubpath()
    return path
}

// MARK: - Shimmer

struct BBShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1
    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0),
                        .init(color: Color.bbText2.opacity(0.2), location: 0.4),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: geo.size.width * 3)
                .offset(x: phase * geo.size.width * 3)
                .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: phase)
                .onAppear { phase = 1 }
            }
            .clipped()
        )
    }
}
extension View {
    func bbShimmer() -> some View { modifier(BBShimmerModifier()) }
}

// MARK: - Toast

struct BBToastModifier: ViewModifier {
    let message: String?
    let isError: Bool
    let onDismiss: () -> Void

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if let msg = message {
                Text(msg)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(isError ? Color.bbRed : Color.bbAccent)
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
        .animation(.spring(), value: message)
    }
}
extension View {
    func bbToast(message: String?, isError: Bool, onDismiss: @escaping () -> Void) -> some View {
        modifier(BBToastModifier(message: message, isError: isError, onDismiss: onDismiss))
    }
}

// MARK: - Preview

#Preview {
    AnalyticsView()
}
