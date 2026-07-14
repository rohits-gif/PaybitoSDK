//
//  WebhooksView+Integrated.swift
//

import SwiftUI

// MARK: - Debug Helper
private func printWebhookDebug(_ message: String) {
    #if DEBUG
    debugPrint(message)
    #endif
}

// MARK: - Safe Hex Color Helper
private func whColor(_ hex: String) -> Color {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let r, g, b, a: UInt64
    switch hex.count {
    case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
    case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default: (r, g, b, a) = (0, 0, 0, 255)
    }
    return Color(.sRGB,
                 red: Double(r) / 255,
                 green: Double(g) / 255,
                 blue: Double(b) / 255,
                 opacity: Double(a) / 255)
}

// MARK: - Color Palette
enum WH {
    static let bgPrimary     = whColor("0D1117")
    static let bgCard        = whColor("161B22")
    static let bgCardInner   = whColor("1C2333")
    static let accentPurple  = whColor("8B5CF6")
    static let accentCyan    = whColor("00D4AA")
    static let textPrimary   = whColor("E6EDF3")
    static let textSecondary = whColor("8B949E")
    static let textLink      = whColor("7C6FF7")
    static let borderColor   = whColor("21262D")
    static let dangerRed     = whColor("F85149")
    static let activeGreen   = whColor("3FB950")
    static let activeBg      = whColor("1A3A26")
    static let logsBg        = whColor("1A3A2E")
    static let endpointBg    = whColor("1E2A4A")
    static let tagBg         = whColor("21262D")
    static let emptyText     = whColor("484F58")
    static let btnPurpleTop  = whColor("9B6FFA")
    static let btnPurpleBot  = whColor("7C3AED")
}

// MARK: - Main View
struct WebhooksIntegratedView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var webhookViewModel = WHEndpointViewModel(
        merchantId: UserDefaults.standard.integer(forKey: "BmerchantId")
    )

    @State private var fromDate        = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
    @State private var toDate          = Date()
    @State private var showAddEndpoint = false
    @State private var viewedEndpoint: WHEndpointDisplayItem? = nil
    @State private var editedEndpoint: WHEndpointDisplayItem? = nil

    private let hPad: CGFloat = 16

    var body: some View {
        ZStack {
            WH.bgPrimary.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    webhookHeaderBar
                    VStack(spacing: 14) {
                        webhookEndpointsCard
                        webhookDeliveryLogsCard
                    }
                    .padding(.horizontal, hPad)
                    .padding(.top, 16)
                    .padding(.bottom, 110)
                }
            }
        }
        
        
        .sheet(isPresented: $showAddEndpoint) {
            AddEndpointSheet(
                onSave: { _ in
                    webhookViewModel.loadWebhookEndpointsFromAPI()
                },
                merchantId: webhookViewModel.merchantId    // ✅ must be here
            )
        }
        .sheet(item: $viewedEndpoint) { ep in
            WHEndpointDetailView(endpoint: ep)
        }
        .sheet(item: $editedEndpoint) { ep in
            WHEndpointEditSheetView(endpoint: ep, onSaved: {
                webhookViewModel.loadWebhookEndpointsFromAPI()
            })
        }
        
        
        .alert("Error", isPresented: $webhookViewModel.showErrorAlertFlag) {
            Button("Retry") { webhookViewModel.retryFetchingWebhookEndpoints() }
            Button("Dismiss", role: .cancel) {}
        } message: {
            Text(webhookViewModel.activeAlertMessage ?? "Something went wrong.")
        }
        .onAppear {
            printWebhookDebug("👁️ [WebhooksIntegratedView] onAppear — triggering initial load")
            webhookViewModel.loadWebhookEndpointsFromAPI()
        }
    }

    // MARK: - Header Bar
    private var webhookHeaderBar: some View {
        HStack(alignment: .center, spacing: 10) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(WH.textPrimary)
                    .frame(width: 36, height: 36)
                    .background(WH.bgCard)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(WH.borderColor, lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Webhooks")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(WH.textPrimary)
                Text("Real-time payment & subscription events")
                    .font(.system(size: 11))
                    .foregroundColor(WH.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 4)

            Button(action: { showAddEndpoint = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                    Text("Add Endpoint")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    LinearGradient(
                        colors: [WH.btnPurpleTop, WH.btnPurpleBot],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, hPad)
        .padding(.top, 16)
        .padding(.bottom, 10)
    }

    // MARK: - Endpoints Card
    private var webhookEndpointsCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(WH.endpointBg)
                        .frame(width: 44, height: 44)
                    Image(systemName: "point.3.connected.trianglepath.dotted")
                        .font(.system(size: 18))
                        .foregroundColor(WH.accentPurple)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Endpoints")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(WH.textPrimary)
                    Text(webhookEndpointsSubtitle)
                        .font(.system(size: 12))
                        .foregroundColor(WH.textSecondary)
                }
                Spacer()

                Button(action: {
                    printWebhookDebug("🔄 [WebhooksIntegratedView] Manual refresh tapped")
                    webhookViewModel.retryFetchingWebhookEndpoints()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(WH.textSecondary)
                        .rotationEffect(.degrees(webhookViewModel.isFetchingEndpoints ? 360 : 0))
                        .animation(
                            webhookViewModel.isFetchingEndpoints
                                ? .linear(duration: 0.8).repeatForever(autoreverses: false)
                                : .default,
                            value: webhookViewModel.isFetchingEndpoints
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            whDivider
            webhookEndpointsContentArea
        }
        .frame(maxWidth: .infinity)
        .background(WH.bgCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
    }

    @ViewBuilder
    private var webhookEndpointsContentArea: some View {
        switch webhookViewModel.viewState {
        case .loadingEndpoints:
            webhookLoadingSkeletonView

        case .emptyEndpoints:
            Text("No endpoints configured")
                .font(.system(size: 14))
                .foregroundColor(WH.emptyText)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)

        case .failedToLoad(let msg):
            webhookErrorStateView(message: msg)

        case .loadedEndpoints, .idle:
            if webhookViewModel.displayEndpoints.isEmpty {
                Text("No endpoints yet")
                    .font(.system(size: 14))
                    .foregroundColor(WH.emptyText)
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(Array(webhookViewModel.displayEndpoints.enumerated()), id: \.element.id) { idx, ep in
                    webhookEndpointRowView(endpoint: ep, index: idx)
                    if idx < webhookViewModel.displayEndpoints.count - 1 {
                        whDivider.padding(.horizontal, 16)
                    }
                }
            }
        }
    }

    // MARK: - Endpoint Row
    private func webhookEndpointRowView(endpoint: WHEndpointDisplayItem, index: Int) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 5) {
                Text(endpoint.url)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(WH.textLink)
                    .lineLimit(1)
                HStack(spacing: 4) {
                    Text(endpoint.eventType)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(WH.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(WH.tagBg)
                        .cornerRadius(5)
                    Text("·  \(endpoint.eventCount) events")
                        .font(.system(size: 11))
                        .foregroundColor(WH.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text(endpoint.isActive ? "Active" : "Inactive")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(endpoint.isActive ? WH.activeGreen : WH.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(endpoint.isActive ? WH.activeBg : WH.bgCardInner)
                .cornerRadius(16)

            HStack(spacing: 14) {
                Button(action: {
                    printWebhookDebug("👁️ [WebhooksIntegratedView] View tapped — epId: \(endpoint.id)")
                    viewedEndpoint = endpoint
                }) {
                    Image(systemName: "eye")
                        .font(.system(size: 14))
                        .foregroundColor(WH.textSecondary)
                }

                Button(action: {
                    printWebhookDebug("✏️ [WebhooksIntegratedView] Edit tapped — epId: \(endpoint.id)")
                    editedEndpoint = endpoint
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14))
                        .foregroundColor(WH.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Loading Skeleton
    private var webhookLoadingSkeletonView: some View {
        VStack(spacing: 0) {
            ForEach(0..<2, id: \.self) { _ in
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 6) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(WH.bgCardInner)
                            .frame(width: 140, height: 14)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(WH.bgCardInner)
                            .frame(width: 80, height: 11)
                    }
                    Spacer()
                    RoundedRectangle(cornerRadius: 10)
                        .fill(WH.bgCardInner)
                        .frame(width: 56, height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .shimmerEffect()
            }
        }
    }

    // MARK: - Error State
    private func webhookErrorStateView(message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 28))
                .foregroundColor(WH.dangerRed)
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(WH.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: { webhookViewModel.retryFetchingWebhookEndpoints() }) {
                Text("Retry")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(WH.accentPurple)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Delivery Logs Card
    private var webhookDeliveryLogsCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(WH.logsBg)
                        .frame(width: 44, height: 44)
                    Image(systemName: "info.circle")
                        .font(.system(size: 18))
                        .foregroundColor(WH.accentCyan)
                }
                Text("Delivery Logs")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(WH.textPrimary)
                Spacer()
                Menu {
                    Button("All endpoints") {
                        webhookViewModel.resetEndpointFilter()
                    }
                    ForEach(webhookViewModel.displayEndpoints) { ep in
                        Button(ep.url) {
                            webhookViewModel.applyEndpointFilter(ep.url)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(webhookViewModel.selectedEndpointFilter)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(WH.textPrimary)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(WH.textSecondary)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(WH.bgCardInner)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(WH.borderColor, lineWidth: 1))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            HStack(spacing: 8) {
                Text("From").font(.system(size: 12)).foregroundColor(WH.textSecondary).fixedSize()
                webhookDatePickerPill(selection: $fromDate)
                Text("To").font(.system(size: 12)).foregroundColor(WH.textSecondary).fixedSize()
                webhookDatePickerPill(selection: $toDate)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 14)

            whDivider

            Text("No delivery logs")
                .font(.system(size: 14))
                .foregroundColor(WH.emptyText)
                .padding(.vertical, 36)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .background(WH.bgCard)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
    }

    private func webhookDatePickerPill(selection: Binding<Date>) -> some View {
        DatePicker("", selection: selection, displayedComponents: .date)
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(WH.accentPurple)
            .colorScheme(.dark)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(WH.bgCardInner)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(WH.borderColor, lineWidth: 1))
    }

    // MARK: - Helpers
    private var webhookEndpointsSubtitle: String {
        switch webhookViewModel.viewState {
        case .loadingEndpoints: return "Loading..."
        case .loadedEndpoints:
            let count = webhookViewModel.displayEndpoints.count
            return "\(count) endpoint\(count == 1 ? "" : "s")"
        case .failedToLoad:     return "Failed to load"
        case .emptyEndpoints:   return "No endpoints"
        case .idle:             return "—"
        }
    }

    private var whDivider: some View {
        Rectangle().fill(WH.borderColor).frame(height: 1)
    }
}

// MARK: - Shimmer Modifier
private struct WHShimmerModifier: ViewModifier {
    @State private var shimmerPhase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.06),
                        Color.white.opacity(0)
                    ]),
                    startPoint: UnitPoint(x: shimmerPhase, y: 0),
                    endPoint: UnitPoint(x: shimmerPhase + 0.5, y: 0)
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        shimmerPhase = 1.5
                    }
                }
            )
    }
}

extension View {
    fileprivate func shimmerEffect() -> some View {
        self.modifier(WHShimmerModifier())
    }
}

// MARK: - Endpoint Detail Sheet
struct WHEndpointDetailView: View {
    let endpoint: WHEndpointDisplayItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            WH.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Endpoint Details")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(WH.textPrimary)
                        Text("Read-only view")
                            .font(.system(size: 12))
                            .foregroundColor(WH.textSecondary)
                    }
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(WH.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        // Status Banner
                        HStack(spacing: 10) {
                            Circle()
                                .fill(endpoint.isActive ? WH.activeGreen : WH.dangerRed)
                                .frame(width: 8, height: 8)
                            Text(endpoint.isActive ? "Active" : "Inactive")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(endpoint.isActive ? WH.activeGreen : WH.dangerRed)
                            Spacer()
                            Text("Webhook")
                                .font(.system(size: 12))
                                .foregroundColor(WH.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(WH.bgCardInner)
                                .cornerRadius(8)
                        }
                        .padding(14)
                        .background(endpoint.isActive ? WH.activeBg.opacity(0.4) : WH.dangerRed.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(endpoint.isActive ? WH.activeGreen.opacity(0.3) : WH.dangerRed.opacity(0.3), lineWidth: 1)
                        )

                        // Main Info Card
                        VStack(spacing: 0) {
                            whDetailRow(icon: "link",             label: "Endpoint URL",   value: endpoint.url,                                                    valueColor: WH.textLink)
                            whRowDivider
                            whDetailRow(icon: "tag",              label: "Events Mode",    value: endpoint.eventType,                                              valueColor: WH.textPrimary)
                            whRowDivider
                            whDetailRow(icon: "doc.text",         label: "Description",    value: endpoint.description.isEmpty ? "—" : endpoint.description,       valueColor: WH.textPrimary)
                            whRowDivider
                            whDetailRow(icon: "checkmark.shield", label: "Status",         value: endpoint.isActive ? "Active" : "Inactive",                       valueColor: endpoint.isActive ? WH.activeGreen : WH.dangerRed)
                            whRowDivider
                            whDetailRow(icon: "arrow.triangle.2.circlepath", label: "Retry Enabled", value: endpoint.retryEnabled ? "Yes (max \(endpoint.maxRetries))" : "No", valueColor: WH.textPrimary)
                            whRowDivider
                            whDetailRow(icon: "clock",            label: "Timeout",        value: "\(endpoint.timeoutSec)s",                                       valueColor: WH.textPrimary)
                            whRowDivider
                            whDetailRow(icon: "list.bullet",      label: "Event Count",    value: "\(endpoint.eventCount)",                                        valueColor: WH.textPrimary)
                        }
                        .background(WH.bgCard)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))

                        // Events List Card
                        if !endpoint.events.isEmpty {
                            VStack(spacing: 0) {
                                HStack {
                                    Image(systemName: "bolt")
                                        .font(.system(size: 13))
                                        .foregroundColor(WH.accentPurple)
                                    Text("Subscribed Events")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(WH.textSecondary)
                                    Spacer()
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                whRowDivider
                                FlowLayoutView(items: endpoint.events)
                                    .padding(14)
                            }
                            .background(WH.bgCard)
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
                        }

                        // ID Card
                        VStack(spacing: 0) {
                            whDetailRow(icon: "number",     label: "Endpoint ID",  value: "ep_\(endpoint.id)",      valueColor: WH.textSecondary)
                            whRowDivider
                            whDetailRow(icon: "building.2", label: "Merchant ID",  value: "\(endpoint.merchantId)", valueColor: WH.textSecondary)
                        }
                        .background(WH.bgCard)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }

    private func whDetailRow(icon: String, label: String, value: String, valueColor: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(WH.accentPurple)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(WH.textSecondary)
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(valueColor)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var whRowDivider: some View {
        Rectangle().fill(WH.borderColor).frame(height: 1).padding(.horizontal, 16)
    }
}

// MARK: - Flow Layout for Event Tags
struct FlowLayoutView: View {
    let items: [String]
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 6)], spacing: 6) {
            ForEach(items, id: \.self) { item in
                Text(item)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(WH.accentCyan)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(WH.bgCardInner)
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(WH.accentCyan.opacity(0.25), lineWidth: 1))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

// MARK: - Edit Sheet
struct WHEndpointEditSheetView: View {
    let endpoint: WHEndpointDisplayItem
    let onSaved:  () -> Void

    var body: some View {
        EditWebhooksView(endpoint: endpoint, onSaved: onSaved)
    }
}

// MARK: - Preview
struct WebhooksIntegratedView_Previews: PreviewProvider {
    static var previews: some View {
        WebhooksIntegratedView()
            .preferredColorScheme(.dark)
    }
}








//import SwiftUI
//
//// MARK: - Models
//struct WebhookEndpoint: Identifiable {
//    let id = UUID()
//    let url: String
//    let description: String
//    var isActive: Bool
//    var eventType: String { description.isEmpty ? "All events" : description }
//}
//
//// MARK: - Safe Hex Color Helper
//private func whColor(_ hex: String) -> Color {
//    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//    var int: UInt64 = 0
//    Scanner(string: hex).scanHexInt64(&int)
//    let r, g, b, a: UInt64
//    switch hex.count {
//    case 6: (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
//    case 8: (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//    default: (r, g, b, a) = (0, 0, 0, 255)
//    }
//    return Color(.sRGB,
//                 red: Double(r) / 255,
//                 green: Double(g) / 255,
//                 blue: Double(b) / 255,
//                 opacity: Double(a) / 255)
//}
//
//// MARK: - Color Palette
//enum WH {
//    static let bgPrimary     = whColor("0D1117")
//    static let bgCard        = whColor("161B22")
//    static let bgCardInner   = whColor("1C2333")
//    static let accentPurple  = whColor("8B5CF6")
//    static let accentCyan    = whColor("00D4AA")
//    static let textPrimary   = whColor("E6EDF3")
//    static let textSecondary = whColor("8B949E")
//    static let textLink      = whColor("7C6FF7")
//    static let borderColor   = whColor("21262D")
//    static let dangerRed     = whColor("F85149")
//    static let activeGreen   = whColor("3FB950")
//    static let activeBg      = whColor("1A3A26")
//    static let logsBg        = whColor("1A3A2E")
//    static let endpointBg    = whColor("1E2A4A")
//    static let tagBg         = whColor("21262D")
//    static let emptyText     = whColor("484F58")
//    static let fabBlueTop    = whColor("3BA7F5")
//    static let fabBlueBot    = whColor("0D85E8")
//    static let btnPurpleTop  = whColor("9B6FFA")
//    static let btnPurpleBot  = whColor("7C3AED")
//    static let orange        = whColor("F59E0B")
//    static let orangeBg      = whColor("2D1F07")
//}
//
//// MARK: - Main View
//struct WebhooksView: View {
//    @Environment(\.dismiss) private var dismiss
//
//    @State private var endpoints: [WebhookEndpoint] = [
//        WebhookEndpoint(url: "google.com", description: "All events", isActive: true),
//        WebhookEndpoint(url: "google.com", description: "All events", isActive: true)
//    ]
//    @State private var fromDate         = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
//    @State private var toDate           = Date()
//    @State private var selectedEndpoint = "All endpoints"
//    @State private var showAddEndpoint  = false
//    @State private var viewEndpoint: WebhookEndpoint? = nil
//    @State private var editEndpoint: WebhookEndpoint? = nil
//
//    private let hPad: CGFloat = 16
//    
//    
//
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            WH.bgPrimary.ignoresSafeArea()
//
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    headerBar
//                    VStack(spacing: 14) {
//                        endpointsCard
//                        deliveryLogsCard
//                    }
//                    .padding(.horizontal, hPad)
//                    .padding(.top, 16)
//                    .padding(.bottom, 110)
//                }
//            }
//
//           // fabButton
//        }
//        // Add new endpoint
//        .sheet(isPresented: $showAddEndpoint) {
//            AddEndpointSheet(onSave: { ep in endpoints.append(ep) })
//        }
//        // Eye → ViewWebhookView (read-only)
//        .sheet(item: $viewEndpoint) { ep in
//            ViewWebhookView(endpoint: ep)
//        }
//        // Pencil → Edit mode
//        .sheet(item: $editEndpoint) { ep in
//            EditWebhooksView(endpoint: ep)
//        }
//
//    }
//
//    // MARK: - Header
//    private var headerBar: some View {
//        HStack(alignment: .center, spacing: 10) {
//            Button(action: { dismiss() }) {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 16, weight: .semibold))
//                    .foregroundColor(WH.textPrimary)
//                    .frame(width: 36, height: 36)
//                    .background(WH.bgCard)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(WH.borderColor, lineWidth: 1))
//            }
//
//            VStack(alignment: .leading, spacing: 2) {
//                Text("Webhooks")
//                    .font(.system(size: 20, weight: .bold))
//                    .foregroundColor(WH.textPrimary)
//                Text("Real-time payment & subscription events")
//                    .font(.system(size: 11))
//                    .foregroundColor(WH.textSecondary)
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.75)
//            }
//
//            Spacer(minLength: 4)
//            
//           
//
//            Button(action: { showAddEndpoint = true }) {
//                HStack(spacing: 4) {
//                    Image(systemName: "plus")
//                        .font(.system(size: 11, weight: .bold))
//                    Text("Add Endpoint")
//                        .font(.system(size: 12, weight: .semibold))
//                }
//                .foregroundColor(.white)
//                .padding(.horizontal, 12)
//                .padding(.vertical, 8)
//                .background(
//                    LinearGradient(
//                        colors: [WH.btnPurpleTop, WH.btnPurpleBot],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                )
//                .cornerRadius(20)
//            }
//        }
//        .padding(.horizontal, hPad)
//        .padding(.top, 16)
//        .padding(.bottom, 10)
//    }
//
//    // MARK: - Endpoints Card
//    private var endpointsCard: some View {
//        VStack(spacing: 0) {
//            HStack(spacing: 12) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(WH.endpointBg)
//                        .frame(width: 44, height: 44)
//                    Image(systemName: "point.3.connected.trianglepath.dotted")
//                        .font(.system(size: 18))
//                        .foregroundColor(WH.accentPurple)
//                }
//                VStack(alignment: .leading, spacing: 2) {
//                    Text("Endpoints")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(WH.textPrimary)
//                    Text("\(endpoints.count) endpoint\(endpoints.count == 1 ? "" : "s")")
//                        .font(.system(size: 12))
//                        .foregroundColor(WH.textSecondary)
//                }
//                Spacer()
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 14)
//
//            dividerLine
//
//            if endpoints.isEmpty {
//                Text("No endpoints yet")
//                    .font(.system(size: 14))
//                    .foregroundColor(WH.emptyText)
//                    .padding(.vertical, 24)
//                    .frame(maxWidth: .infinity)
//            } else {
//                ForEach(Array(endpoints.enumerated()), id: \.element.id) { idx, ep in
//                    endpointRow(endpoint: ep, index: idx)
//                    if idx < endpoints.count - 1 {
//                        dividerLine.padding(.horizontal, 16)
//                    }
//                }
//            }
//        }
//        .frame(maxWidth: .infinity)
//        .background(WH.bgCard)
//        .cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
//    }
//
//    private func endpointRow(endpoint: WebhookEndpoint, index: Int) -> some View {
//        HStack(spacing: 8) {
//            VStack(alignment: .leading, spacing: 5) {
//                Text(endpoint.url)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(WH.textLink)
//                    .lineLimit(1)
//                HStack(spacing: 4) {
//                    Text(endpoint.eventType)
//                        .font(.system(size: 11, weight: .medium))
//                        .foregroundColor(WH.textSecondary)
//                        .padding(.horizontal, 8)
//                        .padding(.vertical, 3)
//                        .background(WH.tagBg)
//                        .cornerRadius(5)
//                    Text("—")
//                        .font(.system(size: 11))
//                        .foregroundColor(WH.textSecondary)
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            Text(endpoint.isActive ? "Active" : "Inactive")
//                .font(.system(size: 11, weight: .semibold))
//                .foregroundColor(endpoint.isActive ? WH.activeGreen : WH.textSecondary)
//                .padding(.horizontal, 10)
//                .padding(.vertical, 4)
//                .background(endpoint.isActive ? WH.activeBg : WH.bgCardInner)
//                .cornerRadius(16)
//
//            HStack(spacing: 14) {
//                // 👁 Eye → ViewWebhookView
//                Button(action: { viewEndpoint = endpoint }) {
//                    Image(systemName: "eye")
//                        .font(.system(size: 14))
//                        .foregroundColor(WH.textSecondary)
//                }
//                // ✏️ Pencil → AddEndpointSheet (edit mode)
//                Button(action: { editEndpoint = endpoint }) {
//                    Image(systemName: "pencil")
//                        .font(.system(size: 14))
//                        .foregroundColor(WH.textSecondary)
//                }
//                // 🗑 Trash → delete
//                Button(action: { endpoints.remove(at: index) }) {
//                    Image(systemName: "trash")
//                        .font(.system(size: 14))
//                        .foregroundColor(WH.dangerRed)
//                }
//            }
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//    }
//
//    // MARK: - Delivery Logs Card
//    private var deliveryLogsCard: some View {
//        VStack(spacing: 0) {
//            HStack(spacing: 12) {
//                ZStack {
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(WH.logsBg)
//                        .frame(width: 44, height: 44)
//                    Image(systemName: "info.circle")
//                        .font(.system(size: 18))
//                        .foregroundColor(WH.accentCyan)
//                }
//                Text("Delivery Logs")
//                    .font(.system(size: 16, weight: .bold))
//                    .foregroundColor(WH.textPrimary)
//                Spacer()
//                Menu {
//                    Button("All endpoints") { selectedEndpoint = "All endpoints" }
//                    ForEach(endpoints) { ep in
//                        Button(ep.url) { selectedEndpoint = ep.url }
//                    }
//                } label: {
//                    HStack(spacing: 4) {
//                        Text(selectedEndpoint)
//                            .font(.system(size: 12, weight: .medium))
//                            .foregroundColor(WH.textPrimary)
//                            .lineLimit(1)
//                        Image(systemName: "chevron.down")
//                            .font(.system(size: 10, weight: .semibold))
//                            .foregroundColor(WH.textSecondary)
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 7)
//                    .background(WH.bgCardInner)
//                    .cornerRadius(8)
//                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(WH.borderColor, lineWidth: 1))
//                }
//            }
//            .padding(.horizontal, 16)
//            .padding(.vertical, 14)
//
//            HStack(spacing: 8) {
//                Text("From").font(.system(size: 12)).foregroundColor(WH.textSecondary).fixedSize()
//                datePill(selection: $fromDate)
//                Text("To").font(.system(size: 12)).foregroundColor(WH.textSecondary).fixedSize()
//                datePill(selection: $toDate)
//            }
//            .padding(.horizontal, 16)
//            .padding(.bottom, 14)
//
//            dividerLine
//
//            Text("No delivery logs")
//                .font(.system(size: 14))
//                .foregroundColor(WH.emptyText)
//                .padding(.vertical, 36)
//                .frame(maxWidth: .infinity)
//        }
//        .frame(maxWidth: .infinity)
//        .background(WH.bgCard)
//        .cornerRadius(14)
//        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
//    }
//
//    private func datePill(selection: Binding<Date>) -> some View {
//        DatePicker("", selection: selection, displayedComponents: .date)
//            .datePickerStyle(.compact)
//            .labelsHidden()
//            .tint(WH.accentPurple)
//            .colorScheme(.dark)
//            .frame(maxWidth: .infinity)
//            .padding(.horizontal, 10)
//            .padding(.vertical, 8)
//            .background(WH.bgCardInner)
//            .cornerRadius(8)
//            .overlay(RoundedRectangle(cornerRadius: 8).stroke(WH.borderColor, lineWidth: 1))
//    }
//
////    // MARK: - FAB
////    private var fabButton: some View {
////        Button(action: { showAddEndpoint = true }) {
////            ZStack {
////                RoundedRectangle(cornerRadius: 16)
////                    .fill(LinearGradient(colors: [WH.fabBlueTop, WH.fabBlueBot],
////                                        startPoint: .top, endPoint: .bottom))
////                    .frame(width: 56, height: 56)
////                    .shadow(color: WH.fabBlueBot.opacity(0.45), radius: 10, x: 0, y: 5)
////                Image(systemName: "plus")
////                    .font(.system(size: 20, weight: .semibold))
////                    .foregroundColor(.white)
////            }
////        }
////        .padding(.trailing, hPad)
////        .padding(.bottom, 28)
////        .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 0) }
////    }
////
//    private var dividerLine: some View {
//       Rectangle().fill(WH.borderColor).frame(height: 1)
//    }
//}
//
//// MARK: - ViewWebhookView (Read-only)
//struct ViewWebhookView: View {
//    let endpoint: WebhookEndpoint
//    @Environment(\.dismiss) private var dismiss
//
//    var body: some View {
//        ZStack {
//            WH.bgPrimary.ignoresSafeArea()
//            VStack(spacing: 0) {
//                // Header
//                HStack {
//                    VStack(alignment: .leading, spacing: 3) {
//                        Text("Endpoint Details")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundColor(WH.textPrimary)
//                        Text("Read-only view")
//                            .font(.system(size: 12))
//                            .foregroundColor(WH.textSecondary)
//                    }
//                    Spacer()
//                    Button(action: { dismiss() }) {
//                        Image(systemName: "xmark.circle.fill")
//                            .font(.system(size: 26))
//                            .foregroundColor(WH.textSecondary)
//                    }
//                    .buttonStyle(.plain)
//                }
//                .padding(.horizontal, 20)
//                .padding(.top, 24)
//                .padding(.bottom, 20)
//
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 14) {
//                        // Status banner
//                        HStack(spacing: 10) {
//                            Circle()
//                                .fill(endpoint.isActive ? WH.activeGreen : WH.dangerRed)
//                                .frame(width: 8, height: 8)
//                            Text(endpoint.isActive ? "Active" : "Inactive")
//                                .font(.system(size: 13, weight: .semibold))
//                                .foregroundColor(endpoint.isActive ? WH.activeGreen : WH.dangerRed)
//                            Spacer()
//                            Text("Webhook")
//                                .font(.system(size: 12))
//                                .foregroundColor(WH.textSecondary)
//                                .padding(.horizontal, 10)
//                                .padding(.vertical, 4)
//                                .background(WH.bgCardInner)
//                                .cornerRadius(8)
//                        }
//                        .padding(14)
//                        .background(endpoint.isActive ? WH.activeBg.opacity(0.4) : WH.dangerRed.opacity(0.08))
//                        .cornerRadius(12)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 12)
//                                .stroke(endpoint.isActive ? WH.activeGreen.opacity(0.3) : WH.dangerRed.opacity(0.3), lineWidth: 1)
//                        )
//
//                        // Info card
//                        VStack(spacing: 0) {
//                            detailRow(icon: "link",             label: "Endpoint URL", value: endpoint.url,         valueColor: WH.textLink)
//                            vDivider
//                            detailRow(icon: "tag",              label: "Events",       value: endpoint.eventType,   valueColor: WH.textPrimary)
//                            vDivider
//                            detailRow(icon: "doc.text",         label: "Description",
//                                      value: endpoint.description.isEmpty ? "—" : endpoint.description,
//                                      valueColor: WH.textPrimary)
//                            vDivider
//                            detailRow(icon: "checkmark.shield", label: "Status",
//                                      value: endpoint.isActive ? "Active" : "Inactive",
//                                      valueColor: endpoint.isActive ? WH.activeGreen : WH.dangerRed)
//                        }
//                        .background(WH.bgCard)
//                        .cornerRadius(14)
//                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
//
//                        // ID card
//                        VStack(spacing: 0) {
//                            detailRow(icon: "number", label: "Endpoint ID",
//                                      value: String(endpoint.id.uuidString.prefix(18)).lowercased() + "…",
//                                      valueColor: WH.textSecondary)
//                        }
//                        .background(WH.bgCard)
//                        .cornerRadius(14)
//                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(WH.borderColor, lineWidth: 1))
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 30)
//                }
//            }
//        }
//        .presentationDetents([.medium, .large])
//        .presentationDragIndicator(.visible)
//        .presentationCornerRadius(20)
//    }
//
//    private func detailRow(icon: String, label: String, value: String, valueColor: Color) -> some View {
//        HStack(spacing: 14) {
//            Image(systemName: icon)
//                .font(.system(size: 14))
//                .foregroundColor(WH.accentPurple)
//                .frame(width: 20)
//            VStack(alignment: .leading, spacing: 3) {
//                Text(label)
//                    .font(.system(size: 11, weight: .medium))
//                    .foregroundColor(WH.textSecondary)
//                Text(value)
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(valueColor)
//                    .lineLimit(2)
//            }
//            Spacer()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 14)
//    }
//
//    private var vDivider: some View {
//        Rectangle().fill(WH.borderColor).frame(height: 1).padding(.horizontal, 16)
//    }
//}
//
//// MARK: - Preview
//struct WebhooksView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            WebhooksView()
//                .previewDevice("iPhone SE (3rd generation)")
//                .previewDisplayName("SE")
//            WebhooksView()
//                .previewDevice("iPhone 15 Pro")
//                .previewDisplayName("15 Pro")
//        }
//        .preferredColorScheme(.dark)
//    }
//}
