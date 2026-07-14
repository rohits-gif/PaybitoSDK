//
//  LogoutPView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 14/04/26.
//

import SwiftUI

struct LogoutPopupView: View {
    
    var body: some View {
        ZStack {
            
            // MARK: Background overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // MARK: Card
            VStack(spacing: 20) {
                
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "arrow.right.square")
                        .font(.system(size: 30))
                        .foregroundColor(.red)
                }
                
                // Title
                Text("Log Out")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                
                // Description
                VStack(spacing: 6) {
                    Text("Are you sure you want to log out?")
                    Text("You'll need to sign in again.")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                
                // Logout Button
                Button(action: {
                    // logout action
                }) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(25)
                }
                .padding(.top, 10)
                
                // Cancel
                Button(action: {
                    // dismiss
                }) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                        .font(.headline)
                }
                .padding(.top, 4)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color(red: 0.08, green: 0.12, blue: 0.2)) // dark blue
            )
            .overlay(
                RoundedRectangle(cornerRadius: 25)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .padding(.horizontal, 30)
        }
    }
}

#Preview {
    LogoutPopupView()
}
