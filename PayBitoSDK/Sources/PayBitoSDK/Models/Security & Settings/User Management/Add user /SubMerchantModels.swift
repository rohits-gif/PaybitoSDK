//  SubMerchantModels.swift
//  Trading_Terminal

import Foundation

// MARK: - Get All Menus Response
struct GetAllMenusResponse: Decodable {
    let errorMsg: String
    let error:    Int
    let list:     [MenuItemModel]

    enum CodingKeys: String, CodingKey {
        case errorMsg = "error_msg"
        case error
        case list
    }
}

// MARK: - Menu Item
struct MenuItemModel: Decodable, Identifiable {
    let id:   Int
    let name: String
}

// MARK: - Menu Permission
struct MenuPermission {
    var read:  Bool
    var write: Bool
    init(read: Bool = false, write: Bool = false) {
        self.read  = read
        self.write = write
    }
}

// MARK: - Access Item
struct AccessItem: Encodable {
    let access: String
    let menuId: String

    enum CodingKeys: String, CodingKey {
        case access
        case menuId = "menu_id"
    }
}

// MARK: - Create Sub Merchant Request
struct CreateSubMerchantRequest: Encodable {
    let country:     String
    let merchantId:  String
    let firstName:   String
    let lastName:    String
    let phone:       String
    let countryCode: String
    let gender:      String
    let email:       String
    let password:    String
    let brokerId:    String
    let accessList:  [AccessItem]

    enum CodingKeys: String, CodingKey {
        case country
        case merchantId  = "merchant_id"
        case firstName   = "first_name"
        case lastName    = "last_name"
        case phone
        case countryCode
        case gender
        case email
        case password
        case brokerId
        case accessList  = "access_list"
    }
}

// MARK: - Create Sub Merchant Response
struct CreateSubMerchantResponse: Decodable {
    let errorMsg: String
    let error:    Int

    enum CodingKeys: String, CodingKey {
        case errorMsg = "error_msg"
        case error
    }
}

// MARK: - Sub Merchant API Model  ✅ renamed to match ViewModel + View
// ✅ RENAMED to SubMerchantCreatedModel — unique, no conflicts
struct SubMerchantCreatedModel {
    let email:     String
    let firstName: String
    let lastName:  String
}
