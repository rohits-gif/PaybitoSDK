//
//  ShippingViewModel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 19/05/26.
//

//  ShippingViewModel.swift

import Foundation
import Combine

class ShippingViewModel: ObservableObject {

    // MARK: - Published
    @Published var profiles:   [Shipping.Profile] = []
    @Published var isLoading   = false
    @Published var isSaving    = false
    @Published var deletingId: Int? = nil

    @Published var toastMessage: String? = nil
    @Published var toastIsError          = false

    private let service = ShippingService.shared

    // MARK: - Load All
    func loadAll() {
        print("🚀 [ShippingVM] loadAll")
        isLoading = true

        service.fetchAll { [weak self]
            (result: Swift.Result<Shipping.FetchAllResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let res):
                    print("✅ [ShippingVM] fetchAll error:\(res.error) count:\(res.data?.count ?? 0)")
                    guard res.error == 0 else {
                        self.toast(res.message ?? "Failed to load profiles", isError: true)
                        return
                    }
                    self.profiles = (res.data ?? []).map { self.mapRecord($0) }
                    print("✅ [ShippingVM] profiles: \(self.profiles.count)")
                    self.profiles.forEach {
                        print("   🚚 \($0.name) shipping:\($0.shippingHandling)% tax:\($0.taxRate)% default:\($0.isDefault)")
                    }
                case .failure(let err):
                    print("❌ [ShippingVM] fetchAll: \(err)")
                    self.toast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Create
    func createProfile(
        name: String,
        shippingHandling: String,
        taxRate: String,
        isDefault: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        guard let shipping = Double(shippingHandling),
              let tax      = Double(taxRate) else {
            toast("Invalid shipping or tax rate value", isError: true)
            completion(false)
            return
        }

        print("🚀 [ShippingVM] createProfile: \(name) shipping:\(shipping) tax:\(tax) default:\(isDefault)")
        isSaving = true

        let payload = Shipping.CreatePayload(
            name:             name,
            shippingHandling: shipping,
            taxRate:          tax,
            isDefaultProfile: isDefault ? 1 : 0
        )

        service.create(payload: payload) { [weak self]
            (result: Swift.Result<Shipping.MutateResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    print("✅ [ShippingVM] create error:\(res.error) msg:\(res.message ?? "")")
                    if res.error == "0" {
                        self.toast(res.message ?? "Profile created successfully", isError: false)
                        self.loadAll()
                        completion(true)
                    } else {
                        self.toast(res.message ?? "Failed to create profile", isError: true)
                        completion(false)
                    }
                case .failure(let err):
                    print("❌ [ShippingVM] create: \(err)")
                    self.toast(err.localizedDescription, isError: true)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Update
    func updateProfile(
        id: Int,
        name: String,
        shippingHandling: String,
        taxRate: String,
        isDefault: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        guard let shipping = Double(shippingHandling),
              let tax      = Double(taxRate) else {
            toast("Invalid shipping or tax rate value", isError: true)
            completion(false)
            return
        }

        print("🚀 [ShippingVM] updateProfile id:\(id) name:\(name) shipping:\(shipping) tax:\(tax) default:\(isDefault)")
        isSaving = true

        let payload = Shipping.UpdatePayload(
            id:               id,
            name:             name,
            shippingHandling: shipping,
            taxRate:          tax,
            isDefaultProfile: isDefault ? 1 : 0
        )

        service.update(payload: payload) { [weak self]
            (result: Swift.Result<Shipping.MutateResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    print("✅ [ShippingVM] update error:\(res.error) msg:\(res.message ?? "")")
                    if res.error == "0" {
                        self.toast(res.message ?? "Profile updated successfully", isError: false)
                        self.loadAll()
                        completion(true)
                    } else {
                        self.toast(res.message ?? "Failed to update profile", isError: true)
                        completion(false)
                    }
                case .failure(let err):
                    print("❌ [ShippingVM] update: \(err)")
                    self.toast(err.localizedDescription, isError: true)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Delete
    func deleteProfile(id: Int) {
        print("🚀 [ShippingVM] deleteProfile id:\(id)")
        deletingId = id

        service.delete(id: id) { [weak self]
            (result: Swift.Result<Shipping.DeleteResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.deletingId = nil
                switch result {
                case .success(let res):
                    print("✅ [ShippingVM] delete error:\(res.error) msg:\(res.message ?? "")")
                    if res.error == 0 {
                        self.toast(res.message ?? "Profile deleted", isError: false)
                        self.profiles.removeAll { $0.id == id }
                    } else {
                        self.toast(res.message ?? "Failed to delete profile", isError: true)
                    }
                case .failure(let err):
                    print("❌ [ShippingVM] delete: \(err)")
                    self.toast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Map API record → UI model
    private func mapRecord(_ rec: Shipping.ProfileRecord) -> Shipping.Profile {
        print("   mapRecord id:\(rec.id) name:\(rec.profileName) shipping:\(rec.handlingFeeValue ?? 0) tax:\(rec.taxRate ?? 0)")
        return Shipping.Profile(
            id:               rec.id,
            name:             rec.profileName,
            shippingHandling: formatRate(rec.handlingFeeValue),
            taxRate:          formatRate(rec.taxRate),
            isDefault:        (rec.isDefaultProfile ?? 0) == 1,
            isActive:         (rec.isActive ?? 1) == 1,
            createdAt:        rec.createdAt
        )
    }

    private func formatRate(_ value: Double?) -> String {
        guard let v = value else { return "0.00" }
        return String(format: "%.2f", v)
    }

    // MARK: - Toast
    func toast(_ msg: String, isError: Bool) {
        toastIsError  = isError
        toastMessage  = msg
    }

    // MARK: - Validation (mirrors web validatePercent)
    func validate(name: String, shipping: String, tax: String) -> [String: String] {
        var errors: [String: String] = [:]

        let trimmed = name.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            errors["name"] = "Profile name is required"
        } else if trimmed.count < 2 || trimmed.count > 100 {
            errors["name"] = "Profile name must be 2–100 characters"
        } else if trimmed.range(of: "^[a-zA-Z0-9 \\-&]+$", options: .regularExpression) == nil {
            errors["name"] = "Only letters, numbers, spaces, hyphens, and & are allowed"
        }

        if let err = validatePercent(shipping, label: "Shipping (%)") {
            errors["shipping"] = err
        }
        if let err = validatePercent(tax, label: "Tax Rate (%)") {
            errors["tax"] = err
        }

        return errors
    }

    private func validatePercent(_ val: String, label: String) -> String? {
        let trimmed = val.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return "\(label) is required" }
        guard let num = Double(trimmed) else { return "Enter a valid number" }
        if num < 0 || num > 100 { return "Value must be between 0% and 100%" }
        // Max 2 decimal places
        let parts = trimmed.split(separator: ".")
        if parts.count == 2 && parts[1].count > 2 {
            return "Maximum 2 decimal places allowed"
        }
        return nil
    }
}
