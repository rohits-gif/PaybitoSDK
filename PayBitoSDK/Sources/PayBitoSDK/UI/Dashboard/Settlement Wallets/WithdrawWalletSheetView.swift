////
////  WithdrawWalletView.swift
////  Trading_Terminal
////
////  Created by Sk Jasimuddin on 06/05/26.
////
//
////
////  WithdrawWalletView.swift
////  Trading_Terminal
////
////  Static UI — "Choose Transfer Type" bottom sheet
////  Matches WS2 screenshot exactly. No API, no external models.
////
//
//import SwiftUI
//
//// MARK: - Root Preview Wrapper
//
//struct WithdrawWalletPreview: View {
//    var body: some View {
//        ZStack(alignment: .bottom) {
//            Color(red: 0.07, green: 0.08, blue: 0.13)
//                .ignoresSafeArea()
//            WithdrawWalletSheetView(onDismiss: {})
//        }
//        .ignoresSafeArea()
//    }
//}
//
//// MARK: - Bottom Sheet
//
//struct WithdrawWalletSheetView: View {
//    var onDismiss: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//
//            // Dimmed backdrop
//            Color.black.opacity(0.55)
//                .ignoresSafeArea()
//                .onTapGesture { onDismiss() }
//
//            // Sheet card
//            VStack(spacing: 0) {
//
//                // ── Drag handle ──
//                Capsule()
//                    .fill(Color.white.opacity(0.20))
//                    .frame(width: 40, height: 4)
//                    .padding(.top, 14)
//                    .padding(.bottom, 26)
//
//                // ── Heading ──
//                Text("Choose Transfer Type")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.white)
//                    .padding(.bottom, 6)
//
//                Text("Select where to send your crypto")
//                    .font(.system(size: 14))
//                    .foregroundColor(Color(white: 0.50))
//                    .padding(.bottom, 28)
//
//                // ── Three options ──
//                VStack(spacing: 12) {
//
//                    WithdrawOptionRow(
//                        iconName: "building.columns.fill",
//                        iconBG:   Color(red: 0.16, green: 0.22, blue: 0.45),
//                        title:    "Transfer to PayBito Wallet",
//                        subtitle: "Move funds to your exchange account"
//                    )
//
//                    WithdrawOptionRow(
//                        iconName: "arrow.up",
//                        iconBG:   Color(red: 0.10, green: 0.32, blue: 0.24),
//                        title:    "Transfer to External Wallet",
//                        subtitle: "Withdraw to an external address"
//                    )
//
//                    WithdrawOptionRow(
//                        iconName: "building.columns.fill",
//                        iconBG:   Color(red: 0.28, green: 0.20, blue: 0.10),
//                        title:    "Withdraw to Bank Account",
//                        subtitle: "Cash out to your bank account"
//                    )
//                }
//                .padding(.horizontal, 16)
//
//                // ── Cancel button ──
//                Button(action: onDismiss) {
//                    Text("Cancel")
//                        .font(.system(size: 16, weight: .semibold))
//                        .foregroundColor(Color(white: 0.70))
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 54)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 16)
//                                .stroke(
//                                    Color(red: 0.38, green: 0.30, blue: 0.78),
//                                    lineWidth: 1.5
//                                )
//                        )
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 20)
//                .padding(.bottom, 36)
//            }
//            .background(
//                Color(red: 0.09, green: 0.10, blue: 0.16)
//                    .clipShape(
//                        UnevenRoundedRectangle(
//                            topLeadingRadius: 26,
//                            topTrailingRadius: 26
//                        )
//                    )
//            )
//        }
//        .ignoresSafeArea()
//    }
//}
//
//// MARK: - Option Row
//
//private struct WithdrawOptionRow: View {
//    let iconName: String
//    let iconBG:   Color
//    let title:    String
//    let subtitle: String
//
//    var body: some View {
//        Button(action: {}) {
//            HStack(spacing: 16) {
//
//                // Colored icon box
//                ZStack {
//                    RoundedRectangle(cornerRadius: 14)
//                            .fill(iconBG)
//                        .frame(width: 52, height: 52)
//                    Image(systemName: iconName)
//                        .font(.system(size: 20, weight: .semibold))
//                        .foregroundColor(.white)
//                }
//
//                // Title + subtitle
//                VStack(alignment: .leading, spacing: 5) {
//                    Text(title)
//                        .font(.system(size: 15, weight: .bold))
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.leading)
//                    Text(subtitle)
//                        .font(.system(size: 13))
//                        .foregroundColor(Color(white: 0.48))
//                }
//
//                Spacer()
//
//                // Chevron
//                Image(systemName: "chevron.right")
//                    .font(.system(size: 13, weight: .semibold))
//                    .foregroundColor(Color(white: 0.35))
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 14)
//            .background(
//                RoundedRectangle(cornerRadius: 16)
//                    .fill(Color(red: 0.12, green: 0.14, blue: 0.21))
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 16)
//                            .stroke(Color(white: 0.13), lineWidth: 1)
//                    )
//            )
//        }
//        .buttonStyle(RowPressStyle())
//    }
//}
//
//// MARK: - Press Button Style
//
//private struct RowPressStyle: ButtonStyle {
//    func makeBody(configuration: Configuration) -> some View {
//        configuration.label
//            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
//            .opacity(configuration.isPressed ? 0.80 : 1.0)
//            .animation(.easeOut(duration: 0.13), value: configuration.isPressed)
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    WithdrawWalletPreview()
//}
