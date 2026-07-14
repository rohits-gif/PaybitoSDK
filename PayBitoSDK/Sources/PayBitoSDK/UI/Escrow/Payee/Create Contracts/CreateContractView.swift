import SwiftUI

// MARK: - Hex Color Helper (non-conflicting name)
private func hx(_ hex: String) -> Color {
    var h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: h).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch h.count {
    case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:(a, r, g, b) = (255, 0, 0, 0)
    }
    return Color(
        .sRGB,
        red:     Double(r) / 255,
        green:   Double(g) / 255,
        blue:    Double(b) / 255,
        opacity: Double(a) / 255
    )
}

// MARK: - Placeholder helper
extension View {
    func placeholder<C: View>(
        when show: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> C
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(show ? 1 : 0)
            self
        }
    }
}

// MARK: - Step Model
struct ContractStep: Identifiable {
    let id   = UUID()
    let index: Int
    let title: String
    let icon:  String
}

// MARK: - Step Indicator
struct StepIndicatorView: View {
    let steps:       [ContractStep]
    let currentStep: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(steps) { step in
                    HStack(spacing: 0) {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(circleBg(step.index))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .stroke(circleBorder(step.index), lineWidth: 1.5)
                                    )
                                Image(systemName: step.icon)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(iconColor(step.index))
                            }
                            Text(step.title)
                                .font(.system(size: 10,
                                              weight: step.index == currentStep ? .semibold : .regular))
                                .foregroundColor(labelColor(step.index))
                                .multilineTextAlignment(.center)
                                .frame(width: 68)
                                .lineLimit(2)
                        }

                        if step.index < steps.count - 1 {
                            Rectangle()
                                .fill(step.index < currentStep
                                      ? hx("#5B6EF5")
                                      : hx("#252840"))
                                .frame(width: 32, height: 2)
                                .padding(.bottom, 22)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func circleBg(_ i: Int) -> Color {
        if i == currentStep { return hx("#5B6EF5") }
        if i <  currentStep { return hx("#1B2547") }
        return hx("#1A1D2E")
    }
    private func circleBorder(_ i: Int) -> Color {
        if i == currentStep { return hx("#5B6EF5") }
        if i <  currentStep { return hx("#3E5AB5") }
        return hx("#2E3150")
    }
    private func iconColor(_ i: Int) -> Color {
        if i == currentStep { return .white }
        if i <  currentStep { return hx("#6E9EFA") }
        return hx("#4A4F66")
    }
    private func labelColor(_ i: Int) -> Color {
        if i == currentStep { return .white }
        if i <  currentStep { return hx("#6E9EFA") }
        return hx("#4A4F66")
    }
}

// MARK: - Main View
struct EscrowContractBuilderView: View {
    @State private var contractName:        String = ""
    @State private var contractDescription: String = ""
    @State private var currentStep:         Int    = 0

    let steps: [ContractStep] = [
        ContractStep(index: 0, title: "Contract Details",    icon: "doc.text.fill"),
        ContractStep(index: 1, title: "Approvers",           icon: "person.2.fill"),
        ContractStep(index: 2, title: "Release Conditions",  icon: "list.bullet.clipboard.fill"),
        ContractStep(index: 3, title: "Payees",              icon: "creditcard.fill"),
        ContractStep(index: 4, title: "Review",              icon: "checkmark.seal.fill"),
    ]

    var body: some View {
        ZStack {
            hx("#0F1117").ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // Title block
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Full Escrow Contract Builder")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Define all parties, conditions, and fund the escrow in one flow.")
                            .font(.system(size: 14))
                            .foregroundColor(hx("#8A8FA8"))
                    }

                    // Steps
                    StepIndicatorView(steps: steps, currentStep: currentStep)

                    // Card
                    VStack(alignment: .leading, spacing: 20) {

                        // Card header
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 13))
                                .foregroundColor(hx("#8A8FA8"))
                            Text("CONTRACT DETAILS")
                                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                                .foregroundColor(hx("#8A8FA8"))
                                .tracking(1.5)
                        }

                        Divider().background(hx("#2A2D3E"))

                        // Contract Name
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("Contract Name")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(hx("#C8CCDE"))
                                Text("*")
                                    .foregroundColor(hx("#E55C5C"))
                                    .font(.system(size: 14, weight: .bold))
                            }

                            TextField("", text: $contractName)
                                .placeholder(when: contractName.isEmpty) {
                                    Text("e.g. Software Development Agreement")
                                        .foregroundColor(hx("#4A4F66"))
                                }
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 13)
                                .background(hx("#1A1D2E"))
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(hx("#2E3150"), lineWidth: 1)
                                )
                        }

                        // Contract Description
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Text("Contract Description")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(hx("#C8CCDE"))
                                Text("Optional")
                                    .font(.system(size: 12))
                                    .foregroundColor(hx("#5A5F78"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(hx("#1E2135"))
                                    .cornerRadius(4)
                            }

                            ZStack(alignment: .topLeading) {
                                if contractDescription.isEmpty {
                                    Text("e.g. This escrow covers the development and delivery of a mobile application...")
                                        .foregroundColor(hx("#4A4F66"))
                                        .font(.system(size: 15))
                                        .padding(.horizontal, 14)
                                        .padding(.top, 14)
                                        .allowsHitTesting(false)
                                }
                                TextEditor(text: $contractDescription)
                                    .font(.system(size: 15))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 10)
                                    .frame(minHeight: 120)
                            }
                            .background(hx("#1A1D2E"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(hx("#2E3150"), lineWidth: 1)
                            )

                            Text("Briefly describe the purpose or scope of this escrow contract")
                                .font(.system(size: 12))
                                .foregroundColor(hx("#5A5F78"))
                        }
                    }
                    .padding(20)
                    .background(hx("#161929"))
                    .cornerRadius(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(hx("#252840"), lineWidth: 1)
                    )

                    // Action buttons — equal width, fitted to screen
                    HStack(spacing: 10) {
                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Cancel")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(hx("#C8CCDE"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(hx("#1E2135"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(hx("#2E3150"), lineWidth: 1)
                            )
                        }

                        Button(action: {}) {
                            HStack(spacing: 6) {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Save as Draft")
                                    .font(.system(size: 15, weight: .medium))
                            }
                            .foregroundColor(hx("#6E9EFA"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(hx("#1B2547"))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(hx("#2E4A9A"), lineWidth: 1)
                            )
                        }

                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                if currentStep < steps.count - 1 { currentStep += 1 }
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("Continue")
                                    .font(.system(size: 15, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(
                                LinearGradient(
                                    colors: [hx("#5B6EF5"), hx("#7B5EA7")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                            .shadow(color: hx("#5B6EF5").opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                    }
                }
                .padding(20)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    EscrowContractBuilderView()
}
