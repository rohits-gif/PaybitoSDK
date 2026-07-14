//
//  StubViews.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 04/06/26.
//

// StubViews.swift
import SwiftUI

// MARK: - SecurityVerificationMode

enum SecurityVerificationMode {
    case exchangeAuth
    case externalTransfer
}

// MARK: - SecurityVerificationView

struct SecurityVerificationView: View {

    let mode: SecurityVerificationMode
    let onConfirm: () -> Void
    let onDismiss: () -> Void

    @EnvironmentObject var vm: SettlementViewModel

    var body: some View {

        ZStack {

            Color(red: 0.07, green: 0.08, blue: 0.13)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Image(systemName: "lock.fill")
                    .foregroundColor(.white)

                Text("Security Authentication")
                    .font(.headline)
                    .foregroundColor(.white)

                // External wallet requires Email OTP
                if mode == .externalTransfer {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("EMAIL OTP")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField(
                            "Enter OTP",
                            text: $vm.externalEmailOTP
                        )
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)

                        if vm.isExternalOtpTimerActive {

                            Text(
                                "OTP Sent - Resend OTP in \(vm.externalOtpTimerSeconds)s"
                            )
                            .font(.caption)
                            .foregroundColor(.blue)

                        } else {

                            Button("Resend OTP") {
                                Task {
                                    await vm.requestExternalEmailOTP()
                                }
                            }
                            .font(.caption)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {

                    Text("6-DIGIT GOOGLE AUTHENTICATOR CODE")
                        .font(.caption)
                        .foregroundColor(.gray)

                    TextField(
                        "Two-Factor Authenticator Code",
                        text: mode == .exchangeAuth
                            ? $vm.exchangeGoogleAuthCode
                            : $vm.externalGoogleAuthCode
                    )
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                }

                HStack(spacing: 20) {

                    Button("Confirm") {

                        if mode == .exchangeAuth {

                            print("Exchange Google Code =", vm.exchangeGoogleAuthCode)
                            onConfirm()

                        } else {

                            print("OTP =", vm.externalEmailOTP)
                            print("Google =", vm.externalGoogleAuthCode)

                            vm.submitExternalTransfer()
                        }
                    }

                    Button("Cancel") {
                        onDismiss()
                    }
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
    }
}

// MARK: - WithdrawalOptionsModal
struct WithdrawalOptionsModal: View {
    let coinCode: String
    let onSelect: (WithdrawType) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {

            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }

            VStack(spacing: 0) {

                Capsule()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 40, height: 4)
                    .padding(.top, 14)
                    .padding(.bottom, 26)

                Text("Withdraw \(coinCode)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Select where to send your crypto")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 6)
                    .padding(.bottom, 28)

                VStack(spacing: 12) {

                    WithdrawOptionRow(
                        iconName: "building.columns.fill",
                        iconBG: Color(red: 0.16, green: 0.22, blue: 0.45),
                        title: "Transfer to PayBito Wallet",
                        subtitle: "Move funds to your exchange account"
                    ) {
                        onSelect(.exchange)
                    }

                    WithdrawOptionRow(
                        iconName: "arrow.up",
                        iconBG: Color(red: 0.10, green: 0.32, blue: 0.24),
                        title: "Transfer to External Wallet",
                        subtitle: "Withdraw to an external address"
                    ) {
                        onSelect(.external)
                    }

                    WithdrawOptionRow(
                        iconName: "building.columns.fill",
                        iconBG: Color(red: 0.28, green: 0.20, blue: 0.10),
                        title: "Withdraw to Bank Account",
                        subtitle: "Cash out to your bank account"
                    ) {
                        onSelect(.bank)
                    }
                }
                .padding(.horizontal, 16)

                Button(action: onDismiss) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(white: 0.70))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(
                                    Color(red: 0.38, green: 0.30, blue: 0.78),
                                    lineWidth: 1.5
                                )
                        )
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
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
private struct WithdrawOptionRow: View {

    let iconName: String
    let iconBG: Color
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {

        Button(action: action) {

            HStack(spacing: 16) {

                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(iconBG)
                        .frame(width: 52, height: 52)

                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 5) {

                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.21))
            )
        }
    }
}

// MARK: - ExchangeTransferView

//struct ExchangeTransferView: View {
//    @EnvironmentObject var vm: SettlementViewModel
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.07, green: 0.08, blue: 0.13).ignoresSafeArea()
//            Text("Exchange Transfer Form")
//                .foregroundColor(.white)
//        }
//    }
//}

// MARK: - ExternalWithdrawForm

struct ExternalWithdrawForm: View {
    
    @State private var showAddCryptoAddress = false
    @EnvironmentObject var vm: SettlementViewModel
    
    @Environment(\.dismiss) private var dismiss
    private var transferTitle: String {

        guard let asset = vm.selectedAsset else {

            return "Transfer to External Wallet"

        }

        if asset.currencyId == "16" {

            let network = vm.selectedNetwork?.uppercased() ?? ""

            return "Transfer \(asset.currencyCode) \(network) to External Wallet"

        }

        return "Transfer \(asset.currencyCode) to External Wallet"

    }
    private var filteredAddresses: [SavedCryptoAddress] {

        guard let network = vm.selectedNetwork else {
            return vm.savedAddresses
        }

        return vm.savedAddresses.filter { address in
            (address.networkType ?? "").uppercased()
            == network.uppercased()
        }
    }
    @State private var externalAddress = ""
    @State private var amount = ""
    @State private var useSavedAddress = false

    private let darkBG = Color(red: 0.07, green: 0.08, blue: 0.13)
    private let cardBG = Color(red: 0.10, green: 0.12, blue: 0.19)

    var body: some View {

        ZStack {

            darkBG
                .ignoresSafeArea()

            ScrollView {

                VStack(spacing: 20) {

                    Spacer()
                        .frame(height: 40)

                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 28))
                        .foregroundColor(.white)

                    Text(transferTitle)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 20) {

                        Button {
                            useSavedAddress = false
                        } label: {

                            Label(
                                "New Address",
                                systemImage: useSavedAddress ? "circle" : "largecircle.fill.circle"
                            )
                        }

                        Button {
                            useSavedAddress = true
                        } label: {

                            Label(
                                "Saved Address",
                                systemImage: useSavedAddress ? "largecircle.fill.circle" : "circle"
                            )
                        }
                    }
                    .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 8) {

                        Text("EXTERNAL ADDRESS")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if useSavedAddress {

                            if filteredAddresses.isEmpty {

                                Button {

                                    showAddCryptoAddress = true

                                } label: {

                                    HStack {

                                        Image(systemName: "plus.circle.fill")

                                        Text("Add Crypto Address")

                                        Spacer()
                                    }
                                    .padding()
                                    .background(cardBG)
                                    .cornerRadius(12)
                                    .foregroundColor(.white)
                                }

                            } else {

                                Picker(
                                    "Select Saved Address",
                                    selection: $vm.externalAddress
                                ) {

                                    Text("Select a saved address")
                                        .tag("")

                                    ForEach(filteredAddresses) { item in

                                        Text(item.addressName ?? item.bitcoinAddress ?? "")
                                            .tag(item.bitcoinAddress ?? "")
                                    }
                                }
                                .pickerStyle(.menu)
                                .onChange(of: vm.externalAddress) { address in

                                    guard !address.isEmpty else { return }

                                    vm.selectSavedAddress(address)
                                }
                            }
                        } else {

                            TextField(
                                "Enter External Address",
                                text: $vm.externalAddress
                            )
                            .onChange(of: vm.externalAddress) { newValue in

                                vm.onAddressChanged(newValue)
                            }
                            .padding()
                            .background(cardBG)
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        }

                        switch vm.addressValidationState {

                        case .idle:
                            EmptyView()

                        case .valid(let message):
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.green)

                        case .invalid(let message):
                            Text(message)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {

                        Text("AMOUNT")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack {

                            TextField(
                                "0",
                                text: $vm.externalAmount
                            )
                            .keyboardType(.decimalPad)
                            .onChange(of: vm.externalAmount) { value in
                                vm.onExternalAmountChanged(value)
                            }

                            Button("Max") {

                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(cardBG)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    }

                    HStack {

                        Text("Estimated Network Fee")
                            .foregroundColor(.white)

                        Spacer()

                        Text(
                            vm.networkFee.isEmpty
                            ? "--"
                            : vm.networkFee
                        )
                        .foregroundColor(.white)
                    }

                    Text("Minimum 25 and Maximum 10000 can be sent.")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.15))
                        .cornerRadius(10)

                    HStack(alignment: .top) {

                        Image(systemName: "exclamationmark.triangle.fill")

                        Text(
                            "For the safety of your assets, please make sure the transfer network is ERC."
                        )
                    }
                    .font(.footnote)
                    .foregroundColor(.orange)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .cornerRadius(10)

                    HStack(spacing: 12) {

                        Button("Transfer") {

                            vm.proceedToExternalAuth()

                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)

                        Button("Cancel") {
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }

                    Spacer()
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAddCryptoAddress) {

            CryptoAddressView()

        }
    }
}

// MARK: - BankWithdrawForm

struct BankWithdrawForm: View {
    @EnvironmentObject var vm: SettlementViewModel

    var body: some View {
        ZStack {
            Color(red: 0.07, green: 0.08, blue: 0.13).ignoresSafeArea()
            Text("Bank Withdraw Form")
                .foregroundColor(.white)
        }
    }
}

// MARK: - KycStatusModal

struct KycStatusModal: View {

    let onSubmitKYC: () -> Void
    let onDismiss: () -> Void

    var body: some View {

        ZStack {

            Color.black.opacity(0.65)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                VStack(spacing: 16) {

                    Image(systemName: "wallet.pass.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 52, height: 52)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.green.opacity(0.2))
                        )

                    Text("KYC Verification Required")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text("KYC Not Submitted")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)

                    Text("Please complete your KYC verification before initiating a bank withdrawal.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 28)

                HStack(spacing: 12) {

                    Button {
                        onSubmitKYC()
                    } label: {
                        Text("Submit KYC")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue)
                            )
                    }

                    Button {
                        onDismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.25))
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 24)

            }
            .frame(maxWidth: 380)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(Color(red: 0.06, green: 0.07, blue: 0.12))
            )
            .padding(.horizontal, 24)
        }
    }
}

