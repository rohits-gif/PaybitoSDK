//
//  Approvedvolumesheet.swift
//  Trading_Terminal
//

import SwiftUI

extension ApplyPlanType: Identifiable {
    var id: String { title }
}

struct ApprovedVolumeSheet: View {

    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: LimitsViewModel
    @State private var applyPlan: ApplyPlanType? = nil

    private let darkBG = Color(red: 0.08, green: 0.10, blue: 0.16)

    var body: some View {
        if #available(iOS 16.4, *) {
            content
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackground(darkBG)
                .sheet(item: $applyPlan) { plan in
                    ApplyPlanSheet(plan: plan, viewModel: viewModel) // ← same instance
                }
        } else {
            content
        }
    }

    private var content: some View {
        ZStack {
            darkBG.ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Header
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                    }
                    .buttonStyle(.plain)

                    Text("Approved Volume")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 12)

                Text("In order to raise your daily processing limits we require additional information to verify your identity and your business.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)

                // MARK: Plans
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        ForEach(viewModel.availablePlans) { plan in
                            PlanCard(
                                plan:            plan,
                                isActive:        plan.volumeName.lowercased() == viewModel.currentPlanName.lowercased(),
                                isPendingReview: viewModel.isPendingReview(volumeId: plan.volumeID),
                                onApply: {
                                    switch plan.volumeName {
                                    case "Basic Plan":    applyPlan = .basic
                                    case "Business Plan": applyPlan = .business
                                    default: break
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                }

                // MARK: Cancel
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color(red: 0.18, green: 0.20, blue: 0.30))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
        }
    }
}

// MARK: - Plan Card

private struct PlanCard: View {

    let plan: VolumePlan
    let isActive: Bool
    let isPendingReview: Bool
    var onApply: () -> Void = {}

    private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let green  = Color(red: 0.10, green: 0.72, blue: 0.45)
    private let orange = Color(red: 0.95, green: 0.60, blue: 0.10)
    private let cardBG = Color(red: 0.10, green: 0.13, blue: 0.20)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Title row
            HStack {
                Text(plan.volumeName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(isActive ? green : .white)
                Spacer()
                if isActive {

                    Text("Activated")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(green)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(green.opacity(0.15))
                        .cornerRadius(6)

                } else if isPendingReview {

                    Text("Pending Review")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(6)
                }
            }

            // Bullets
            VStack(alignment: .leading, spacing: 6) {
                if plan.volumeName != "Enterprise Plan" {
                    bullet("Daily Limit: $\(plan.formattedDailyCap)")
                    bullet("Monthly Transactions: \(plan.formattedMonthlyCap)")
                }
                if plan.volumeName == "Basic Plan" {
                    bullet("Merchant needs Valid Govt issued Tax ID and a functioning online website.")
                }
                if plan.volumeName == "Business Plan" {
                    bullet("Valid Govt. issued Tax Id.")
                    bullet("Principal/Director/Owner Photo Identification.")
                    bullet("Proof of Business Address.")
                    bullet("Business Registration Documents.")
                }
                if plan.volumeName == "Enterprise Plan" {
                    bullet("Contact support for enterprise onboarding.")
                }
            }

            // Apply / Pending row
            if !isActive && plan.volumeName != "Enterprise Plan" {
                HStack(alignment: .center, spacing: 10) {

                    Button(action: onApply) {
                        Text("APPLY")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                            .background(purple)
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)

                    if isPendingReview {
                        Text("Requested and waiting for review")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(orange)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(orange.opacity(0.12))
                            .cornerRadius(6)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isActive ? green.opacity(0.07) : cardBG)
        .cornerRadius(14)
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    isActive ? green.opacity(0.40) : Color.white.opacity(0.10),
                    lineWidth: 1
                )
        }
    }

    @ViewBuilder
    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.70))
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.70))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ApprovedVolumeSheet(viewModel: LimitsViewModel())
        }
}
