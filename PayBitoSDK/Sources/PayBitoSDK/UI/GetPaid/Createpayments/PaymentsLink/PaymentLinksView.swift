//
//  PaymentLinksView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/05/26.
//

////
////  ViewPaymentLinksView.swift
////  Trading_Terminal
////
////  ViewPaymentLinksView.swift
////  Trading_Terminal
////

import SwiftUI

// MARK: - Main View

struct ViewPaymentLinksView: View {

    @Environment(\.dismiss) private var dismiss

    @StateObject private var vm = ViewPaymentLinksViewModel()
    
    
    
    // MARK: - Bottom Sheet State

       @State private var selectedPCN: String? = nil
       @State private var showDetail = false
    

    // ── Navigation state for detail bottom sheet
  //////  @State private var selectedPCN: String? = nil
  ///////  @State private var showDetail:  Bool    = false

    
    
    // ── Theme
    private let darkBG = Color(red: 0.07, green: 0.09, blue: 0.13)
    private let cardBG = Color(red: 0.10, green: 0.12, blue: 0.19)
    private let purple = Color(red: 0.28, green: 0.24, blue: 0.80)
    private let border = Color.white.opacity(0.08)

    // MARK: - Body

    var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 14) {
                        pageTitle
                        
                        // ── Content area
                        if vm.isLoading && vm.payments.isEmpty {
                            loadingView
                            
                        } else if let errorMessage = vm.errorMessage, vm.payments.isEmpty {
                            errorView(message: errorMessage)
                            
                        } else if vm.totalCount == 0 && !vm.isLoading {
                            emptyStateView
                            
                        } else {
                            cardsGrid
                            footerSection
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
            
            // ── Overlay spinner while refreshing an existing page
            if vm.isLoading && !vm.payments.isEmpty {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.4)
            }
            
            // ── PaymentLinkDetailView bottom sheet
            // Sits on top of the whole ZStack at zIndex 99
            // PaymentLinkDetailView handles its own dim overlay + slide animation internally
            if showDetail, let pcn = selectedPCN {
                PaymentLinkDetailView(
                    pcn:         pcn,
                    merchantId:  Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "") ?? 0,
                    isPresented: $showDetail
                )
                .zIndex(99)
            }
        }
        .navigationBarHidden(true)
        .onAppear { vm.onAppear() }
    }

    // MARK: - Page Title

    private var pageTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
                .buttonStyle(ScaleButtonStyle())

                Text("Payments")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
            }

            Text("All payment links you've created")
                .foregroundColor(Color.white.opacity(0.38))
                .font(.system(size: 12))
                .padding(.leading, 40)
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: purple))
                .scaleEffect(1.3)
            Text("Loading payments…")
                .foregroundColor(Color.white.opacity(0.45))
                .font(.system(size: 13))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    // MARK: - Error

    private func errorView(message: String) -> some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.orange)

            Text(message)
                .foregroundColor(Color.white.opacity(0.65))
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Button {
                vm.onAppear()
            } label: {
                Text("Retry")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(purple)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(Color.white.opacity(0.15))
            
            Text("No payment links created yet")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(border, lineWidth: 1)
        )
    }

    // MARK: - 2-Column Grid

    private var cardsGrid: some View {
        let cols = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
        ]
        return LazyVGrid(columns: cols, spacing: 10) {
            ForEach(vm.payments) { payment in
                PaymentCardCell(
                    payment: payment,
                    cardBG:  cardBG,
                    purple:  purple,
                    border:  border,
                    onView: {
                        // ── Tap "View" → set PCN → open bottom sheet
                        debugPrint("🔷 [ViewPaymentLinksView] View tapped")
                        debugPrint("   PCN  : \(payment.id)")
                        debugPrint("   Name : \(payment.paymentName)")
                        selectedPCN = payment.id   // e.g. "PCN2873"
                        showDetail  = true         // PaymentLinkDetailView animates itself
                    }
                )
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Spacer()
                Text("Showing \(vm.showStart)–\(vm.showEnd) of \(vm.totalCount)")
                    .foregroundColor(Color.white.opacity(0.38))
                    .font(.system(size: 11))
                Spacer()
            }

            HStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        pageBtn("«", canTap: vm.canGoPrevious) { vm.goToFirstPage()    }
                        pageBtn("‹", canTap: vm.canGoPrevious) { vm.goToPreviousPage() }

                        ForEach(vm.visiblePages, id: \.self) { p in
                            pageBtn("\(p)", canTap: true, isActive: p == vm.currentPage) {
                                vm.goToPage(p)
                            }
                        }

                        pageBtn("›", canTap: vm.canGoNext) { vm.goToNextPage() }
                        pageBtn("»", canTap: vm.canGoNext) { vm.goToLastPage() }
                    }
                    .padding(.vertical, 2)
                }
                .fixedSize()
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Pagination Button

    @ViewBuilder
    private func pageBtn(
        _ label:  String,
        canTap:   Bool,
        isActive: Bool = false,
        action:   @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { action() }
        } label: {
            Text(label)
                .font(.system(size: 12, weight: isActive ? .bold : .regular))
                .foregroundColor(
                    isActive ? .white :
                    canTap   ? Color.white.opacity(0.65) :
                               Color.white.opacity(0.20)
                )
                .frame(width: 30, height: 30)
                .background(isActive ? purple : Color.white.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(isActive ? Color.clear : border, lineWidth: 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(ButtonStylesView())
        .disabled(!canTap)
    }
}

// MARK: - Payment Card Cell

private struct PaymentCardCell: View {

    let payment: PaymentLinkItem
    let cardBG:  Color
    let purple:  Color
    let border:  Color
    let onView:  () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // PCN badge + date
            HStack(alignment: .top, spacing: 6) {
                Text(payment.id)                      // PCN code e.g. "PCN2873"
                    .foregroundColor(.white)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(purple)
                    .clipShape(RoundedRectangle(cornerRadius: 4))

                Spacer(minLength: 2)

                VStack(alignment: .trailing, spacing: 1) {
                    Image(systemName: "calendar")
                        .font(.system(size: 8))
                        .foregroundColor(Color.white.opacity(0.35))
                    Text(payment.formattedDate)
                        .font(.system(size: 9))
                        .foregroundColor(Color.white.opacity(0.35))
                        .lineLimit(1)
                }
            }

            // Payment name
            Text(payment.paymentName)
                .foregroundColor(.white)
                .font(.system(size: 11, weight: .semibold))
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            // View button → triggers onView closure above
            Button(action: onView) {
                HStack(spacing: 4) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 9))
                    Text("View")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .background(purple)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .contentShape(Rectangle())
            }
            .buttonStyle(ButtonStylesView())
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(cardBG)
        .clipShape(RoundedRectangle(cornerRadius: 11))
        .overlay(
            RoundedRectangle(cornerRadius: 11)
                .stroke(border, lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct ViewPaymentsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ViewPaymentLinksView()
                .previewDevice("iPhone 16 Pro")
                .preferredColorScheme(.dark)
                .previewDisplayName("iPhone 16 Pro")

            ViewPaymentLinksView()
                .previewDevice("iPhone SE (3rd generation)")
                .preferredColorScheme(.dark)
                .previewDisplayName("iPhone SE")
        }
    }
}
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}








