////
////  RedirectsView.swift
////  Trading_Terminal
////
////  Created by Sk Jasimuddin on 17/04/26.


// MARK: - RedirectsView.swift


import SwiftUI

struct RedirectsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = RedirectsViewModel()

    private let bg = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.07, blue: 0.12),
            Color(red: 0.02, green: 0.04, blue: 0.08)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    private let purple = Color(red: 0.60, green: 0.35, blue: 0.95)
    private let blue   = Color(red: 0.20, green: 0.55, blue: 0.95)
    private let green  = Color(red: 0.13, green: 0.77, blue: 0.37)
    private let red    = Color(red: 0.94, green: 0.27, blue: 0.27)
    private let cardBg = Color(red: 0.10, green: 0.12, blue: 0.18)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar

                Divider()
                    .background(Color.white.opacity(0.08))

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        defaultRedirectCard
                        templateSection
                    }
                    .padding(16)
                    .padding(.bottom, 100)
                }
            }

            if !vm.isReadOnly {
                floatingButton
            }

            if let toast = vm.toast {
                RDToastView(
                    message: toast.message,
                    isSuccess: toast.isSuccess
                )
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        vm.clearToast()
                    }
                }
            }

            if let cs = vm.confirmState {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()

                RDConfirmDialog(state: cs) {
                    vm.confirmState = nil
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.loadAll()
        }
        .fullScreenCover(isPresented: $vm.isModalOpen) {
            RedirectFormModal(vm: vm)
        }
    }
}

// MARK: Header
extension RedirectsView {
    private var headerBar: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Redirects")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)

                Text("Control where customers are sent after checkout")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }

            Spacer()

            if !vm.isReadOnly {
                Button {
                    vm.openModal(id: nil)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Create")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [purple, blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(22)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    private var floatingButton: some View {
        Button {
            vm.openModal(id: nil)
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 58, height: 58)
                .background(
                    LinearGradient(
                        colors: [purple, blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: purple.opacity(0.5), radius: 12, x: 0, y: 6)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 30)
    }
}

// MARK: Default Redirect Card
extension RedirectsView {
    private var defaultRedirectCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Default Redirects")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if vm.isDefaultActive {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Active Default")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(green)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(green.opacity(0.3))
                    )
                    .cornerRadius(16)
                }
            }

            Text("Applied globally to all payments when no specific template is selected")
                .font(.system(size: 12))
                .foregroundColor(.gray)

            RDURLRow(
                icon: "checkmark.circle.fill",
                iconColor: green,
                label: "Success URL",
                value: vm.defaultRedirect?.successURL ?? "",
                placeholder: "https://yourdomain.com/success"
            )

            RDURLRow(
                icon: "xmark.circle.fill",
                iconColor: red,
                label: "Failure URL",
                value: vm.defaultRedirect?.failureURL ?? "",
                placeholder: "https://yourdomain.com/failure"
            )

            RDURLRow(
                icon: "info.circle",
                iconColor: .gray,
                label: "Cancel URL",
                value: vm.defaultRedirect?.cancelURL ?? "",
                placeholder: "https://yourdomain.com/cancel",
                isOptional: true
            )

            if !vm.isReadOnly {
                Button {
                    vm.makeDefaultCard()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "star")
                        Text("Make Default")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(green)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(green.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(green.opacity(0.3))
                    )
                    .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(green.opacity(0.25))
        )
    }
}

// MARK: Template Section
extension RedirectsView {
    private var templateSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Redirect Templates")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(vm.templates.count)")
                    .foregroundColor(.gray)
            }

            if vm.isLoading {
                loadingState
            } else if vm.templates.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(vm.templates) { template in
                        RDTemplateCard(
                            template: template,
                            isReadOnly: vm.isReadOnly,
                            green: green,
                            purple: purple,
                            red: red,
                            onEdit: {
                                vm.openModal(id: template.id)
                            },
                            onDelete: {
                                vm.deleteTemplate(id: template.id)
                            },
                            onDefault: {
                                vm.setTemplateDefault(id: template.id)
                            }
                        )
                    }
                }
            }
        }
    }

    private var loadingState: some View {
        VStack(spacing: 12) {
            ProgressView()
                .tint(.white)

            Text("Loading templates...")
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "arrow.uturn.right")
                .font(.system(size: 30))
                .foregroundColor(purple)

            Text("No templates yet")
                .foregroundColor(.white)

            if !vm.isReadOnly {
                Button("Create Redirect Template") {
                    vm.openModal(id: nil)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [purple, blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
}

// MARK: URL Row
struct RDURLRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    let placeholder: String
    var isOptional: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(iconColor)

                Text(label)
                    .foregroundColor(.white)

                if isOptional {
                    Text("optional")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
            }

            Text(value.isEmpty ? placeholder : value)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(value.isEmpty ? .gray : .white.opacity(0.8))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.05))
                .cornerRadius(10)
        }
    }
}

// MARK: Template Card
struct RDTemplateCard: View {
    let template: RedirectTemplate
    let isReadOnly: Bool
    let green: Color
    let purple: Color
    let red: Color
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDefault: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(template.name)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if template.isDefault {
                    Text("Default")
                        .foregroundColor(green)
                }
            }

            urlRow(
                title: "Success URL",
                value: template.successMode == .hosted ? "Hosted page" : template.successURL
            )

            urlRow(
                title: "Failure URL",
                value: template.failureMode == .hosted ? "Hosted page" : template.failureURL
            )

            if !isReadOnly {
                HStack {
                    Button("Edit", action: onEdit)

                    if !template.isDefault {
                        Button("Delete", action: onDelete)
                        Button("Set Default", action: onDefault)
                    }
                }
            }
        }
        .padding()
        .background(Color.white.opacity(0.04))
        .cornerRadius(14)
    }

    private func urlRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .foregroundColor(.gray)

            Text(value)
                .foregroundColor(.white)
                .lineLimit(2)
        }
    }
}

// MARK: - Template Row
struct RDTemplateRow: View {
    let template:   RedirectTemplate
    let isReadOnly: Bool
    let green:      Color
    let purple:     Color
    let red:        Color
    let onEdit:     () -> Void
    let onDelete:   () -> Void
    let onDefault:  () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                // Name
                Text(template.name)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)

                // Success URL
                Group {
                    if template.successMode == .hosted {
                        Text("Hosted page").italic()
                            .foregroundColor(.white.opacity(0.3))
                    } else {
                        Text(template.successURL.isEmpty ? "—" : template.successURL)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 120, alignment: .leading)
                .lineLimit(1)

                // Failure URL
                Group {
                    if template.failureMode == .hosted {
                        Text("Hosted page").italic()
                            .foregroundColor(.white.opacity(0.3))
                    } else {
                        Text(template.failureURL.isEmpty ? "—" : template.failureURL)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .font(.system(size: 12, design: .monospaced))
                .frame(width: 120, alignment: .leading)
                .lineLimit(1)

                // Default badge
                Group {
                    if template.isDefault {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
                            Text("Default").font(.system(size: 11, weight: .bold))
                        }
                        .foregroundColor(green)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(green.opacity(0.1))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(green.opacity(0.3)))
                        .cornerRadius(12)
                    } else {
                        Text("—").foregroundColor(.white.opacity(0.2))
                    }
                }
                .frame(width: 70, alignment: .leading)

                // Actions
                if !isReadOnly {
                    HStack(spacing: 7) {
                        Button("Edit") { onEdit() }
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(purple)
                            .padding(.horizontal, 12).padding(.vertical, 5)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(purple.opacity(0.4)))
                            .cornerRadius(7)

                        if !template.isDefault {
                            Button("Delete") { onDelete() }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(red)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .overlay(RoundedRectangle(cornerRadius: 7).stroke(red.opacity(0.35)))
                                .cornerRadius(7)

                            Button("Set Default") { onDefault() }
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Color(r:0.13, g:0.77, b:0.37))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .overlay(RoundedRectangle(cornerRadius: 7)
                                    .stroke(Color(r:0.13, g:0.77, b:0.37).opacity(0.4)))
                                .cornerRadius(7)
                        }
                    }
                    .frame(width: 200, alignment: .leading)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
        }
    }
}

// MARK: - Confirm Dialog
struct RDConfirmDialog: View {
    let state:    ConfirmDialogState
    let onCancel: () -> Void

    private let purple = Color(r:0.60, g:0.35, b:0.95)
    private let red    = Color(r:0.94, g:0.27, b:0.27)
    private let cardBg = Color(r:0.10, g:0.12, b:0.18)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(state.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            Text(state.body)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
            HStack(spacing: 10) {
                Spacer()
                Button("Cancel", action: onCancel)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.2)))
                    .cornerRadius(8)

                Button(state.btnLabel) {
                    onCancel()
                    state.onConfirm()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(state.isDanger ? red : .white)
                .padding(.horizontal, 16).padding(.vertical, 8)
//                .background(state.isDanger
//                            ? red.opacity(0.12)
//                            : LinearGradient(colors: [purple, Color(r:0.20, g:0.55, b:0.95)],
//                                             startPoint: .leading, endPoint: .trailing))
                .overlay(state.isDanger
                         ? AnyView(RoundedRectangle(cornerRadius: 8).stroke(red.opacity(0.35)))
                         : AnyView(EmptyView()))
                .cornerRadius(8)
            }
        }
        .padding(24)
        .background(cardBg)
        .cornerRadius(16)
        .padding(.horizontal, 28)
        .shadow(color: .black.opacity(0.4), radius: 30)
    }
}

// MARK: - Toast
struct RDToastView: View {
    let message:   String
    let isSuccess: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            Text(message).font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 18).padding(.vertical, 12)
        .background(isSuccess ? Color(r:0.13, g:0.77, b:0.37) : Color(r:0.94, g:0.27, b:0.27))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.25), radius: 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 24).padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.3), value: message)
    }
}

#Preview { RedirectsView() }
