import SwiftUI

/// A built-in Cart Drawer UI that displays the products currently in the cart
public struct CartView: View {
    @ObservedObject private var cartManager = CartManager.shared
    @Environment(\.dismiss) private var dismiss
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Premium Dark Mode Background
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    if cartManager.items.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "cart")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Your cart is empty")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(cartManager.items) { item in
                                    HStack(spacing: 16) {
                                        AsyncImage(url: URL(string: item.imageUrl)) { phase in
                                            if let image = phase.image {
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } else {
                                                Color.gray.opacity(0.3)
                                            }
                                        }
                                        .frame(width: 70, height: 70)
                                        .cornerRadius(12)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("$\(String(format: "%.2f", item.price))")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        // Quantity Controls
                                        HStack(spacing: 12) {
                                            Button(action: {
                                                cartManager.updateQuantity(productId: item.productId, newQuantity: cartManager.quantity(for: item.productId) - 1)
                                            }) {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            Text("\(cartManager.quantity(for: item.productId))")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Button(action: {
                                                cartManager.updateQuantity(productId: item.productId, newQuantity: cartManager.quantity(for: item.productId) + 1)
                                            }) {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(Color(hex: cartManager.branding.backgroundColorHex) ?? .blue)
                                            }
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(16)
                                }
                            }
                            .padding()
                        }
                        
                        VStack(spacing: 16) {
                            HStack {
                                Text("Total")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("$\(cartManager.total)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            
                            Button(action: {
                                dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    NotificationCenter.default.post(name: NSNotification.Name("PayBitoSDK_LaunchCheckout"), object: nil)
                                }
                            }) {
                                Text("Proceed to Checkout")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(hex: cartManager.branding.navbarColorHex) ?? .blue,
                                            Color(hex: cartManager.branding.backgroundColorHex) ?? .purple
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                        .background(Color.black.shadow(color: .white.opacity(0.1), radius: 10, x: 0, y: -5))
                    }
                }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            // Fix for dark mode navigation bar
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
        }
    }
}

#Preview {
    CartView()
}
