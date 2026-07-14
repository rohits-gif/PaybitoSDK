// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message

//  AddShippingView.swift
//  Trading_Terminal
//  Created by Rajit HashCash on 14/04/26.


//import SwiftUI
//
//// MARK: - New Shipping Profile View
//struct AddShippingView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var profileName: String = ""
//    @State private var shippingPercent: String = ""
//    @State private var taxRate: String = ""
//    @State private var isDefault: Bool = false
//
//    // Colors
//    private let bgColor = Color(red: 0.08, green: 0.09, blue: 0.12)
//    private let fieldBg = Color(red: 0.12, green: 0.14, blue: 0.19)
//    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.17)
//    private let borderColor = Color(red: 0.22, green: 0.25, blue: 0.32)
//    private let purpleColor = Color(red: 0.56, green: 0.27, blue: 0.90)
//    private let subtitleColor = Color(red: 0.50, green: 0.53, blue: 0.62)
//    private let plusBlue = Color(red: 0.38, green: 0.45, blue: 0.98)
//
//    var body: some View {
//        ZStack {
//            bgColor.ignoresSafeArea()
//
//            ScrollView {
//                VStack(alignment: .leading, spacing: 0) {
//
//                    // Header
//                    HStack(spacing: 14) {
//                        Button(action: { dismiss() }) {
//                            Image(systemName: "chevron.left")
//                                .font(.system(size: 17, weight: .semibold))
//                                .foregroundColor(.white)
//                        }
//
//                        Image(systemName: "plus")
//                            .font(.system(size: 17, weight: .bold))
//                            .foregroundColor(plusBlue)
//
//                        Text("New Shipping Profile")
//                            .font(.system(size: 19, weight: .bold))
//                            .foregroundColor(.white)
//
//                        Spacer()
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 18)
//                    .padding(.bottom, 22)
//
//                    Rectangle()
//                        .fill(Color.white.opacity(0.07))
//                        .frame(height: 0.5)
//                        .padding(.bottom, 24)
//
//                    // PROFILE NAME
//                    VStack(alignment: .leading, spacing: 9) {
//                        Text("PROFILE NAME *")
//                            .labelStyle(subtitleColor)
//
//                        TextField("", text: $profileName)
//                            .customPlaceholder(when: profileName.isEmpty) {
//                                Text("e.g. Standard Rates")
//                                    .foregroundColor(subtitleColor)
//                            }
//                            .styledField(fieldBg: fieldBg, borderColor: borderColor)
//                    }
//                    .padding(.horizontal, 16)
//
//                    // SHIPPING + TAX
//                    HStack(spacing: 12) {
//                        VStack(alignment: .leading, spacing: 9) {
//                            Text("SHIPPING (%) *")
//                                .labelStyle(subtitleColor)
//
//                            TextField("", text: $shippingPercent)
//                                .customPlaceholder(when: shippingPercent.isEmpty) {
//                                    Text("0.00")
//                                        .foregroundColor(subtitleColor)
//                                }
//                                .keyboardType(.decimalPad)
//                                .styledField(fieldBg: fieldBg, borderColor: borderColor)
//
//                            Text("Percentage for shipping")
//                                .font(.system(size: 11.5))
//                                .foregroundColor(subtitleColor)
//                        }
//
//                        VStack(alignment: .leading, spacing: 9) {
//                            Text("TAX RATE (%) *")
//                                .labelStyle(subtitleColor)
//
//                            TextField("", text: $taxRate)
//                                .customPlaceholder(when: taxRate.isEmpty) {
//                                    Text("0.00")
//                                        .foregroundColor(subtitleColor)
//                                }
//                                .keyboardType(.decimalPad)
//                                .styledField(fieldBg: fieldBg, borderColor: borderColor)
//
//                            Text("Tax applied to order total")
//                                .font(.system(size: 11.5))
//                                .foregroundColor(subtitleColor)
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 20)
//
//                    // DEFAULT CARD
//                    HStack {
//                        VStack(alignment: .leading, spacing: 4) {
//                            Text("Set as Default Profile")
//                                .font(.system(size: 15, weight: .semibold))
//                                .foregroundColor(.white)
//
//                            Text("This profile will be pre-selected at checkout")
//                                .font(.system(size: 12.5))
//                                .foregroundColor(subtitleColor)
//                        }
//
//                        Spacer()
//
//                        Toggle("", isOn: $isDefault)
//                            .toggleStyle(SwitchToggleStyle(tint: purpleColor))
//                            .labelsHidden()
//                    }
//                    .padding(16)
//                    .background(cardBg)
//                    .cornerRadius(12)
//                    .overlay(
//                        RoundedRectangle(cornerRadius: 12)
//                            .stroke(borderColor, lineWidth: 1)
//                    )
//                    .padding(.horizontal, 16)
//                    .padding(.top, 20)
//
//                    // BUTTONS
//                    HStack(spacing: 14) {
//                        Button(action: { dismiss() }) {
//                            Text("Cancel")
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 30)
//                                        .stroke(purpleColor, lineWidth: 1.5)
//                                )
//                        }
//
//                        Button(action: saveProfile) {
//                            Text("Save Profile")
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(purpleColor)
//                                .cornerRadius(30)
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 28)
//
//                    Spacer(minLength: 30)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .preferredColorScheme(.dark)
//    }
//
//    private func saveProfile() {
//        print("Saved")
//    }
//}
//
//// MARK: - Extensions
//
//private extension View {
//    func styledField(fieldBg: Color, borderColor: Color) -> some View {
//        self
//            .font(.system(size: 15))
//            .foregroundColor(.white)
//            .padding(.horizontal, 14)
//            .padding(.vertical, 14)
//            .background(fieldBg)
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(borderColor, lineWidth: 1)
//            )
//    }
//
//    func customPlaceholder<Content: View>(
//        when shouldShow: Bool,
//        @ViewBuilder placeholder: () -> Content
//    ) -> some View {
//        ZStack(alignment: .leading) {
//            if shouldShow {
//                placeholder().padding(.leading, 14)
//            }
//            self
//        }
//    }
//}
//
//private extension Text {
//    func labelStyle(_ color: Color) -> some View {
//        self
//            .font(.system(size: 11.5, weight: .semibold))
//            .foregroundColor(color)
//            .tracking(0.8)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    AddShippingView()
//}

//  AddShippingView.swift

import SwiftUI

struct AddShippingView: View {

    @ObservedObject var vm: ShippingViewModel
    var editingProfile: Shipping.Profile?
    var onDismiss: () -> Void

    @State private var profileName      = ""
    @State private var shippingPercent  = ""
    @State private var taxRate          = ""
    @State private var isDefault        = false
    @State private var errors: [String: String] = [:]

    var isEditing: Bool { editingProfile != nil }

    private let bgColor     = Color(red: 0.08, green: 0.09, blue: 0.12)
    private let fieldBg     = Color(red: 0.12, green: 0.14, blue: 0.19)
    private let cardBg      = Color(red: 0.10, green: 0.12, blue: 0.17)
    private let borderColor = Color(red: 0.22, green: 0.25, blue: 0.32)
    private let purpleColor = Color(red: 0.56, green: 0.27, blue: 0.90)
    private let subtitleClr = Color(red: 0.50, green: 0.53, blue: 0.62)
    private let plusBlue    = Color(red: 0.38, green: 0.45, blue: 0.98)

    var body: some View {
        ZStack {
            bgColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // Header
                    HStack(spacing: 14) {
                        Button { onDismiss() } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.white)
                        }

                        Image(systemName: isEditing ? "pencil" : "plus")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(plusBlue)

                        Text(isEditing ? "Edit Shipping Profile" : "New Shipping Profile")
                            .font(.system(size: 19, weight: .bold)).foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                    .padding(.bottom, 22)

                    Rectangle().fill(Color.white.opacity(0.07))
                        .frame(height: 0.5).padding(.bottom, 24)

                    // Profile Name
                    VStack(alignment: .leading, spacing: 9) {
                        labelText("PROFILE NAME *")

                        TextField("", text: $profileName)
                            .customPlaceholder(when: profileName.isEmpty) {
                                Text("e.g. Standard Rates").foregroundColor(subtitleClr)
                            }
                            .styledField(
                                fieldBg:     fieldBg,
                                borderColor: errors["name"] != nil
                                             ? Color.red
                                             : borderColor
                            )

                        if let err = errors["name"] {
                            errorText(err)
                        }
                    }
                    .padding(.horizontal, 16)

                    // Shipping + Tax side by side
                    HStack(spacing: 12) {

                        // Shipping
                        VStack(alignment: .leading, spacing: 9) {
                            labelText("SHIPPING (%) *")

                            ZStack(alignment: .trailing) {
                                TextField("", text: $shippingPercent)
                                    .customPlaceholder(when: shippingPercent.isEmpty) {
                                        Text("0.00").foregroundColor(subtitleClr)
                                    }
                                    .keyboardType(.decimalPad)
                                    .styledField(
                                        fieldBg:     fieldBg,
                                        borderColor: errors["shipping"] != nil
                                                     ? Color.red
                                                     : borderColor
                                    )
                                Text("%")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(subtitleClr)
                                    .padding(.trailing, 14)
                            }

                            if let err = errors["shipping"] {
                                errorText(err)
                            } else {
                                Text("Percentage for shipping")
                                    .font(.system(size: 11.5)).foregroundColor(subtitleClr)
                            }
                        }

                        // Tax Rate
                        VStack(alignment: .leading, spacing: 9) {
                            labelText("TAX RATE (%) *")

                            ZStack(alignment: .trailing) {
                                TextField("", text: $taxRate)
                                    .customPlaceholder(when: taxRate.isEmpty) {
                                        Text("0.00").foregroundColor(subtitleClr)
                                    }
                                    .keyboardType(.decimalPad)
                                    .styledField(
                                        fieldBg:     fieldBg,
                                        borderColor: errors["tax"] != nil
                                                     ? Color.red
                                                     : borderColor
                                    )
                                Text("%")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(subtitleClr)
                                    .padding(.trailing, 14)
                            }

                            if let err = errors["tax"] {
                                errorText(err)
                            } else {
                                Text("Tax applied to order total")
                                    .font(.system(size: 11.5)).foregroundColor(subtitleClr)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    // Default Toggle card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Set as Default Profile")
                                .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            Text("This profile will be pre-selected at checkout")
                                .font(.system(size: 12.5)).foregroundColor(subtitleClr)
                        }
                        Spacer()
                        Toggle("", isOn: $isDefault)
                            .toggleStyle(SwitchToggleStyle(tint: purpleColor))
                            .labelsHidden()
                    }
                    .padding(16)
                    .background(cardBg)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(borderColor, lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 20)

                    // Buttons
                    HStack(spacing: 14) {
                        Button { onDismiss() } label: {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding()
                                .overlay(RoundedRectangle(cornerRadius: 30)
                                    .stroke(purpleColor, lineWidth: 1.5))
                        }
                        .disabled(vm.isSaving)

                        Button { save() } label: {
                            HStack(spacing: 6) {
                                if vm.isSaving {
                                    ProgressView().tint(.white).scaleEffect(0.8)
                                } else {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 13, weight: .bold))
                                }
                                Text(vm.isSaving ? "Saving…" : "Save Profile")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity).padding()
                            .background(purpleColor)
                            .cornerRadius(30)
                            .opacity(vm.isSaving ? 0.7 : 1)
                        }
                        .disabled(vm.isSaving)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 28)
                    .padding(.bottom, 30)
                }
            }

            // Full-screen loader
            if vm.isSaving {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white).scaleEffect(1.5)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
        .onAppear { prefill() }
    }

    // MARK: - Prefill for edit
    private func prefill() {
        guard let p = editingProfile else { return }
        profileName     = p.name
        shippingPercent = p.shippingHandling
        taxRate         = p.taxRate
        isDefault       = p.isDefault
    }

    // MARK: - Save
    private func save() {
        errors = vm.validate(
            name:     profileName,
            shipping: shippingPercent,
            tax:      taxRate
        )
        guard errors.isEmpty else { return }

        if let profile = editingProfile {
            vm.updateProfile(
                id:               profile.id,
                name:             profileName.trimmingCharacters(in: .whitespaces),
                shippingHandling: shippingPercent,
                taxRate:          taxRate,
                isDefault:        isDefault
            ) { success in if success { onDismiss() } }
        } else {
            vm.createProfile(
                name:             profileName.trimmingCharacters(in: .whitespaces),
                shippingHandling: shippingPercent,
                taxRate:          taxRate,
                isDefault:        isDefault
            ) { success in if success { onDismiss() } }
        }
    }

    // MARK: - Local helpers
    private func labelText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11.5, weight: .semibold))
            .foregroundColor(subtitleClr)
            .tracking(0.8)
    }

    private func errorText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11)).foregroundColor(.red)
    }
}

// MARK: - View extensions (same as original)
private extension View {
    func styledField(fieldBg: Color, borderColor: Color) -> some View {
        self
            .font(.system(size: 15))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(fieldBg)
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor, lineWidth: 1))
    }

    func customPlaceholder<Content: View>(
        when shouldShow: Bool,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow { placeholder().padding(.leading, 14) }
            self
        }
    }
}

#Preview {
    AddShippingView(
        vm: ShippingViewModel(),
        editingProfile: nil
    ) {}
}
