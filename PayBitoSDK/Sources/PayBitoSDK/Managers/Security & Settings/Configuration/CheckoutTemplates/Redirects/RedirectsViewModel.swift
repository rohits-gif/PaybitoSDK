// MARK: - RedirectsViewModel.swift
// Updated to match new RedirectService signatures (Alamofire 4 Result<T> single type).

import Foundation

final class RedirectsViewModel: ObservableObject {

    // MARK: - List state
    @Published var templates:       [RedirectTemplate] = []
    @Published var isLoading:       Bool = true
    @Published var isReadOnly:      Bool = false

    // MARK: - Default redirect card state
    @Published var defaultRedirect: DefaultRedirect? = nil
    @Published var isDefaultActive: Bool = true

    // MARK: - Toast
    @Published var toast:           RedirectToast? = nil

    // MARK: - Confirm dialog
    @Published var confirmState:    ConfirmDialogState? = nil

    // MARK: - Modal form state
    @Published var isModalOpen:     Bool = false
    @Published var editingId:       Int? = nil
    @Published var isSaving:        Bool = false

    @Published var tplName:         String = ""
    @Published var tplSuccess:      String = ""
    @Published var tplFailure:      String = ""
    @Published var successMode:     RedirectMode = .hosted
    @Published var failureMode:     RedirectMode = .hosted
    @Published var advOpen:         Bool = false
    @Published var qpPaymentId:     Bool = true
    @Published var qpStatus:        Bool = true
    @Published var qpEmail:         Bool = true
    @Published var qpAmount:        Bool = true

    // Validation errors
    @Published var nameError:       String = ""
    @Published var successUrlError: String = ""
    @Published var failureUrlError: String = ""

    private let service: RedirectService

    init(service: RedirectService = .shared) {
        self.service = service
    }

    // MARK: - Computed: example output (mirrors React's exampleOutput)
    var exampleOutput: String {
        if successMode == .hosted { return "Hosted success page (no redirect URL)" }
        let base  = tplSuccess.isEmpty ? "https://yourdomain.com/success" : tplSuccess
        var parts: [String] = []
        if qpPaymentId { parts.append("payment_id=pay_abc123") }
        if qpStatus    { parts.append("status=succeeded") }
        if qpEmail     { parts.append("customer_email=user%40email.com") }
        if qpAmount    { parts.append("amount=800") }
        return base + (parts.isEmpty ? "" : "?" + parts.joined(separator: "&"))
    }

    // MARK: - Load
    func loadAll() {
        loadTemplates()
        loadDefault()
    }

    func loadTemplates() {
        isLoading = true
        service.fetchAll { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let templates):
                    self?.templates = templates
                case .failure(let error):
                    self?.showToast(error.localizedDescription, success: false)
                }
            }
        }
    }

    func loadDefault() {
        service.fetchDefault { [weak self] def in
            DispatchQueue.main.async {
                self?.defaultRedirect = def
            }
        }
    }

    // MARK: - Modal open/close
    func openModal(id: Int?) {
        editingId       = id
        nameError       = ""
        successUrlError = ""
        failureUrlError = ""
        advOpen         = false

        if let id = id, let t = templates.first(where: { $0.id == id }) {
            tplName     = t.name
            tplSuccess  = t.successURL
            tplFailure  = t.failureURL
            successMode = t.successMode
            failureMode = t.failureMode
            qpPaymentId = t.params.paymentId
            qpStatus    = t.params.status
            qpEmail     = t.params.customerEmail
            qpAmount    = t.params.amount
        } else {
            tplName     = ""
            tplSuccess  = ""
            tplFailure  = ""
            successMode = .hosted
            failureMode = .hosted
            qpPaymentId = true
            qpStatus    = true
            qpEmail     = true
            qpAmount    = true
        }
        isModalOpen = true
    }

    func closeModal() {
        isModalOpen = false
        editingId   = nil
    }

    // MARK: - Validation
    private func validate() -> Bool {
        var ok = true

        if tplName.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Template name is required"; ok = false
        } else { nameError = "" }

        if successMode == .url {
            if tplSuccess.trimmingCharacters(in: .whitespaces).isEmpty {
                successUrlError = "Success URL is required"; ok = false
            } else if !isValidURL(tplSuccess) {
                successUrlError = "Must be a valid URL starting with http:// or https://"; ok = false
            } else { successUrlError = "" }
        } else { successUrlError = "" }

        if failureMode == .url {
            if tplFailure.trimmingCharacters(in: .whitespaces).isEmpty {
                failureUrlError = "Failure URL is required"; ok = false
            } else if !isValidURL(tplFailure) {
                failureUrlError = "Must be a valid URL starting with http:// or https://"; ok = false
            } else { failureUrlError = "" }
        } else { failureUrlError = "" }

        return ok
    }

    // MARK: - Save template (mirrors saveTemplate(makeDefault) in React)
    func saveTemplate(makeDefault: Bool, onSuccess: @escaping () -> Void) {
        guard !isReadOnly else {
            showToast("You need write access to perform this operation", success: false); return
        }
        guard validate() else { return }

        let successUrl = successMode == .hosted
            ? (defaultRedirect?.successURL ?? "")
            : tplSuccess.trimmingCharacters(in: .whitespaces)

        let failureUrl = failureMode == .hosted
            ? (defaultRedirect?.failureURL ?? "")
            : tplFailure.trimmingCharacters(in: .whitespaces)

        let payload = RedirectSavePayload(
            id:                editingId,
            merchantId:        0,              // service uses extractMerchantId() internally
            templateName:      tplName.trimmingCharacters(in: .whitespaces),
            successUrl:        successUrl,
            successMode:       successMode == .hosted ? 1 : 0,
            failureUrl:        failureUrl,
            failureMode:       failureMode == .hosted ? 1 : 0,
            cancelUrl:         "",
            passPaymentId:     qpPaymentId     ? 1 : 0,
            passStatus:        qpStatus        ? 1 : 0,
            passCustomerEmail: qpEmail         ? 1 : 0,
            passAmount:        qpAmount        ? 1 : 0,
            isDefault:         makeDefault     ? 1 : 0
        )

        isSaving = true
        service.save(payload: payload) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success:
                    if makeDefault { self.isDefaultActive = false }
                    let msg = self.editingId != nil ? "Template updated" : "Template created"
                    self.showToast(msg, success: true)
                    self.closeModal()
                    self.loadTemplates()
                    onSuccess()
                case .failure(let error):
                    self.showToast(error.localizedDescription, success: false)
                }
            }
        }
    }

    // MARK: - Delete (mirrors deleteTemplate in React)
    func deleteTemplate(id: Int) {
        guard !isReadOnly else {
            showToast("You need write access to perform this operation", success: false); return
        }
        confirmState = ConfirmDialogState(
            title:    "Delete Template",
            body:     "This redirect template will be permanently removed.",
            btnLabel: "Delete",
            isDanger: true,
            onConfirm: { [weak self] in
                self?.service.delete(id: id) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.showToast("Template deleted", success: true)
                            self?.loadTemplates()
                        case .failure(let error):
                            self?.showToast(error.localizedDescription, success: false)
                        }
                    }
                }
            }
        )
    }

    // MARK: - Set template as default (mirrors setTemplateDefault — mackDefault=0)
    func setTemplateDefault(id: Int) {
        guard !isReadOnly else {
            showToast("You need write access to perform this operation", success: false); return
        }
        confirmState = ConfirmDialogState(
            title:    "Set as Default",
            body:     "This template will be used as the default redirect template.",
            btnLabel: "Set Default",
            isDanger: false,
            onConfirm: { [weak self] in
                self?.service.setDefault(id: id, mackDefault: 0) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.isDefaultActive = false
                            self?.showToast("Default template updated", success: true)
                            self?.loadTemplates()
                        case .failure(let error):
                            self?.showToast(error.localizedDescription, success: false)
                        }
                    }
                }
            }
        )
    }

    // MARK: - Restore global default card (mirrors makeDefaultCard — mackDefault=1)
    func makeDefaultCard() {
        guard !isReadOnly else {
            showToast("You need write access to perform this operation", success: false); return
        }
        guard let defId = defaultRedirect?.id else {
            showToast("Default redirect not loaded yet", success: false); return
        }
        confirmState = ConfirmDialogState(
            title:    "Set as Default",
            body:     "The default redirect card will be used as the default for all payments.",
            btnLabel: "Set Default",
            isDanger: false,
            onConfirm: { [weak self] in
                self?.service.setDefault(id: defId, mackDefault: 1) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success:
                            self?.isDefaultActive = true
                            self?.templates = (self?.templates ?? []).map {
                                var t = $0; t.isDefault = false; return t
                            }
                            self?.showToast("Default redirects activated", success: true)
                        case .failure(let error):
                            self?.showToast(error.localizedDescription, success: false)
                        }
                    }
                }
            }
        )
    }

    // MARK: - Toast helpers
    func showToast(_ message: String, success: Bool) {
        toast = RedirectToast(message: message, isSuccess: success)
    }
    func clearToast() { toast = nil }

    // MARK: - URL validation
    private func isValidURL(_ string: String) -> Bool {
        guard let url = URL(string: string.trimmingCharacters(in: .whitespaces)) else { return false }
        return url.scheme == "http" || url.scheme == "https"
    }
}

// MARK: - Confirm Dialog State
struct ConfirmDialogState: Identifiable {
    let id         = UUID()
    let title:     String
    let body:      String
    let btnLabel:  String
    let isDanger:  Bool
    let onConfirm: () -> Void
}
