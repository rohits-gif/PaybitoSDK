//  AddSubMerchantViewModel.swift
//  Trading_Terminal

import Foundation
import Combine

@MainActor
final class AddSubMerchantViewModel: ObservableObject {

    // MARK: - Menu State
    @Published var menuItems:      [MenuItemModel]       = []
    @Published var permissions:    [Int: MenuPermission] = [:]
    @Published var isLoadingMenus: Bool                  = false
    @Published var menuLoadError:  String?               = nil

    // MARK: - Create State
    @Published var isCreating:    Bool    = false
    @Published var createError:   String? = nil
    @Published var createSuccess: Bool    = false

    // MARK: - Form Fields
    @Published var firstName:  String = ""
    @Published var lastName:   String = ""
    @Published var gender:     String = "Mr."
    @Published var email:      String = ""
    @Published var phone:      String = ""
    @Published var password:   String = ""
    @Published var confirmPwd: String = ""

    // MARK: - Dependency
    private let service: SubMerchantServiceProtocol

    init(service: SubMerchantServiceProtocol = AddUserManagementService.shared) {
        self.service = service
        debugPrint("🛠️ [AddSubMerchantViewModel] init")
    }

    // MARK: - Validation
    var isFormValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty     &&
        !password.isEmpty                                        &&
        password == confirmPwd                                   &&
        !isCreating
    }

    // MARK: - Fetch Menus
    func fetchMenus() {
        guard !isLoadingMenus else {
            debugPrint("⚠️ [AddSubMerchantViewModel] already loading, skipping")
            return
        }
        isLoadingMenus = true
        menuLoadError  = nil
        debugPrint("🔄 [AddSubMerchantViewModel] fetchMenus")

        service.getAllMenus { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isLoadingMenus = false
                switch result {
                case .success(let response):
                    guard response.error == 0 else {
                        self.menuLoadError = "Server error: \(response.errorMsg)"
                        debugPrint("⚠️ [AddSubMerchantViewModel] \(self.menuLoadError!)")
                        return
                    }
                    self.menuItems = response.list
                    debugPrint("✅ [AddSubMerchantViewModel] \(response.list.count) menus loaded")
                    var perms: [Int: MenuPermission] = [:]
                    for item in response.list {
                        let defaultRead = (item.name == "Get Started")
                        perms[item.id] = MenuPermission(read: defaultRead, write: false)
                        debugPrint("   🔐 [\(item.id)] \(item.name) read:\(defaultRead)")
                    }
                    self.permissions = perms

                case .failure(let error):
                    self.menuLoadError = error.localizedDescription
                    debugPrint("❌ [AddSubMerchantViewModel] fetchMenus: \(error)")
                }
            }
        }
    }

    // MARK: - Create Sub Merchant
    func createSubMerchant(completion: @escaping (SubMerchantCreatedModel?) -> Void) {
        guard !isCreating else { return }

        let merchantId = UserDefaults.standard.string(forKey: "Bmerchant_id") ?? ""
        let brokerId   = UserDefaults.standard.string(forKey: "brokerId")     ?? ""
        let country    = UserDefaults.standard.string(forKey: "Bcountry")     ?? "United States"

        

        debugPrint("🛠️ [AddSubMerchantViewModel] createSubMerchant")
        debugPrint("   merchantId : \(merchantId)")
        debugPrint("   brokerId   : \(brokerId)")
        debugPrint("   country    : \(country)")
        debugPrint("   firstName  : \(firstName)")
        debugPrint("   lastName   : \(lastName)")
        debugPrint("   gender     : \(gender)")
        debugPrint("   email      : \(email)")
        debugPrint("   phone      : \(phone)")
        


        // Build access_list
        var accessList: [AccessItem] = []
        for (menuId, perm) in permissions.sorted(by: { $0.key < $1.key }) {
            if perm.read  {
                accessList.append(AccessItem(access: "READ",  menuId: String(menuId)))
            }
            if perm.write {
                accessList.append(AccessItem(access: "WRITE", menuId: String(menuId)))
            }
        }
        debugPrint("   accessList (\(accessList.count)):")
        accessList.forEach { debugPrint("      \($0.access) menu_id:\($0.menuId)") }

        // Map gender label → API value
        let genderValue: String
        switch gender {
        case "Mr.":  genderValue = "Male"
        case "Mrs.": genderValue = "Female"
        default:     genderValue = "Other"
        }

        let apiRequest = CreateSubMerchantRequest(
            country:     country,
            merchantId:  merchantId,
            firstName:   firstName.trimmingCharacters(in: .whitespaces),
            lastName:    lastName.trimmingCharacters(in: .whitespaces),
            phone:       phone,
            countryCode: "1",
            gender:      genderValue,
            email:       email.trimmingCharacters(in: .whitespaces),
            password:    password,
            brokerId:    brokerId,
            accessList:  accessList
        )

        isCreating    = true
        createError   = nil
        createSuccess = false

        service.createSubMerchant(request: apiRequest) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                self.isCreating = false
                switch result {

                case .success(let response):
                    if response.error == 0 {
                        debugPrint("✅ [AddSubMerchantViewModel] created successfully")
                        self.createSuccess = true
                        // ✅ Capture fields into locals BEFORE constructing the model
                        let emailVal     = self.email
                        let firstNameVal = self.firstName
                        let lastNameVal  = self.lastName
                        let model = SubMerchantCreatedModel(
                            email:     emailVal,
                            firstName: firstNameVal,
                            lastName:  lastNameVal
                        )
                        completion(model)
                    } else {
                        debugPrint("⚠️ [AddSubMerchantViewModel] server rejected: \(response.errorMsg)")
                        self.createError = response.errorMsg
                        completion(nil)
                    }

                case .failure(let error):
                    debugPrint("❌ [AddSubMerchantViewModel] \(error.localizedDescription)")
                    self.createError = error.localizedDescription
                    completion(nil)
                }
            }
        }
    }

    // MARK: - Permission Helpers
    func setRead(_ value: Bool, for menuId: Int) {
        permissions[menuId, default: MenuPermission()].read = value
        debugPrint("🔐 [Permissions] menuId:\(menuId) read → \(value)")
    }

    func setWrite(_ value: Bool, for menuId: Int) {
        permissions[menuId, default: MenuPermission()].write = value
        debugPrint("🔐 [Permissions] menuId:\(menuId) write → \(value)")
    }

    func readValue(for menuId: Int)  -> Bool { permissions[menuId]?.read  ?? false }
    func writeValue(for menuId: Int) -> Bool { permissions[menuId]?.write ?? false }

    // MARK: - Debug Helper
    func selectedPermissions() -> [(menuId: Int, read: Bool, write: Bool)] {
        let result = permissions
            .filter { $0.value.read || $0.value.write }
            .map    { (menuId: $0.key, read: $0.value.read, write: $0.value.write) }
            .sorted { $0.menuId < $1.menuId }
        debugPrint("📋 [AddSubMerchantViewModel] selectedPermissions: \(result.count)")
        result.forEach { debugPrint("   menuId:\($0.menuId) read:\($0.read) write:\($0.write)") }
        return result
    }
}
