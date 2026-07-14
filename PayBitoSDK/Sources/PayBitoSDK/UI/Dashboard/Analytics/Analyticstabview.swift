//
//  Analyticstabview.swift
//  PaymentsTerminsl


import SwiftUI

// MARK: - Which section is open

private enum AnalyticsSection: Hashable {
    case insights
    case rewards
}

// MARK: - Root Tab View

struct AnalyticsTabView: View {

    @State private var openSection: AnalyticsSection? = nil   // nil = both collapsed

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(bbHex2: "#0d1117").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Page header (matches Android "Analytics / Payment performance…") ──
                    pageHeader

                    // ── Divider ────────────────────────────────────────────────────────
                    Rectangle()
                        .fill(Color(bbHex2: "#21262d"))
                        .frame(height: 1)
                        .padding(.horizontal, 0)
                        .padding(.bottom, 12)

                    // ── Insights accordion card ────────────────────────────────────────
                    accordionCard(
                        section:   .insights,
                        icon:      "chart.bar.fill",
                        iconBG:    Color(bbHex2: "#bc8cff").opacity(0.18),
                        iconColor: Color(bbHex2: "#bc8cff"),
                        title:     "Insights",
                        subtitle:  "Business performance and revenue trends"
                    ) {
                        // Embed the existing AnalyticsView content
                        // (AnalyticsView must NOT embed its own NavigationView/TabView)
                        AnalyticsView()
                            // Remove the top safe-area gap AnalyticsView normally adds
                            .padding(.top, -16)
                    }

                    // ── Reward Analytics accordion card ────────────────────────────────
                    accordionCard(
                        section:   .rewards,
                        icon:      "gift.fill",
                        iconBG:    Color(bbHex2: "#58a6ff").opacity(0.18),
                        iconColor: Color(bbHex2: "#58a6ff"),
                        title:     "Reward Analytics",
                        subtitle:  "Rewards paid out today"
                    ) {
                        RewardAnalyticsView()
                    }

                    Spacer().frame(height: 100)
                }
            }
        }
    }

    // MARK: Page Header

    private var pageHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Analytics")
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(bbHex2: "#e6edf3"))
            Text("Payment performance, revenue trends & activity")
                .font(.system(size: 13))
                .foregroundColor(Color(bbHex2: "#8b949e"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }

    // MARK: Generic Accordion Card

    @ViewBuilder
    private func accordionCard<Content: View>(
        section:   AnalyticsSection,
        icon:      String,
        iconBG:    Color,
        iconColor: Color,
        title:     String,
        subtitle:  String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {

        let isOpen = openSection == section

        VStack(spacing: 0) {

            // ── Header row (always visible) ───────────────────────────────
            Button {
                withAnimation(.spring(response: 0.38, dampingFraction: 0.78)) {
                    openSection = isOpen ? nil : section
                }
            } label: {
                HStack(spacing: 14) {

                    // Icon badge
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(iconColor)
                        .frame(width: 44, height: 44)
                        .background(iconBG)
                        .cornerRadius(12)

                    // Title + subtitle
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(bbHex2: "#e6edf3"))
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(Color(bbHex2: "#8b949e"))
                            .lineLimit(2)
                    }

                    Spacer()

                    // Chevron — rotates when open
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(bbHex2: "#8b949e"))
                        .rotationEffect(.degrees(isOpen ? 180 : 0))
                        .animation(.spring(response: 0.38, dampingFraction: 0.78), value: isOpen)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .buttonStyle(.plain)

            // ── Expandable content ────────────────────────────────────────
            if isOpen {
                Divider()
                    .background(Color(bbHex2: "#21262d"))
                    .padding(.horizontal, 0)

                content()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal:   .opacity.combined(with: .move(edge: .top))
                        )
                    )
            }
        }
        .background(Color(bbHex2: "#161b22"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(bbHex2: "#21262d"), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 14)
    }
}

// MARK: - Color helper (local, avoids conflict with AnalyticsView's extension)

private extension Color {
    init(bbHex2 hex: String) {
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

