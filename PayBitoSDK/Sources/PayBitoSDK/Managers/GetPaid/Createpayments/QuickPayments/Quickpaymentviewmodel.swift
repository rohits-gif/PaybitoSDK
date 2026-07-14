
//
//
//  QuickPaymentViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

@MainActor
final class QuickPaymentViewModel: ObservableObject {

    // ── Input
    @Published var amount:   String = ""
    @Published var currency: String = "USD"

    // ── Link creation
    @Published var isCreating:   Bool    = false
    @Published var createError:  String? = nil
    @Published var paymentID:    String? = nil
    @Published var paymentURL:   String? = nil

    // ── Email
    @Published var isSendingEmail:   Bool    = false
    @Published var emailSentSuccess: Bool    = false
    @Published var emailError:       String? = nil

    // MARK: Computed

    var isReadyToCreate: Bool {
        guard let v = Double(amount) else { return false }
        return v > 0
    }

    var hasResult: Bool { paymentID != nil && paymentURL != nil }

    // MARK: - Create Link

    func createLink(onSuccess: @escaping () -> Void) {
        guard isReadyToCreate else { return }
        isCreating  = true
        createError = nil
        paymentID   = nil
        paymentURL  = nil

        debugPrint("⚡ [QuickPayVM] create amount=\(amount) currency=\(currency)")

        CreatePaymentService.shared.createQuickPaymentLink(
            amount:   amount,
            currency: currency,
            name:     nil
        ) { [weak self] result in
            guard let self else { return }
            self.isCreating = false
            switch result {
            case .success(let res):
                self.paymentID  = res.id
                self.paymentURL = res.url
                debugPrint("✅ [QuickPayVM] id=\(res.id) url=\(res.url)")
                onSuccess()
            case .failure(let error):
                self.createError = error.localizedDescription
                debugPrint("❌ [QuickPayVM] \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Send Email

    func sendEmail(emailsRaw: String,
                   onSuccess: @escaping () -> Void,
                   onFailure: @escaping (String) -> Void) {

        let emails = emailsRaw
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !emails.isEmpty else { onFailure("Enter at least one email."); return }
        guard let pid = paymentID, let purl = paymentURL else {
            onFailure("No payment link yet. Create one first."); return
        }

        isSendingEmail   = true
        emailSentSuccess = false
        emailError       = nil

        CreatePaymentService.shared.sendPaymentLink(
            paymentOrderId: pid,
            paymentLink:    purl,
            emails:         emails
        ) { [weak self] result in
            guard let self else { return }
            self.isSendingEmail = false
            switch result {
            case .success:
                self.emailSentSuccess = true
                debugPrint("✅ [QuickPayVM] email sent to \(emails)")
                onSuccess()
            case .failure(let error):
                self.emailError = error.localizedDescription
                debugPrint("❌ [QuickPayVM] sendEmail: \(error.localizedDescription)")
                onFailure(error.localizedDescription)
            }
        }
    }
}
