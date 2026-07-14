//  PaymentToleranceView.swift

import SwiftUI

struct PaymentToleranceView: View {

    @ObservedObject var vm: PaymentToleranceViewModel
    @Environment(\.dismiss) private var dismiss

    init(vm: PaymentToleranceViewModel = PaymentToleranceViewModel()) {
        self.vm = vm
    }

    enum Field { case underLimit, overLimit }
    @FocusState private var focusedField: Field?
    @State private var showDropdown = false

    var body: some View {
        ZStack(alignment: .top) {

            // Background
            Color(red: 0.08, green: 0.10, blue: 0.14)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    toleranceInfoCard
                    currencyDropdown
                    underpaymentSection
                    overpaymentSection
                    saveButton
                        .padding(.bottom, 30)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }

            // Dropdown overlay
            if showDropdown { dropdownView }

            // Loader
            if vm.isLoading {
                Color.black.opacity(0.5).ignoresSafeArea()
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.8)
                    Spacer()
                }
            }

            // Toast
            if let msg = vm.toastMessage {
                toastBanner(msg)
            }
        }
        .onAppear { vm.loadAssets() }
    }
}

// MARK: - Components
extension PaymentToleranceView {

    // MARK: Header
    var header: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                dismiss()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 36, height: 36)
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Payment Tolerance")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                Text("Configure how overpayments and underpayments are handled")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    // MARK: Info Card
    var toleranceInfoCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Card header row
            HStack(spacing: 14) {
                iconCircle(systemName: "exclamationmark.circle.fill",
                           bg: Color(red: 0.55, green: 0.38, blue: 0.05),
                           fg: Color(red: 1.0, green: 0.72, blue: 0.10),
                           size: 46)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Tolerance Settings")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    Text("Define thresholds for automatic payment acceptance")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
            }
            .padding(16)

            // Info box
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 1.0, green: 0.72, blue: 0.10))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Overpayments and Underpayments")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Configure tolerance thresholds per currency. When a payment falls within the defined range, it will be automatically accepted or adjusted.")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.55))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(red: 1.0, green: 0.72, blue: 0.10).opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 1.0, green: 0.72, blue: 0.10).opacity(0.18), lineWidth: 1)
                    )
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.14, blue: 0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: Currency Dropdown
    var currencyDropdown: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("SELECT CURRENCY")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .tracking(0.8)

            Button { showDropdown.toggle() } label: {
                HStack {
                    let label = vm.assets
                        .first(where: { String($0.assetId) == vm.selectedCurrencyId })
                        .map { "\($0.assetCode) - \($0.assetName)" }
                        ?? "Select Currency"

                    Text(label)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(label == "Select Currency" ? .white.opacity(0.4) : .white)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.45))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.12, green: 0.14, blue: 0.20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: Underpayment Section
    var underpaymentSection: some View {
        toleranceCard(
            icon: "arrow.down.circle.fill",
            iconBG: Color.red.opacity(0.15),
            iconFG: Color.red,
            title: "Underpayments",
            description: "An invoice price automatically adjusts down so it counts as fully paid if the underpaid amount is within the threshold you define.",
            toggleLabel: "Automatically accept Underpayments",
            isOn: $vm.isAutomaticAcceptUnderpayment,
            limitLabel: "Underpayment tolerance limit (IN % OF INVOICE AMOUNT)",
            limitText: $vm.underPaymentToleranceLimit,
            field: .underLimit
        )
    }

    // MARK: Overpayment Section
    var overpaymentSection: some View {
        toleranceCard(
            icon: "arrow.up.circle.fill",
            iconBG: Color.green.opacity(0.15),
            iconFG: Color.green,
            title: "Overpayments",
            description: "If a customer overpays, the system can automatically credit the extra funds to your ledger if the overpaid amount is within the tolerance threshold.",
            toggleLabel: "Automatically accept Overpayments",
            isOn: $vm.isAutomaticAcceptOverpayment,
            limitLabel: "Overpayment tolerance limit (IN % OF INVOICE AMOUNT)",
            limitText: $vm.overPaymentToleranceLimit,
            field: .overLimit
        )
    }

    // MARK: Reusable Tolerance Card
    func toleranceCard(
        icon: String,
        iconBG: Color,
        iconFG: Color,
        title: String,
        description: String,
        toggleLabel: String,
        isOn: Binding<Bool>,
        limitLabel: String,
        limitText: Binding<String>,
        field: Field
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            // Title row
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(iconBG).frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(iconFG)
                }
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            // Description
            Text(description)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.55))
                .fixedSize(horizontal: false, vertical: true)

            // Checkbox row  (matches Android checkbox style)
            Button {
                isOn.wrappedValue.toggle()
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isOn.wrappedValue
                                  ? Color(red: 0.42, green: 0.32, blue: 0.90)
                                  : Color.white.opacity(0.08))
                            .frame(width: 22, height: 22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isOn.wrappedValue
                                            ? Color.clear
                                            : Color.white.opacity(0.25), lineWidth: 1.5)
                            )

                        if isOn.wrappedValue {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Text(toggleLabel)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            // Input field
            VStack(alignment: .leading, spacing: 6) {
                Text(limitLabel)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
                    .tracking(0.3)
                    .fixedSize(horizontal: false, vertical: true)

                TextField("", text: limitText)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 0.08, green: 0.10, blue: 0.14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(focusedField == field
                                            ? Color(red: 0.42, green: 0.32, blue: 0.90)
                                            : Color.white.opacity(0.12),
                                            lineWidth: 1.5)
                            )
                    )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.12, green: 0.14, blue: 0.20))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }

    // MARK: Save Button
    var saveButton: some View {
        Button { vm.saveSettings() } label: {
            HStack(spacing: 8) {
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                Text("Save Settings")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if vm.canSave {
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.35, blue: 0.95),
                                Color(red: 0.35, green: 0.45, blue: 0.95)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.white.opacity(0.08), Color.white.opacity(0.08)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .cornerRadius(14)
        }
        .disabled(!vm.canSave)
    }

    // MARK: Dropdown Sheet
    var dropdownView: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { showDropdown = false }

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 4)
                    .padding(.top, 12)
                    .padding(.bottom, 8)

                Text("Select Currency")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 12)

                Divider().background(Color.white.opacity(0.1))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(vm.assets, id: \.assetId) { asset in
                            Button {
                                vm.selectedCurrencyId = String(asset.assetId)
                                vm.loadSettings(currencyId: vm.selectedCurrencyId)
                                showDropdown = false
                            } label: {
                                HStack(spacing: 14) {
                                    // Coin initial badge
                                    ZStack {
                                        Circle()
                                            .fill(Color(red: 0.22, green: 0.26, blue: 0.38))
                                            .frame(width: 36, height: 36)
                                        Text(String(asset.assetCode.prefix(1)))
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(asset.assetCode)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                        Text(asset.assetName)
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                    Spacer()

                                    if String(asset.assetId) == vm.selectedCurrencyId {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(red: 0.42, green: 0.32, blue: 0.90))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .background(Color.white.opacity(0.07))
                                .padding(.leading, 70)
                        }
                    }
                }
                .frame(maxHeight: 320)

                // Safe area spacer
                Color.clear.frame(height: 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.12, green: 0.14, blue: 0.20))
            )
        }
        .ignoresSafeArea()
    }

    // MARK: Toast
    func toastBanner(_ msg: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: vm.toastIsError ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(vm.toastIsError ? .red : .green)
                .font(.system(size: 16))
            Text(msg)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.15, green: 0.17, blue: 0.24))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(vm.toastIsError
                                ? Color.red.opacity(0.4)
                                : Color.green.opacity(0.4), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
        )
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                vm.toastMessage = nil
            }
        }
    }

    // MARK: Icon Circle Helper
    func iconCircle(systemName: String, bg: Color, fg: Color, size: CGFloat) -> some View {
        ZStack {
            Circle().fill(bg).frame(width: size, height: size)
            Image(systemName: systemName)
                .font(.system(size: size * 0.42))
                .foregroundColor(fg)
        }
    }
}

// MARK: - Preview
struct PaymentToleranceView_Previews: PreviewProvider {
    static var previews: some View {
        PaymentToleranceView()
            .preferredColorScheme(.dark)
    }
}
