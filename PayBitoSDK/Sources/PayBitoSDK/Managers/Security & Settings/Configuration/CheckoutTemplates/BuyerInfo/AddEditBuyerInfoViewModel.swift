import Foundation
import Combine

final class AddEditBuyerInfoViewModel: ObservableObject {

    @Published var profileName: String = ""
    @Published var stdFields: [StdField] = StdField.defaultMap
    @Published var customFields: [CustomField] = []
    @Published var isDefaultProfile: Bool = false
    @Published var expandedCustomIndex: Int? = nil

    @Published var isSaving: Bool = false
    @Published var nameError: String = ""
    @Published var toast: ToastState? = nil
    @Published var didSaveSuccessfully: Bool = false

    let maxCustomFields = 3
    let fieldTypes = [
        "text",
        "number",
        "email",
        "phone",
        "date",
        "textarea",
        "dropdown",
        "checkbox"
    ]

    private let editingProfile: BuyerInfoProfile?
    private let service: BuyerInfoService

    private var merchantId: String {
        UserDefaults.standard.string(forKey: "merchant_id") ?? ""
    }

    var isEditing: Bool {
        editingProfile != nil
    }

    init(
        editing: BuyerInfoProfile? = nil,
        service: BuyerInfoService = .shared
    ) {
        self.editingProfile = editing
        self.service = service

        if let p = editing {
            profileName = p.name
            stdFields = p.stdFields
            customFields = p.customFields
            isDefaultProfile = p.isDefaultProfile
        }
    }

    func toggleStdField(key: String, enabled: Bool) {
        if let idx = stdFields.firstIndex(where: { $0.key == key }) {
            stdFields[idx].enabled = enabled
        }
    }

    func addCustomField() {
        guard customFields.count < maxCustomFields else { return }

        let newField = CustomField(
            customFieldId: customFields.count + 1,
            label: "",
            type: "text",
            required: false,
            placeholder: "",
            helpText: "",
            options: ""
        )

        customFields.append(newField)
        expandedCustomIndex = customFields.count - 1
    }

    func removeCustomField(at index: Int) {
        guard customFields.indices.contains(index) else { return }

        customFields.remove(at: index)

        if expandedCustomIndex == index {
            expandedCustomIndex = nil
        } else if let expanded = expandedCustomIndex, expanded > index {
            expandedCustomIndex = expanded - 1
        }
    }

    func updateCustomField<T>(
        at index: Int,
        keyPath: WritableKeyPath<CustomField, T>,
        value: T
    ) {
        customFields[index][keyPath: keyPath] = value
    }

    func toggleExpandCustom(at index: Int) {
        expandedCustomIndex = (expandedCustomIndex == index) ? nil : index
    }

    private func validate() -> Bool {
        let trimmed = profileName.trimmingCharacters(in: .whitespaces)

        if trimmed.isEmpty {
            nameError = "Profile name is required"
            return false
        }

        if trimmed.count < 2 || trimmed.count > 100 {
            nameError = "Profile name must be 2–100 characters"
            return false
        }

        let allowed = CharacterSet.alphanumerics.union(
            CharacterSet(charactersIn: " -&")
        )

        if trimmed.unicodeScalars.contains(where: {
            !allowed.contains($0)
        }) {
            nameError = "Only letters, numbers, spaces, hyphens, and & are allowed"
            return false
        }

        nameError = ""
        return true
    }

    func save(completion: @escaping () -> Void) {
        guard validate() else { return }

        isSaving = true

        let profile = BuyerInfoProfile(
            id: editingProfile?.id ?? 0,
            merchantId: merchantId,
            name: profileName.trimmingCharacters(in: .whitespaces),
            isDefaultProfile: isDefaultProfile,
            createdAt: editingProfile?.createdAt,
            stdFields: stdFields,
            customFields: customFields
        )

        if let existing = editingProfile {
            // UPDATE
            service.update(
                id: existing.id,
                profile: profile
            ) { [weak self] result in

                DispatchQueue.main.async {
                    guard let self = self else { return }

                    self.isSaving = false

                    switch result {
                    case .success:
                        self.toast = ToastState(
                            message: "Profile updated successfully",
                            isSuccess: true
                        )
                        self.didSaveSuccessfully = true
                        completion()

                    case .failure(let error):
                        self.toast = ToastState(
                            message: error.localizedDescription,
                            isSuccess: false
                        )
                    }
                }
            }

        } else {
            // CREATE
            service.save(
                profile: profile
            ) { [weak self] result in

                DispatchQueue.main.async {
                    guard let self = self else { return }

                    self.isSaving = false

                    switch result {
                    case .success:
                        self.toast = ToastState(
                            message: "Profile created successfully",
                            isSuccess: true
                        )
                        self.didSaveSuccessfully = true
                        completion()

                    case .failure(let error):
                        self.toast = ToastState(
                            message: error.localizedDescription,
                            isSuccess: false
                        )
                    }
                }
            }
        }
    }

    func clearNameError() {
        if !nameError.isEmpty {
            nameError = ""
        }
    }
}
