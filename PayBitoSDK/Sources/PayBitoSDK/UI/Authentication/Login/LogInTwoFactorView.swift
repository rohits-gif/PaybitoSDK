//import SwiftUI
//
//// MARK: - Hex Color Helper (avoids redeclaration conflicts)
//private func hexColor(_ hex: String) -> Color {
//    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//    var int: UInt64 = 0
//    Scanner(string: hex).scanHexInt64(&int)
//    let a, r, g, b: UInt64
//    switch hex.count {
//    case 3:
//        (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//    case 6:
//        (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//    case 8:
//        (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//    default:
//        (a, r, g, b) = (255, 0, 0, 0)
//    }
//    return Color(
//        .sRGB,
//        red: Double(r) / 255,
//        green: Double(g) / 255,
//        blue: Double(b) / 255,
//        opacity: Double(a) / 255
//    )
//}
//
//// MARK: - Main Login View (Background)
//struct PayBitoLoginView: View {
//    @State private var email = "rajit@hashcashconsultants.com"
//    @State private var password = ""
//    @State private var showAuthSheet = true
//
//    var body: some View {
//        ZStack {
//            hexColor("#0A0D1A")
//                .ignoresSafeArea()
//
//            VStack(spacing: 24) {
//                // Header
//                VStack(spacing: 8) {
//                    Text("Welcome to PayBito")
//                        .font(.system(size: 28, weight: .bold))
//                        .foregroundStyle(Color.white)
//                    Text("Sign in to your payment account")
//                        .font(.system(size: 14))
//                        .foregroundStyle(hexColor("#8A8FA8"))
//                }
//                .padding(.top, 60)
//
//                // Form Fields
//                VStack(alignment: .leading, spacing: 16) {
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Email Address *")
//                            .font(.system(size: 13))
//                            .foregroundStyle(hexColor("#8A8FA8"))
//                        TextField("", text: $email)
//                            .foregroundStyle(Color.white)
//                            .padding()
//                            .background(hexColor("#1A1E2E"))
//                            .cornerRadius(10)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(hexColor("#2A2F45"), lineWidth: 1)
//                            )
//                    }
//
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Password *")
//                            .font(.system(size: 13))
//                            .foregroundStyle(hexColor("#8A8FA8"))
//                        SecureField("", text: $password)
//                            .foregroundStyle(Color.white)
//                            .padding()
//                            .background(hexColor("#1A1E2E"))
//                            .cornerRadius(10)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(hexColor("#2A2F45"), lineWidth: 1)
//                            )
//                    }
//                }
//                .padding(.horizontal, 24)
//
//                Spacer()
//            }
//        }
//        .sheet(isPresented: $showAuthSheet) {
//            SecurityAuthSheet(isPresented: $showAuthSheet)
//        }
//    }
//}
//
//// MARK: - Security Authentication Bottom Sheet
//struct SecurityAuthSheet: View {
//    @Binding var isPresented: Bool
//    @State private var emailOTP = ""
//    @State private var authenticatorCode = ""
//
//    var body: some View {
//        ZStack {
//            hexColor("#141728")
//                .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                // Drag Indicator
//                RoundedRectangle(cornerRadius: 3)
//                    .fill(hexColor("#3A3F55"))
//                    .frame(width: 40, height: 5)
//                    .padding(.top, 12)
//                    .padding(.bottom, 20)
//
//                ScrollView {
//                    VStack(alignment: .leading, spacing: 24) {
//                        // Header Row
//                        HStack {
//                            Text("Security Authentication")
//                                .font(.system(size: 20, weight: .bold))
//                                .foregroundStyle(Color.white)
//                            Spacer()
//                            Button(action: { isPresented = false }) {
//                                ZStack {
//                                    Circle()
//                                        .fill(hexColor("#2A2F45"))
//                                        .frame(width: 32, height: 32)
//                                    Image(systemName: "xmark")
//                                        .font(.system(size: 13, weight: .semibold))
//                                        .foregroundStyle(hexColor("#8A8FA8"))
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 24)
//
//                        // Email OTP Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("*One-time password sent to your email.")
//                                .font(.system(size: 13))
//                                .foregroundStyle(hexColor("#8A8FA8"))
//
//                            Text("Email OTP")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundStyle(hexColor("#C8CDDE"))
//
//                            HStack {
//                                TextField("Enter email OTP", text: $emailOTP)
//                                    .foregroundStyle(Color.white)
//                                    .font(.system(size: 15))
//
//                                Button(action: {}) {
//                                    Text("Get OTP")
//                                        .font(.system(size: 14, weight: .semibold))
//                                        .foregroundStyle(hexColor("#6C63FF"))
//                                }
//                            }
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 18)
//                            .background(hexColor("#1A1E2E"))
//                            .cornerRadius(12)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(hexColor("#2A2F45"), lineWidth: 1)
//                            )
//                        }
//                        .padding(.horizontal, 24)
//
//                        // Google Authenticator Section
//                        VStack(alignment: .leading, spacing: 10) {
//                            Text("*Input 6 digit Code from your google authenticator app.")
//                                .font(.system(size: 13))
//                                .foregroundStyle(hexColor("#8A8FA8"))
//
//                            Text("Google Authenticator Code")
//                                .font(.system(size: 14, weight: .medium))
//                                .foregroundStyle(hexColor("#C8CDDE"))
//
//                            TextField("6-digit code from authenticator", text: $authenticatorCode)
//                                .foregroundStyle(Color.white)
//                                .font(.system(size: 15))
//                                .keyboardType(.numberPad)
//                                .padding(.horizontal, 16)
//                                .padding(.vertical, 18)
//                                .background(hexColor("#1A1E2E"))
//                                .cornerRadius(12)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 12)
//                                        .stroke(hexColor("#2A2F45"), lineWidth: 1)
//                                )
//                        }
//                        .padding(.horizontal, 24)
//
//                        // Action Buttons
//                        HStack(spacing: 16) {
//                            // Submit Button
//                            Button(action: {}) {
//                                Text("Submit")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundStyle(Color.white)
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.vertical, 18)
//                                    .background(
//                                        LinearGradient(
//                                            colors: [hexColor("#8B5CF6"), hexColor("#6366F1")],
//                                            startPoint: .leading,
//                                            endPoint: .trailing
//                                        )
//                                    )
//                                    .cornerRadius(14)
//                            }
//
//                            // Cancel Button
//                            Button(action: { isPresented = false }) {
//                                Text("Cancel")
//                                    .font(.system(size: 16, weight: .semibold))
//                                    .foregroundStyle(Color.white)
//                                    .frame(maxWidth: .infinity)
//                                    .padding(.vertical, 18)
//                                    .background(Color.clear)
//                                    .cornerRadius(14)
//                                    .overlay(
//                                        RoundedRectangle(cornerRadius: 14)
//                                            .stroke(hexColor("#6366F1"), lineWidth: 2)
//                                    )
//                            }
//                        }
//                        .padding(.horizontal, 24)
//                        .padding(.bottom, 40)
//                    }
//                }
//            }
//        }
//        .presentationDetents([.medium, .large])
//        .presentationDragIndicator(.hidden)
//        .presentationCornerRadius(24)
//    }
//}
//
//// MARK: - Preview
//#Preview {
//    PayBitoLoginView()
//}
