

//
//  PaymentsConstants.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/04/26.
//

import Foundation

struct PaymentsConstants {
    // MARK: - Base URLs
    static let baseURLMerchant = "https://service.hashcashconsultants.com/billbitcoins-v2/"
    static let baseURLPayBito   = "https://accounts.paybito.com/api/"

    // MARK: - Auth
    static let basicAuthValue   = "Basic bXktdHJ1c3RlZC1jbGllbnQ6c2VjcmV0"
    static let originHeader     = "9E5XLQU4+cJS8AbKqd5BbPIS+qu1Iv3Dk6ntcvKvDvtMpwbGTvJb4tAF7Uomk1fc"
    static let brokerID         = "PAYB18022021121103"
    static let deviceType       = "iOS"
    static let recaptchaSiteKey = "6LcnlkghAAAAAHkjawugM_r0kzNmBq8R9LMaGUiV"
    static let locationAPIKey   = "693da481af1b4a3e80e3dfea9115dc52"
    static let termsURL         = "https://www.paybito.com/terms-of-use/"

    // MARK: - UserDefaults keys
    static let accessTokenKey   = "ACCESS_TOKEN"
    static let merchantIdKey    = "MERCHANT_ID"
    static let uuidKey          = "USER_UUID"
    static let userEmailKey     = "USER_EMAIL"

    // MARK: - Transfer types
    static let transferPayBitoWallet   = "0"
    static let transferExternalWallet  = "1"
    static let withdrawToBank          = "2"
    static let erc20                   = "ERC 20"

    // MARK: - 2FA validation types
    static let otpValidationAll     = 0
    static let otpValidationPhone   = 1
    static let otpValidationGA      = 2
    static let otpValidationNone    = 3

    // MARK: - Phone number types
    static let oldPhoneType = 1
    static let newPhoneType = 2

    // MARK: - Validation messages
    static let emailValid          = "Enter a valid email"
    static let phoneValid          = "Enter a valid phone number"
    static let passwordNotMatch    = "Password does not match"
    static let passwordValid       = "Password must be 8-35 characters with at least one uppercase, lowercase, number, and special character ($@.!)."
    static let otpSent             = "Secure token sent to registered email"
    static let otpError            = "Either Email or Client Id is incorrect"
    static let emptyField          = "Field cannot be empty"
    static let apiError            = "Something went wrong! Please try again."
    static let loginError          = "Either email or password is incorrect"

    // MARK: - Password regex
    static let passwordRegex = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z])(?=.*[$@.!])(?=\\S+$).{8,}$"
}

