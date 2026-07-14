//
//  ExchangeTransferView.swift
//  SettlementWallet
//
//  Shown after getFeesByCurrencyId succeeds when user selects
//  "Transfer to PayBito Wallet".
//
//  Matches the web modal exactly:
//    • Title:    "Withdraw your crypto"
//    • Subtitle: "Transfer balance to PayBito"
//    • Field:    AMOUNT  (min/max from FROMFEE / TOFEE)
//    • Info:     "Minimum of X and maximum Y can be sent."
//    • Buttons:  Transfer (blue)  |  Cancel
//

import SwiftUI

// MARK: - ExchangeTransferView

struct ExchangeTransferView: View {

    @EnvironmentObject private var vm: SettlementViewModel
    @FocusState private var amountFocused: Bool

    @State private var amount: String = ""
    @State private var amountError: String = ""
    @State private var isTransferBtnEnabled: Bool = false

    private let dimBG  = Color(red: 0.09, green: 0.10, blue: 0.16)
    private let cardBG = Color(red: 0.12, green: 0.14, blue: 0.21)
    private let accent = Color(red: 0.22, green: 0.48, blue: 0.92)

    private var fromFee: String { vm.exchangeFromFee }
    private var toFee:   String { vm.exchangeToFee   }

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { amountFocused = false }

            VStack(alignment: .leading, spacing: 0) {

                // ── Header ──
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(accent.opacity(0.18))
                            .frame(width: 40, height: 40)
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(accent)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Withdraw your crypto")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Text("Transfer balance to PayBito")
                            .font(.system(size: 12))
                            .foregroundColor(Color(white: 0.50))
                    }
                    Spacer()
                }
                .padding(.bottom, 20)

                // ── AMOUNT label ──
                Text("AMOUNT")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(white: 0.55))
                    .tracking(0.8)
                    .padding(.bottom, 6)

                // ── Amount input ──
                TextField("Enter amount", text: $amount)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .focused($amountFocused)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(Color(red: 0.08, green: 0.09, blue: 0.14))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                amountError.isEmpty
                                    ? Color(white: 0.20)
                                    : Color.red.opacity(0.6),
                                lineWidth: 1
                            )
                    )
                    .onChange(of: amount) { newVal in
                        validateAmount(newVal)
                    }

                // ── Inline error ──
                if !amountError.isEmpty {
                    Text(amountError)
                        .font(.system(size: 12))
                        .foregroundColor(.red)
                        .padding(.top, 4)
                }

                // ── Info box ──
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 13))
                        .foregroundColor(accent)
                    Text("Minimum of \(fromFee) and maximum \(toFee) can be sent.")
                        .font(.system(size: 13))
                        .foregroundColor(Color(white: 0.75))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(accent.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accent.opacity(0.20), lineWidth: 1)
                )
                .cornerRadius(8)
                .padding(.top, 12)
                .padding(.bottom, 20)

                // ── Buttons ──
                HStack(spacing: 10) {
                    Button(action: handleTransfer) {
                        ZStack {
                            if vm.isSubmittingExchange {
                                ProgressView().tint(.white).scaleEffect(0.85)
                            } else {
                                Text("Transfer")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            isTransferBtnEnabled && !vm.isSubmittingExchange
                                ? accent
                                : accent.opacity(0.40)
                        )
                        .cornerRadius(8)
                    }
                    .disabled(!isTransferBtnEnabled || vm.isSubmittingExchange)

                    Button(action: handleCancel) {
                        Text("Cancel")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color(white: 0.80))
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(white: 0.12))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color(white: 0.22), lineWidth: 1)
                            )
                    }
                    .disabled(vm.isSubmittingExchange)
                }
            }
            .padding(24)
            .background(cardBG)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color(white: 0.15), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.40), radius: 24, x: 0, y: 8)
            .padding(.horizontal, 20)
        }
        .onTapGesture { amountFocused = false }
        .onChange(of: amount) { vm.exchangeTransferAmount = $0 }
        .onAppear {
            if !vm.exchangeTransferAmount.isEmpty {
                amount = vm.exchangeTransferAmount
                validateAmount(amount)
            }
        }
    }

    // MARK: - Validation — mirrors React transferAmt() + onChange

    private func validateAmount(_ raw: String) {
        guard !raw.isEmpty else {
            amountError = ""
            isTransferBtnEnabled = false
            return
        }
        guard let val = Double(raw) else {
            amountError = "Enter a valid number"
            isTransferBtnEnabled = false
            return
        }
        let minAmt = Double(fromFee) ?? 0
        let maxAmt = Double(toFee)   ?? 0

        if maxAmt > 0, val > maxAmt {
            amountError = "Maximum amount is \(toFee)"
            isTransferBtnEnabled = false
        } else if minAmt > 0, val < minAmt {
            amountError = "Minimum amount is \(fromFee)"
            isTransferBtnEnabled = false
        } else {
            amountError = ""
            isTransferBtnEnabled = true
        }
    }

    // MARK: - Actions

    private func handleTransfer() {
        amountFocused = false
        vm.submitExchangeTransfer()
    }

    private func handleCancel() {
        amountFocused = false
        amount = ""
        vm.exchangeTransferAmount = ""
        vm.exchangeTransferAmountError = ""
        vm.showExchangeTransferForm = false
//        vm.selectedWithdrawOption = nil
    }
}

// MARK: - Preview (no inline closure — avoids "Ambiguous use of init()")

#Preview {
    let vm = SettlementViewModel()
    vm.exchangeFeesInfo = CurrencyFeesResponse(
        currency: "ETH",
        minFee: "0.001",
        fromFee: "0.01",
        toFee: "200",
        feeRate: "0.5",
        currencyPrecision: "8",
        error: "0",
        errorMsg: nil
    )
    return ZStack {
        Color(red: 0.07, green: 0.08, blue: 0.13).ignoresSafeArea()
        ExchangeTransferView()
            .environmentObject(vm)
    }
}
