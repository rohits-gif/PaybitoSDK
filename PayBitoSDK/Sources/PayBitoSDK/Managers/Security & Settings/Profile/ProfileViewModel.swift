//
//  ProfileViewModel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 23/04/26.
//

import SwiftUI
import Alamofire
import Foundation
import SwiftyJSON

class ProfileViewModel: ObservableObject {

    @Published var memberSince = ""
    @Published var firstName = ""
    @Published var lastName = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var merchantId = ""
    @Published var country = ""
    @Published var address = ""
    @Published var city = ""
    @Published var state = ""
    @Published var zip = ""
    @Published var organization = ""
    @Published var profileImage: UIImage? = nil
    @Published var isLoading = false
    @Published var uploadSuccess: Bool? = nil   // nil = idle, true = ok, false = failed

    // MARK: - Fetch Profile

    func fetchProfile() {

        guard let merchantId = UserDefaults.standard.string(forKey: "Bmerchant_id"),
              let uuid     = UserDefaults.standard.string(forKey: "Buuid"),
              let token    = UserDefaults.standard.string(forKey: "Baccess_token") else {
            print("❌ Missing UserDefaults values")
            return
        }

        print("🚀 START FETCH PROFILE")
        isLoading = true

        let headers: HTTPHeaders = [
            "Authorization": "bearer \(token)",
            "UUID": uuid,
            "Content-Type": "application/json",
            "origin": "https://trade.paybito.com"
        ]

        let group = DispatchGroup()
        var userData: JSON    = [:]
        var merchantData: JSON = [:]
        var basicData: JSON   = [:]

        // 1. USER SETTINGS
        group.enter()
        Alamofire.request(
            "https://service.hashcashconsultants.com/billbitcoins-v2/MerchantDashboard/FetchUserSettings",
            method: .post,
            parameters: ["merchant_id": merchantId],
            encoding: JSONEncoding.default,
            headers: headers
        ).responseJSON { res in
            print("\n🟦 USER SETTINGS:", res.response?.statusCode ?? 0)
            if let val = res.value {
                userData = JSON(val).arrayValue.first ?? [:]
            }
            group.leave()
        }

        // 2. MERCHANT PROFILE
        group.enter()
        Alamofire.request(
            "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/FetchMerchantProfile",
            method: .post,
            parameters: ["merchant_id": merchantId],
            encoding: JSONEncoding.default,
            headers: headers
        ).responseJSON { res in
            print("\n🟨 MERCHANT PROFILE:", res.response?.statusCode ?? 0)
            if let val = res.value {
                merchantData = JSON(val).arrayValue.first ?? [:]
            }
            group.leave()
        }

        // 3. BASIC VERIFICATION
        group.enter()
        Alamofire.request(
            "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/FetchBasicVerification",
            method: .post,
            parameters: ["merchant_id": merchantId],
            encoding: JSONEncoding.default,
            headers: headers
        ).responseJSON { res in
            print("\n🟩 BASIC VERIFICATION:", res.response?.statusCode ?? 0)
            if let val = res.value {
                basicData = JSON(val).arrayValue.first ?? [:]
            }
            group.leave()
        }

        // FINAL MERGE
        group.notify(queue: .main) {
            self.isLoading = false

            self.firstName = !basicData["owner_first_name"].stringValue.isEmpty
                ? basicData["owner_first_name"].stringValue
                : (!userData["first_name"].stringValue.isEmpty
                    ? userData["first_name"].stringValue
                    : UserDefaults.standard.string(forKey: "Bfirst_name") ?? "")

            self.lastName = !basicData["owner_last_name"].stringValue.isEmpty
                ? basicData["owner_last_name"].stringValue
                : (!userData["last_name"].stringValue.isEmpty
                    ? userData["last_name"].stringValue
                    : UserDefaults.standard.string(forKey: "Blast_name") ?? "")

            self.email = userData["email"].stringValue.isEmpty
                ? UserDefaults.standard.string(forKey: "Bemail") ?? "—"
                : userData["email"].stringValue

            self.phone = basicData["phone_no"].stringValue.isEmpty
                ? userData["phone_no"].stringValue
                : basicData["phone_no"].stringValue

            self.organization = basicData["organization_name"].stringValue.isEmpty
                ? merchantData["organization_name"].stringValue
                : basicData["organization_name"].stringValue

            self.address    = basicData["address_line_1"].stringValue
            self.city       = basicData["city"].stringValue
            self.state      = basicData["state"].stringValue
            self.zip        = basicData["zip"].stringValue
            self.country    = basicData["country"].stringValue
            self.merchantId = merchantId

            let rawDate = UserDefaults.standard.string(forKey: "Bcreated_on") ?? ""
            self.memberSince = rawDate.isEmpty ? "—" : self.formatDate(rawDate)

            print("✅ Name:", self.firstName, self.lastName)
            print("✅ Email:", self.email)

            self.fetchProfileImage(uuid: uuid)
        }
    }

    // MARK: - Fetch Profile Image
    // FIX: Added auth headers — without them the server returns an error JSON
    // instead of image data, so UIImage(data:) silently returns nil.

    func fetchProfileImage(uuid: String) {
        guard let token = UserDefaults.standard.string(forKey: "Baccess_token") else { return }

        let headers: HTTPHeaders = [
            "Authorization": "bearer \(token)",
            "UUID": uuid,
            "origin": "https://trade.paybito.com"
        ]

        Alamofire.request(
            "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/getProfilePicture/\(uuid)",
            headers: headers
        ).responseData { res in
            let statusCode = res.response?.statusCode ?? 0
            print("🖼 getProfilePicture HTTP status:", statusCode)

            guard
                statusCode == 200,                    // ← reject non-200
                let data = res.data,
                data.count > 500,                     // ← reject tiny JSON error bodies
                let img = UIImage(data: data)
            else {
                print("⚠️ No valid image data for uuid:", uuid,
                      "| size:", res.data?.count ?? 0, "bytes")
                return
            }

            DispatchQueue.main.async {
                self.profileImage = img
                print("✅ Profile image loaded, size:", data.count, "bytes")
            }
        }
    }

    // MARK: - Upload Profile Image
    // Mirrors the web's POST to uploadProfilePicture with multipart form data.
    // On success (error:0) updates profileImage immediately for instant UI feedback.

    // MARK: - Upload Profile Image

    func uploadProfileImage(_ image: UIImage, uuid: String) {
        guard
            let token = UserDefaults.standard.string(forKey: "Baccess_token"),
            let merchantId = UserDefaults.standard.string(forKey: "Bmerchant_id"),
            let imageData = image.jpegData(compressionQuality: 0.8)
        else {
            print("❌ Upload prerequisites missing")
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "bearer \(token)",
            "UUID": uuid,
            "origin": "https://trade.paybito.com"
        ]

        isLoading = true
        uploadSuccess = nil

        Alamofire.upload(
            multipartFormData: { form in

                // EXACT field names from web request
                form.append(imageData,
                            withName: "profile_picture",
                            fileName: "profile.jpg",
                            mimeType: "image/jpeg")

                form.append(merchantId.data(using: .utf8)!,
                            withName: "merchant_id")

                form.append(uuid.data(using: .utf8)!,
                            withName: "uuid")
            },
            to: "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/uploadProfilePicture",
            method: .post,
            headers: headers
        ) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    DispatchQueue.main.async {
                        self.isLoading = false

                        print("HTTP:", response.response?.statusCode ?? 0)
                        print("JSON:", response.value ?? "nil")

                        if let json = response.value as? [String: Any],
                           response.response?.statusCode == 200,
                           (json["error"] as? Int) == 0 {
                            self.profileImage = image
                            self.uploadSuccess = true
                        } else {
                            self.uploadSuccess = false
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.uploadSuccess = false
                    print(error)
                }
            }
        }
    }

    // MARK: - Date Formatter

    func formatDate(_ dateString: String) -> String {
        let formats = [
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]
        let output = DateFormatter()
        output.dateFormat = "MMM dd, yyyy"

        for format in formats {
            let input = DateFormatter()
            input.dateFormat = format
            input.locale = Locale(identifier: "en_US_POSIX")
            if let date = input.date(from: dateString) {
                return output.string(from: date)
            }
        }
        return "—"
    }
}
