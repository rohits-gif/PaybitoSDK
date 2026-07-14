import SwiftUI

// MARK: - Theme
private enum WHTheme {
    static let darkBg        = Color(red: 0.09, green: 0.10, blue: 0.13)
    static let cardBg        = Color(red: 0.13, green: 0.15, blue: 0.19)
    static let fieldBg       = Color(red: 0.11, green: 0.13, blue: 0.16)
    static let iconCircleBg  = Color(red: 0.16, green: 0.18, blue: 0.24)
    static let closeBtnBg    = Color(red: 0.18, green: 0.20, blue: 0.25)
    static let xCircleBg     = Color(red: 0.20, green: 0.22, blue: 0.28)
    static let dividerColor  = Color(red: 0.20, green: 0.22, blue: 0.28)
    static let purple        = Color(red: 0.52, green: 0.40, blue: 0.95)
    static let purpleLight   = Color(red: 0.75, green: 0.55, blue: 1.00)
    static let purpleGradA   = Color(red: 0.60, green: 0.42, blue: 1.00)
    static let purpleGradB   = Color(red: 0.42, green: 0.28, blue: 0.88)
    static let green         = Color(red: 0.20, green: 0.75, blue: 0.45)
    static let labelGray     = Color(red: 0.55, green: 0.58, blue: 0.65)
    static let textMain      = Color(red: 0.92, green: 0.93, blue: 0.95)
    static let textMuted     = Color(red: 0.70, green: 0.72, blue: 0.78)
}

// MARK: - Model
struct WHEndpoint {
    var endpointID: String    = "#499"
    var endpointURL: String   = "google.com"
    var active: Bool          = true
    var eventsMode: String    = "All events"
    var retryOnFailure: Bool  = true
    var maxRetries: Int       = 5
    var timeoutSeconds: Int   = 5
    var signingSecret: String? = nil
}

// MARK: - Main View
struct ViewWebhooksView: View {

    @State private var endpoint      = WHEndpoint()
    @State private var sheetVisible  = true
    @State private var urlCopied     = false
    @State private var secretCopied  = false

    var body: some View {
        ZStack {
            WHTheme.darkBg.ignoresSafeArea()

            VStack(spacing: 0) {
                navHeader

                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(WHTheme.cardBg)

                    VStack(spacing: 0) {
                        dragPill

                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                sheetTitle

                                Divider()
                                    .background(WHTheme.dividerColor)
                                    .padding(.horizontal, 20)

                                VStack(spacing: 22) {
                                    urlField
                                    statusRow
                                    configCard
                                    eventsField
                                    secretField
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 24)
                                .padding(.bottom, 16)

                                dismissButton
                                    .padding(.horizontal, 20)
                                    .padding(.bottom, 32)
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
    }

    // MARK: Nav Header
    private var navHeader: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(WHTheme.textMain)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Webhooks")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(WHTheme.textMain)
                Text("Receive real-time payment and\nsubscription events.")
                    .font(.system(size: 12))
                    .foregroundColor(WHTheme.labelGray)
                    .lineLimit(2)
            }

            Spacer()

            Button(action: {}) {
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                    Text("Add Endpoint")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(
                        colors: [WHTheme.purpleGradA, WHTheme.purpleGradB],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 56)
        .padding(.bottom, 12)
    }

    // MARK: Drag Pill
    private var dragPill: some View {
        Capsule()
            .fill(WHTheme.labelGray.opacity(0.4))
            .frame(width: 36, height: 4)
            .padding(.top, 12)
            .padding(.bottom, 8)
    }

    // MARK: Sheet Title
    private var sheetTitle: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(WHTheme.iconCircleBg)
                    .frame(width: 52, height: 52)
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [WHTheme.purple, WHTheme.purpleLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("Endpoint Details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(WHTheme.textMain)
                Text("ID: \(endpoint.endpointID)")
                    .font(.system(size: 13))
                    .foregroundColor(WHTheme.labelGray)
            }

            Spacer()

            Button(action: { sheetVisible = false }) {
                ZStack {
                    Circle()
                        .fill(WHTheme.xCircleBg)
                        .frame(width: 30, height: 30)
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(WHTheme.textMuted)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    // MARK: URL Field
    private var urlField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("ENDPOINT URL")

            HStack {
                Text(endpoint.endpointURL)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundColor(WHTheme.purple)
                Spacer()
                Button(action: {
                    UIPasteboard.general.string = endpoint.endpointURL
                    urlCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { urlCopied = false }
                }) {
                    Image(systemName: urlCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(urlCopied ? WHTheme.green : WHTheme.labelGray)
                        .animation(.easeInOut(duration: 0.2), value: urlCopied)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(WHTheme.fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: Status Row
    private var statusRow: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("STATUS")
                activeBadge
            }
            VStack(alignment: .leading, spacing: 8) {
                fieldLabel("EVENTS MODE")
                Text(endpoint.eventsMode)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(WHTheme.textMain)
            }
            Spacer()
        }
    }

    private var activeBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(WHTheme.green)
                .frame(width: 7, height: 7)
            Text("Active")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(WHTheme.green)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(WHTheme.green.opacity(0.12))
        .clipShape(Capsule())
    }

    // MARK: Config Card
    private var configCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("CONFIGURATION")

            VStack(spacing: 0) {
                configRow("Retry on Failure", value: endpoint.retryOnFailure ? "Enabled" : "Disabled", divider: true)
                configRow("Max Retries",      value: "\(endpoint.maxRetries)",                           divider: true)
                configRow("Timeout",          value: "\(endpoint.timeoutSeconds)s",                      divider: false)
            }
            .background(WHTheme.fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    @ViewBuilder
    private func configRow(_ label: String, value: String, divider: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(WHTheme.textMuted)
                Spacer()
                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(WHTheme.textMain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            if divider {
                Divider()
                    .background(WHTheme.dividerColor)
                    .padding(.horizontal, 16)
            }
        }
    }

    // MARK: Selected Events Field
    private var eventsField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("SELECTED EVENTS")

            HStack {
                Text("All events are enabled for this endpoint.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(WHTheme.purple)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(WHTheme.fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: Signing Secret Field
    private var secretField: some View {
        VStack(alignment: .leading, spacing: 8) {
            fieldLabel("SIGNING SECRET")

            HStack {
                Text(endpoint.signingSecret ?? "Not set")
                    .font(.system(size: 15))
                    .foregroundColor(endpoint.signingSecret == nil ? WHTheme.labelGray : WHTheme.textMain)
                Spacer()
                Button(action: {
                    guard let secret = endpoint.signingSecret else { return }
                    UIPasteboard.general.string = secret
                    secretCopied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { secretCopied = false }
                }) {
                    Image(systemName: secretCopied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(secretCopied ? WHTheme.green : WHTheme.labelGray)
                        .animation(.easeInOut(duration: 0.2), value: secretCopied)
                }
                .disabled(endpoint.signingSecret == nil)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(WHTheme.fieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: Dismiss Button
    private var dismissButton: some View {
        Button(action: { sheetVisible = false }) {
            HStack {
                Spacer()
                Text("Close")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(WHTheme.textMain)
                Spacer()
            }
            .padding(.vertical, 18)
            .background(WHTheme.closeBtnBg)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    // MARK: Helper
    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(WHTheme.labelGray)
            .tracking(0.8)
    }
}

// MARK: - Preview
#Preview {
    ViewWebhooksView()
        .preferredColorScheme(.dark)
}
