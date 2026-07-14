import SwiftUI

// MARK: - Theme Colors
private extension Color {
    static let kycBgPrimary     = Color(red: 0.08, green: 0.09, blue: 0.13)
    static let kycBgCard        = Color(red: 0.11, green: 0.13, blue: 0.18)
    static let kycBgCardBorder  = Color(red: 0.18, green: 0.21, blue: 0.28)
    static let kycAccent        = Color(red: 0.47, green: 0.38, blue: 0.85)
    static let kycAccentLight   = Color(red: 0.58, green: 0.47, blue: 0.95)
    static let kycTextPrimary   = Color.white
    static let kycTextSecondary = Color(red: 0.70, green: 0.72, blue: 0.78)
    static let kycInfoBlue      = Color(red: 0.38, green: 0.55, blue: 0.95)
    static let kycInfoBlueBg    = Color(red: 0.10, green: 0.16, blue: 0.28)
}

// MARK: - Account Type Model
private struct KYCAccountType: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let iconName: String
    let features: [String]
    let buttonLabel: String
}

// MARK: - Feature Row
private struct KYCFeatureRow: View {
    let text: String
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.kycAccent.opacity(0.2))
                    .frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.kycAccentLight)
            }
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(.kycTextSecondary)
            Spacer()
        }
    }
}

// MARK: - Account Card
private struct KYCAccountCard: View {
    let account: KYCAccountType
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 16) {
                Image(systemName: account.iconName)
                    .font(.system(size: 42))
                    .foregroundColor(.kycAccent)
                    .padding(.top, 28)

                VStack(spacing: 6) {
                    Text(account.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.kycTextPrimary)
                    Text(account.subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.kycTextSecondary)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    ForEach(account.features, id: \.self) { feature in
                        KYCFeatureRow(text: feature)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)

            Button(action: action) {
                Text(account.buttonLabel)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.kycAccentLight, Color.kycAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(14)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color.kycBgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.kycBgCardBorder, lineWidth: 1)
        )
    }
}

// MARK: - Info Banner
private struct KYCInfoBanner: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Not sure which to choose?")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(.kycTextPrimary)

            Text("Individual accounts are for personal use, while Enterprise accounts are for registered businesses.")
                .font(.system(size: 14))
                .foregroundColor(.kycTextSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "info.circle")
                    .font(.system(size: 14))
                    .foregroundColor(.kycInfoBlue)
                    .padding(.top, 1)

                Text("If you are a merchant seeking card payment services, you must complete Enterprise KYC verification.")
                    .font(.system(size: 14))
                    .foregroundColor(.kycInfoBlue)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(Color.kycInfoBlueBg)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .padding(16)
        .background(Color.kycBgCard)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.kycBgCardBorder, lineWidth: 1)
        )
    }
}

// MARK: - FAB
private struct KYCFAB: View {
    var body: some View {
        Button(action: {}) {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.kycAccent)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.kycAccent.opacity(0.5), radius: 12, x: 0, y: 4)
        }
    }
}

// MARK: - Main Selection View
struct KYCVerificationView: View {
    @Environment(\.dismiss) var dismiss

    // Navigation flags
   // @State private var navigateToIndividual  = false
    @State private var navigateToEnterprise  = false

    private let accounts: [KYCAccountType] = [
//        KYCAccountType(
//            title: "Individual",
//            subtitle: "For personal accounts and individual traders",
//            iconName: "person.fill",
//            features: [
//                "Personal ID verification",
//                "Address proof upload",
//                "Employment details",
//                "Photo verification"
//            ],
//            buttonLabel: "Select Individual"
//        ),
        KYCAccountType(
            title: "Enterprise",
            subtitle: "For businesses and corporate accounts",
            iconName: "building.2.fill",
            features: [
                "Company information",
                "Business documents",
                "Authorization letter",
                "Beneficial owners"
            ],
            buttonLabel: "Select Enterprise"
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.kycBgPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(accounts) { account in
                            KYCAccountCard(account: account) {
                                if account.title == "Individual" {
                                 //   navigateToIndividual = true
                                } else if account.title == "Enterprise" {
                                    navigateToEnterprise = true
                                }
                            }
                        }

                        KYCInfoBanner()

                        Spacer(minLength: 80)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                }

                KYCFAB()
                    .padding(.trailing, 16)
                    .padding(.bottom, 24)

                // ✅ Individual navigation (KYCFormView — wire up when ready)
                NavigationLink(
                    destination: KYCFormView(),
                 //   isActive: $navigateToIndividual
                ) {
                    EmptyView()
                }
                .hidden()

                // ✅ Enterprise → KYCEnterpriseFormView
                NavigationLink(
                    destination: EnterpriseKycFormView(),
                    isActive: $navigateToEnterprise
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .navigationTitle("KYC Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview {
    KYCVerificationView()
}
