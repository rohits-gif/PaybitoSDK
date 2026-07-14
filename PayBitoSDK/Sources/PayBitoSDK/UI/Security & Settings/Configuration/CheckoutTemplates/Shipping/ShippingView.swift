//
//  ShippingView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 19/05/26.
//
//
//import SwiftUI
//
//// MARK: - Shipping View (no system nav bar / tab bar)
//struct ShippingView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        ZStack {
//            Color(red: 0.08, green: 0.09, blue: 0.12)
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//
//                // Page Nav Row
//                HStack(alignment: .center, spacing: 14) {
//
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "chevron.left")
//                            .font(.system(size: 17, weight: .semibold))
//                            .foregroundColor(.white)
//                    }
//
//                    VStack(alignment: .leading, spacing: 3) {
//                        Text("Shipping")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(.white)
//
//                        Text("Configure shipping and tax rates")
//                            .font(.system(size: 12.5, weight: .regular))
//                            .foregroundColor(Color(red: 0.50, green: 0.53, blue: 0.62))
//                    }
//
//                    Spacer()
//
//                    //  Add Profile button
//                    Button(action: {}) {
//                        HStack(spacing: 5) {
//                            Image(systemName: "plus")
//                                .font(.system(size: 13, weight: .bold))
//                            Text("Add Profile")
//                                .font(.system(size: 14, weight: .semibold))
//                        }
//                        .foregroundColor(.white)
//                        .padding(.horizontal, 16)
//                        .padding(.vertical, 10)
//                        .background(Color(red: 0.56, green: 0.27, blue: 0.90))
//                        .cornerRadius(22)
//                    }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 18)
//                .padding(.bottom, 16)
//
//                // Thin separator
//                Rectangle()
//                    .fill(Color.white.opacity(0.07))
//                    .frame(height: 0.5)
//
//                // ── Empty State
//                Spacer()
//
//                VStack(spacing: 16) {
//                    Image(systemName: "shippingbox.fill")
//                        .font(.system(size: 48))
//                        .foregroundColor(Color(red: 0.40, green: 0.38, blue: 0.90))
//
//                    VStack(spacing: 8) {
//                        Text("No shipping profiles yet")
//                            .font(.system(size: 18, weight: .semibold))
//                            .foregroundColor(.white)
//
//                        Text("Add a profile to configure shipping\nand tax rates for checkout")
//                            .font(.system(size: 14, weight: .regular))
//                            .foregroundColor(Color(red: 0.50, green: 0.53, blue: 0.62))
//                            .multilineTextAlignment(.center)
//                            .lineSpacing(3)
//                    }
//                }
//
//                Spacer()
//            }
//
//            // ── Floating + Button
//            VStack {
//                Spacer()
//                HStack {
//                    Spacer()
//                    Button(action: {}) {
//                        Image(systemName: "plus")
//                            .font(.system(size: 24, weight: .semibold))
//                            .foregroundColor(.white)
//                            .frame(width: 60, height: 60)
//                            .background(Color(red: 0.25, green: 0.75, blue: 0.95))
//                            .clipShape(RoundedRectangle(cornerRadius: 18))
//                            .shadow(color: Color(red: 0.25, green: 0.75, blue: 0.95).opacity(0.40),
//                                    radius: 12, x: 0, y: 6)
//                    }
//                    .padding(.trailing, 20)
//                    .padding(.bottom, 20)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//        .preferredColorScheme(.dark)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    ShippingView()
//}
//  ShippingView.swift

import SwiftUI

struct ShippingView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = ShippingViewModel()

    @State private var showAddSheet   = false
    @State private var editingProfile: Shipping.Profile? = nil
    @State private var deleteConfirmId: Int? = nil
    @State private var showDeleteConfirm = false

    private let bgColor     = Color(red: 0.08, green: 0.09, blue: 0.12)
    private let cardBg      = Color(red: 0.10, green: 0.12, blue: 0.17)
    private let subtitleClr = Color(red: 0.50, green: 0.53, blue: 0.62)
    private let purpleClr   = Color(red: 0.56, green: 0.27, blue: 0.90)
    private let blueClr     = Color(red: 0.25, green: 0.75, blue: 0.95)

    var body: some View {
        ZStack(alignment: .top) {
            bgColor.ignoresSafeArea()

            VStack(spacing: 0) {
                navBar
                Rectangle().fill(Color.white.opacity(0.07)).frame(height: 0.5)

                if vm.isLoading {
                    Spacer()
                    ProgressView().tint(.white).scaleEffect(1.5)
                    Spacer()
                } else if vm.profiles.isEmpty {
                    emptyState
                } else {
                    profileList
                }
            }

            // FAB
            if !vm.isLoading {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            editingProfile = nil
                            showAddSheet   = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(blueClr)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: blueClr.opacity(0.40), radius: 12, x: 0, y: 6)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }

            // Toast
            if let msg = vm.toastMessage {
                toastBanner(msg)
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .preferredColorScheme(.dark)
        .onAppear { vm.loadAll() }
        .fullScreenCover(isPresented: $showAddSheet) {
            AddShippingView(
                vm:              vm,
                editingProfile:  editingProfile
            ) {
                showAddSheet   = false
                editingProfile = nil
            }
        }
        .confirmationDialog("Delete Profile",
                            isPresented: $showDeleteConfirm,
                            titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                if let id = deleteConfirmId { vm.deleteProfile(id: id) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Nav Bar
    var navBar: some View {
        HStack(alignment: .center, spacing: 14) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Shipping")
                    .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Text("Configure shipping and tax rates")
                    .font(.system(size: 12.5)).foregroundColor(subtitleClr)
            }

            Spacer()

            Button {
                editingProfile = nil
                showAddSheet   = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                    Text("Add Profile").font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16).padding(.vertical, 10)
                .background(purpleClr).cornerRadius(22)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
        .padding(.bottom, 16)
    }

    // MARK: - Empty State
    var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "shippingbox.fill")
                .font(.system(size: 48))
                .foregroundColor(Color(red: 0.40, green: 0.38, blue: 0.90))

            VStack(spacing: 8) {
                Text("No shipping profiles yet")
                    .font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                Text("Add a profile to configure shipping\nand tax rates for checkout")
                    .font(.system(size: 14)).foregroundColor(subtitleClr)
                    .multilineTextAlignment(.center).lineSpacing(3)
            }
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Profile List
    var profileList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 12) {
                // Stats row
                statsRow
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                // Cards
                ForEach(vm.profiles) { profile in
                    profileCard(profile)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 100)
        }
    }

    // MARK: - Stats Row (mirrors web stats section)
    var statsRow: some View {
        let avgShipping = vm.profiles.isEmpty ? 0.0 :
            vm.profiles.compactMap { Double($0.shippingHandling) }.reduce(0, +) / Double(vm.profiles.count)
        let avgTax      = vm.profiles.isEmpty ? 0.0 :
            vm.profiles.compactMap { Double($0.taxRate) }.reduce(0, +) / Double(vm.profiles.count)

        return HStack(spacing: 10) {
            statCard(value: "\(vm.profiles.count)",
                     label: "Total Profiles",
                     icon: "shippingbox.fill",
                     color: purpleClr)
            statCard(value: String(format: "%.1f%%", avgShipping),
                     label: "Avg. Shipping",
                     icon: "truck.box.fill",
                     color: Color(red: 0.23, green: 0.51, blue: 0.96))
            statCard(value: String(format: "%.1f%%", avgTax),
                     label: "Avg. Tax",
                     icon: "receipt.fill",
                     color: Color(red: 0.96, green: 0.62, blue: 0.04))
        }
    }

    func statCard(value: String, label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold)).foregroundColor(.white)
                Text(label)
                    .font(.system(size: 10)).foregroundColor(subtitleClr)
            }
            Spacer()
        }
        .padding(12)
        .background(cardBg)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Profile Card
    func profileCard(_ profile: Shipping.Profile) -> some View {
        let isDeleting = vm.deletingId == profile.id

        return VStack(spacing: 0) {
            // Header row
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(purpleClr.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 15)).foregroundColor(purpleClr)
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(profile.name)
                            .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                        if profile.isDefault {
                            defaultBadge
                        }
                    }
                }
                Spacer()
            }
            .padding(16)

            Divider().background(Color.white.opacity(0.08))

            // Rate pills
            HStack(spacing: 12) {
                ratePill(
                    icon: "shippingbox",
                    value: "\(profile.shippingHandling)%",
                    label: "Shipping",
                    color: Color(red: 0.23, green: 0.51, blue: 0.96)
                )
                ratePill(
                    icon: "receipt",
                    value: "\(profile.taxRate)%",
                    label: "Tax Rate",
                    color: Color(red: 0.96, green: 0.62, blue: 0.04)
                )
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            Divider().background(Color.white.opacity(0.08))

            // Action buttons
            HStack(spacing: 8) {
                Button {
                    editingProfile = profile
                    showAddSheet   = true
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "pencil").font(.system(size: 11))
                        Text("Edit").font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.white.opacity(0.12), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)

                Spacer()

                Button {
                    deleteConfirmId   = profile.id
                    showDeleteConfirm = true
                } label: {
                    Group {
                        if isDeleting {
                            ProgressView().tint(.red).scaleEffect(0.8)
                        } else {
                            Image(systemName: "trash").font(.system(size: 14)).foregroundColor(.red)
                        }
                    }
                    .frame(width: 36, height: 36)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(10)
                }
                .buttonStyle(.plain)
                .disabled(isDeleting)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBg)
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(profile.isDefault
                            ? purpleClr.opacity(0.4)
                            : Color.white.opacity(0.08), lineWidth: 1.5))
        )
        .opacity(isDeleting ? 0.6 : 1)
        .animation(.easeInOut(duration: 0.2), value: isDeleting)
    }

    // MARK: - Helpers
    var defaultBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 10))
            Text("Default").font(.system(size: 10, weight: .bold))
        }
        .foregroundColor(purpleClr)
        .padding(.horizontal, 8).padding(.vertical, 3)
        .background(purpleClr.opacity(0.12))
        .cornerRadius(20)
    }

    func ratePill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(subtitleClr).tracking(0.5)
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12)).foregroundColor(color)
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 10)
        .background(color.opacity(0.08))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(color.opacity(0.2), lineWidth: 1))
    }

    func toastBanner(_ msg: String) -> some View {
        let isError     = vm.toastIsError
        let iconName    = isError ? "xmark.circle.fill" : "checkmark.circle.fill"
        let iconColor   = isError ? Color.red : Color.green
        let borderColor = isError ? Color.red.opacity(0.4) : Color.green.opacity(0.4)

        return HStack(spacing: 10) {
            Image(systemName: iconName).foregroundColor(iconColor)
            Text(msg).font(.system(size: 13, weight: .medium)).foregroundColor(.white)
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(red: 0.12, green: 0.14, blue: 0.20))
        )
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
        .padding(.horizontal, 16)
        .padding(.top, 60)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.vm.toastMessage = nil
            }
        }
    }
}
