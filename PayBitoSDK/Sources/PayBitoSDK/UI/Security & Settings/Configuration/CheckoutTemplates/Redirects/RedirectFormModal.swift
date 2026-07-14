// MARK: - RedirectFormModal.swift
// Create / Edit modal — mirrors React's modal section exactly.
// Radio cards, URL inputs with validation, collapsible Advanced Options, example output.

import SwiftUI

struct RedirectFormModal: View {

    @ObservedObject var vm: RedirectsViewModel
    @Environment(\.dismiss) private var dismiss

    private let purple = Color(red: 0.60, green: 0.35, blue: 0.95)
    private let blue   = Color(red: 0.20, green: 0.55, blue: 0.95)
    private let green  = Color(red: 0.13, green: 0.77, blue: 0.37)
    private let red    = Color(red: 0.94, green: 0.27, blue: 0.27)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.18)

    private let bg = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.07, blue: 0.12),
            Color(red: 0.02, green: 0.04, blue: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()
            VStack(spacing: 0) {
                modalHeader
                Divider().background(Color.white.opacity(0.08))
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        nameField
                        successSection
                        failureSection
                        advancedSection
                        Spacer(minLength: 80)
                    }
                    .padding(20)
                }
                modalFooter
            }

            // Toast from save errors
            if let t = vm.toast {
                RDToastView(message: t.message, isSuccess: t.isSuccess)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { vm.clearToast() }
                    }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Modal Header
    private var modalHeader: some View {
        HStack(spacing: 12) {
            Button { vm.closeModal(); dismiss() } label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white.opacity(0.6))
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 30, height: 30)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(7)
            }
            Text(vm.editingId != nil ? "Edit Redirect Template" : "Create Redirect Template")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
    }

    // MARK: - Template Name Field
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Text("Template Name")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white.opacity(0.55))
                Text("*").foregroundColor(red)
            }

            ZStack(alignment: .leading) {
                if vm.tplName.isEmpty {
                    Text("e.g. Campaign A Redirects")
                        .foregroundColor(.gray.opacity(0.4))
                        .padding(.horizontal, 14)
                }
                TextField("", text: $vm.tplName)
                    .foregroundColor(.white)
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .onChange(of: vm.tplName) { _ in vm.nameError = "" }
            }
            .background(Color.white.opacity(0.07))
            .cornerRadius(9)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(vm.nameError.isEmpty ? Color.white.opacity(0.1) : red, lineWidth: 1.5)
            )

            if !vm.nameError.isEmpty {
                Text(vm.nameError).font(.system(size: 11)).foregroundColor(red)
            }
        }
    }

    // MARK: - Success Section
    private var successSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ON PAYMENT SUCCESS")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .tracking(0.8)
                .padding(.bottom, 2)

            // Radio: Redirect to URL
            RDRadioCard(
                title:      "Redirect to URL",
                isSelected: vm.successMode == .url,
                onTap:      { vm.successMode = .url }
            ) {
                if vm.successMode == .url {
                    VStack(alignment: .leading, spacing: 6) {
                        ZStack(alignment: .leading) {
                            if vm.tplSuccess.isEmpty {
                                Text("https://yourdomain.com/success")
                                    .foregroundColor(.gray.opacity(0.4))
                                    .padding(.horizontal, 12)
                            }
                            TextField("", text: $vm.tplSuccess)
                                .foregroundColor(.white)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .padding(.horizontal, 12).padding(.vertical, 10)
                                .onChange(of: vm.tplSuccess) { _ in vm.successUrlError = "" }
                        }
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.successUrlError.isEmpty ? Color.white.opacity(0.1) : red,
                                        lineWidth: 1.5)
                        )
                        if !vm.successUrlError.isEmpty {
                            Text(vm.successUrlError).font(.system(size: 11)).foregroundColor(red)
                        }
                    }
                    .padding(.leading, 28)
                    .padding(.top, 8)
                }
            }

            // Radio: Hosted page
            RDRadioCard(
                title:      "Show hosted success page",
                isSelected: vm.successMode == .hosted,
                onTap:      { vm.successMode = .hosted }
            )
        }
    }

    // MARK: - Failure Section
    private var failureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ON PAYMENT FAILURE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.3))
                .tracking(0.8)
                .padding(.bottom, 2)

            RDRadioCard(
                title:      "Redirect to URL",
                isSelected: vm.failureMode == .url,
                onTap:      { vm.failureMode = .url }
            ) {
                if vm.failureMode == .url {
                    VStack(alignment: .leading, spacing: 6) {
                        ZStack(alignment: .leading) {
                            if vm.tplFailure.isEmpty {
                                Text("https://yourdomain.com/failure")
                                    .foregroundColor(.gray.opacity(0.4))
                                    .padding(.horizontal, 12)
                            }
                            TextField("", text: $vm.tplFailure)
                                .foregroundColor(.white)
                                .keyboardType(.URL)
                                .autocapitalization(.none)
                                .padding(.horizontal, 12).padding(.vertical, 10)
                                .onChange(of: vm.tplFailure) { _ in vm.failureUrlError = "" }
                        }
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(vm.failureUrlError.isEmpty ? Color.white.opacity(0.1) : red,
                                        lineWidth: 1.5)
                        )
                        if !vm.failureUrlError.isEmpty {
                            Text(vm.failureUrlError).font(.system(size: 11)).foregroundColor(red)
                        }
                    }
                    .padding(.leading, 28)
                    .padding(.top, 8)
                }
            }

            RDRadioCard(
                title:      "Show hosted failure page",
                isSelected: vm.failureMode == .hosted,
                onTap:      { vm.failureMode = .hosted }
            )
        }
    }

    // MARK: - Advanced Options (collapsible — mirrors rd-col-hdr/rd-col-body in React)
    private var advancedSection: some View {
        VStack(spacing: 0) {
            // Collapse header
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { vm.advOpen.toggle() }
            } label: {
                HStack {
                    Image(systemName: "gearshape.2").font(.system(size: 14))
                    Text("Advanced Options").font(.system(size: 13, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .rotationEffect(.degrees(vm.advOpen ? 180 : 0))
                        .foregroundColor(.white.opacity(0.4))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14).padding(.vertical, 12)
            }
            .background(Color.white.opacity(0.06))
            .cornerRadius(vm.advOpen ? 0 : 9)
            .overlay(
                RoundedRectangle(cornerRadius: vm.advOpen ? 0 : 9)
                    .stroke(Color.white.opacity(0.1))
            )
            .clipShape(
                vm.advOpen
                    ? AnyShape(UnevenRoundedRectangle(topLeadingRadius: 9, topTrailingRadius: 9))
                    : AnyShape(RoundedRectangle(cornerRadius: 9))
            )

            // Collapse body
            if vm.advOpen {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Append query parameters to redirect URLs")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.45))

                    // Checkboxes
                    RDCheckbox(label: "payment_id",     isOn: $vm.qpPaymentId, purple: purple)
                    RDCheckbox(label: "status",         isOn: $vm.qpStatus,    purple: purple)
                    RDCheckbox(label: "customer_email", isOn: $vm.qpEmail,     purple: purple)
                    RDCheckbox(label: "amount",         isOn: $vm.qpAmount,    purple: purple)

                    // Example output — mirrors exampleOutput computed property
                    Text("EXAMPLE OUTPUT")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(0.5)
                        .padding(.top, 4)

                    Text(vm.exampleOutput)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(purple.opacity(0.9))
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(purple.opacity(0.08))
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(purple.opacity(0.15)))
                }
                .padding(14)
                .background(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.white.opacity(0.1))
                )
                .clipShape(
                    UnevenRoundedRectangle(bottomLeadingRadius: 9, bottomTrailingRadius: 9)
                )
            }
        }
    }

    // MARK: - Modal Footer (Cancel / Save / Save & Make Default)
    private var modalFooter: some View {
        VStack(spacing: 0) {
            Divider().background(Color.white.opacity(0.08))
            HStack(spacing: 10) {
                Button("Cancel") { vm.closeModal(); dismiss() }
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(height: 44)
                    .padding(.horizontal, 20)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2)))
                    .cornerRadius(10)
                    .disabled(vm.isSaving)

                Button {

                    vm.saveTemplate(makeDefault: false) {

                        dismiss()

                    }

                } label: {
                    if vm.isSaving {
                        HStack(spacing: 6) {
                            ProgressView().tint(.white).scaleEffect(0.8)
                            Text("Saving…")
                        }
                    } else {
                        Text("Save Template")
                    }
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    LinearGradient(colors: [purple, blue], startPoint: .leading, endPoint: .trailing)
                        .opacity(vm.isSaving ? 0.7 : 1.0)
                )
                .cornerRadius(10)
                .disabled(vm.isSaving)

                Button {
                    vm.saveTemplate(makeDefault: true) {
                        dismiss()
                    }
                } label: {
                    Text(vm.isSaving ? "Saving…" : "Save & Make Default")
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(green)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(green.opacity(0.12))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(green.opacity(0.35))
                )
                .disabled(vm.isSaving)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .background(Color.black.opacity(0.15))
    }

    // MARK: - Helpers
    // Published flag check after save
    private var didSaveSuccessfully: Bool { vm.didSaveSuccessfully }
}

// Expose flag on VM for footer logic
extension RedirectsViewModel {
    var didSaveSuccessfully: Bool {
        // The VM closes the modal on success via closeModal()
        // so we just check !isModalOpen after save
        return !isModalOpen && !isSaving
    }
}

// MARK: - Radio Card Component (mirrors rd-rc in React)
struct RDRadioCard<Content: View>: View {
    let title:      String
    let isSelected: Bool
    let onTap:      () -> Void
    var content:    () -> Content

    private let purple = Color(r:0.60, g:0.35, b:0.95)

    init(title: String,
         isSelected: Bool,
         onTap: @escaping () -> Void,
         @ViewBuilder content: @escaping () -> Content = { EmptyView() }) {
        self.title      = title
        self.isSelected = isSelected
        self.onTap      = onTap
        self.content    = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(isSelected ? purple : Color.white.opacity(0.3), lineWidth: 1.5)
                            .frame(width: 18, height: 18)
                        if isSelected {
                            Circle().fill(purple).frame(width: 9, height: 9)
                        }
                    }
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }

            content()
                .padding(.horizontal, 14)
                .padding(.bottom, isSelected ? 12 : 0)
        }
        .background(isSelected ? purple.opacity(0.05) : Color.white.opacity(0.04))
        .cornerRadius(9)
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .stroke(isSelected ? purple.opacity(0.45) : Color.white.opacity(0.1), lineWidth: 1.5)
        )
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}

// MARK: - Checkbox Component (mirrors rd-chk in React)
struct RDCheckbox: View {
    let label:  String
    @Binding var isOn: Bool
    let purple: Color

    var body: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: 10) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(isOn ? purple : .white.opacity(0.35))
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.white)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(purple.opacity(0.1))
                    .cornerRadius(4)
                Spacer()
            }
        }
    }
}

// MARK: - AnyShape helper for mixed corner radii
struct AnyShape: Shape {
    private let base: (CGRect) -> Path
    init<S: Shape>(_ shape: S) { base = { shape.path(in: $0) } }
    func path(in rect: CGRect) -> Path { base(rect) }
}

// MARK: - UnevenRoundedRectangle (iOS 16 backport for mixed corners)
struct UnevenRoundedRectangle: Shape {
    var topLeadingRadius:    CGFloat = 0
    var topTrailingRadius:   CGFloat = 0
    var bottomLeadingRadius: CGFloat = 0
    var bottomTrailingRadius: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let tl = topLeadingRadius
        let tr = topTrailingRadius
        let bl = bottomLeadingRadius
        let br = bottomTrailingRadius

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                    radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                    radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                    radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                    radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()
        return path
    }
}

#Preview { RedirectFormModal(vm: RedirectsViewModel()) }
