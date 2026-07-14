//
//  ProfileMenuSheet.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 14/04/26.
//

//  ProfileMenuSheet.swift
//  Bottom sheet shown when profile icon is tapped in BBNavBar.

import SwiftUI

private struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let iconBG: Color
    let title: String
    let isDestructive: Bool
}

private let menuItems: [MenuItem] = [
    MenuItem(icon: "person.fill",           iconBG: Color(red:0.22,green:0.26,blue:0.45), title: "Profile",           isDestructive: false),
    MenuItem(icon: "checkmark.shield.fill", iconBG: Color(red:0.22,green:0.26,blue:0.45), title: "Get Started",       isDestructive: false),
    MenuItem(icon: "person.circle.fill",    iconBG: Color(red:0.22,green:0.26,blue:0.45), title: "User Settings",     isDestructive: false),
    MenuItem(icon: "building.2.fill",       iconBG: Color(red:0.22,green:0.26,blue:0.45), title: "Business Settings", isDestructive: false),
    MenuItem(icon: "slider.horizontal.3",   iconBG: Color(red:0.22,green:0.26,blue:0.45), title: "Configurations",    isDestructive: false),
    MenuItem(icon: "person.2.fill",         iconBG: Color(red:0.22,green:0.26,blue:0.45), title: "User Management",   isDestructive: false),
    MenuItem(icon: "rectangle.portrait.and.arrow.right.fill",
                                            iconBG: Color(red:0.55,green:0.12,blue:0.12), title: "Logout",            isDestructive: true),
]

struct ProfileMenuSheet: View {

    var onLogout: () -> Void
    var onMenuTap: ((String) -> Void)?
    @Environment(\.dismiss) private var dismiss

    // ← 1. Add this
    @State private var showProfile = false
    @State private var getStarted = false
    @State private var showUserSettings = false
    @State private var showbusinessSettings = false
    @State private var showuserManagement = false
    @State private var showConfigurations = false
    

    var body: some View {
        if #available(iOS 16.4, *) {
            ZStack {
                Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()

                VStack(spacing: 0) {
                    Capsule()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 40, height: 4)
                        .padding(.top, 12)
                        .padding(.bottom, 20)

                    HStack {
                        Text("Security And Settings")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                    Rectangle()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 0.5)
                        .padding(.horizontal, 20)

                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            ForEach(menuItems) { item in
                                MenuRow(item: item) {
                                    if item.isDestructive {
                                        dismiss()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            print("LOGOUT BUTTON CLICKED")
                                            onLogout()
                                        }
                                    } else if item.title == "Profile" {
                                        // ← 2. Show ProfileView here
                                        showProfile = true
                                    }
                                    else if item.title == "Get Started" {
                                        // ← 2. Show ProfileView here
                                        getStarted = true
                                    }
                                    else if item.title == "User Settings" {
                                                           showUserSettings = true
                                    }
                                    else if item.title == "Business Settings" {
                                                           showbusinessSettings = true
                                    }
                                    else if item.title == "User Management" {
                                                           showuserManagement = true
                                    }
                                    else if item.title == "Configurations" {
                                                            showConfigurations = true
                                    }
                                    
                                    
                                    
                                    
                                    else {
                                        onMenuTap?(item.title)
                                        dismiss()
                                    }
                                }
                                if item.id != menuItems.last?.id {
                                    Rectangle()
                                        .fill(Color.white.opacity(0.07))
                                        .frame(height: 0.5)
                                        .padding(.leading, 72)
                                }
                            }
                        }
                        .padding(.top, 8)
                    }

                    Spacer().frame(height: 34)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(20)
            .presentationBackground(Color(red: 0.08, green: 0.10, blue: 0.16))
            // ← 3. Add this
            .fullScreenCover(isPresented: $showProfile) {
                ProfileView()
            }
            .sheet(isPresented: $getStarted) {

                NavigationStack {

                    GetStartedView()

                }

            }
            .fullScreenCover(isPresented: $showUserSettings) {
                UserSettingsView()
            }
            .fullScreenCover(isPresented: $showbusinessSettings) {
                BusinessSettingsView()
            }
            .fullScreenCover(isPresented: $showuserManagement) {
                UserManagementView()
            }
            .sheet(isPresented: $showConfigurations) {
                            ConfigurationSheet()
            }
        } else {
            EmptyView()
        }
    }
}

private struct MenuRow: View {
    let item: MenuItem
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(item.iconBG)
                        .frame(width: 44, height: 44)
                    Image(systemName: item.icon)
                        .resizable().scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(item.isDestructive
                                         ? Color(red: 0.95, green: 0.30, blue: 0.30)
                                         : .white)
                }
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.isDestructive
                                     ? Color(red: 0.95, green: 0.30, blue: 0.30)
                                     : .white)
                Spacer()
                if !item.isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color.white.opacity(0.35))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(isPressed ? Color.white.opacity(0.05) : Color.clear)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded   { _ in isPressed = false }
        )
    }
}

#Preview {
    Color.black.ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            ProfileMenuSheet(onLogout: {})
        }
}
