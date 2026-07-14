//
//  Apikeysview.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 15/04/26.
//

//  APIKeysView.swift


import SwiftUI

struct APIKeyItem: Identifiable {
    let id = UUID()
    let name: String
    let publicKey: String
    let createdAt: String
}

struct APIKeysView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var keyName = ""
    @State private var apiKeys: [APIKeyItem] = []

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    pageHeader
                    VStack(spacing: 16) {
                        createSection
                        yourKeysSection
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 100)
                }
            }

            // FAB
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(Color(red: 0.20, green: 0.40, blue: 0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            .padding(.trailing, 20).padding(.bottom, 28)
        }
    }

    // MARK: - Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("API Keys")
                    .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                Text("Create and manage your API keys and permissions")
                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.50))
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 4)
    }

    // MARK: - Create API Key Section

    private var createSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.10, green: 0.45, blue: 0.30))
                        .frame(width: 46, height: 46)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Create API Key")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text("Generate a new key for API access")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.50))
                }
                Spacer()
            }
            .padding(16)

            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)

            VStack(alignment: .leading, spacing: 10) {
                Text("KEY NAME")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.top, 16)

                TextField("e.g. My Trading Bot Key", text: $keyName)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color(red: 0.12, green: 0.15, blue: 0.22))
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    }

                Button(action: handleGenerate) {
                    Text("Generate Key")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 28).padding(.vertical, 14)
                        .background(Color(red: 0.20, green: 0.40, blue: 0.95))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 16)
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    // MARK: - Your API Keys Section

    private var yourKeysSection: some View {
        VStack(spacing: 0) {
            // Section header
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.20, green: 0.22, blue: 0.45))
                        .frame(width: 46, height: 46)
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Your API Keys")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    Text("Active keys for API access")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.50))
                }
                Spacer()
            }
            .padding(16)

            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)

            if apiKeys.isEmpty {
                emptyState
            } else {
                VStack(spacing: 0) {
                    ForEach(apiKeys) { key in
                        APIKeyRow(key: key)
                        if key.id != apiKeys.last?.id {
                            Rectangle().fill(Color.white.opacity(0.07)).frame(height: 0.5)
                                .padding(.horizontal, 16)
                        }
                    }
                }
            }
        }
        .background(Color(red: 0.10, green: 0.12, blue: 0.19))
        .cornerRadius(14)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.14, green: 0.17, blue: 0.28))
                    .frame(width: 80, height: 80)
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(.top, 40)

            Text("No API Keys Yet")
                .font(.system(size: 17, weight: .bold)).foregroundColor(.white)

            Text("Create your first API key above to get started")
                .font(.system(size: 13)).foregroundColor(.white.opacity(0.40))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Generate

    private func handleGenerate() {
        guard !keyName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        let newKey = APIKeyItem(
            name: keyName,
            publicKey: "pk_" + UUID().uuidString.prefix(16).lowercased(),
            createdAt: "Today"
        )
        apiKeys.append(newKey)
        keyName = ""
    }
}

// MARK: - API Key Row

private struct APIKeyRow: View {
    let key: APIKeyItem

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(key.name)
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                Text(key.publicKey)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
                Text(key.createdAt)
                    .font(.system(size: 11)).foregroundColor(.white.opacity(0.35))
            }
            Spacer()
            Button(action: {}) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.95, green: 0.30, blue: 0.30))
                    .frame(width: 36, height: 36)
                    .background(Color(red: 0.22, green: 0.10, blue: 0.10))
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
    }
}

// MARK: - Preview

#Preview { APIKeysView() }
