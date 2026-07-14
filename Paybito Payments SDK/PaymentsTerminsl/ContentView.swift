//
//  ContentView.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 19/05/26.
//

import SwiftUI
import PayBitoSDK

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "building.2.crop.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                
                Text("Welcome to Payments Terminal")
                    .font(.title)
                    .bold()
                    .multilineTextAlignment(.center)
                
                NavigationLink(destination: PayBito.enterpriseKYCView()) {
                    Text("Start Enterprise KYC")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    ContentView()
}

