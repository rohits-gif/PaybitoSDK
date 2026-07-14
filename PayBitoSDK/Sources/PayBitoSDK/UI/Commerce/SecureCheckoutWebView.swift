import SwiftUI
import WebKit

/// A wrapper for WKWebView to handle the secure Checkout flow
public struct SecureCheckoutWebView: UIViewRepresentable {
    
    private let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // Handle updates if necessary
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        var parent: SecureCheckoutWebView
        
        init(_ parent: SecureCheckoutWebView) {
            self.parent = parent
        }
        
        // Handle navigation actions, intercept payment success/failure callbacks here
        public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            
            if let urlString = navigationAction.request.url?.absoluteString {
                if PayBito.shared.configuration?.enableDebugLogs == true {
                    print("[PayBitoSDK] Checkout Navigating to: \(urlString)")
                }
                
                // Intercepting a success deep link callback (e.g. paybito://checkout/success)
                if urlString.starts(with: "paybito://checkout/success") || urlString.contains("payment/success") {
                    
                    if PayBito.shared.configuration?.enableDebugLogs == true {
                        print("[PayBitoSDK] Payment Success Intercepted! Clearing cart.")
                    }
                    
                    // Clear the cart on successful payment
                    CartManager.shared.clearCart()
                    
                    // Notify the app so it can dismiss the checkout and show a Success Card
                    NotificationCenter.default.post(name: NSNotification.Name("PayBitoSDK_PaymentSuccess"), object: nil)
                    
                    // Cancel the navigation because we are handling it natively
                    decisionHandler(.cancel)
                    return
                }
            }
            
            decisionHandler(.allow)
        }
    }
}

/// A SwiftUI View that presents the SecureCheckoutWebView with a navigation bar
public struct CheckoutScreen: View {
    @Environment(\.dismiss) private var dismiss
    private let url: URL
    
    public init(url: URL) {
        self.url = url
    }
    
    public var body: some View {
        NavigationView {
            SecureCheckoutWebView(url: url)
                .navigationTitle("Secure Checkout")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("PayBitoSDK_PaymentSuccess"))) { _ in
            // Automatically dismiss the checkout sheet when the deep link succeeds
            dismiss()
        }
    }
}
