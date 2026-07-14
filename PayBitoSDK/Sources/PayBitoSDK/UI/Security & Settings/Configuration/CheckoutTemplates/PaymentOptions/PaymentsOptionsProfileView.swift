// MARK: - NewPaymentProfileView.swift

import SwiftUI

struct NewPaymentProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: PaymentOptionsViewModel
    let editingProfile: BillingProfile.Profile?

    @State private var profileName = ""
    @State private var email = ""
    @State private var isDefault = false

    // Card gateways
    @State private var isStripeEnabled = false
    @State private var isPaypalEnabled = false
    @State private var isKurvPayEnabled = false
    @State private var isNetbillingEnabled = false
    @State private var isHMSEnabled = false
    @State private var isCardFloEnabled = false
    @State private var isNMIEnabled = false

    // Crypto
    @State private var isCryptoEnabled = true
    @State private var brandWallet = true
    @State private var externalWallet = false
    @State private var guestCheckout = false

    @State private var selectedCryptos: Set<String> = []
    @FocusState private var focusedField: Field?
    @State private var selectAllCryptos = false

    enum Field { case profileName, email }

    private var cryptos: [String] { vm.currencies.map { $0.code } }

    // MARK: - Init
    init(vm: PaymentOptionsViewModel, editingProfile: BillingProfile.Profile? = nil) {
        self.vm = vm
        self.editingProfile = editingProfile

        _profileName = State(initialValue: editingProfile?.name ?? "")
        _email = State(initialValue: editingProfile?.customerEmail ?? "")
        _isDefault = State(initialValue: editingProfile?.isDefault ?? false)

        _isStripeEnabled    = State(initialValue: editingProfile?.stripeEnabled    ?? false)
        _isPaypalEnabled    = State(initialValue: editingProfile?.paypalEnabled    ?? false)
        _isKurvPayEnabled   = State(initialValue: editingProfile?.kurvPayEnabled   ?? false)
        _isNetbillingEnabled = State(initialValue: editingProfile?.netbillingEnabled ?? false)
        _isHMSEnabled       = State(initialValue: editingProfile?.hmsEnabled       ?? false)
        _isCardFloEnabled   = State(initialValue: editingProfile?.cardFloEnabled   ?? false)
        _isNMIEnabled       = State(initialValue: editingProfile?.nmiEnabled       ?? false)

        _isCryptoEnabled    = State(initialValue: editingProfile?.cryptoEnabled    ?? true)
        _brandWallet        = State(initialValue: editingProfile?.brandWallet      ?? true)
        _externalWallet     = State(initialValue: editingProfile?.externalWalletEnabled ?? false)
        _guestCheckout      = State(initialValue: editingProfile?.guestCheckout    ?? false)

        _selectedCryptos = State(
            initialValue: Set(editingProfile?.selectedCryptoCodes ?? ["BTC", "USDT"])
        )
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    headerView.padding(.bottom, 28)

                    inputField(label: "PROFILE NAME",
                               placeholder: "e.g. Standard Crypto Checkout",
                               text: $profileName, icon: "tag.fill",
                               required: true, field: .profileName)
                        .padding(.bottom, 12)

//                    inputField(label: "CUSTOMER EMAIL",
//                               placeholder: "customer@example.com",
//                               text: $email, icon: "envelope.fill",
//                               required: false, field: .email)
//                        .padding(.bottom, 20)

                    // Default toggle
                    defaultToggleRow.padding(.bottom, 24)

                    sectionHeader(icon: "creditcard.fill", title: "Payment Methods", color: .blue)
                        .padding(.bottom, 6)

                    Text("Enable the checkout options available to your customers.")
                        .foregroundColor(Color.white.opacity(0.35))
                        .font(.system(size: 12))
                        .padding(.bottom, 16)

                    // ── Card gateways ───────────────────────────────────────
                    if vm.availableMethodIds.contains(1) {
                        paymentMethodRow(
                            icon: "creditcard",
                            iconColor: Color(red: 0.388, green: 0.357, blue: 1.0),
                            title: "Pay with Card (PayBito Apex)",
                            subtitle: "Powered by Stripe",
                            badge: nil,
                            isOn: $isStripeEnabled,
                            guardConfig: vm.gatewayConfig.stripeConfigured,
                            guardMessage: "Please configure your PayBito Apex credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    if vm.availableMethodIds.contains(2) {
                        paymentMethodRow(
                            icon: "p.circle.fill",
                            iconColor: Color(red: 0.0, green: 0.19, blue: 0.53),
                            title: "PayBito Titan",
                            subtitle: "Accept PayPal payments",
                            badge: nil,
                            isOn: $isPaypalEnabled,
                            guardConfig: vm.gatewayConfig.paypalConfigured,
                            guardMessage: "Please configure your PayBito Titan credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    if vm.availableMethodIds.contains(7) {
                        paymentMethodRow(
                            icon: "bolt.fill",
                            iconColor: Color(red: 0.051, green: 0.580, blue: 0.533),
                            title: "PayBito Nexus",
                            subtitle: "Card payments via Collect.js",
                            badge: nil,
                            isOn: $isKurvPayEnabled,
                            guardConfig: vm.gatewayConfig.kurvPayConfigured,
                            guardMessage: "Please configure your PayBito Nexus credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    if vm.availableMethodIds.contains(8) {
                        paymentMethodRow(
                            icon: "creditcard.fill",
                            iconColor: Color(red: 0.055, green: 0.647, blue: 0.914),
                            title: "PayBito Vertex",
                            subtitle: "Card payments via NetBilling",
                            badge: nil,
                            isOn: $isNetbillingEnabled,
                            guardConfig: vm.gatewayConfig.netbillingConfigured,
                            guardMessage: "Please configure your PayBito Vertex credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    if vm.availableMethodIds.contains(9) {
                        paymentMethodRow(
                            icon: "building.columns",
                            iconColor: Color(red: 0.388, green: 0.400, blue: 0.945),
                            title: "PayBito Nova",
                            subtitle: "Card payments via Host Merchant Services",
                            badge: nil,
                            isOn: $isHMSEnabled,
                            guardConfig: vm.gatewayConfig.hmsConfigured,
                            guardMessage: "Please configure your PayBito Nova credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    if vm.availableMethodIds.contains(11) {
                        paymentMethodRow(
                            icon: "bolt.fill",
                            iconColor: Color(red: 0.486, green: 0.227, blue: 0.929),
                            title: "PayBito Zenith",
                            subtitle: "Card payments via NMI",
                            badge: nil,
                            isOn: $isNMIEnabled,
                            guardConfig: vm.gatewayConfig.nmiConfigured,
                            guardMessage: "Please configure your PayBito Zenith credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    if vm.availableMethodIds.contains(10) {
                        paymentMethodRow(
                            icon: "creditcard.fill",
                            iconColor: Color(red: 0.310, green: 0.275, blue: 0.898),
                            title: "PayBito Sovereign",
                            subtitle: "Card payments via CardFlo",
                            badge: nil,
                            isOn: $isCardFloEnabled,
                            guardConfig: vm.gatewayConfig.cardFloConfigured,
                            guardMessage: "Please configure your PayBito Sovereign credentials in Payment Settings first."
                        )
                        .padding(.bottom, 10)
                    }

                    // ── Crypto section ──────────────────────────────────────
                    cryptoSection.padding(.bottom, 32)

                    actionButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 32)
            }
        }
    }

    // MARK: - Save
    private func saveProfile() {
        let trimmedName = profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            vm.toast("Profile name is required", isError: true)
            return
        }
        if isCryptoEnabled && selectedCryptos.isEmpty {
            vm.toast("Select at least one cryptocurrency", isError: true)
            return
        }
        // At least one method must be enabled
        let anyCryptoOn = isCryptoEnabled && (brandWallet || externalWallet || guestCheckout)
        let anyEnabled = isStripeEnabled || isPaypalEnabled || isKurvPayEnabled ||
                         isNetbillingEnabled || isHMSEnabled || isCardFloEnabled ||
                         isNMIEnabled || anyCryptoOn
        guard anyEnabled else {
            vm.toast("At least one payment method must be enabled", isError: true)
            return
        }

        let selectedCodes = isCryptoEnabled ? Array(selectedCryptos) : []

        if let profile = editingProfile {
            vm.updateProfile(
                id: profile.id,
                name: trimmedName,
                customerEmail: email,
                stripeEnabled: isStripeEnabled,
                paypalEnabled: isPaypalEnabled,
                kurvPayEnabled: isKurvPayEnabled,
                netbillingEnabled: isNetbillingEnabled,
                hmsEnabled: isHMSEnabled,
                cardFloEnabled: isCardFloEnabled,
                nmiEnabled: isNMIEnabled,
                brandWallet: isCryptoEnabled ? brandWallet : false,
                externalWalletEnabled: isCryptoEnabled ? externalWallet : false,
                guestCheckout: isCryptoEnabled ? guestCheckout : false,
                selectedCodes: selectedCodes,
                isDefault: isDefault
            ) { success in if success { self.dismiss() } }
        } else {
            vm.createProfile(
                name: trimmedName,
                customerEmail: email,
                stripeEnabled: isStripeEnabled,
                paypalEnabled: isPaypalEnabled,
                kurvPayEnabled: isKurvPayEnabled,
                netbillingEnabled: isNetbillingEnabled,
                hmsEnabled: isHMSEnabled,
                cardFloEnabled: isCardFloEnabled,
                nmiEnabled: isNMIEnabled,
                brandWallet: isCryptoEnabled ? brandWallet : false,
                externalWalletEnabled: isCryptoEnabled ? externalWallet : false,
                guestCheckout: isCryptoEnabled ? guestCheckout : false,
                selectedCodes: selectedCodes,
                isDefault: isDefault
            ) { success in if success { self.dismiss() } }
        }
    }

    // MARK: - Header
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.07)).frame(width: 36, height: 36)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            Spacer()
            Text(editingProfile == nil ? "New Payment Profile" : "Edit Payment Profile")
                .foregroundColor(.white)
                .font(.system(size: 17, weight: .bold))
            Spacer()
            Circle().fill(Color.clear).frame(width: 36, height: 36)
        }
    }

    // MARK: - Default toggle row
    private var defaultToggleRow: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("Set as Default")
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                }
                Text("Use this profile as the default billing profile.")
                    .foregroundColor(Color.white.opacity(0.4))
                    .font(.system(size: 12))
            }
            Spacer()
            Toggle("", isOn: $isDefault)
                .labelsHidden()
                .tint(.yellow)
        }
        .padding(14)
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    // MARK: - Crypto section
    private var cryptoSection: some View {
        VStack(alignment: .leading, spacing: 0) {

            paymentMethodRow(
                icon: "bitcoinsign.circle.fill",
                iconColor: .orange,
                title: "Pay with Crypto",
                subtitle: "Wallet & guest checkout",
                badge: "RECOMMENDED",
                isOn: $isCryptoEnabled,
                guardConfig: true,
                guardMessage: ""
            )

            if isCryptoEnabled {
                VStack(alignment: .leading, spacing: 0) {

                    VStack(spacing: 0) {
                        subToggleRow(icon: "wallet.pass.fill", iconColor: .purple,
                                     title: "Brand Wallet", subtitle: "Built-in crypto wallet",
                                     isOn: $brandWallet)
                        rowDivider()
                        subToggleRow(icon: "link.circle.fill", iconColor: .blue,
                                     title: "External Wallet", subtitle: "MetaMask, TrustWallet",
                                     isOn: $externalWallet)
                        rowDivider()
                        subToggleRow(icon: "person.fill.questionmark", iconColor: .teal,
                                     title: "Guest Checkout", subtitle: "Manual address input",
                                     isOn: $guestCheckout)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 12) {
                         HStack(spacing: 6) {
                            Image(systemName: "bitcoinsign.circle")
                                .foregroundColor(.orange.opacity(0.7))
                            Text("ACCEPTED CRYPTOCURRENCIES")
                                .foregroundColor(Color.white.opacity(0.4))
                                .font(.system(size: 11, weight: .semibold))
                        }

                        // ⚠️ FIXED HERE: Added allCryptoChip before the ForEach loop
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80), spacing: 8)], spacing: 8) {
                            
                            allCryptoChip()  // <--- Added this!
                            
                            ForEach(cryptos, id: \.self) { coin in
                                cryptoChip(coin)
                            }
                        }

                        Text(selectAllCryptos ? "All selected" : "\(selectedCryptos.count) of \(cryptos.count) selected")
                            .foregroundColor(Color.white.opacity(0.25))
                            .font(.system(size: 11))
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.08), lineWidth: 1))
                    .padding(.top, 10)
                }
                .padding(.top, 10)
            }
        }
        .padding(14)
        .background(Color.orange.opacity(0.07))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orange.opacity(0.25), lineWidth: 1.5))
    }

    // MARK: - Action buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("Cancel") { dismiss() }
                .frame(maxWidth: .infinity).frame(height: 52)
                .background(Color.white.opacity(0.06))
                .cornerRadius(26)
                .overlay(RoundedRectangle(cornerRadius: 26).stroke(Color.white.opacity(0.15), lineWidth: 1))
                .foregroundColor(.white.opacity(0.7))

            Button {
                saveProfile()
            } label: {
                if vm.isSaving {
                    ProgressView().tint(.white).frame(maxWidth: .infinity).frame(height: 52)
                } else {
                    Text("Save Profile").frame(maxWidth: .infinity).frame(height: 52)
                }
            }
            .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(26)
            .foregroundColor(.white)
            .disabled(vm.isSaving)
        }
    }
}

// MARK: - Helper components
extension NewPaymentProfileView {

    func sectionHeader(icon: String, title: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon).foregroundColor(color)
            Text(title).foregroundColor(.white).font(.system(size: 15, weight: .bold))
        }
    }

    func inputField(
        label: String,
        placeholder: String,
        text: Binding<String>,
        icon: String,
        required: Bool,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label).foregroundColor(Color.white.opacity(0.4))
                if required { Text("*").foregroundColor(.purple) }
            }
            HStack {
                Image(systemName: icon).foregroundColor(Color.white.opacity(0.25))
                TextField(placeholder, text: text)
                    .foregroundColor(.white)
                    .focused($focusedField, equals: field)
            }
            .padding()
            .background(Color.white.opacity(0.06))
            .cornerRadius(12)
            .contentShape(Rectangle())
            .onTapGesture { focusedField = field }
        }
    }

    /// Mirrors the web's MethodRow toggle — shows a guard toast if the gateway
    /// isn't configured and the user tries to enable it.
    func paymentMethodRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        badge: String?,
        isOn: Binding<Bool>,
        guardConfig: Bool,
        guardMessage: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon).foregroundColor(iconColor)
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(title).foregroundColor(.white).font(.system(size: 13, weight: .semibold))
                    if let badge = badge {
                        Text(badge).font(.system(size: 8, weight: .bold)).foregroundColor(.orange)
                    }
                }
                Text(subtitle).foregroundColor(Color.white.opacity(0.35)).font(.system(size: 12))
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { isOn.wrappedValue },
                set: { newVal in
                    if newVal && !guardConfig && !guardMessage.isEmpty {
                        vm.toast(guardMessage, isError: true)
                    } else {
                        isOn.wrappedValue = newVal
                    }
                }
            ))
            .labelsHidden()
            .tint(iconColor)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(14)
    }

    func subToggleRow(
        icon: String, iconColor: Color,
        title: String, subtitle: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack {
            Image(systemName: icon).foregroundColor(iconColor)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).foregroundColor(.white)
                Text(subtitle).foregroundColor(Color.white.opacity(0.3)).font(.system(size: 11))
            }
            Spacer()
            Toggle("", isOn: isOn).labelsHidden().tint(.purple)
        }
        .padding(.vertical, 10)
    }

    func rowDivider() -> some View {
        Divider().background(Color.white.opacity(0.08))
    }
    func allCryptoChip() -> some View {
         let isAllSelected = selectedCryptos.count == cryptos.count && !cryptos.isEmpty
         return Button {
             if isAllSelected {
                 selectedCryptos.removeAll()
                 selectAllCryptos = false
             } else {
                 selectedCryptos = Set(cryptos)
                 selectAllCryptos = true
             }
         } label: {
             HStack {
                 Image(systemName: isAllSelected ? "checkmark.square.fill" : "square")
                     .font(.system(size: 12))
                     .foregroundColor(isAllSelected ? .orange : .gray)
                 Text("All")
                     .foregroundColor(isAllSelected ? .white : .gray)
             }
             .frame(maxWidth: .infinity).padding(.vertical, 10)
             .background(isAllSelected ? Color.orange.opacity(0.2) : Color.white.opacity(0.05))
             .cornerRadius(10)
         }
         .buttonStyle(.plain)
     }

    func cryptoChip(_ coin: String) -> some View {
        let selected = selectedCryptos.contains(coin)
        return Button {
            if selected {
                selectedCryptos.remove(coin)
                // If we uncheck a single coin, uncheck the "All" button too
                if selectAllCryptos {
                    selectAllCryptos = false
                }
            } else {
                selectedCryptos.insert(coin)
                // If all coins happen to be selected by manual tapping, check "All"
                if selectedCryptos.count == cryptos.count {
                    selectAllCryptos = true
                }
            }
        } label: {
            HStack {
                if selected {
                    Image(systemName: "checkmark").font(.system(size: 9, weight: .bold)).foregroundColor(.orange)
                }
                Text(coin).foregroundColor(selected ? .white : .gray)
            }
            .frame(maxWidth: .infinity).padding(.vertical, 10)
            .background(selected ? Color.orange.opacity(0.2) : Color.white.opacity(0.05))
            .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }
}
struct NewPaymentProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NewPaymentProfileView(vm: PaymentOptionsViewModel())
            .preferredColorScheme(.dark)
    }
}
