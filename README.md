# PayBito iOS Payment SDK

The official PayBito Payment SDK for iOS, designed for high-performance mobile checkout integration. 

This SDK allows third-party developers and merchants to easily integrate the PayBito Secure Checkout into their iOS apps. It features a fully reactive Cart Engine, dynamic white-label UI branding, deep-link transaction interceptors, and strict Apple `@MainActor` thread safety.

## 🚀 Key Features

* **Dynamic UI Branding:** The SDK silently communicates with the PayBito broker API to fetch custom Merchant Colors (Hex) and perfectly brands the iOS Shopping Cart to match the merchant's identity.
* **Reactive Cart Engine:** Built with Apple's `Combine` framework, the `CartManager` automatically calculates totals and updates the UI whenever a user adds or removes items.
* **Strict Thread Safety:** Fully compliant with Swift 6 and strict concurrency rules. All UI updates are securely locked to the `@MainActor`.
* **Deep-Link Interception:** Seamlessly intercepts web-portal success and cancellation callbacks directly into native Swift delegates.
* **Graceful Fallbacks:** Detailed `@ViewBuilder` error handling that shows diagnostic UIs for missing credentials instead of crashing the host app.

## 📦 Installation

**Requirements:** iOS 17.0+ and Swift 5.9+

### Swift Package Manager (Recommended)
You can easily integrate PayBitoSDK into your project via Swift Package Manager:
1. Open your project in Xcode.
2. Go to **File > Add Package Dependencies...**
3. Paste the following repository URL into the search bar:
   ```text
   https://github.com/rohits-gif/PaybitoSDK.git
   ```
4. Set the Dependency Rule (e.g., to "Up to Next Major Version" for version `1.0.0`) and click **Add Package**.

## 💻 Usage Guide

### 1. Initialization
Initialize the SDK once during your app's startup phase (e.g., in `AppDelegate` or the root `@main` struct). 

```swift
import PayBitoSDK

let config = PaymentConfiguration(
    merchantId: "YOUR_MERCHANT_ID",
    publicKey: "pk_your_public_key",
    brokerId: "YOUR_BROKER_ID",
    origin: "https://portal.paybito.com/payments/merchant/",
    enableDebugLogs: true
)

PayBito.initialize(configuration: config)
```
*Note: This will automatically fetch and cache your custom Broker UI branding!*

### 2. Adding Items to the Cart
The `CartManager` is a globally accessible, thread-safe singleton.

```swift
let product = PayBitoProduct(
    productId: "P001",
    name: "4K Monitor",
    price: 399.50,
    imageUrl: "https://example.com/monitor.jpg"
)

// Safely add items to the cart from anywhere in your app!
PayBito.addToCart(product)
```

### 3. Displaying the Checkout Cart
You can natively present the user's Shopping Cart by wrapping `PayBito.openCart()` inside a sheet or navigation stack:

```swift
.sheet(isPresented: $isShowingCart) {
    PayBito.openCart()
}
```

### 4. Processing Payments (Backend Token Sync)
For severe security reasons, mobile apps should **never** directly generate Session Tokens using a `CLIENT-SECRET-KEY`. 

When the user is ready to check out:
1. The iOS App sends the selected `CartManager` items to **Your Secure Backend Server**.
2. Your server (which safely holds your Client Secret Key) hits the PayBito `/register` and `/create` APIs to generate a Checkout Token.
3. Your server returns the Token to the iOS App.
4. Pass the token directly to the PayBito WebView UI:

```swift
// Safely launch the Secure Payment Portal
PayBito.checkout(token: "PCN-GENERATED-TOKEN")
```

### 5. Deep-Link Configuration (Success/Cancel Callbacks)
To properly handle success and failure callbacks from the secure checkout portal, you must register a custom URL scheme in your app's `Info.plist`:
1. Open your project target settings in Xcode.
2. Go to the **Info** tab.
3. Under **URL Types**, add a new entry.
4. Set the **URL Schemes** to `paybito`.

The SDK will then automatically intercept completion URLs (like `paybito://checkout/success`) and dismiss the checkout screen.

## 🔒 Security Requirements
Never hardcode your `CLIENT-SECRET-KEY` inside the iOS source code. The Secret Key must remain isolated on your backend infrastructure.
