//
//  PaymentsTerminslApp.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 19/05/26.
//

//import SwiftUI
//
//@main
//struct PaymentsTerminslApp: App {
//    var body: some Scene {
//        WindowGroup {
//            NavigationStack {
//                BrokerInputView()
//            }
//        }
//    }
//}

//
//  PaymentsTerminslApp.swift
//  PaymentsTerminsl
//

import SwiftUI
import PayBitoSDK

@main
struct PaymentsTerminslApp: App {
    init() {
           print("Blogin =", UserDefaults.standard.string(forKey: "Blogin") ?? "nil")
           print("Baccess_token =", UserDefaults.standard.string(forKey: "Baccess_token") ?? "nil")
           print("isSessionActive =", PayBito.isSessionActive)
       }
    
    @State private var showLogin = !PayBito.isSessionActive
    
    var body: some Scene {
        WindowGroup {
            // New E-Commerce Integration Demo
            TechStoreDemoView()
            
            /* Old Trading Terminal Integration
            Group {
                if showLogin {
                    NavigationStack {
                        BrokerInputView()
                    }
                } else {
                    PayBito.dashboardView()
                }
            }
            .onReceive(NotificationCenter.default.publisher(
                for: NSNotification.Name("userDidLogout"))) { _ in
                    print("✅ userDidLogout received")
                    showLogin = true
                    print("showLogin =", showLogin)
            }
            .onReceive(NotificationCenter.default.publisher(
                    for: NSNotification.Name("userDidLogin"))) { _ in
                    print("✅ userDidLogin received")
                    showLogin = false
            }
            */
        }
    }
}
