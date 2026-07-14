//
//  OTPVerificationView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 24/04/26.
//
import SwiftUI

struct OTPVerificationView: View {

    @Binding var otpCode: String
    var type: UserSettingsView.OTPType
    var onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            Text("Security Authentication")
                .font(.headline)

            if type == .google {
                Text("Enter Google Authenticator Code")
            }

            if type == .email {
                Text("Enter Email OTP")
            }

            TextField("Enter OTP", text: $otpCode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button("Confirm") {
                onConfirm()
                dismiss()
            }
            .disabled(!isValid)

            Button("Cancel") {
                dismiss()
            }
        }
        .padding()
    }

    var isValid: Bool {
        switch type {
        case .google:
            return otpCode.count == 6
        case .email:
            return otpCode.count == 7
        case .both:
            return false
        }
    }
}
