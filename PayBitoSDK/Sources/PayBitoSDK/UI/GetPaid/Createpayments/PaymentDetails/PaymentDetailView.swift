import SwiftUI
import SafariServices   // ← SFSafariViewController



// MARK: - Color Theme

private func pbHex(_ hex: String) -> Color {
    let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var v: UInt64 = 0
    Scanner(string: h).scanHexInt64(&v)
    let a, r, g, b: UInt64
    switch h.count {
    case 3:  (a,r,g,b) = (255,(v>>8)*17,(v>>4 & 0xF)*17,(v & 0xF)*17)
    case 6:  (a,r,g,b) = (255,v>>16,v>>8 & 0xFF,v & 0xFF)
    case 8:  (a,r,g,b) = (v>>24,v>>16 & 0xFF,v>>8 & 0xFF,v & 0xFF)
    default: (a,r,g,b) = (255,0,0,0)
    }
    return Color(.sRGB, red: Double(r)/255, green: Double(g)/255,
                 blue: Double(b)/255, opacity: Double(a)/255)
}

private extension Color {
    static let pbSurface       = pbHex("#161B22")
    static let pbCard          = pbHex("#1C2128")
    static let pbBorder        = pbHex("#2A3140")
    static let pbAccent        = pbHex("#6C5CE7")
    static let pbTextPrimary   = Color.white
    static let pbTextSecondary = pbHex("#8B949E")
    static let pbTextMuted     = pbHex("#6E7681")
    static let pbTag           = pbHex("#252D3A")
    static let pbTagBorder     = pbHex("#3A4553")
}

// MARK: - Main View

struct PaymentLinkDetailView: View {

    // MARK: - Inputs
    let pcn:        String
    let merchantId: Int
    @Binding var isPresented: Bool

    // MARK: - ViewModel
    @StateObject private var vm = ViewPaymentDetailViewModel()

    // MARK: - Local state
    @State private var copied: Bool = false

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {

                // Dim backdrop
                Color.black.opacity(0.55)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { isPresented = false }
                    }
                    .transition(.opacity)

                // Sheet
                VStack(spacing: 0) {
                    dragHandle

                    switch vm.state {
                    case .idle, .loading: loadingBody
                    case .success:
                        if let m = vm.displayModel { successBody(m) }
                    case .failure(let msg): errorBody(msg)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.pbSurface)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.pbBorder, lineWidth: 0.5)
                        .ignoresSafeArea(edges: .bottom)
                )
                .overlay(alignment: .bottom) {
                    if vm.state != .loading && vm.state != .idle { closeBtn }
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(response: 0.4, dampingFraction: 0.85), value: isPresented)

            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .onAppear {
            debugPrint("🔷 [PaymentLinkDetailView] onAppear — \(pcn) merchantId:\(merchantId)")
            vm.fetchDetail(pcn: pcn, merchantId: merchantId)
        }
        .onChange(of: isPresented) { val in
            if !val {
                debugPrint("🔷 [PaymentLinkDetailView] dismissed — reset")
                vm.reset()
                copied = false
            }
        }
    }

    // MARK: - Drag Handle

    private var dragHandle: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.pbTextMuted)
            .frame(width: 40, height: 5)
            .padding(.top, 12)
            .padding(.bottom, 16)
    }

    // MARK: - Loading

    private var loadingBody: some View {
        VStack(spacing: 18) {
            Spacer().frame(height: 50)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.pbAccent))
                .scaleEffect(1.4)
            Text("Loading payment details…")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.pbTextSecondary)
            Spacer().frame(height: 120)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    // MARK: - Error

    private func errorBody(_ message: String) -> some View {
        VStack(spacing: 14) {
            Spacer().frame(height: 36)
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 36))
                .foregroundColor(.red.opacity(0.85))
            Text("Failed to Load")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.pbTextPrimary)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(.pbTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button {
                vm.fetchDetail(pcn: pcn, merchantId: merchantId)
            } label: {
                Text("Retry")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 12)
                    .background(Color.pbAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer().frame(height: 120)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }

    // MARK: - Success

    private func successBody(_ m: PaymentDetailDisplayModel) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                sectionHeader(m)
                sectionPaymentLink(m)
                sectionProducts(m)
                sectionPaymentOption(m)
                sectionFeeHandling(m)
                sectionBuyerInfo(m)
                sectionShipping(m)
                sectionDiscount(m)
                sectionRedirects(m)
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Header

    private func sectionHeader(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(m.paymentId)
                .font(.system(size: 21, weight: .bold, design: .monospaced))
                .foregroundColor(.pbTextPrimary)
            HStack(spacing: 6) {
                Text(m.pcn)
                    .font(.system(size: 13, weight: .medium, design: .monospaced))
                    .foregroundColor(.pbTextSecondary)
                Circle().fill(Color.pbTextMuted).frame(width: 3, height: 3)
                Text(m.date)
                    .font(.system(size: 13))
                    .foregroundColor(.pbTextSecondary)
            }
        }
    }

    // MARK: - Payment Link
    // "Open" → SFSafariViewController (in-app, matches web behaviour)
    // "Copy" → clipboard

    private func sectionPaymentLink(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("PAYMENT LINK")

            VStack(spacing: 0) {
                // URL text
                Text(m.paymentLink)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.pbTextSecondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)
                    .padding(.bottom, 10)

                Divider().background(Color.pbBorder)

                HStack(spacing: 0) {

                    // ── OPEN button → System Browser
                    Button {
                        let encodedLink = m.paymentLink.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? m.paymentLink
                        guard let url = URL(string: encodedLink) else {
                            debugPrint("❌ [PaymentLinkDetailView] Invalid URL: \(m.paymentLink)")
                            return
                        }
                        debugPrint("🔷 [PaymentLinkDetailView] Open tapped — \(url.absoluteString)")
                        UIApplication.shared.open(url)
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 13))
                            Text("Open")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.pbTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                    }

                    Divider().background(Color.pbBorder).frame(height: 40)

                    // ── COPY button → clipboard
                    Button {
                        UIPasteboard.general.string = m.paymentLink
                        debugPrint("🔷 [PaymentLinkDetailView] Copied: \(m.paymentLink)")
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { copied = false }
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 13))
                            Text(copied ? "Copied!" : "Copy")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(copied ? .green : .pbTextPrimary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .animation(.easeInOut(duration: 0.2), value: copied)
                    }
                }
            }
            .card()
        }
    }

    // MARK: - Products

    private func sectionProducts(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("PRODUCTS")
            if m.hasProduct {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().fill(Color.pbTag).frame(width: 46, height: 46)
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.pbTextMuted)
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(m.productName ?? "—")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.pbTextPrimary)
                        HStack(spacing: 5) {
                            Text(m.productAmountFormatted ?? "—")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.pbTextPrimary)
                            if m.isSubscription {
                                Image(systemName: "arrow.2.circlepath")
                                    .font(.system(size: 9))
                                    .foregroundColor(.pbAccent)
                            }
                        }
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(Color.pbTag).clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.pbTagBorder, lineWidth: 0.8))

                        if let iv = m.subscriptionInterval {
                            Text(iv).font(.system(size: 11)).foregroundColor(.pbTextMuted)
                        }
                    }
                    Spacer()
                }
                .padding(14)
                .card()
            } else {
                emptyProfile("products")
            }
        }
    }

    // MARK: - Payment Option

    private func sectionPaymentOption(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("PAYMENT OPTION")
            if m.hasBilling {
                VStack(spacing: 0) {
                    row("Profile", m.billingProfileName ?? "—")
                    sep()
                    row("Type", m.billingType?.capitalized ?? "—")
                    if !m.paymentMethods.isEmpty {
                        sep()
                        chipSection("Methods", chips: m.paymentMethods)
                    }
                    if !m.paymentCurrencies.isEmpty {
                        sep()
                        chipSection("Currencies", chips: m.paymentCurrencies)
                    }
                }
                .card()
            } else {
                emptyProfile("payment option")
            }
        }
    }

    // MARK: - Fee Handling

    private func sectionFeeHandling(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("FEE HANDLING")
            row("Handling", m.feeHandling).card()
        }
    }

    // MARK: - Buyer Info

    private func sectionBuyerInfo(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("BUYER INFO")
            if m.hasBuyer {
                VStack(spacing: 0) {
                    row("Profile", m.buyerProfileName ?? "—")
                    if !m.collectedFields.isEmpty {
                        sep()
                        chipSection("Collects", chips: m.collectedFields)
                    }
                }
                .card()
            } else {
                emptyProfile("buyer info")
            }
        }
    }

    // MARK: - Shipping

    private func sectionShipping(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("SHIPPING")
            if m.hasShipping {
                VStack(spacing: 0) {
                    row("Profile", m.shippingProfileName ?? "—")
                    if let handling = m.shippingHandlingFee {
                        sep()
                        row("Handling Fee", "\(handling)")
                    }
                    if let tax = m.shippingTaxRate {
                        sep()
                        row("Tax Rate", "\(tax)")
                    }
                }
                .card()
            } else {
                emptyProfile("shipping")
            }
        }
    }

    // MARK: - Discount

    private func sectionDiscount(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("DISCOUNT")
            if m.hasDiscount {
                VStack(spacing: 0) {
                    row("Profile", m.discountProfileName ?? "—")
                    if let pct = m.discountPercentage {
                        sep()
                        row("Discount", "\(pct)%")
                    }
                    if let minVal = m.discountMinCartValue {
                        sep()
                        row("Min. Cart Value", "\(minVal)")
                    }
                }
                .card()
            } else {
                emptyProfile("discount")
            }
        }
    }

    // MARK: - Redirects

    private func sectionRedirects(_ m: PaymentDetailDisplayModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            label("REDIRECTS")
            if m.hasRedirect {
                VStack(spacing: 0) {
                    row("Template",    m.redirectTemplateName ?? "—")
                    sep()
                    row("Success URL", m.successURL ?? "—")
                    sep()
                    row("Failure URL", m.failureURL ?? "—")
                }
                .card()
            } else {
                emptyProfile("redirects")
            }
        }
    }

    // MARK: - Close Button

    private var closeBtn: some View {
        Button {
            debugPrint("🔷 [PaymentLinkDetailView] close")
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { isPresented = false }
        } label: {
            Text("CLOSE")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(Color.pbAccent)
                .clipShape(RoundedRectangle(cornerRadius: 13))
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 34)
        .background(
            LinearGradient(
                colors: [Color.pbSurface.opacity(0), Color.pbSurface],
                startPoint: .top, endPoint: .bottom
            ).frame(height: 100)
        )
    }

    // MARK: - Reusable UI helpers

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.pbTextMuted)
            .tracking(1.4)
    }

    private func emptyProfile(_ label: String) -> some View {
        Text("No \(label) selected")
            .font(.system(size: 13))
            .foregroundColor(.pbTextMuted)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
    }

    private func row(_ key: String, _ value: String) -> some View {
        HStack {
            Text(key)
                .font(.system(size: 14))
                .foregroundColor(.pbTextSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.pbTextPrimary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
    }

    private func sep() -> some View {
        Divider().background(Color.pbBorder).padding(.horizontal, 14)
    }

    private func chipSection(_ title: String, chips: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.pbTextSecondary)
            FlowLayout(spacing: 8) {
                ForEach(chips, id: \.self) { chip(for: $0) }
            }
        }
        .padding(14)
    }

    private func chip(for text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.pbTextPrimary)
            .padding(.horizontal, 11).padding(.vertical, 5)
            .background(Color.pbTag)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.pbTagBorder, lineWidth: 0.8))
    }
}

// MARK: - Card modifier

private extension View {
    func card() -> some View {
        self
            .background(Color.pbCard)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.pbBorder, lineWidth: 0.8))
    }
}

// MARK: - Corner radius (top only)

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(PBRoundedCorner(radius: radius, corners: corners))
    }
}

private struct PBRoundedCorner: Shape {
    var radius: CGFloat; var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: .init(width: radius, height: radius)).cgPath)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        layout(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews).size
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let r = layout(in: bounds.width, subviews: subviews)
        for (i, f) in r.frames.enumerated() {
            subviews[i].place(at: .init(x: bounds.minX + f.minX, y: bounds.minY + f.minY), proposal: .unspecified)
        }
    }
    private func layout(in maxW: CGFloat, subviews: Subviews) -> (frames: [CGRect], size: CGSize) {
        var frames: [CGRect] = []
        var x: CGFloat = 0, y: CGFloat = 0, h: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > maxW, x > 0 { y += h + spacing; x = 0; h = 0 }
            frames.append(.init(x: x, y: y, width: sz.width, height: sz.height))
            x += sz.width + spacing; h = max(h, sz.height)
        }
        return (frames, .init(width: maxW, height: y + h))
    }
}

// MARK: - Preview

#if DEBUG
struct PaymentLinkDetailView_Previews: PreviewProvider {
    @State static var show = true
    static var previews: some View {
        ZStack {
            Color(red: 0.07, green: 0.09, blue: 0.13).ignoresSafeArea()
            PaymentLinkDetailView(pcn: "PCN2942", merchantId: 21758, isPresented: $show)
        }
        .preferredColorScheme(.dark)
    }
}
#endif




























