//
//  DevelopersSheetView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 15/04/26.
//
//  DevelopersSheet.swift
//  Bottom sheet opened by the </> button in BBNavBar.

//  DevelopersSheet.swift
//  Bottom sheet opened by the </> button in BBNavBar.

//  DevelopersSheet.swift
//  Bottom sheet opened by the </> button in BBNavBar.

import SwiftUI

private struct DevMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
}

private let devMenuItems: [DevMenuItem] = [
    DevMenuItem(icon: "key.fill",              title: "API Keys"),
    DevMenuItem(icon: "doc.text.fill",         title: "API Documentation"),
    DevMenuItem(icon: "arrow.triangle.2.circlepath", title: "Webhooks"),
    DevMenuItem(icon: "checkmark.shield.fill", title: "Domain Whitelisting"),
]

struct DevelopersSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var showAPIKeys = false
    @State private var showWebhooks = false

    var body: some View {
        if #available(iOS 16.4, *) {
            content
                .presentationDetents([.height(380)])
                .presentationDragIndicator(.hidden)
                .presentationCornerRadius(20)
                .presentationBackground(Color(red: 0.10, green: 0.12, blue: 0.19))
        .fullScreenCover(isPresented: $showAPIKeys) { APIKeysView() }
       // .fullScreenCover(isPresented: $showWebhooks) { WebhooksView() }
        .fullScreenCover(isPresented: $showWebhooks) { WebhooksIntegratedView() }
        } else {
            content
        }
    }

    private var content: some View {
        ZStack {
            Color(red: 0.10, green: 0.12, blue: 0.19).ignoresSafeArea()

            VStack(spacing: 0) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.20))
                    .frame(width: 40, height: 4)
                    .padding(.top, 12)

                // Title
                HStack {
                    Text("Developers")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 6)

                Rectangle()
                    .fill(Color.white.opacity(0.10))
                    .frame(height: 0.5)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)

                // Menu rows
                VStack(spacing: 0) {
                    ForEach(devMenuItems) { item in
                        DevRow(item: item) {
                            if item.title == "API Keys" {
                                showAPIKeys = true
                            } else if item.title == "Webhooks" {
                                showWebhooks = true
                            } else {
                                dismiss()
                            }
                        }

                        if item.id != devMenuItems.last?.id {
                            Rectangle()
                                .fill(Color.white.opacity(0.07))
                                .frame(height: 0.5)
                                .padding(.leading, 72)
                        }
                    }
                }

                Spacer()
            }
        }
    }
}

// MARK: - Row

private struct DevRow: View {
    let item: DevMenuItem
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.25, green: 0.22, blue: 0.55))
                        .frame(width: 46, height: 46)
                    Image(systemName: item.icon)
                        .resizable().scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color.white)
                }

                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.30))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(pressed ? Color.white.opacity(0.05) : Color.clear)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}

// MARK: - Preview

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            DevelopersSheet()
        }
}
