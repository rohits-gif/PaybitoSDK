// MARK: - PaymentSettingsView  (root screen)

import SwiftUI

struct PaymentSettingsView: View {
    @StateObject private var vm = PaymentSettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            PSColor.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {

                    // ── Custom Nav Bar (fullScreenCover has no navbar) ──
                    HStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            HStack(spacing: 5) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Back")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(PSColor.accent)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 4)

                    // ── Page Header ───────────────────────────
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Payment Setup")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(PSColor.textPrimary)
                        Text("Manage payment gateway credentials and API keys")
                            .font(.system(size: 13))
                            .foregroundColor(PSColor.textSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                    if vm.isLoading {
                        loadingView
                    } else if let err = vm.errorMessage {
                        errorView(err)
                    } else {
                        SectionDivider(label: "Gateway Credentials")
                            .padding(.horizontal, 20)
                            .padding(.bottom, 16)

                        StripeCardView(vm: vm.stripeVM)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        PayPalCardView(vm: vm.paypalVM)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        SecretV4GatewayCardView(
                            vm: vm.kurvPayVM,
                            accentColor: Color(red: 0.051, green: 0.580, blue: 0.533), // #0D9488
                            portalName: "PayBito Nexus Merchant Portal"
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                        SecretV4GatewayCardView(
                            vm: vm.hmsVM,
                            accentColor: Color(red: 0.051, green: 0.580, blue: 0.533),
                            portalName: "PayBito Nova Merchant Portal"
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                        SecretV4GatewayCardView(
                            vm: vm.nmiVM,
                            accentColor: Color(red: 0.051, green: 0.580, blue: 0.533),
                            portalName: "PayBito Zenith Merchant Portal"
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)

                        NetBillingCardView(vm: vm.netBillingVM)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)

                        CardFloCardView(vm: vm.cardFloVM)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 40)
                    }
                }
            }

            // ── Toast overlays ────────────────────────────
            VStack(spacing: 8) {
                toastLayer(vm.stripeVM.toastMessage, vm.stripeVM.toastIsError)
                toastLayer(vm.paypalVM.toastMessage, vm.paypalVM.toastIsError)
                toastLayer(vm.kurvPayVM.toastMessage, vm.kurvPayVM.toastIsError)
                toastLayer(vm.hmsVM.toastMessage, vm.hmsVM.toastIsError)
                toastLayer(vm.nmiVM.toastMessage, vm.nmiVM.toastIsError)
                toastLayer(vm.netBillingVM.toastMessage, vm.netBillingVM.toastIsError)
                toastLayer(vm.cardFloVM.toastMessage, vm.cardFloVM.toastIsError)
            }
            .padding(.bottom, 24)
            .animation(.easeInOut(duration: 0.3), value: vm.stripeVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: vm.paypalVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: vm.kurvPayVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: vm.hmsVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: vm.nmiVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: vm.netBillingVM.toastMessage)
            .animation(.easeInOut(duration: 0.3), value: vm.cardFloVM.toastMessage)
        }
        .navigationBarHidden(true)   // hide any pushed nav bar
        .preferredColorScheme(.dark)
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: PSColor.accent))
                .scaleEffect(1.4)
            Text("Loading Payment Setup…")
                .font(.system(size: 13))
                .foregroundColor(PSColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(PSColor.danger)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(PSColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button("Retry") { vm.fetchGateways() }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(PSColor.accent)
                .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    @ViewBuilder
    private func toastLayer(_ message: String?, _ isError: Bool) -> some View {
        if let msg = message {
            PSToastView(message: msg, isError: isError)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.horizontal, 20)
        }
    }
}

struct PaymentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentSettingsView()
            .preferredColorScheme(.dark)
    }
}
