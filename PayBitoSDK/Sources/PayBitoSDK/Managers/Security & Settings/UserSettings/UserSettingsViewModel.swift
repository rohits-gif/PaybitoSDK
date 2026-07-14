//
//  UserSettingsViewModel.swift
//  Trading_Terminal

//
//  UserSettingsViewModel.swift
//  Trading_Terminal

//

import SwiftUI
import Alamofire
import SwiftyJSON

class UserSettingsViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var phone = ""
    @Published var twoFAEnabled = false
    
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var successMessage = ""
    
    // MARK: - Private Properties
    private var merchantId: String? {
        UserDefaults.standard.string(forKey: "Bmerchant_id")
    }
    
    private var uuid: String? {
        UserDefaults.standard.string(forKey: "Buuid")
    }
    
    private var token: String? {
        UserDefaults.standard.string(forKey: "Baccess_token")
    }
    
    private let baseURL = "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard"
    
    // MARK: - Headers Helper
    private func getHeaders() -> HTTPHeaders {
        return [
            "Authorization": "bearer \(token ?? "")",
            "UUID": uuid ?? "",
            "Content-Type": "application/json",
            "origin": "https://trade.paybito.com"
        ]
    }
    
    // MARK: - FETCH USER SETTINGS
    func fetchUserSettings() {
        
        guard let merchantId = merchantId,
              let merchantIdInt = Int(merchantId) else {
            showError("Missing authentication data")
            return
        }
        
        isLoading = true
        clearMessages()
        
        let params: [String: Any] = [
            "merchant_id": merchantIdInt
        ]
        
        print("📤 FETCH REQUEST:")
        print("URL:", "\(baseURL)/FetchUserSettings")
        print("Params:", params)
        
        Alamofire.request(
            "\(baseURL)/FetchUserSettings",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getHeaders()
        )
        .validate()
        .responseJSON { [weak self] response in
            
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch response.result {
            case .success(let value):
                print("📥 FETCH RESPONSE:", value)
                self.handleFetchResponse(JSON(value))
                
            case .failure(let error):
                print("❌ FETCH ERROR:", error.localizedDescription)
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("Response Body:", str)
                }
                self.showError("Failed to load settings: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleFetchResponse(_ json: JSON) {
        
        // Response is an array
        guard let obj = json.arrayValue.first else {
            showError("Invalid response format")
            return
        }
        
        // Check for API error
        if obj["error"].stringValue == "1" {
            showError(obj["error_msg"].stringValue)
            return
        }
        
        // Update UI on main thread
        DispatchQueue.main.async {
            self.firstName = obj["first_name"].stringValue
            self.lastName = obj["last_name"].stringValue
            self.phone = obj["phone_no"].stringValue
            self.twoFAEnabled = obj["two_factor_auth_enabled"].intValue == 1
            
            print("✅ Settings loaded successfully")
        }
    }
    
    // MARK: - SAVE SETTINGS
    func saveSettings() {
        
        guard let merchantId = merchantId,
              let merchantIdInt = Int(merchantId) else {
            showError("Missing authentication data")
            return
        }
        
        // Validation (matching web validation)
        guard !firstName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter your first name")
            return
        }
        
        guard !lastName.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter your last name")
            return
        }
        
        guard !phone.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter your phone number")
            return
        }
        
        isLoading = true
        clearMessages()
        
        let params: [String: Any] = [
            "merchant_id": merchantIdInt,
            "merchant_f_name": firstName,
            "merchant_l_name": lastName,
            "phone": phone,
            "two_factor_auth_enabled": twoFAEnabled ? 1 : 0
        ]
        
        print("📤 SAVE REQUEST:")
        print("URL:", "\(baseURL)/SaveUserSettings")
        print("Params:", params)
        
        Alamofire.request(
            "\(baseURL)/SaveUserSettings",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getHeaders()
        )
        .validate()
        .responseJSON { [weak self] response in
            
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch response.result {
            case .success(let value):
                print("📥 SAVE RESPONSE:", value)
                self.handleSaveResponse(JSON(value))
                
            case .failure(let error):
                print("❌ SAVE ERROR:", error.localizedDescription)
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("Response Body:", str)
                }
                self.showError("Failed to save: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleSaveResponse(_ json: JSON) {
        
        guard let obj = json.arrayValue.first else {
            showError("Invalid response format")
            return
        }
        
        if obj["error"].stringValue == "0" {
            // Success
            DispatchQueue.main.async {
                self.successMessage = "Successfully Saved"
                
                // Update UserDefaults (matching web behavior)
                UserDefaults.standard.set(self.firstName, forKey: "Bfirst_name")
                UserDefaults.standard.set(self.lastName, forKey: "Blast_name")
                UserDefaults.standard.set(self.phone, forKey: "BuserPhone")
                
                print("✅ Settings saved successfully")
                
                // Auto-hide success message after 6 seconds (like web)
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    self.successMessage = ""
                }
            }
        } else {
            showError(obj["error_msg"].stringValue)
        }
    }
    func verifyEmailOTP(otp: String) {

        guard let merchantId = merchantId,
              let merchantIdInt = Int(merchantId) else { return }

        let params: [String: Any] = [
            "merchant_id": merchantIdInt,
            "email_otp": otp
        ]

        Alamofire.request(
            "\(baseURL)/VerifyEmailOTP",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getHeaders()
        )
        .responseJSON { response in
            print(response)
        }
    }
    // MARK: - SEND EMAIL OTP
    func send2FAEmailOTP(completion: @escaping (Bool) -> Void) {

        isLoading = true

        let params: [String: Any] = [
            "merchant_id": merchantId ?? ""
        ]

        Alamofire.request(
            "\(baseURL)/SendOtp2faemailotp",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getHeaders()
        )
        .responseJSON { response in
            DispatchQueue.main.async {
                self.isLoading = false
                completion(response.error == nil)
            }
        }
    }
    // MARK: - GET GOOGLE QR + SECRET
    func getGoogleAuthSetup(completion: @escaping (String, String) -> Void) {

        isLoading = true

        let params: [String: Any] = [
            "merchant_id": merchantId ?? ""
        ]

        Alamofire.request(
            "\(baseURL)/GetTwoFactorykey",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getHeaders()
        )
        .responseJSON { response in

            DispatchQueue.main.async {
                self.isLoading = false

                if let value = response.value {
                    let json = JSON(value)
                    let obj = json.arrayValue.first

                    let qr = obj?["qr_code"].stringValue ?? ""
                    let secret = obj?["secret_key"].stringValue ?? ""

                    completion(qr, secret)
                }
            }
        }
    }
    
    // MARK: - CHANGE PASSWORD
    // Matching web implementation - NO OTP required by default
    func changePassword(current: String, new: String, otp: String){
        
        guard let merchantId = merchantId,
              let merchantIdInt = Int(merchantId) else {
            showError("Missing authentication data")
            return
        }
        
        // Validation (matching web validation)
        guard !current.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter your current password")
            return
        }
        
        guard !new.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError("Please enter new password")
            return
        }
        
//        guard !retype.trimmingCharacters(in: .whitespaces).isEmpty else {
//            showError("Please re-enter new password")
//            return
//        }
        
//        guard new == retype else {
//            showError("Passwords do not match")
//            return
//        }
        
        isLoading = true
        clearMessages()
        
        // Matching web parameters exactly
        let params: [String: Any] = [
            "merchant_id": merchantIdInt,
            "current_password": current,
            "new_password": new,
            "google_auth_otp": otp
        ]
        
        print("📤 PASSWORD CHANGE REQUEST:")
        print("URL:", "\(baseURL)/ChangePassword")
        print("Params:", params.keys) // Don't log passwords
        
        Alamofire.request(
            "\(baseURL)/ChangePassword",
            method: .post,
            parameters: params,
            encoding: JSONEncoding.default,
            headers: getHeaders()
        )
        .validate()
        .responseJSON { [weak self] response in
            
            guard let self = self else { return }
            
            self.isLoading = false
            
            switch response.result {
            case .success(let value):
                print("📥 PASSWORD CHANGE RESPONSE:", value)
                self.handlePasswordChangeResponse(JSON(value))
                
            case .failure(let error):
                print("❌ PASSWORD CHANGE ERROR:", error.localizedDescription)
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("Response Body:", str)
                }
                self.showError("Failed to change password: \(error.localizedDescription)")
            }
        }
    }
    
    private func handlePasswordChangeResponse(_ json: JSON) {
        
        guard let obj = json.arrayValue.first else {
            showError("Invalid response format")
            return
        }
        
        if obj["error"].stringValue == "0" {
            DispatchQueue.main.async {
                self.successMessage = "Password changed successfully"
                print("✅ Password changed successfully")
                
                // Auto-hide success message after 6 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    self.successMessage = ""
                }
            }
        } else {
            showError(obj["error_msg"].stringValue)
        }
    }
    
    // MARK: - Helper Methods
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            print("❌", message)
        }
    }
    
    private func clearMessages() {
        DispatchQueue.main.async {
            self.errorMessage = ""
            self.successMessage = ""
        }
    }
    
    func clearError() {
        errorMessage = ""
    }
    
    func clearSuccess() {
        successMessage = ""
    }
}
