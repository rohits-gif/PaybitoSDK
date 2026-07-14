// MARK: - Shared UI Components (Payment Setup)

import SwiftUI

// ─────────────────────────────────────────────
// PSColor — all values are non-optional Color
// Uses Color(red:green:blue:) directly to avoid
// any conflict with the project's Color(hex:) → Color?
// ─────────────────────────────────────────────
enum PSColor {
    // #0F1117
    static let background    = Color(red: 0.059, green: 0.067, blue: 0.090)
    // #161B27
    static let cardBg        = Color(red: 0.086, green: 0.106, blue: 0.153)
    // #232A3B
    static let cardBorder    = Color(red: 0.137, green: 0.165, blue: 0.231)
    // #1A2133
    static let inputBg       = Color(red: 0.102, green: 0.129, blue: 0.200)
    static let textPrimary   = Color.white
    static let textSecondary = Color.white.opacity(0.5)
    static let textHint      = Color.white.opacity(0.35)
    // #9747FF
    static let accent        = Color(red: 0.592, green: 0.278, blue: 1.000)
    // #635BFF
    static let stripeBlue    = Color(red: 0.388, green: 0.357, blue: 1.000)
    // #009CDE
    static let paypalBlue    = Color(red: 0.000, green: 0.612, blue: 0.871)
    // #EF4444
    static let danger        = Color(red: 0.937, green: 0.267, blue: 0.267)
    // #22C55E
    static let success       = Color(red: 0.133, green: 0.773, blue: 0.369)
    // #232A3B (same as cardBorder)
    static let inputBorder   = Color(red: 0.137, green: 0.165, blue: 0.231)
    // #EF4444 (same as danger)
    static let errorBorder   = Color(red: 0.937, green: 0.267, blue: 0.267)
    // #9747FF (same as accent)
    static let saveBtn       = Color(red: 0.592, green: 0.278, blue: 1.000)
    // #1E2436
    static let toastBg       = Color(red: 0.118, green: 0.141, blue: 0.212)
}

// ─────────────────────────────────────────────
// MonoTextField
// ─────────────────────────────────────────────
struct MonoTextField: View {
    let placeholder: String
    @Binding var text: String
    var hasError: Bool = false
    var icon: String? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundColor(PSColor.textHint)
                    .frame(width: 18)
            }
            TextField("", text: $text)
                .psPlaceholder(when: text.isEmpty) {
                    Text(placeholder)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(PSColor.textHint)
                }
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(PSColor.textPrimary)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(PSColor.inputBg)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? PSColor.errorBorder : PSColor.inputBorder, lineWidth: 1)
        )
    }
}

// ─────────────────────────────────────────────
// SecureMonoField
// ─────────────────────────────────────────────
struct SecureMonoField: View {
    let placeholder: String
    @Binding var text: String
    var hasError: Bool = false

    @State private var isVisible: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isVisible {
                    TextField("", text: $text)
                        .psPlaceholder(when: text.isEmpty) {
                            Text(placeholder)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(PSColor.textHint)
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(PSColor.textPrimary)
                } else {
                    SecureField("", text: $text)
                        .psPlaceholder(when: text.isEmpty) {
                            Text(placeholder)
                                .font(.system(size: 13, design: .monospaced))
                                .foregroundColor(PSColor.textHint)
                        }
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(PSColor.textPrimary)
                }
            }
            .autocapitalization(.none)
            .disableAutocorrection(true)

            Button(action: { isVisible.toggle() }) {
                Image(systemName: isVisible ? "eye.slash" : "eye")
                    .font(.system(size: 14))
                    .foregroundColor(PSColor.textHint)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(PSColor.inputBg)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? PSColor.errorBorder : PSColor.inputBorder, lineWidth: 1)
        )
    }
}

// ─────────────────────────────────────────────
// FormFieldLabel
// ─────────────────────────────────────────────
struct FormFieldLabel: View {
    let text: String
    var required: Bool = false

    var body: some View {
        HStack(spacing: 3) {
            Text(text.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.5)
                .foregroundColor(PSColor.textSecondary)
            if required {
                Text("*").font(.system(size: 11)).foregroundColor(PSColor.danger)
            }
        }
    }
}

// ─────────────────────────────────────────────
// FieldErrorText
// ─────────────────────────────────────────────
struct FieldErrorText: View {
    let message: String
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 11))
            Text(message)
                .font(.system(size: 11))
        }
        .foregroundColor(PSColor.danger)
    }
}

// ─────────────────────────────────────────────
// PSSaveButton
// ─────────────────────────────────────────────
struct PSSaveButton: View {
    let action: () -> Void
    let isSaving: Bool
    let isSaved: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                    Text("Saving…")
                } else if isSaved {
                    Image(systemName: "checkmark.circle")
                    Text("Saved")
                } else {
                    Image(systemName: "square.and.arrow.down")
                    Text("Save Changes")
                }
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(isSaved ? PSColor.success : PSColor.saveBtn)
            .cornerRadius(10)
        }
        .disabled(isSaving)
    }
}

// ─────────────────────────────────────────────
// ClearKeysButton
// ─────────────────────────────────────────────
struct ClearKeysButton: View {
    let action: () -> Void
    let isDisabled: Bool

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "trash")
                    .font(.system(size: 12))
                Text("Clear Keys")
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(PSColor.danger)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(PSColor.danger.opacity(0.08))
            .cornerRadius(9)
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(PSColor.danger.opacity(0.25), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1)
    }
}

// ─────────────────────────────────────────────
// PSInfoBanner — prefixed to avoid project conflicts
// ─────────────────────────────────────────────
struct PSInfoBanner: View {
    let message: String
    var accentColor: Color = PSColor.stripeBlue

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "info.circle")
                .font(.system(size: 15))
                .foregroundColor(accentColor)
                .padding(.top, 1)
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(PSColor.textSecondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .background(accentColor.opacity(0.06))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(accentColor.opacity(0.18), lineWidth: 1)
        )
    }
}

// ─────────────────────────────────────────────
// GatewayBadge
// ─────────────────────────────────────────────
struct GatewayBadge: View {
    let label: String
    var color: Color = PSColor.stripeBlue

    var body: some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.3)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.12))
            .cornerRadius(6)
    }
}

// ─────────────────────────────────────────────
// PSToastView — prefixed to avoid project conflicts
// ─────────────────────────────────────────────
struct PSToastView: View {
    let message: String
    let isError: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isError ? "xmark.circle.fill" : "checkmark.circle.fill")
                .foregroundColor(isError ? PSColor.danger : PSColor.success)
            Text(message)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(PSColor.toastBg.opacity(0.97))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 4)
    }
}

// ─────────────────────────────────────────────
// psPlaceholder — prefixed to avoid project conflicts
// ─────────────────────────────────────────────
extension View {
    func psPlaceholder<Content: View>(
        when condition: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if condition { placeholder() }
            self
        }
    }
}

// ─────────────────────────────────────────────
// SectionDivider
// ─────────────────────────────────────────────
struct SectionDivider: View {
    let label: String
    var body: some View {
        HStack(spacing: 10) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(PSColor.textSecondary)
            Rectangle()
                .fill(PSColor.cardBorder)
                .frame(height: 1)
        }
    }
}
