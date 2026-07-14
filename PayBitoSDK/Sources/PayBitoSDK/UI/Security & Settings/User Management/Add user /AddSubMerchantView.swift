//  AddSubMerchantView.swift
//  Trading_Terminal

import SwiftUI

struct AddSubMerchantView: View {

    var onCreate: (SubMerchantCreatedModel?) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: AddSubMerchantViewModel = AddSubMerchantViewModel()

    @State private var showPassword: Bool = false
    @State private var showConfirm:  Bool = false

    private let genders: [String] = ["Mr.", "Mrs.", "Other"]
    private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)

    // MARK: - Binding Helpers
    private func readBinding(for menuId: Int) -> Binding<Bool> {
        Binding(
            get: { self.vm.readValue(for: menuId) },
            set: { self.vm.setRead($0, for: menuId) }
        )
    }

    private func writeBinding(for menuId: Int) -> Binding<Bool> {
        Binding(
            get: { self.vm.writeValue(for: menuId) },
            set: { self.vm.setWrite($0, for: menuId) }
        )
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    addHeader
                    VStack(spacing: 20) {
                        formCard
                        permissionsCard
                        actionButtons
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }
            .allowsHitTesting(!vm.isCreating)

            // ── Loading overlay ──
            if vm.isCreating {
                Color.black.opacity(0.60)
                    .ignoresSafeArea()
                    .transition(.opacity)

                VStack(spacing: 14) {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                    Text("Creating sub-account…")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.10, green: 0.12, blue: 0.19))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.10), lineWidth: 1)
                        )
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.22), value: vm.isCreating)
        .alert("Error", isPresented: Binding(
            get: { vm.createError != nil },
            set: { if !$0 { vm.createError = nil } }
        )) {
            Button("OK", role: .cancel) { vm.createError = nil }
        } message: {
            Text(vm.createError ?? "")
        }
        .onAppear {
            debugPrint("👁️ [AddSubMerchantView] appeared — fetching menus")
            vm.fetchMenus()
        }
    }

    // MARK: - Header
    private var addHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Add New Sub Merchant")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Create a new sub-account with custom permissions")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.50))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 4)
    }

    // MARK: - Form Card
    private var formCard: some View {
        VStack(spacing: 16) {

            // ✅ Use inputText: label everywhere
            UMField(label: "First Name", placeholder: "Enter first name",
                    inputText: $vm.firstName)
            UMField(label: "Last Name",  placeholder: "Enter last name",
                    inputText: $vm.lastName)

            // Gender Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Gender")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.60))
                HStack(spacing: 10) {
                    ForEach(genders, id: \.self) { g in
                        Button(action: { vm.gender = g }) {
                            Text(g)
                                .font(.system(size: 14,
                                             weight: vm.gender == g ? .bold : .medium))
                                .foregroundColor(vm.gender == g ? purple : .white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 46)
                                .background(
                                    vm.gender == g
                                        ? purple.opacity(0.15)
                                        : Color(red: 0.12, green: 0.15, blue: 0.22)
                                )
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            vm.gender == g
                                                ? purple
                                                : Color.white.opacity(0.12),
                                            lineWidth: 1.5
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            UMField(label: "Email", placeholder: "Enter email address",
                    inputText: $vm.email, keyboard: .emailAddress)

            // Phone
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.60))
                HStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Text("🇺🇸").font(.system(size: 16))
                        Text("+1")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.50))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
                    .background(Color(red: 0.12, green: 0.15, blue: 0.22))

                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 1)

                    // ✅ Direct TextField — no custom wrapper needed here
                    TextField("Enter phone number", text: $vm.phone)
                        .keyboardType(.phonePad)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                }
                .frame(height: 50)
                .background(Color(red: 0.12, green: 0.15, blue: 0.22))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
            }

            UMSecureField(label: "Password",
                          placeholder: "Enter password",
                          inputText: $vm.password,
                          show: $showPassword)

            UMSecureField(label: "Confirm Password",
                          placeholder: "Re-enter password",
                          inputText: $vm.confirmPwd,
                          show: $showConfirm)
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Permissions Card
    private var permissionsCard: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Access Permissions")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
                .padding(.bottom, 12)

            HStack {
                Text("MENU")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("READ")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                    .frame(width: 56, alignment: .center)
                Text("WRITE")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                    .frame(width: 56, alignment: .center)
            }
            .padding(.bottom, 8)

            if vm.isLoadingMenus {
                HStack {
                    Spacer()
                    ProgressView().tint(.white)
                    Text("Loading menus…")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.50))
                        .padding(.leading, 8)
                    Spacer()
                }
                .padding(.vertical, 24)

            } else if let errorMsg = vm.menuLoadError {
                VStack(spacing: 8) {
                    Text("Failed to load menus")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.red)
                    Text(errorMsg)
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.50))
                        .multilineTextAlignment(.center)
                    Button(action: { vm.fetchMenus() }) {
                        Text("Retry")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(purple)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)

            } else {
                VStack(spacing: 6) {
                    ForEach(vm.menuItems) { item in
                        PermissionRow(
                            menu:    item.name,
                            readOn:  readBinding(for: item.id),
                            writeOn: writeBinding(for: item.id)
                        )
                    }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        HStack(spacing: 12) {

            Button(action: { dismiss() }) {
                Text("Cancel")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.30), lineWidth: 1.5)
                    )
            }
            .buttonStyle(.plain)
            .disabled(vm.isCreating)

            Button(action: handleCreate) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            vm.isFormValid
                                ? Color(red: 0.20, green: 0.40, blue: 0.95)
                                : Color.gray.opacity(0.40)
                        )
                    if vm.isCreating {
                        ProgressView().tint(.white).scaleEffect(0.85)
                    } else {
                        Text("Create Sub-account")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
            }
            .buttonStyle(.plain)
            .disabled(!vm.isFormValid || vm.isCreating)
        }
    }

    // MARK: - Handle Create
    private func handleCreate() {
        debugPrint("🚀 [AddSubMerchantView] handleCreate tapped")
        debugPrint("   firstName : \(vm.firstName)")
        debugPrint("   lastName  : \(vm.lastName)")
        debugPrint("   gender    : \(vm.gender)")
        debugPrint("   email     : \(vm.email)")
        debugPrint("   phone     : \(vm.phone)")

        vm.createSubMerchant { model in
            if let model {
                debugPrint("✅ [AddSubMerchantView] success — dismissing")
                onCreate(model)
                dismiss()
            } else {
                debugPrint("⚠️ [AddSubMerchantView] failed — alert shown")
            }
        }
    }
}

// MARK: - Permission Row
private struct PermissionRow: View {
    let menu:    String
    @Binding var readOn:  Bool
    @Binding var writeOn: Bool

    private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)

    var body: some View {
        HStack {
            Text(menu)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: { readOn.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(readOn ? purple : Color.clear)
                        .frame(width: 24, height: 24)
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(purple, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    if readOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: 56)

            Button(action: { writeOn.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(writeOn ? purple : Color.clear)
                        .frame(width: 24, height: 24)
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(purple, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                    if writeOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: 56)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(red: 0.12, green: 0.15, blue: 0.22))
        .cornerRadius(10)
    }
}

// MARK: - UMField
// ✅ Renamed 'text' → 'inputText' to avoid Binding<Subject> conflict
private struct UMField: View {
    let label:       String
    let placeholder: String
    @Binding var inputText: String          // ✅ fixed
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.60))
            TextField(placeholder, text: $inputText)  // ✅ $inputText
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .padding(14)
                .background(Color(red: 0.12, green: 0.15, blue: 0.22))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
    }
}

// MARK: - UMSecureField
// ✅ Renamed 'text' → 'inputText' to avoid Binding<Subject> conflict
private struct UMSecureField: View {
    let label:       String
    let placeholder: String
    @Binding var inputText: String          // ✅ fixed
    @Binding var show:      Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.60))
            HStack {
                Group {
                    if show {
                        TextField(placeholder, text: $inputText)
                    } else {
                        SecureField(placeholder, text: $inputText)
                    }
                }
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .foregroundColor(.white)

                Button(action: { show.toggle() }) {
                    Image(systemName: show ? "eye" : "eye.slash")
                        .foregroundColor(.white.opacity(0.40))
                }
            }
            .padding(14)
            .background(Color(red: 0.12, green: 0.15, blue: 0.22))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
        }
    }
}

// MARK: - Preview
#Preview {
    AddSubMerchantView(onCreate: { (_: SubMerchantCreatedModel?) in })
}
