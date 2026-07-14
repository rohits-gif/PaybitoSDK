import SwiftUI

struct ConfigurationSheet: View {

    @Environment(\.dismiss) private var dismiss

    @State private var showCheckoutExpanded = false
    @State private var showLimits = false
    @State private var showPaymentTolerance = false

    // checkout destinations
    @State private var showBuyerInfo = false
    @State private var showDiscounts = false
    @State private var showFeeHandling = false
    @State private var showPaymentOptions = false
    @State private var showRedirects = false
    @State private var showRewards = false
    @State private var showShipping = false
    @State private var showPaymentsSetup = false

    var body: some View {
        if #available(iOS 16.4, *) {
            sheetContent
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackground(Color(red: 0.10, green: 0.12, blue: 0.19))
            

                .fullScreenCover(isPresented: $showLimits) {
                    LimitsView()
                }

                .fullScreenCover(isPresented: $showPaymentTolerance) {
                    PaymentToleranceView()
                }

                .fullScreenCover(isPresented: $showBuyerInfo) {
                    BuyerInfoView()
                }

                .fullScreenCover(isPresented: $showDiscounts) {
                    DiscountsView()
                }

                .fullScreenCover(isPresented: $showFeeHandling) {
                    FeeHandlingView()
                }

                .fullScreenCover(isPresented: $showPaymentOptions) {
                    PaymentOptionsView()
                }

                .fullScreenCover(isPresented: $showRedirects) {
                    RedirectsView()
                }

                .fullScreenCover(isPresented: $showRewards) {
                    RewardCampaignsView()
                }
                .fullScreenCover(isPresented: $showShipping) {
                    ShippingView()
                }
                .fullScreenCover(isPresented: $showPaymentsSetup) {
                    PaymentSettingsView()
                }

        } else {
            sheetContent
        }
    }
    private struct CheckoutTemplateRow: View {
        let title: String
        let action: () -> Void

        var body: some View {
            Button(action: action) {
                HStack {
                    Text(title)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.70))
                        .padding(.leading, 72)

                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.trailing, 20)
                }
                .padding(.vertical, 13)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 0.5)
                .padding(.leading, 72)
        }
    }

    private var sheetContent: some View {
        ZStack {
            Color(red: 0.10, green: 0.12, blue: 0.19)
                .ignoresSafeArea()

            VStack(spacing: 0) {

//                Capsule()
//                    .fill(Color.white.opacity(0.22))
//                    .frame(width: 40, height: 4)
//                    .padding(.top, 24)
//                    .padding(.bottom, 20)

                HStack {
                    Text("Configuration")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
//                .padding(.top, 24)

                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 0.5)
                    .padding(.horizontal, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        // Payment Setup
                        ConfigRow(
                            icon: "creditcard.fill",
                            iconBG: Color(red: 0.22, green: 0.26, blue: 0.55),
                            title: "Payment Setup",
                            style: .arrow
                        ) {
                            showPaymentsSetup = true
                        }

                        rowDivider

                        // Checkout Templates
                        ConfigRow(
                            icon: "doc.fill",
                            iconBG: Color(red: 0.22, green: 0.26, blue: 0.55),
                            title: "Checkout Templates",
                            style: showCheckoutExpanded ? .chevronUp : .chevronDown
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showCheckoutExpanded.toggle()
                            }
                        }
                        

                        if showCheckoutExpanded {
                            VStack(spacing: 0) {
                                CheckoutTemplateRow(title: "Payment Options") {
                                    showPaymentOptions = true
                                }
                                CheckoutTemplateRow(title: "Fee Handling") {
                                    showFeeHandling = true
                                }
                                CheckoutTemplateRow(title: "Buyer Info") {
                                    showBuyerInfo = true
                                }
                                CheckoutTemplateRow(title: "Shipping") {
                                    showShipping = true
                                }

                                CheckoutTemplateRow(title: "Discounts") {
                                    showDiscounts = true
                                }
                                CheckoutTemplateRow(title: "Redirects") {
                                    showRedirects = true
                                }

                                CheckoutTemplateRow(title: "Rewards") {
                                    showRewards = true
                                }
                              
                            }
                            .background(Color(red: 0.08, green: 0.10, blue: 0.16))
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        rowDivider

                        ConfigRow(
                            icon: "gauge.medium",
                            iconBG: Color(red: 0.22, green: 0.26, blue: 0.55),
                            title: "Limits",
                            style: .arrow
                        ) {
                            showLimits = true
                        }

                        rowDivider

                        ConfigRow(
                            icon: "clock.badge.checkmark.fill",
                            iconBG: Color(red: 0.22, green: 0.26, blue: 0.55),
                            title: "Payment Tolerance",
                            style: .arrow
                        ) {
                            showPaymentTolerance = true
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 34)
                }
            }
        }
    }

    private var rowDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.07))
            .frame(height: 0.5)
            .padding(.leading, 72)
    }
    
}

// MARK: - Row style

private enum ConfigRowStyle {
    case arrow
    case chevronDown
    case chevronUp
}

private struct ConfigRow: View {
    let icon: String
    let iconBG: Color
    let title: String
    let style: ConfigRowStyle
    let action: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(iconBG)
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                }

                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                switch style {
                case .arrow:
                    Image(systemName: "chevron.right")

                case .chevronDown:
                    Image(systemName: "chevron.down")

                case .chevronUp:
                    Image(systemName: "chevron.up")
                }
//                .font(.system(size: 13, weight: .medium))
//                .foregroundColor(.white.opacity(0.35))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(pressed ? Color.white.opacity(0.05) : Color.clear)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded { _ in pressed = false }
        )
    }
}
