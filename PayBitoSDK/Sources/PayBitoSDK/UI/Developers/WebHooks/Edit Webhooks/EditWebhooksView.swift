//
//  EditWebhooksView.swift
//

import SwiftUI

// MARK: - Models

struct EPEndpoint {
    var url:            String       = ""
    var description:    String       = ""
    var eventMode:      EPEventMode  = .all
    var selectedEvents: Set<String>  = []
    var signingSecret:  String       = ""
    var retryOnFailure: Bool         = true
    var maxRetries:     Int          = 5
    var timeout:        Int          = 5
    var status:         EPStatus     = .active
}

enum EPEventMode { case all, selected }
enum EPStatus    { case active, disabled }

// MARK: - Theme

private enum EPDS {
    static let bg         = Color(epHex: "#0E1117")
    static let card       = Color(epHex: "#1C2333")
    static let border     = Color(epHex: "#2A3348")
    static let accent     = Color(epHex: "#6C63FF")
    static let label      = Color(epHex: "#8B93A8")
    static let text       = Color.white
    static let green      = Color(epHex: "#22C55E")
    static let orange     = Color(epHex: "#F59E0B")
    static let radius: CGFloat = 14
}

private extension Color {
    init(epHex hex: String) {
        var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if h.hasPrefix("#") { h.removeFirst() }
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >>  8) & 0xFF) / 255
        let b = Double( rgb        & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Entry Point

struct EditWebhooksView: View {
    @State  private var endpoint:   EPEndpoint
    private let epId:               Int
    private let merchantId:         Int       // ✅ added
    private let onSaved:            (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    // Default empty init (for preview / standalone use)
    init() {
        _endpoint  = State(initialValue: EPEndpoint())
        epId       = 0
        merchantId = 0                        // ✅
        onSaved    = nil
    }

    // Init from WHEndpointDisplayItem
    init(endpoint: WHEndpointDisplayItem, onSaved: (() -> Void)? = nil) {
        var ep            = EPEndpoint()
        ep.url            = endpoint.url
        ep.description    = endpoint.description
        ep.status         = endpoint.isActive ? .active : .disabled
        ep.retryOnFailure = endpoint.retryEnabled
        ep.maxRetries     = endpoint.maxRetries
        ep.timeout        = endpoint.timeoutSec
        ep.eventMode      = endpoint.eventsMode == "all" ? .all : .selected
        ep.selectedEvents = Set(endpoint.events)
        ep.signingSecret  = endpoint.secret ?? ""
        _endpoint         = State(initialValue: ep)
        epId              = endpoint.id
        merchantId        = endpoint.merchantId   // ✅ from display item
        self.onSaved      = onSaved
    }

    var body: some View {
        EPSheet(
            endpoint:   $endpoint,
            epId:       epId,
            merchantId: merchantId,           // ✅ forwarded
            onDismiss:  { dismiss() },
            onSaved:    onSaved
        )
    }
}

// MARK: - Sheet

struct EPSheet: View {
    @Binding var endpoint:  EPEndpoint
    let epId:               Int
    let merchantId:         Int               // ✅ added
    let onDismiss:          () -> Void
    let onSaved:            (() -> Void)?

    @State private var isSaving = false
    @State private var errorMsg: String? = nil
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .bottom) {
            EPDS.bg.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Edit Endpoint")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(EPDS.text)
                        Spacer()
                        Button { onDismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(EPDS.label)
                                .frame(width: 32, height: 32)
                                .background(EPDS.card)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                    Divider().background(EPDS.border).padding(.horizontal, 20)

                    VStack(spacing: 24) {
                        EPSummaryCard(endpoint: endpoint)

                        EPSectionHeader("BASIC INFO")
                        EPBasicInfo(endpoint: $endpoint)

                        Divider().background(EPDS.border)

                        EPSectionHeader("EVENTS TO SEND")
                        EPEventsSection(endpoint: $endpoint)

                        Divider().background(EPDS.border)

                        EPSectionHeader("SECURITY")
                        EPSecurity(endpoint: $endpoint)

                        Divider().background(EPDS.border)

                        EPSectionHeader("DELIVERY SETTINGS")
                        EPDelivery(endpoint: $endpoint)

                        Divider().background(EPDS.border)

                        EPSectionHeader("STATUS")
                        EPStatusSection(endpoint: $endpoint)

                        if let errorMsg {
                            Text(errorMsg)
                                .font(.system(size: 13))
                                .foregroundColor(Color(epHex: "#F85149"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 110)
                }
            }

            EPBottomButtons(
                isSaving:  isSaving,
                onDismiss: onDismiss,
                onSave:    handleSave
            )
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    // MARK: - Save

    private func handleSave() {
        let trimmedURL = endpoint.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedURL.isEmpty else { errorMsg = "Endpoint URL is required."; return }
        guard URL(string: trimmedURL) != nil else { errorMsg = "Please enter a valid URL."; return }

        errorMsg = nil
        isSaving = true

        let uuid = UserDefaults.standard.string(forKey: "Buuid") ?? ""

        let endpointFields: [String: Any] = [
            "url":          trimmedURL,
            "description":  endpoint.description.trimmingCharacters(in: .whitespacesAndNewlines),
            "eventsMode":   endpoint.eventMode == .all ? "all" : "select",
            "secret":       endpoint.signingSecret,
            "retryEnabled": endpoint.retryOnFailure ? "Y" : "N",
            "maxRetries":   endpoint.maxRetries,
            "timeoutSec":   endpoint.timeout,
            "status":       endpoint.status == .active ? "Active" : "Inactive",
            "events":       Array(endpoint.selectedEvents)
        ]

        WebhookEndpointService.shared.updateMerchantWebhookEndpoint(
            uuid:       uuid,
            epId:       epId,
            merchantId: merchantId,           // ✅ real value, not 0
            params:     endpointFields
        ) { result in
            isSaving = false
            switch result {
            case .success:
                onSaved?()
                onDismiss()
            case .failure(let error):
                errorMsg = error.localizedDescription
            }
        }
    }
}

// MARK: - Summary Card

struct EPSummaryCard: View {
    let endpoint: EPEndpoint
    var body: some View {
        VStack(spacing: 0) {
            EPSummaryRow(label: "Endpoint URL", value: endpoint.url.isEmpty ? "—" : endpoint.url)
            Divider().background(EPDS.border).padding(.leading, 16)
            EPSummaryRow(label: "Events",       value: endpoint.eventMode == .all ? "All events" : "\(endpoint.selectedEvents.count) selected")
            Divider().background(EPDS.border).padding(.leading, 16)
            EPSummaryRowStatus(label: "Status", status: endpoint.status)
            Divider().background(EPDS.border).padding(.leading, 16)
            EPSummaryRow(label: "Last Delivery", value: "—")
        }
        .background(EPDS.card)
        .cornerRadius(EPDS.radius)
        .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.border, lineWidth: 1))
    }
}

struct EPSummaryRow: View {
    let label: String
    let value: String
    var body: some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(EPDS.label)
            Spacer()
            Text(value).font(.system(size: 14)).foregroundColor(EPDS.text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct EPSummaryRowStatus: View {
    let label: String
    let status: EPStatus
    var body: some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(EPDS.label)
            Spacer()
            Text(status == .active ? "Active" : "Disabled")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(status == .active ? EPDS.green : EPDS.label)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(status == .active ? EPDS.green.opacity(0.15) : EPDS.label.opacity(0.15))
                .cornerRadius(20)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Section Header

struct EPSectionHeader: View {
    let title: String
    init(_ title: String) { self.title = title }
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(EPDS.label)
                .kerning(0.8)
            Spacer()
        }
    }
}

// MARK: - Basic Info

struct EPBasicInfo: View {
    @Binding var endpoint: EPEndpoint
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Endpoint URL *")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(EPDS.text)
                TextField("https://your-server.com/webhook", text: $endpoint.url)
                    .textFieldStyle(EPFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.URL)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("Description (optional)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(EPDS.text)
                TextField("e.g. Internal notifications", text: $endpoint.description)
                    .textFieldStyle(EPFieldStyle())
            }
        }
    }
}

struct EPFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(.system(size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(EPDS.card)
            .cornerRadius(EPDS.radius)
            .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.border, lineWidth: 1))
    }
}

// MARK: - Events Section

private let epEventGroups: [(String, [String])] = [
    ("PAYMENT",      ["payment.succeeded", "payment.failed", "payment.refunded", "payment.pending"]),
    ("CHECKOUT",     ["checkout.session.created", "checkout.session.completed", "checkout.session.expired"]),
    ("SUBSCRIPTION", ["subscription.created", "subscription.updated", "subscription.canceled", "subscription.renewed"]),
    ("CHARGE",       ["charge.succeeded", "charge.failed", "charge.disputed"]),
]

struct EPEventsSection: View {
    @Binding var endpoint: EPEndpoint
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EPRadio(label: "All events",    selected: endpoint.eventMode == .all)      { endpoint.eventMode = .all }
            EPRadio(label: "Select events", selected: endpoint.eventMode == .selected) { endpoint.eventMode = .selected }

            if endpoint.eventMode == .selected {
                VStack(spacing: 0) {
                    ForEach(epEventGroups, id: \.0) { group in
                        EPEventGroup(groupName: group.0, events: group.1, selected: $endpoint.selectedEvents)
                    }
                }
                .background(EPDS.card)
                .cornerRadius(EPDS.radius)
                .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.border, lineWidth: 1))
                .transition(.opacity.combined(with: .move(edge: .top)))
                .animation(.easeInOut(duration: 0.25), value: endpoint.eventMode == .selected)
            }
        }
    }
}

struct EPRadio: View {
    let label:    String
    let selected: Bool
    let action:   () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().stroke(EPDS.accent, lineWidth: 2).frame(width: 22, height: 22)
                    if selected {
                        Circle().fill(EPDS.accent).frame(width: 12, height: 12)
                    }
                }
                Text(label).font(.system(size: 16)).foregroundColor(EPDS.text)
                Spacer()
            }
        }
    }
}

struct EPEventGroup: View {
    let groupName: String
    let events:    [String]
    @Binding var selected: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(groupName)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(EPDS.label)
                .kerning(0.6)
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 8)

            ForEach(events, id: \.self) { event in
                Button {
                    if selected.contains(event) { selected.remove(event) }
                    else { selected.insert(event) }
                } label: {
                    HStack(spacing: 12) {
                        EPCheckBox(checked: selected.contains(event))
                        Text(event)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(EPDS.text)
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                }
                if event != events.last {
                    Divider().background(EPDS.border).padding(.leading, 52)
                }
            }
        }
    }
}

struct EPCheckBox: View {
    let checked: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(checked ? EPDS.accent : Color.clear)
                .frame(width: 22, height: 22)
            RoundedRectangle(cornerRadius: 5)
                .stroke(checked ? EPDS.accent : EPDS.border, lineWidth: 1.5)
                .frame(width: 22, height: 22)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Security

struct EPSecurity: View {
    @Binding var endpoint: EPEndpoint
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Signing Secret")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(EPDS.text)
            HStack(spacing: 10) {
                SecureField("••••••••••••••••", text: $endpoint.signingSecret)
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(EPDS.card)
                    .cornerRadius(EPDS.radius)
                    .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.border, lineWidth: 1))

                Button("Regenerate") {
                    endpoint.signingSecret = "sk_live_" + UUID().uuidString
                        .replacingOccurrences(of: "-", with: "")
                        .prefix(24)
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(EPDS.orange)
                .padding(.horizontal, 14)
                .padding(.vertical, 13)
                .background(EPDS.orange.opacity(0.12))
                .cornerRadius(EPDS.radius)
                .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.orange.opacity(0.35), lineWidth: 1))
            }
            Text("Used to verify the authenticity of webhook payloads")
                .font(.system(size: 12))
                .foregroundColor(EPDS.label)
        }
    }
}

// MARK: - Delivery Settings

struct EPDelivery: View {
    @Binding var endpoint: EPEndpoint
    var body: some View {
        VStack(spacing: 18) {
            HStack {
                Toggle("", isOn: $endpoint.retryOnFailure)
                    .toggleStyle(EPPillToggle())
                Text("Retry on failure")
                    .font(.system(size: 16))
                    .foregroundColor(EPDS.text)
                Spacer()
            }
            HStack {
                Text("Max retries")
                    .font(.system(size: 14))
                    .foregroundColor(EPDS.label)
                Spacer()
                EPStepper(value: $endpoint.maxRetries, range: 0...20)
            }
            HStack {
                Text("Timeout")
                    .font(.system(size: 14))
                    .foregroundColor(EPDS.label)
                Spacer()
                HStack(spacing: 8) {
                    EPStepper(value: $endpoint.timeout, range: 1...60)
                    Text("sec")
                        .font(.system(size: 13))
                        .foregroundColor(EPDS.label)
                }
            }
        }
    }
}

struct EPPillToggle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button { configuration.isOn.toggle() } label: {
            ZStack(alignment: configuration.isOn ? .trailing : .leading) {
                Capsule()
                    .fill(configuration.isOn ? EPDS.accent : EPDS.border)
                    .frame(width: 48, height: 28)
                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .padding(3)
                    .shadow(color: .black.opacity(0.2), radius: 2)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
    }
}

struct EPStepper: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    var body: some View {
        HStack(spacing: 0) {
            Button { if value > range.lowerBound { value -= 1 } } label: {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(EPDS.label)
                    .frame(width: 32, height: 36)
            }
            Text("\(value)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(EPDS.text)
                .frame(minWidth: 28)
            Button { if value < range.upperBound { value += 1 } } label: {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(EPDS.label)
                    .frame(width: 32, height: 36)
            }
        }
        .background(EPDS.card)
        .cornerRadius(EPDS.radius)
        .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.border, lineWidth: 1))
    }
}

// MARK: - Status

struct EPStatusSection: View {
    @Binding var endpoint: EPEndpoint
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            EPRadio(label: "Active",   selected: endpoint.status == .active)   { endpoint.status = .active }
            EPRadio(label: "Disabled", selected: endpoint.status == .disabled) { endpoint.status = .disabled }
        }
    }
}

// MARK: - Bottom Buttons

struct EPBottomButtons: View {
    let isSaving:  Bool
    let onDismiss: () -> Void
    let onSave:    () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button("Cancel") { onDismiss() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(EPDS.text)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(EPDS.card)
                .cornerRadius(EPDS.radius)
                .overlay(RoundedRectangle(cornerRadius: EPDS.radius).stroke(EPDS.border, lineWidth: 1))
                .disabled(isSaving)

            Button(action: onSave) {
                ZStack {
                    Text("Save Endpoint")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .opacity(isSaving ? 0 : 1)
                    if isSaving {
                        ProgressView().tint(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color(epHex: "#7C6FFF"), Color(epHex: "#5A4FE0")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .opacity(isSaving ? 0.6 : 1)
                )
                .cornerRadius(EPDS.radius)
                .shadow(color: EPDS.accent.opacity(0.4), radius: 10, y: 4)
            }
            .disabled(isSaving)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
        .padding(.top, 12)
        .background(
            EPDS.bg.overlay(
                Divider().background(EPDS.border),
                alignment: .top
            )
        )
    }
}

// MARK: - Preview

#Preview {
    EditWebhooksView()
}
