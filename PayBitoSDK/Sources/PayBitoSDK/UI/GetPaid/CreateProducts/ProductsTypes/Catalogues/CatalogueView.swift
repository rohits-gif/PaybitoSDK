//
//  CatalogueView.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message

//
//  CataloguesView.swift
//  Trading_Terminal
//

import SwiftUI

// Local theme alias — PCTheme defined in CreateProductView.swift
private typealias T = PCTheme

// ============================================================
// MARK: - Catalogues Tab View
// ============================================================

struct PCCataloguesTabView: View {

    @ObservedObject var vm: PCCatalogueViewModel
    let merchantId: Int                                      // ← pass from parent

    @State private var searchText           = ""
    @State private var catalogueToDelete:   PCCatalogueItem? = nil
    @State private var showDeleteAlert      = false
    @State private var showAddCatalogue     = false
    @State private var catalogueToEdit:     PCCatalogueItem? = nil

    private var filtered: [PCCatalogueItem] {
        searchText.isEmpty ? vm.catalogues :
            vm.catalogues.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                searchBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                content
            }

            // Toast
            if let msg = vm.successMessage {
                PCCatalogueToast(message: msg, isSuccess: true)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            vm.clearMessages()
                        }
                    }
            }
            if let err = vm.errorMessage {
                PCCatalogueToast(message: err, isSuccess: false)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            vm.clearMessages()
                        }
                    }
            }
        }
        // ── Add sheet ─────────────────────────────────────────
        .sheet(isPresented: $showAddCatalogue) {
            PCAddCatalogueSheet(isCreating: vm.isCreating) { name, desc in
                vm.createCatalogue(name: name, description: desc)
            }
        }
        // ── Edit full-screen sheet ────────────────────────────
        .sheet(item: $catalogueToEdit, onDismiss: {
            vm.loadProductCounts()   // ✅ refresh counts after edit sheet closes
        }) { item in
            EditCatalogueView(
                catalogueVM: vm,
                item:        item,
                merchantId:  merchantId
            )
        }
        // ── Delete alert ──────────────────────────────────────
        .alert("Delete Catalogue",
               isPresented: $showDeleteAlert,
               presenting: catalogueToDelete) { cat in
            Button("Delete", role: .destructive) { vm.deleteCatalogue(item: cat) }
            Button("Cancel", role: .cancel) {}
        } message: { cat in
            Text("Are you sure you want to delete \"\(cat.name)\"?")
        }
    }

    // ── Search Bar ────────────────────────────────────────────

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(T.textSecondary).font(.system(size: 14))
            TextField("Search catalogues...", text: $searchText)
                .foregroundColor(T.textPrimary).font(.system(size: 14))
            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(T.textSecondary).font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(T.surface).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
    }

    // ── Content ───────────────────────────────────────────────

    @ViewBuilder
    private var content: some View {
        if vm.isLoading {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: T.accentLight))
                .scaleEffect(1.4)
            Spacer()
        } else if filtered.isEmpty {
            emptyState
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filtered) { item in
                        PCCatalogueCard(
                            item: item,
                            onEdit: {
                                catalogueToEdit = item
                            },
                            onDelete: {
                                catalogueToDelete = item
                                showDeleteAlert   = true
                            }
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.bottom, 100)
            }
        }
    }

    // ── Empty State ───────────────────────────────────────────

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(T.textSecondary.opacity(0.4))
            Text("No Catalogues Found")
                .font(.system(size: 18, weight: .semibold)).foregroundColor(T.textPrimary)
            Text("Tap \"Add Catalogue\" to create your first one.")
                .font(.system(size: 14)).foregroundColor(T.textSecondary)
                .multilineTextAlignment(.center)
            Button { vm.loadCatalogues() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 13))
                    Text("Refresh").font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(T.accentLight)
                .padding(.horizontal, 20).padding(.vertical, 10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.accent, lineWidth: 1.5))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

// ============================================================
// MARK: - Catalogue Card
// ============================================================

struct PCCatalogueCard: View {
    let item:     PCCatalogueItem
    let onEdit:   () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Purple accent stripe
            LinearGradient(colors: [T.accent, T.accentLight],
                           startPoint: .leading, endPoint: .trailing)
                .frame(height: 3)
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 14, topTrailingRadius: 14, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0))

            VStack(spacing: 0) {
                // Icon + name + id badge
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.176, green: 0.106, blue: 0.408))
                            .frame(width: 54, height: 54)
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 22)).foregroundColor(T.accentLight)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.name)
                            .font(.system(size: 16, weight: .bold)).foregroundColor(T.textPrimary)
                        Text(item.description.isEmpty ? "No description" : item.description)
                            .font(.system(size: 13)).foregroundColor(T.textSecondary).lineLimit(1)
                    }
                    Spacer()
                    Text("#\(item.id)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(T.textMuted)
                        .padding(.horizontal, 6).padding(.vertical, 3)
                        .background(T.border).cornerRadius(6)
                }
                .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 14)

                Divider().background(T.border)

                // Footer
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "cart")
                            .font(.system(size: 13)).foregroundColor(T.textSecondary)
                        Text("\(item.productCount) product\(item.productCount == 1 ? "" : "s")")
                            .font(.system(size: 13)).foregroundColor(T.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Button(action: onEdit) {
                            HStack(spacing: 5) {
                                Image(systemName: "pencil").font(.system(size: 12))
                                Text("Edit").font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(T.accentLight)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(T.accent, lineWidth: 1.5))
                        }
                        Button(action: onDelete) {
                            HStack(spacing: 5) {
                                Image(systemName: "trash").font(.system(size: 12))
                                Text("Delete").font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(T.deleteRed)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 8)
                                .stroke(T.deleteRed, lineWidth: 1.5))
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
        }
        .background(T.surfaceHigh).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(T.border, lineWidth: 1))
    }
}

// ============================================================
// MARK: - Add Catalogue Sheet
// ============================================================

struct PCAddCatalogueSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var name        = ""
    @State private var description = ""

    let isCreating: Bool
    let onAdd: (String, String) -> Void

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !isCreating
    }

    var body: some View {
        ZStack {
            T.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {

                // Drag handle
                HStack {
                    Spacer()
                    Capsule().fill(T.border).frame(width: 40, height: 4)
                    Spacer()
                }
                .padding(.top, 12).padding(.bottom, 20)

                Text("New Catalogue")
                    .font(.system(size: 20, weight: .bold)).foregroundColor(T.textPrimary)
                    .padding(.horizontal, 20).padding(.bottom, 24)

                // Name field
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 4) {
                        Text("Catalogue Name")
                            .font(.system(size: 13, weight: .medium)).foregroundColor(T.textSecondary)
                        Text("*").foregroundColor(T.deleteRed)
                    }
                    TextField("e.g. Mobile Phones", text: $name)
                        .foregroundColor(T.textPrimary).font(.system(size: 15))
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(T.surface).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(name.isEmpty ? T.border : T.accent, lineWidth: 1))
                }
                .padding(.horizontal, 20).padding(.bottom, 16)

                // Description field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Description")
                        .font(.system(size: 13, weight: .medium)).foregroundColor(T.textSecondary)
                    TextField("Short description (optional)", text: $description)
                        .foregroundColor(T.textPrimary).font(.system(size: 15))
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(T.surface).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
                }
                .padding(.horizontal, 20).padding(.bottom, 32)

                // Buttons
                HStack(spacing: 12) {
                    Button { dismiss() } label: {
                        Text("CANCEL")
                            .font(.system(size: 14, weight: .bold)).foregroundColor(T.textSecondary)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(T.surfaceHigh).cornerRadius(14)
                    }
                    .disabled(isCreating)

                    Button {
                        let trimmed = name.trimmingCharacters(in: .whitespaces)
                        guard !trimmed.isEmpty else { return }
                        onAdd(trimmed, description)
                        dismiss()
                    } label: {
                        ZStack {
                            Text("ADD CATALOGUE")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                                .opacity(isCreating ? 0 : 1)
                            if isCreating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                            }
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: canSubmit
                                    ? [Color(red: 0.659, green: 0.333, blue: 0.969), T.accent]
                                    : [T.border, T.border],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                    .disabled(!canSubmit)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.hidden)
    }
}

// ============================================================
// MARK: - Toast
// ============================================================

struct PCCatalogueToast: View {
    let message:   String
    let isSuccess: Bool

    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: isSuccess
                      ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                    .foregroundColor(isSuccess ? T.green : T.deleteRed)
                    .font(.system(size: 16))
                Text(message)
                    .font(.system(size: 14, weight: .medium)).foregroundColor(T.textPrimary)
                    .lineLimit(2)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(T.surfaceHigh).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12)
                .stroke(isSuccess ? T.green.opacity(0.3) : T.deleteRed.opacity(0.3), lineWidth: 1))
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
            .padding(.horizontal, 20).padding(.top, 60)
            Spacer()
        }
        .transition(.move(edge: .top).combined(with: .opacity))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: message)
    }
}

























////
////  CataloguesView.swift
////  Trading_Terminal
////
//
//import SwiftUI
//
//// Local theme alias — PCTheme defined in CreateProductView.swift
//private typealias T = PCTheme
//
//// ============================================================
//// MARK: - Catalogues Tab View
//// ============================================================
//
//struct PCCataloguesTabView: View {
//
//    @ObservedObject var vm: PCCatalogueViewModel
//
//    @State private var searchText           = ""
//    @State private var catalogueToDelete:   PCCatalogueItem? = nil
//    @State private var showDeleteAlert      = false
//    @State private var showAddCatalogue     = false
//    @State private var catalogueToEdit:     PCCatalogueItem? = nil   // ← drives edit sheet
//
//    private var filtered: [PCCatalogueItem] {
//        searchText.isEmpty ? vm.catalogues :
//            vm.catalogues.filter {
//                $0.name.localizedCaseInsensitiveContains(searchText) ||
//                $0.description.localizedCaseInsensitiveContains(searchText)
//            }
//    }
//
//    var body: some View {
//        ZStack {
//            VStack(spacing: 0) {
//                searchBar
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 14)
//                content
//            }
//
//            // Toast
//            if let msg = vm.successMessage {
//                PCCatalogueToast(message: msg, isSuccess: true)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//                            vm.clearMessages()
//                        }
//                    }
//            }
//            if let err = vm.errorMessage {
//                PCCatalogueToast(message: err, isSuccess: false)
//                    .onAppear {
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                            vm.clearMessages()
//                        }
//                    }
//            }
//        }
//        // ── Add sheet ─────────────────────────────────────────
//        .sheet(isPresented: $showAddCatalogue) {
//            PCAddCatalogueSheet(isCreating: vm.isCreating) { name, desc in
//                vm.createCatalogue(name: name, description: desc)
//            }
//        }
//        // ── Edit full-screen sheet ────────────────────────────
//        .sheet(item: $catalogueToEdit) { item in
//            EditCatalogueView(
//                catalogueVM: vm,
//                item: item
//            )
//        }
//        // ── Delete alert ──────────────────────────────────────
//        .alert("Delete Catalogue",
//               isPresented: $showDeleteAlert,
//               presenting: catalogueToDelete) { cat in
//            Button("Delete", role: .destructive) { vm.deleteCatalogue(item: cat) }
//            Button("Cancel", role: .cancel) {}
//        } message: { cat in
//            Text("Are you sure you want to delete \"\(cat.name)\"?")
//        }
//    }
//
//    // ── Search Bar ────────────────────────────────────────────
//
//    private var searchBar: some View {
//        HStack(spacing: 8) {
//            Image(systemName: "magnifyingglass")
//                .foregroundColor(T.textSecondary).font(.system(size: 14))
//            TextField("Search catalogues...", text: $searchText)
//                .foregroundColor(T.textPrimary).font(.system(size: 14))
//            if !searchText.isEmpty {
//                Button { searchText = "" } label: {
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(T.textSecondary).font(.system(size: 14))
//                }
//            }
//        }
//        .padding(.horizontal, 14).padding(.vertical, 12)
//        .background(T.surface).cornerRadius(10)
//        .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
//    }
//
//    // ── Content ───────────────────────────────────────────────
//
//    @ViewBuilder
//    private var content: some View {
//        if vm.isLoading {
//            Spacer()
//            ProgressView()
//                .progressViewStyle(CircularProgressViewStyle(tint: T.accentLight))
//                .scaleEffect(1.4)
//            Spacer()
//        } else if filtered.isEmpty {
//            emptyState
//        } else {
//            ScrollView {
//                LazyVStack(spacing: 12) {
//                    ForEach(filtered) { item in
//                        PCCatalogueCard(
//                            item: item,
//                            onEdit: {
//                                catalogueToEdit = item          // ← open EditCatalogueView
//                            },
//                            onDelete: {
//                                catalogueToDelete = item
//                                showDeleteAlert   = true
//                            }
//                        )
//                        .padding(.horizontal, 16)
//                    }
//                }
//                .padding(.bottom, 100)
//            }
//        }
//    }
//
//    // ── Empty State ───────────────────────────────────────────
//
//    private var emptyState: some View {
//        VStack(spacing: 16) {
//            Spacer()
//            Image(systemName: "square.grid.2x2")
//                .font(.system(size: 50, weight: .light))
//                .foregroundColor(T.textSecondary.opacity(0.4))
//            Text("No Catalogues Found")
//                .font(.system(size: 18, weight: .semibold)).foregroundColor(T.textPrimary)
//            Text("Tap \"Add Catalogue\" to create your first one.")
//                .font(.system(size: 14)).foregroundColor(T.textSecondary)
//                .multilineTextAlignment(.center)
//            Button { vm.loadCatalogues() } label: {
//                HStack(spacing: 6) {
//                    Image(systemName: "arrow.clockwise").font(.system(size: 13))
//                    Text("Refresh").font(.system(size: 14, weight: .semibold))
//                }
//                .foregroundColor(T.accentLight)
//                .padding(.horizontal, 20).padding(.vertical, 10)
//                .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.accent, lineWidth: 1.5))
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//    }
//}
//
//// ============================================================
//// MARK: - Catalogue Card
//// ============================================================
//
//struct PCCatalogueCard: View {
//    let item:     PCCatalogueItem
//    let onEdit:   () -> Void
//    let onDelete: () -> Void
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // Purple accent stripe
//            LinearGradient(colors: [T.accent, T.accentLight],
//                           startPoint: .leading, endPoint: .trailing)
//                .frame(height: 3)
//                .clipShape(UnevenRoundedRectangle(
//                    topLeadingRadius: 14, bottomLeadingRadius: 0,
//                    bottomTrailingRadius: 0, topTrailingRadius: 14))
//
//            VStack(spacing: 0) {
//                // Icon + name + id badge
//                HStack(spacing: 14) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color(red: 0.176, green: 0.106, blue: 0.408))
//                            .frame(width: 54, height: 54)
//                        Image(systemName: "list.bullet.rectangle")
//                            .font(.system(size: 22)).foregroundColor(T.accentLight)
//                    }
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(item.name)
//                            .font(.system(size: 16, weight: .bold)).foregroundColor(T.textPrimary)
//                        Text(item.description.isEmpty ? "No description" : item.description)
//                            .font(.system(size: 13)).foregroundColor(T.textSecondary).lineLimit(1)
//                    }
//                    Spacer()
//                    Text("#\(item.id)")
//                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
//                        .foregroundColor(T.textMuted)
//                        .padding(.horizontal, 6).padding(.vertical, 3)
//                        .background(T.border).cornerRadius(6)
//                }
//                .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 14)
//
//                Divider().background(T.border)
//
//                // Footer
//                HStack {
//                    HStack(spacing: 6) {
//                        Image(systemName: "cart")
//                            .font(.system(size: 13)).foregroundColor(T.textSecondary)
//                        Text("\(item.productCount) product\(item.productCount == 1 ? "" : "s")")
//                            .font(.system(size: 13)).foregroundColor(T.textSecondary)
//                    }
//                    Spacer()
//                    HStack(spacing: 10) {
//                        Button(action: onEdit) {
//                            HStack(spacing: 5) {
//                                Image(systemName: "pencil").font(.system(size: 12))
//                                Text("Edit").font(.system(size: 10, weight: .medium))
//                            }
//                            .foregroundColor(T.accentLight)
//                            .padding(.horizontal, 14).padding(.vertical, 8)
//                            .overlay(RoundedRectangle(cornerRadius: 8)
//                                .stroke(T.accent, lineWidth: 1.5))
//                        }
//                        Button(action: onDelete) {
//                            HStack(spacing: 5) {
//                                Image(systemName: "trash").font(.system(size: 12))
//                                Text("Delete").font(.system(size: 10, weight: .medium))
//                            }
//                            .foregroundColor(T.deleteRed)
//                            .padding(.horizontal, 14).padding(.vertical, 8)
//                            .overlay(RoundedRectangle(cornerRadius: 8)
//                                .stroke(T.deleteRed, lineWidth: 1.5))
//                        }
//                    }
//                }
//                .padding(.horizontal, 16).padding(.vertical, 14)
//            }
//        }
//        .background(T.surfaceHigh).cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(T.border, lineWidth: 1))
//    }
//}
//
//// ============================================================
//// MARK: - Add Catalogue Sheet
//// ============================================================
//
//struct PCAddCatalogueSheet: View {
//
//    @Environment(\.dismiss) private var dismiss
//    @State private var name        = ""
//    @State private var description = ""
//
//    let isCreating: Bool
//    let onAdd: (String, String) -> Void
//
//    private var canSubmit: Bool {
//        !name.trimmingCharacters(in: .whitespaces).isEmpty && !isCreating
//    }
//
//    var body: some View {
//        ZStack {
//            T.background.ignoresSafeArea()
//            VStack(alignment: .leading, spacing: 0) {
//
//                // Drag handle
//                HStack {
//                    Spacer()
//                    Capsule().fill(T.border).frame(width: 40, height: 4)
//                    Spacer()
//                }
//                .padding(.top, 12).padding(.bottom, 20)
//
//                Text("New Catalogue")
//                    .font(.system(size: 20, weight: .bold)).foregroundColor(T.textPrimary)
//                    .padding(.horizontal, 20).padding(.bottom, 24)
//
//                // Name field
//                VStack(alignment: .leading, spacing: 8) {
//                    HStack(spacing: 4) {
//                        Text("Catalogue Name")
//                            .font(.system(size: 13, weight: .medium)).foregroundColor(T.textSecondary)
//                        Text("*").foregroundColor(T.deleteRed)
//                    }
//                    TextField("e.g. Mobile Phones", text: $name)
//                        .foregroundColor(T.textPrimary).font(.system(size: 15))
//                        .padding(.horizontal, 14).padding(.vertical, 12)
//                        .background(T.surface).cornerRadius(10)
//                        .overlay(RoundedRectangle(cornerRadius: 10)
//                            .stroke(name.isEmpty ? T.border : T.accent, lineWidth: 1))
//                }
//                .padding(.horizontal, 20).padding(.bottom, 16)
//
//                // Description field
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Description")
//                        .font(.system(size: 13, weight: .medium)).foregroundColor(T.textSecondary)
//                    TextField("Short description (optional)", text: $description)
//                        .foregroundColor(T.textPrimary).font(.system(size: 15))
//                        .padding(.horizontal, 14).padding(.vertical, 12)
//                        .background(T.surface).cornerRadius(10)
//                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
//                }
//                .padding(.horizontal, 20).padding(.bottom, 32)
//
//                // Buttons
//                HStack(spacing: 12) {
//                    Button { dismiss() } label: {
//                        Text("CANCEL")
//                            .font(.system(size: 14, weight: .bold)).foregroundColor(T.textSecondary)
//                            .frame(maxWidth: .infinity).padding(.vertical, 16)
//                            .background(T.surfaceHigh).cornerRadius(14)
//                    }
//                    .disabled(isCreating)
//
//                    Button {
//                        let trimmed = name.trimmingCharacters(in: .whitespaces)
//                        guard !trimmed.isEmpty else { return }
//                        onAdd(trimmed, description)
//                        dismiss()
//                    } label: {
//                        ZStack {
//                            Text("ADD CATALOGUE")
//                                .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
//                                .opacity(isCreating ? 0 : 1)
//                            if isCreating {
//                                ProgressView()
//                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                                    .scaleEffect(0.9)
//                            }
//                        }
//                        .frame(maxWidth: .infinity).padding(.vertical, 16)
//                        .background(
//                            LinearGradient(
//                                colors: canSubmit
//                                    ? [Color(red: 0.659, green: 0.333, blue: 0.969), T.accent]
//                                    : [T.border, T.border],
//                                startPoint: .leading, endPoint: .trailing
//                            )
//                        )
//                        .cornerRadius(14)
//                    }
//                    .disabled(!canSubmit)
//                }
//                .padding(.horizontal, 20)
//
//                Spacer()
//            }
//        }
//        .presentationDetents([.medium])
//        .presentationDragIndicator(.hidden)
//    }
//}
//
//// ============================================================
//// MARK: - Toast
//// ============================================================
//
//struct PCCatalogueToast: View {
//    let message:   String
//    let isSuccess: Bool
//
//    var body: some View {
//        VStack {
//            HStack(spacing: 10) {
//                Image(systemName: isSuccess
//                      ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
//                    .foregroundColor(isSuccess ? T.green : T.deleteRed)
//                    .font(.system(size: 16))
//                Text(message)
//                    .font(.system(size: 14, weight: .medium)).foregroundColor(T.textPrimary)
//                    .lineLimit(2)
//            }
//            .padding(.horizontal, 16).padding(.vertical, 12)
//            .background(T.surfaceHigh).cornerRadius(12)
//            .overlay(RoundedRectangle(cornerRadius: 12)
//                .stroke(isSuccess ? T.green.opacity(0.3) : T.deleteRed.opacity(0.3), lineWidth: 1))
//            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 4)
//            .padding(.horizontal, 20).padding(.top, 60)
//            Spacer()
//        }
//        .transition(.move(edge: .top).combined(with: .opacity))
//        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: message)
//    }
//}














