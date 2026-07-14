// MARK: - Gateway Card Views

import SwiftUI

// ─────────────────────────────────────────────
// StripeCardView
// ─────────────────────────────────────────────
struct StripeCardView: View {
    @ObservedObject var vm: GatewayCardViewModel

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ──────────────────────────────────
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(PSColor.stripeBlue.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Text("S")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(PSColor.stripeBlue)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("PayBito Apex")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PSColor.textPrimary)
                        GatewayBadge(label: "Card Payments", color: PSColor.stripeBlue)
                    }
                    Text("Accept card payments via Stripe — enter your API credentials below")
                        .font(.system(size: 12))
                        .foregroundColor(PSColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Rectangle()
                .fill(PSColor.cardBorder)
                .frame(height: 1)

            // ── Body ─────────────────────────────────────
            VStack(spacing: 18) {
                PSInfoBanner(
                    message: "Retrieve your API keys from the Stripe Dashboard → Developers → API Keys. Use pk_live_ / sk_live_ for production.",
                    accentColor: PSColor.stripeBlue
                )

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Publishable Key", required: true)
                    MonoTextField(
                        placeholder: "pk_live_xxxxxxxxxxxx",
                        text: $vm.clientId,
                        hasError: vm.clientIdError != nil,
                        icon: "key"
                    )
                    if let err = vm.clientIdError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your public-facing PayBito Apex key (safe to expose client-side)")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Secret Key", required: true)
                    SecureMonoField(
                        placeholder: "sk_live_xxxxxxxxxxxx",
                        text: $vm.clientSecret,
                        hasError: vm.clientSecretError != nil
                    )
                    if let err = vm.clientSecretError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Keep this secret — never expose in frontend code")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                Rectangle()
                    .fill(PSColor.cardBorder)
                    .frame(height: 1)

                HStack(spacing: 12) {
                    Spacer()
                    if vm.gatewayId != nil {
                        ClearKeysButton(action: vm.handleClearKeys, isDisabled: vm.isSaving)
                    }
                    PSSaveButton(action: vm.handleSave, isSaving: vm.isSaving, isSaved: vm.saveSuccess)
                }
            }
            .padding(20)
        }
        .background(PSColor.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PSColor.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 2)
        .alert(isPresented: $vm.showClearConfirm) {
            Alert(
                title: Text("Clear API Keys"),
                message: Text("Are you sure? This cannot be undone."),
                primaryButton: .destructive(Text("Clear Keys")) { vm.confirmClearKeys() },
                secondaryButton: .cancel()
            )
        }
    }
}

// ─────────────────────────────────────────────
// PayPalCardView
// ─────────────────────────────────────────────
struct PayPalCardView: View {
    @ObservedObject var vm: GatewayCardViewModel

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ──────────────────────────────────
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(PSColor.paypalBlue.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: "p.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(PSColor.paypalBlue)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("PayBito Titan")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PSColor.textPrimary)
                        GatewayBadge(label: "PayPal Payments", color: PSColor.paypalBlue)
                    }
                    Text("Accept PayPal payments — enter your PayPal REST API credentials")
                        .font(.system(size: 12))
                        .foregroundColor(PSColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Rectangle()
                .fill(PSColor.cardBorder)
                .frame(height: 1)

            // ── Body ─────────────────────────────────────
            VStack(spacing: 18) {
                PSInfoBanner(
                    message: "Retrieve your credentials from PayPal Developer Dashboard → My Apps & Credentials. Create a REST API app to get your Client ID and Secret.",
                    accentColor: PSColor.paypalBlue
                )

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Client ID", required: true)
                    MonoTextField(
                        placeholder: "AXxxxxxxxxxxxxxxxxxxxx",
                        text: $vm.clientId,
                        hasError: vm.clientIdError != nil,
                        icon: "number"
                    )
                    if let err = vm.clientIdError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your PayBito Titan REST API Client ID")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Secret Key", required: true)
                    SecureMonoField(
                        placeholder: "EKxxxxxxxxxxxxxxxxxxxx",
                        text: $vm.clientSecret,
                        hasError: vm.clientSecretError != nil
                    )
                    if let err = vm.clientSecretError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your PayBito Titan REST API Secret — keep this confidential")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                Rectangle()
                    .fill(PSColor.cardBorder)
                    .frame(height: 1)

                HStack(spacing: 12) {
                    Spacer()
                    if vm.gatewayId != nil {
                        ClearKeysButton(action: vm.handleClearKeys, isDisabled: vm.isSaving)
                    }
                    PSSaveButton(action: vm.handleSave, isSaving: vm.isSaving, isSaved: vm.saveSuccess)
                }
            }
            .padding(20)
        }
        .background(PSColor.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PSColor.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 2)
        .alert(isPresented: $vm.showClearConfirm) {
            Alert(
                title: Text("Clear API Keys"),
                message: Text("Are you sure? This cannot be undone."),
                primaryButton: .destructive(Text("Clear Keys")) { vm.confirmClearKeys() },
                secondaryButton: .cancel()
            )
        }
    }
}

// ─────────────────────────────────────────────
// SecretV4GatewayCardView
// Drives KurvPay (Nexus) / HostMerchantServices (Nova) / NMI (Zenith) — same shape.
// ─────────────────────────────────────────────
struct SecretV4GatewayCardView: View {
    @ObservedObject var vm: SecretV4GatewayViewModel
    let accentColor: Color
    let portalName: String   // e.g. "PayBito Nexus Merchant Portal"
    let badgeLabel: String = "Card Payments"
    let iconText: String = "⚡"

    var body: some View {
        VStack(spacing: 0) {

            // ── Header ──────────────────────────────────
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(vm.displayName)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PSColor.textPrimary)
                        GatewayBadge(label: badgeLabel, color: accentColor)
                    }
                    Text("Accept card payments via \(vm.displayName) — enter your Collect.js tokenization key and secret below")
                        .font(.system(size: 12))
                        .foregroundColor(PSColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Rectangle()
                .fill(PSColor.cardBorder)
                .frame(height: 1)

            // ── Body ─────────────────────────────────────
            VStack(spacing: 18) {
                PSInfoBanner(
                    message: "How to get your Collect.js Tokenization Key: log in to your \(portalName), navigate to Settings → Security Keys → Public Security Keys, then copy your Tokenization Key and Secret Key from that section.",
                    accentColor: accentColor
                )

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Collect.js Tokenization Key", required: true)
                    MonoTextField(
                        placeholder: "your-tokenization-key",
                        text: $vm.clientId,
                        hasError: vm.clientIdError != nil,
                        icon: "key"
                    )
                    if let err = vm.clientIdError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your Collect.js tokenization key from the \(vm.displayName) portal")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Secret Key", required: true)
                    SecureMonoField(
                        placeholder: "your-secret-key",
                        text: $vm.clientSecret,
                        hasError: vm.clientSecretError != nil
                    )
                    if let err = vm.clientSecretError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Keep this secret — never expose in frontend code")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "V4 Secret Key", required: true)
                    SecureMonoField(
                        placeholder: "your-v4-secret-key",
                        text: $vm.secretKeyV4,
                        hasError: vm.secretKeyV4Error != nil
                    )
                    if let err = vm.secretKeyV4Error {
                        FieldErrorText(message: err)
                    } else {
                        Text("For enhanced authentication")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                Rectangle()
                    .fill(PSColor.cardBorder)
                    .frame(height: 1)

                HStack(spacing: 12) {
                    Spacer()
                    if vm.gatewayId != nil {
                        ClearKeysButton(action: vm.handleClearKeys, isDisabled: vm.isSaving)
                    }
                    PSSaveButton(action: vm.handleSave, isSaving: vm.isSaving, isSaved: vm.saveSuccess)
                }
            }
            .padding(20)
        }
        .background(PSColor.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PSColor.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 2)
        .alert(isPresented: $vm.showClearConfirm) {
            Alert(
                title: Text("Clear API Keys"),
                message: Text("Are you sure you want to clear the \(vm.displayName) API keys? This action cannot be undone."),
                primaryButton: .destructive(Text("Clear Keys")) { vm.confirmClearKeys() },
                secondaryButton: .cancel()
            )
        }
    }
}

// ─────────────────────────────────────────────
// NetBillingCardView  (PayBito Vertex)
// ─────────────────────────────────────────────
struct NetBillingCardView: View {
    @ObservedObject var vm: NetBillingCardViewModel
    private let accentColor = Color(red: 0.0, green: 0.290, blue: 0.600) // #004A99

    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("PayBito Vertex")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PSColor.textPrimary)
                        GatewayBadge(label: "Card Payments", color: accentColor)
                    }
                    Text("Accept card payments via PayBito Vertex — enter your Account ID and Site Tag below")
                        .font(.system(size: 12))
                        .foregroundColor(PSColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Rectangle()
                .fill(PSColor.cardBorder)
                .frame(height: 1)

            VStack(spacing: 18) {
                PSInfoBanner(
                    message: "Retrieve your Account ID and Site Tag from the PayBito Vertex Merchant Portal.",
                    accentColor: accentColor
                )

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Account ID", required: true)
                    MonoTextField(
                        placeholder: "123456",
                        text: $vm.accountId,
                        hasError: vm.accountIdError != nil,
                        icon: "person"
                    )
                    if let err = vm.accountIdError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your numeric PayBito Vertex Account ID")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Site Tag", required: true)
                    MonoTextField(
                        placeholder: "SITE_TAG",
                        text: $vm.siteTag,
                        hasError: vm.siteTagError != nil,
                        icon: "tag"
                    )
                    if let err = vm.siteTagError {
                        FieldErrorText(message: err)
                    } else {
                        Text("The Site Tag assigned to your account")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Authorization", required: true)
                    MonoTextField(
                        placeholder: "Authorization Key",
                        text: $vm.authorization,
                        hasError: vm.authorizationError != nil,
                        icon: "checkmark.shield"
                    )
                    if let err = vm.authorizationError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your PayBito Vertex authorization key")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Control keyword", required: false)
                    MonoTextField(
                        placeholder: "Control keyword",
                        text: $vm.controlKeyword,
                        hasError: false,
                        icon: "lock"
                    )
                    Text("The control keyword for your PayBito Vertex account")
                        .font(.system(size: 11))
                        .foregroundColor(PSColor.textHint)
                }

                Rectangle()
                    .fill(PSColor.cardBorder)
                    .frame(height: 1)

                HStack(spacing: 12) {
                    Spacer()
                    if vm.gatewayId != nil {
                        ClearKeysButton(action: vm.handleClearKeys, isDisabled: vm.isSaving)
                    }
                    PSSaveButton(action: vm.handleSave, isSaving: vm.isSaving, isSaved: vm.saveSuccess)
                }
            }
            .padding(20)
        }
        .background(PSColor.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PSColor.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 2)
        .alert(isPresented: $vm.showClearConfirm) {
            Alert(
                title: Text("Clear API Keys"),
                message: Text("Are you sure you want to clear the PayBito Vertex API keys? This action cannot be undone."),
                primaryButton: .destructive(Text("Clear Keys")) { vm.confirmClearKeys() },
                secondaryButton: .cancel()
            )
        }
    }
}

// ─────────────────────────────────────────────
// CardFloCardView  (PayBito Sovereign)
// ─────────────────────────────────────────────
struct CardFloCardView: View {
    @ObservedObject var vm: CardFloCardViewModel
    private let accentColor = Color(red: 0.310, green: 0.275, blue: 0.898) // #4F46E5

    /// Mirrors `window.location.origin` from the web app — set to your merchant
    /// web app's base URL if it differs.
    private var webOrigin: String { "https://trade.paybito.com" }

    var body: some View {
        VStack(spacing: 0) {

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(accentColor.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 16))
                        .foregroundColor(accentColor)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("PayBito Sovereign")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PSColor.textPrimary)
                        GatewayBadge(label: "PayBito Sovereign Payments", color: accentColor)
                    }
                    Text("Accept card payments via PayBito Sovereign — enter your credentials below")
                        .font(.system(size: 12))
                        .foregroundColor(PSColor.textSecondary)
                        .lineLimit(2)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)

            Rectangle()
                .fill(PSColor.cardBorder)
                .frame(height: 1)

            VStack(spacing: 18) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 15))
                            .foregroundColor(accentColor)
                            .padding(.top, 1)
                        VStack(alignment: .leading, spacing: 6) {
                            Text("How to configure PayBito Sovereign Checkout: log in to your PayBito Sovereign Dashboard, navigate to Checkouts, add a checkout with the redirect & webhook URLs below, activate it, then enter your credentials.")
                                .font(.system(size: 12))
                                .foregroundColor(PSColor.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)

                            webhookRow(label: "Success Redirect URL", value: "\(webOrigin)/payments/merchant/checkout/success")
                            webhookRow(label: "Cancel Redirect URL", value: "\(webOrigin)/payments/merchant/checkout/cancel")
                            webhookRow(label: "Failure Redirect URL", value: "\(webOrigin)/payments/merchant/checkout/failure")
                            webhookRow(label: "Webhook Notification URL", value: vm.webhookURL)
                        }
                    }
                }
                .padding(14)
                .background(accentColor.opacity(0.06))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(accentColor.opacity(0.18), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "API Key", required: true)
                    MonoTextField(
                        placeholder: "PAYBITO_SOVEREIGN_API_KEY",
                        text: $vm.clientId,
                        hasError: vm.clientIdError != nil,
                        icon: "key"
                    )
                    if let err = vm.clientIdError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your unique PayBito Sovereign API key")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Username", required: true)
                    MonoTextField(
                        placeholder: "paybito_sovereign_user",
                        text: $vm.userName,
                        hasError: vm.userNameError != nil,
                        icon: "person"
                    )
                    if let err = vm.userNameError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your PayBito Sovereign account username")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Password", required: true)
                    SecureMonoField(
                        placeholder: "paybito_sovereign_pass",
                        text: $vm.password,
                        hasError: vm.passwordError != nil
                    )
                    if let err = vm.passwordError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your PayBito Sovereign account password")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    FormFieldLabel(text: "Cashier Key", required: true)
                    SecureMonoField(
                        placeholder: "PAYBITO_SOVEREIGN_CASHIER_KEY",
                        text: $vm.cashierKey,
                        hasError: vm.cashierKeyError != nil
                    )
                    if let err = vm.cashierKeyError {
                        FieldErrorText(message: err)
                    } else {
                        Text("Your PayBito Sovereign cashier authentication key")
                            .font(.system(size: 11))
                            .foregroundColor(PSColor.textHint)
                    }
                }

                Rectangle()
                    .fill(PSColor.cardBorder)
                    .frame(height: 1)

                HStack(spacing: 12) {
                    Spacer()
                    if vm.gatewayId != nil {
                        ClearKeysButton(action: vm.handleClearKeys, isDisabled: vm.isSaving)
                    }
                    PSSaveButton(action: vm.handleSave, isSaving: vm.isSaving, isSaved: vm.saveSuccess)
                }
            }
            .padding(20)
        }
        .background(PSColor.cardBg)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(PSColor.cardBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 2)
        .alert(isPresented: $vm.showClearConfirm) {
            Alert(
                title: Text("Clear API Keys"),
                message: Text("Are you sure you want to clear the PayBito Sovereign API keys? This action cannot be undone."),
                primaryButton: .destructive(Text("Clear Keys")) { vm.confirmClearKeys() },
                secondaryButton: .cancel()
            )
        }
    }

    private func webhookRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(PSColor.textPrimary)
            Text(value)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(PSColor.textSecondary)
                .textSelection(.enabled)
        }
        .padding(.top, 4)
    }
}
