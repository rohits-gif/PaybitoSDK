
// MARK: - BuyerInfoView.swift


import SwiftUI

struct BuyerInfoView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = BuyerInfoViewModel()

    @State private var showAdd  = false
    @State private var editTarget: BuyerInfoProfile? = nil

    // Colors
    private let bg    = LinearGradient(colors: [Color(r:0.05,g:0.07,b:0.12), Color(r:0.02,g:0.04,b:0.08)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
    private let purple = Color(r:0.60, g:0.35, b:0.95)
    private let blue   = Color(r:0.20, g:0.55, b:0.95)

    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                Divider().background(Color.white.opacity(0.08))
                contentArea
            }

            // Toast overlay
            if let t = vm.toast {
                ToastView(message: t.message, isSuccess: t.isSuccess)
                    .onAppear { DispatchQueue.main.asyncAfter(deadline: .now() + 3) { vm.clearToast() } }
            }

            // Delete confirm modal
            if vm.deleteTarget != nil {
                Color.black.opacity(0.5).ignoresSafeArea()
                DeleteConfirmModal(
                    profileName: vm.deleteTarget?.name ?? "",
                    isDeleting:  vm.isDeleting,
                    onConfirm:   { vm.confirmDelete() },
                    onCancel:    { vm.cancelDelete() }
                )
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .onAppear { vm.fetchProfiles() }
        .fullScreenCover(isPresented: $showAdd, onDismiss: { vm.fetchProfiles() }) {
            AddEditBuyerInfoView(mode: .add)
        }
        .fullScreenCover(item: $editTarget, onDismiss: { vm.fetchProfiles() }) { profile in
            AddEditBuyerInfoView(mode: .edit(profile))
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .foregroundColor(.white)
                    .font(.system(size: 18, weight: .semibold))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Buyer Info")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Text("Configure what data to collect at checkout")
                    .font(.system(size: 12))
                    .foregroundColor(.gray.opacity(0.7))
            }

            Spacer()

            if !vm.isLoading && !vm.isReadOnly {
                Button { showAdd = true } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                        Text("Add Profile")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(LinearGradient(colors: [purple, blue], startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(18)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 16)
    }

    // MARK: - Content Area
    @ViewBuilder
    private var contentArea: some View {
        if vm.isLoading {
            // Skeleton loading state
            ScrollView {
                VStack(spacing: 16) {
                    ProfileSkeletonView()
                    ProfileSkeletonView()
                }
                .padding(16)
            }
        } else if vm.profiles.isEmpty {
            emptyState
        } else {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(vm.profiles) { profile in
                            ProfileCardView(
                                profile:    profile,
                                isReadOnly: vm.isReadOnly,
                                onEdit:     { editTarget = profile },
                                onDelete:   { vm.requestDelete(profile: profile) }
                            )
                        }
                    }
                    .padding(16)
                    .padding(.bottom, 80)
                }

                // Floating + button (matches screenshot)
                if !vm.isReadOnly {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(LinearGradient(colors: [blue, blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(16)
                            .shadow(color: blue.opacity(0.4), radius: 10, x: 0, y: 6)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "person")
                .font(.system(size: 40))
                .foregroundColor(purple)
            Text("No buyer info profiles")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .padding(.top, 16)
            Text("Create a profile to define what\ninformation to collect from buyers")
                .font(.system(size: 14))
                .foregroundColor(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.top, 8)
            Spacer()

            // Floating + button
            if !vm.isReadOnly {
                HStack {
                    Spacer()
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(LinearGradient(colors: [blue, blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .cornerRadius(16)
                            .shadow(color: blue.opacity(0.4), radius: 10, x: 0, y: 6)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                }
            }
        }
    }
}

// MARK: - Profile Card
struct ProfileCardView: View {
    let profile:    BuyerInfoProfile
    let isReadOnly: Bool
    let onEdit:     () -> Void
    let onDelete:   () -> Void

    private let purple = Color(r:0.60, g:0.35, b:0.95)
    private let cardBg = Color(r:0.10, g:0.12, b:0.18)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Card header
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(purple.opacity(0.15))
                        .frame(width: 36, height: 36)
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(purple)
                        .font(.system(size: 16))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)

                    let stdCount = profile.stdFields.filter { $0.enabled }.count
                    let cfCount  = profile.customFields.count
                    Text("\(stdCount) std + \(cfCount) custom field\(cfCount != 1 ? "s" : "")")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                }

                Spacer()

                if profile.isDefaultProfile {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill").font(.system(size: 10))
                        Text("Default")
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(r:0.23, g:0.51, b:0.96))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(r:0.23, g:0.51, b:0.96).opacity(0.12))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(r:0.23, g:0.51, b:0.96).opacity(0.25)))
                    .cornerRadius(20)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            // Edit / Delete buttons
            if !isReadOnly {
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(purple)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 7)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(purple))
                        .cornerRadius(10)
                    }

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color(r:0.94, g:0.27, b:0.27))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(Color(r:0.94, g:0.27, b:0.27).opacity(0.1))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
            }

            Divider().background(Color.white.opacity(0.08))

            // Field chips
            let enabledStd = profile.stdFields.filter { $0.enabled }
            let custom     = profile.customFields
            if enabledStd.isEmpty && custom.isEmpty {
                Text("No fields configured")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(16)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(enabledStd) { f in
                        FieldChip(icon: f.icon, label: f.label, color: purple)
                    }
                    ForEach(custom) { f in
                        FieldChip(icon: "pencil", label: f.label.isEmpty ? "Unnamed" : f.label, color: Color(r:0.55, g:0.36, b:0.96))
                    }
                }
                .padding(16)
            }
        }
        .background(cardBg)
        .cornerRadius(16)
        
        
        
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.white.opacity(0.08)))
    }
}

// MARK: - Field Chip
struct FieldChip: View {
    let icon:  String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11))
            Text(label).font(.system(size: 12, weight: .semibold))
        }
        .foregroundColor(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(color.opacity(0.2)))
        .cornerRadius(20)
    }
}

// MARK: - Skeleton Loading Card
struct ProfileSkeletonView: View {
    @State private var animate = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 10).frame(width: 36, height: 36)
                RoundedRectangle(cornerRadius: 6).frame(width: 160, height: 16)
                Spacer()
            }
            HStack(spacing: 8) {
                ForEach([100, 80, 120, 90], id: \.self) { w in
                    RoundedRectangle(cornerRadius: 20).frame(width: CGFloat(w), height: 28)
                }
            }
        }
        .foregroundColor(Color.white.opacity(animate ? 0.12 : 0.06))
        .padding(16)
        .background(Color(r:0.10, g:0.12, b:0.18))
        .cornerRadius(16)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { animate = true }
        }
    }
}

// MARK: - Delete Confirm Modal (mirrors ConfirmDialog in React)
struct DeleteConfirmModal: View {
    let profileName: String
    let isDeleting:  Bool
    let onConfirm:   () -> Void
    let onCancel:    () -> Void

    private let purple = Color(r:0.60, g:0.35, b:0.95)

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(r:0.94, g:0.27, b:0.27).opacity(0.1))
                        .frame(width: 44, height: 44)
                    Image(systemName: "trash")
                        .foregroundColor(Color(r:0.94, g:0.27, b:0.27))
                        .font(.system(size: 20))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Delete Profile")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                    Text("\"\(profileName)\" will be permanently removed.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
            }

            HStack(spacing: 10) {
                Button("Cancel") { onCancel() }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(purple))
                    .foregroundColor(.white)
                    .font(.system(size: 13, weight: .semibold))
                    .disabled(isDeleting)

                Button(action: onConfirm) {
                    if isDeleting {
                        HStack(spacing: 6) {
                            ProgressView().tint(.white).scaleEffect(0.8)
                            Text("Deleting…")
                        }
                    } else {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(Color(r:0.94, g:0.27, b:0.27).opacity(0.15))
                .foregroundColor(Color(r:0.94, g:0.27, b:0.27))
                .font(.system(size: 13, weight: .semibold))
                .cornerRadius(10)
                .disabled(isDeleting)
            }
        }
        .padding(28)
        .background(Color(r:0.10, g:0.12, b:0.18))
        .cornerRadius(16)
        .padding(.horizontal, 24)
        .shadow(color: .black.opacity(0.3), radius: 30)
    }
}

// MARK: - Toast View
struct ToastView: View {
    let message:   String
    let isSuccess: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
            Text(message).font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(isSuccess ? Color(r:0.13, g:0.77, b:0.37) : Color(r:0.94, g:0.27, b:0.27))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom, 24)
        .padding(.horizontal, 16)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(response: 0.3), value: message)
    }
}

// MARK: - FlowLayout (wrapping HStack for chips)
//struct FlowLayout: Layout {
//    var spacing: CGFloat = 8
//
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let width = proposal.width ?? 0
//        var height: CGFloat = 0
//        var rowX: CGFloat = 0
//        var rowH: CGFloat = 0
//        for sub in subviews {
//            let sz = sub.sizeThatFits(.unspecified)
//            if rowX + sz.width > width && rowX > 0 {
//                height += rowH + spacing
//                rowX = 0; rowH = 0
//            }
//            rowX += sz.width + spacing
//            rowH = max(rowH, sz.height)
//        }
//        height += rowH
//        return CGSize(width: width, height: height)
//    }
//
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        var rowX = bounds.minX
//        var rowY = bounds.minY
//        var rowH: CGFloat = 0
//        for sub in subviews {
//            let sz = sub.sizeThatFits(.unspecified)
//            if rowX + sz.width > bounds.maxX && rowX > bounds.minX {
//                rowY += rowH + spacing
//                rowX = bounds.minX; rowH = 0
//            }
//            sub.place(at: CGPoint(x: rowX, y: rowY), proposal: ProposedViewSize(sz))
//            rowX += sz.width + spacing
//            rowH = max(rowH, sz.height)
//        }
//    }
//}

// MARK: - Color convenience
extension Color {
    init(r: Double, g: Double, b: Double) {
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    BuyerInfoView()
}
