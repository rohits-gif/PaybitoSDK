// MARK: - EnterpriseKYCGateView.swift
// Routing rules (from network inspector + JSON):
//   userDocsStatus = null + no enterpriseUser  → fresh blank form
//   userDocsStatus = null + enterpriseUser      → prefilled form (draft restore)
//   userDocsStatus = "0"  + no enterpriseUser  → pending screen
//   userDocsStatus = "0"  + enterpriseUser      → pending screen (data saved for reference)
//   userDocsStatus = "1"                        → approved screen
//   userDocsStatus = "2"  + enterpriseUser      → prefilled form (rejected, re-submit)
//   userDocsStatus = "2"  + no enterpriseUser   → fresh form (fallback)

import SwiftUI

private enum GT {
    static let bg     = Color(red: 0.07, green: 0.08, blue: 0.14)
    static let card   = Color(red: 0.10, green: 0.12, blue: 0.19)
    static let purple = Color(red: 0.47, green: 0.35, blue: 0.95)
    static let orange = Color(red: 0.98, green: 0.55, blue: 0.10)
    static let red    = Color(red: 0.92, green: 0.22, blue: 0.20)
    static let green  = Color(red: 0.22, green: 0.75, blue: 0.45)
    static let border = Color(white: 0.22)
    static let white  = Color.white
    static let gray   = Color(white: 0.60)
}

// MARK: - Gate State
private enum GateState {
    case loading
    case error(String)
    case freshForm
    case prefilledForm(KYCPrefillData)
    case pendingReview
    case approved
    case rejected(KYCPrefillData?)
}

// MARK: - Gate View
public struct EnterpriseKYCGateView: View {
    public init() {}

    @State private var state: GateState = .loading
    @State private var hasFetched = false

    public var body: some View {
        ZStack {
            GT.bg.ignoresSafeArea()
            switch state {
            case .loading:
                loadingCard
                    .onAppear {
                        guard !hasFetched else { return }
                        hasFetched = true
                        fetchStatus()
                    }
            case .error(let msg):
                errorView(msg)
            case .freshForm:
                EnterpriseKycFormView(prefill: nil)
            case .prefilledForm(let prefill):
                EnterpriseKycFormView(prefill: prefill)
            case .pendingReview:
                statusScreen(icon: "clock.fill", iconColor: GT.orange,
                             title: "KYC Under Review",
                             message: "Your KYC information has been submitted and is currently being reviewed by our compliance team. This usually takes 1–3 business days.",
                             badgeText: "Pending Review", badgeColor: GT.orange)
            case .approved:
                statusScreen(icon: "checkmark.seal.fill", iconColor: GT.green,
                             title: "KYC Approved",
                             message: "Your enterprise account has been verified successfully. You now have full access to all features.",
                             badgeText: "Approved", badgeColor: GT.green)
            case .rejected(let prefill):
                rejectedScreen(prefill: prefill)
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Fetch
    private func fetchStatus() {
        print("fetch status tapped")
        state = .loading
        let brokerId = SessionManager.shared.adminUserId
        print("🚪 [GateView] Fetching — brokerId=\(brokerId)")

        GetUserDetailsService.shared.fetchUserDetails(brokerId: brokerId) { result in
            switch result {
            case .success(let response): route(using: response)
            case .failure(let error):
                state = .error(error.localizedDescription)
            }
        }
    }

    // MARK: - Route
    // ┌────────────────────┬──────────────────┬──────────────────────────────┐
    // │ userDocsStatus     │ enterpriseUser   │ → GateState                  │
    // ├────────────────────┼──────────────────┼──────────────────────────────┤
    // │ null               │ nil              │ freshForm                    │
    // │ null               │ present          │ prefilledForm (draft)        │
    // │ "0" (pending)      │ nil              │ pendingReview                │
    // │ "0" (pending)      │ present          │ pendingReview                │
    // │ "1" (approved)     │ any              │ approved                     │
    // │ "2" (rejected)     │ present          │ prefilledForm (re-submit)    │
    // │ "2" (rejected)     │ nil              │ freshForm (fallback)         │
    // └────────────────────┴──────────────────┴──────────────────────────────┘
    private func route(using response: GetUserDetailsResponse) {
        let isKycFinishedRaw = (response.userResult?.isKycFinished ?? response.isKycFinished)?.stringValue.trimmingCharacters(in: .whitespaces)
        let isKycFinished = isKycFinishedRaw.flatMap { Int($0) } ?? 0

        let rawStr = (response.userResult?.userDocsStatus ?? response.userDocsStatus)?.stringValue
            .trimmingCharacters(in: .whitespaces)

        let enterpriseUser = response.userResult?.enterpriseUser ?? response.enterpriseUser
        let prefill: KYCPrefillData? = enterpriseUser.map { KYCPrefillData.build(from: $0) }

        var kycStatus = -1
        if isKycFinished == 1 {
            if rawStr == "0" { kycStatus = 0 }
            else if rawStr == "1" { kycStatus = 1 }
            else if rawStr == "2" { kycStatus = 2 }
        }

        switch kycStatus {
        case 0:
            state = .pendingReview
        case 1:
            state = .approved
        case 2:
            state = .rejected(prefill)
        default:
            if let p = prefill {
                state = .prefilledForm(p)
            } else {
                state = .freshForm
            }
        }
    }

    // MARK: - Loading Card
    private var loadingCard: some View {
        VStack {
            Spacer()
            VStack(spacing: 24) {
                ZStack {
                    Circle().fill(GT.purple.opacity(0.12)).frame(width: 72, height: 72)
                    ProgressView().progressViewStyle(.circular).scaleEffect(1.3).tint(GT.purple)
                }
                VStack(spacing: 8) {
                    Text("Checking KYC Status")
                        .font(.system(size: 17, weight: .bold)).foregroundColor(GT.white)
                    Text("Please wait while we retrieve your\nverification status…")
                        .font(.system(size: 13)).foregroundColor(GT.gray)
                        .multilineTextAlignment(.center).lineSpacing(3)
                }
                VStack(spacing: 12) {
                    Rectangle().fill(GT.border.opacity(0.5)).frame(height: 1)
                    HStack(spacing: 8) {
                        Circle().fill(GT.orange).frame(width: 7, height: 7)
                        Text("Connecting to compliance server")
                            .font(.system(size: 12)).foregroundColor(GT.gray)
                    }
                }
            }
            .padding(.horizontal, 28).padding(.vertical, 32).frame(maxWidth: 320)
            .background(GT.card).cornerRadius(20)
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(GT.border.opacity(0.6), lineWidth: 1))
            Spacer()
        }
        .padding(.horizontal, 32)
    }

    // MARK: - Error View
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 18) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44)).foregroundColor(GT.red)
            Text("Something Went Wrong")
                .font(.system(size: 18, weight: .bold)).foregroundColor(GT.white)
            Text(message)
                .font(.system(size: 13)).foregroundColor(GT.gray)
                .multilineTextAlignment(.center).padding(.horizontal, 32)
            Button { fetchStatus() } label: {
                Text("Retry").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                    .padding(.horizontal, 32).padding(.vertical, 14)
                    .background(GT.purple).cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity).padding(.top, 80).padding(24)
    }

    // MARK: - Status Screen
    private func statusScreen(
        icon:       String,
        iconColor:  Color,
        title:      String,
        message:    String,
        badgeText:  String,
        badgeColor: Color
    ) -> some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(iconColor.opacity(0.12)).frame(width: 96, height: 96)
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .semibold)).foregroundColor(iconColor)
            }
            VStack(spacing: 10) {
                Text(title).font(.system(size: 20, weight: .bold)).foregroundColor(GT.white)
                Text(badgeText).font(.system(size: 11, weight: .bold)).foregroundColor(badgeColor)
                    .padding(.horizontal, 12).padding(.vertical, 5)
                    .overlay(Capsule().stroke(badgeColor, lineWidth: 1.2))
                Text(message).font(.system(size: 13)).foregroundColor(GT.gray)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 32).padding(.top, 4)
            }
            Spacer()
            Button { fetchStatus() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 13, weight: .semibold))
                    Text("Refresh Status").font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white).frame(maxWidth: .infinity)
                .padding(.vertical, 16).background(GT.purple).cornerRadius(12)
            }
            .padding(.horizontal, 20).padding(.bottom, 32)
        }
        .padding(.top, 60)
    }

    // MARK: - Rejected Screen
    private func rejectedScreen(prefill: KYCPrefillData?) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            Text("KYC Rejected")
                .font(.title2.bold())
                .foregroundColor(.white)
            Text("Your KYC application was rejected. Please review your information and resubmit.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .foregroundColor(.gray)

            Button {
                if let p = prefill { state = .prefilledForm(p) }
                else { state = .freshForm }
            } label: {
                Text("Resubmit KYC")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(GT.purple)
                    .cornerRadius(12)
            }
            .padding(.top, 20)
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Preview
#Preview { EnterpriseKYCGateView() }
