//
//  Editcataloguemodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 21/05/26.
//

// Online Swift compiler to run Swift program online
// Print "Start small. Ship something." message
//
//  EditCatalogueModel.swift
//  Trading_Terminal
//
//  Request/response models specific to the Edit Catalogue APIs.
//

import Foundation

// ─────────────────────────────────────────────
// MARK: - Edit Catalogue Request
// ─────────────────────────────────────────────

/// Body for PUT /shopping/catalogue/{id}
struct EditCatalogueRequest: Encodable {
    let merchantId:  Int
    let catalogName: String
    let description: String
}

// ─────────────────────────────────────────────
// MARK: - Edit Catalogue Response
// ─────────────────────────────────────────────

/// { "status": true, "message": "...", "data": { ... } }
struct EditCatalogueResponse: Decodable {
    let status:  Bool
    let message: String
    let data:    EditCatalogueData
}

struct EditCatalogueData: Decodable {
    let id:          Int
    let merchantId:  Int
    let catalogName: String
    let description: String
    let createdAt:   String
}

// ─────────────────────────────────────────────
// MARK: - Add Product to Catalogue Response
// ─────────────────────────────────────────────

/// POST /shopping/catalogs/add-product-price
/// Response: { "success": bool, "returnId": int, "message": string }
struct AddProductToCatalogueResponse: Decodable {
    let success:  Bool
    let returnId: Int
    let message:  String
}
