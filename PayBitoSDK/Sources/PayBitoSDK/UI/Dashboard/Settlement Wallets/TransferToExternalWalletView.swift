//
//  TransferToExternalWalletView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 06/05/26.
//
//
//  TransferToExternalWalletView.swift
//  Trading_Terminal
//
//  Static UI — "Transfer BTC to External Wallet" bottom sheet
//  Matches W1A screenshot exactly.
//

import SwiftUI

// MARK: - View

struct TransferToExternalWalletView: View {

    // Pass coin name + code + balance from parent
    var coinName:    String = "BTC"
    var coinCode:    String = "BTC"
    var balance:     String = "0.00047192"
    var onCancel:    () -> Void = {}
    var onTransfer:  (_ address: String, _ amount: String) -> Void = { _, _ in }

    @State private var address = ""
    @State private var amount  = ""
    @FocusState private var focusedField: Field?

    private enum Field { case address, amount }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Dimmed backdrop
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            // Sheet
            VStack(spacing: 0) {

                // ── Drag handle ──
                Capsule()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 22)

                // ── Title ──
                Text("Transfer \(coinCode) to External Wallet")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 6)

                // ── Subtitle: balance ──
                Text("Total available balance \(balance) \(coinCode)")
                    .font(.system(size: 13))
                    .foregroundColor(Color(white: 0.55))
                    .padding(.bottom, 26)

                // ── External Address ──
                VStack(alignment: .leading, spacing: 8) {
                    Text("External Address")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    TextField("", text: $address, prompt:
                        Text("Enter external wallet address")
                            .foregroundColor(Color(white: 0.30))
                    )
                    .focused($focusedField, equals: .address)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.11, green: 0.13, blue: 0.20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        focusedField == .address
                                            ? Color(red: 0.35, green: 0.45, blue: 0.95)
                                            : Color(white: 0.16),
                                        lineWidth: 1.2
                                    )
                            )
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                // ── Amount ──
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    HStack(spacing: 0) {
                        TextField("", text: $amount, prompt:
                            Text("Enter amount")
                                .foregroundColor(Color(white: 0.30))
                        )
                        .focused($focusedField, equals: .amount)
                        .keyboardType(.decimalPad)
                        .autocorrectionDisabled()
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .padding(.leading, 14)
                        .padding(.vertical, 16)

                        // MAX button
                        Button(action: { amount = balance }) {
                            Text("MAX")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.25, green: 0.40, blue: 0.90))
                                )
                        }
                        .padding(.trailing, 10)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.11, green: 0.13, blue: 0.20))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        focusedField == .amount
                                            ? Color(red: 0.35, green: 0.45, blue: 0.95)
                                            : Color(white: 0.16),
                                        lineWidth: 1.2
                                    )
                            )
                    )
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)

                // ── Cancel / Transfer buttons ──
                HStack(spacing: 12) {
                    // Cancel
                    Button(action: onCancel) {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(red: 0.13, green: 0.15, blue: 0.22))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color(white: 0.20), lineWidth: 1)
                                    )
                            )
                    }
                    .buttonStyle(ExternalPressStyle())

                    // Transfer
                    Button(action: { onTransfer(address, amount) }) {
                        Text("Transfer")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.32, green: 0.38, blue: 0.90),
                                        Color(red: 0.42, green: 0.30, blue: 0.85)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(ExternalPressStyle())
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                // ── Info box ──
                VStack(alignment: .leading, spacing: 8) {
                    Text("Minimum of 0.0015 and Maximum 8 can be sent.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.65))

                    Text("For the safety of your assets, please make sure the transfer network is \(coinCode). If the network does not match, your assets will be lost.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.42, green: 0.55, blue: 0.98))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.11, green: 0.13, blue: 0.20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(white: 0.13), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 36)
            }
            .background(
                Color(red: 0.09, green: 0.10, blue: 0.16)
                    .clipShape(
                        UnevenRoundedRectangle(
                            topLeadingRadius: 26,
                            topTrailingRadius: 26
                        )
                    )
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Press Style

private struct ExternalPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.82 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color(red: 0.07, green: 0.08, blue: 0.13).ignoresSafeArea()
        TransferToExternalWalletView(
            coinName: "Bitcoin",
            coinCode: "BTC",
            balance:  "0.00047192"
        )
    }
}
