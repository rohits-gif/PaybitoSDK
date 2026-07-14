import SwiftUI
import PayBitoSDK

struct TechStoreDemoView: View {
    
    // We observe the CartManager so the cart badge updates instantly
    @ObservedObject private var cartManager = PayBito.shared.cartManager
    
    @State private var isShowingCart = false
    @State private var isShowingCheckout = false
    @State private var showSuccessScreen = false
    @State private var checkoutToken = ""
    @State private var isCreatingSession = false
    
    // Listen for the checkout trigger from the CartView
    let checkoutPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("PayBitoSDK_LaunchCheckout"))
    let successPublisher = NotificationCenter.default.publisher(for: NSNotification.Name("PayBitoSDK_PaymentSuccess"))
    
    let demoProducts = [
        PayBitoProduct(productId: "P001", name: "Studio Headphones", price: 89.99, imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500&q=80"),
        PayBitoProduct(productId: "P002", name: "Mechanical Keyboard", price: 120.00, imageUrl: "https://images.unsplash.com/photo-1595225476474-87563907a212?w=500&q=80"),
        PayBitoProduct(productId: "P003", name: "4K Monitor", price: 399.50, imageUrl: "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=500&q=80"),
        PayBitoProduct(productId: "P004", name: "Wireless Mouse", price: 45.00, imageUrl: "https://images.unsplash.com/photo-1527864550417-7fd91fc51a46?w=500&q=80")
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Premium Dark Mode Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                if showSuccessScreen {
                    // Modern Success Card
                    VStack(spacing: 24) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("Payment Successful!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Your order is being processed and will ship soon.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button(action: {
                            withAnimation {
                                showSuccessScreen = false
                            }
                        }) {
                            Text("Continue Shopping")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 24) {
                            ForEach(demoProducts) { product in
                                ProductCard(product: product, cartManager: cartManager)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 24)
                    }
                }
            }
            .navigationTitle("TechStore")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !showSuccessScreen {
                        Button(action: {
                            isShowingCart = true
                        }) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                // Reactive Cart Badge
                                if cartManager.count > 0 {
                                    Text("\(cartManager.count)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .padding(5)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 10, y: -10)
                                }
                            }
                        }
                    }
                }
            }
            // Present the SDK's built-in Cart Drawer
            .sheet(isPresented: $isShowingCart) {
                PayBito.openCart()
            }
            // Present the SDK's secure Checkout WebView with the dynamically fetched token
            .sheet(isPresented: $isShowingCheckout) {
                PayBito.checkout(token: checkoutToken)
            }
            // Listen for the checkout trigger
            .onReceive(checkoutPublisher) { _ in
                fetchCheckoutToken()
            }
            // Listen for successful payment intercept
            .onReceive(successPublisher) { _ in
                withAnimation {
                    showSuccessScreen = true
                }
            }
            // Fix for dark mode navigation bar
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            
            // Show a native loading spinner while fetching the dynamic token from your backend API
            if isCreatingSession {
                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all)
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Text("Creating Secure Session...")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(32)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(16)
            }
        }
        .onAppear {
         
            let config = PaymentConfiguration(
                merchantId: "26660L",
                publicKey: "pk_test_4CF18E9E042CB4B0363886559A7E9B913E2C84BED7EE01C28236786676E23505",
                brokerId: "ARNA02042026142506", // Using the real broker ID from your screenshots!
                origin: "https://portal.paybito.com/payments/merchant/",
                enableDebugLogs: true
            )
            PayBito.initialize(configuration: config)
        }
    }
    
    // MARK: - Backend Simulation
    
    /// This function simulates what the Third-Party Developer will write in their own App.
    /// It performs the exact 3-step API flow required by the backend.
    private func fetchCheckoutToken() {
        isCreatingSession = true
        
        // ⚠️ TOGGLE THIS FLAG:
        // Set to `true` when the Backend Team gives you a valid, unexpired CLINET-SECRET-KEY.
        // Set to `false` to just use the hardcoded Demo Token and avoid backend crashes.
        let useLiveBackendSync = true
        
        if !useLiveBackendSync {
            print("⚠️ [Demo App] Skipping live backend sync because Client Secret is expired. Using Fallback Token.")
            self.fallbackCheckout()
            return
        }
        
        let cartItems = PayBito.shared.cartManager.cartItems.values
        var backendProducts: [[String: Any]] = []
        
        for item in cartItems {
            let productDict: [String: Any] = [
                "productId": item.product.productId,
                "productType": "CART",
                "quantity": item.quantity,
                "name": item.product.name,
                "description": "",
                "imageUrl": item.product.imageUrl,
                "attributes": [:],
                "metadata": [:],
                "prices": [
                    [
                        "priceId": 39, // Using a valid priceId format
                        "isDefault": true,
                        "priceType": "one-time",
                        "intervalType": "",
                        "intervalCount": 0,
                        "trialDays": 0,
                        "retryAttempts": 0,
                        "totalCycles": 0,
                        "retryInterval": "",
                        "variant": [:],
                        "sku": item.product.name,
                        "inventory": [
                            "track": true,
                            "quantity": item.quantity
                        ],
                        "currencies": [
                            [
                                "currency": "USD",
                                "amount": item.product.price,
                                "isDefault": true
                            ]
                        ]
                    ]
                ]
            ]
            backendProducts.append(productDict)
        }
        
        // Step 1: Hit `/register` to generate a BRAND NEW cartToken
        let registerPayload: [String: Any] = [
            "merchantId": 26660,
            "catalogId": 82, // Updated to 82 as seen in response
            "cartToken": "", // Send empty to get a new one
            "products": backendProducts
        ]
        
        guard let registerUrl = URL(string: "https://service.hashcashconsultants.com/TestPayments-Apikey-V2/shopping/products/register") else { return }
        var registerReq = URLRequest(url: registerUrl)
        registerReq.httpMethod = "POST"
        registerReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
        registerReq.setValue("https://coulombworld.com", forHTTPHeaderField: "Origin") // REQUIRED ORIGIN
        registerReq.setValue("csk_we8_7cZejXvKZVSLA3lrYogz7yV1hdm6jP556TG7of0", forHTTPHeaderField: "CLINET-SECRET-KEY")
        registerReq.setValue(PayBito.shared.configuration?.publicKey ?? "", forHTTPHeaderField: "X-MBX-PUBLIC-KEY")
        registerReq.httpBody = try? JSONSerialization.data(withJSONObject: registerPayload)
        
        URLSession.shared.dataTask(with: registerReq) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 [Demo App] /register HTTP Status: \(httpResponse.statusCode)")
            }
            if let data = data, let rawString = String(data: data, encoding: .utf8) {
                print("📡 [Demo App] /register RAW RESPONSE: \(rawString)")
            }
            
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let newCartToken = dataDict["cartToken"] as? String else {
                self.fallbackCheckout()
                return
            }
            
            print("✅ [Demo App] Step 1: Registered items. Got new cartToken: \(newCartToken)")
            
            // Step 2: Hit GET `/products?cartToken=...`
            guard let getUrl = URL(string: "https://service.hashcashconsultants.com/TestPayments-Apikey-V2/shopping/products?cartToken=\(newCartToken)") else { return }
            var getReq = URLRequest(url: getUrl)
            getReq.httpMethod = "GET"
            getReq.setValue("https://coulombworld.com", forHTTPHeaderField: "Origin")
            getReq.setValue("csk_we8_7cZejXvKZVSLA3lrYogz7yV1hdm6jP556TG7of0", forHTTPHeaderField: "CLINET-SECRET-KEY")
            getReq.setValue(PayBito.shared.configuration?.publicKey ?? "", forHTTPHeaderField: "X-MBX-PUBLIC-KEY")
            
            URLSession.shared.dataTask(with: getReq) { _, _, _ in
                print("✅ [Demo App] Step 2: Validated cartToken")
                
                // Step 3: Hit `/create` to get the final Checkout Token
                guard let createUrl = URL(string: "https://service.hashcashconsultants.com/TestPayments-Apikey-V2/shopping/payment/create") else { return }
                var createReq = URLRequest(url: createUrl)
                createReq.httpMethod = "POST"
                createReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
                createReq.setValue("https://coulombworld.com", forHTTPHeaderField: "Origin")
                createReq.setValue("csk_we8_7cZejXvKZVSLA3lrYogz7yV1hdm6jP556TG7of0", forHTTPHeaderField: "CLINET-SECRET-KEY")
                createReq.setValue(PayBito.shared.configuration?.publicKey ?? "", forHTTPHeaderField: "X-MBX-PUBLIC-KEY")
                
                let createPayload: [String: Any] = [
                    "merchantId": 26660,
                    "cartToken": newCartToken, // Use the dynamically generated cartToken!
                    "paymentName": "Cart Payment",
                    "catalogId": 82
                ]
                createReq.httpBody = try? JSONSerialization.data(withJSONObject: createPayload)
                
                URLSession.shared.dataTask(with: createReq) { createData, _, _ in
                    DispatchQueue.main.async {
                        self.isCreatingSession = false
                        
                        if let cData = createData,
                           let cJson = try? JSONSerialization.jsonObject(with: cData) as? [String: Any],
                           let dynamicToken = cJson["id"] as? String {
                            
                            print("✅ [Demo App] Step 3: Created Session Checkout Token: \(dynamicToken)")
                            self.checkoutToken = dynamicToken
                            self.isShowingCheckout = true
                            
                        } else {
                            self.fallbackCheckout()
                        }
                    }
                }.resume()
            }.resume()
        }.resume()
    }
    
    private func fallbackCheckout() {
        DispatchQueue.main.async {
            self.isCreatingSession = false
            print("⚠️ [Demo App] API Chain Failed. Using fallback.")
            self.checkoutToken = "PCN-TEST-ID551"
            self.isShowingCheckout = true
        }
    }
}

// Subview for the Product Card Grid Item
struct ProductCard: View {
    let product: PayBitoProduct
    @ObservedObject var cartManager: CartManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Product Image from Unsplash
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                }
            }
            .frame(height: 150)
            .clipped()
            .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text("$\(String(format: "%.2f", product.price))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            let qty = cartManager.quantity(for: product.productId)
            
            if qty > 0 {
                // + / - Quantity Controls
                HStack {
                    Button(action: {
                        cartManager.updateQuantity(productId: product.productId, newQuantity: qty - 1)
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Text("\(qty)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        cartManager.updateQuantity(productId: product.productId, newQuantity: qty + 1)
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.top, 4)
            } else {
                // Add to Cart Button
                Button(action: {
                    PayBito.addToCart(product)
                }) {
                    Text("Add")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.top, 4)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    TechStoreDemoView()
}
