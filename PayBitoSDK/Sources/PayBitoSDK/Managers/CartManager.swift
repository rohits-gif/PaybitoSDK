import Foundation
import Combine

/// Manages the shopping cart state for the PayBito SDK
@MainActor
public class CartManager: ObservableObject {
    
    public static let shared = CartManager()
    
    // Dictionary to hold product and its quantity
    @Published public private(set) var cartItems: [String: (product: PayBitoProduct, quantity: Int)] = [:]
    
    // Dynamic White-Label Branding
    @Published public var branding = BrandingConfig()
    
    /// Array of unique items for lists (only showing items with quantity > 0)
    public var items: [PayBitoProduct] {
        cartItems.values
            .filter { $0.quantity > 0 }
            .map { $0.product }
            .sorted { $0.name < $1.name }
    }
    
    /// The total number of items in the cart (only counting > 0)
    public var count: Int {
        cartItems.values.filter { $0.quantity > 0 }.reduce(0) { $0 + $1.quantity }
    }
    
    /// The total formatted price of all active items in the cart
    public var total: String {
        let sum = cartItems.values
            .filter { $0.quantity > 0 }
            .reduce(0) { $0 + ($1.product.price * Double($1.quantity)) }
        return String(format: "%.2f", sum)
    }
    
    private init() {}
    
    /// Adds a product to the cart or increases its quantity
    public func addToCart(_ product: PayBitoProduct) {
        if let existing = cartItems[product.productId] {
            cartItems[product.productId] = (product, existing.quantity + 1)
        } else {
            cartItems[product.productId] = (product, 1)
        }
        
        if PayBito.shared.configuration?.enableDebugLogs == true {
            print("[PayBitoSDK] Added item to cart: \(product.name)")
        }
    }
    
    /// Update the quantity of a specific product
    public func updateQuantity(productId: String, newQuantity: Int) {
        guard let existing = cartItems[productId] else { return }
        
        // We do NOT remove the item from the dictionary when quantity hits 0.
        // We must keep it at 0 so the backend API knows to delete it from the merged cart!
        let safeQuantity = max(0, newQuantity)
        cartItems[productId] = (existing.product, safeQuantity)
    }
    
    /// Get quantity for a specific product
    nonisolated public func quantity(for productId: String) -> Int {
        // Safe to call from anywhere, though mostly used by UI
        // Since cartItems is published, its read is technically safe if accessed via MainActor
        // But for simplicity, we will assume it's always called on Main thread by views
        return MainActor.assumeIsolated {
            cartItems[productId]?.quantity ?? 0
        }
    }
    
    /// Clears the cart
    public func clearCart() {
        cartItems.removeAll()
    }
}
