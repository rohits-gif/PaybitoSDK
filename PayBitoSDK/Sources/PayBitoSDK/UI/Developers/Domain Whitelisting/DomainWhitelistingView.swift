
//  DomainWhitelistingView.swift
//  Trading_Terminal
//  Created by Sk Jasimuddin on 14/04/26.




import SwiftUI

struct DomainWhitelistingView: View {
    
    @State private var domain: String = ""
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.black, Color(#colorLiteral(red: 0.05, green: 0.1, blue: 0.18, alpha: 1))],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                
                // Title
                Text("Domain Whitelisting")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Restrict API access to specific domains")
                    .foregroundColor(.gray)
                    .font(.system(size: 14))
                
                // Main Card
                VStack(alignment: .leading, spacing: 16) {
                    
                    // Header Row
                    HStack {
                        Text("Whitelisted Domains")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("Security")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(8)
                        
                        Text("0 / 5 domains")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // Info Banner
                    Text("Only requests originating from whitelisted domains will be accepted by the payment API. Each domain has a default rate limit of 3,600 requests/hour.")
                        .font(.caption)
                        .foregroundColor(.green)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                    
                    // Input Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ADD DOMAIN")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            TextField("e.g. app.yoursite.com", text: $domain)
                                .foregroundColor(.white)
                            
                            Button("Add Domain") {
                                // Action
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .foregroundColor(Color.white)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(8)
                        }
                        .padding()
                        .background(Color(#colorLiteral(red: 0.08, green: 0.12, blue: 0.2, alpha: 1)))
                        .cornerRadius(12)
                    }
                    
                    // Empty State Box
                    VStack(spacing: 10) {
                        Image(systemName: "shield")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                        
                        Text("No domains whitelisted")
                            .foregroundColor(.white)
                            .font(.subheadline)
                        
                        Text("Add at least one domain to restrict API access")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(30)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(12)
                    
                    // Footer
                    HStack {
                        Text("Domain slots used")
                            .foregroundColor(.gray)
                            .font(.caption)
                        
                        Spacer()
                        
                        Text("0 / 5")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                }
                .padding()
                .background(Color(#colorLiteral(red: 0.07, green: 0.1, blue: 0.18, alpha: 1)))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.5), radius: 10)
                
                Spacer()
            }
            .padding()
        }
    }
}


#Preview {
    DomainWhitelistingView()
}
