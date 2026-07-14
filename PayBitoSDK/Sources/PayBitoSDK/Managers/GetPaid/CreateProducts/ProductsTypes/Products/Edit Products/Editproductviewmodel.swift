import Foundation

// MARK: - EPVMPrice

struct EPVMPrice: Identifiable {
    let id:        UUID
    var priceId:   Int?
    var kind:      EPVMPriceKind
    var amount:    String
    var currency:  String
    var sku:       String
    var qty:       Int
    var trackQty:  Bool
    var isDefault: Bool
    var variant:   [String: String]

    init(
        id:        UUID          = UUID(),
        priceId:   Int?          = nil,
        kind:      EPVMPriceKind = .oneTime,
        amount:    String        = "",
        currency:  String        = "USD",
        sku:       String        = "",
        qty:       Int           = 0,
        trackQty:  Bool          = false,
        isDefault: Bool          = false,
        variant:   [String: String] = [:]
    ) {
        self.id        = id
        self.priceId   = priceId
        self.kind      = kind
        self.amount    = amount
        self.currency  = currency
        self.sku       = sku
        self.qty       = qty
        self.trackQty  = trackQty
        self.isDefault = isDefault
        self.variant   = variant
    }
}

enum EPVMPriceKind: Equatable {
    case oneTime
    case subscription

    var apiValue: String {
        switch self {
        case .oneTime:      return "one-time"
        case .subscription: return "subscription"
        }
    }
}

// MARK: - View State

enum EditProductViewState: Equatable {
    case idle
    case loading
    case success(message: String)
    case failure(message: String)
}

// MARK: - ViewModel

@MainActor
final class EditProductViewModel: ObservableObject {

    // MARK: Published — form fields
    @Published var productName:  String      = ""
    @Published var imageURL:     String      = ""
    @Published var statusActive: Bool        = true
    @Published var description:  String      = ""
    @Published var prices:       [EPVMPrice] = [EPVMPrice(isDefault: true)]
    @Published var metaKeys:     [String]    = [""]
    @Published var metaValues:   [String]    = [""]

    // MARK: Published — UI state
    @Published var viewState:    EditProductViewState = .idle
    @Published var showAlert:    Bool   = false
    @Published var alertMessage: String = ""

    // ── Dismiss signal — EditProductView watches this to pop back ──────────
    @Published var shouldDismiss: Bool = false

    // MARK: Published — attribute seeding
    @Published var seedAttrs: [SeedAttr] = []

    // MARK: Config
    var productId: String = ""

    private var merchantId: Int {
        Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0
    }

    private let service: EditProductService

    init(service: EditProductService = .shared) {
        self.service = service
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Seed Attr
    // ─────────────────────────────────────────────────────────

    struct SeedAttr: Identifiable, Equatable {
        let id     = UUID()
        var name:   String
        var values: [String]
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Product Detail Response Models
    // ─────────────────────────────────────────────────────────

    struct ProductDetailResponse: Decodable {
        let status:  Bool?
        let message: String?
        let data:    ProductDetailData?
    }
    struct ProductDetailData: Decodable {
        let products: [ProductDetail]?
    }
    struct ProductDetail: Decodable {
        let productId:   String?
        let name:        String?
        let description: String?
        let imageUrl:    String?
        let status:      String?
        let attributes:  [String: [String]]?
        let metadata:    [String: String]?
        let prices:      [ProductDetailPrice]?
    }
    struct ProductDetailPrice: Decodable {
        let priceId:    Int?
        let priceType:  String?
        let sku:        String?
        let inventory:  ProductDetailInventory?
        let currencies: [ProductDetailCurrency]?
        var amount:   Double? { currencies?.first?.amount }
        var currency: String? { currencies?.first?.currency }
    }
    struct ProductDetailInventory: Decodable {
        let track:    Bool?
        let quantity: Int?
    }
    struct ProductDetailCurrency: Decodable {
        let currency:  String?
        let amount:    Double?
        let isDefault: Bool?
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Fetch Full Product Detail then Seed
    // ─────────────────────────────────────────────────────────

    func fetchAndSeed(api: PCAPIProduct) {
        productId    = api.productId
        productName  = api.name
        statusActive = api.status.lowercased() == "active"
        imageURL     = api.imageUrl ?? ""
        prices = [EPVMPrice(
            kind:      api.displayBillingType.lowercased().contains("sub") ? .subscription : .oneTime,
            amount:    String(format: "%.2f", api.displayAmount),
            currency:  api.displayCurrency,
            sku:       api.skuCode ?? "",
            qty:       0,
            trackQty:  api.isTracked,
            isDefault: true
        )]

        viewState = .loading

        let url = "https://service.hashcashconsultants.com/billbitcoins-v2/shopping/products?productId=\(api.productId)"
        var headers: [String: String] = [
            "Content-Type":     "application/json",
            "Accept":           "application/json",
            "Origin":           "https://trade.paybito.com",
            "Referer":          "https://trade.paybito.com/",
            "X-Requested-With": "XMLHttpRequest"
        ]
        if let token = UserDefaults.standard.string(forKey: "Baccess_token"), !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
        }
        if let uuid = UserDefaults.standard.string(forKey: "Buuid"), !uuid.isEmpty {
            headers["UUID"] = uuid
        }

        guard let request = makeRequest(url: url, headers: headers) else {
            viewState = .idle
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            DispatchQueue.main.async {
                guard let self else { return }
                self.viewState = .idle
                guard let data, error == nil else {
                    debugPrint("❌ [EditProductVM] Detail fetch error: \(error?.localizedDescription ?? "unknown")")
                    return
                }
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
                    let dataDict = json["data"] as? [String: Any]
                    let products = (dataDict?["products"] as? [[String: Any]]) ?? (json["products"] as? [[String: Any]]) ?? []
                    
                    if let p = products.first {
                        if let img = p["imageUrl"] as? String, !img.isEmpty { self.imageURL = img }
                        self.description = (p["description"] as? String) ?? ""

                        if let attrs = p["attributes"] as? [String: Any] {
                            var seedAttrs: [SeedAttr] = []
                            for (k, v) in attrs {
                                if let arr = v as? [String] {
                                    seedAttrs.append(SeedAttr(name: k, values: arr))
                                } else if let str = v as? String {
                                    seedAttrs.append(SeedAttr(name: k, values: [str]))
                                } else {
                                    seedAttrs.append(SeedAttr(name: k, values: ["\(v)"]))
                                }
                            }
                            self.seedAttrs = seedAttrs
                        }

                        if let meta = p["metadata"] as? [String: Any], !meta.isEmpty {
                            var keys: [String] = []
                            var values: [String] = []
                            for (k, v) in meta {
                                keys.append(k)
                                if let str = v as? String { values.append(str) }
                                else { values.append("\(v)") }
                            }
                            self.metaKeys = keys
                            self.metaValues = values
                        }

                        if let pricesArray = p["prices"] as? [[String: Any]], !pricesArray.isEmpty {
                            self.prices = pricesArray.enumerated().map { idx, dp in
                                let pType = (dp["priceType"] as? String) ?? (dp["type"] as? String) ?? ""
                                let isSub = pType.lowercased().contains("sub") || pType.lowercased().contains("recurring")
                                
                                let rInt = dp["priceId"] as? Int
                                let rStr = (dp["priceId"] as? String).flatMap(Int.init)
                                let pId = rInt ?? rStr
                                
                                // Parse currencies
                                var curAmount: Double = 0
                                var curCode: String = "USD"
                                if let currencies = dp["currencies"] as? [[String: Any]] {
                                    let primaryCur = currencies.first(where: { ($0["default"] as? Bool) == true || ($0["isDefault"] as? Bool) == true }) ?? currencies.first
                                    curCode = (primaryCur?["currency"] as? String) ?? "USD"
                                    curAmount = (primaryCur?["amount"] as? Double) ?? (primaryCur?["amount"] as? String).flatMap(Double.init) ?? 0
                                }
                                
                                // SKU and inventory might be at root or inside metadata
                                var sku = (dp["sku"] as? String) ?? ""
                                var track = (dp["inventory"] as? [String: Any])?["track"] as? Bool ?? false
                                var qty = (dp["inventory"] as? [String: Any])?["quantity"] as? Int ?? ((dp["inventory"] as? [String: Any])?["quantity"] as? String).flatMap(Int.init) ?? 0
                                var variantDict: [String: String] = [:]
                                
                                if let dpMeta = dp["metadata"] as? [String: Any] {
                                    if sku.isEmpty { sku = (dpMeta["sku"] as? String) ?? "" }
                                    if let inv = dpMeta["inventory"] as? [String: Any] {
                                        track = (inv["track"] as? Bool) ?? track
                                        qty = (inv["quantity"] as? Int) ?? (inv["quantity"] as? String).flatMap(Int.init) ?? qty
                                    }
                                    if let vDict = dpMeta["variant"] as? [String: Any] {
                                        for (vk, vv) in vDict {
                                            variantDict[vk] = "\(vv)"
                                        }
                                    }
                                }
                                
                                return EPVMPrice(
                                    priceId:   pId,
                                    kind:      isSub ? .subscription : .oneTime,
                                    amount:    String(format: "%.2f", curAmount),
                                    currency:  curCode,
                                    sku:       sku,
                                    qty:       qty,
                                    trackQty:  track,
                                    isDefault: idx == 0,
                                    variant:   variantDict
                                )
                            }
                        }
                        debugPrint("✅ [EditProductVM] Detail seeded — img: \(self.imageURL.prefix(60))")
                    }
                } catch {
                    debugPrint("❌ [EditProductVM] Detail parse error: \(error)")
                }
            }
        }.resume()
    }

    private func makeRequest(url: String, headers: [String: String]) -> URLRequest? {
        guard let u = URL(string: url) else { return nil }
        var req = URLRequest(url: u)
        req.httpMethod = "GET"
        headers.forEach { req.setValue($1, forHTTPHeaderField: $0) }
        return req
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Seed from PCEDProduct
    // ─────────────────────────────────────────────────────────

    func seed(from product: PCEDProduct) {
        productName  = product.name
        imageURL     = product.imageURL
        description  = product.desc
        statusActive = product.status == .active

        prices = product.prices.isEmpty
            ? [EPVMPrice(isDefault: true)]
            : product.prices.map { p in
                EPVMPrice(
                    kind:      p.kind == .subscription ? .subscription : .oneTime,
                    amount:    p.amount,
                    currency:  p.currency,
                    sku:       p.sku,
                    trackQty:  p.trackInventory,
                    isDefault: p.isDefault
                )
            }

        let metas  = product.meta.isEmpty ? [PCEDMeta()] : product.meta
        metaKeys   = metas.map { $0.key }
        metaValues = metas.map { $0.value }
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Validation
    // ─────────────────────────────────────────────────────────

    private func validate() -> String? {
        if productName.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Product name is required."
        }
        if productId.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Product ID is missing."
        }
        if merchantId == 0 {
            return "Merchant ID not found. Please log in again."
        }
        for (i, price) in prices.enumerated() {
            if (Double(price.amount) ?? -1) < 0 {
                return "Price #\(i + 1): enter a valid amount."
            }
        }
        return nil
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Build PUT Request
    // ─────────────────────────────────────────────────────────

    private func buildRequest(imageUrlOverride: String? = nil, attributes: [String: [String]] = [:]) -> EditProductRequest {
        var metaDict: [String: String] = [:]
        for (i, key) in metaKeys.enumerated() {
            let k = key.trimmingCharacters(in: .whitespaces)
            let v = i < metaValues.count ? metaValues[i].trimmingCharacters(in: .whitespaces) : ""
            if !k.isEmpty { metaDict[k] = v }
        }

        let priceRequests: [EditProductPriceRequest] = prices.map { p in
            EditProductPriceRequest(
                priceId:        p.priceId,
                isDefault:      p.isDefault,
                priceType:      p.kind.apiValue,
                sku:            p.sku,
                amount:         Double(p.amount) ?? 0,
                currency:       p.currency,
                trackInventory: p.trackQty,
                quantity:       p.qty,
                variant:        p.variant
            )
        }

        // Use override (post-upload S3 URL) or clean current imageURL
        let finalImageUrl: String = {
            if let override = imageUrlOverride { return override }
            let raw = imageURL.trimmingCharacters(in: .whitespaces)
            if raw.hasPrefix("data:") { return "" }
            return raw
        }()

        debugPrint("────────────────────────────────────────")
        debugPrint("🔨 [EditProductVM] buildRequest")
        debugPrint("   productName  : \(productName)")
        debugPrint("   description  : \(description)")
        debugPrint("   imageURL raw : \(imageURL.prefix(60))")
        debugPrint("   imageURL sent: \(finalImageUrl.prefix(80))")
        debugPrint("   status       : \(statusActive ? "ACTIVE" : "DRAFT")")
        debugPrint("   merchantId   : \(merchantId)")
        for (i, p) in priceRequests.enumerated() {
            debugPrint("   price[\(i)]: \(p.currencies.first?.currency ?? "") \(p.currencies.first?.amount ?? 0) sku=\(p.sku)")
        }
        debugPrint("   metadata     : \(metaDict)")
        debugPrint("────────────────────────────────────────")

        return EditProductRequest(
            merchantId:  merchantId,
            name:        productName.trimmingCharacters(in: .whitespaces),
            productType: "PAYMENT_LINK",
            description: description.trimmingCharacters(in: .whitespaces),
            imageUrl:    finalImageUrl,
            attributes:  attributes,
            metadata:    metaDict,
            status:      statusActive ? "ACTIVE" : "DRAFT",
            addPrices:   priceRequests
        )
    }

    // ─────────────────────────────────────────────────────────
    // MARK: - Update Product
    // Flow:
    //   1. Validate
    //   2. If local photo (data: URI) → upload image via EditProductService
    //   3. PUT update with S3 URL or existing URL
    //   4. On success → show alert, then resetState() triggers dismiss
    // ─────────────────────────────────────────────────────────

    func updateProduct(attributes: [String: [String]] = [:]) {
        if let err = validate() {
            alertMessage = err
            showAlert    = true
            return
        }

        viewState = .loading

        let rawURL = imageURL.trimmingCharacters(in: .whitespaces)

        if rawURL.hasPrefix("data:image"),
           let commaIdx  = rawURL.firstIndex(of: ","),
           let imageData = Data(base64Encoded: String(rawURL[rawURL.index(after: commaIdx)...])) {

            // ── Local photo → upload first using EditProductService ────────
            debugPrint("🖼️  [EditProductVM] Local photo — uploading for \(productId)")

            service.uploadImage(productId: productId, imageData: imageData) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let urlStr):
                    debugPrint("✅ [EditProductVM] Uploaded → \(urlStr)")
                    self.performUpdate(imageUrlOverride: urlStr, attributes: attributes)
                case .failure(let error):
                    debugPrint("❌ [EditProductVM] Image upload failed: \(error)")
                    // fallback to no-image or existing
                    self.performUpdate(imageUrlOverride: nil, attributes: attributes)
                }
            }
        } else {
            // No new photo
            performUpdate(imageUrlOverride: nil, attributes: attributes)
        }
    }

    private func performUpdate(imageUrlOverride: String?, attributes: [String: [String]]) {
        debugPrint("🚀 [EditProductVM] performUpdate — productId: \(productId)")
        let req = buildRequest(imageUrlOverride: imageUrlOverride, attributes: attributes)

        service.updateProduct(productId: productId, request: req) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                debugPrint("🎉 [EditProductVM] Success: \(response.message)")
                self.viewState    = .success(message: response.message)
                self.alertMessage = response.message
                self.showAlert    = true

            case .failure(let error):
                debugPrint("💥 [EditProductVM] Failed: \(error.localizedDescription)")
                self.viewState    = .failure(message: error.localizedDescription)
                self.alertMessage = error.localizedDescription
                self.showAlert    = true
            }
        }
    }

    // MARK: - Price Helpers

    func addPrice() {
        prices.append(EPVMPrice())
        debugPrint("➕ [EditProductVM] Price added — total: \(prices.count)")
    }

    func removePrice(at index: Int) {
        guard prices.indices.contains(index), !prices[index].isDefault else {
            debugPrint("⚠️  [EditProductVM] Cannot remove default price")
            return
        }
        prices.remove(at: index)
        debugPrint("🗑  [EditProductVM] Price removed — total: \(prices.count)")
    }

    // MARK: - Metadata Helpers

    func addMetaRow() {
        metaKeys.append("")
        metaValues.append("")
        debugPrint("➕ [EditProductVM] Meta row added — total: \(metaKeys.count)")
    }

    func removeMetaRow(at index: Int) {
        guard metaKeys.indices.contains(index) else { return }
        metaKeys.remove(at: index)
        metaValues.remove(at: index)
        debugPrint("🗑  [EditProductVM] Meta row removed — total: \(metaKeys.count)")
    }

    // MARK: - Reset
    // Called when user taps OK on alert — triggers dismiss on success

    func resetState() {
        let wasSuccess: Bool
        if case .success = viewState { wasSuccess = true } else { wasSuccess = false }

        viewState    = .idle
        showAlert    = false
        alertMessage = ""

        if wasSuccess {
            shouldDismiss = true
        }
    }
}
