//
//  Cryptoaddressview.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 03/06/26.
//

// CryptoAddressView.swift
// Standalone page — mirrors the React web page layout:
//   • Grid of asset cards (assetName, network, balance, Add Address button)
//   • Sheet modal: Address Name, Memo (HCX/XRP), ERC/TRC inputs (USDT) or Native input
//   • Per-field validation feedback (validating / valid / invalid)
//   • Auto-withdraw checkbox for USDT
//   • Toast feedback

import SwiftUI

// MARK: - Design tokens (match BusinessSettingsView palette)

private let darkBG       = Color(red: 0.08, green: 0.10, blue: 0.16)
private let darkCard     = Color(red: 0.10, green: 0.12, blue: 0.19)
private let darkField    = Color(red: 0.12, green: 0.15, blue: 0.22)
private let purpleAccent = Color(red: 0.55, green: 0.40, blue: 0.95)
private let labelGray    = Color.white.opacity(0.45)
private let strokeClr    = Color.white.opacity(0.10)
private let successGreen = Color(red: 0.09, green: 0.64, blue: 0.29)
private let errorRed     = Color(red: 0.86, green: 0.15, blue: 0.15)

// MARK: - Main View

struct CryptoAddressView: View {

    @StateObject private var vm = CryptoAddressViewModel()
    @Environment(\.dismiss) private var dismiss

    // Two-column grid for asset cards
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()

            VStack(spacing: 0) {
                pageHeader
                ScrollView(showsIndicators: false) {
                    assetGrid
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 32)
                }
            }

            // Loading overlay
            if vm.isLoading {
                Color.black.opacity(0.45).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)
            }

            // Toast
            if let msg = vm.toastMessage {
                VStack {
                    Spacer()
                    ToastView(message: msg, isSuccess: vm.toastIsSuccess)
                        .padding(.bottom, 32)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                vm.toastMessage = nil
                            }
                        }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(), value: vm.toastMessage)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $vm.showAddressModal) {
            AddressModalView(vm: vm)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .onAppear { vm.loadAssets() }
    }

    // MARK: Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Add Crypto Address")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("Manage your crypto asset addresses")
                    .font(.system(size: 12))
                    .foregroundColor(labelGray)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }

    // MARK: Asset grid

    @ViewBuilder
    private var assetGrid: some View {
        if vm.assets.isEmpty && !vm.isLoading {
            emptyState
        } else {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(vm.assets) { asset in
                    AssetCard(asset: asset, hasWritePermission: vm.hasWritePermission) {
                        vm.openAddressModal(for: asset)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.25))
            Text("No assets found")
                .font(.system(size: 14))
                .foregroundColor(labelGray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Asset Card

private struct AssetCard: View {
    let asset: CryptoAsset
    let hasWritePermission: Bool
    let onAddTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Coin header ──────────────────────────────────────────────────
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: asset.assetImage)) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    Circle().fill(Color.white.opacity(0.1))
                }
                .frame(width: 38, height: 38)
                .clipShape(Circle())
                .overlay(Circle().stroke(strokeClr, lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(asset.assetName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(asset.assetCode)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(labelGray)
                        .textCase(.uppercase)
                }
                Spacer()
            }
            .padding(.bottom, 14)

            // ── Network field ────────────────────────────────────────────────
            infoBox(label: "NETWORK",
                    value: asset.network.joined(separator: " / ").uppercased())
                .padding(.bottom, 10)

            // ── Balance field ────────────────────────────────────────────────
            infoBox(label: "BALANCE",
                    value: "\(asset.coinBalance) \(asset.assetCode)")
                .padding(.bottom, 14)

            // ── Add Address button ───────────────────────────────────────────
            Button(action: onAddTap) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                    Text("Add Address")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(
                    hasWritePermission
                        ? LinearGradient(colors: [purpleAccent,
                                                   Color(red: 0.40, green: 0.30, blue: 0.85)],
                                         startPoint: .leading, endPoint: .trailing)
                        : LinearGradient(colors: [Color.gray.opacity(0.4),
                                                   Color.gray.opacity(0.4)],
                                         startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(10)
            }
            .disabled(!hasWritePermission)
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(darkCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1))
    }

    private func infoBox(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(labelGray)
            Text(value)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(darkBG)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1))
        }
    }
}

// MARK: - Address Modal Sheet

struct AddressModalView: View {
    @ObservedObject var vm: CryptoAddressViewModel

    var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    modalHeader
                    Divider().background(strokeClr).padding(.bottom, 20)

                    // Address Name
                    formField(label: "ADDRESS NAME",
                              placeholder: "Enter Address Name",
                              text: $vm.addressName,
                              error: vm.addressNameError)

                    // Memo — only for HCX / XRP
                    if vm.showMemoField {
                        let placeholder = vm.selectedAsset?.assetCode == "XRP"
                            ? "Enter Destination Tag"
                            : "Enter Memo"
                        formFieldWithRequired(label: "MEMO / DESTINATION TAG",
                                             placeholder: placeholder,
                                             text: $vm.memo,
                                             error: vm.memoError)
                    }

                    // Address inputs
                    if vm.isUSDT {
                        addressInputSection(networkType: "ERC",
                                            label: "USDT ERC ADDRESS",
                                            address: $vm.ercAddress,
                                            validationState: vm.ercValidationState)
                        addressInputSection(networkType: "TRC",
                                            label: "USDT TRC ADDRESS",
                                            address: $vm.trcAddress,
                                            validationState: vm.trcValidationState)
                    } else {
                        let assetName = vm.selectedAsset?.assetName ?? "Crypto"
                        addressInputSection(networkType: "",
                                            label: "\(assetName.uppercased()) ADDRESS",
                                            address: $vm.nativeAddress,
                                            validationState: vm.nativeValidationState)
                    }

                    // Action buttons
                    HStack(spacing: 12) {
                        Button("Save") { vm.saveAddress() }
                            .buttonStyle(PrimaryButtonStyle())

                        Button("Cancel") { vm.dismissModal() }
                            .buttonStyle(SecondaryButtonStyle())
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
    }

    // MARK: Modal header

    private var modalHeader: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 0.45, green: 0.35, blue: 0.90).opacity(0.18))
                    .frame(width: 40, height: 40)
                Image(systemName: "pencil")
                    .foregroundColor(purpleAccent)
                    .font(.system(size: 16))
            }
            Text("\(vm.selectedAsset?.assetName ?? "") Address")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.bottom, 16)
    }

    // MARK: Generic form field

    private func formField(label: String,
                           placeholder: String,
                           text: Binding<String>,
                           error: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(labelGray)

            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(darkField)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(strokeClr, lineWidth: 1))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)

            if !error.isEmpty {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(errorRed)
            }
        }
        .padding(.bottom, 18)
    }

    private func formFieldWithRequired(label: String,
                                       placeholder: String,
                                       text: Binding<String>,
                                       error: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 3) {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(labelGray)
                Text("*").foregroundColor(errorRed).font(.system(size: 11))
            }
            TextField(placeholder, text: text)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(darkField)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(strokeClr, lineWidth: 1))
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            if !error.isEmpty {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(errorRed)
            }
        }
        .padding(.bottom, 18)
    }

    // MARK: Address input with validation badge + auto-withdraw toggle

    @ViewBuilder
    private func addressInputSection(networkType: String,
                                     label: String,
                                     address: Binding<String>,
                                     validationState: AddressValidationState) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(labelGray)

            TextField("Enter \(label.capitalized)", text: address)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .background(darkField)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(borderColor(for: validationState), lineWidth: 1)
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
//                .onSubmit { vm.validateAddressOnBlur(networkType: networkType) }
                .onChange(of: address.wrappedValue) { _, newValue in
                    guard !newValue.isEmpty else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        if address.wrappedValue == newValue {
                            vm.validateAddressOnBlur(networkType: networkType)
                        }
                    }
                }

            // Validation feedback
            switch validationState {
            case .validating:
                HStack(spacing: 6) {
                    ProgressView().scaleEffect(0.7)
                    Text("Validating…").font(.system(size: 12)).foregroundColor(labelGray)
                }
            case .valid:
                Label("Valid Address", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(successGreen)
            case .invalid:
                Label("Invalid Address", systemImage: "xmark.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(errorRed)
            case .idle:
                EmptyView()
            }

            // Auto-withdraw toggle — USDT only
            if vm.isUSDT {
                let addrFilled = !address.wrappedValue.isEmpty
                let notInvalid = validationState != .invalid

                Toggle(isOn: Binding(
                    get: { vm.autoWithdrawNetwork == networkType },
                    set: { if $0 { vm.autoWithdrawNetwork = networkType } }
                )) {
                    Text("Use for Automatic Withdrawal")
                        .font(.system(size: 13))
                        .foregroundColor(addrFilled && notInvalid ? .white : labelGray)
                }
                .toggleStyle(CheckboxToggleStyle())
                .disabled(!addrFilled || !notInvalid)
                .padding(.top, 6)
            }
        }
        .padding(.bottom, 18)
    }

    private func borderColor(for state: AddressValidationState) -> Color {
        switch state {
        case .valid:   return successGreen.opacity(0.8)
        case .invalid: return errorRed.opacity(0.8)
        default:       return strokeClr
        }
    }
}

// MARK: - Checkbox toggle style

private struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: configuration.isOn
                      ? "checkmark.square.fill"
                      : "square")
                    .foregroundColor(configuration.isOn ? purpleAccent : labelGray)
                    .font(.system(size: 16))
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Button styles

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(purpleAccent.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(10)
    }
}

private struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(darkField.opacity(configuration.isPressed ? 0.7 : 1))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(strokeClr, lineWidth: 1))
    }
}

// MARK: - Toast

//private struct ToastView: View {
//    let message: String
//    let isSuccess: Bool
//
//    var body: some View {
//        HStack(spacing: 10) {
//            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
//                .foregroundColor(isSuccess ? successGreen : errorRed)
//            Text(message)
//                .font(.system(size: 13, weight: .medium))
//                .foregroundColor(.white)
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 14)
//        .background(Color(red: 0.14, green: 0.17, blue: 0.25))
//        .cornerRadius(14)
//        .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
//        .padding(.horizontal, 24)
//    }
//}

// MARK: - Preview

#Preview {
    CryptoAddressView()
}
