import Foundation
import SwiftUI

/// The main entry point for the PayBito SDK.
public class PayBito {
    
    public static let shared = PayBito()
    
    private init() {}
    
    /// Initializes the SDK with a specific configuration
    public static func initialize(configuration: PaymentConfiguration) {
        shared.configuration = configuration
        if configuration.enableDebugLogs {
            print("✅ [PayBitoSDK] Initialized with Merchant: \(configuration.merchantId)")
        }
        
        // Dynamically fetch the broker's branding config!
        fetchDynamicBranding(brokerId: configuration.brokerId)
    }
    
    /// Fetches the white-label branding from the server and updates the UI state
    private static func fetchDynamicBranding(brokerId: String) {
        let urlString = "https://accounts.paybito.com/api/home/getBrokerWiseExchangeInfo?brokerId=\(brokerId)"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15", forHTTPHeaderField: "User-Agent")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("🎨 [PayBitoSDK] Branding API HTTP Status: \(httpResponse.statusCode)")
            }
            if let data = data, let rawString = String(data: data, encoding: .utf8) {
                print("🎨 [PayBitoSDK] Branding API RAW RESPONSE: \(rawString.prefix(200))...")
            }
            guard let data = data else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let colorDict = json["color"] as? [String: Any],
                   let navHex = colorDict["navbarColor"] as? String,
                   let bgHex = colorDict["backgroundColor1"] as? String {
                    
                    // Dispatch to MainActor since we are updating CartManager state
                    DispatchQueue.main.async {
                        shared.cartManager.branding = BrandingConfig(
                            navbarColorHex: navHex,
                            backgroundColorHex: bgHex
                        )
                        if shared.configuration?.enableDebugLogs == true {
                            print("🎨 [PayBitoSDK] Dynamic Branding Applied! Nav: \(navHex), BG: \(bgHex)")
                        }
                    }
                }
            } catch {
                print("⚠️ [PayBitoSDK] Failed to parse dynamic branding: \(error)")
            }
        }.resume()
    }

    public var configuration: PaymentConfiguration?
    
    /// Checks if there is an active session
    public static var isSessionActive: Bool {
        return LoginService.isSessionActive
    }
    
    /// Logs out the user
    public static func logout() {
        LoginService.clearSession()
        NotificationCenter.default.post(name: NSNotification.Name("userDidLogout"), object: nil)
    }
    
    // Old Payment flow removed in favor of Cart/Checkout engine
    
    /// View for the main dashboard/container
    public static func dashboardView() -> some View {
        return BillBitcoinsContainerView()
    }
    
    /// View for Enterprise KYC Gate
    public static func enterpriseKYCView() -> some View {
        return EnterpriseKYCGateView()
    }
    
    /// View for the Login flow
    public static func loginView() -> some View {
        return LoginView()
    }
    
    // MARK: - E-Commerce Engine
    
    /// Access the reactive CartManager to observe cart state (items, count, total)
    public var cartManager: CartManager {
        return CartManager.shared
    }
    
    /// Add a product to the shopping cart
    @MainActor
    public static func addToCart(_ product: PayBitoProduct) {
        shared.cartManager.addToCart(product)
    }
    
    /// View for the Cart Bottom Sheet Drawer
    @MainActor
    public static func openCart() -> some View {
        return CartView()
    }
    
    /// View for the Secure Checkout WebView
    @MainActor
    public static func checkout(token: String) -> some View {
        if let config = shared.configuration {
            let total = shared.cartManager.total
            
            // Dynamically construct the checkout URL using the merchant's origin and the session token
            var components = URLComponents(string: config.origin + "checkout/\(token)")!
            
            // Append query params just in case they are still required by the web portal
            components.queryItems = [
                URLQueryItem(name: "merchantId", value: config.merchantId),
                URLQueryItem(name: "brokerId", value: config.brokerId),
                URLQueryItem(name: "amount", value: total),
                URLQueryItem(name: "publicKey", value: config.publicKey)
            ]
            
            return AnyView(CheckoutScreen(url: components.url!))
        } else {
            print("🚨 [PayBitoSDK ERROR] SDK must be initialized before calling checkout().")
            return AnyView(
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                    Text("PayBito SDK Not Initialized")
                        .font(.headline)
                        .padding(.top, 8)
                    Text("Please call PayBito.initialize(configuration:) in your AppDelegate or App entry point.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                }
            )
        }
    }
}
