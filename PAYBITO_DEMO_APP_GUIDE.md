# PayBito TechStore Demo App Guide

<p align="center">
  <img src="https://github.com/user-attachments/assets/1879884d-1ccb-47b2-a1da-535cb4134170" width="23%" />
  <img src="https://github.com/user-attachments/assets/5fb8dabb-1b91-4a34-8543-626ecffc641b" width="23%" />
  <img src="https://github.com/user-attachments/assets/72541722-009d-4a08-a7c1-22834d81c3bb" width="23%" />
  <img src="https://github.com/user-attachments/assets/bdf74fa6-5131-4199-b50f-640bdf0d2a85" width="23%" />
</p>

This guide walks you through the implementation of the **TechStore Demo App**, which serves as a reference implementation for integrating the **PayBito Payment SDK** into an iOS application using SwiftUI.

## Overview

The TechStore Demo showcases a complete e-commerce workflow:
1. Initializing the PayBito SDK.
2. Displaying a list of products.
3. Adding/removing items from the cart and reflecting these changes dynamically.
4. Launching the built-in cart UI.
5. Securely fetching a checkout token via a backend API simulation.
6. Presenting the PayBito Secure Checkout portal and handling the success callback.

## 1. SDK Initialization

The SDK must be initialized before any cart operations or checkouts occur. In the demo, this is done when the main view appears (`.onAppear`):

```swift
let config = PaymentConfiguration(
    merchantId: "26660L",
    publicKey: "pk_test_...",
    brokerId: "ARNA...", // Merchant's Broker ID for custom UI branding
    origin: "https://portal.paybito.com/payments/merchant/",
    enableDebugLogs: true
)
PayBito.initialize(configuration: config)
```

## 2. Managing the Shopping Cart

The `CartManager` provided by the SDK is a globally accessible, thread-safe, reactive component. 

### Observing the Cart State
In SwiftUI, you can observe the cart to dynamically update the UI (e.g., updating a cart badge):

```swift
@ObservedObject private var cartManager = PayBito.shared.cartManager

// In the view...
if cartManager.count > 0 {
    Text("\(cartManager.count)")
    // ... styling for cart badge
}
```

### Adding and Updating Products
Products (`PayBitoProduct`) can be added to the cart using the `PayBito` singleton. The cart manager also allows updating quantities:

```swift
// Adding a product for the first time
PayBito.addToCart(product)

// Updating quantity (e.g., using + / - buttons)
cartManager.updateQuantity(productId: product.productId, newQuantity: newQuantity)
```

### Displaying the Cart UI
The PayBito SDK provides a native, pre-built cart interface. You can present it as a sheet when the user taps the cart button:

```swift
.sheet(isPresented: $isShowingCart) {
    PayBito.openCart()
}
```

## 3. The Secure Checkout Flow (Backend Simulation)

When the user taps "Checkout" inside the PayBito Cart UI, the SDK posts a notification. The host app listens for this trigger:

```swift
let checkoutPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("PayBitoSDK_LaunchCheckout"))

// In the view modifiers...
.onReceive(checkoutPublisher) { _ in
    fetchCheckoutToken()
}
```

### 3-Step Backend API Integration
For security, the iOS app must **never** hardcode or use the `CLINET-SECRET-KEY` to generate a token. The demo simulates a backend server performing a 3-step process:

1. **Register Products (`/register`)**: The cart items are extracted from `PayBito.shared.cartManager.cartItems.values` and sent to the server. The server registers these items and returns a `cartToken`.
2. **Validate Cart (`/products`)**: The server validates the `cartToken`.
3. **Create Session (`/payment/create`)**: The server uses the `cartToken` to generate a final, secure **Checkout Token**.

*Note: If the backend fails (e.g., expired secret key), the demo gracefully falls back to a hardcoded token to prevent crashes.*

### Displaying the Checkout Portal
Once the checkout token is securely fetched from the server, pass it to the SDK's WebView checkout portal:

```swift
.sheet(isPresented: $isShowingCheckout) {
    PayBito.checkout(token: checkoutToken)
}
```

## 4. Handling Payment Success

The SDK intercepts the successful payment URL from the WebView and posts a success notification, which the app can listen for to show an order confirmation screen:

```swift
let successPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("PayBitoSDK_PaymentSuccess"))

.onReceive(successPublisher) { _ in
    withAnimation {
        showSuccessScreen = true
    }
}
```

## Security Requirements Reminder
- **Never** embed your `CLINET-SECRET-KEY` inside the iOS source code in production.
- Token generation must be securely isolated on your backend infrastructure.
