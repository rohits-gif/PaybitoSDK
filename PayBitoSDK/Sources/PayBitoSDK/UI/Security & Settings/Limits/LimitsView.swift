//
//  LimitsView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 16/04/26.
//
//
//  LimitsView.swift  (updated — ViewModel wired)
//  Trading_Terminal
//

import SwiftUI

struct LimitsView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = LimitsViewModel()
    @State private var showChangePlan = false

    private let green  = Color(red: 0.10, green: 0.72, blue: 0.45)
    private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let card   = Color(red: 0.10, green: 0.14, blue: 0.20)

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    pageHeader

                    // ── Error Banner ──────────────────────────────────────
                    if let msg = vm.errorMessage {
                        Text(msg)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.red.opacity(0.25))
                            .cornerRadius(10)
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                    }

                    // ── Loading Skeleton ──────────────────────────────────
                    if vm.isLoading {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(card)
                            .frame(height: 180)
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                            .redacted(reason: .placeholder)
                            .shimmering()
                    } else {
                        approvedVolumeCard
                            .padding(.horizontal, 16)
                            .padding(.top, 20)
                    }

                    Spacer().frame(height: 100)
                }
            }
            .refreshable { vm.fetchLimits() }

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
        .task { vm.fetchLimits() }           // fetch on appear
        .sheet(isPresented: $showChangePlan) {
            ApprovedVolumeSheet(viewModel: vm)
        }
    }

    // MARK: - Page Header
    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Limits")
                    .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                Text("Approved revenue volume and transaction limits")
                    .font(.system(size: 12)).foregroundColor(.white.opacity(0.50))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 4)
    }

    // MARK: - Approved Volume Card
    private var approvedVolumeCard: some View {
        VStack(spacing: 0) {
            // Card header
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.08, green: 0.28, blue: 0.22))
                        .frame(width: 40, height: 40)
                    Image(systemName: "gauge.medium")
                        .font(.system(size: 18))
                        .foregroundColor(green)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Approved Volume")
                        .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Text("Your current transaction limits")
                        .font(.system(size: 12)).foregroundColor(.white.opacity(0.50))
                }
                Spacer()
                Button(action: { showChangePlan = true }) {
                    Text("Change Plan")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(purple)
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(purple, lineWidth: 1.5)
                        }
                }
                .buttonStyle(.plain)
            }
            .padding(16)

            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
                .padding(.horizontal, 16)

            // Current Plan Row
            VStack(spacing: 4) {
                Text("CURRENT PLAN")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.45))
                Text(vm.currentPlanName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(purple)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)

            Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
                .padding(.horizontal, 16)

            // Limits grid
            HStack(spacing: 0) {
                // Daily
                VStack(alignment: .leading, spacing: 8) {
                    Text("DAILY LIMIT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(green)
                    Text(vm.dailyAmountCap)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("per day")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)

                Rectangle().fill(Color.white.opacity(0.08)).frame(width: 0.5)
                    .padding(.vertical, 20)

                // Monthly
                VStack(alignment: .leading, spacing: 8) {
                    Text("MONTHLY LIMIT")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(green)
                    Text(vm.monthlyTransactionCap)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text("payments per month")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.45))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 16)
            }
            .padding(.vertical, 20)
        }
        .background(card)
        .cornerRadius(16)
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        }
    }
}

// MARK: - Shimmering Modifier (simple pulse)
struct ShimmeringModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear,                     location: phase - 0.3),
                        .init(color: .white.opacity(0.12),       location: phase),
                        .init(color: .clear,                     location: phase + 0.3)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: phase)
            )
            .onAppear { phase = 1.3 }
    }
}

extension View {
    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}

#Preview {
    LimitsView()
}
