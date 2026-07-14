import SwiftUI

struct GetPaidSheet: View {
    @Environment(\.dismiss) private var dismiss

    let onCreatePayment: () -> Void
    let onPaymentLinks: () -> Void
    let onProducts: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.35))
                .frame(width: 42, height: 5)
                .padding(.top, 10)

            HStack {
                Text("Get Paid")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 14)

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            VStack(spacing: 10) {
                GetPaidRow(
                    icon: "creditcard",
                    title: "Create Payment"
                ) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onCreatePayment()
                    }
                }

                GetPaidRow(
                    icon: "doc.text",
                    title: "View Payment Links"
                ) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onPaymentLinks()
                    }
                }

                GetPaidRow(
                    icon: "cart",
                    title: "Products"
                ) {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        onProducts()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)

            Spacer(minLength: 10)
        }
        .frame(maxWidth: .infinity)
        .background(Color.bbDarkBG)
        .presentationCornerRadius(26)
    }
}

struct GetPaidRow: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.bbAccentBlue.opacity(0.12))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: icon)
                            .font(.system(size: 22))
                            .foregroundColor(.bbAccentBlue)
                    )

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray.opacity(0.8))
            }
            .frame(height: 64)
        }
        .buttonStyle(.plain)
    }
}
