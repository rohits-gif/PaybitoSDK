//
//  AutoWithdrawalComponents.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 10/06/26.
//

//
//  AutoWithdrawalComponents.swift
//  PaymentsTerminsl
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - CoinCard
struct CoinCard: View {
    let coin: AutoWithdrawal.Coin
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                WebImage(url: URL(string: coin.logo))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2))

                Text(coin.currencyCode)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.awText)
                    .lineLimit(1)

                Text(coin.currencyName)
                    .font(.system(size: 10))
                    .foregroundColor(Color.awText.opacity(0.5))
                    .lineLimit(1)
            }
            .padding(10)
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.accentColor.opacity(0.12) : Color.awCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.awBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - DestinationRow
struct DestinationRow: View {
    let dest: AutoWithdrawal.Destination
    let isSelected: Bool
    let isDisabled: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.awBorder.opacity(0.3))
                        .frame(width: 40, height: 40)
                    Image(systemName: dest.icon)
                        .foregroundColor(isSelected ? .accentColor : Color.awText.opacity(0.5))
                        .font(.system(size: 18))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(dest.label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.awText)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.system(size: 20))
                } else {
                    Circle()
                        .stroke(Color.awBorder, lineWidth: 1.5)
                        .frame(width: 20, height: 20)
                }
            }
            .padding(14)
            .background(isSelected ? Color.accentColor.opacity(0.06) : Color.awCard)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor.opacity(0.4) :Color.awBorder, lineWidth: 1)
            )
            .opacity(isDisabled ? 0.6 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}

// MARK: - AddressesFoundView
struct AddressesFoundView: View {
    let addresses: [AutoWithdrawal.ResolvedAddress]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(Color(hex: "#10b981"))
                Text("Addresses Found")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "#10b981"))
            }
            ForEach(addresses) { addr in
                HStack(spacing: 10) {
                    WebImage(url: URL(string: addr.logo))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .clipShape(Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(addr.name)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.awText)
                        Text(addr.address)
                            .font(.system(size: 10).monospaced())
                            .foregroundColor(Color.awText.opacity(0.5))
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                }
                .padding(10)
                .background(Color(hex: "#10b981").opacity(0.06))
                .cornerRadius(10)
//                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(hex: "#10b981").opacity(0.2), lineWidth: 1))
            }
        }
    }
}

// MARK: - AmountField
struct AmountField: View {
    @Binding var value: String
    let prefix: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .decimalPad
    let onChanged: (String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(prefix)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.awText.opacity(0.6))
            TextField(placeholder, text: $value)
                .keyboardType(keyboardType)
                .font(.system(size: 15))
                .foregroundColor(Color.awText)
                .onChange(of: value) { onChanged($0) }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.awBorder.opacity(0.3))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke((Color(hex: "#10b981") ?? .green).opacity(0.25), lineWidth: 1))
    }
}

// MARK: - FrequencyField
struct FrequencyField: View {
    @Binding var value: String
    let onChanged: (String) -> Void

    var body: some View {
        HStack(spacing: 10) {
            TextField("7", text: $value)
                .keyboardType(.numberPad)
                .font(.system(size: 15))
                .foregroundColor(Color.awText)
                .onChange(of: value) { onChanged($0) }
            Text("days")
                .font(.system(size: 14))
                .foregroundColor(Color.awText.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 13)
        .background(Color.awBorder.opacity(0.3))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke((Color(hex: "#10b981") ?? .green).opacity(0.25), lineWidth: 1))
    }
}

// MARK: - RuleCard
struct RuleCard: View {
    let rule: AutoWithdrawal.Rule
    let onEdit: () -> Void
    let onDelete: () -> Void

    private let accent = Color(red: 0.55, green: 0.35, blue: 0.95)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: rule.destination.icon)
                        .font(.system(size: 13))
                        .foregroundColor(accent)
                    Text(rule.destination.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.awText)
                }
                Spacer()
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accent)
                            .padding(8)
                            .background(accent.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#ef4444"))
                            .padding(8)
                            .background(Color(hex: "#ef4444").opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }

            HStack(spacing: 16) {
                Label("$\(String(format: "%.2f", rule.amountInUsd))", systemImage: "dollarsign.circle")
                    .font(.system(size: 12))
                    .foregroundColor(Color.awText.opacity(0.7))
                Label("Every \(rule.frequencyInDays)d", systemImage: "calendar")
                    .font(.system(size: 12))
                    .foregroundColor(Color.awText.opacity(0.7))
            }

            if !rule.currencies.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(rule.currencies) { cur in
                            Text(cur.currency)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(accent)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(accent.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.awCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.awBorder, lineWidth: 1))
    }
}

// MARK: - AWAlertSheet
struct AWAlertSheet: View {
    let icon: String
    let iconColor: Color
    let title: String
    let headline: String
    let message: String
    let primaryLabel: String
    let primaryIcon: String
    var primaryDanger: Bool = false
    let onCancel: () -> Void
    let onPrimary: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color(white: 0.3))
                .frame(width: 36, height: 4)
                .padding(.top, 12)
                .padding(.bottom, 20)

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 26))
            }
            .padding(.bottom, 16)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundColor(iconColor)
                .padding(.bottom, 6)

            Text(headline)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.awText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10)

            Text(message)
                .font(.system(size: 13))
                .foregroundColor(Color.awText.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 20)
                .padding(.bottom, 28)

            VStack(spacing: 10) {
                Button(action: onPrimary) {
                    HStack(spacing: 8) {
                        Image(systemName: primaryIcon)
                        Text(primaryLabel)
                    }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(primaryDanger ? Color(hex: "#ef4444") : Color.accentColor)
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)

                Button("Cancel", action: onCancel)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color.awText.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.awBorder.opacity(0.3))
                    .cornerRadius(14)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
        }
        .background(Color.awCard)
    }
}

// MARK: - AutoWithdrawalEditSheet
struct AutoWithdrawalEditSheet: View {
    @ObservedObject var vm: AutoWithdrawalViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Coins
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Edit Assets")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.awText)
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                            ForEach(vm.coins) { coin in
                                CoinCard(
                                    coin: coin,
                                    isSelected: vm.editCoins.contains(coin.currencyCode)
                                ) { vm.toggleEditCoin(coin.currencyCode) }
                            }
                        }
                        if let err = vm.editFormErrors.coins { errorText(err) }
                    }
                    .padding(20)
                    .background(Color.awCard)
                    .cornerRadius(16)

                    // Destination
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Destination")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.awText)
                        ForEach(AutoWithdrawal.Destination.allCases, id: \.rawValue) { dest in
                            DestinationRow(
                                dest: dest,
                                isSelected: vm.editDest == dest,
                                isDisabled: vm.editDestChecking
                            ) { if !vm.editDestChecking { vm.changeEditDestination(dest) } }
                        }
                        if vm.editDestChecking {
                            HStack(spacing: 8) {
                                ProgressView().scaleEffect(0.8)
                                Text("Verifying...").font(.system(size: 12)).foregroundColor(Color.awText.opacity(0.6))
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.awCard)
                    .cornerRadius(16)

                    // Amount + Frequency
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Amount (USD)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.awText)
                            AmountField(value: $vm.editAmount, prefix: "$", placeholder: "100",
                                        keyboardType: .decimalPad) { val in
                                vm.editFormErrors.amount = vm.validateAmount(val)
                            }
                            if let err = vm.editFormErrors.amount { errorText(err) }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Frequency")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color.awText)
                            FrequencyField(value: $vm.editFrequency) { val in
                                vm.editFormErrors.frequency = vm.validateFrequency(val)
                            }
                            if let err = vm.editFormErrors.frequency { errorText(err) }
                        }
                    }
                    .padding(20)
                    .background(Color.awCard)
                    .cornerRadius(16)
                }
                .padding(16)
            }
            .background(Color.awBackground.ignoresSafeArea())
            .navigationTitle("Edit Rule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { vm.closeEdit() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(vm.editSubmitting ? "Saving..." : "Save") { vm.saveEdit() }
                        .disabled(vm.editSubmitting)
                }
            }
        }
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11))
            .foregroundColor(Color(hex: "#ef4444"))
            .padding(.top, 4)
    }
}

// MARK: - ToastView
//struct ToastView: View {
//    let toast: ToastMessage
//
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: toast.style == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
//                .foregroundColor(.white)
//            Text(toast.message)
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(.white)
//                .lineLimit(2)
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .fill(toast.style == .success
//                    ? Color(red: 0.10, green: 0.60, blue: 0.35)
//                    : Color(red: 0.75, green: 0.20, blue: 0.20))
//        )
//        .padding(.horizontal, 16)
//    }
//}
extension Color {
    static let awText        = Color(.label)
    static let awBackground  = Color(.systemBackground)
    static let awCard        = Color(.secondarySystemBackground)
    static let awBorder      = Color(.separator)
}
