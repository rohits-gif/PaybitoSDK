////
////  EditAutomaticExceptionHandlingView.swift
////  PaymentsTerminsl
////
////  Created by HashCash on 15/06/26.
////
//
//import SwiftUI
//
//// MARK: - Models
//
//enum ProcessingFeeOption {
//    case addToTotal
//    case deductFromPayout
//}
//
//struct ExceptionHandlingSettings {
//    var selectedCoin: CryptoOption = .usdt
//    var processingFee: ProcessingFeeOption = .deductFromPayout
//    var autoAcceptUnderPayments: Bool = true
//    var underpaymentTolerance: String = "1"
//    var autoAcceptOverPayments: Bool = true
//    var overpaymentTolerance: String = "1"
//}
//
//enum CryptoOption: String, CaseIterable, Identifiable {
//    case usdt = "USDT - Tether"
//    case doge = "DOGE - Dogecoin"
//    case eth  = "ETH - Ethereum"
//    case ltc  = "LTC - Litecoin"
//    case hcx  = "HCX - Hashcash Coin"
//    case bch  = "BCH - Bitcoin Cash"
//    case xrp  = "XRP - Ripple"
//    case btc  = "BTC - Bitcoin"
//    case usdc = "USDC - USDC"
//
//    var id: String { rawValue }
//}
//
//// MARK: - Color Palette
//
//private extension Color {
//    static let bgPrimary   = Color(red: 0.08, green: 0.09, blue: 0.13)   // #141620
//    static let bgCard      = Color(red: 0.11, green: 0.13, blue: 0.18)   // #1C2130
//    static let bgField     = Color(red: 0.09, green: 0.11, blue: 0.16)   // #171C28
//    static let borderNorm  = Color(white: 1, opacity: 0.08)
//    static let borderAccent = Color(red: 0.40, green: 0.35, blue: 0.90)  // #6659E6
//    static let accent      = Color(red: 0.45, green: 0.38, blue: 0.95)   // #7361F2
//    static let textPrimary = Color.white
//    static let textSecond  = Color(white: 1, opacity: 0.55)
//    static let checkFill   = Color(red: 0.35, green: 0.30, blue: 0.85)   // #5A4DD9
//}
//
//// MARK: - Reusable Components
//
//struct SectionCard<Content: View>: View {
//    let content: Content
//    init(@ViewBuilder content: () -> Content) { self.content = content() }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 14) { content }
//            .padding(18)
//            .background(Color.bgCard)
//            .clipShape(RoundedRectangle(cornerRadius: 14))
//            .overlay(
//                RoundedRectangle(cornerRadius: 14)
//                    .stroke(Color.borderNorm, lineWidth: 1)
//            )
//    }
//}
//
//struct SectionTitle: View {
//    let title: String
//    let subtitle: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 4) {
//            Text(title)
//                .font(.system(size: 16, weight: .bold))
//                .foregroundColor(.textPrimary)
//            Text(subtitle)
//                .font(.system(size: 13))
//                .foregroundColor(.textSecond)
//        }
//    }
//}
//
//struct RadioOptionRow: View {
//    let title: String
//    let subtitle: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 12) {
//                ZStack {
//                    Circle()
//                        .stroke(isSelected ? Color.accent : Color.borderNorm, lineWidth: 2)
//                        .frame(width: 22, height: 22)
//                    if isSelected {
//                        Circle()
//                            .fill(Color.accent)
//                            .frame(width: 12, height: 12)
//                    }
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(title)
//                        .font(.system(size: 15, weight: .semibold))
//                        .foregroundColor(.textPrimary)
//                    Text(subtitle)
//                        .font(.system(size: 12))
//                        .foregroundColor(.textSecond)
//                }
//                Spacer()
//            }
//            .padding(14)
//            .background(
//                isSelected
//                    ? Color.accent.opacity(0.12)
//                    : Color.bgField
//            )
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(
//                        isSelected ? Color.borderAccent : Color.borderNorm,
//                        lineWidth: isSelected ? 1.5 : 1
//                    )
//            )
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//struct CheckboxRow: View {
//    let label: String
//    @Binding var isChecked: Bool
//
//    var body: some View {
//        HStack(spacing: 12) {
//            Button {
//                isChecked.toggle()
//            } label: {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 5)
//                        .fill(isChecked ? Color.checkFill : Color.clear)
//                        .frame(width: 22, height: 22)
//                    RoundedRectangle(cornerRadius: 5)
//                        .stroke(isChecked ? Color.checkFill : Color.borderNorm, lineWidth: 1.5)
//                        .frame(width: 22, height: 22)
//                    if isChecked {
//                        Image(systemName: "checkmark")
//                            .font(.system(size: 12, weight: .bold))
//                            .foregroundColor(.white)
//                    }
//                }
//            }
//            .buttonStyle(.plain)
//
//            Text(label)
//                .font(.system(size: 14))
//                .foregroundColor(.textPrimary)
//        }
//    }
//}
//
//struct ToleranceField: View {
//    let label: String
//    @Binding var value: String
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(label)
//                .font(.system(size: 12, weight: .semibold))
//                .foregroundColor(.textSecond)
//                .textCase(.uppercase)
//                .tracking(0.3)
//
//            TextField("", text: $value)
//                .keyboardType(.decimalPad)
//                .font(.system(size: 15))
//                .foregroundColor(.textPrimary)
//                .padding(.horizontal, 14)
//                .padding(.vertical, 12)
//                .background(Color.bgField)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.borderNorm, lineWidth: 1)
//                )
//        }
//    }
//}
//
//struct CoinPickerMenu: View {
//    @Binding var selected: CryptoOption
//    @State private var isExpanded = false
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Select Coin")
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(.textSecond)
//
//            Menu {
//                ForEach(CryptoOption.allCases) { option in
//                    Button(option.rawValue) {
//                        selected = option
//                    }
//                }
//            } label: {
//                HStack {
//                    Text(selected.rawValue)
//                        .font(.system(size: 15))
//                        .foregroundColor(.textPrimary)
//                    Spacer()
//                    Image(systemName: "chevron.down")
//                        .font(.system(size: 13, weight: .semibold))
//                        .foregroundColor(.textSecond)
//                }
//                .padding(.horizontal, 14)
//                .padding(.vertical, 14)
//                .background(Color.bgField)
//                .clipShape(RoundedRectangle(cornerRadius: 10))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.borderNorm, lineWidth: 1)
//                )
//            }
//        }
//    }
//}
//
//// MARK: - Main View
//
//struct AutomaticExceptionHandlingView: View {
//    @Environment(\.dismiss) private var dismiss
//    @State private var settings = ExceptionHandlingSettings()
//
//    var body: some View {
//        ZStack {
//            Color.bgPrimary.ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // Navigation bar
//                HStack {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Image(systemName: "arrow.left")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.textPrimary)
//                    }
//
//                    Text("Automatic Exception Handling")
//                        .font(.system(size: 18, weight: .bold))
//                        .foregroundColor(.textPrimary)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.8)
//
//                    Spacer()
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 16)
//                .padding(.bottom, 12)
//
//                // Subtitle
//                Text("Automatic Exception handling settings requires Business Plan.")
//                    .font(.system(size: 13))
//                    .foregroundColor(.textSecond)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 20)
//
//                // Scrollable content
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 14) {
//
//                        // Currency Section
//                        SectionCard {
//                            SectionTitle(
//                                title: "Currency",
//                                subtitle: "Select coin for which automatic accept settings will be applicable"
//                            )
//                            CoinPickerMenu(selected: $settings.selectedCoin)
//                        }
//
//                        // Processing Fee Section
//                        SectionCard {
//                            SectionTitle(
//                                title: "Processing Fee Handling",
//                                subtitle: "Choose who pays the processing fee for this asset."
//                            )
//                            RadioOptionRow(
//                                title: "Add to Total (Customer)",
//                                subtitle: "Processing fee is added to the order total",
//                                isSelected: settings.processingFee == .addToTotal
//                            ) {
//                                settings.processingFee = .addToTotal
//                            }
//                            RadioOptionRow(
//                                title: "Deduct from Payout (Merchant)",
//                                subtitle: "Processing fee is deducted from your payout",
//                                isSelected: settings.processingFee == .deductFromPayout
//                            ) {
//                                settings.processingFee = .deductFromPayout
//                            }
//                        }
//
//                        // Under Payments Section
//                        SectionCard {
//                            SectionTitle(
//                                title: "Under Payments",
//                                subtitle: "An invoice price automatically adjust down so it counts as fully paid if the underpaid amount is within the thresholds you define."
//                            )
//                            CheckboxRow(
//                                label: "Automatically accept Under Payments?",
//                                isChecked: $settings.autoAcceptUnderPayments
//                            )
//                            ToleranceField(
//                                label: "Underpayment tolerance limit (IN % OF INVOICE AMOUNT)",
//                                value: $settings.underpaymentTolerance
//                            )
//                        }
//
//                        // Over Payments Section
//                        SectionCard {
//                            SectionTitle(
//                                title: "Over Payments",
//                                subtitle: "If a customer overpays Blockchain can automatically credit the extra funds to your ledger if the overpaid amount is less than the percent threshold."
//                            )
//                            CheckboxRow(
//                                label: "Automatically accept Over Payments?",
//                                isChecked: $settings.autoAcceptOverPayments
//                            )
//                            ToleranceField(
//                                label: "Overpayment tolerance limit (IN % OF INVOICE AMOUNT)",
//                                value: $settings.overpaymentTolerance
//                            )
//                        }
//
//                        Spacer(minLength: 100)
//                    }
//                    .padding(.horizontal, 16)
//                }
//
//                // Bottom action buttons
//                HStack(spacing: 12) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        Text("Cancel")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.textPrimary)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 52)
//                            .background(Color.bgCard)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.borderNorm, lineWidth: 1.5)
//                            )
//                    }
//
//                    Button {
//                        // Handle update
//                    } label: {
//                        Text("Update")
//                            .font(.system(size: 16, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 52)
//                            .background(Color.accent)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.vertical, 16)
//                .background(Color.bgPrimary)
//            }
//        }
//        .navigationBarHidden(true)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    AutomaticExceptionHandlingView()
//}
