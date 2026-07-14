//
//  BusinessSettingsView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 14/04/26.
//  Fixed: userUUID key corrected from "userUUID" → "Buuid"

import SwiftUI

// MARK: - Reusable atoms

private let darkCard     = Color(red: 0.10, green: 0.12, blue: 0.19)
private let darkBG       = Color(red: 0.08, green: 0.10, blue: 0.16)
private let purpleAccent = Color(red: 0.45, green: 0.35, blue: 0.90)
private let labelGray    = Color.white.opacity(0.45)
private let strokeClr    = Color.white.opacity(0.10)



private struct BSRow: View {
    let label: String
    let value: String
    var valueColor: Color = .white
    

    var body: some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundColor(labelGray)
            Spacer()
            Text(value).font(.system(size: 13)).foregroundColor(valueColor)
        }
        .padding(.vertical, 10)
    }
}

private struct AddButton: View {
    var action: () -> Void = {}   // ✅ add this

    var body: some View {
        Button(action: action) {  // ✅ use it here
            HStack(spacing: 6) {
                Image(systemName: "pencil").font(.system(size: 12))
                Text("Add").font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Color(red: 0.14, green: 0.17, blue: 0.28))
            .cornerRadius(8)
            .overlay { RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1) }
        }
        .buttonStyle(.plain)
    }
}

private struct AccordionHeader: View {
    let icon: String
    let iconBG: Color
    let title: String
    let subtitle: String
    let isExpanded: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(iconBG)
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .resizable().scaledToFit()
                        .frame(width: 22, height: 22)
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    Text(subtitle).font(.system(size: 12)).foregroundColor(labelGray)
                }
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 13)).foregroundColor(labelGray)
            }
            .padding(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Crypto coin model

private struct CryptoCoin: Identifiable {
    let id = UUID()
    let name: String
    let code: String
    let icon: String
    let iconBG: Color
    let network: String
}

private let cryptoCoins: [CryptoCoin] = [
    CryptoCoin(name: "Dogecoin",      code: "DOGE", icon: "d.circle.fill",          iconBG: Color(red:0.80,green:0.65,blue:0.10), network: "NATIVE"),
    CryptoCoin(name: "Tether",        code: "USDT", icon: "t.circle.fill",           iconBG: Color(red:0.10,green:0.65,blue:0.45), network: "ERC / TRC"),
    CryptoCoin(name: "Ethereum",      code: "ETH",  icon: "e.circle.fill",           iconBG: Color(red:0.35,green:0.45,blue:0.85), network: "NATIVE"),
    CryptoCoin(name: "Bitcoin",       code: "BTC",  icon: "bitcoinsign.circle.fill", iconBG: Color(red:0.95,green:0.50,blue:0.10), network: "NATIVE"),
    CryptoCoin(name: "Litecoin",      code: "LTC",  icon: "l.circle.fill",           iconBG: Color(red:0.55,green:0.55,blue:0.60), network: "NATIVE"),
    CryptoCoin(name: "Hashcash Coin", code: "HCX",  icon: "h.circle.fill",           iconBG: Color(red:0.10,green:0.55,blue:0.55), network: "ERC"),
    CryptoCoin(name: "Ripple",        code: "XRP",  icon: "x.circle.fill",           iconBG: Color(red:0.18,green:0.22,blue:0.32), network: "NATIVE"),
    CryptoCoin(name: "Bitcoin Cash",  code: "BCH",  icon: "bitcoinsign.circle.fill", iconBG: Color(red:0.10,green:0.72,blue:0.35), network: "NATIVE"),
    CryptoCoin(name: "USDC",          code: "USDC", icon: "dollarsign.circle.fill",  iconBG: Color(red:0.15,green:0.45,blue:0.90), network: "ERC"),
]

// MARK: - Main View

struct BusinessSettingsView: View {

    @Environment(\.dismiss) private var dismiss

       @State private var expandMerchant  = true
       @State private var expandVolume    = false
       @State private var expandCharges   = false
       @State private var expandOrder     = false
       @State private var expandException = false
       @State private var expandCrypto    = false
       @State private var expandBank      = false

    @State private var showEditMerchant = false
    @State private var showAddMerchant  = false  // ✅ add this
    @State private  var navigateToBankDetails = false


     

    @StateObject private var bankVM = BankDetailsViewModel()

    // ✅ FIX: was "userUUID" — corrected to "Buuid" to match the key written
    //         by the login flow and read by UserManagementService / BankDetailsService.
    private var userUUID: String {
        // GetUserBankDetails expects exchangeUserUuid, not the login uuid
        UserDefaults.standard.string(forKey: "Bexchange_uuid")
            ?? UserDefaults.standard.string(forKey: "Buuid")
            ?? ""
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                darkBG.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        pageHeader
                        VStack(spacing: 12) {
                            merchantProfileSection
                            approvedVolumeSection
                            transactionChargesSection
                            orderSettingsSection
                            autoExceptionSection
                            cryptoAddressSection
                            bankDetailsSection
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 100)
                    }
                }
                .navigationDestination(isPresented: $navigateToBankDetails) {
                    AddBankDetailsView()
                }
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color(red: 0.20, green: 0.40, blue: 0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color.blue.opacity(0.5), radius: 12, x: 0, y: 6)
                }
                .padding(.trailing, 20).padding(.bottom, 28)
            }
            .onAppear {
                debugPrint("🔑 Buuid         : \(UserDefaults.standard.string(forKey: "Buuid") ?? "nil")")
                  debugPrint("🔑 Bexchange_uuid: \(UserDefaults.standard.string(forKey: "Bexchange_uuid") ?? "nil")")

                let uuid = userUUID
                guard !uuid.isEmpty else {
                    print("⚠️  [BusinessSettingsView] Buuid is empty – bank details fetch skipped.")
                    return
                }
                print("🔑 [BusinessSettingsView] Fetching bank details for uuid: \(uuid)")
                bankVM.load(uuid: uuid)
            }
        }
    }

    // MARK: Header

    private var pageHeader: some View {
        HStack(spacing: 12) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Business Settings")
                    .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
                Text("Manage your merchant profile, volume limits, and order preferences")
                    .font(.system(size: 12)).foregroundColor(labelGray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 4)
    }

    // MARK: 1 — Merchant Profile

    private var merchantProfileSection: some View {
        VStack(spacing: 0) {
            AccordionHeader(
                icon: "building.columns.fill",
                iconBG: Color(red: 0.18, green: 0.22, blue: 0.40),
                title: "Merchant Profile",
                subtitle: "Your business identity and contact details",
                isExpanded: expandMerchant
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandMerchant.toggle() } }

            if expandMerchant {
                VStack(spacing: 0) {
                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
                    VStack(spacing: 0) {
                        BSRow(label: "Name",          value: "raj")
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        BSRow(label: "Industry",      value: "Banking, Mortgage")
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        BSRow(label: "Website",       value: "www.hashcashconsultants.com", valueColor: purpleAccent)
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        BSRow(label: "Support Phone", value: "N/A")
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        BSRow(label: "Support Email", value: "N/A")
                    }
                    .padding(.horizontal, 16)

                    HStack {
                        Spacer()
                        // ✅ NavigationLink triggers EditBankDetailsView
                        NavigationLink(destination: AddBankDetailsView(), isActive: $showEditMerchant) {
                            EmptyView()
                        }
                        Button(action: { showEditMerchant = true }) {
                            Text("Edit")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(purpleAccent)
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
                }
            }
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }

    // MARK: 2 — Approved Volume

    private var approvedVolumeSection: some View {
        VStack(spacing: 0) {
            AccordionHeader(
                icon: "checkmark",
                iconBG: Color(red: 0.12, green: 0.45, blue: 0.35),
                title: "Approved Volume",
                subtitle: "Your current transaction limits",
                isExpanded: expandVolume
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandVolume.toggle() } }

            if expandVolume {
                VStack(spacing: 0) {
                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
                    VStack(spacing: 0) {
                        HStack {
                            Text("Daily Limit").font(.system(size: 13)).foregroundColor(labelGray)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$ 100000").font(.system(size: 15, weight: .semibold)).foregroundColor(purpleAccent)
                                Text("per day").font(.system(size: 11)).foregroundColor(labelGray)
                            }
                        }.padding(.vertical, 12)
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        HStack {
                            Text("Monthly Limit").font(.system(size: 13)).foregroundColor(labelGray)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("10000").font(.system(size: 15, weight: .semibold)).foregroundColor(purpleAccent)
                                Text("payments per month").font(.system(size: 11)).foregroundColor(labelGray)
                            }
                        }.padding(.vertical, 12)
                    }
                    .padding(.horizontal, 16)
                    HStack { Spacer(); EditButton() }
                        .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
                }
            }
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }

    // MARK: 3 — Transaction Charges

    private let charges = ["BTC","ETH","BCH","LTC","HCX","XRP","USDT","DOGE","USDC"]

    private var transactionChargesSection: some View {
        VStack(spacing: 0) {
            AccordionHeader(
                icon: "doc.text.fill",
                iconBG: Color(red: 0.25, green: 0.20, blue: 0.35),
                title: "Transaction Charges",
                subtitle: "Fee structure for each supported asset",
                isExpanded: expandCharges
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandCharges.toggle() } }

            if expandCharges {
                VStack(spacing: 0) {
                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
                    VStack(spacing: 0) {
                        ForEach(charges, id: \.self) { coin in
                            HStack {
                                Text(coin).font(.system(size: 14)).foregroundColor(.white)
                                Spacer()
                                Text("2%").font(.system(size: 14, weight: .semibold)).foregroundColor(purpleAccent)
                            }
                            .padding(.vertical, 12)
                            if coin != charges.last {
                                Rectangle().fill(strokeClr).frame(height: 0.5)
                            }
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 12)
                }
            }
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }

    // MARK: 4 — Order Settings

    private var orderSettingsSection: some View {
        VStack(spacing: 0) {
            AccordionHeader(
                icon: "envelope.fill",
                iconBG: Color(red: 0.18, green: 0.22, blue: 0.40),
                title: "Order Settings",
                subtitle: "Configure notification preferences",
                isExpanded: expandOrder
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandOrder.toggle() } }

            if expandOrder {
                VStack(spacing: 0) {
                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
                    HStack(spacing: 4) {
                        Text("Send Notification to").font(.system(size: 13)).foregroundColor(labelGray)
                        Text(UserDefaults.standard.string(forKey: "Bemail") ?? "rajit@hashcashconsultants.com")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 14)
                    HStack { Spacer(); EditButton() }
                        .padding(.horizontal, 16).padding(.bottom, 16)
                }
            }
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }

    // MARK: 5 — Automatic Exception Handling

    private var autoExceptionSection: some View {
        VStack(spacing: 0) {
            AccordionHeader(
                icon: "shield.fill",
                iconBG: Color(red: 0.25, green: 0.22, blue: 0.55),
                title: "Automatic Exception Handling",
                subtitle: "Configure overpayment and underpayment tolerance",
                isExpanded: expandException
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandException.toggle() } }

            if expandException {
                VStack(spacing: 0) {
                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
                    VStack(spacing: 0) {
                        BSRow(label: "Currency",      value: "% of Invoice Amount")
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        BSRow(label: "Underpayments", value: "Enabled", valueColor: purpleAccent)
                        Rectangle().fill(strokeClr).frame(height: 0.5)
                        BSRow(label: "Overpayments",  value: "Enabled", valueColor: purpleAccent)
                    }
                    .padding(.horizontal, 16)
                    HStack {
                        Spacer()
                        NavigationLink(destination: PaymentToleranceView()) {
                            Text("Edit")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(purpleAccent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 7)
                                .background(purpleAccent.opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
                }
            }
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }
    // MARK: 6 — Crypto Address

    private var cryptoAddressSection: some View {
        VStack(spacing: 0) {
            AccordionHeader(
                icon: "wallet.pass.fill",
                iconBG: Color(red: 0.12, green: 0.45, blue: 0.35),
                title: "Crypto Address",
                subtitle: "Manage your crypto asset addresses",
                isExpanded: expandCrypto
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandCrypto.toggle() } }

            if expandCrypto {
                NavigationLink(destination: CryptoAddressView()) {
                    HStack(spacing: 10) {
                        Image(systemName: "wallet.pass.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                        Text("View & Manage Crypto Addresses")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    .padding(16)
                    .background(Color(red: 0.12, green: 0.15, blue: 0.22))
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
            }
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }

    // MARK: 7 — Bank Details

    private var bankDetailsSection: some View {
        let subtitle    = bankVM.subtitleText
        let isLoading   = bankVM.isLoading
        let state = bankVM.viewState
        let holderName  = bankVM.holderName
        let accountNo   = bankVM.accountNo
        let accountType = bankVM.accountType
        let bankName    = bankVM.bankName
        let bankAddress = bankVM.bankAddress
        let bankCode    = bankVM.bankCode
        let uuid        = userUUID
        
        
        return VStack(spacing: 0) {

            AccordionHeader(
                icon: "building.columns.fill",
                iconBG: Color(red: 0.18, green: 0.22, blue: 0.40),
                title: "Bank Details",
                subtitle: subtitle,
                isExpanded: expandBank
            ) { withAnimation(.easeInOut(duration: 0.22)) { expandBank.toggle() } }

            if expandBank {
                VStack(spacing: 0) {
                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
                    
                    HStack {
                        bankStatusBadge
                        Spacer()
                    }
                    .padding(.horizontal, 16).padding(.top, 14)
                    
                    if case .loaded = state {
                        VStack(spacing: 0) {
                            BSRow(label: "Holder Name",  value: holderName)
                            Rectangle().fill(strokeClr).frame(height: 0.5)
                            BSRow(label: "Account No.",  value: accountNo)
                            Rectangle().fill(strokeClr).frame(height: 0.5)
                            BSRow(label: "Account Type", value: accountType)
                            Rectangle().fill(strokeClr).frame(height: 0.5)
                            BSRow(label: "Bank Name",    value: bankName)
                            Rectangle().fill(strokeClr).frame(height: 0.5)
                            BSRow(label: "Bank Address", value: bankAddress)
                            Rectangle().fill(strokeClr).frame(height: 0.5)
                            BSRow(label: "Bank Code",    value: bankCode)
                        }
                        .padding(.horizontal, 16)
                    } else if case .empty = state {
                        // 200 OK but user has no bank details on file yet
                        VStack(spacing: 8) {
                            Image(systemName: "building.columns")
                                .font(.system(size: 28)).foregroundColor(labelGray)
                            Text("No bank account added yet")
                                .font(.system(size: 13)).foregroundColor(labelGray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else if case .error(let msg) = state {
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange).font(.system(size: 22))
                            Text(msg)
                                .font(.system(size: 12)).foregroundColor(.white.opacity(0.55))
                                .multilineTextAlignment(.center)
                            Button {
                                print("🔁 [BusinessSettingsView] Retry tapped.")
                                bankVM.load(uuid: uuid)
                            } label: {
                                Text("Retry")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 18).padding(.vertical, 7)
                                    .background(Color(red: 0.18, green: 0.22, blue: 0.40))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 14)
                    } else {
                        VStack(spacing: 0) {
                            ForEach(["Holder Name","Account No.","Account Type",
                                     "Bank Name","Bank Address","Bank Code"], id: \.self) { lbl in
                                BSRow(label: lbl, value: "——")
                                Rectangle().fill(strokeClr).frame(height: 0.5)
                            }
                        }
                        .padding(.horizontal, 16)
                        .redacted(reason: isLoading ? .placeholder : [])
                    }
                    
                    
                    // Replace the NavigationLink + AddButton lines at the bottom of bankDetailsSection with:

                    HStack {
                        Spacer()

                        AddButton {
                            navigateToBankDetails = true
                        }
                    }
                   
                    .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
                }
               // .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
            }
            
        }
        .background(darkCard).cornerRadius(14)
        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
    }

    @ViewBuilder private var bankStatusBadge: some View {
        let state       = bankVM.state
        let isSubmitted = bankVM.isSubmitted

        if case .loading = state {
            badgeView(label: "Loading…",     bg: Color(red: 0.18, green: 0.18, blue: 0.28))
        } else if case .error = state {
            badgeView(label: "Error",         bg: Color(red: 0.38, green: 0.10, blue: 0.10))
        } else if case .empty = state {
            badgeView(label: "Not Added",     bg: Color(red: 0.25, green: 0.20, blue: 0.12))
        } else if case .loaded = state, isSubmitted {
            badgeView(label: "Submitted",     bg: Color(red: 0.10, green: 0.30, blue: 0.15))
        } else {
            badgeView(label: "Not Submitted", bg: Color(red: 0.25, green: 0.20, blue: 0.12))
        }
    }

    private func badgeView(label: String, bg: Color) -> some View {
        Text(label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(bg)
            .cornerRadius(20)
    }
}

// MARK: - Crypto Coin Card

private struct CryptoCoinCard: View {
    let coin: CryptoCoin

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().fill(coin.iconBG).frame(width: 40, height: 40)
                    Image(systemName: coin.icon)
                        .resizable().scaledToFit()
                        .frame(width: 22, height: 22).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(coin.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    Text(coin.code).font(.system(size: 12)).foregroundColor(labelGray)
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("NETWORK").font(.system(size: 10, weight: .semibold)).foregroundColor(labelGray)
                Text(coin.network).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(darkBG).cornerRadius(8)
                    .overlay { RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1) }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("BALANCE").font(.system(size: 10, weight: .semibold)).foregroundColor(labelGray)
                Text("0 \(coin.code)").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(darkBG).cornerRadius(8)
                    .overlay { RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1) }
            }

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                    Text("Add Address").font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 46)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.40, blue: 0.95),
                                 Color(red: 0.40, green: 0.30, blue: 0.85)],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(red: 0.12, green: 0.15, blue: 0.22))
        .cornerRadius(12)
        .overlay { RoundedRectangle(cornerRadius: 12).stroke(strokeClr, lineWidth: 1) }
    }
}

// MARK: - Preview

#Preview {
    BusinessSettingsView()
}



























////  Businesssettingsview.swift
////  Trading_Terminal

//
////  BusinessSettingsView.swift
////  SwiftUI — UI only. Matches all 8 Business Settings screenshots.
//
//import SwiftUI
//
//// MARK: - Reusable atoms
//
//private let darkCard  = Color(red: 0.10, green: 0.12, blue: 0.19)
//private let darkBG    = Color(red: 0.08, green: 0.10, blue: 0.16)
//private let purpleAccent = Color(red: 0.45, green: 0.35, blue: 0.90)
//private let labelGray = Color.white.opacity(0.45)
//private let strokeClr = Color.white.opacity(0.10)
//
//private struct BSRow: View {
//    let label: String
//    let value: String
//    var valueColor: Color = .white
//
//    var body: some View {
//        HStack {
//            Text(label).font(.system(size: 13)).foregroundColor(labelGray)
//            Spacer()
//            Text(value).font(.system(size: 13)).foregroundColor(valueColor)
//        }
//        .padding(.vertical, 10)
//    }
//}
//
//private struct EditButton: View {
//    var body: some View {
//        HStack(spacing: 6) {
//            Image(systemName: "pencil").font(.system(size: 12))
//            Text("EDIT").font(.system(size: 13, weight: .semibold))
//        }
//        .foregroundColor(.white)
//        .padding(.horizontal, 16).padding(.vertical, 8)
//        .background(Color(red: 0.14, green: 0.17, blue: 0.28))
//        .cornerRadius(8)
//        .overlay { RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1) }
//    }
//}
//
//private struct AccordionHeader: View {
//    let icon: String
//    let iconBG: Color
//    let title: String
//    let subtitle: String
//    let isExpanded: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack(spacing: 14) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10).fill(iconBG)
//                        .frame(width: 44, height: 44)
//                    Image(systemName: icon)
//                        .resizable().scaledToFit()
//                        .frame(width: 22, height: 22)
//                        .foregroundColor(.white)
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(title).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
//                    Text(subtitle).font(.system(size: 12)).foregroundColor(labelGray)
//                }
//                Spacer()
//                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
//                    .font(.system(size: 13)).foregroundColor(labelGray)
//            }
//            .padding(16)
//        }
//        .buttonStyle(.plain)
//    }
//}
//
//// MARK: - Crypto coin model
//
//private struct CryptoCoin: Identifiable {
//    let id = UUID()
//    let name: String
//    let code: String
//    let icon: String
//    let iconBG: Color
//    let network: String
//}
//
//private let cryptoCoins: [CryptoCoin] = [
//    CryptoCoin(name: "Dogecoin",      code: "DOGE",  icon: "d.circle.fill",          iconBG: Color(red:0.80,green:0.65,blue:0.10), network: "NATIVE"),
//    CryptoCoin(name: "Tether",        code: "USDT",  icon: "t.circle.fill",           iconBG: Color(red:0.10,green:0.65,blue:0.45), network: "ERC / TRC"),
//    CryptoCoin(name: "Ethereum",      code: "ETH",   icon: "e.circle.fill",           iconBG: Color(red:0.35,green:0.45,blue:0.85), network: "NATIVE"),
//    CryptoCoin(name: "Bitcoin",       code: "BTC",   icon: "bitcoinsign.circle.fill", iconBG: Color(red:0.95,green:0.50,blue:0.10), network: "NATIVE"),
//    CryptoCoin(name: "Litecoin",      code: "LTC",   icon: "l.circle.fill",           iconBG: Color(red:0.55,green:0.55,blue:0.60), network: "NATIVE"),
//    CryptoCoin(name: "Hashcash Coin", code: "HCX",   icon: "h.circle.fill",           iconBG: Color(red:0.10,green:0.55,blue:0.55), network: "ERC"),
//    CryptoCoin(name: "Ripple",        code: "XRP",   icon: "x.circle.fill",           iconBG: Color(red:0.18,green:0.22,blue:0.32), network: "NATIVE"),
//    CryptoCoin(name: "Bitcoin Cash",  code: "BCH",   icon: "bitcoinsign.circle.fill", iconBG: Color(red:0.10,green:0.72,blue:0.35), network: "NATIVE"),
//    CryptoCoin(name: "USDC",          code: "USDC",  icon: "dollarsign.circle.fill",  iconBG: Color(red:0.15,green:0.45,blue:0.90), network: "ERC"),
//]
//
//// MARK: - Main View
//
//struct BusinessSettingsView: View {
//
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var expandMerchant     = true
//    @State private var expandVolume       = false
//    @State private var expandCharges      = false
//    @State private var expandOrder        = false
//    @State private var expandException    = false
//    @State private var expandCrypto       = false
//    @State private var expandBank         = false
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            darkBG.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    pageHeader
//                    VStack(spacing: 12) {
//                        merchantProfileSection
//                        approvedVolumeSection
//                        transactionChargesSection
//                        orderSettingsSection
//                        autoExceptionSection
//                        cryptoAddressSection
//                        bankDetailsSection
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.top, 16)
//                    .padding(.bottom, 100)
//                }
//            }
//
//            Button(action: {}) {
//                Image(systemName: "plus")
//                    .font(.system(size: 22, weight: .bold))
//                    .foregroundColor(.white)
//                    .frame(width: 60, height: 60)
//                    .background(Color(red: 0.20, green: 0.40, blue: 0.95))
//                    .clipShape(RoundedRectangle(cornerRadius: 18))
//                    .shadow(color: Color.blue.opacity(0.5), radius: 12, x: 0, y: 6)
//            }
//            .padding(.trailing, 20).padding(.bottom, 28)
//        }
//    }
//
//    // MARK: Header
//
//    private var pageHeader: some View {
//        HStack(spacing: 12) {
//            Button(action: { dismiss() }) {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 17, weight: .semibold))
//                    .foregroundColor(.white)
//                    .frame(width: 36, height: 36)
//            }
//            VStack(alignment: .leading, spacing: 3) {
//                Text("Business Settings")
//                    .font(.system(size: 22, weight: .bold)).foregroundColor(.white)
//                Text("Manage your merchant profile, volume limits, and order preferences")
//                    .font(.system(size: 12)).foregroundColor(labelGray)
//                    .fixedSize(horizontal: false, vertical: true)
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 16).padding(.top, 20).padding(.bottom, 4)
//    }
//
//    // MARK: 1 — Merchant Profile
//
//    private var merchantProfileSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "building.columns.fill",
//                iconBG: Color(red: 0.18, green: 0.22, blue: 0.40),
//                title: "Merchant Profile",
//                subtitle: "Your business identity and contact details",
//                isExpanded: expandMerchant
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandMerchant.toggle() } }
//
//            if expandMerchant {
//                VStack(spacing: 0) {
//                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
//                    VStack(spacing: 0) {
//                        BSRow(label: "Name",          value: "raj")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Industry",      value: "Banking, Mortgage")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Website",       value: "www.hashcashconsultants.com", valueColor: purpleAccent)
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Support Phone", value: "N/A")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Support Email", value: "N/A")
//                    }
//                    .padding(.horizontal, 16)
//
//                    HStack { Spacer(); EditButton() }
//                        .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
//                }
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//
//    // MARK: 2 — Approved Volume
//
//    private var approvedVolumeSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "checkmark",
//                iconBG: Color(red: 0.12, green: 0.45, blue: 0.35),
//                title: "Approved Volume",
//                subtitle: "Your current transaction limits",
//                isExpanded: expandVolume
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandVolume.toggle() } }
//
//            if expandVolume {
//                VStack(spacing: 0) {
//                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
//                    VStack(spacing: 0) {
//                        HStack {
//                            Text("Daily Limit").font(.system(size: 13)).foregroundColor(labelGray)
//                            Spacer()
//                            VStack(alignment: .trailing, spacing: 2) {
//                                Text("$ 100000").font(.system(size: 15, weight: .semibold))
//                                    .foregroundColor(purpleAccent)
//                                Text("per day").font(.system(size: 11)).foregroundColor(labelGray)
//                            }
//                        }.padding(.vertical, 12)
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        HStack {
//                            Text("Monthly Limit").font(.system(size: 13)).foregroundColor(labelGray)
//                            Spacer()
//                            VStack(alignment: .trailing, spacing: 2) {
//                                Text("10000").font(.system(size: 15, weight: .semibold))
//                                    .foregroundColor(purpleAccent)
//                                Text("payments per month").font(.system(size: 11)).foregroundColor(labelGray)
//                            }
//                        }.padding(.vertical, 12)
//                    }
//                    .padding(.horizontal, 16)
//                    HStack { Spacer(); EditButton() }
//                        .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
//                }
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//
//    // MARK: 3 — Transaction Charges
//
//    private let charges = ["BTC","ETH","BCH","LTC","HCX","XRP","USDT","DOGE","USDC"]
//
//    private var transactionChargesSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "doc.text.fill",
//                iconBG: Color(red: 0.25, green: 0.20, blue: 0.35),
//                title: "Transaction Charges",
//                subtitle: "Fee structure for each supported asset",
//                isExpanded: expandCharges
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandCharges.toggle() } }
//
//            if expandCharges {
//                VStack(spacing: 0) {
//                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
//                    VStack(spacing: 0) {
//                        ForEach(charges, id: \.self) { coin in
//                            HStack {
//                                Text(coin).font(.system(size: 14)).foregroundColor(.white)
//                                Spacer()
//                                Text("2%").font(.system(size: 14, weight: .semibold))
//                                    .foregroundColor(purpleAccent)
//                            }
//                            .padding(.vertical, 12)
//                            if coin != charges.last {
//                                Rectangle().fill(strokeClr).frame(height: 0.5)
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 12)
//                }
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//
//    // MARK: 4 — Order Settings
//
//    private var orderSettingsSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "envelope.fill",
//                iconBG: Color(red: 0.18, green: 0.22, blue: 0.40),
//                title: "Order Settings",
//                subtitle: "Configure notification preferences",
//                isExpanded: expandOrder
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandOrder.toggle() } }
//
//            if expandOrder {
//                VStack(spacing: 0) {
//                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
//                    HStack(spacing: 4) {
//                        Text("Send Notification to").font(.system(size: 13)).foregroundColor(labelGray)
//                        Text(UserDefaults.standard.string(forKey: "Bemail") ?? "rajit@hashcashconsultants.com")
//                            .font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
//                    }
//                    .padding(.horizontal, 16).padding(.vertical, 14)
//                    HStack { Spacer(); EditButton() }
//                        .padding(.horizontal, 16).padding(.bottom, 16)
//                }
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//
//    // MARK: 5 — Automatic Exception Handling
//
//    private var autoExceptionSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "shield.fill",
//                iconBG: Color(red: 0.25, green: 0.22, blue: 0.55),
//                title: "Automatic Exception Handling",
//                subtitle: "Configure overpayment and underpayment tolerance",
//                isExpanded: expandException
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandException.toggle() } }
//
//            if expandException {
//                VStack(spacing: 0) {
//                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
//                    VStack(spacing: 0) {
//                        BSRow(label: "Currency",      value: "% of Invoice Amount")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Underpayments", value: "Enabled", valueColor: purpleAccent)
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Overpayments",  value: "Enabled", valueColor: purpleAccent)
//                    }
//                    .padding(.horizontal, 16)
//                    HStack { Spacer(); EditButton() }
//                        .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
//                }
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//
//    // MARK: 6 — Crypto Address
//
//    private var cryptoAddressSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "wallet.pass.fill",
//                iconBG: Color(red: 0.12, green: 0.45, blue: 0.35),
//                title: "Crypto Address",
//                subtitle: "Manage your crypto asset addresses",
//                isExpanded: expandCrypto
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandCrypto.toggle() } }
//
//            if expandCrypto {
//                VStack(spacing: 12) {
//                    ForEach(cryptoCoins) { coin in
//                        CryptoCoinCard(coin: coin)
//                    }
//                }
//                .padding(12)
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//
//    // MARK: 7 — Bank Details
//
//    private var bankDetailsSection: some View {
//        VStack(spacing: 0) {
//            AccordionHeader(
//                icon: "building.columns.fill",
//                iconBG: Color(red: 0.18, green: 0.22, blue: 0.40),
//                title: "Bank Details",
//                subtitle: "Bank details not submitted.",
//                isExpanded: expandBank
//            ) { withAnimation(.easeInOut(duration: 0.22)) { expandBank.toggle() } }
//
//            if expandBank {
//                VStack(spacing: 0) {
//                    Rectangle().fill(strokeClr).frame(height: 0.5).padding(.horizontal, 16)
//
//                    // Not Submitted badge
//                    HStack {
//                        Text("Not Submitted")
//                            .font(.system(size: 12, weight: .semibold))
//                            .foregroundColor(.white)
//                            .padding(.horizontal, 12).padding(.vertical, 6)
//                            .background(Color(red: 0.25, green: 0.20, blue: 0.12))
//                            .cornerRadius(20)
//                        Spacer()
//                    }
//                    .padding(.horizontal, 16).padding(.top, 14)
//
//                    VStack(spacing: 0) {
//                        BSRow(label: "Holder Name",   value: "N/A")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Account No.",   value: "N/A")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Account Type",  value: "N/A")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Bank Name",     value: "N/A")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Bank Address",  value: "N/A")
//                        Rectangle().fill(strokeClr).frame(height: 0.5)
//                        BSRow(label: "Bank Code",     value: "N/A")
//                    }
//                    .padding(.horizontal, 16)
//
//                    HStack { Spacer(); EditButton() }
//                        .padding(.horizontal, 16).padding(.bottom, 16).padding(.top, 8)
//                }
//            }
//        }
//        .background(darkCard).cornerRadius(14)
//        .overlay { RoundedRectangle(cornerRadius: 14).stroke(strokeClr, lineWidth: 1) }
//    }
//}
//
//// MARK: - Crypto Coin Card
//
//private struct CryptoCoinCard: View {
//    let coin: CryptoCoin
//
//    var body: some View {
//        VStack(spacing: 10) {
//            // Coin header
//            HStack(spacing: 12) {
//                ZStack {
//                    Circle().fill(coin.iconBG).frame(width: 40, height: 40)
//                    Image(systemName: coin.icon)
//                        .resizable().scaledToFit()
//                        .frame(width: 22, height: 22).foregroundColor(.white)
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text(coin.name).font(.system(size: 14, weight: .bold)).foregroundColor(.white)
//                    Text(coin.code).font(.system(size: 12)).foregroundColor(labelGray)
//                }
//                Spacer()
//            }
//
//            // Network field
//            VStack(alignment: .leading, spacing: 4) {
//                Text("NETWORK").font(.system(size: 10, weight: .semibold)).foregroundColor(labelGray)
//                Text(coin.network).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(12)
//                    .background(darkBG).cornerRadius(8)
//                    .overlay { RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1) }
//            }
//
//            // Balance field
//            VStack(alignment: .leading, spacing: 4) {
//                Text("BALANCE").font(.system(size: 10, weight: .semibold)).foregroundColor(labelGray)
//                Text("0 \(coin.code)").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    .padding(12)
//                    .background(darkBG).cornerRadius(8)
//                    .overlay { RoundedRectangle(cornerRadius: 8).stroke(strokeClr, lineWidth: 1) }
//            }
//
//            // Add Address button
//            Button(action: {}) {
//                HStack(spacing: 6) {
//                    Image(systemName: "plus").font(.system(size: 13, weight: .bold))
//                    Text("Add Address").font(.system(size: 14, weight: .semibold))
//                }
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity).frame(height: 46)
//                .background(
//                    LinearGradient(
//                        colors: [Color(red: 0.55, green: 0.40, blue: 0.95),
//                                 Color(red: 0.40, green: 0.30, blue: 0.85)],
//                        startPoint: .leading, endPoint: .trailing
//                    )
//                )
//                .cornerRadius(12)
//            }
//            .buttonStyle(.plain)
//        }
//        .padding(14)
//        .background(Color(red: 0.12, green: 0.15, blue: 0.22))
//        .cornerRadius(12)
//        .overlay { RoundedRectangle(cornerRadius: 12).stroke(strokeClr, lineWidth: 1) }
//    }
//}
//
//// MARK: - Preview
//
//#Preview {
//    BusinessSettingsView()
//}
