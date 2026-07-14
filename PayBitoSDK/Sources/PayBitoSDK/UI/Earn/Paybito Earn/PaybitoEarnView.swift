//import SwiftUI
//
//// MARK: - Hex Color Helper (private to avoid redeclaration conflicts)
//private func pbColor(_ hex: String) -> Color {
//    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//    var int: UInt64 = 0
//    Scanner(string: hex).scanHexInt64(&int)
//    let a, r, g, b: UInt64
//    switch hex.count {
//    case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//    case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//    case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//    default: (a, r, g, b) = (255, 0, 0, 0)
//    }
//    return Color(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
//}
//
//
//// MARK: - Color Theme
//extension Color {
//    static let pbBgPrimary = pbColor("#0D1117")
//    static let pbBgCard = pbColor("#161B22")
//    static let pbBgCardAlt = pbColor("#1C2333")
//    static let pbAccentPurple = pbColor("#8B5CF6")
//    static let pbAccentBlue = pbColor("#3B82F6")
//    static let pbAccentGreen = pbColor("#10B981")
//    static let pbAccentOrange = pbColor("#F59E0B")
//    static let pbAccentYellow = pbColor("#FBBF24")
//    static let pbTextPrimary = Color.white
//    static let pbTextSecondary = pbColor("#8B949E")
//    static let pbBorderBlue = pbColor("#1D4ED8")
//    static let pbBorderGreen = pbColor("#059669")
//    static let pbBorderOrange = pbColor("#D97706")
//    static let pbBorderPurple = pbColor("#7C3AED")
//    static let pbDotActive = pbColor("#22C55E")
//    static let pbDotPending = pbColor("#F59E0B")
//    static let pbDotInactive = pbColor("#4B5563")
//
//}
//
//// MARK: - Main PayBito Earn View
//struct PayBitoEarnView: View {
//    @State private var showReferralTools = false
//    @State private var emailInput = ""
//
//    var body: some View {
//        NavigationView {
//            ZStack(alignment: .bottomTrailing) {
//                Color.pbBgPrimary.ignoresSafeArea()
//
//                ScrollView {
//                    VStack(spacing: 20) {
//                        headerSection
//                        statsGrid
//                        referralProgressSection
//                        milestoneSection
//                        monthlyEarningsChart
//                        referralToolsSection
//                        referredMerchantsSection
//                        earningHistorySection
//                        howItWorksSection
//                        Spacer(minLength: 80)
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 8)
//                }
//
//                // FAB
//                Button(action: { showReferralTools = true }) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 22, weight: .semibold))
//                        .foregroundColor(.white)
//                        .frame(width: 56, height: 56)
//                        .background(Color.pbAccentBlue)
//                        .clipShape(RoundedRectangle(cornerRadius: 16))
//                        .shadow(color: Color.pbAccentBlue.opacity(0.4), radius: 12, x: 0, y: 4)
//                }
//                .padding(.trailing, 20)
//                .padding(.bottom, 30)
//            }
//            .navigationBarHidden(true)
//        }
//    }
//
//    // MARK: - Header
//    var headerSection: some View {
//        HStack(alignment: .top) {
//            Button(action: {}) {
//                Image(systemName: "arrow.left")
//                    .foregroundColor(.pbTextPrimary)
//                    .font(.system(size: 18, weight: .medium))
//            }
//
//            HStack(spacing: 12) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 12)
//                        .fill(pbColor("#1A2744"))
//                        .frame(width: 44, height: 44)
//                    Image(systemName: "gift.fill")
//                        .foregroundColor(Color.pbAccentGreen)
//                        .font(.system(size: 20))
//                }
//
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("PayBito Earn")
//                        .font(.system(size: 22, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    Text("Earn a share of processing fees by introducing businesses to PayBito.")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                        .fixedSize(horizontal: false, vertical: true)
//                }
//            }
//
//            Spacer()
//
//            Button(action: {}) {
//                Text("Invite Merchants")
//                    .font(.system(size: 14, weight: .semibold))
//                    .foregroundColor(.white)
//                    .padding(.horizontal, 14)
//                    .padding(.vertical, 10)
//                    .background(
//                        LinearGradient(colors: [pbColor("#7C3AED"), pbColor("#6D28D9")],
//                                       startPoint: .topLeading, endPoint: .bottomTrailing)
//                    )
//                    .clipShape(RoundedRectangle(cornerRadius: 12))
//            }
//        }
//        .padding(.top, 12)
//    }
//
//    // MARK: - Stats Grid
//    var statsGrid: some View {
//        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//            StatCard(
//                icon: "person.2.fill",
//                iconColor: .pbAccentBlue,
//                title: "TOTAL REFERRALS",
//                value: "0",
//                subtitle: "0 total referrals",
//                subtitleBg: pbColor("#1D2D50"),
//                subtitleColor: .pbAccentBlue,
//                borderColor: .pbBorderBlue
//            )
//
//            StatCard(
//                icon: "checkmark.circle.fill",
//                iconColor: .pbAccentGreen,
//                title: "ACTIVE MERCHANTS",
//                value: "0",
//                subtitle: "Verified & active",
//                subtitleBg: pbColor("#1A3A2E"),
//                subtitleColor: .pbAccentGreen,
//                borderColor: .pbBorderGreen
//            )
//
//            StatCard(
//                icon: "percent",
//                iconColor: .pbAccentOrange,
//                title: "REFERRAL VOLUME",
//                value: "$0",
//                subtitle: "Total processed",
//                subtitleBg: pbColor("#3A2A0D"),
//                subtitleColor: .pbAccentOrange,
//                borderColor: .pbBorderOrange
//            )
//
//            EarningsCard()
//        }
//    }
//
//    // MARK: - Referral Progress
//    var referralProgressSection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Referral Progress")
//                        .font(.system(size: 17, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    HStack(spacing: 4) {
//                        Image(systemName: "trophy.fill")
//                            .foregroundColor(.pbAccentOrange)
//                            .font(.system(size: 14))
//                        Text("Milestone rewards")
//                            .font(.system(size: 13))
//                            .foregroundColor(.pbTextSecondary)
//                    }
//                    HStack(spacing: 4) {
//                        Image(systemName: "info.circle")
//                            .foregroundColor(.pbAccentPurple)
//                            .font(.system(size: 12))
//                        Text("Learn more")
//                            .font(.system(size: 13))
//                            .foregroundColor(.pbAccentPurple)
//                    }
//                }
//                Spacer()
//                VStack(alignment: .trailing, spacing: 8) {
//                    Text("$0.00 Available")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(.pbAccentGreen)
//                    Button(action: {}) {
//                        Text("Settlement Wallet")
//                            .font(.system(size: 14, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 10)
//                            .background(
//                                LinearGradient(colors: [pbColor("#7C3AED"), pbColor("#6D28D9")],
//                                               startPoint: .topLeading, endPoint: .bottomTrailing)
//                            )
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                }
//            }
//            .padding(16)
//
//            Divider().background(Color.pbBgCardAlt)
//
//            VStack(alignment: .leading, spacing: 8) {
//                HStack {
//                    Text("$0 of $0 target")
//                        .font(.system(size: 15, weight: .medium))
//                        .foregroundColor(.pbTextPrimary)
//                    Spacer()
//                    Text("0.0%")
//                        .font(.system(size: 14, weight: .semibold))
//                        .foregroundColor(.pbAccentPurple)
//                }
//
//                GeometryReader { geo in
//                    ZStack(alignment: .leading) {
//                        RoundedRectangle(cornerRadius: 4)
//                            .fill(pbColor("#1C2333"))
//                            .frame(height: 8)
//                        RoundedRectangle(cornerRadius: 4)
//                            .fill(Color.pbAccentPurple)
//                            .frame(width: 0, height: 8)
//                    }
//                }
//                .frame(height: 8)
//
//                HStack(spacing: 6) {
//                    Image(systemName: "star")
//                        .foregroundColor(.pbAccentYellow)
//                        .font(.system(size: 12))
//                    Text("Next Milestone Reward: $0 Bonus")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(.pbAccentYellow)
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.bottom, 16)
//        }
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(pbColor("#21262D"), lineWidth: 1))
//    }
//
//    // MARK: - Milestone Section
//    var milestoneSection: some View {
//        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
//            MiniStatCard(icon: "arrow.clockwise", iconColor: .pbAccentBlue, title: "Volume Achieved", subtitle: "Your current volume", value: "$0", borderColor: .pbBorderBlue)
//            MiniStatCard(icon: "percent", iconColor: .pbAccentPurple, title: "Milestone Volume", subtitle: "Target to reach", value: "$0", borderColor: .pbBorderPurple)
//            MiniStatCard(icon: "gift.fill", iconColor: .pbAccentGreen, title: "Milestone Reward", subtitle: "Bonus on completion", value: "$0", borderColor: .pbBorderGreen)
//            MiniStatCard(icon: "checkmark.seal.fill", iconColor: .pbAccentOrange, title: "Bonus Rewarded", subtitle: "Total earned bonuses", value: "$0", borderColor: .pbBorderOrange)
//        }
//    }
//
//    // MARK: - Monthly Earnings Chart
//    var monthlyEarningsChart: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            HStack {
//                ZStack {
//                    Circle()
//                        .fill(pbColor("#1A2744"))
//                        .frame(width: 36, height: 36)
//                    Image(systemName: "chart.line.uptrend.xyaxis")
//                        .foregroundColor(.pbAccentBlue)
//                        .font(.system(size: 16))
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Monthly Referral Earnings")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    Text("Passive income trend")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                }
//                Spacer()
//                Text("0% YTD")
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(.pbAccentGreen)
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 5)
//                    .background(pbColor("#0D2B1D"))
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//            }
//
//            SimpleLineChart()
//                .frame(height: 140)
//        }
//        .padding(16)
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(pbColor("#21262D"), lineWidth: 1))
//    }
//
//    // MARK: - Referral Tools Section
//    var referralToolsSection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                ZStack {
//                    Circle()
//                        .fill(pbColor("#1A2744"))
//                        .frame(width: 36, height: 36)
//                    Image(systemName: "link")
//                        .foregroundColor(.pbAccentOrange)
//                        .font(.system(size: 16))
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Your Referral Tools")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    Text("Share and earn")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                }
//                Spacer()
//            }
//            .padding(16)
//
//            Divider().background(Color.pbBgCardAlt)
//
//            // Tab Toggle
//            HStack(spacing: 0) {
//                Button(action: {}) {
//                    Text("Link by Merchant ID")
//                        .font(.system(size: 13, weight: .medium))
//                        .foregroundColor(.pbTextSecondary)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 10)
//                }
//                Button(action: {}) {
//                    Text("Link by Referral Code")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 10)
//                        .background(Color.pbAccentPurple)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//            }
//            .padding(4)
//            .background(Color.pbBgCardAlt)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .padding(.horizontal, 16)
//            .padding(.top, 12)
//
//            // Referral Link
//            HStack {
//                Text("https://exchange.nexusfi...ignup?ref=JHO00034137")
//                    .font(.system(size: 13))
//                    .foregroundColor(.pbTextSecondary)
//                    .lineLimit(1)
//                    .truncationMode(.middle)
//                Spacer()
//                Button(action: {}) {
//                    Image(systemName: "doc.on.doc.fill")
//                        .foregroundColor(.white)
//                        .font(.system(size: 16))
//                        .frame(width: 40, height: 40)
//                        .background(Color.pbAccentPurple)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//            }
//            .padding(14)
//            .background(Color.pbBgCardAlt)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .padding(.horizontal, 16)
//            .padding(.top, 10)
//
//            // Referral Code
//            HStack {
//                VStack(alignment: .leading, spacing: 4) {
//                    Text("Referral Code")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                    Text("JHO00034137")
//                        .font(.system(size: 22, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                }
//                Spacer()
//                Button(action: {}) {
//                    Image(systemName: "qrcode")
//                        .foregroundColor(.white)
//                        .font(.system(size: 18))
//                        .frame(width: 44, height: 44)
//                        .background(Color.pbAccentPurple)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//                Button(action: {}) {
//                    Image(systemName: "doc.on.doc.fill")
//                        .foregroundColor(.pbTextSecondary)
//                        .font(.system(size: 18))
//                        .frame(width: 44, height: 44)
//                        .background(Color.pbBgCardAlt)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                }
//            }
//            .padding(14)
//            .background(Color.pbBgCardAlt)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .padding(.horizontal, 16)
//            .padding(.top, 10)
//
//            // Quick Invite
//            VStack(alignment: .leading, spacing: 8) {
//                Text("Quick Invite")
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(.pbTextPrimary)
//                Text("Press Enter or tap + to add an email to the list.")
//                    .font(.system(size: 12))
//                    .foregroundColor(.pbTextSecondary)
//
//                HStack {
//                    TextField("Enter business email", text: $emailInput)
//                        .font(.system(size: 14))
//                        .foregroundColor(.pbTextPrimary)
//                        .padding(.horizontal, 14)
//                        .frame(height: 48)
//                        .background(Color.pbBgCardAlt)
//                        .clipShape(RoundedRectangle(cornerRadius: 10))
//                    Button(action: {}) {
//                        Image(systemName: "plus")
//                            .foregroundColor(.white)
//                            .font(.system(size: 20, weight: .bold))
//                            .frame(width: 48, height: 48)
//                            .background(Color.pbAccentPurple)
//                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                    }
//                }
//            }
//            .padding(16)
//
//            // Earnings banner
//            HStack(spacing: 12) {
//                Text("🏆")
//                    .font(.system(size: 24))
//                VStack(alignment: .leading, spacing: 3) {
//                    Text("You earned $0.00 from referrals this month")
//                        .font(.system(size: 14, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    Text("Every merchant you bring earns you a recurring share of their processing fees — automatically.")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                }
//            }
//            .padding(14)
//            .background(Color.pbBgCardAlt)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//            .padding(.horizontal, 16)
//            .padding(.bottom, 16)
//        }
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(pbColor("#21262D"), lineWidth: 1))
//    }
//
//    // MARK: - Referred Merchants
//    var referredMerchantsSection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                ZStack {
//                    Circle()
//                        .fill(pbColor("#1A2744"))
//                        .frame(width: 36, height: 36)
//                    Image(systemName: "person.2.fill")
//                        .foregroundColor(.pbAccentGreen)
//                        .font(.system(size: 14))
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Referred Merchants")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    Text("Track your network growth")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                }
//                Spacer()
//                Text("0 merchants")
//                    .font(.system(size: 13, weight: .medium))
//                    .foregroundColor(.pbTextSecondary)
//                    .padding(.horizontal, 12)
//                    .padding(.vertical, 6)
//                    .background(Color.pbBgCardAlt)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//            }
//            .padding(16)
//
//            Divider().background(Color.pbBgCardAlt)
//
//            HStack(spacing: 16) {
//                StatusDot(color: .pbDotActive, label: "Active")
//                StatusDot(color: .pbDotPending, label: "Pending")
//                StatusDot(color: .pbDotInactive, label: "Inactive")
//                Spacer()
//            }
//            .padding(.horizontal, 16)
//            .padding(.top, 12)
//
//            VStack(spacing: 8) {
//                Image(systemName: "person.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(pbColor("#30363D"))
//                Image(systemName: "person.crop.rectangle")
//                    .font(.system(size: 20))
//                    .foregroundColor(pbColor("#30363D"))
//                Text("No referrals found")
//                    .font(.system(size: 14))
//                    .foregroundColor(.pbTextSecondary)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 30)
//        }
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(pbColor("#21262D"), lineWidth: 1))
//    }
//
//    // MARK: - Earning History
//    var earningHistorySection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(pbColor("#1A2744"))
//                        .frame(width: 36, height: 36)
//                    Image(systemName: "calendar")
//                        .foregroundColor(.pbAccentBlue)
//                        .font(.system(size: 16))
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Earning History")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.pbTextPrimary)
//                    Text("Monthly payout breakdown")
//                        .font(.system(size: 12))
//                        .foregroundColor(.pbTextSecondary)
//                }
//                Spacer()
//            }
//            .padding(16)
//
//            Divider().background(Color.pbBgCardAlt)
//
//            // Table Header
//            HStack {
//                Text("DATE").frame(maxWidth: .infinity, alignment: .leading)
//                Text("TRANS ID").frame(maxWidth: .infinity, alignment: .center)
//                Text("EARNING").frame(maxWidth: .infinity, alignment: .trailing)
//            }
//            .font(.system(size: 11, weight: .semibold))
//            .foregroundColor(.pbTextSecondary)
//            .padding(.horizontal, 16)
//            .padding(.vertical, 10)
//            .background(Color.pbBgCardAlt)
//
//            VStack(spacing: 8) {
//                Image(systemName: "arrow.clockwise")
//                    .font(.system(size: 36))
//                    .foregroundColor(pbColor("#30363D"))
//                Text("No earnings yet")
//                    .font(.system(size: 14))
//                    .foregroundColor(.pbTextSecondary)
//            }
//            .frame(maxWidth: .infinity)
//            .padding(.vertical, 30)
//
//            // Note
//            HStack(alignment: .top, spacing: 10) {
//                Image(systemName: "exclamationmark.circle.fill")
//                    .foregroundColor(.pbAccentBlue)
//                    .font(.system(size: 16))
//                Text("Note: Earnings become automatically withdrawable 30 days after the transaction date and are transferred to the Settlement Wallet.")
//                    .font(.system(size: 12))
//                    .foregroundColor(.pbTextSecondary)
//            }
//            .padding(14)
//            .background(Color.pbBgCardAlt)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .padding(.horizontal, 16)
//            .padding(.bottom, 16)
//        }
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(pbColor("#21262D"), lineWidth: 1))
//    }
//
//    // MARK: - How It Works
//    var howItWorksSection: some View {
//        VStack(spacing: 0) {
//            HStack {
//                ZStack {
//                    Circle()
//                        .fill(pbColor("#1A2744"))
//                        .frame(width: 36, height: 36)
//                    Image(systemName: "shield.fill")
//                        .foregroundColor(.pbAccentBlue)
//                        .font(.system(size: 16))
//                }
//                Text("How PayBito Earn Works")
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(.pbTextPrimary)
//                Spacer()
//            }
//            .padding(16)
//
//            Divider().background(Color.pbBgCardAlt)
//
//            HStack(alignment: .top, spacing: 0) {
//                HowItWorksStep(number: "01", title: "Share Your Link", description: "Share your unique referral link with businesses looking to accept crypto payments.")
//                HowItWorksStep(number: "02", title: "Merchant Activates", description: "When they sign up and process their first successful payment, they become an Active merchant.")
//                HowItWorksStep(number: "03", title: "Earn Income", description: "You earn a share of PayBito's processing fees — automatically, month by month.")
//            }
//            .padding(.horizontal, 8)
//            .padding(.vertical, 20)
//
//            Text("Build a sustainable stream of passive income. No limits on earnings or the number of merchants.")
//                .font(.system(size: 13))
//                .foregroundColor(.pbTextSecondary)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 16)
//                .padding(.bottom, 16)
//        }
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(pbColor("#21262D"), lineWidth: 1))
//    }
//}
//
//// MARK: - Subviews
//
//struct StatCard: View {
//    let icon: String
//    let iconColor: Color
//    let title: String
//    let value: String
//    let subtitle: String
//    let subtitleBg: Color
//    let subtitleColor: Color
//    let borderColor: Color
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack(spacing: 8) {
//                Image(systemName: icon)
//                    .foregroundColor(iconColor)
//                    .font(.system(size: 14))
//                Text(title)
//                    .font(.system(size: 10, weight: .semibold))
//                    .foregroundColor(.pbTextSecondary)
//                    .lineLimit(2)
//            }
//            Text(value)
//                .font(.system(size: 28, weight: .bold))
//                .foregroundColor(.pbTextPrimary)
//            Divider().background(pbColor("#21262D"))
//            Text(subtitle)
//                .font(.system(size: 11, weight: .medium))
//                .foregroundColor(subtitleColor)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//                .background(subtitleBg)
//                .clipShape(RoundedRectangle(cornerRadius: 6))
//        }
//        .padding(14)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor.opacity(0.6), lineWidth: 1.5))
//    }
//}
//
//struct EarningsCard: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            HStack(spacing: 8) {
//                Image(systemName: "gift.fill")
//                    .foregroundColor(.pbAccentPurple)
//                    .font(.system(size: 14))
//                Text("TOTAL EARNINGS")
//                    .font(.system(size: 10, weight: .semibold))
//                    .foregroundColor(.pbTextSecondary)
//            }
//            Text("$0.00")
//                .font(.system(size: 28, weight: .bold))
//                .foregroundColor(.pbTextPrimary)
//            Divider().background(pbColor("#21262D"))
//            VStack(alignment: .leading, spacing: 2) {
//                Text("$0.00 Commissions")
//                    .font(.system(size: 11))
//                    .foregroundColor(.pbTextSecondary)
//                Text("$0.00 Bonuses")
//                    .font(.system(size: 11))
//                    .foregroundColor(.pbTextSecondary)
//            }
//        }
//        .padding(14)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 16))
//        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.pbBorderPurple.opacity(0.6), lineWidth: 1.5))
//    }
//}
//
//struct MiniStatCard: View {
//    let icon: String
//    let iconColor: Color
//    let title: String
//    let subtitle: String
//    let value: String
//    let borderColor: Color
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 6) {
//            HStack(spacing: 6) {
//                Image(systemName: icon)
//                    .foregroundColor(iconColor)
//                    .font(.system(size: 12))
//                Text(title)
//                    .font(.system(size: 12, weight: .semibold))
//                    .foregroundColor(.pbTextPrimary)
//                    .lineLimit(2)
//            }
//            Text(subtitle)
//                .font(.system(size: 11))
//                .foregroundColor(.pbTextSecondary)
//            Text(value)
//                .font(.system(size: 22, weight: .bold))
//                .foregroundColor(iconColor)
//        }
//        .padding(14)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.pbBgCard)
//        .clipShape(RoundedRectangle(cornerRadius: 14))
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(borderColor.opacity(0.5), lineWidth: 1.5))
//    }
//}
//
//struct SimpleLineChart: View {
//    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
//    let values: [CGFloat] = [0, 0, 0, 0, 0, 0]
//
//    var body: some View {
//        GeometryReader { geo in
//            let w = geo.size.width
//            let h = geo.size.height
//            let topPad: CGFloat = 20
//            let bottomPad: CGFloat = 28
//            let chartH = h - topPad - bottomPad
//            let stepX = w / CGFloat(months.count - 1)
//            let baseY = topPad + chartH
//
//            ZStack(alignment: .bottomLeading) {
//                // Y-axis labels
//                VStack(alignment: .leading, spacing: 0) {
//                    ForEach([1.2, 1.0, 0.8, 0.6, 0.4, 0.2, 0.0], id: \.self) { v in
//                        Spacer()
//                        Text(String(format: "%.1f", v))
//                            .font(.system(size: 9))
//                            .foregroundColor(.pbTextSecondary)
//                    }
//                    Spacer()
//                }
//                .frame(width: 28, height: h - bottomPad)
//
//                // Grid lines
//                ForEach(0..<7) { i in
//                    let y = topPad + (chartH / 6) * CGFloat(i)
//                    Path { p in
//                        p.move(to: CGPoint(x: 32, y: y))
//                        p.addLine(to: CGPoint(x: w, y: y))
//                    }
//                    .stroke(pbColor("#21262D"), lineWidth: 0.5)
//                }
//
//                // Line
//                Path { p in
//                    for (i, _) in values.enumerated() {
//                        let x = 32 + stepX * CGFloat(i)
//                        let y = baseY
//                        if i == 0 { p.move(to: CGPoint(x: x, y: y)) }
//                        else { p.addLine(to: CGPoint(x: x, y: y)) }
//                    }
//                }
//                .stroke(Color.pbAccentBlue, lineWidth: 2)
//
//                // Dots
//                ForEach(0..<values.count, id: \.self) { i in
//                    let x = 32 + stepX * CGFloat(i)
//                    Circle()
//                        .fill(Color.pbAccentBlue)
//                        .frame(width: 8, height: 8)
//                        .position(x: x, y: baseY)
//                }
//
//                // X-axis labels
//                HStack(spacing: 0) {
//                    ForEach(months, id: \.self) { m in
//                        Text(m)
//                            .font(.system(size: 10))
//                            .foregroundColor(.pbTextSecondary)
//                            .frame(maxWidth: .infinity)
//                    }
//                }
//                .frame(width: w - 32)
//                .offset(x: 32)
//                .position(x: (w - 32) / 2 + 32, y: h - 10)
//            }
//        }
//    }
//}
//
//struct StatusDot: View {
//    let color: Color
//    let label: String
//
//    var body: some View {
//        HStack(spacing: 5) {
//            Circle()
//                .fill(color)
//                .frame(width: 8, height: 8)
//            Text(label)
//                .font(.system(size: 12))
//                .foregroundColor(.pbTextSecondary)
//        }
//    }
//}
//
//struct HowItWorksStep: View {
//    let number: String
//    let title: String
//    let description: String
//
//    var body: some View {
//        VStack(spacing: 10) {
//            ZStack {
//                Circle()
//                    .fill(Color.pbAccentPurple)
//                    .frame(width: 40, height: 40)
//                Text(number)
//                    .font(.system(size: 14, weight: .bold))
//                    .foregroundColor(.white)
//            }
//            Text(title)
//                .font(.system(size: 13, weight: .bold))
//                .foregroundColor(.pbTextPrimary)
//                .multilineTextAlignment(.center)
//            Text(description)
//                .font(.system(size: 11))
//                .foregroundColor(.pbTextSecondary)
//                .multilineTextAlignment(.center)
//                .fixedSize(horizontal: false, vertical: true)
//        }
//        .frame(maxWidth: .infinity)
//        .padding(.horizontal, 6)
//    }
//}
//
//// MARK: - Preview
//struct PayBitoEarnView_Previews: PreviewProvider {
//    static var previews: some View {
//        PayBitoEarnView()
//            .preferredColorScheme(.dark)
//    }
//}
