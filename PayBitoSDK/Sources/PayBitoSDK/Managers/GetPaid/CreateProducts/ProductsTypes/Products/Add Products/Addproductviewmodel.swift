import Foundation
import Combine

// MARK: - AddProductViewModel

@MainActor
final class AddProductViewModel: ObservableObject {

    // ── Published UI state ─────────────────────────────────────────────────
    @Published var formData        = AddProductFormData()
    @Published var isLoading       = false
    @Published var successMessage: String? = nil
    @Published var errorMessage:   String? = nil
    @Published var shouldDismiss:  Bool    = false

    // ── Auth ───────────────────────────────────────────────────────────────
    private var merchantId: Int {
        let raw = UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0"
        let value = Int(raw) ?? 0
        debugPrint("🔑 [AddProductViewModel] merchantId = \(value)")
        return value
    }

    // ── Service ────────────────────────────────────────────────────────────
    private let service = AddProductService.shared

    // ============================================================
    // MARK: - Save / Submit
    // Flow:
    //   1. Validate form
    //   2. If user picked a local photo (data: URI) → upload image first
    //   3. Replace imageURL with S3 URL returned by server
    //   4. Register product with final imageUrl
    // ============================================================

    func saveProduct() {
        guard validate() else { return }

        isLoading      = true
        successMessage = nil
        errorMessage   = nil

        // ── Always register product first, then upload image if needed ──
        registerProduct(withProductId: nil)
    }

    private func registerProduct(withProductId preGeneratedId: String?) {
        let request = buildRequest(productId: preGeneratedId)
        debugPrint("🔨 [AddProductViewModel] Registering product for merchant \(merchantId)")

        service.registerProduct(request: request) { [weak self] (result: Swift.Result<AddProductResponse, Error>) in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let response):
                    if response.status {
                        // ── Get the real productId assigned by the server ──────
                        let registeredProductId = response.data?.products.first?.productId

                        // ── Check if user picked a local photo ────────────────
                        let rawImageURL = self.formData.imageURL.trimmingCharacters(in: .whitespaces)

                        if rawImageURL.hasPrefix("data:image"),
                           let commaIdx  = rawImageURL.firstIndex(of: ","),
                           let imageData = Data(base64Encoded: String(rawImageURL[rawImageURL.index(after: commaIdx)...])),
                           let productId = registeredProductId {

                            debugPrint("🖼️  [AddProductViewModel] Product registered — now uploading image for \(productId)")

                            // ── Upload image using the real server productId ───
                            self.service.uploadImage(productId: productId, imageData: imageData) { [weak self] imgResult in
                                guard let self else { return }
                                Task { @MainActor in
                                    self.isLoading = false
                                    switch imgResult {
                                    case .success(let s3URL):
                                        debugPrint("✅ [AddProductViewModel] Image uploaded: \(s3URL)")
                                        // Product is already registered — just show success
                                        self.successMessage = response.message
                                        self.resetForm()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                                            self?.shouldDismiss = true
                                        }
                                    case .failure(let error):
                                        // Product was saved but image upload failed — still success
                                        debugPrint("⚠️  [AddProductViewModel] Image upload failed (product saved): \(error)")
                                        self.successMessage = response.message + " (image not uploaded)"
                                        self.resetForm()
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                                            self?.shouldDismiss = true
                                        }
                                    }
                                }
                            }

                        } else {
                            // ── No local photo — just show success ────────────
                            self.isLoading = false
                            self.successMessage = response.message
                            self.resetForm()
                            debugPrint("🎉 [AddProductViewModel] Product saved (no image): \(response.message)")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                                self?.shouldDismiss = true
                            }
                        }

                    } else {
                        self.isLoading    = false
                        self.errorMessage = response.message
                        debugPrint("⚠️  [AddProductViewModel] status=false: \(response.message)")
                    }

                case .failure(let error):
                    self.isLoading    = false
                    self.errorMessage = error.localizedDescription
                    debugPrint("💥 [AddProductViewModel] Network error: \(error.localizedDescription)")
                }
            }
        }
    }

    // ============================================================
    // MARK: - Validation
    // ============================================================

    private func validate() -> Bool {
        guard !formData.name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Product name is required."
            debugPrint("⚠️  [AddProductViewModel] Validation failed: name empty")
            return false
        }
        guard !formData.prices.isEmpty else {
            errorMessage = "At least one price entry is required."
            debugPrint("⚠️  [AddProductViewModel] Validation failed: no prices")
            return false
        }
        for price in formData.prices {
            guard let amount = Double(price.amount), amount > 0 else {
                errorMessage = "Enter a valid amount for all prices."
                debugPrint("⚠️  [AddProductViewModel] Validation failed: bad amount '\(price.amount)'")
                return false
            }
        }
        debugPrint("✅ [AddProductViewModel] Validation passed")
        return true
    }

    // ============================================================
    // MARK: - Build Request
    // ============================================================

    private func buildRequest(productId preGeneratedId: String? = nil) -> AddProductRequest {

        var attributesDict: [String: [String]] = [:]
        for attr in formData.attributes where !attr.name.isEmpty {
            attributesDict[attr.name] = attr.values
        }

        var metaDict: [String: String] = [:]
        for m in formData.metadata where !m.key.isEmpty {
            metaDict[m.key] = m.value
        }

        let prices: [PricePayload] = formData.prices.map { entry in
            let amount = Double(entry.amount) ?? 0.0
            return PricePayload(
                isDefault:     entry.isDefault,
                priceType:     entry.type.rawValue,
                intervalType:  entry.type == .subscription ? "month" : nil,
                intervalCount: entry.type == .subscription ? 1       : nil,
                trialDays:     0,
                totalCycles:   "0",
                retryAttempts: nil,
                retryInterval: nil,
                variant:       entry.variant,
                sku:           entry.sku,
                inventory:     InventoryPayload(
                                   track:    entry.trackInventory,
                                   quantity: entry.trackInventory ? entry.quantity : 0
                               ),
                currencies:    [CurrencyPayload(currency: entry.currency,
                                                amount:   amount,
                                                isDefault: true)]
            )
        }

        let productId = preGeneratedId ?? "PROD_\(Int64(Date().timeIntervalSince1970 * 1000))"

        // ── Always send empty imageUrl on register ─────────────────────────────
        // Image is uploaded separately AFTER product is registered,
        // using the real productId returned by the server.
        let imageUrlForRegister: String = {
            let raw = formData.imageURL.trimmingCharacters(in: .whitespaces)
            // If it's a local data URI → will be uploaded after register, send empty
            if raw.hasPrefix("data:") { return "" }
            // If it's a real https:// URL → send it directly
            return raw
        }()

        let product = ProductPayload(
            productId:   productId,
            productType: "PAYMENT_LINK",
            name:        formData.name,
            status:      formData.status.rawValue,
            description: formData.description,
            imageUrl:    imageUrlForRegister,
            attributes:  attributesDict,
            metadata:    metaDict,
            prices:      prices
        )

        debugPrint("📦 [AddProductViewModel] productId=\(productId) name=\(product.name) imageUrl='\(imageUrlForRegister.prefix(60))'")

        return AddProductRequest(merchantId: merchantId, products: [product])
    }
    
    
    // ============================================================
    // MARK: - Helpers
    // ============================================================

    func resetForm() {
        formData = AddProductFormData()
        debugPrint("🔄 [AddProductViewModel] Form reset")
    }

    func dismissError()   { errorMessage   = nil }
    func dismissSuccess() { successMessage = nil }

    // ── Attribute helpers ──────────────────────────────────────────────────
    func addAttribute() {
        formData.attributes.append(APAttributeEntry())
    }
    func removeAttribute(id: UUID) {
        formData.attributes.removeAll { $0.id == id }
    }
    func addAttributeValue(id: UUID, value: String) {
        guard let i = formData.attributes.firstIndex(where: { $0.id == id }) else { return }
        let v = value.trimmingCharacters(in: .whitespaces)
        guard !v.isEmpty else { return }
        formData.attributes[i].values.append(v)
    }

    // ── Price helpers ──────────────────────────────────────────────────────
    func addPrice()              { formData.prices.append(APPriceEntry()) }
    func removePrice(id: UUID)   { formData.prices.removeAll { $0.id == id } }

    // ── Metadata helpers ───────────────────────────────────────────────────
    func addMeta()               { formData.metadata.append(APMetaEntry()) }
    func removeMeta(id: UUID)    { formData.metadata.removeAll { $0.id == id } }
}
