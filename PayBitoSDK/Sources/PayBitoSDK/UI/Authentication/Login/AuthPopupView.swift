////
////  AuthPopupView.swift
////  Trading_Terminal
////
////  Created by Sk Jasimuddin on 09/04/26.
////
//
//import SwiftUI
//
//struct AuthPopupView: View {
//
//    @ObservedObject var vm: LoginViewModell
//
//    var body: some View {
//
//        VStack(spacing: 16) {
//
//            Text("Authentication")
//                .font(.headline)
//
//            TextField("Email OTP", text: $vm.emailOTP)
//                .textFieldStyle(.roundedBorder)
//
//            if vm.isGAEnabled {
//                TextField("Google Auth Code", text: $vm.gaOTP)
//                    .textFieldStyle(.roundedBorder)
//            }
//
//            if vm.isPhoneEnabled {
//                TextField("Phone OTP", text: $vm.phoneOTP)
//                    .textFieldStyle(.roundedBorder)
//            }
//
//            Button("Submit") {
//                vm.finalLogin()
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//            .background(Color.green)
//            .foregroundColor(.white)
//            .cornerRadius(10)
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(16)
//        .padding()
//    }
//}
