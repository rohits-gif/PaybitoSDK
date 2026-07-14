//
//  Autowithdrawalview.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 10/06/26.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - Main View
struct AutoWithdrawalView: View {
    @StateObject private var vm = AutoWithdrawalViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.awBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    pageHeader
                    infoBanner
                    step1ChooseAssets
                    step2ChooseDestination
                    steps3And4
                    saveButton
                    rulesSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }

            // FAB
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button { vm.submit() } label: {
//                        Image(systemName: "plus")
//                            .font(.system(size: 22, weight: .bold))
//                            .foregroundColor(.white)
//                            .frame(width: 56, height: 56)
//                            .background(Color.accentColor)
//                            .clipShape(RoundedRectangle(cornerRadius: 16))
//                            .shadow(color: Color.accentColor.opacity(0.4), radius: 8, y: 4)
//                    }
//                    .padding(.trailing, 20)
//                    .padding(.bottom, 20)
//                }
//            }
        }
        .navigationBarHidden(true)
        .onAppear { vm.loadCoins(); vm.loadRules() }
        // Modals
        .sheet(isPresented: $vm.showCryptoAddrModal) { cryptoAddrModal }
        .sheet(isPresented: $vm.showBankModal) { bankModal }
        .sheet(item: $vm.ruleToDelete) { rule in deleteConfirmModal(rule: rule) }
        .sheet(item: $vm.ruleToEdit) { _ in editModal }
        .overlay(toastOverlay, alignment: .top)
    }

    // MARK: - Page Header
    private var pageHeader: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "arrow.2.circlepath")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 20))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Automatic Withdrawal")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.awText)
                Text("Configure automated withdrawal rules for your assets")
                    .font(.system(size: 12))
                    .foregroundColor(Color.awText.opacity(0.55))
//                Button {
//                    dismiss()
//                } label: {
//                    HStack(spacing: 4) {
//                        Image(systemName: "arrow.left")
//                            .font(.system(size: 12, weight: .semibold))
//                        Text("Go back to settlement wallet")
//                            .font(.system(size: 12, weight: .semibold))
//                    }
//                    .foregroundColor(.accentColor)
//                }
                .padding(.top, 2)
            }
            Spacer()
        }
    }

    // MARK: - Info Banner
    private var infoBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle")
                .foregroundColor(.accentColor)
                .font(.system(size: 18))
            Text("Merchant needs to turn automatic withdrawals on. Otherwise withdrawals are as it is now, manual.")
                .font(.system(size: 13))
                .foregroundColor(Color.awText)
                .lineSpacing(3)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.accentColor.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.accentColor.opacity(0.22), lineWidth: 1)
        )
        .cornerRadius(12)
    }

    // MARK: - Step 1
    private var step1ChooseAssets: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepLabel("Step 1")
            Text("Choose Assets")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.awText)
                .padding(.bottom, 2)
            Text("Select one or more cryptocurrencies for automatic withdrawal")
                .font(.system(size: 12))
                .foregroundColor(Color.awText.opacity(0.5))
                .padding(.bottom, 16)

            if vm.coinsLoading {
                HStack { Spacer(); ProgressView().padding(24); Spacer() }
            } else if vm.coins.isEmpty {
                Text("No assets available.")
                    .font(.system(size: 13))
                    .foregroundColor(Color.awText.opacity(0.5))
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                    ForEach(vm.coins) { coin in
                        CoinCard(
                            coin: coin,
                            isSelected: vm.selectedCoins.contains(coin.currencyCode)
                        ) {
                            vm.toggleCoin(coin.currencyCode)
                        }
                    }
                }
            }

            if let err = vm.formErrors.coins {
                errorText(err)
            }
        }
        .padding(20)
        .background(Color.awCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.awBorder, lineWidth: 1))
    }

    // MARK: - Step 2
    private var step2ChooseDestination: some View {
        VStack(alignment: .leading, spacing: 0) {
            stepLabel("Step 2")
            Text("Choose Destination")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.awText)
                .padding(.bottom, 2)
            Text("Select where the crypto will be sent")
                .font(.system(size: 12))
                .foregroundColor(Color.awText.opacity(0.5))
                .padding(.bottom, 16)

            VStack(spacing: 10) {
                ForEach(AutoWithdrawal.Destination.allCases, id: \.rawValue) { dest in
                    DestinationRow(
                        dest: dest,
                        isSelected: vm.destination == dest,
                        isDisabled: vm.destChecking
                    ) {
                        if !vm.destChecking { vm.changeDestination(dest) }
                    }
                }
            }

            if vm.destChecking {
                HStack(spacing: 8) {
                    ProgressView().scaleEffect(0.8)
                    Text("Verifying destination requirements...")
                        .font(.system(size: 12))
                        .foregroundColor(Color.awText.opacity(0.6))
                }
                .padding(.top, 12)
            }

            if vm.destination == .bankAccount && vm.bankStatus == .verified && !vm.destChecking {
                bankVerifiedBadge
                    .padding(.top, 14)
            }

            if vm.destination == .externalWallet && !vm.resolvedAddresses.isEmpty && !vm.destChecking {
                AddressesFoundView(addresses: vm.resolvedAddresses)
                    .padding(.top, 14)
            }
        }
        .padding(20)
        .background(Color.awCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.awBorder, lineWidth: 1))
    }

    // MARK: - Steps 3 & 4
    private var steps3And4: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Amount
            VStack(alignment: .leading, spacing: 0) {
                stepLabel("Step 3")
                Text("Withdrawal Amount")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.awText)
                    .padding(.bottom, 2)
                Text("Trigger withdrawal when balance reaches this amount")
                    .font(.system(size: 12))
                    .foregroundColor(Color.awText.opacity(0.5))
                    .padding(.bottom, 12)

                AmountField(value: $vm.amount, prefix: "$", placeholder: "100",
                            keyboardType: .decimalPad) { val in
                    vm.formErrors.amount = vm.validateAmount(val)
                }

                Text("Min: $100 · Max: 12 digits · Up to 6 decimal places")
                    .font(.system(size: 11))
                    .foregroundColor(Color.awText.opacity(0.45))
                    .padding(.top, 6)
                if let err = vm.formErrors.amount { errorText(err) }
            }
            .padding(.bottom, 24)

            // Frequency
            VStack(alignment: .leading, spacing: 0) {
                stepLabel("Step 4")
                Text("Withdrawal Frequency")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color.awText)
                    .padding(.bottom, 2)
                Text("How often the automatic withdrawal should run")
                    .font(.system(size: 12))
                    .foregroundColor(Color.awText.opacity(0.5))
                    .padding(.bottom, 12)

                FrequencyField(value: $vm.frequency) { val in
                    vm.formErrors.frequency = vm.validateFrequency(val)
                }

                Text("Min: 7 days · Max: 999 days · Whole numbers only")
                    .font(.system(size: 11))
                    .foregroundColor(Color.awText.opacity(0.45))
                    .padding(.top, 6)
                if let err = vm.formErrors.frequency { errorText(err) }
            }
        }
        .padding(20)
        .background(Color.awCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.awBorder, lineWidth: 1))
    }

    // MARK: - Save Button
    private var saveButton: some View {
        let disabled = vm.submitting || vm.hasAddrError || vm.hasBankError
        return Button(action: vm.submit) {
            HStack(spacing: 8) {
                if vm.submitting {
                    ProgressView().tint(.white).scaleEffect(0.85)
                    Text("Saving...")
                } else {
                    Image(systemName: "checkmark.circle")
                    Text("Save Automatic Withdrawal Rule")
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Color.accentColor.opacity(disabled ? 0.5 : 1))
            .cornerRadius(14)
        }
        .disabled(disabled)
    }

    // MARK: - Rules Section
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.purple.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.2.circlepath")
                        .foregroundColor(.purple)
                        .font(.system(size: 16))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Automate Withdrawals Configurations")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.awText)
                    Text("Your configured auto-withdrawal rules")
                        .font(.system(size: 12))
                        .foregroundColor(Color.awText.opacity(0.5))
                }
                Spacer()
            }
            .padding(.bottom, 16)

            Divider().background(Color.awBorder)

            if vm.rulesLoading {
                HStack { Spacer(); ProgressView().padding(40); Spacer() }
            } else if vm.rules.isEmpty {
                emptyState
            } else {
                VStack(spacing: 12) {
                    ForEach(vm.rules) { rule in
                        RuleCard(rule: rule,
                                 onEdit: { vm.openEdit(rule) },
                                 onDelete: { vm.ruleToDelete = rule })
                    }
                }
                .padding(.top, 12)
            }
        }
        .padding(20)
        .background(Color.awCard)
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.awBorder, lineWidth: 1))
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "arrow.2.circlepath")
                .font(.system(size: 38))
                .foregroundColor(Color.awText.opacity(0.2))
            Text("No rules configured")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.awText.opacity(0.4))
            Text("Save a rule above to see it listed here.")
                .font(.system(size: 12))
                .foregroundColor(Color.awText.opacity(0.3))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Bank Verified Badge
    private var bankVerifiedBadge: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(hex: "#10b981"))
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 2) {
                Text("BANK VERIFIED")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
                    .foregroundColor(Color(hex: "#10b981"))
                Text("Your bank account has been verified and is ready for withdrawals.")
                    .font(.system(size: 12))
                    .foregroundColor(Color.awText.opacity(0.65))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(hex: "#10b981").opacity(0.08))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke((Color(hex: "#10b981") ?? .green).opacity(0.25), lineWidth: 1))
        .cornerRadius(12)
    }

    // MARK: - Modals
    private var cryptoAddrModal: some View {
        AWAlertSheet(
            icon: "wallet.pass",
            iconColor: Color(hex: "#f59e0b") ?? .orange,
            title: "Crypto Address Required",
            headline: "No Crypto Address Found",
            message: "You need to add a crypto address for the selected currency before setting up an external wallet withdrawal. Please add it in the Add Crypto Address section first.",
            primaryLabel: "Add Crypto Address",
            primaryIcon: "plus.circle",
            onCancel: { vm.cancelCryptoAddrModal() },
            onPrimary: {
                vm.cancelCryptoAddrModal()
                // navigate to crypto-address screen via NavigationStack
            }
        )
    }

    private var bankModal: some View {
        let (title, headline, message, icon, label) = bankModalContent(status: vm.bankModalStatus)
        return AWAlertSheet(
            icon: "building.columns",
            iconColor: Color(hex: "#f59e0b") ?? .orange,
            title: title, headline: headline, message: message,
            primaryLabel: label, primaryIcon: icon,
            onCancel: { vm.showBankModal = false },
            onPrimary: {
                vm.showBankModal = false
                // navigate to bank-info screen
            }
        )
    }

    private func deleteConfirmModal(rule: AutoWithdrawal.Rule) -> some View {
        let currencies = rule.currencies.map(\.currency).joined(separator: ", ")
        let dest = AutoWithdrawal.Destination(rawValue: rule.withdrawType)?.label ?? rule.withdrawType
        let msg = "This will permanently remove the rule for \(currencies) — \(dest), $\(String(format: "%.2f", rule.amountInUsd)) every \(rule.frequencyInDays) days."

        return AWAlertSheet(
            icon: "trash",
            iconColor: Color(hex: "#f59e0b") ?? .orange,
            title: "Delete Rule",
            headline: "Delete this auto-withdrawal rule?",
            message: msg,
            primaryLabel: vm.deleteSubmitting ? "Deleting..." : "Delete Rule",
            primaryIcon: "trash",
            primaryDanger: true,
            onCancel: { if !vm.deleteSubmitting { vm.ruleToDelete = nil } },
            onPrimary: { vm.deleteRule() }
        )
    }

    private var editModal: some View {
        AutoWithdrawalEditSheet(vm: vm)
    }

    // MARK: - Toast
    @ViewBuilder
    private var toastOverlay: some View {
        if let toast = vm.toastMessage {
            ToastView(message: toast.message, isSuccess: toast.style == .success)
                .padding(.top, 50)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        vm.toastMessage = nil
                    }
                }
        }
    }

    // MARK: - Helpers
    private func stepLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .tracking(1)
            .foregroundColor(.accentColor)
            .padding(.bottom, 4)
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(Color(hex: "#ef4444"))
            .padding(.top, 5)
    }

    private func bankModalContent(status: Int?) -> (String, String, String, String, String) {
        switch status {
        case 0: return ("Bank Account Pending", "Bank Details Not Verified Yet",
                         "Your bank details have been submitted and are currently under review. Please wait for verification.",
                         "building.columns", "View Bank Details")
        case 3: return ("Bank Account Rejected", "Bank Details Rejected",
                         "Your bank details submission was rejected. Please resubmit with correct information.",
                         "arrow.counterclockwise", "Resubmit Bank Details")
        default: return ("Bank Account Required", "Bank Details Not Submitted",
                          "You haven't submitted your bank details yet. Please add your bank account before setting up a bank account withdrawal.",
                          "plus", "Add Bank Details")
        }
    }
}
