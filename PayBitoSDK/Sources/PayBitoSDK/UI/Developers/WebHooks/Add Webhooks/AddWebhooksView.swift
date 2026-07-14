//
//  AddWebhooksView.swift
//

import SwiftUI

// MARK: - Add Endpoint Sheet

struct AddEndpointSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    var onSave: (WHEndpointDisplayItem) -> Void
    let merchantId: Int
    
    @State private var endpointURL   = ""
    @State private var description   = ""
    @State private var allEvents     = true
    @State private var retryEnabled  = true
    @State private var maxRetries    = "5"
    @State private var timeout       = "10"
    @State private var isActive      = true
    @State private var signingSecret = "sk_live_YOUR_STRIPE_SECRET_KEY"
    @State private var isSaving      = false
    @State private var errorMessage: String? = nil
    
    private let sectionLabel = Color.white.opacity(0.40)
    private let fieldBG      = Color(red: 0.12, green: 0.15, blue: 0.22)
    private let purple       = Color(red: 0.45, green: 0.35, blue: 0.90)
    private let orange       = Color(red: 0.85, green: 0.55, blue: 0.10)
    
    var body: some View {
        if #available(iOS 16.4, *) {
            sheetContent
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
                .presentationBackground(Color(red: 0.08, green: 0.10, blue: 0.16))
        } else {
            sheetContent
        }
    }
    
    private var sheetContent: some View {
        ZStack {
            Color(red: 0.08, green: 0.10, blue: 0.16).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Sheet header
                HStack {
                    Text("Add Endpoint")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.white.opacity(0.40))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20).padding(.top, 20).padding(.bottom, 16)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        basicInfoSection
                        addDivider
                        eventsSection
                        addDivider
                        securitySection
                        addDivider
                        deliverySection
                        addDivider
                        statusSection
                        
                        // Inline error
                        if let errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.97, green: 0.32, blue: 0.29))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                                .padding(.top, 12)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Bottom buttons
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity).frame(height: 52)
                            .background(Color(red: 0.18, green: 0.20, blue: 0.30))
                            .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                    
                    Button(action: handleSave) {
                        ZStack {
                            Text("Save Endpoint")
                                .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                .opacity(isSaving ? 0 : 1)
                            if isSaving {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity).frame(height: 52)
                        .background(purple.opacity(isSaving ? 0.6 : 1))
                        .cornerRadius(14)
                    }
                    .buttonStyle(.plain)
                    .disabled(isSaving)
                }
                .padding(.horizontal, 20).padding(.vertical, 16)
                .background(Color(red: 0.08, green: 0.10, blue: 0.16))
            }
        }
    }
    
    // MARK: - Basic Info
    
    private var basicInfoSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("BASIC INFO")
                .font(.system(size: 11, weight: .semibold)).foregroundColor(sectionLabel)
            
            WHField(label: "Endpoint URL *",
                    placeholder: "https://yourdomain.com/webhook",
                    text: $endpointURL,
                    keyboard: .URL)
            
            WHField(label: "Description (optional)",
                    placeholder: "e.g. Internal notifications",
                    text: $description)
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }
    
    // MARK: - Events
    
    private var eventsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("EVENTS TO SEND")
                .font(.system(size: 11, weight: .semibold)).foregroundColor(sectionLabel)
            
            RadioOption(label: "All events",    isSelected: allEvents)  { allEvents = true }
            RadioOption(label: "Select events", isSelected: !allEvents) { allEvents = false }
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }
    
    // MARK: - Security
    
    private var securitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SECURITY")
                .font(.system(size: 11, weight: .semibold)).foregroundColor(sectionLabel)
            
            Text("Signing Secret")
                .font(.system(size: 14)).foregroundColor(.white)
            
            HStack(spacing: 0) {
                Text(signingSecret)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white.opacity(0.60))
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(fieldBG)
                
                Button(action: regenerateSecret) {
                    Text("Regenerate")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(orange)
                        .padding(.horizontal, 14).padding(.vertical, 12)
                        .background(Color(red: 0.22, green: 0.16, blue: 0.06))
                }
            }
            .cornerRadius(10)
            .overlay { RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.12), lineWidth: 1) }
            
            Text("Used to verify the authenticity of webhook payloads")
                .font(.system(size: 11)).foregroundColor(.white.opacity(0.35))
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }
    
    // MARK: - Delivery Settings
    
    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("DELIVERY SETTINGS")
                .font(.system(size: 11, weight: .semibold)).foregroundColor(sectionLabel)
            
            HStack {
                Toggle("", isOn: $retryEnabled)
                    .labelsHidden()
                    .tint(purple)
                Text("Retry on failure")
                    .font(.system(size: 15)).foregroundColor(.white)
                Spacer()
            }
            
            if retryEnabled {
                HStack {
                    Text("Max retries")
                        .font(.system(size: 14)).foregroundColor(.white)
                    Spacer()
                    TextField("5", text: $maxRetries)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(width: 60).frame(height: 40)
                        .background(fieldBG).cornerRadius(8)
                        .overlay { RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1) }
                }
                
                HStack {
                    Text("Timeout")
                        .font(.system(size: 14)).foregroundColor(.white)
                    Spacer()
                    HStack(spacing: 6) {
                        TextField("10", text: $timeout)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .frame(width: 60).frame(height: 40)
                            .background(fieldBG).cornerRadius(8)
                            .overlay { RoundedRectangle(cornerRadius: 8).stroke(Color.white.opacity(0.12), lineWidth: 1) }
                        Text("sec")
                            .font(.system(size: 13)).foregroundColor(.white.opacity(0.45))
                    }
                }
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }
    
    // MARK: - Status
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("STATUS")
                .font(.system(size: 11, weight: .semibold)).foregroundColor(sectionLabel)
            
            RadioOption(label: "Active",   isSelected: isActive)  { isActive = true }
            RadioOption(label: "Disabled", isSelected: !isActive) { isActive = false }
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
    }
    
    // MARK: - Helpers
    
    private var addDivider: some View {
        Rectangle().fill(Color.white.opacity(0.08)).frame(height: 0.5)
    }
    
    private func regenerateSecret() {
        signingSecret = "sk_live_" + UUID().uuidString
            .replacingOccurrences(of: "-", with: "")
            .prefix(24)
    }
    
    // MARK: - Save → real API call
    
    private func handleSave() {
        let trimmedURL = endpointURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else { errorMessage = "Endpoint URL is required."; return }
        guard URL(string: trimmedURL) != nil else { errorMessage = "Please enter a valid URL."; return }
        
        errorMessage = nil
        isSaving = true
        
        let uuid       = UserDefaults.standard.string(forKey: "Buuid") ?? ""
        let eventsMode = allEvents ? "all" : "select"
        
        WebhookEndpointService.shared.addMerchantWebhookEndpoint(
            uuid:        uuid,
            merchantId:  merchantId,                 // ✅ use injected value
            endpointURL: trimmedURL,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            eventsMode:  eventsMode
        ) { result in
            isSaving = false
            switch result {
            case .success(let response):
                let epId = response.epId ?? 0
                let apiModel = WHEndpointAPIModel(
                    epId:         epId,
                    merchantId:   merchantId,        // ✅ use injected value
                    url:          trimmedURL,
                    description:  description.isEmpty ? nil : description,
                    eventsMode:   eventsMode,
                    secret:       signingSecret,
                    retryEnabled: retryEnabled ? "Y" : "N",
                    maxRetries:   Int(maxRetries) ?? 5,
                    timeoutSec:   Int(timeout) ?? 10,
                    status:       isActive ? "Active" : "Inactive",
                    lastDelivery: nil,
                    eventCount:   0,
                    events:       []
                )
                let displayItem = WHEndpointDisplayItem(from: apiModel)
                onSave(displayItem)
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
    }
    
    // MARK: - Radio Option
    
    private struct RadioOption: View {
        let label: String
        let isSelected: Bool
        let action: () -> Void
        
        private let purple = Color(red: 0.45, green: 0.35, blue: 0.90)
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle().stroke(purple, lineWidth: 2).frame(width: 24, height: 24)
                        if isSelected {
                            Circle().fill(purple).frame(width: 14, height: 14)
                        }
                    }
                    Text(label)
                        .font(.system(size: 15)).foregroundColor(.white)
                    Spacer()
                }
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: - Field Helper
    
    private struct WHField: View {
        let label: String
        let placeholder: String
        @Binding var text: String
        var keyboard: UIKeyboardType = .default
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(label).font(.system(size: 14)).foregroundColor(.white)
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .padding(14)
                    .background(Color(red: 0.12, green: 0.15, blue: 0.22))
                    .cornerRadius(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    }
            }
        }
        // }
        
        // MARK: - Preview
        
        #Preview("Add") {
            Color.black.ignoresSafeArea()
                .sheet(isPresented: .constant(true)) {
                    AddEndpointSheet(onSave: { _ in }, merchantId: 0) // ✅ add merchantId: 0
                }
        }}

}
