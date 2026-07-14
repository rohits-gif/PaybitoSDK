//
////
////  AddDiscountsProfileView.swift
////  Trading_Terminal
////
////  Created by Rajit HashCash on 14/04/26.
////
//
//import SwiftUI
//
//// MARK: - Color Extensions (reuse or keep standalone)
//extension Color {
//    static let appBg         = Color(red: 0.08, green: 0.09, blue: 0.12)
//    static let appCard       = Color(red: 0.11, green: 0.13, blue: 0.17)
//    static let appFieldBg    = Color(red: 0.13, green: 0.15, blue: 0.20)
//    static let appPurpleBtn  = Color(red: 0.56, green: 0.27, blue: 0.90)
//    static let appGreenIcon  = Color(red: 0.20, green: 0.85, blue: 0.55)
//    static let appGreenBadge = Color(red: 0.20, green: 0.78, blue: 0.50)
//    static let appRed        = Color(red: 0.93, green: 0.26, blue: 0.26)
//    static let appArrow      = Color(red: 0.55, green: 0.58, blue: 0.65)
//    static let appSubtitle   = Color(red: 0.45, green: 0.48, blue: 0.56)
//    static let appDivider    = Color(red: 0.20, green: 0.85, blue: 0.55) // green rule line
//    static let fieldBorder   = Color(red: 0.22, green: 0.25, blue: 0.32)
//    static let ruleBg        = Color(red: 0.10, green: 0.12, blue: 0.16)
//}
//
//// MARK: - Discount Rule Model
//struct DiscountRule: Identifiable {
//    let id = UUID()
//    var cartValue: String = "0.00"
//    var discountPercent: String = "10"
//}
//
//// MARK: - New Discounts Profile View
//struct NewDiscountsProfileView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var profileName: String = ""
//    @State private var rules: [DiscountRule] = [DiscountRule()]
//
//    var body: some View {
//        ZStack {
//            Color.appBg.ignoresSafeArea()
//
//            VStack(alignment: .leading, spacing: 0) {
//
//                //age Nav Row
//                HStack(spacing: 14) {
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 17, weight: .semibold))
//                            .foregroundColor(.white)
//                    }
//
//                    // Green circle + icon
//                    ZStack {
//                        Circle()
//                            .fill(Color.appGreenIcon.opacity(0.18))
//                            .frame(width: 36, height: 36)
//                            .overlay(
//                                Circle()
//                                    .stroke(Color.appGreenIcon, lineWidth: 1.5)
//                            )
//                        Image(systemName: "plus")
//                            .font(.system(size: 15, weight: .bold))
//                            .foregroundColor(Color.appGreenIcon)
//                    }
//
//                    Text("New Discounts Profile")
//                        .font(.system(size: 19, weight: .bold))
//                        .foregroundColor(.white)
//
//                    Spacer()
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 18)
//                .padding(.bottom, 22)
//
//                // Thin separator
//                Rectangle()
//                    .fill(Color.white.opacity(0.07))
//                    .frame(height: 0.5)
//                    .padding(.bottom, 24)
//
//                // PROFILE NAME
//                VStack(alignment: .leading, spacing: 10) {
//                    Text("PROFILE NAME *")
//                        .font(.system(size: 11.5, weight: .semibold))
//                        .foregroundColor(Color.appSubtitle)
//                        .tracking(0.8)
//
//                    TextField("", text: $profileName)
//                        .placeholder(when: profileName.isEmpty) {
//                            Text("e.g. Summer Sale 2025")
//                                .foregroundColor(Color.appSubtitle)
//                                .font(.system(size: 15))
//                        }
//                        .font(.system(size: 15))
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 14)
//                        .background(Color.appFieldBg)
//                        .cornerRadius(10)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 10)
//                                .stroke(Color.fieldBorder, lineWidth: 1)
//                        )
//                }
//                .padding(.horizontal, 16)
//
//                // DISCOUNT RULES header
//                HStack(spacing: 10) {
//                    Text("Discount Rules")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.white)
//
//                    // Badge  1 / 50
//                    HStack(spacing: 3) {
//                        Text("\(rules.count)")
//                            .foregroundColor(Color.appGreenBadge)
//                        Text("/ 50")
//                            .foregroundColor(Color.appSubtitle)
//                    }
//                    .font(.system(size: 12.5, weight: .semibold))
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 4)
//                    .background(Color.appGreenBadge.opacity(0.12))
//                    .cornerRadius(20)
//
//                    Spacer()
//
//                    // + Add Rule
//                    Button(action: {
//                        if rules.count < 50 { rules.append(DiscountRule()) }
//                    }) {
//                        HStack(spacing: 5) {
//                            Image(systemName: "plus")
//                                .font(.system(size: 12, weight: .bold))
//                            Text("Add Rule")
//                                .font(.system(size: 13.5, weight: .semibold))
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 9)
//                        .background(Color.appPurpleBtn)
//                        .cornerRadius(22)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 26)
//
//                // Green underline beneath "Discount Rules" row
//                Rectangle()
//                    .fill(Color.appDivider)
//                    .frame(height: 2)
//                    .padding(.horizontal, 16)
//                    .padding(.top, 6)
//
//                // ── RULES LIST
//                VStack(spacing: 10) {
//                    ForEach(Array(rules.enumerated()), id: \.element.id) { index, rule in
//                        RuleRowView(
//                            index: index + 1,
//                            cartValue: Binding(
//                                get: { rules[index].cartValue },
//                                set: { rules[index].cartValue = $0 }
//                            ),
//                            discountPercent: Binding(
//                                get: { rules[index].discountPercent },
//                                set: { rules[index].discountPercent = $0 }
//                            ),
//                            onDelete: {
//                                rules.remove(at: index)
//                            }
//                        )
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 12)
//
//                // ── CANCEL / SAVE
//                HStack(spacing: 14) {
//                    // Cancel
//                    Button(action: { dismiss() }) {
//                        Text("Cancel")
//                            .font(.system(size: 15, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(maxWidth: .infinity)
//                            .padding(.vertical, 14)
//                            .background(Color.clear)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 30)
//                                    .stroke(Color.appPurpleBtn, lineWidth: 1.8)
//                            )
//                            .cornerRadius(30)
//                    }
//
//                    // Save Profile
//                    Button(action: { saveProfile() }) {
//                        HStack(spacing: 8) {
//                            Image(systemName: "checkmark")
//                                .font(.system(size: 13, weight: .bold))
//                            Text("Save Profile")
//                                .font(.system(size: 15, weight: .semibold))
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 14)
//                        .background(Color.appPurpleBtn)
//                        .cornerRadius(30)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 28)
//
//                Spacer()
//            }
//        }
//        .navigationBarHidden(true)
//        .preferredColorScheme(.dark)
//    }
//
//    private func saveProfile() {
//        // Handle save logic here
//    }
//}
//
//// MARK: - Rule Row
//struct RuleRowView: View {
//    let index: Int
//    @Binding var cartValue: String
//    @Binding var discountPercent: String
//    let onDelete: () -> Void
//
//    var body: some View {
//        HStack(spacing: 8) {
//            // Index badge
//            Text("\(index)")
//                .font(.system(size: 12, weight: .bold))
//                .foregroundColor(.white)
//                .frame(width: 24, height: 24)
//                .background(Color.appGreenBadge.opacity(0.85))
//                .cornerRadius(6)
//
//            // "If cart >"
//            Text("If cart >")
//                .font(.system(size: 13, weight: .medium))
//                .foregroundColor(Color.appSubtitle)
//                .fixedSize()
//
//            // Cart value field
//            TextField("0.00", text: $cartValue)
//                .keyboardType(.decimalPad)
//                .font(.system(size: 14))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 9)
//                .frame(maxWidth: .infinity)
//                .background(Color.appFieldBg)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.fieldBorder, lineWidth: 1)
//                )
//
//            // Arrow
//            Image(systemName: "arrow.right")
//                .font(.system(size: 13, weight: .semibold))
//                .foregroundColor(Color.appArrow)
//
//            // Discount % field
//            TextField("10", text: $discountPercent)
//                .keyboardType(.numberPad)
//                .font(.system(size: 14))
//                .foregroundColor(.white)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 9)
//                .frame(maxWidth: .infinity)
//                .background(Color.appFieldBg)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.fieldBorder, lineWidth: 1)
//                )
//
//            // Delete
//            Button(action: onDelete) {
//                ZStack {
//                    Circle()
//                        .fill(Color.appRed)
//                        .frame(width: 26, height: 26)
//                    Image(systemName: "xmark")
//                        .font(.system(size: 10, weight: .bold))
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        .padding(.horizontal, 12)
//        .padding(.vertical, 10)
//        .background(Color.ruleBg)
//        .cornerRadius(10)
//        .overlay(
//            RoundedRectangle(cornerRadius: 10)
//                .stroke(Color.fieldBorder, lineWidth: 1)
//        )
//    }
//}
//
//// MARK: - Placeholder helper
////extension View {
////    func placeholder<Content: View>(
////        when shouldShow: Bool,
////        @ViewBuilder placeholder: () -> Content
////    ) -> some View {
////        ZStack(alignment: .leading) {
////            if shouldShow { placeholder() }
////            self
////        }
////    }
////}
//
//// MARK: - Preview
//#Preview {
//    NewDiscountsProfileView()
//}



import SwiftUI

// MARK: - Add/Edit ViewModel

@MainActor
final class AddDiscountsProfileViewModel: ObservableObject {
    @Published var profileName: String = ""
    @Published var rules: [UIDiscountRule] = []
    @Published var isDefaultProfile: Bool = false
    @Published var saving: Bool = false
    @Published var errorMessage: String?
    @Published var saved: Bool = false

    @Published var nameError: String?
    @Published var ruleErrors: [Int: RuleError] = [:]
    @Published var rulesGlobalError: String?

    private var deletedApiIds: [Int] = []

    var merchantId: Int {
        UserDefaults.standard.integer(forKey: "Bmerchant_id")
    }

    struct RuleError {
        var cartThreshold: String?
        var discountValue: String?
    }

    func populate(from profile: DiscountProfile?) {
        guard let p = profile else {
            rules = [UIDiscountRule(apiId: nil, cartThreshold: "", discountValue: "")]
            return
        }
        profileName = p.name
        isDefaultProfile = p.isDefaultProfile == 1
        rules = p.rules
        deletedApiIds = []
    }

    func addRule() {
        guard rules.count < 50 else { return }
        rules.append(UIDiscountRule(apiId: nil, cartThreshold: "", discountValue: ""))
    }

    func removeRule(at index: Int) {
        if let apiId = rules[index].apiId {
            deletedApiIds.append(apiId)
        }
        rules.remove(at: index)
    }

    private func validate() -> Bool {
        var valid = true
        nameError = nil
        ruleErrors = [:]
        rulesGlobalError = nil

        let trimmed = profileName.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            nameError = "Profile name is required"
            valid = false
        } else if trimmed.count < 2 || trimmed.count > 100 {
            nameError = "Profile name must be 2–100 characters"
            valid = false
        }

        if rules.isEmpty {
            rulesGlobalError = "Add at least one rule"
            valid = false
        }

        for (idx, rule) in rules.enumerated() {
            var re = RuleError()
            let cartVal = Double(rule.cartThreshold) ?? 0
            if rule.cartThreshold.isEmpty || cartVal <= 0 {
                re.cartThreshold = "Enter a valid cart threshold (> 0)"
                valid = false
            }
            let discVal = Double(rule.discountValue) ?? 0
            if rule.discountValue.isEmpty || discVal <= 0 {
                re.discountValue = "Enter a valid discount value (> 0)"
                valid = false
            } else if discVal > 99 {
                re.discountValue = "Percentage cannot exceed 99%"
                valid = false
            }
            if re.cartThreshold != nil || re.discountValue != nil {
                ruleErrors[idx] = re
            }
        }
        return valid
    }

    // Mirrors web handleSave:
    // 1. DELETE removed rules individually
    // 2. POST /batch with updates (existing apiId) + newDiscounts (nil apiId)
    func save() async {
        guard validate() else { return }
        saving = true
        errorMessage = nil
        do {
            for apiId in deletedApiIds {
                try await DiscountsService.shared.deleteRule(
                    merchantId: merchantId, ruleId: apiId
                )
            }

            let updates = rules
                .filter { $0.apiId != nil }
                .compactMap { rule -> BatchPayload.UpdateRule? in
                    guard let id = rule.apiId,
                          let cart = Double(rule.cartThreshold),
                          let disc = Double(rule.discountValue) else { return nil }
                    return BatchPayload.UpdateRule(
                        id: id,
                        minimumCartValue: cart,
                        discountPercentage: disc
                    )
                }

            let newDiscounts = rules
                .filter { $0.apiId == nil }
                .compactMap { rule -> BatchPayload.NewRule? in
                    guard let cart = Double(rule.cartThreshold),
                          let disc = Double(rule.discountValue) else { return nil }
                    return BatchPayload.NewRule(
                        minimumCartValue: cart,
                        discountPercentage: disc
                    )
                }

            let payload = BatchPayload(
                merchantId: merchantId,
                profileName: profileName.trimmingCharacters(in: .whitespaces),
                updates: updates,
                newDiscounts: newDiscounts,
                isDefaultProfile: isDefaultProfile ? 1 : 0
            )

            _ = try await DiscountsService.shared.batch(payload: payload)
            saved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        saving = false
    }
}

// MARK: - Rule Row

private let addProfileRuleColors: [Color] = [
    Color(red: 0.13, green: 0.77, blue: 0.37),
    Color(red: 0.23, green: 0.51, blue: 0.96),
    Color(red: 0.55, green: 0.36, blue: 0.96),
    Color(red: 0.96, green: 0.62, blue: 0.04),
    Color(red: 0.94, green: 0.27, blue: 0.27),
    Color(red: 0.02, green: 0.71, blue: 0.83),
]
private func addProfileRuleColor(_ idx: Int) -> Color {
    addProfileRuleColors[idx % addProfileRuleColors.count]
}

struct AddProfileRuleRow: View {
    let index: Int
    @Binding var rule: UIDiscountRule
    let cartError: String?
    let discountError: String?
    let onDelete: () -> Void

    private var color: Color { addProfileRuleColor(index) }

    var body: some View {
        VStack(spacing: 0) {
            // Top color bar
            Rectangle()
                .fill(color)
                .frame(height: 3)

            HStack(spacing: 8) {
                // Index badge
                Text("\(index + 1)")
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(color)
                    .frame(width: 26, height: 26)
                    .background(color.opacity(0.14))
                    .cornerRadius(7)

                Text("If cart >")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                    .fixedSize()

                // $ + cart value
                HStack(spacing: 0) {
                    Text("$")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                        .padding(.leading, 10)
                    TextField("0.00", text: Binding(
                        get: { rule.cartThreshold },
                        set: { rule.cartThreshold = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 9)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.13, green: 0.15, blue: 0.20))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(cartError != nil ? Color.red : Color(red: 0.22, green: 0.25, blue: 0.32), lineWidth: 1)
                )

                Image(systemName: "arrow.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)

                // Discount % field
                HStack(spacing: 0) {
                    TextField("10", text: Binding(
                        get: { rule.discountValue },
                        set: { rule.discountValue = $0 }
                    ))
                    .keyboardType(.decimalPad)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 9)
                    Text("%")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                        .padding(.trailing, 10)
                }
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.13, green: 0.15, blue: 0.20))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(discountError != nil ? Color.red : Color(red: 0.22, green: 0.25, blue: 0.32), lineWidth: 1)
                )

                // Delete
                Button(action: onDelete) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.93, green: 0.26, blue: 0.26))
                            .frame(width: 28, height: 28)
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            // Validation errors
            if cartError != nil || discountError != nil {
                HStack(spacing: 16) {
                    if let e = cartError {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 10))
                            Text(e).font(.system(size: 11))
                        }
                        .foregroundColor(.red)
                    }
                    if let e = discountError {
                        HStack(spacing: 3) {
                            Image(systemName: "exclamationmark.circle")
                                .font(.system(size: 10))
                            Text(e).font(.system(size: 11))
                        }
                        .foregroundColor(.red)
                    }
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.16))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 0.22, green: 0.25, blue: 0.32), lineWidth: 1)
        )
    }
}

// MARK: - Rules Preview Ladder

struct RulesPreviewLadder: View {
    let rules: [UIDiscountRule]

    var filled: [UIDiscountRule] {
        rules
            .filter { !$0.cartThreshold.isEmpty && !$0.discountValue.isEmpty }
            .sorted { (Double($0.cartThreshold) ?? 0) < (Double($1.cartThreshold) ?? 0) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 11))
                Text("RULES PREVIEW — SORTED BY CART VALUE")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.5)
            }
            .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))

            ForEach(Array(filled.enumerated()), id: \.element.id) { idx, rule in
                let color = addProfileRuleColor(idx)
                HStack(spacing: 10) {
                    Circle().fill(color).frame(width: 8, height: 8)
                    Text("If cart >")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                    Text("$\(String(format: "%.2f", Double(rule.cartThreshold) ?? 0))")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("→")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(color)
                    Text("\(rule.discountValue)% off")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(color)
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.16))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
    }
}

// MARK: - Field background / border helpers (avoid Color extension conflicts)

private let fieldBg    = Color(red: 0.13, green: 0.15, blue: 0.20)
private let fieldBorder = Color(red: 0.22, green: 0.25, blue: 0.32)
private let ruleBg     = Color(red: 0.10, green: 0.12, blue: 0.16)

// MARK: - AddDiscountsProfileView

struct AddDiscountsProfileView: View {
    let existingProfile: DiscountProfile?
    @StateObject private var vm = AddDiscountsProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    var isEditing: Bool { existingProfile != nil }

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.09, blue: 0.12).ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav Row
                HStack(spacing: 14) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                    }

                    ZStack {
                        Circle()
                            .fill(Color(red: 0.20, green: 0.85, blue: 0.55).opacity(0.15))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle().stroke(Color(red: 0.20, green: 0.85, blue: 0.55), lineWidth: 1.5)
                            )
                        Image(systemName: isEditing ? "pencil" : "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(red: 0.20, green: 0.85, blue: 0.55))
                    }

                    Text(isEditing ? "Edit — \(existingProfile?.name ?? "")" : "New Discounts Profile")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 18)
                .padding(.bottom, 18)

                Rectangle()
                    .fill(Color.white.opacity(0.07))
                    .frame(height: 0.5)

                ScrollView {
                    VStack(spacing: 24) {

                        // PROFILE NAME
                        VStack(alignment: .leading, spacing: 8) {
                            Text("PROFILE NAME *")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(red: 0.45, green: 0.48, blue: 0.56))
                                .tracking(0.8)

                            TextField("e.g. Summer Sale 2025", text: $vm.profileName)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                                .background(fieldBg)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(vm.nameError != nil ? Color.red : fieldBorder, lineWidth: 1)
                                )

                            if let e = vm.nameError {
                                HStack(spacing: 4) {
                                    Image(systemName: "exclamationmark.circle").font(.system(size: 11))
                                    Text(e).font(.system(size: 11))
                                }
                                .foregroundColor(.red)
                            }
                        }

                        // DISCOUNT RULES header + green underline
                        VStack(spacing: 0) {
                            HStack(spacing: 10) {
                                Text("Discount Rules")
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.white)

                                let atMax = vm.rules.count >= 50
                                HStack(spacing: 3) {
                                    Text("\(vm.rules.count)")
                                        .foregroundColor(atMax ? .red : Color(red: 0.20, green: 0.85, blue: 0.55))
                                    Text("/ 50")
                                        .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                                }
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background((atMax ? Color.red : Color(red: 0.20, green: 0.85, blue: 0.55)).opacity(0.1))
                                .cornerRadius(20)

                                Spacer()

                                Button(action: vm.addRule) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "plus").font(.system(size: 11, weight: .bold))
                                        Text("Add Rule").font(.system(size: 13, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(vm.rules.count >= 50 ? Color.gray : Color(red: 0.56, green: 0.27, blue: 0.90))
                                    .cornerRadius(22)
                                }
                                .disabled(vm.rules.count >= 50)
                            }

                            Rectangle()
                                .fill(Color(red: 0.20, green: 0.85, blue: 0.55))
                                .frame(height: 2)
                                .padding(.top, 8)
                        }

                        // Global rules error
                        if let e = vm.rulesGlobalError {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.circle").font(.system(size: 11))
                                Text(e).font(.system(size: 11))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        // RULES LIST
                        if vm.rules.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 26))
                                    .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65).opacity(0.4))
                                Text("No rules yet — tap + Add Rule to create your first discount rule")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65).opacity(0.6))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(32)
                            .frame(maxWidth: .infinity)
                            .background(ruleBg)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
                            )
                        } else {
                            VStack(spacing: 8) {
                                ForEach(Array(vm.rules.indices), id: \.self) { idx in
                                    AddProfileRuleRow(
                                        index: idx,
                                        rule: $vm.rules[idx],
                                        cartError: vm.ruleErrors[idx]?.cartThreshold,
                                        discountError: vm.ruleErrors[idx]?.discountValue,
                                        onDelete: { vm.removeRule(at: idx) }
                                    )
                                }
                            }

                            // Preview ladder — only when 2+ filled rules (matches web)
                            if vm.rules.filter({ !$0.cartThreshold.isEmpty && !$0.discountValue.isEmpty }).count > 1 {
                                RulesPreviewLadder(rules: vm.rules)
                            }
                        }

                        // DEFAULT PROFILE TOGGLE
                        HStack(spacing: 16) {
                            ZStack(alignment: vm.isDefaultProfile ? .trailing : .leading) {
                                Capsule()
                                    .fill(vm.isDefaultProfile
                                          ? Color(red: 0.56, green: 0.27, blue: 0.90)
                                          : Color.gray.opacity(0.4))
                                    .frame(width: 48, height: 26)
                                Circle()
                                    .fill(.white)
                                    .frame(width: 20, height: 20)
                                    .shadow(color: .black.opacity(0.25), radius: 2, y: 1)
                                    .padding(3)
                            }
                            .animation(.spring(response: 0.2), value: vm.isDefaultProfile)
                            .onTapGesture { vm.isDefaultProfile.toggle() }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Set as Default Profile")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("This profile will be pre-selected at checkout")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.55, green: 0.58, blue: 0.65))
                            }
                            Spacer()
                        }
                        .padding(16)
                        .background(ruleBg)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )

                        // API error banner
                        if let e = vm.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text(e)
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.12))
                            .cornerRadius(10)
                        }

                        // CANCEL / SAVE
                        HStack(spacing: 14) {
                            Button(action: { dismiss() }) {
                                Text("Cancel")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color(red: 0.56, green: 0.27, blue: 0.90), lineWidth: 1.8)
                                    )
                            }
                            .disabled(vm.saving)

                            Button(action: {
                                Task {
                                    await vm.save()
                                    if vm.saved { dismiss() }
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if vm.saving {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text("Saving…")
                                    } else {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 13, weight: .bold))
                                        Text("Save Profile")
                                    }
                                }
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    vm.saving
                                    ? Color(red: 0.56, green: 0.27, blue: 0.90).opacity(0.7)
                                    : Color(red: 0.56, green: 0.27, blue: 0.90)
                                )
                                .cornerRadius(30)
                            }
                            .disabled(vm.saving)
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(16)
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationBarHidden(true)
        .onAppear {
            vm.populate(from: existingProfile)
        }
    }
}

#Preview {
    AddDiscountsProfileView(existingProfile: nil)
}

#Preview("Edit Mode") {
    AddDiscountsProfileView(existingProfile: DiscountProfile(
        id: "Summer Sale",
        name: "Summer Sale",
        isDefaultProfile: 1,
        rules: [
            UIDiscountRule(apiId: 1, cartThreshold: "50", discountValue: "5"),
            UIDiscountRule(apiId: 2, cartThreshold: "100", discountValue: "10"),
        ]
    ))
}
