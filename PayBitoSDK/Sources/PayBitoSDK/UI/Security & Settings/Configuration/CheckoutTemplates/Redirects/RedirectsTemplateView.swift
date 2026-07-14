//
//  RedirectsTemplateView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 17/04/26.
//

import SwiftUI

struct RedirectTemplateView: View {

    @State private var templateName: String = ""

    @State private var successOption: String = "Custom URL"
    @State private var failureOption: String = "Stay on Checkout"

    @State private var successCustomURL: String = ""
    @State private var failureCustomURL: String = ""

    @State private var paymentId = true
    @State private var status = true
    @State private var email = true
    @State private var amount = true
    
    

    @State private var isAdvancedExpanded: Bool = false

    var body: some View {
        ZStack {

            // MARK: - Background
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {

                    // MARK: - Header
                    HStack {
                        Image(systemName: "arrow.left")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .medium))
                        
                        Spacer()
                      
                        
                        Text("New Redirect Template")
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .bold))
                            .tracking(0.3)

                        Spacer()

                       
                    }

                    // MARK: - Template Name
                    sectionLabel("TEMPLATE NAME", required: true)

                    TextField("e.g. Main Store Redirects", text: $templateName)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .font(.system(size: 15, weight: .medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.12))
                        )

                    // MARK: - Success Redirect
                    sectionLabel("SUCCESS REDIRECT", required: false)

                    HStack(spacing: 12) {
                        radioButton(
                            title: "Hosted Page",
                            subtitle: "Built-in success page",
                            selected: successOption == "Hosted Page"
                        ) {
                            successOption = "Hosted Page"
                        }

                        radioButton(
                            title: "Custom URL",
                            subtitle: "Redirect to your URL",
                            selected: successOption == "Custom URL"
                        ) {
                            successOption = "Custom URL"
                        }
                    }

                    if successOption == "Custom URL" {
                        TextField("https://yoursite.com/thank-you", text: $successCustomURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .padding(14)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.12))
                            )
                    }

                    // MARK: - Failure Redirect
                    sectionLabel("FAILURE REDIRECT", required: false)

                    HStack(spacing: 12) {
                        radioButton(
                            title: "Stay on Checkout",
                            subtitle: "Remain on checkout page",
                            selected: failureOption == "Stay on Checkout"
                        ) {
                            failureOption = "Stay on Checkout"
                        }
                      

                        radioButton(
                            title: "Custom URL",
                            subtitle: "Redirect to your URL",
                            selected: failureOption == "Custom URL"
                        ) {
                            failureOption = "Custom URL"
                        }
                    }

                    if failureOption == "Custom URL" {
                        TextField("https://yoursite.com/retry", text: $failureCustomURL)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.URL)
                            .padding(14)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .font(.system(size: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.white.opacity(0.12))
                            )
                    }

                    // MARK: - Advanced Options
                    VStack(alignment: .leading, spacing: 14) {

                        Button {
                            withAnimation {
                                isAdvancedExpanded.toggle()
                            }
                        } label: {
                            HStack {
                                Text("Advanced Options")
                                    .foregroundColor(.white)
                                    .font(.system(size: 15, weight: .semibold))

                                Spacer()

                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white.opacity(0.6))
                                    .rotationEffect(.degrees(isAdvancedExpanded ? 180 : 0))
                            }
                        }

                        if isAdvancedExpanded {

                            Text("Append query parameters to redirect URL:")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.system(size: 12))

                            VStack {
                                checkbox("payment_id", $paymentId)
                                divider()
                                checkbox("status", $status)
                                divider()
                                checkbox("customer_email", $email)
                                divider()
                                checkbox("amount", $amount)
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.05))
                    .cornerRadius(12)

                    // MARK: - Buttons
                    HStack(spacing: 12) {

                        Button("Cancel") {}
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .overlay(
                                RoundedRectangle(cornerRadius: 26)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .foregroundColor(.white.opacity(0.9))
                            .font(.system(size: 15, weight: .semibold))

                        gradientButton("Save Template")
                        gradientButton("Save & Make Default")
                    }
                }
                .padding()
            }
        }
    }
}

// MARK: - Components

extension RedirectTemplateView {

    func sectionLabel(_ text: String, required: Bool) -> some View {
        HStack(spacing: 4) {
            Text(text)
                .foregroundColor(.white.opacity(0.45))
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.5)

            if required {
                Text("*")
                    .foregroundColor(.purple)
            }
        }
    }

    func radioButton(title: String, subtitle: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Circle()
                    .stroke(selected ? Color.blue : Color.white.opacity(0.3), lineWidth: 1.5)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Circle()
                            .fill(selected ? Color.blue : Color.clear)
                            .frame(width: 9, height: 9)
                    )

                VStack(alignment: .leading) {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.system(size: 13, weight: .semibold))

                    Text(subtitle)
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 11))
                }

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(selected ? Color.blue.opacity(0.15) : Color.white.opacity(0.05))
            .cornerRadius(10)
        }
    }

    func checkbox(_ title: String, _ isOn: Binding<Bool>) -> some View {
        Button {
            isOn.wrappedValue.toggle()
        } label: {
            HStack {
                Image(systemName: isOn.wrappedValue ? "checkmark.square.fill" : "square")
                    .foregroundColor(.purple)

                Text(title)
                    .foregroundColor(.white)
                    .font(.system(size: 14))

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }
    }

    func divider() -> some View {
        Divider().background(Color.white.opacity(0.1))
    }

    func gradientButton(_ title: String) -> some View {
        Button(title) {}
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(26)
            .foregroundColor(.white)
            .font(.system(size: 12, weight: .semibold))
           // .tracking(1.5)
    }
}

// MARK: - Preview

struct RedirectTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        RedirectTemplateView()
            .preferredColorScheme(.dark)
    }
}
