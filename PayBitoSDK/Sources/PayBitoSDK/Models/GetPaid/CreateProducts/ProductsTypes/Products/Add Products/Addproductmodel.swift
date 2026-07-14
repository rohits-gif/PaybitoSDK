import Foundation

// MARK: - Request Models

struct AddProductRequest: Encodable {
    let merchantId: Int
    let products: [ProductPayload]
}

struct ProductPayload: Encodable {
    let productId:   String
    let productType: String
    let name:        String
    let status:      String
    let description: String
    let imageUrl:    String
    let attributes:  [String: [String]]
    let metadata:    [String: String]
    let prices:      [PricePayload]
}

struct PricePayload: Encodable {
    let isDefault:     Bool
    let priceType:     String
    let intervalType:  String?
    let intervalCount: Int?
    let trialDays:     Int
    let totalCycles:   String
    let retryAttempts: Int?
    let retryInterval: Int?
    let variant:       [String: String]
    let sku:           String
    let inventory:     InventoryPayload
    let currencies:    [CurrencyPayload]
}

struct InventoryPayload: Encodable {
    let track:    Bool
    let quantity: Int
}

struct CurrencyPayload: Encodable {
    let currency:  String
    let amount:    Double
    let isDefault: Bool
}

// MARK: - Response Models

struct AddProductResponse: Decodable {
    let status:  Bool
    let message: String
    let data:    AddProductData?
}

struct AddProductData: Decodable {
    let success:    Bool
    let registered: Int
    let products:   [RegisteredProduct]
}

struct RegisteredProduct: Decodable {
    let productId:    String?
    let priceId:      Int?
    let status:       String
    let priceStatuses: [PriceStatus]?

    enum CodingKeys: String, CodingKey {
        case productId, priceId, status, priceStatuses
    }

    init(from decoder: Decoder) throws {
        let c         = try decoder.container(keyedBy: CodingKeys.self)
        productId     = try c.decodeIfPresent(String.self,        forKey: .productId)
        priceId       = try c.decodeIfPresent(Int.self,           forKey: .priceId)
        status        = try c.decode(String.self,                 forKey: .status)
        priceStatuses = try c.decodeIfPresent([PriceStatus].self, forKey: .priceStatuses)
    }
}

struct PriceStatus: Decodable {
    let priceId: Int
    let status:  String
}

// MARK: - Image Upload Response
// POST /shopping/products/image → { "status": true, "message": "Image uploaded",
//                                   "data": "https://s3.amazonaws.com/..." }
struct ImageUploadResponse: Decodable {
    let status:  Bool
    let message: String
    let data:    String?   // S3 URL returned by server
}

// MARK: - UI / Form Models

struct AddProductFormData {
    var name:        String         = ""
    var imageURL:    String         = ""
    var status:      APProductStatus = .active
    var description: String         = ""
    var attributes:  [APAttributeEntry] = [APAttributeEntry()]
    var prices:      [APPriceEntry]     = [APPriceEntry(isDefault: true)]
    var metadata:    [APMetaEntry]      = []
}

enum APProductStatus: String {
    case active = "ACTIVE"
    case draft  = "DRAFT"
}

enum APPriceType: String {
    case oneTime      = "one-time"
    case subscription = "subscription"
}

struct APAttributeEntry: Identifiable {
    let id = UUID()
    var name:   String   = ""
    var values: [String] = []
}

struct APPriceEntry: Identifiable {
    let id = UUID()
    var type:           APPriceType = .oneTime
    var amount:         String      = ""
    var currency:       String      = "USD"
    var sku:            String      = ""
    var trackInventory: Bool        = false
    var quantity:       Int         = 0
    var isDefault:      Bool        = false
    var variant:        [String: String] = [:]
}

struct APMetaEntry: Identifiable {
    let id = UUID()
    var key:   String = ""
    var value: String = ""
}
