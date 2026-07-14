// MARK: - PaymentOptionsView.swift

import SwiftUI

struct PaymentOptionsView: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var vm: PaymentOptionsViewModel
    @State private var showForm = false
    @State private var editProfile: BillingProfile.Profile? = nil
    @State private var deleteConfirmId: Int? = nil
    @State private var showDeleteConfirm = false

    init(vm: PaymentOptionsViewModel = PaymentOptionsViewModel()) {
        self.vm = vm
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.06, green: 0.07, blue: 0.10).ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    .padding(.bottom, 16)

                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(.white).scaleEffect(1.5)
                    Spacer()
                } else if vm.profiles.isEmpty {
                    emptyState
                } else {
                    profileList
                }
            }

            // FAB
            if !vm.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button { showForm = true; editProfile = nil } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.white)
                                .font(.system(size: 24, weight: .bold))
                                .frame(width: 60, height: 60)
                                .background(Color.blue)
                                .cornerRadius(18)
                                .shadow(color: Color.blue.opacity(0.5), radius: 12)
                        }
                        .padding(20)
                    }
                }
            }

            // Toast
            if let msg = vm.toastMessage { toastBanner(msg) }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { vm.loadAll() }
        .fullScreenCover(isPresented: $showForm) {
            NewPaymentProfileView(vm: vm, editingProfile: editProfile)
        }
        .confirmationDialog("Delete Profile", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let id = deleteConfirmId { vm.deleteProfile(id: id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Header
    var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button { dismiss() } label: {
                ZStack {
                    Circle().fill(Color.white.opacity(0.08)).frame(width: 38, height: 38)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Payment Options")
                    .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Text("Configure payment methods for checkout")
                    .font(.system(size: 13)).foregroundColor(.white.opacity(0.55))
            }
            Spacer()
            Button {
                editProfile = nil
                showForm = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add Profile")
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                .cornerRadius(20)
            }
        }
    }

    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 16).fill(Color.purple.opacity(0.12)).frame(width: 72, height: 72)
                Image(systemName: "creditcard").font(.system(size: 32)).foregroundColor(.purple)
            }
            Text("No payment profiles yet")
                .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
            Text("Add a profile to configure payment methods\navailable at checkout")
                .font(.system(size: 14)).foregroundColor(.white.opacity(0.45))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Profile List
    var profileList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(vm.profiles) { profile in profileCard(profile) }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Profile Card
    func profileCard(_ profile: BillingProfile.Profile) -> some View {
        let isDeleting      = vm.deletingId == profile.id
        let isMakingDefault = vm.makingDefaultId == profile.id

        return VStack(alignment: .leading, spacing: 0) {

            // Card header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.15)).frame(width: 38, height: 38)
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16)).foregroundColor(.purple)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(profile.name)
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        if profile.isDefault { defaultBadge }
                    }
                }
                Spacer()
            }
            .padding(16)

            Divider().background(Color.white.opacity(0.08))

            // Methods
            VStack(alignment: .leading, spacing: 10) {
                Text("PAYMENT METHODS")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(0.8)

                // Chips for every enabled gateway
                FlexWrapView(tags: enabledMethodChips(for: profile))

                if profile.cryptoEnabled {
                    VStack(alignment: .leading, spacing: 6) {
                        if profile.brandWallet {
                            subMethodRow(icon: "wallet.pass.fill", color: .purple, label: "Brand Wallet")
                        }
                        if profile.externalWalletEnabled {
                            subMethodRow(icon: "link.circle.fill", color: .blue,
                                         label: "External Wallet (MetaMask, TronLink, TrustWallet)")
                        }
                        if profile.guestCheckout {
                            subMethodRow(icon: "person.fill.questionmark", color: .teal, label: "Guest Checkout")
                        }

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 60), spacing: 6)], spacing: 6) {
                            ForEach(profile.selectedCryptoCodes, id: \.self) { code in
                                Text(code)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Color(red: 0.96, green: 0.62, blue: 0.04))
                                    .padding(.horizontal, 8).padding(.vertical, 4)
                                    .background(Color(red: 0.96, green: 0.62, blue: 0.04).opacity(0.12))
                                    .cornerRadius(6)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 14)

            Divider().background(Color.white.opacity(0.08))

            // Actions
            HStack(spacing: 8) {
                if !profile.isDefault {
                    Button {
                        vm.markAsDefault(id: profile.id)
                    } label: {
                        HStack(spacing: 5) {
                            if isMakingDefault {
                                ProgressView().tint(.purple).scaleEffect(0.7)
                            } else {
                                Image(systemName: "star").font(.system(size: 11))
                            }
                            Text("Make Default").font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(.purple)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(Color.purple.opacity(0.08))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.purple.opacity(0.25), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .disabled(isMakingDefault || isDeleting)
                }

                Button {
                    editProfile = profile
                    showForm = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil").font(.system(size: 11))
                        Text("Edit").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)

                Spacer()

                Button {
                    deleteConfirmId  = profile.id
                    showDeleteConfirm = true
                } label: {
                    Group {
                        if isDeleting {
                            ProgressView().tint(.red).scaleEffect(0.8)
                        } else {
                            Image(systemName: "trash").font(.system(size: 14)).foregroundColor(.red)
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.11, green: 0.13, blue: 0.19))
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(profile.isDefault ? Color.purple.opacity(0.4) : Color.white.opacity(0.08), lineWidth: 1.5))
        )
        .opacity(isDeleting ? 0.6 : 1)
        .animation(.easeInOut(duration: 0.2), value: isDeleting)
    }

    // MARK: - Enabled method chips — one per active gateway
    private func enabledMethodChips(for p: BillingProfile.Profile) -> [(label: String, color: Color, icon: String)] {
        var chips: [(label: String, color: Color, icon: String)] = []
        if p.stripeEnabled     { chips.append(("Pay with Card",      Color(red: 0.39, green: 0.36, blue: 1.0),   "creditcard")) }
        if p.paypalEnabled     { chips.append(("PayBito Titan",      Color(red: 0.0, green: 0.19, blue: 0.53),   "p.circle.fill")) }
        if p.kurvPayEnabled    { chips.append(("PayBito Nexus",      Color(red: 0.05, green: 0.58, blue: 0.53),  "bolt.fill")) }
        if p.netbillingEnabled { chips.append(("PayBito Vertex",     Color(red: 0.06, green: 0.65, blue: 0.91),  "creditcard.fill")) }
        if p.hmsEnabled        { chips.append(("PayBito Nova",       Color(red: 0.39, green: 0.40, blue: 0.95),  "building.columns")) }
        if p.nmiEnabled        { chips.append(("PayBito Zenith",     Color(red: 0.49, green: 0.23, blue: 0.93),  "bolt.fill")) }
        if p.cardFloEnabled    { chips.append(("PayBito Sovereign",  Color(red: 0.31, green: 0.27, blue: 0.90),  "creditcard.fill")) }
        if p.cryptoEnabled     { chips.append(("Crypto",             Color(red: 0.96, green: 0.62, blue: 0.04),  "bitcoinsign.circle.fill")) }
        return chips
    }

    // MARK: - Helpers
    var defaultBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
            Text("Default").font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(.purple)
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(Color.purple.opacity(0.12))
        .cornerRadius(20)
    }

    func subMethodRow(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 11)).foregroundColor(color)
            Text(label).font(.system(size: 11)).foregroundColor(.white.opacity(0.55))
        }
    }

    func toastBanner(_ msg: String) -> some View {
        let borderColor = vm.toastIsError ? Color.red.opacity(0.4) : Color.green.opacity(0.4)
        let iconName    = vm.toastIsError ? "xmark.circle.fill" : "checkmark.circle.fill"
        let iconColor   = vm.toastIsError ? Color.red : Color.green

        return HStack(spacing: 10) {
            Image(systemName: iconName).foregroundColor(iconColor)
            Text(msg).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
            Spacer()
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(red: 0.12, green: 0.14, blue: 0.20)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { self.vm.toastMessage = nil }
        }
    }
}

// MARK: - FlexWrapView — wraps gateway chips without overflow
// Simple alternative to a LazyVGrid so chips wrap naturally like the web's flex-wrap.
struct FlexWrapView: View {
    let tags: [(label: String, color: Color, icon: String)]

    var body: some View {
        if tags.isEmpty {
            Text("None enabled")
                .font(.system(size: 12)).foregroundColor(.white.opacity(0.3))
        } else {
            VStack(alignment: .leading, spacing: 6) {
                // Simple two-column grid — adjust columns if needed
                let columns = [GridItem(.adaptive(minimum: 130), spacing: 8)]
                LazyVGrid(columns: columns, alignment: .leading, spacing: 6) {
                    ForEach(tags, id: \.label) { chip in
                        HStack(spacing: 5) {
                            Image(systemName: chip.icon)
                                .font(.system(size: 11))
                                .foregroundColor(chip.color)
                            Text(chip.label)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(chip.color)
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(chip.color.opacity(0.12))
                        .cornerRadius(20)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(chip.color.opacity(0.25), lineWidth: 1))
                    }
                }
            }
        }
    }
}
