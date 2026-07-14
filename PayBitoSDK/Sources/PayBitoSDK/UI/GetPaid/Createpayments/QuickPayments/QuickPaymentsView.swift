//
//  QuickPaymentsView.swift
//  Trading_Terminal
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - QR Code Image View

private struct QPQRCodeImage: View {
    let content: String

    private var uiImage: UIImage? {
        guard !content.isEmpty else { return nil }
        let context = CIContext()
        let filter  = CIFilter.qrCodeGenerator()
        filter.message         = Data(content.utf8)
        filter.correctionLevel = "H"
        guard let ciImage = filter.outputImage else { return nil }
        let scaled = ciImage.transformed(by: CGAffineTransform(scaleX: 12, y: 12))
        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    var body: some View {
        if let img = uiImage {
            Image(uiImage: img)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .foregroundColor(.black)
        }
    }
}

// MARK: - Focus Fields

enum QuickPaymentFocus: Hashable {
    case amount
    case email
}

// MARK: - Currency Model

struct QPCurrency: Identifiable, Hashable {
    let id     = UUID()
    let code:   String
    let symbol: String
    let name:   String
}

// MARK: - Share Tab (matches CreatepaymentlinkView exactly)

enum QPShareTab: String, CaseIterable {
    case link      = "Link"
    case button    = "Button"
    case hyperlink = "Hyperlink"
    case qr        = "QR"
}

enum QPButtonSize: String, CaseIterable {
    case small  = "Small"
    case medium = "Medium"
    case large  = "Large"
}

// MARK: - CTA Background

private struct QPCTABackground: View {
    let isReady:    Bool
    let showResult: Bool

    private let green  = Color(red: 0.10, green: 0.72, blue: 0.45)
    private let purple = Color(red: 0.52, green: 0.38, blue: 0.95)
    private let dark   = Color(red: 0.32, green: 0.25, blue: 0.80)

    var body: some View {
        if !isReady {
            RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.06))
        } else if showResult {
            RoundedRectangle(cornerRadius: 16).fill(green.opacity(0.82))
        } else {
            RoundedRectangle(cornerRadius: 16)
                .fill(LinearGradient(colors: [purple, dark], startPoint: .leading, endPoint: .trailing))
        }
    }
}

// MARK: - CTA Label

private struct QPCTALabel: View {
    let isCreating: Bool
    let showResult: Bool
    let isReady:    Bool

    var body: some View {
        if isCreating {
            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
        } else {
            HStack(spacing: 8) {
                Image(systemName: showResult ? "checkmark" : "bolt.fill")
                    .font(.system(size: 15, weight: .bold))
                Text(showResult ? "Open payment page" : "Create Payment")
                    .font(.system(size: 17, weight: .bold))
            }
            .foregroundColor(isReady ? .white : Color.white.opacity(0.32))
        }
    }
}

// MARK: - QuickPaymentsView

struct QuickPaymentsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = QuickPaymentViewModel()
    @FocusState private var focusedField: QuickPaymentFocus?

    @State private var selectedCurrency     = QPCurrency(code: "USD", symbol: "$", name: "US Dollar")
    @State private var showCurrencyDropdown = false

    @State private var showResult        = false
    @State private var selectedTab       = QPShareTab.link
    @State private var selectedSize      = QPButtonSize.large
    @State private var emailInput        = ""
    @State private var isSendingEmail    = false
    @State private var isRegenerating    = false
    @State private var showCheckoutSheet = false

    @State private var showToast    = false
    @State private var toastMessage = ""

    private let darkBg    = Color(red: 0.07, green: 0.09, blue: 0.14)
    private let cardBg    = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let surfaceBg = Color(red: 0.12, green: 0.14, blue: 0.20)
    private let inputBg   = Color(red: 0.12, green: 0.14, blue: 0.20)
    private let rowBg     = Color(red: 0.09, green: 0.11, blue: 0.17)
    private let previewBg = Color(red: 0.07, green: 0.08, blue: 0.12)
    private let border    = Color.white.opacity(0.09)
    private let purple    = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let blue      = Color(red: 0.36, green: 0.49, blue: 0.96)
    private let cyan      = Color(red: 0.36, green: 0.82, blue: 1.0)
    private let green     = Color(red: 0.10, green: 0.72, blue: 0.45)
    private let teal      = Color(red: 0.29, green: 0.87, blue: 0.69)
    private let checkBg   = Color(red: 0.13, green: 0.35, blue: 0.27)
    private let textSub   = Color(red: 0.60, green: 0.65, blue: 0.78)
    private let textMuted = Color(red: 0.38, green: 0.43, blue: 0.56)

    let currencies: [QPCurrency] = [
        QPCurrency(code: "USD", symbol: "$",   name: "US Dollar"),
        QPCurrency(code: "EUR", symbol: "EUR", name: "Euro"),
        QPCurrency(code: "GBP", symbol: "GBP", name: "British Pound"),
        QPCurrency(code: "AUD", symbol: "A$",  name: "Australian Dollar"),
        QPCurrency(code: "CAD", symbol: "C$",  name: "Canadian Dollar"),
        QPCurrency(code: "SGD", symbol: "S$",  name: "Singapore Dollar"),
        QPCurrency(code: "JPY", symbol: "JPY", name: "Japanese Yen"),
        QPCurrency(code: "CHF", symbol: "CHF", name: "Swiss Franc"),
        QPCurrency(code: "HKD", symbol: "HK$", name: "Hong Kong Dollar"),
        QPCurrency(code: "MYR", symbol: "RM",  name: "Malaysian Ringgit"),
        QPCurrency(code: "BRL", symbol: "R$",  name: "Brazilian Real"),
        QPCurrency(code: "NZD", symbol: "NZ$", name: "New Zealand Dollar"),
    ]

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .bottom) {
            darkBg.ignoresSafeArea()

            Color.clear
                .contentShape(Rectangle())
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) { showCurrencyDropdown = false }
                    focusedField = nil
                }

            VStack(spacing: 0) {
                headerBar
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        amountCard

                        if let errMsg = vm.createError {
                            errorBanner(errMsg)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        if showResult {
                            resultHeaderCard
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .top)),
                                    removal: .opacity))

                            resultURLBar
                                .transition(.opacity.combined(with: .move(edge: .top)))

                            resultTabSelector
                                .transition(.opacity)

                            resultTabContent
                                .transition(.opacity)

                            emailSection
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Spacer(minLength: 110)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 130)
                    .animation(.spring(response: 0.4, dampingFraction: 0.78), value: showResult)
                    .animation(.easeInOut(duration: 0.2), value: vm.createError)
                }
            }

            if showResult { resultBottomBar } else { createCTA }

            if showToast {
                VStack {
                    Spacer()
                    Text(toastMessage)
                        .font(.system(size: 14, weight: .medium)).foregroundColor(.white)
                        .padding(.horizontal, 20).padding(.vertical, 10)
                        .background(purple.opacity(0.9)).cornerRadius(20)
                        .padding(.bottom, 130)
                }
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: showToast)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .navigationBarHidden(true)
        .onChange(of: selectedCurrency) { newVal in vm.currency = newVal.code }
        .onAppear { vm.currency = selectedCurrency.code }
        .fullScreenCover(isPresented: $showCheckoutSheet) {
            if let urlStr = vm.paymentURL, let url = URL(string: urlStr) {
                let email = UserDefaults.standard.string(forKey: "Bemail") ?? ""
                CheckoutSheet(checkoutURL: url, email: email)
            }
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "arrow.left")
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 38, height: 38)
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white.opacity(0.08)))
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                ZStack {
                    Circle().fill(cyan.opacity(0.15)).frame(width: 32, height: 32)
                    Image(systemName: "bolt.fill").foregroundColor(cyan).font(.system(size: 14))
                }
                Text("Quick Payment")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .overlay(Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1), alignment: .bottom)
    }

    // MARK: - Amount Card

    private var amountCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("AMOUNT")
                .foregroundColor(Color.gray.opacity(0.55))
                .font(.system(size: 11, weight: .semibold)).tracking(1.1)

            amountInputRow

            if showCurrencyDropdown {
                currencyDropdown
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(10)
            }

            if !vm.amount.isEmpty {
                amountPill
                    .transition(.opacity.combined(with: .scale(scale: 0.92, anchor: .leading)))
            }
        }
        .padding(16).background(cardBg).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(border, lineWidth: 1))
        .animation(.spring(response: 0.3, dampingFraction: 0.78), value: showCurrencyDropdown)
        .animation(.easeInOut(duration: 0.2), value: vm.amount.isEmpty)
        .zIndex(showCurrencyDropdown ? 20 : 1)
    }

    private var amountInputRow: some View {
        HStack(spacing: 0) {
            currencyButton
            amountTextField
        }
        .background(RoundedRectangle(cornerRadius: 14).fill(inputBg))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(amountBorderColor, lineWidth: amountBorderWidth))
    }

    private var amountBorderColor: Color {
        if focusedField == .amount { return purple }
        if showCurrencyDropdown    { return purple.opacity(0.55) }
        return border
    }

    private var amountBorderWidth: CGFloat {
        (focusedField == .amount || showCurrencyDropdown) ? 1.8 : 1
    }

    private var currencyButton: some View {
        Button {
            focusedField = nil
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                showCurrencyDropdown.toggle()
            }
        } label: {
            HStack(spacing: 5) {
                Text(selectedCurrency.code)
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .bold))
                    .frame(minWidth: 34)
                Image(systemName: showCurrencyDropdown ? "chevron.up" : "chevron.down")
                    .foregroundColor(showCurrencyDropdown ? purple : Color.gray.opacity(0.55))
                    .font(.system(size: 10, weight: .bold))
            }
            .padding(.horizontal, 14).frame(height: 56)
            .background(RoundedRectangle(cornerRadius: 0)
                .fill(showCurrencyDropdown ? purple.opacity(0.14) : Color.white.opacity(0.05)))
            .overlay(Rectangle()
                .fill(showCurrencyDropdown ? purple.opacity(0.5) : Color.white.opacity(0.10))
                .frame(width: 1), alignment: .trailing)
        }
        .buttonStyle(.plain)
    }

    private var amountTextField: some View {
        TextField("",
                  text: $vm.amount,
                  prompt: Text("Enter amount").foregroundColor(Color.gray.opacity(0.38)))
            .focused($focusedField, equals: .amount)
            .keyboardType(.decimalPad)
            .foregroundColor(.white).tint(purple)
            .font(.system(size: 22, weight: .semibold))
            .padding(.horizontal, 16).frame(height: 56).frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) { showCurrencyDropdown = false }
                focusedField = .amount
            }
    }

    private var currencyDropdown: some View {
        ScrollView(showsIndicators: true) {
            VStack(spacing: 0) {
                ForEach(Array(currencies.enumerated()), id: \.element.id) { idx, cur in
                    currencyRow(cur: cur, isLast: idx == currencies.count - 1)
                }
            }
        }
        .frame(height: 280)
        .background(
            RoundedRectangle(cornerRadius: 14).fill(rowBg)
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.11), lineWidth: 1))
                .shadow(color: .black.opacity(0.55), radius: 24, x: 0, y: 12)
        )
    }

    private func currencyRow(cur: QPCurrency, isLast: Bool) -> some View {
        let isSelected = cur.code == selectedCurrency.code
        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.8)) {
                    selectedCurrency     = cur
                    showCurrencyDropdown = false
                }
            } label: {
                HStack(spacing: 12) {
                    Text(cur.symbol)
                        .foregroundColor(isSelected ? purple : Color.gray.opacity(0.6))
                        .font(.system(size: 13, weight: .semibold))
                        .frame(width: 28, alignment: .center)
                        .padding(.vertical, 4)
                        .background(RoundedRectangle(cornerRadius: 6)
                            .fill(isSelected ? purple.opacity(0.14) : Color.white.opacity(0.05)))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(cur.code)
                            .foregroundColor(.white)
                            .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                        Text(cur.name)
                            .foregroundColor(Color.gray.opacity(0.5))
                            .font(.system(size: 11))
                    }
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(purple).font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(isSelected ? purple.opacity(0.08) : Color.clear)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if !isLast {
                Divider().background(Color.white.opacity(0.06)).padding(.horizontal, 14)
            }
        }
    }

    private var amountPill: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(purple.opacity(0.8)).font(.system(size: 12))
            Text("\(selectedCurrency.symbol)\(vm.amount) \(selectedCurrency.code)")
                .foregroundColor(Color.white.opacity(0.75))
                .font(.system(size: 12, weight: .semibold))
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .background(Capsule().fill(purple.opacity(0.12))
            .overlay(Capsule().stroke(purple.opacity(0.3), lineWidth: 1)))
    }

    // MARK: - Error Banner

    private func errorBanner(_ msg: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange).font(.system(size: 15))
            Text(msg).foregroundColor(Color.orange.opacity(0.9)).font(.system(size: 13))
            Spacer()
            Button { vm.createError = nil } label: {
                Image(systemName: "xmark")
                    .foregroundColor(Color.gray.opacity(0.5)).font(.system(size: 12))
            }
        }
        .padding(14)
        .background(Color(red: 0.18, green: 0.12, blue: 0.06)).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.orange.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Result: Header Card
    // Identical to CreatepaymentlinkView headerCard

    private var resultHeaderCard: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10).fill(checkBg).frame(width: 44, height: 44)
                Image(systemName: "checkmark").font(.system(size: 18, weight: .bold)).foregroundColor(teal)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Payment Link Created")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(teal)
                Text("ID: \(vm.paymentID ?? "")")
                    .font(.system(size: 13)).foregroundColor(textSub)
            }
            Spacer()
            Button { showToastMsg(vm.paymentID ?? "", copy: true, label: "ID Copied!") } label: {
                Text("Copy ID")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(surfaceBg).cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(border, lineWidth: 1))
            }
        }
        .padding(16)
        .background(cardBg).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(teal.opacity(0.3), lineWidth: 1))
    }

    // MARK: - Result: URL Bar
    // Identical to CreatepaymentlinkView urlBar

    private var resultURLBar: some View {
        HStack(spacing: 10) {
            Text(vm.paymentURL ?? "")
                .font(.system(size: 13)).foregroundColor(blue)
                .lineLimit(1).truncationMode(.middle)
            Spacer()
            Button { showToastMsg(vm.paymentURL ?? "", copy: true, label: "Link Copied!") } label: {
                Text("Copy").font(.system(size: 13, weight: .medium)).foregroundColor(purple)
            }
            Button { openURL(vm.paymentURL ?? "") } label: {
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 16)).foregroundColor(textSub)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(cardBg).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(border, lineWidth: 1))
    }

    // MARK: - Result: Tab Selector
    // Identical to CreatepaymentlinkView tabSelector

    private var resultTabSelector: some View {
        HStack(spacing: 0) {
            ForEach(QPShareTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
                } label: {
                    Text(tab.rawValue)
                        .font(.system(size: 14, weight: selectedTab == tab ? .semibold : .regular))
                        .foregroundColor(selectedTab == tab ? .white : textSub)
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                        .background(Group {
                            if selectedTab == tab { Capsule().fill(purple) }
                        })
                }
            }
        }
        .padding(4)
        .background(cardBg).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(border, lineWidth: 1))
    }

    // MARK: - Result: Tab Content Router

    @ViewBuilder
    private var resultTabContent: some View {
        switch selectedTab {
        case .link:      linkTabContent
        case .button:    buttonTabContent
        case .hyperlink: hyperlinkTabContent
        case .qr:        qrTabContent
        }
    }

    // MARK: Link Tab
    // Identical to CreatepaymentlinkView linkTabContent:
    //   pbOutlineButton "Share Link" + pbPreviewBox showing the URL

    private var linkTabContent: some View {
        VStack(spacing: 16) {
            pbOutlineButton(title: "Share Link") { shareLink(vm.paymentURL ?? "") }
            pbPreviewBox {
                Text(vm.paymentURL ?? "")
                    .font(.system(size: 13, design: .monospaced))
                    .foregroundColor(blue)
                    .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: Button Tab
    // Identical to CreatepaymentlinkView buttonTabContent

    private var buttonTabContent: some View {
        let url  = vm.paymentURL ?? ""
        let code = "<a href=\"\(url)\"\n  style=\"background:#7c3aed;color:#fff;\n  padding:12px 24px;border-radius:8px\">\n  Pay Now\n</a>"
        return VStack(spacing: 16) {
            pbCodeBox(code)
            pbOutlineButton(title: "Copy Button Code") {
                showToastMsg(code, copy: true, label: "Button Code Copied!")
            }
            HStack(spacing: 12) {
                Text("Size:").font(.system(size: 14)).foregroundColor(textSub)
                ForEach(QPButtonSize.allCases, id: \.self) { size in
                    Button { selectedSize = size } label: {
                        Text(size.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(selectedSize == size ? .white : textSub)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(selectedSize == size ? purple : surfaceBg)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(
                                selectedSize == size ? Color.clear : border, lineWidth: 1))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            pbPreviewBox {
                Button { openURL(url) } label: { payNowButton(size: selectedSize) }
                    .buttonStyle(.plain)
            }
        }
    }

    // MARK: Hyperlink Tab
    // Identical to CreatepaymentlinkView hyperlinkTabContent

    private var hyperlinkTabContent: some View {
        let url  = vm.paymentURL ?? ""
        let code = "<a href=\"\(url)\">\n  Pay Now\n</a>"
        return VStack(spacing: 16) {
            pbCodeBox(code)
            pbOutlineButton(title: "Copy Hyperlink Code") {
                showToastMsg(code, copy: true, label: "Hyperlink Copied!")
            }
            pbPreviewBox {
                Button { openURL(url) } label: {
                    Text("Pay Now")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(purple).underline()
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: QR Tab
    // Identical to CreatepaymentlinkView qrTabContent

    private var qrTabContent: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .frame(width: 220, height: 220)
                    .shadow(color: purple.opacity(0.25), radius: 16, x: 0, y: 6)
                QPQRCodeImage(content: vm.paymentURL ?? "")
                    .frame(width: 190, height: 190)
            }
            .padding(.vertical, 12)

            VStack(spacing: 4) {
                Text("Scan to pay")
                    .font(.system(size: 14, weight: .medium)).foregroundColor(textSub)
                Text(vm.paymentURL ?? "")
                    .font(.system(size: 10)).foregroundColor(textMuted)
                    .lineLimit(1).truncationMode(.middle)
                    .padding(.horizontal, 32)
            }
        }
    }

    // MARK: - Email Section
    // Identical to CreatepaymentlinkView emailSection

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SEND PAYMENT LINK VIA EMAIL")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(textMuted).tracking(0.8)

            ZStack(alignment: .topLeading) {
                if emailInput.isEmpty {
                    Text("Enter emails with comma separation\n(e.g., customer1@example.com, customer2@example.com)")
                        .font(.system(size: 14)).foregroundColor(textMuted).padding(16)
                }
                TextField("", text: $emailInput, axis: .vertical)
                    .focused($focusedField, equals: .email)
                    .font(.system(size: 14)).foregroundColor(.white)
                    .lineLimit(3...5).padding(16)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            .background(cardBg).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(focusedField == .email ? purple : border, lineWidth: 1.5))

            Button { sendEmail() } label: {
                ZStack {
                    LinearGradient(colors: [purple, blue],
                                   startPoint: .leading, endPoint: .trailing)
                        .cornerRadius(12)
                    if isSendingEmail {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Send Email")
                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity).frame(height: 54)
            }
            .disabled(isSendingEmail)
        }
    }

    // MARK: - Result Bottom Bar
    // Identical to CreatepaymentlinkView bottomBar

    private var resultBottomBar: some View {
        HStack(spacing: 12) {
            Button { showToastMsg(vm.paymentURL ?? "", copy: true, label: "Link Copied!") } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(surfaceBg)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(purple, lineWidth: 1.5))
                    Image(systemName: "doc.on.doc").font(.system(size: 20)).foregroundColor(purple)
                }
                .frame(width: 54, height: 54)
            }

            Button { regenerate() } label: {
                ZStack {
                    LinearGradient(colors: [purple, Color(red: 0.6, green: 0.35, blue: 1.0)],
                                   startPoint: .leading, endPoint: .trailing)
                        .cornerRadius(16)
                    if isRegenerating {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Regenerate Link")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 54)
            }
            .disabled(isRegenerating)

            Button { showCheckoutSheet = true } label: {
                Text("Go to Checkout")
                    .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(LinearGradient(
                        colors: [Color(red: 0.55, green: 0.35, blue: 1.0), blue],
                        startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(16)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(
            darkBg
                .overlay(Rectangle().frame(height: 1).foregroundColor(border), alignment: .top)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    // MARK: - Create CTA

    private var createCTA: some View {
        VStack(spacing: 0) {
            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 1)

            Button {
                focusedField = nil
                withAnimation(.easeInOut(duration: 0.2)) { showCurrencyDropdown = false }
                vm.createLink {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.78)) {
                        showResult = true
                    }
                }
            } label: {
                ZStack {
                    QPCTABackground(isReady: vm.isReadyToCreate, showResult: showResult)
                    QPCTALabel(isCreating: vm.isCreating,
                               showResult: showResult,
                               isReady: vm.isReadyToCreate)
                }
                .frame(maxWidth: .infinity).frame(height: 56)
                .animation(.easeInOut(duration: 0.22), value: showResult)
            }
            .disabled(!vm.isReadyToCreate || vm.isCreating)
            .buttonStyle(.plain)
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 30)
        }
        .background(darkBg.ignoresSafeArea(edges: .bottom))
    }

    // MARK: - Shared UI Helpers (identical to CreatepaymentlinkView)

    private func pbOutlineButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .semibold)).foregroundColor(purple)
                .frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(surfaceBg).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(purple, lineWidth: 1.5))
        }
    }

    private func pbPreviewBox<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12).fill(previewBg)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(border.opacity(0.6),
                            style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])))
            content().padding(20)
        }
        .frame(minHeight: 80)
    }

    private func pbCodeBox(_ code: String) -> some View {
        Text(code)
            .font(.system(size: 12, design: .monospaced)).foregroundColor(textSub)
            .frame(maxWidth: .infinity, alignment: .leading).padding(14)
            .background(surfaceBg).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(border, lineWidth: 1))
    }

    @ViewBuilder
    private func payNowButton(size: QPButtonSize) -> some View {
        let cfg: (CGFloat, CGFloat, CGFloat) = {
            switch size {
            case .small:  return (13, 20, 10)
            case .medium: return (15, 28, 13)
            case .large:  return (17, 36, 16)
            }
        }()
        Text("Pay Now")
            .font(.system(size: cfg.0, weight: .semibold)).foregroundColor(.white)
            .padding(.horizontal, cfg.1).padding(.vertical, cfg.2)
            .background(purple).cornerRadius(12)
    }

    // MARK: - Actions

    private func showToastMsg(_ text: String, copy: Bool, label: String) {
        if copy { UIPasteboard.general.string = text }
        toastMessage = label
        withAnimation { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { withAnimation { showToast = false } }
    }

    private func openURL(_ urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private func shareLink(_ urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let root   = window.rootViewController else { return }
        var topVC = root
        while let presented = topVC.presentedViewController { topVC = presented }
        if let popover = av.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(x: topVC.view.bounds.midX, y: topVC.view.bounds.midY,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        topVC.present(av, animated: true)
    }

    private func regenerate() {
        isRegenerating = true
        vm.createLink {
            isRegenerating = false
            showToastMsg("", copy: false, label: "New link generated!")
        }
    }

    private func sendEmail() {
        let trimmed = emailInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            showToastMsg("", copy: false, label: "Enter at least one email")
            return
        }
        isSendingEmail = true
        vm.sendEmail(
            emailsRaw: trimmed,
            onSuccess: {
                isSendingEmail = false
                showToastMsg("", copy: false, label: "Email sent successfully!")
            },
            onFailure: { err in
                isSendingEmail = false
                showToastMsg("", copy: false, label: "Failed: \(err)")
            }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack { QuickPaymentsView() }
        .preferredColorScheme(.dark)
}
