// MARK: - AddOwnerViewModel.swift

import Foundation
import SwiftUI
import UIKit

@MainActor
final class AddOwnerViewModel: ObservableObject {

    // MARK: - Inputs
    let editing: UBOOwner?
    let merchantId: String
    /// NOTE: no longer `let` — this can be refreshed with a fresh value
    /// fetched from the session/GetUserDetails API right before submission,
    /// instead of trusting whatever was passed in at init (which can go stale
    /// across a long-lived session and cause silent insert failures).
    private(set) var userUuid: String

    // MARK: - Owner data
    @Published var owner: UBOOwner

    // MARK: - API state
    @Published var isSubmitting   = false
    @Published var showAPISuccess = false
    @Published var showAPIError   = false
    @Published var apiErrorMsg    = ""

    // MARK: - File validation state
    @Published var showFileError  = false
    @Published var fileErrorMsg   = ""

    // MARK: - Form validation state
    @Published var validationErrors: [String] = []
    @Published var showValidation    = false

    // MARK: - File URLs (kept for multipart upload)
    @Published var idFrontURL: URL?
    @Published var idBackURL:  URL?
    @Published var poaURL:     URL?
    @Published var selfieURL:  URL?
    @Published var investURL:  URL?

    // MARK: - Static option lists
    let ownerTypes = ["Authorized signatory", "Director", "UBO"]
    let pepOptions  = ["Yes","No"]
    let idDocTypes  = ["Driver's license", "Passport", "National ID Card", "Residence Permit / Green Card"]
    let poaTypes    = ["Utility Bill (Electricity / Water / Gas / Internet)", "Bank Statement", "Credit Card Statement", "Government-Issued Letter", "Processing Statement", "Tax Document / Tax Assessment", "Rental / Lease Agreement", "Mortgage Statement", "Insurance Statement"]
    let countries   = ["United States","United Kingdom","Canada","Australia","India","Germany","France","Singapore","UAE","Afghanistan","Other"]
    let phoneCodes  = ["+1 (US)","+1 (CA)","+44 (UK)","+91 (IN)","+61 (AU)","+49 (DE)","+33 (FR)","+65 (SG)","+971 (AE)"]

    // MARK: - Init
    init(editing: UBOOwner? = nil, merchantId: String = "", userUuid: String = "") {
        self.editing    = editing
        self.merchantId = merchantId
        self.userUuid   = userUuid
        self.owner      = editing ?? UBOOwner()
    }

    // MARK: - Validation
    func validate() -> [String] {
        var e: [String] = []
        if owner.ownershipPct.trimmingCharacters(in: .whitespaces).isEmpty {
            e.append("Ownership Percentage is required")
        } else if let pct = Double(owner.ownershipPct), pct <= 0 || pct > 100 {
            e.append("Ownership Percentage must be between 1 and 100")
        }
        if owner.firstName.trimmingCharacters(in: .whitespaces).isEmpty    { e.append("First Name is required") }
        if owner.lastName.trimmingCharacters(in: .whitespaces).isEmpty     { e.append("Last Name is required") }
        if owner.email.trimmingCharacters(in: .whitespaces).isEmpty        { e.append("Email Address is required") }
        else if !isValidEmail(owner.email)                                 { e.append("Email Address is not valid") }
        if owner.phone.trimmingCharacters(in: .whitespaces).isEmpty        { e.append("Phone Number is required") }
        if owner.dob.trimmingCharacters(in: .whitespaces).isEmpty          { e.append("Date of Birth is required") }
        if owner.placeOfBirth.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Place of Birth is required") }
        if owner.ssnPassport.trimmingCharacters(in: .whitespaces).isEmpty  { e.append("SSN / Passport Number is required") }
        if owner.street.trimmingCharacters(in: .whitespaces).isEmpty       { e.append("Street Address is required") }
        if owner.city.trimmingCharacters(in: .whitespaces).isEmpty         { e.append("City is required") }
        if owner.addrState.trimmingCharacters(in: .whitespaces).isEmpty    { e.append("State is required") }
        if owner.country.isEmpty                                            { e.append("Country is required") }
        if owner.zip.trimmingCharacters(in: .whitespaces).isEmpty          { e.append("Zip Code is required") }
        if owner.isPEP.isEmpty                                              { e.append("PEP selection is required") }
        if owner.idDocType.isEmpty                                          { e.append("Identity Document Type is required") }
        if owner.idCountry.isEmpty                                          { e.append("Identity Document Country is required") }
        if owner.idDocType == "Driver's license" && owner.idState.trimmingCharacters(in: .whitespaces).isEmpty {
            e.append("Identity Document State is required")
        }
        if owner.govIdFront.isEmpty                                         { e.append("Government ID Front is required") }
        if owner.govIdBack.isEmpty                                          { e.append("Government ID Back is required") }
        if owner.poaType.isEmpty                                            { e.append("Proof of Address Type is required") }
        if owner.proofOfAddress.isEmpty                                     { e.append("Proof of Address document is required") }
        if owner.selfieFile.isEmpty                                         { e.append("Selfie holding ID is required") }
        return e
    }

    func isValidEmail(_ s: String) -> Bool {
        s.range(of: #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#,
                options: .regularExpression) != nil
    }

    /// Returns true if validation has been run and the given condition is an error.
    func err(_ isEmpty: Bool) -> Bool { showValidation && isEmpty }

    // MARK: - File Import Handling
    /// Validates a file-importer result against size/type rules, sets the
    /// corresponding URL + display name on success, or shows an error alert.
    private func copyToTemporaryDirectory(from url: URL) -> URL? {
        let needsAccess = url.startAccessingSecurityScopedResource()
        defer { if needsAccess { url.stopAccessingSecurityScopedResource() } }
        
        let tempDir = FileManager.default.temporaryDirectory
        let destinationURL = tempDir.appendingPathComponent(UUID().uuidString).appendingPathExtension(url.pathExtension)
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: url, to: destinationURL)
            return destinationURL
        } catch {
            print("❌ [AddOwnerViewModel] Failed to copy file to temporary directory: \(error.localizedDescription)")
            return nil
        }
    }

    func handleFileImport(
        _ result: Result<[URL], Error>,
        urlBinding: ReferenceWritableKeyPath<AddOwnerViewModel, URL?>,
        nameBinding: WritableKeyPath<UBOOwner, String>
    ) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            if let problem = UBOFileValidation.validate(url) {
                fileErrorMsg  = problem
                showFileError = true
                return
            }
            guard let localURL = copyToTemporaryDirectory(from: url) else {
                fileErrorMsg  = "Could not process selected file."
                showFileError = true
                return
            }
            self[keyPath: urlBinding] = localURL
            owner[keyPath: nameBinding] = url.lastPathComponent
        case .failure(let error):
            fileErrorMsg  = "Could not import file: \(error.localizedDescription)"
            showFileError = true
        }
    }

    // MARK: - Duplicate Document Detection
    /// The backend appears to reject an owner INSERT (generic
    /// "Failed to add enterprise owner. Please try again later.") when the
    /// same file bytes are reused across multiple required document slots
    /// (e.g. the same photo used for ID front, address proof, and selfie).
    /// Catch this client-side before ever hitting the network, so the user
    /// gets an immediate, specific message instead of a vague server error.
    private func filesAreIdentical(_ a: URL?, _ b: URL?) -> Bool {
        guard let a, let b else { return false }
        guard let dataA = try? Data(contentsOf: a), let dataB = try? Data(contentsOf: b) else { return false }
        return !dataA.isEmpty && dataA == dataB
    }

    /// Returns a user-facing message if any two *required* document slots
    /// contain byte-identical files, or nil if all required documents are distinct.
    func duplicateDocumentError() -> String? {
        let slots: [(name: String, url: URL?)] = [
            ("Government ID Front", idFrontURL),
            ("Government ID Back",  idBackURL),
            ("Proof of Address",    poaURL),
            ("Selfie holding ID",   selfieURL)
        ]
        for i in 0..<slots.count {
            for j in (i + 1)..<slots.count {
                if filesAreIdentical(slots[i].url, slots[j].url) {
                    return "\"\(slots[i].name)\" and \"\(slots[j].name)\" appear to be the exact same file. Please upload a distinct document/photo for each field."
                }
            }
        }
        return nil
    }

    // MARK: - Fresh userUuid
    /// Fetches the current userUuid from the session / GetUserDetails API and
    /// updates `self.userUuid` before building the request, so a stale UUID
    /// captured whenever this ViewModel was first created can never be the
    /// reason an INSERT/UPDATE silently fails.
    ///
    /// ⚠️ INTEGRATION POINT: replace the body of this function with your real
    /// call — e.g. `SessionManager.shared.getUserDetails { ... }` or whatever
    /// your GetUserDetails service is actually named. The signature below
    /// (an async completion returning an optional fresh UUID string) is the
    /// only thing that matters for the rest of this file to work correctly.
    private func refreshUserUuid(completion: @escaping (Bool) -> Void) {
        // Example wiring — uncomment and adapt to your actual service:
        //
        // SessionManager.shared.getUserDetails { [weak self] result in
        //     guard let self else { completion(false); return }
        //     switch result {
        //     case .success(let details):
        //         self.userUuid = details.userUuid   // <- adjust field name
        //         completion(true)
        //     case .failure(let error):
        //         print("❌ [AddOwnerViewModel] Failed to refresh userUuid: \(error)")
        //         completion(false)
        //     }
        // }

        // Fallback no-op until wired to a real service: keep the existing
        // userUuid and let submission proceed rather than blocking forever.
        completion(true)
    }

    // MARK: - Submit
    /// Returns true if the submission was handled locally (no API call needed)
    /// and the sheet should be dismissed immediately via `onSave`.
    func submitOwner(onSave: @escaping (UBOOwner) -> Void, onLocalSaveComplete: @escaping () -> Void) {
        let errors = validate()
        guard errors.isEmpty else {
            validationErrors = errors; showValidation = true; return
        }
        showValidation = false; validationErrors = []

        // Catch duplicate/reused document files before ever calling the API.
        if let dupError = duplicateDocumentError() {
            fileErrorMsg  = dupError
            showFileError = true
            return
        }

        // No session params → save locally only
        guard !merchantId.isEmpty, !userUuid.isEmpty else {
            print("ℹ️ [AddOwnerViewModel] No session params — saving locally")
            onSave(owner)
            onLocalSaveComplete()
            return
        }

        isSubmitting = true

        // Refresh userUuid from the session/GetUserDetails API first, then
        // proceed with the actual submission using whatever value comes back
        // (fresh if the refresh succeeded, unchanged if it failed/no-ops).
        refreshUserUuid { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.performSubmit(onSave: onSave, onLocalSaveComplete: onLocalSaveComplete)
            }
        }
    }

    /// The actual network submission, called only after `userUuid` has been refreshed.
    private func performSubmit(onSave: @escaping (UBOOwner) -> Void, onLocalSaveComplete: @escaping () -> Void) {

        // Build payload
        var payload = AddOwnerPayload()
        payload.firstName           = owner.firstName
        payload.middleName          = owner.middleName
        payload.lastName            = owner.lastName
        payload.email               = owner.email
        let cleanCode = owner.phoneCode.components(separatedBy: .whitespaces).first ?? owner.phoneCode
        let cleanPhoneCode = cleanCode.filter { $0.isNumber }
        let digitsOnlyPhone = owner.phone.filter { $0.isNumber }
        // NOTE: digits only — the backend rejects a leading "+" with
        // {"error_data":1,"error_msg":"Invalid input."}. Sanitize defensively
        // in case anything upstream (owner.phone, phoneCode, or the payload
        // model itself) reintroduces a "+" or other non-digit characters.
        payload.phone               = "\(cleanPhoneCode)\(digitsOnlyPhone)".filter { $0.isNumber }
        payload.address             = owner.street
        payload.city                = owner.city
        payload.state                = owner.addrState
        payload.country             = owner.country
        payload.zip                 = owner.zip
        payload.dob                 = owner.dob
        payload.birthPlace          = owner.placeOfBirth
        payload.ssn                 = owner.ssnPassport
        payload.ownerShipPer        = owner.ownershipPct.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        payload.pep                 = owner.isPEP == "Yes" ? 1 : 0
        payload.action              = owner.ownerUuid.isEmpty ? "INSERT" : "UPDATE"
        payload.ownerType           = owner.ownerType
        payload.ownerUuid           = owner.ownerUuid
      
        payload.identityDocType     = owner.idDocType
        payload.identityDocCountry  = owner.idCountry
        payload.identityDocState    = owner.idState
        payload.addressProofDocType = owner.poaType

        // Build attachments
        var attachments: [AddOwnerDocAttachment] = []
        func attach(_ url: URL?, field: String) {
            guard let u = url else { return }

            let ext = u.pathExtension.lowercased()

            // The backend generically fails ("Failed to add enterprise owner.
            // Please try again later.") on HEIC/HEIF uploads — the default
            // format for photos captured directly from the iOS camera/photo
            // picker. Convert to JPEG before attaching so the server always
            // receives a format it accepts.
            if ext == "heic" || ext == "heif" {
                if let data = try? Data(contentsOf: u),
                   let uiImage = UIImage(data: data),
                   let jpegData = uiImage.jpegData(compressionQuality: 0.9) {
                    attachments.append(AddOwnerDocAttachment(
                        fieldName: field,
                        fileData: jpegData,
                        fileName: "\(field).jpg",
                        mimeType: "image/jpeg"
                    ))
                } else {
                    print("❌ [AddOwnerViewModel] Failed to convert HEIC file to JPEG for field '\(field)' from URL: \(u)")
                }
                return
            }

            if let data = try? Data(contentsOf: u) {
                let outExt = u.pathExtension.isEmpty ? "jpg" : u.pathExtension
                let mime = u.pathExtension.isEmpty ? "image/jpeg" : u.mimeType
                attachments.append(AddOwnerDocAttachment(
                    fieldName: field,
                    fileData: data,
                    fileName: "\(field).\(outExt)",
                    mimeType: mime
                ))
            } else {
                print("❌ [AddOwnerViewModel] Failed to read file data for field '\(field)' from URL: \(u)")
            }
        }
        attach(idFrontURL, field: "idProofFront")
        attach(idBackURL,  field: "idProofBack")
        attach(poaURL,     field: "addressProofDoc")
        attach(selfieURL,  field: "selfieDoc")
        attach(investURL,  field: "investmentProofDoc")

        print("🚀 [AddOwnerViewModel] Attachments built: \(attachments.count) files. Fields: \(attachments.map { $0.fieldName })")

        let params = AddOwnerQueryParams(merchantId: merchantId, userUuid: userUuid)
        let isInsert = payload.action == "INSERT"
        isSubmitting = true
        print("🚀 [AddOwnerViewModel] Submitting owner to API… (userUuid: \(userUuid))")

        AddEnterpriseOwnerService.shared.addOwner(
            queryParams:  params,
            ownerPayload: payload,
            attachments:  attachments,
            completion:   { [weak self] result in
                guard let self else { return }
                Task { @MainActor in
                    self.isSubmitting = false
                    switch result {
                    case .success:
                        print("✅ [AddOwnerViewModel] Owner saved via API")
                        self.showAPISuccess = true
                    case .failure(let error):
                        print("❌ [AddOwnerViewModel] API error: \(error.localizedDescription)")
                        var message = error.localizedDescription
                        // This generic message on a new-owner INSERT very often
                        // means the email or SSN/passport number is already
                        // registered to another owner for this merchant. Give
                        // the user something actionable instead of just
                        // "please try again later."
                        let looksLikeGenericInsertFailure =
                            message.localizedCaseInsensitiveContains("did not insert") ||
                            message.localizedCaseInsensitiveContains("try again later")
                        if isInsert && looksLikeGenericInsertFailure {
                            message += " This usually means the email or SSN/Passport number is already registered to another owner for this merchant. Double-check those fields, or use \"Edit\" on the existing owner instead of adding a new one."
                        }
                        self.apiErrorMsg  = message
                        self.showAPIError = true
                    }
                }
            }
        )
    }
}
