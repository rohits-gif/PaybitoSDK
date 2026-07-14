import SwiftUI
import PhotosUI

// MARK: - Color Helper
private extension Color {
    init(pcHex hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: h).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch h.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255,
                  blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Tokens
private enum PC {
    static let bg       = Color(pcHex: "#0D1117")
    static let card     = Color(pcHex: "#161B22")
    static let inputBg  = Color(pcHex: "#1C2333")
    static let field    = Color(pcHex: "#21262D")
    static let tabOff   = Color(pcHex: "#21262D")
    static let purple   = Color(pcHex: "#7C5CFC")
    static let orange   = Color(pcHex: "#F97316")
    static let blue     = Color(pcHex: "#3B82F6")
    static let white    = Color.white
    static let sub      = Color(pcHex: "#8B949E")
    static let muted    = Color(pcHex: "#484F58")
    static let border   = Color(pcHex: "#30363D")
    static let gold     = Color(pcHex: "#F5A623")
    static let red      = Color(pcHex: "#EF4444")
    static let cancelBg = Color(pcHex: "#2D3340")
}

// MARK: - Focus Field Enum
enum APField: Hashable {
    case productName
    case imageURL
    case description
    case attrName(Int)
    case attrValue(Int)
    case priceAmount(Int)
    case priceSKU(Int)
    case priceQty(Int)
    case metaKey(Int)
    case metaValue(Int)
}

// MARK: - Internal APM Models
private enum APM {
    enum Status: Equatable { case active, draft }
    enum PriceKind: Equatable { case oneTime, subscription }

    struct Attr: Identifiable {
        let id = UUID()
        var name: String     = ""
        var values: [String] = []
    }
    struct Meta: Identifiable {
        let id = UUID()
        var key: String   = ""
        var value: String = ""
    }
}

private extension APM.Status {
    init(from edStatus: PCEDStatus) {
        switch edStatus {
        case .active:   self = .active
        case .draft:    self = .draft
        case .archived: self = .draft
        }
    }
}

// MARK: - Root View

struct EditProductView: View {
    
    private let apiProduct: PCAPIProduct?
    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm = EditProductViewModel()
    @State private var tab = 0
    
    init(apiProduct: PCAPIProduct) {
        self.apiProduct = apiProduct
    }
    
    init() {
        self.apiProduct = nil
    }
    
    var body: some View {
        ZStack {
            PC.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                APHeader(onBack: { dismiss() })
                HStack(spacing: 8) {
                    APTab(title: "Products",   n: 12, on: tab == 0) { tab = 0 }
                    APTab(title: "Catalogues", n: 1,  on: tab == 1) { tab = 1 }
                    Spacer()
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
                
                if tab == 0 {
                    APForm(vm: vm, isEditing: apiProduct != nil, onBack: { dismiss() })
                } else {
                    APCatalogues()
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if let api = apiProduct {
                vm.fetchAndSeed(api: api)
            } else {
                if vm.prices.isEmpty { vm.prices = [EPVMPrice(isDefault: true)] }
            }
        }
        .alert(alertTitle, isPresented: $vm.showAlert) {
            Button("OK") { vm.resetState() }
        } message: {
            Text(vm.alertMessage)
        }
        // ── Navigate back to CreateProductView after successful update ─────────
        .onChange(of: vm.shouldDismiss) { newValue in
            if newValue { dismiss() }
        }
    }


    private var alertTitle: String {
        switch vm.viewState {
        case .success: return "✅ Success"
        case .failure: return "❌ Error"
        default:       return "Notice"
        }
    }
}

// MARK: - Header

private struct APHeader: View {
    let onBack: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onBack) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PC.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Edit Product")
                    .font(.system(size: 20, weight: .bold)).foregroundColor(PC.white)
                Text("Manage products, pricing, and catalogues")
                    .font(.system(size: 13)).foregroundColor(PC.sub)
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.top, 16).padding(.bottom, 8)
    }
}

// MARK: - Tab Button

private struct APTab: View {
    let title: String; let n: Int; let on: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title).font(.system(size: 14, weight: .semibold))
                    .foregroundColor(on ? .white : PC.sub)
                Text("\(n)").font(.system(size: 12, weight: .medium))
                    .foregroundColor(on ? .white : PC.sub)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(on ? PC.purple.opacity(0.35) : PC.field).clipShape(Capsule())
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(on ? PC.purple : PC.tabOff).clipShape(Capsule())
        }
    }
}

// MARK: - URL Image Preview

private struct URLImagePreview: View {
    let urlString: String

    private var url: URL? {
        guard !urlString.isEmpty, urlString.hasPrefix("http") else { return nil }
        return URL(string: urlString)
    }

    var body: some View {
        if let url = url {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(PC.purple.opacity(0.35), lineWidth: 1)
                        )
                case .failure:
                    EmptyView()
                default:
                    ProgressView().frame(width: 72, height: 72)
                }
            }
        }
    }
}

// MARK: - Image Input Row

struct APImageInputRow: View {
    @Binding var imageURL: String

    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage? = nil
    @State private var isLoadingImage = false
    @FocusState private var urlFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let img = pickedImage {
                // ── Library photo selected ─────────────────────────
                HStack(spacing: 12) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(PC.purple.opacity(0.5), lineWidth: 1.5)
                        )
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Image selected from library")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(PC.white)
                        Button(action: {
                            pickedImage = nil
                            pickerItem  = nil
                            imageURL    = ""
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill").font(.system(size: 13))
                                Text("Remove").font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(PC.red)
                        }
                    }
                    Spacer()
                    PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(PC.purple)
                            .frame(width: 40, height: 40)
                            .background(PC.purple.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(12)
                .background(PC.field)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(PC.purple.opacity(0.35), lineWidth: 1))

            } else {
                // ── URL input + photo picker ───────────────────────
                HStack(spacing: 8) {
                    TextField("", text: $imageURL,
                              prompt: Text("https://example.com/image.jpg").foregroundColor(PC.muted))
                        .font(.system(size: 14))
                        .foregroundColor(PC.white)
                        .tint(PC.purple)
                        .focused($urlFocused)
                        .padding(.horizontal, 14).padding(.vertical, 13)
                        .frame(minHeight: 50)
                        .background(RoundedRectangle(cornerRadius: 10).fill(PC.field))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(urlFocused ? PC.purple : PC.border,
                                        lineWidth: urlFocused ? 1.8 : 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                        .animation(.easeInOut(duration: 0.15), value: urlFocused)

                    PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if isLoadingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: PC.purple))
                                    .scaleEffect(0.85)
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(PC.purple)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .background(PC.purple.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PC.purple.opacity(0.35), lineWidth: 1))
                    }
                    .disabled(isLoadingImage)
                }

                // ── Remote URL preview ─────────────────────────────
                URLImagePreview(urlString: imageURL)

                Text("Paste a URL or tap \(Image(systemName: "photo.badge.plus")) to pick from your library")
                    .font(.system(size: 11))
                    .foregroundColor(PC.muted)
                    .padding(.leading, 2)
            }
        }
        // ── Load picked photo ──────────────────────────────────────
        .onChange(of: pickerItem) { newItem in
            guard let newItem else { return }
            isLoadingImage = true
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        pickedImage    = uiImage
                        if let jpeg = uiImage.jpegData(compressionQuality: 0.8) {
                            imageURL = "data:image/jpeg;base64," + jpeg.base64EncodedString()
                        }
                        isLoadingImage = false
                    }
                } else {
                    await MainActor.run { isLoadingImage = false }
                }
            }
        }
        // ── Restore local photo when imageURL is a data URI ────────
        .onAppear {
            guard imageURL.hasPrefix("data:image") else { return }
            let parts = imageURL.components(separatedBy: ",")
            if parts.count == 2,
               let data = Data(base64Encoded: parts[1]),
               let uiImage = UIImage(data: data) {
                pickedImage = uiImage
            }
        }
        // ── When VM seeds a remote URL, clear any stale local photo ─
        .onChange(of: imageURL) { newURL in
            if newURL.hasPrefix("http") {
                pickedImage = nil
                pickerItem  = nil
            }
        }
    }
}

// MARK: - Form

private struct APForm: View {

    @ObservedObject var vm: EditProductViewModel
    let isEditing: Bool
    let onBack:    () -> Void

    @FocusState private var focus: APField?
    @State private var attrs: [APM.Attr] = []   // starts empty; seeded via onChange

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                Button(action: onBack) {
                    Label("Back to Products", systemImage: "arrow.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(PC.purple)
                }
                .padding(.horizontal, 16)

                Text(isEditing
                     ? "Edit — \(vm.productName.isEmpty ? "Product" : vm.productName)"
                     : "Add Product")
                    .font(.system(size: 24, weight: .bold)).foregroundColor(PC.white)
                    .lineLimit(1).truncationMode(.tail)
                    .padding(.horizontal, 16)

                // ── BASIC INFO ────────────────────────────────────
                APCard {
                    APSecTitle("BASIC INFO")

                    APLabel("Product Name *")
                    APTextField(placeholder: "e.g. Classic T-Shirt",
                                text: $vm.productName,
                                field: .productName, focus: $focus)

                    APLabel("Image (optional)").padding(.top, 12)
                    APImageInputRow(imageURL: $vm.imageURL)

                    APLabel("Status").padding(.top, 12)
                    HStack(spacing: 20) {
                        APRadio("Active", on:  vm.statusActive) { vm.statusActive = true  }
                        APRadio("Draft",  on: !vm.statusActive) { vm.statusActive = false }
                    }.padding(.top, 2)

                    APLabel("Description (optional)").padding(.top, 12)
                    APTextArea(placeholder: "Describe your product…",
                               text: $vm.description,
                               field: .description, focus: $focus)
                }

                // ── ATTRIBUTES & VARIANTS ─────────────────────────
                APCard {
                    HStack {
                        APSecTitle("ATTRIBUTES & VARIANTS")
                        APOptBadge()
                        Spacer()
                        APAddBtn("+ Add Attribute") { attrs.append(APM.Attr()) }
                    }
                    Text("Define attributes like size, color, etc.")
                        .font(.system(size: 13)).foregroundColor(PC.sub).padding(.top, 4)

                    if attrs.isEmpty {
                        Text("No attributes yet. Tap + Add Attribute to define size, color, etc.")
                            .font(.system(size: 13))
                            .foregroundColor(PC.muted)
                            .padding(.top, 8)
                    } else {
                        ForEach(attrs.indices, id: \.self) { i in
                            APAttrRow(attr: $attrs[i], idx: i, focus: $focus) {
                                attrs.remove(at: i)
                            }.padding(.top, 10)
                        }
                    }
                }

                // ── PRICING ───────────────────────────────────────
                APCard {
                    HStack {
                        APSecTitle("PRICING")
                        Spacer()
                        APAddBtn("+ Add Price") { vm.addPrice() }
                    }
                    ForEach(vm.prices.indices, id: \.self) { i in
                        APPriceRow(price: $vm.prices[i], idx: i, attrs: attrs, focus: $focus) {
                            vm.removePrice(at: i)
                        }.padding(.top, 10)
                    }
                }

                // ── METADATA ──────────────────────────────────────
                APCard {
                    HStack {
                        APSecTitle("METADATA")
                        APOptBadge()
                        Spacer()
                    }
                    Text("Extra key-value pairs sent as the metadata field.")
                        .font(.system(size: 13)).foregroundColor(PC.sub).padding(.top, 4)

                    ForEach(vm.metaKeys.indices, id: \.self) { i in
                        APMetaRow(
                            key: Binding(
                                get: { vm.metaKeys.indices.contains(i)   ? vm.metaKeys[i]   : "" },
                                set: { if vm.metaKeys.indices.contains(i)   { vm.metaKeys[i]   = $0 } }
                            ),
                            value: Binding(
                                get: { vm.metaValues.indices.contains(i) ? vm.metaValues[i] : "" },
                                set: { if vm.metaValues.indices.contains(i) { vm.metaValues[i] = $0 } }
                            ),
                            idx: i, focus: $focus
                        ) { vm.removeMetaRow(at: i) }.padding(.top, 8)
                    }
                    Button(action: { vm.addMetaRow() }) {
                        Text("+ Add Metadata")
                            .font(.system(size: 14, weight: .medium)).foregroundColor(PC.purple)
                    }.padding(.top, 10)
                }

                // ── ACTION BUTTONS ────────────────────────────────
                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Text("CANCEL")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(PC.white)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(PC.cancelBg).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Button(action: {
                        focus = nil
                        var attributesDict: [String: [String]] = [:]
                        for attr in attrs {
                            let k = attr.name.trimmingCharacters(in: .whitespaces)
                            if !k.isEmpty {
                                attributesDict[k] = attr.values.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                            }
                        }
                        vm.updateProduct(attributes: attributesDict)
                    }) {
                        ZStack {
                            Text(isEditing ? "UPDATE PRODUCT" : "ADD PRODUCT")
                                .font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                                .frame(maxWidth: .infinity).padding(.vertical, 16)
                                .background(vm.viewState == .loading
                                    ? PC.orange.opacity(0.5) : PC.orange)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            if vm.viewState == .loading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    }
                    .disabled(vm.viewState == .loading)
                }
                .padding(.horizontal, 16).padding(.bottom, 100)
            }
            .padding(.top, 4)
            .contentShape(Rectangle())
            .onTapGesture { focus = nil }
        }
        // ── Seed attrs when VM detail fetch completes ──────────────
        .onChange(of: vm.seedAttrs) { newAttrs in
            guard !newAttrs.isEmpty else { return }
            attrs = newAttrs.map { seed in
                var a = APM.Attr()
                a.name   = seed.name
                a.values = seed.values
                return a
            }
        }
        // ── Loading overlay while fetching product detail ──────────
        .overlay {
            if vm.viewState == .loading {
                ZStack {
                    Color.black.opacity(0.45).ignoresSafeArea()
                    VStack(spacing: 14) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: PC.purple))
                            .scaleEffect(1.3)
                        Text("Loading product…")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PC.sub)
                    }
                    .padding(28)
                    .background(PC.card)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                }
            }
        }
    }
}

// MARK: - Price Row

private struct APPriceRow: View {
    @Binding var price: EPVMPrice
    let idx: Int
    let attrs: [APM.Attr]
    @FocusState.Binding var focus: APField?
    let onRemove: () -> Void

    private let currencies = ["USD", "EUR", "GBP", "CHF", "INR", "JPY", "AED"]
    private var amtFocused: Bool { focus == APField.priceAmount(idx) }
    private var skuFocused: Bool { focus == APField.priceSKU(idx) }
    private var qtyFocused: Bool { focus == APField.priceQty(idx) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Price #\(idx + 1)")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(PC.white)
                Spacer()
                if price.isDefault {
                    APDefaultBadge()
                } else {
                    Button(action: onRemove) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark").font(.system(size: 11, weight: .bold))
                            Text("Remove").font(.system(size: 13, weight: .medium))
                        }.foregroundColor(PC.red)
                    }
                }
            }

            HStack(spacing: 0) {
                typeBtn("One-time",     sel: price.kind == .oneTime)     { price.kind = .oneTime }
                typeBtn("Subscription", sel: price.kind == .subscription) { price.kind = .subscription }
            }
            .background(PC.field).clipShape(RoundedRectangle(cornerRadius: 10))

            APLabel("Amount")
            HStack(spacing: 8) {
                TextField("", text: $price.amount,
                          prompt: Text("0.00").foregroundColor(PC.muted))
                    .keyboardType(.decimalPad)
                    .focused($focus, equals: APField.priceAmount(idx))
                    .loginFieldShell(active: amtFocused) { focus = APField.priceAmount(idx) }
                    .frame(maxWidth: .infinity)

                Menu {
                    ForEach(currencies, id: \.self) { c in Button(c) { price.currency = c } }
                } label: {
                    HStack(spacing: 6) {
                        Text(price.currency)
                            .font(.system(size: 14, weight: .semibold)).foregroundColor(PC.white)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 11)).foregroundColor(PC.sub)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 13).frame(minHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 10).fill(PC.bg))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(PC.border, lineWidth: 1))
                }
            }

            APLabel("SKU (optional)")
            TextField("", text: $price.sku,
                      prompt: Text("e.g. TSHIRT-BLK-L").foregroundColor(PC.muted))
                .focused($focus, equals: APField.priceSKU(idx))
                .loginFieldShell(active: skuFocused) { focus = APField.priceSKU(idx) }

            if !attrs.filter({ !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    APLabel("Variations")
                    Text("Select specific variant values this price applies to.")
                        .font(.system(size: 12)).foregroundColor(PC.sub)
                    
                    VStack(spacing: 10) {
                        ForEach(attrs.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }, id: \.id) { attr in
                            HStack(spacing: 12) {
                                Text(attr.name)
                                    .font(.system(size: 13, weight: .medium)).foregroundColor(PC.white)
                                    .frame(width: 80, alignment: .leading)
                                
                                Menu {
                                    Button("Any \(attr.name)") { price.variant[attr.name] = nil }
                                    ForEach(attr.values, id: \.self) { val in
                                        Button(val) { price.variant[attr.name] = val }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(price.variant[attr.name] ?? "Any \(attr.name)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(price.variant[attr.name] == nil ? PC.muted : PC.white)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 11)).foregroundColor(PC.sub)
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(PC.bg))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(PC.border, lineWidth: 1))
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }

            HStack {
                Text("Additional Currencies").font(.system(size: 13)).foregroundColor(PC.sub)
                Spacer()
                Button("+ Add Currency") {}.font(.system(size: 13, weight: .medium)).foregroundColor(PC.purple)
            }

            Button(action: { price.trackQty.toggle() }) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(PC.purple, lineWidth: 2).frame(width: 22, height: 22)
                        if price.trackQty {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold)).foregroundColor(PC.purple)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Track Inventory")
                            .font(.system(size: 14, weight: .medium)).foregroundColor(PC.white)
                        Text("Enable to set a stock quantity for this price")
                            .font(.system(size: 12)).foregroundColor(PC.muted)
                    }
                }
            }

            if price.trackQty {
                APLabel("Quantity").padding(.top, 4)
                TextField("", value: $price.qty, format: .number,
                          prompt: Text("0").foregroundColor(PC.muted))
                    .keyboardType(.numberPad)
                    .focused($focus, equals: APField.priceQty(idx))
                    .loginFieldShell(active: qtyFocused) { focus = APField.priceQty(idx) }
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14).background(PC.inputBg).clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: price.trackQty)
    }

    @ViewBuilder
    private func typeBtn(_ label: String, sel: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 13, weight: .semibold))
                .foregroundColor(sel ? .white : PC.sub)
                .frame(maxWidth: .infinity).padding(.vertical, 9)
                .background(sel ? PC.purple : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 9))
        }.padding(3)
    }
}

// MARK: - Meta Row

private struct APMetaRow: View {
    @Binding var key: String
    @Binding var value: String
    let idx: Int
    @FocusState.Binding var focus: APField?
    let onRemove: () -> Void

    private var kFocused: Bool { focus == APField.metaKey(idx) }
    private var vFocused: Bool { focus == APField.metaValue(idx) }

    var body: some View {
        HStack(spacing: 8) {
            TextField("", text: $key,
                      prompt: Text("Key").foregroundColor(PC.muted))
                .focused($focus, equals: APField.metaKey(idx))
                .loginFieldShellCompact(active: kFocused) { focus = APField.metaKey(idx) }
            TextField("", text: $value,
                      prompt: Text("Value").foregroundColor(PC.muted))
                .focused($focus, equals: APField.metaValue(idx))
                .loginFieldShellCompact(active: vFocused) { focus = APField.metaValue(idx) }
            Button(action: onRemove) {
                Image(systemName: "xmark").font(.system(size: 13, weight: .bold)).foregroundColor(PC.red)
            }
        }
    }
}

// MARK: - Attribute Row

private struct APAttrRow: View {
    @Binding var attr: APM.Attr
    let idx: Int
    @FocusState.Binding var focus: APField?
    let onRemove: () -> Void
    @State private var valInput = ""

    private var nameFocused:  Bool { focus == APField.attrName(idx) }
    private var valueFocused: Bool { focus == APField.attrValue(idx) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button(action: onRemove) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark").font(.system(size: 11, weight: .bold))
                        Text("Remove").font(.system(size: 13, weight: .medium))
                    }.foregroundColor(PC.red)
                }
            }
            TextField("", text: $attr.name,
                      prompt: Text("Attribute name (e.g. size, color)").foregroundColor(PC.muted))
                .focused($focus, equals: APField.attrName(idx))
                .loginFieldShell(active: nameFocused) { focus = APField.attrName(idx) }

            Text("Add values below — these become the selectable options at checkout")
                .font(.system(size: 12)).foregroundColor(PC.sub)

            if !attr.values.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(attr.values, id: \.self) { v in
                            HStack(spacing: 4) {
                                Text(v).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
                                Button(action: { attr.values.removeAll { $0 == v } }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold)).foregroundColor(PC.sub)
                                }
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(PC.purple.opacity(0.25)).clipShape(Capsule())
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                TextField("", text: $valInput,
                          prompt: Text("Add value then press Enter (e.g. S, M, L)").foregroundColor(PC.muted))
                    .focused($focus, equals: APField.attrValue(idx))
                    .loginFieldShell(active: valueFocused) { focus = APField.attrValue(idx) }
                    .onSubmit { addVal() }
                Button(action: addVal) {
                    Text("Add").font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 13)
                        .background(PC.purple).clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(12).background(PC.inputBg).clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func addVal() {
        let v = valInput.trimmingCharacters(in: .whitespaces)
        guard !v.isEmpty else { return }
        attr.values.append(v); valInput = ""
    }
}

// MARK: - Shared Input Components

private struct APTextField: View {
    let placeholder: String
    @Binding var text: String
    let field: APField
    @FocusState.Binding var focus: APField?
    private var isActive: Bool { focus == field }
    var body: some View {
        TextField("", text: $text,
                  prompt: Text(placeholder).foregroundColor(PC.muted))
            .font(.system(size: 14)).foregroundColor(PC.white).tint(PC.purple)
            .focused($focus, equals: field)
            .padding(.horizontal, 14).padding(.vertical, 13).frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.field))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? PC.purple : PC.border, lineWidth: isActive ? 1.8 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture { focus = field }
            .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

private struct APTextArea: View {
    let placeholder: String
    @Binding var text: String
    let field: APField
    @FocusState.Binding var focus: APField?
    private var isActive: Bool { focus == field }
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder).font(.system(size: 14)).foregroundColor(PC.muted)
                    .padding(.horizontal, 14).padding(.top, 14).allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .font(.system(size: 14)).foregroundColor(PC.white).tint(PC.purple)
                .frame(minHeight: 100).scrollContentBackground(.hidden)
                .padding(.horizontal, 10).padding(.vertical, 8).focused($focus, equals: field)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(PC.field))
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(isActive ? PC.purple : PC.border, lineWidth: isActive ? 1.8 : 1))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { focus = field }
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// MARK: - Atom Views

private struct APCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ b: () -> Content) { content = b() }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(16).background(PC.card)
            .clipShape(RoundedRectangle(cornerRadius: 16)).padding(.horizontal, 12)
    }
}
private struct APSecTitle: View {
    let t: String; init(_ t: String) { self.t = t }
    var body: some View {
        Text(t).font(.system(size: 11, weight: .semibold))
            .foregroundColor(PC.sub).kerning(1.2).padding(.bottom, 8)
    }
}
private struct APLabel: View {
    let t: String; init(_ t: String) { self.t = t }
    var body: some View {
        Text(t).font(.system(size: 13, weight: .medium))
            .foregroundColor(PC.sub).padding(.bottom, 6)
    }
}
private struct APOptBadge: View {
    var body: some View {
        Text("optional").font(.system(size: 11, weight: .medium)).foregroundColor(PC.sub)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .overlay(Capsule().stroke(PC.border, lineWidth: 1)).padding(.leading, 6)
    }
}
private struct APAddBtn: View {
    let t: String; let a: () -> Void
    init(_ t: String, _ a: @escaping () -> Void) { self.t = t; self.a = a }
    var body: some View {
        Button(action: a) {
            Text(t).font(.system(size: 13, weight: .semibold)).foregroundColor(PC.purple)
        }
    }
}
private struct APDefaultBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("⭐").font(.system(size: 12))
            Text("Default").font(.system(size: 12, weight: .semibold)).foregroundColor(PC.gold)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(PC.gold.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
private struct APRadio: View {
    let label: String; let on: Bool; let action: () -> Void
    init(_ l: String, on: Bool, _ a: @escaping () -> Void) { label = l; self.on = on; action = a }
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().stroke(on ? PC.purple : PC.border, lineWidth: 2).frame(width: 22, height: 22)
                    if on { Circle().fill(PC.purple).frame(width: 12, height: 12) }
                }
                Text(label).font(.system(size: 14)).foregroundColor(PC.white)
            }
        }
    }
}
private extension View {
    func loginFieldShell(active: Bool, onTap: @escaping () -> Void) -> some View {
        self.font(.system(size: 14)).foregroundColor(PC.white).tint(PC.purple)
            .padding(.horizontal, 14).padding(.vertical, 13).frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.field))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(active ? PC.purple : PC.border, lineWidth: active ? 1.8 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.15), value: active)
    }
    func loginFieldShellCompact(active: Bool, onTap: @escaping () -> Void) -> some View {
        self.font(.system(size: 13)).foregroundColor(PC.white).tint(PC.purple)
            .padding(.horizontal, 12).padding(.vertical, 13).frame(minHeight: 48)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.field))
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(active ? PC.purple : PC.border, lineWidth: active ? 1.8 : 1))
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.15), value: active)
    }
}
private struct APCatalogues: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "square.grid.2x2").font(.system(size: 55)).foregroundColor(PC.sub)
            Text("No Catalogues Found").font(.system(size: 20, weight: .bold)).foregroundColor(PC.white)
            Text("Create catalogues to organize products.").font(.system(size: 14)).foregroundColor(PC.sub)
            Spacer()
        }
    }
}
