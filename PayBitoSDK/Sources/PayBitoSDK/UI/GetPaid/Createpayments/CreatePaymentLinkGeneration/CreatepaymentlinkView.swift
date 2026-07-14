
//
//  CreatepaymentlinkView.swift
//  Trading_Terminal
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins   // CIQRCodeGenerator

// MARK: - QR Code Generator (CoreImage — crisp, no blur)

private struct QRCodeImage: View {
    let content: String

    private var uiImage: UIImage? {
        let context = CIContext()
        let filter  = CIFilter.qrCodeGenerator()
        filter.message       = Data(content.utf8)
        filter.correctionLevel = "H"                 // highest error-correction = more modules → denser

        guard let ciImage = filter.outputImage else { return nil }

        // Scale up 12× so pixels are sharp at any display size
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    var body: some View {
        if let img = uiImage {
            Image(uiImage: img)
                .interpolation(.none)          // ← keeps pixels crisp, no bilinear blur
                .resizable()
                .scaledToFit()
        } else {
            // Fallback if CIFilter fails
            Image(systemName: "qrcode")
                .resizable().scaledToFit()
                .foregroundColor(.black)
        }
    }
}

// MARK: - Models

enum PaymentShareTab: String, CaseIterable {
    case link      = "Link"
    case button    = "Button"
    case hyperlink = "Hyperlink"
    case qr        = "QR"
}

enum PayNowButtonSize: String, CaseIterable {
    case small  = "Small"
    case medium = "Medium"
    case large  = "Large"
}

// MARK: - Color Theme

private enum PBColor {
    static let darkBg      = Color(red: 0.08, green: 0.09, blue: 0.14)
    static let cardBg      = Color(red: 0.11, green: 0.13, blue: 0.19)
    static let surfaceBg   = Color(red: 0.14, green: 0.16, blue: 0.23)
    static let border      = Color(red: 0.22, green: 0.25, blue: 0.35)
    static let teal        = Color(red: 0.29, green: 0.87, blue: 0.69)
    static let purple      = Color(red: 0.52, green: 0.38, blue: 0.95)
    static let blue        = Color(red: 0.24, green: 0.56, blue: 0.99)
    static let orange      = Color(red: 0.99, green: 0.60, blue: 0.20)
    static let textPrimary = Color.white
    static let textSub     = Color(red: 0.60, green: 0.65, blue: 0.78)
    static let textMuted   = Color(red: 0.38, green: 0.43, blue: 0.56)
    static let checkBg     = Color(red: 0.13, green: 0.35, blue: 0.27)
    static let previewBg   = Color(red: 0.07, green: 0.08, blue: 0.12)
}

// MARK: - Main View

struct CreatepaymentlinkView: View {
    
    let paymentID:  String
    let paymentURL: String
    var vm: CreatePaymentViewModel? = nil
    
    // Pre-populated email (e.g. from the logged-in user's profile)
    var initialEmail: String = ""
    
    
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentID:  String
    @State private var currentURL: String
    
    @State private var selectedTab:        PaymentShareTab  = .link
    @State private var selectedButtonSize: PayNowButtonSize = .large
    @State private var emailInput:         String           = ""
    @State private var showCopiedToast     = false
    @State private var copiedMessage       = ""
    @State private var isRegenerating      = false
    @State private var isSendingEmail      = false
    
    @State private var showCheckoutSheet = false
    
    // MARK: Init
    
    init(paymentID: String, paymentURL: String, vm: CreatePaymentViewModel? = nil, initialEmail: String = "") {
        self.paymentID    = paymentID
        self.paymentURL   = paymentURL
        self.vm           = vm
        self.initialEmail = initialEmail
        _currentID  = State(initialValue: paymentID)
        _currentURL = State(initialValue: paymentURL)
        _emailInput = State(initialValue: "")   // ← pre-fill
    }
    
    // MARK: Body
    
    var body: some View {
        ZStack {
            PBColor.darkBg.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerCard
                        .padding(.horizontal, 16).padding(.top, 16)
                    urlBar
                        .padding(.horizontal, 16).padding(.top, 12)
                    tabSelector
                        .padding(.horizontal, 16).padding(.top, 12)
                    tabContent
                        .padding(.horizontal, 16).padding(.top, 12)
                    emailSection
                        .padding(.horizontal, 16).padding(.top, 24).padding(.bottom, 120)
                }
            }
            
            VStack { Spacer(); bottomBar }
            
            if showCopiedToast {
                VStack {
                    Spacer()
                    toastView.padding(.bottom, 140)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showCopiedToast)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showCheckoutSheet) {
            if let url = URL(string: currentURL) {
                let checkoutEmail = UserDefaults.standard.string(forKey: "Bemail") ?? ""
                CheckoutSheet(checkoutURL: url, email: checkoutEmail)
            }
        }
    }
    
    // MARK: - Header Card
    
    private var headerCard: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.plain)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(PBColor.checkBg).frame(width: 44, height: 44)
                Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(PBColor.teal)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Payment Link Created")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(PBColor.teal)
                Text("ID: \(currentID)")
                    .font(.system(size: 13)).foregroundColor(PBColor.textSub)
            }
            
            Spacer()
            
            Button { copyToClipboard(currentID, label: "ID Copied!") } label: {
                Text("Copy ID")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(PBColor.textPrimary)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(PBColor.surfaceBg).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(PBColor.border, lineWidth: 1))
            }
        }
        .padding(16).background(PBColor.cardBg).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PBColor.border, lineWidth: 1))
    }
    
    // MARK: - URL Bar
    
    private var urlBar: some View {
        HStack(spacing: 10) {
            Text(currentURL)
                .font(.system(size: 13)).foregroundColor(PBColor.blue)
                .lineLimit(1).truncationMode(.middle)
            Spacer()
            Button { copyToClipboard(currentURL, label: "Link Copied!") } label: {
                Text("Copy").font(.system(size: 13, weight: .medium)).foregroundColor(PBColor.purple)
            }
            Button { openExternalURL(currentURL) } label: {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 16)).foregroundColor(PBColor.textSub)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(PBColor.cardBg).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(PBColor.border, lineWidth: 1))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(PaymentShareTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? .white : PBColor.textSub)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(Group { if selectedTab == tab { Capsule().fill(PBColor.purple) } })
                }
            }
        }
        .padding(4).background(PBColor.cardBg).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PBColor.border, lineWidth: 1))
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .link:      linkTabContent
        case .button:    buttonTabContent
        case .hyperlink: hyperlinkTabContent
        case .qr:        qrTabContent
        }
    }

    // MARK: Link Tab

    private var linkTabContent: some View {
        VStack(spacing: 16) {
            pbOutlineButton(title: "Share Link") { shareLink(currentURL) }
            pbPreviewBox {
                Text(currentURL)
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(PBColor.blue).multilineTextAlignment(.center)
            }
        }
    }
    
    private func shareLink(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        // Find the topmost presented view controller to avoid "already presenting" crash
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let root   = window.rootViewController else { return }
        
        // Walk up to the topmost presented VC so we don't present on one already presenting
        var topVC = root
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        
        // iPad popover anchor (required — crashes without it on iPad)
        if let popover = av.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        topVC.present(av, animated: true)
    }

    // MARK: Button Tab

    private var buttonTabContent: some View {
        let code = "<a href=\"\(currentURL)\"\n  style=\"background:#7c3aed;color:#fff;\n  padding:12px 24px;border-radius:8px\">\n  Pay Now\n</a>"
        return VStack(spacing: 16) {
            pbCodeBox(code)
            pbOutlineButton(title: "Copy Button Code") {
                copyToClipboard(code, label: "Button Code Copied!")
            }
            HStack(spacing: 12) {
                Text("Size:").font(.system(size: 14)).foregroundColor(PBColor.textSub)
                ForEach(PayNowButtonSize.allCases, id: \.self) { size in
                    Button { selectedButtonSize = size } label: {
                        Text(size.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedButtonSize == size ? .white : PBColor.textSub)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(selectedButtonSize == size ? PBColor.purple : PBColor.surfaceBg)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(
                                selectedButtonSize == size ? Color.clear : PBColor.border, lineWidth: 1))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // ✅ Pay Now button opens real checkout URL
            pbPreviewBox {
                Button { openExternalURL(currentURL) } label: {
                    pbPayNowButton(size: selectedButtonSize)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Hyperlink Tab

    private var hyperlinkTabContent: some View {
        let code = "<a href=\"\(currentURL)\">\n  Pay Now\n</a>"
        return VStack(spacing: 16) {
            pbCodeBox(code)
            pbOutlineButton(title: "Copy Hyperlink Code") {
                copyToClipboard(code, label: "Hyperlink Copied!")
            }
            // ✅ Pay Now hyperlink opens real checkout URL
            pbPreviewBox {
                Button { openExternalURL(currentURL) } label: {
                    Text("Pay Now")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(PBColor.purple).underline()
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: QR Tab — ✅ High-quality CoreImage QR, no blur
    private var qrTabContent: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(width: 220, height: 220)
                    .shadow(color: PBColor.purple.opacity(0.25), radius: 16, x: 0, y: 6)

                QRCodeImage(content: currentURL)
                    .frame(width: 190, height: 190)
            }
            .padding(.vertical, 12)

            VStack(spacing: 4) {
                Text("Scan to pay").font(.system(size: 14, weight: .medium)).foregroundColor(PBColor.textSub)
                Text(currentURL)
                    .font(.system(size: 10)).foregroundColor(PBColor.textMuted)
                    .lineLimit(1).truncationMode(.middle)
                    .padding(.horizontal, 32)
            }
        }
    }

    // MARK: - Email Section

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SEND PAYMENT LINK VIA EMAIL")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(PBColor.textMuted).tracking(0.8)

         
            ZStack(alignment: .topLeading) {
                if emailInput.isEmpty {
                    Text("Enter emails with comma separation\n(e.g., customer1@example.com, customer2@example.com)")
                        .font(.system(size: 14)).foregroundColor(PBColor.textMuted).padding(16)
                }
                TextField("", text: $emailInput, axis: .vertical)
                    .font(.system(size: 14)).foregroundColor(PBColor.textPrimary)
                    .lineLimit(3...5).padding(16)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            .background(PBColor.cardBg).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(PBColor.border, lineWidth: 1))

            Button { sendEmail() } label: {
                ZStack {
                    LinearGradient(colors: [PBColor.purple, PBColor.blue],
                                   startPoint: .leading, endPoint: .trailing)
                        .cornerRadius(12)
                    if isSendingEmail {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Email")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
            }
            .disabled(isSendingEmail)
        }
    }
    // MARK: - Bottom Bar

    private var bottomBar: some View {
        HStack(spacing: 12) {
            Button { copyToClipboard(currentURL, label: "Link Copied!") } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(PBColor.surfaceBg)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(PBColor.purple, lineWidth: 1.5))
                    Image(systemName: "doc.on.doc").font(.system(size: 20)).foregroundColor(PBColor.purple)
                }
                .frame(width: 54, height: 54)
            }
            
            Button { regenerate() } label: {
                ZStack {
                    LinearGradient(colors: [PBColor.purple, Color(red: 0.6, green: 0.35, blue: 1.0)],
                                   startPoint: .leading, endPoint: .trailing)
                    .cornerRadius(16)
                    if isRegenerating {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Regenerate Link").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 54)
            }
            .disabled(isRegenerating)
            
            
            
            // ✅ Go to Checkout opens real URL
            Button {
                showCheckoutSheet = true
            } label: {
                Text("Go to Checkout")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(
                        colors: [Color(red: 0.55, green: 0.35, blue: 1.0), PBColor.blue],
                        startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
            }
        }
        
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(
            PBColor.darkBg
                .overlay(Rectangle().frame(height: 1).foregroundColor(PBColor.border), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func openCheckoutWithEmail() {
        var urlString = currentURL
        let email = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !email.isEmpty,
           let firstEmail = email.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces),
           !firstEmail.isEmpty,
           let encoded = firstEmail.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            // Append email as query param so checkout page pre-fills it
            let separator = urlString.contains("?") ? "&" : "?"
            urlString += "\(separator)email=\(encoded)"
        }
        
        openExternalURL(urlString)
    }
    // MARK: - Toast

    private var toastView: some View {
        Text(copiedMessage)
            .font(.system(size: 14, weight: .medium)).foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(PBColor.purple.opacity(0.9)).cornerRadius(20)
    }

    // MARK: - Reusable helpers

    private func pbOutlineButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold)).foregroundColor(PBColor.purple)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(PBColor.surfaceBg).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(PBColor.purple, lineWidth: 1.5))
        }
    }

    private func pbPreviewBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(PBColor.previewBg)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(PBColor.border.opacity(0.6),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])))
            content().padding(20)
        }
        .frame(minHeight: 80)
    }

    private func pbCodeBox(_ code: String) -> some View {
        Text(code)
            .font(.system(size: 12, design: .monospaced)).foregroundColor(PBColor.textSub)
            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(PBColor.surfaceBg).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(PBColor.border, lineWidth: 1))
    }

    @ViewBuilder
    private func pbPayNowButton(size: PayNowButtonSize) -> some View {
        let config: (CGFloat, CGFloat, CGFloat) = {
            switch size {
            case .small:  return (13, 20, 10)
            case .medium: return (15, 28, 13)
            case .large:  return (17, 36, 16)
            }
        }()
        Text("Pay Now")
            .font(.system(size: config.0, weight: .semibold)).foregroundColor(.white)
            .padding(.horizontal, config.1).padding(.vertical, config.2)
            .background(PBColor.purple).cornerRadius(12)
    }

    // MARK: - Actions

    private func copyToClipboard(_ text: String, label: String) {
        UIPasteboard.general.string = text
        copiedMessage = label
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedToast = false }
        }
    }

    private func openExternalURL(_ urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            copyToClipboard(urlString, label: "URL copied (couldn't open)")
            return
        }
        UIApplication.shared.open(url)
    }

//    private func shareLink(_ urlString: String) {
//        guard let url = URL(string: urlString) else { return }
//        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
//        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let root  = scene.windows.first?.rootViewController {
//            root.present(av, animated: true)
//        }
//    }

    private func regenerate() {
        guard let vm else { showToast("Pass vm to regenerate"); return }
        isRegenerating = true
        Task { @MainActor in
            vm.regeneratePaymentLink {
                self.currentID  = vm.createdPaymentID  ?? self.currentID
                self.currentURL = vm.createdPaymentURL ?? self.currentURL
                self.isRegenerating = false
                self.showToast("New link generated!")
            }
        }
    }

    private func sendEmail() {
        let trimmed = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { showToast("Enter at least one email"); return }

        guard let vm else {
            showToast("No VM — cannot send email")
            return
        }

        isSendingEmail = true
        vm.sendPaymentLink(
            emailsRaw: trimmed,
            onSuccess: {
                self.isSendingEmail = false
                self.showToast("Email sent successfully! ✉️")
            },
            onFailure: { errMsg in
                self.isSendingEmail = false
                self.showToast("Failed: \(errMsg)")
            }
        )
    }

    private func showToast(_ msg: String) {
        copiedMessage = msg
        withAnimation { showCopiedToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedToast = false }
        }
    }
}





// MARK: - Preview

#Preview {
    NavigationStack {
        CreatepaymentlinkView(
            paymentID:  "PCN3069",
            paymentURL: "https://trade.paybito.com/payments/merchant/checkout/PCN3069"
        )
    }
}





