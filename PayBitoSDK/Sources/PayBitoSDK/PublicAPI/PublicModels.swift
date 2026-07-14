import Foundation

/// Configuration object required to initialize the SDK
public struct PaymentConfiguration {
    public let merchantId: String
    public let publicKey: String
    public let brokerId: String
    public let origin: String
    public let enableDebugLogs: Bool
    
    public init(merchantId: String, publicKey: String, brokerId: String, origin: String, enableDebugLogs: Bool = false) {
        self.merchantId = merchantId
        self.publicKey = publicKey
        self.brokerId = brokerId
        self.origin = origin
        self.enableDebugLogs = enableDebugLogs
    }
}

/// A product that can be added to the shopping cart
public struct PayBitoProduct: Identifiable, Equatable {
    public let id: String
    public let productId: String
    public let name: String
    public let price: Double
    public let imageUrl: String
    
    public init(productId: String, name: String, price: Double, imageUrl: String) {
        self.id = UUID().uuidString
        self.productId = productId
        self.name = name
        self.price = price
        self.imageUrl = imageUrl
    }
}

public enum PaymentStatus {
    case pending
    case success
    case failed
}

public struct PaymentResult {
    public let status: PaymentStatus
    public let transactionId: String?
    public let errorMessage: String?
}

public enum SDKError: Error {
    case notInitialized
    case invalidAmount
    case networkError(Error)
}

// MARK: - Dynamic Branding

/// Holds the dynamic white-label branding fetched from the broker API
public struct BrandingConfig {
    public var navbarColorHex: String
    public var backgroundColorHex: String
    
    public init(navbarColorHex: String = "#000000", backgroundColorHex: String = "#007AFF") {
        self.navbarColorHex = navbarColorHex
        self.backgroundColorHex = backgroundColorHex
    }
}


