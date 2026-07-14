import Foundation

// ============================================================
// MARK: - API Response Models (Codable)
// ============================================================

struct PCCatalogueResponse: Codable {
    let status:  Bool
    let message: String?
    let data:    PCCatalogueData?
}

struct PCCatalogueData: Codable {
    let id:          Int
    let merchantId:  Int
    let catalogName: String
    let description: String?
    let createdAt:   String
    let productCount: Int?
}

struct PCGetCataloguesResponse: Codable {
    let status:  Bool
    let message: String?
    let data:    [PCCatalogueData]?
}

struct PCCatalogProductSelection {
    var productId:   String
    var rawPriceId:  Int
    var productName: String
    var priceID:     String
    var priceDisplay: String?
    var quantity:    Int?
    var currencies:  [String]
}

// ============================================================
// MARK: - Catalogue Products Response
// GET /shopping/catalogs/products/{catalogId}


// ============================================================
// MARK: - Local UI Model
// ============================================================

struct PCCatalogueItem: Identifiable {
    let id:           Int
    var name:         String
    var description:  String
    var productCount: Int
    var createdAt:    String = ""

    init(from data: PCCatalogueData) {
        self.id           = data.id
        self.name         = data.catalogName
        self.description  = data.description ?? ""
        self.createdAt    = data.createdAt
        self.productCount = data.productCount ?? 0
    }

    init(id: Int = Int.random(in: 1000...9999),
         name: String, description: String = "", productCount: Int = 0) {
        self.id           = id
        self.name         = name
        self.description  = description
        self.productCount = productCount
    }
}
