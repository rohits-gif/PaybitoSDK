//
//  PaymentsValidationHelper.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/04/26.
//


import Foundation
import Combine

struct PaymentsValidationHelper {

    // MARK: - Email
    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }

    // MARK: - Password
    static func isValidPassword(_ password: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", PaymentsConstants.passwordRegex)
            .evaluate(with: password)
    }

    // MARK: - Phone
    static func isValidPhone(_ phone: String) -> Bool {
        let digits = phone.filter { $0.isNumber }
        return digits.count >= 8 && digits.count <= 15
    }

    // MARK: - OTP (6 digits)
    static func isValidOTP(_ otp: String) -> Bool {
        let digits = otp.filter { $0.isNumber }
        return digits.count == 6
    }

    // MARK: - Amount
    static func isValidAmount(_ amount: String) -> Bool {
        guard let value = Double(amount) else { return false }
        return value > 0
    }

    // MARK: - Non-empty
    static func isNonEmpty(_ text: String) -> Bool {
        return !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Name
    static func isValidName(_ name: String) -> Bool {
        let pattern = "^[a-zA-Z ]+$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: name)
            && !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Login form
    static func validateLoginForm(email: String, password: String) -> String? {
        if email.isEmpty || password.isEmpty { return PaymentsConstants.emptyField }
        if !isValidEmail(email) { return PaymentsConstants.emailValid }
        if password.count < 8 { return "Password must be at least 8 characters" }
        return nil
    }

    // MARK: - Registration form
    static func validateRegistrationForm(
        email: String,
        password: String,
        confirmPassword: String,
        phone: String,
        orgName: String
    ) -> String? {
        if email.isEmpty || password.isEmpty || phone.isEmpty || orgName.isEmpty {
            return PaymentsConstants.emptyField
        }
        if !isValidEmail(email) { return PaymentsConstants.emailValid }
        if !isValidPassword(password) { return PaymentsConstants.passwordValid }
        if password != confirmPassword { return PaymentsConstants.passwordNotMatch }
        if !isValidPhone(phone) { return PaymentsConstants.phoneValid }
        return nil
    }

    // MARK: - GA code (6 digits)
    static func isValidGACode(_ code: String) -> Bool {
        return code.count == 6 && code.allSatisfy { $0.isNumber }
    }
}
