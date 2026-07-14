//
//  ChoosePlatformView.swift
//  Trading_Terminal
//
//  SwiftUI conversion of ChoosePlatformViewController.swift
//  Payment    → LoginView (SwiftUI — BillBitcoins / Payments)
//  Financial  → LoginView (SwiftUI — swap for your trading login if needed)
//

import SwiftUI
import PayBitoSDK

// MARK: - ChoosePlatformView

struct ChoosePlatformView: View {

    @Environment(\.dismiss) private var dismiss

    @State private var goToPayments  = false
    @State private var goToFinancial = false

    private let purpleAccent = Color(red: 0.42, green: 0.35, blue: 0.95)
    private let darkBG       = Color(red: 0.05, green: 0.07, blue: 0.12)
    private let cardBG       = Color(red: 0.10, green: 0.13, blue: 0.20)

    var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── Back button ───────────────────────────────────────
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
Spacer()
                // ── Logo ──────────────────────────────────────────────
//                Image("TC")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 90, height: 90)
//                    .background(Color.white)
//                    .clipShape(RoundedRectangle(cornerRadius: 20))
//                    .padding(.top, 24)

                // ── Title + subtitle ──────────────────────────────────
                Text("Choose Your Platform")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)

                Text("Select the platform you'd like to use")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 24)

                // ── Platform cards ────────────────────────────────────
                VStack(spacing: 48) {
                    platformCard(
                        icon:     "wallet.pass.fill",
                        title:    "Payment",
                        subtitle: "Digital payment solutions"
                    ) {
                        goToPayments = true
                    }

                   
                }
                .padding(.horizontal, 24)
                .padding(.top, 48)

                Spacer()
            }
        }
        .navigationBarHidden(true)

        // ── Payment → LoginView (Payments / BillBitcoins) ─────────────
        .fullScreenCover(isPresented: $goToPayments) {
            PayBito.loginView()
        }

        // ── Financial → trading login ─────────────────────────────────
        // Swap LoginView() here for your SwiftUI trading login view
        // once it's ready (e.g. TradingLoginView()).
        .fullScreenCover(isPresented: $goToFinancial) {
            PayBito.loginView()
        }
    }

    // MARK: - Card builder

    private func platformCard(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {

                ZStack {
                    Circle()
                        .fill(purpleAccent.opacity(0.2))
                        .frame(width: 56, height: 56)
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                        .foregroundColor(purpleAccent)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.55))
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundColor(purpleAccent)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(height: 88)
            .background(cardBG)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(purpleAccent.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview { ChoosePlatformView() }
