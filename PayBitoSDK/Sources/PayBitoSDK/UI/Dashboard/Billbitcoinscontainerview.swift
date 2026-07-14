//import SwiftUI
//import SDWebImageSwiftUI
//
//// MARK: - Tab Model
//
//struct BBTabItem: Identifiable {
//    let id: Int
//    let icon: String
//    let title: String
//}
//
//private let bbTabItems: [BBTabItem] = [
//    BBTabItem(id: 0, icon: "rectangle.grid.2x2.fill", title: "Dashboard"),
//    BBTabItem(id: 1, icon: "pencil.tip.crop.circle.fill", title: "Get Paid"),
//    BBTabItem(id: 2, icon: "list.bullet.rectangle", title: "Transactions"),
//    BBTabItem(id: 3, icon: "wallet.pass.fill", title: "Wallets"),
//    @State private var showProfileMenu = false
//    @State private var showDevelopers = false
//    @Environment(\.dismiss) private var dismiss
//    @StateObject private var profileVM = ProfileViewModel()
//
//    var body: some View {
//        NavigationStack {
//            VStack(spacing: 0) {
//                BBNavBar(
//                    onToggle: { dismiss() },
//                    onProfile: { showProfileMenu = true },
//                    onDeveloper: { showDevelopers = true },
//                    profileImage: profileVM.profileImage
//                )
//                
//                tabContent
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                
//                BBTabBar(items: bbTabItems, selectedTab: $selectedTab,
//                         onGetPaidTap: {showGetPaid = true
//                    
//                })
//            }
//            .background(Color.bbDarkBG.ignoresSafeArea())
//            .preferredColorScheme(.dark)
//            .onAppear {
//                profileVM.fetchProfile()
//            }
//            .sheet(isPresented: $showProfileMenu) {
//                ProfileMenuSheet(onLogout: logoutAndDismiss)
//            }
//            .sheet(isPresented: $showDevelopers) {
//                DevelopersSheet()
//            }
//            .sheet(isPresented: $showGetPaid) {
//
//                          GetPaidSheet(
//
//                              onCreatePayment: {
//
//                                  goCreatePayment = true
//
//                              },
//
//                              onPaymentLinks: {
//
//                                  goPaymentLinks = true
//
//                              },
//
//                              onProducts: {
//
//                                  goProducts = true
//
//                              }
//
//                          )
//
//                          .presentationDetents([.height(360)])
//
//                          .presentationDragIndicator(.hidden)
//
//                      }
//
//                      .navigationDestination(isPresented: $goCreatePayment) {
//
//                          CreatePaymentView()
//
//                      }
//
//                      .navigationDestination(isPresented: $goPaymentLinks) {
//
//                          ViewPaymentLinksView()
//
//                      }
//
//                      .navigationDestination(isPresented: $goProducts) {
//
//                          CreateProductView()
//
//                      }
//        }
//    }
//
//    @ViewBuilder
//    private var tabContent: some View {
//        switch selectedTab {
//        case 0:
//            BillBitcoinsDashboardView()
//
//        case 1:
//            BBPlaceholderView(title: "Get Paid")
//
//        case 2:
//            let merchantId = Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0
//            TransactionsView(merchantId: merchantId)
//
//        case 3:
////            WalletsView()
//            WalletDashboardView()
//
//        default:
//            AnalyticsTabView()
//        }
//    }
//
//    private func logoutAndDismiss() {
//        LoginService.clearSession()
//
//        if let onLogout = onLogout {
//            onLogout()
//        } else {
//            dismiss()
//        }
//    }
//}
//
//// MARK: - Nav Bar
//
//struct BBNavBar: View {
//    let onToggle: () -> Void
//    let onProfile: () -> Void
//    let onDeveloper: () -> Void
//    let profileImage: UIImage?
//
//    @State private var brokerLogoImage: UIImage? = nil
//
//    private let navBG = Color(red: 0.18, green: 0.30, blue: 0.85)
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            navBG.ignoresSafeArea(edges: .top)
//
//            HStack(spacing: 0) {
//
//                // Broker logo
//                Group {
//                    if let img = brokerLogoImage {
//                        Image(uiImage: img)
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 36, height: 36)
//                            .clipShape(Circle())
//                    } else {
//                        Circle()
//                            .fill(Color.white.opacity(0.25))
//                            .frame(width: 36, height: 36)
//                    }
//                }
//
//                // Toggle buttons
////                HStack(spacing: 0) {
////                    Image(systemName: "creditcard.fill")
////                        .resizable()
////                        .scaledToFit()
////                        .frame(width: 18, height: 18)
////                        .foregroundColor(.white)
////
////                    Rectangle()
////                        .fill(Color.white.opacity(0.3))
////                        .frame(width: 1, height: 20)
////                        .padding(.horizontal, 8)
////
////                    Image(systemName: "rectangle.grid.2x2.fill")
////                        .resizable()
////                        .scaledToFit()
////                        .frame(width: 18, height: 18)
////                        .foregroundColor(.white.opacity(0.6))
////                }
////                .padding(.horizontal, 10)
////                .frame(height: 36)
////                .background(Color.white.opacity(0.20))
////                .clipShape(Capsule())
////                .padding(.leading, 10)
////                .onTapGesture {
////                    onToggle()
////                }
//
//                Spacer()
//
////                Text("Brand Wallet")
////                    .font(.system(size: 13, weight: .semibold))
////                    .foregroundColor(.white)
////                    .padding(.horizontal, 14)
////                    .padding(.vertical, 6)
////                    .background(Color.white.opacity(0.15))
////                    .clipShape(Capsule())
////                    .overlay(
////                        Capsule().stroke(Color.bbAccentGreen, lineWidth: 1)
////                    )
//
//                Button(action: onDeveloper) {
//                    Image(systemName: "chevron.left.forwardslash.chevron.right")
//                        .frame(width: 32, height: 32)
//                        .foregroundColor(.white)
//                }
//                .padding(.leading, 8)
//
//                // Dynamic profile avatar
//                Button(action: onProfile) {
//                    if let img = profileImage {
//                        Image(uiImage: img)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 34, height: 34)
//                            .clipShape(Circle())
//                    } else {
//                        Image(systemName: "person.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 34, height: 34)
//                            .foregroundColor(.white)
//                    }
//                }
//                .padding(.leading, 8)
//            }
//            .padding(.horizontal, 14)
//            .padding(.bottom, 12)
//        }
//        .frame(height: 64)
//        .onAppear {
//            print("✅ BBNavBar appeared")
//            fetchBrokerLogo()
//        }
//    }
//
//    private func fetchBrokerLogo() {
//        let brokerId = UserDefaults.standard.string(forKey: "brokerId") ?? "PAYB18022021121103"
//        let urlString = "https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo?brokerId=\(brokerId)"
//
//        print("🌐 Fetching broker logo from:", urlString)
//
//        guard let url = URL(string: urlString) else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
//        request.setValue("https://trade.paybito.com", forHTTPHeaderField: "Origin")
//        request.setValue("https://trade.paybito.com/", forHTTPHeaderField: "Referer")
//
//        URLSession.shared.dataTask(with: request) { data, _, error in
//
//            if let error {
//                print("❌ API error:", error)
//                return
//            }
//
//            guard let data else {
//                print("❌ No data received")
//                return
//            }
//
//            if let raw = String(data: data, encoding: .utf8) {
//                print("📦 RAW RESPONSE:", raw)
//            }
//
//            guard
//                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
//                let valueArray = json["value"] as? [[String: Any]],
//                let first = valueArray.first
//            else {
//                print("❌ Failed to parse JSON")
//                return
//            }
//
//            guard
//                let logoURLString = first["exchange_logo"] as? String,
//                !logoURLString.isEmpty,
//                let logoURL = URL(string: logoURLString)
//            else {
//                print("⚠️ No logo from API, using fallback")
//
//                DispatchQueue.main.async {
//                    brokerLogoImage = UIImage(systemName: "person.circle.fill")
//                }
//                return
//            }
//
//            print("🏢 Downloading logo:", logoURLString)
//
//            URLSession.shared.dataTask(with: logoURL) { imgData, _, imgError in
//                if let imgError {
//                    print("❌ Image download error:", imgError)
//                    return
//                }
//
//                guard let imgData, let img = UIImage(data: imgData) else {
//                    print("❌ Failed to create UIImage")
//                    return
//                }
//
//                print("✅ Broker logo loaded")
//
//                DispatchQueue.main.async {
//                    brokerLogoImage = img
//                }
//
//            }.resume()
//
//        }.resume()
//    }
//}
//
//// MARK: - Tab Bar
//
//struct BBTabBar: View {
//    let items: [BBTabItem]
//    @Binding var selectedTab: Int
//    let onGetPaidTap: () -> Void
//
//    private let tabInactive = Color.white.opacity(0.40)
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Rectangle()
//                .fill(Color.bbBorder)
//                .frame(height: 0.5)
//
//            HStack(spacing: 0) {
//                ForEach(items) { item in
//                    Button {
//                        if item.id == 1 {
//                            onGetPaidTap()
//                        } else {
//                            selectedTab = item.id
//                        }
//                    } label: {
//                        VStack(spacing: 3) {
//                            Image(systemName: item.icon)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 22, height: 22)
//                                .foregroundColor(
//                                    selectedTab == item.id
//                                    ? .bbAccentBlue
//                                    : tabInactive
//                                )
//
//                            Text(item.title)
//                                .font(
//                                    .system(
//                                        size: 10,
//                                        weight: selectedTab == item.id
//                                            ? .bold
//                                            : .medium
//                                    )
//                                )
//                                .foregroundColor(
//                                    selectedTab == item.id
//                                    ? .bbAccentBlue
//                                    : tabInactive
//                                )
//                        }
//                        .frame(maxWidth: .infinity)
//                        .padding(.top, 8)
//                    }
//                    .buttonStyle(.plain)
//                }
//            }
//            .padding(.bottom, 8)
//        }
//        .background(Color.bbCardBG)
//        .frame(height: 83)
//    }
//}
//
//// MARK: - Placeholder
//
//struct BBPlaceholderView: View {
//    let title: String
//
//    var body: some View {
//        ZStack {
//            Color.bbDarkBG.ignoresSafeArea()
//
//            Text(title)
//                .font(.system(size: 22, weight: .bold))
//                .foregroundColor(.white)
//        }
//    }
//}
//
//#Preview {
//    BillBitcoinsContainerView()
//}












import SwiftUI
import SDWebImageSwiftUI

// MARK: - Tab Model

struct BBTabItem: Identifiable {
    let id: Int
    let icon: String
    let title: String
}

private let bbMainTabItems: [BBTabItem] = [
    BBTabItem(id: 0, icon: "rectangle.grid.2x2.fill",       title: "Dashboard"),
    BBTabItem(id: 1, icon: "pencil.tip.crop.circle.fill",   title: "Get Paid"),
    BBTabItem(id: 2, icon: "list.bullet.rectangle",         title: "Transactions"),
    BBTabItem(id: 3, icon: "wallet.pass.fill",              title: "Wallets"),
    BBTabItem(id: 4, icon: "chart.bar.fill",                title: "Analytics"),
]

private let bbOnboardingTabItems: [BBTabItem] = [
    BBTabItem(id: 99, icon: "checkmark.seal.fill", title: "Get Started"),
]

// MARK: - Container View

public struct BillBitcoinsContainerView: View {
    public init() {}
    var onLogout: (() -> Void)? = nil

    @State private var businessActivated: Bool = false
    @State private var showGetPaid = false
    @State private var goCreatePayment = false
    @State private var goPaymentLinks = false
    @State private var goProducts = false
    @State private var selectedTab = 0
    @State private var showProfileMenu = false
    @State private var showDevelopers = false

    @Environment(\.dismiss) private var dismiss
    @StateObject private var profileVM = ProfileViewModel()

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                BBNavBar(
                    onToggle: { dismiss() },
                    onProfile: { showProfileMenu = true },
                    onDeveloper: { showDevelopers = true },
                    profileImage: profileVM.profileImage
                )

                tabContent
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                if businessActivated {
                    BBTabBar(
                        items: bbMainTabItems,
                        selectedTab: $selectedTab,
                        onGetPaidTap: { showGetPaid = true }
                    )
                } else {
                    BBTabBar(
                        items: bbOnboardingTabItems,
                        selectedTab: .constant(99),
                        onGetPaidTap: {}
                    )
                }
            }
            .background(Color.bbDarkBG.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .onAppear {
                profileVM.fetchProfile()
                refreshActivationState()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("businessActivationComplete"))) { _ in
                withAnimation(.easeInOut(duration: 0.35)) {
                    businessActivated = true
                    selectedTab = 0
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("refreshGetStarted"))) { _ in
                refreshActivationState()
            }
            .sheet(isPresented: $showProfileMenu) {
                ProfileMenuSheet(onLogout: logoutAndDismiss)
            }
            .sheet(isPresented: $showDevelopers) {
                DevelopersSheet()
            }
            .sheet(isPresented: $showGetPaid) {
                GetPaidSheet(
                    onCreatePayment: { goCreatePayment = true },
                    onPaymentLinks:  { goPaymentLinks  = true },
                    onProducts:      { goProducts      = true }
                )
                .presentationDetents([.height(360)])
                .presentationDragIndicator(.hidden)
            }
            .navigationDestination(isPresented: $goCreatePayment) { CreatePaymentView() }
            .navigationDestination(isPresented: $goPaymentLinks)  { ViewPaymentLinksView() }
            .navigationDestination(isPresented: $goProducts)      { CreateProductView() }
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        if !businessActivated {
            GetStartedView(cameFromDashboard: true)
        } else {
            switch selectedTab {
            case 0:
                BillBitcoinsDashboardView()
            case 1:
                BBPlaceholderView(title: "Get Paid")
            case 2:
                let merchantId = Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0
                TransactionsView(merchantId: merchantId)
            case 3:
                WalletDashboardView()
            default:
                AnalyticsTabView()
            }
        }
    }

    // MARK: - Helpers

    private func refreshActivationState() {
        let activated = UserDefaults.standard.integer(forKey: "Bbasic_verification_submitted") == 1
        if activated && !businessActivated {
            withAnimation(.easeInOut(duration: 0.35)) {
                businessActivated = true
                selectedTab = 0
            }
        } else if !activated {
            businessActivated = false
        }
    }

//    private func logoutAndDismiss() {
//        LoginService.clearSession()
//        if let onLogout = onLogout {
//            onLogout()
//        } else {
//            dismiss()
//        }
//    }
    private func logoutAndDismiss() {
        print("🚪 LOGOUT START")

        LoginService.clearSession()

        NotificationCenter.default.post(
            name: NSNotification.Name("userDidLogout"),
            object: nil
        )
    }
}

// MARK: - Nav Bar

struct BBNavBar: View {
    let onToggle: () -> Void
    let onProfile: () -> Void
    let onDeveloper: () -> Void
    let profileImage: UIImage?

    @State private var brokerLogoImage: UIImage? = nil

    private let navBG = Color(red: 0.18, green: 0.30, blue: 0.85)

    var body: some View {
        ZStack(alignment: .bottom) {
            navBG.ignoresSafeArea(edges: .top)

            HStack(spacing: 0) {
                Group {
                    if let img = brokerLogoImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 36, height: 36)
                    }
                }

                Spacer()

                Button(action: onDeveloper) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .frame(width: 32, height: 32)
                        .foregroundColor(.white)
                }
                .padding(.leading, 8)

                Button(action: onProfile) {
                    if let img = profileImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 34, height: 34)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 34, height: 34)
                            .foregroundColor(.white)
                    }
                }
                .padding(.leading, 8)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .frame(height: 64)
        .onAppear {
            fetchBrokerLogo()
        }
    }

    private func fetchBrokerLogo() {
        let brokerId = UserDefaults.standard.string(forKey: "brokerId") ?? "PAYB18022021121103"
        let urlString = "https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo?brokerId=\(brokerId)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json",           forHTTPHeaderField: "Content-Type")
        request.setValue("application/json, text/plain, */*", forHTTPHeaderField: "Accept")
        request.setValue("https://trade.paybito.com",  forHTTPHeaderField: "Origin")
        request.setValue("https://trade.paybito.com/", forHTTPHeaderField: "Referer")

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data, error == nil,
                  let json       = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let valueArray = json["value"] as? [[String: Any]],
                  let first      = valueArray.first,
                  let logoStr    = first["exchange_logo"] as? String, !logoStr.isEmpty,
                  let logoURL    = URL(string: logoStr)
            else {
                DispatchQueue.main.async {
                    brokerLogoImage = UIImage(systemName: "person.circle.fill")
                }
                return
            }

            URLSession.shared.dataTask(with: logoURL) { imgData, _, _ in
                guard let imgData, let img = UIImage(data: imgData) else { return }
                DispatchQueue.main.async { brokerLogoImage = img }
            }.resume()
        }.resume()
    }
}

// MARK: - Tab Bar

struct BBTabBar: View {
    let items: [BBTabItem]
    @Binding var selectedTab: Int
    let onGetPaidTap: () -> Void

    private let tabInactive = Color.white.opacity(0.40)

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Color.bbBorder)
                .frame(height: 0.5)

            HStack(spacing: 0) {
                ForEach(items) { item in
                    Button {
                        if item.id == 1 {
                            onGetPaidTap()
                        } else {
                            selectedTab = item.id
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Image(systemName: item.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(selectedTab == item.id ? .bbAccentBlue : tabInactive)

                            Text(item.title)
                                .font(.system(size: 10,
                                              weight: selectedTab == item.id ? .bold : .medium))
                                .foregroundColor(selectedTab == item.id ? .bbAccentBlue : tabInactive)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 8)
        }
        .background(Color.bbCardBG)
        .frame(height: 83)
    }
}

// MARK: - Placeholder

struct BBPlaceholderView: View {
    let title: String

    var body: some View {
        ZStack {
            Color.bbDarkBG.ignoresSafeArea()
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    BillBitcoinsContainerView()
}
