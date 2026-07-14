import SwiftUI
import PhotosUI

// MARK: - Hex Color Helper
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

// MARK: - Design Tokens
private enum PC {
    static let bgPrimary     = Color(pcHex: "#0D1117")
    static let bgCard        = Color(pcHex: "#161B22")
    static let bgInput       = Color(pcHex: "#1C2333")
    static let bgField       = Color(pcHex: "#21262D")
    static let tabInactive   = Color(pcHex: "#21262D")
    static let accentPurple  = Color(pcHex: "#7C5CFC")
    static let accentOrange  = Color(pcHex: "#F97316")
    static let accentBlue    = Color(pcHex: "#3B82F6")
    static let accentGreen   = Color(pcHex: "#22C55E")
    static let textPrimary   = Color.white
    static let textSecondary = Color(pcHex: "#8B949E")
    static let textMuted     = Color(pcHex: "#484F58")
    static let borderColor   = Color(pcHex: "#30363D")
    static let starGold      = Color(pcHex: "#F5A623")
    static let removeRed     = Color(pcHex: "#EF4444")
    static let cancelBg      = Color(pcHex: "#2D3340")
}

// MARK: - Focus Field Enum
enum APVMField: Hashable {
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

// MARK: - Root View
public struct AddProductView: View {
    @StateObject private var vm = AddProductViewModel()
    @State private var selectedTab = 0
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        ZStack {
            PC.bgPrimary.ignoresSafeArea()
            VStack(spacing: 0) {
                PCHeaderBar(onDismiss: { dismiss() })

                HStack(spacing: 8) {
                    PCTabPill(title: "Products",   count: 12, active: selectedTab == 0) { selectedTab = 0 }
                    PCTabPill(title: "Catalogues", count: 1,  active: selectedTab == 1) { selectedTab = 1 }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if selectedTab == 0 {
                    PCAddProductForm(vm: vm, onDismiss: { dismiss() })
                } else {
                    PCCataloguesPlaceholder()
                }
            }

            if vm.isLoading {
                Color.black.opacity(0.55).ignoresSafeArea()
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: PC.accentPurple))
                        .scaleEffect(1.4)
                    Text("Saving product…")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(PC.textSecondary)
                }
                .padding(32)
                .background(PC.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        }
        .preferredColorScheme(.dark)
        .overlay(alignment: .top) {
            if let msg = vm.successMessage {
                PCToast(message: msg, isSuccess: true) {
                    vm.dismissSuccess()  // still tappable to dismiss early
                }
                .padding(.top, 60)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.4), value: vm.successMessage)
            }
        }
        .overlay(alignment: .top) {
            if let msg = vm.errorMessage {
                PCToast(message: msg, isSuccess: false) { vm.dismissError() }
                    .padding(.top, 60)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.4), value: vm.errorMessage)
            }
        }
        
        .onChange(of: vm.shouldDismiss) { newValue in
                if newValue {
                    dismiss()
                }
            }
    }
}

// MARK: - Header
private struct PCHeaderBar: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onDismiss) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(PC.textPrimary)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Product Catalogue")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(PC.textPrimary)
                Text("Manage products, pricing, and catalogues")
                    .font(.system(size: 13))
                    .foregroundColor(PC.textSecondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }
}

// MARK: - Tab Pill
private struct PCTabPill: View {
    let title: String
    let count: Int
    let active: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(active ? .white : PC.textSecondary)
                Text("\(count)")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(active ? .white : PC.textSecondary)
                    .padding(.horizontal, 7).padding(.vertical, 2)
                    .background(active ? PC.accentPurple.opacity(0.35) : PC.bgField)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(active ? PC.accentPurple : PC.tabInactive)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Image URL Field with Upload
private struct PCImageInputRow: View {
    @ObservedObject var vm: AddProductViewModel
    @FocusState.Binding var focus: APVMField?

    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var pickedImage: UIImage? = nil
    @State private var isLoadingImage = false

    private var urlFocused: Bool { focus == .imageURL }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let img = pickedImage {
                HStack(spacing: 12) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(PC.accentPurple.opacity(0.5), lineWidth: 1.5)
                        )
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Image selected from library")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(PC.textPrimary)
                        Button(action: {
                            pickedImage          = nil
                            pickerItem           = nil
                            vm.formData.imageURL = ""   // ← also clear the stored data URI
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "xmark.circle.fill").font(.system(size: 13))
                                Text("Remove").font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(PC.removeRed)
                        }
                    }
                    Spacer()
                    PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(PC.accentPurple)
                            .frame(width: 40, height: 40)
                            .background(PC.accentPurple.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(12)
                .background(PC.bgField)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(PC.accentPurple.opacity(0.35), lineWidth: 1))
            } else {
                HStack(spacing: 8) {
                    TextField("", text: $vm.formData.imageURL,
                              prompt: Text("https://example.com/image.jpg").foregroundColor(PC.textMuted))
                    .font(.system(size: 14))
                    .foregroundColor(PC.textPrimary)
                    .tint(PC.accentPurple)
                    .focused($focus, equals: .imageURL)
                    .padding(.horizontal, 14).padding(.vertical, 13)
                    .frame(minHeight: 50)
                    .background(RoundedRectangle(cornerRadius: 10).fill(PC.bgField))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(urlFocused ? PC.accentPurple : PC.borderColor,
                                    lineWidth: urlFocused ? 1.8 : 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture { focus = .imageURL }
                    .animation(.easeInOut(duration: 0.15), value: urlFocused)
                    
                    PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                        ZStack {
                            if isLoadingImage {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: PC.accentPurple))
                                    .scaleEffect(0.85)
                            } else {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(PC.accentPurple)
                            }
                        }
                        .frame(width: 50, height: 50)
                        .background(PC.accentPurple.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(PC.accentPurple.opacity(0.35), lineWidth: 1))
                    }
                    .disabled(isLoadingImage)
                }
                Text("Paste a URL or tap \(Image(systemName: "photo.badge.plus")) to pick from your library")
                    .font(.system(size: 11))
                    .foregroundColor(PC.textMuted)
                    .padding(.leading, 2)
            }
        }
        // AFTER — stores data URI so saveProduct() can detect and upload it:
        .onChange(of: pickerItem) { newItem in
            guard let newItem else { return }
            isLoadingImage = true
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        pickedImage = uiImage
                        // ── Store as base64 data URI so saveProduct() uploads it ──
                        if let jpeg = uiImage.jpegData(compressionQuality: 0.8) {
                            vm.formData.imageURL = "data:image/jpeg;base64,"
                            + jpeg.base64EncodedString()
                        }
                        isLoadingImage = false
                    }
                } else {
                    await MainActor.run { isLoadingImage = false }
                }
            }
        }
    }
}

// MARK: - Add Product Form
private struct PCAddProductForm: View {
    @ObservedObject var vm: AddProductViewModel
    let onDismiss: () -> Void

    @FocusState private var focus: APVMField?

    var body: some View {
        // ── FIX: simultaneousGesture prevents ScrollView stealing Menu tap ──
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                Button(action: onDismiss) {
                    Label("Back to Products", systemImage: "arrow.left")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(PC.accentPurple)
                }
                .padding(.horizontal, 16)

                Text("Add New Product")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(PC.textPrimary)
                    .padding(.horizontal, 16)

                // ── BASIC INFO ──────────────────────────────────────────
                PCFormCard {
                    PCSectionTitle("BASIC INFO")
                    PCFieldLabel("Product Name *")
                    PCFocusTextField(
                        placeholder: "e.g. Classic T-Shirt",
                        text: $vm.formData.name,
                        field: .productName,
                        focus: $focus
                    )
                    PCFieldLabel("Image (optional)").padding(.top, 12)
                    PCImageInputRow(vm: vm, focus: $focus)
                    PCFieldLabel("Status").padding(.top, 12)
                    HStack(spacing: 20) {
                        PCRadioButton(label: "Active",
                                      selected: vm.formData.status == APProductStatus.active)
                        { vm.formData.status = APProductStatus.active }
                        PCRadioButton(label: "Draft",
                                      selected: vm.formData.status == APProductStatus.draft)
                        { vm.formData.status = APProductStatus.draft }
                    }.padding(.top, 2)
                    PCFieldLabel("Description (optional)").padding(.top, 12)
                    PCFocusTextArea(
                        placeholder: "Describe your product…",
                        text: $vm.formData.description,
                        field: .description,
                        focus: $focus
                    )
                }

                // ── ATTRIBUTES & VARIANTS ───────────────────────────────
                PCFormCard {
                    HStack {
                        PCSectionTitle("ATTRIBUTES & VARIANTS")
                        PCOptionalTag()
                        Spacer()
                        PCAddLink("+ Add Attribute") { vm.addAttribute() }
                    }
                    Text("Define attributes like size, color, etc.")
                        .font(.system(size: 13))
                        .foregroundColor(PC.textSecondary)
                        .padding(.top, 4)
                    ForEach(Array(vm.formData.attributes.enumerated()), id: \.element.id) { idx, _ in
                        PCAttributeCard(
                            entry: $vm.formData.attributes[idx],
                            idx: idx,
                            focus: $focus,
                            onAddValue: { value in
                                vm.addAttributeValue(id: vm.formData.attributes[idx].id, value: value)
                            },
                            onRemove: { vm.removeAttribute(id: vm.formData.attributes[idx].id) }
                        )
                        .padding(.top, 10)
                    }
                }

                // ── PRICING ─────────────────────────────────────────────
                PCFormCard {
                    HStack {
                        PCSectionTitle("PRICING")
                        Spacer()
                        PCAddLink("+ Add Price") { vm.addPrice() }
                    }
                    ForEach(Array(vm.formData.prices.enumerated()), id: \.element.id) { idx, _ in
                        PCPriceCard(
                            entry: $vm.formData.prices[idx],
                            priceNumber: idx + 1,
                            idx: idx,
                            attrs: vm.formData.attributes,
                            focus: $focus,
                            onRemove: { vm.removePrice(id: vm.formData.prices[idx].id) }
                        )
                        .padding(.top, 10)
                    }
                }

                // ── METADATA ────────────────────────────────────────────
                PCFormCard {
                    HStack {
                        PCSectionTitle("METADATA")
                        PCOptionalTag()
                        Spacer()
                    }
                    Text("Extra key-value pairs sent as the metadata field (e.g. brand, material).")
                        .font(.system(size: 13))
                        .foregroundColor(PC.textSecondary)
                        .padding(.top, 4)
                    ForEach(Array(vm.formData.metadata.enumerated()), id: \.element.id) { idx, _ in
                        PCMetaRow(
                            entry: $vm.formData.metadata[idx],
                            idx: idx,
                            focus: $focus,
                            onRemove: { vm.removeMeta(id: vm.formData.metadata[idx].id) }
                        )
                        .padding(.top, 8)
                    }
                    Button(action: { vm.addMeta() }) {
                        Text("+ Add Metadata")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(PC.accentPurple)
                    }.padding(.top, 10)
                }

                // ── ACTION BUTTONS ───────────────────────────────────────
                HStack(spacing: 12) {
                    Button(action: { focus = nil; vm.resetForm(); onDismiss() }) {
                        Text("CANCEL")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(PC.textPrimary)
                            .frame(maxWidth: .infinity).padding(.vertical, 16)
                            .background(PC.cancelBg)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    Button(action: { focus = nil; vm.saveProduct() }) {
                        HStack(spacing: 8) {
                            if vm.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.85)
                            }
                            Text(vm.isLoading ? "SAVING…" : "SAVE PRODUCT")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(vm.isLoading ? PC.accentOrange.opacity(0.6) : PC.accentOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .disabled(vm.isLoading)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 60)
            }
            .padding(.top, 4)
            .contentShape(Rectangle())
            .onTapGesture {
                // only dismiss focus, but don't block child interactions
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                to: nil, from: nil, for: nil)
            }
        }
        // ── KEY FIX: lets Menu receive tap without ScrollView stealing it ──
       // .simultaneousGesture(DragGesture().onChanged { _ in })
    }
}

// MARK: - Toast
private struct PCToast: View {
    let message: String
    let isSuccess: Bool
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isSuccess ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundColor(isSuccess ? PC.accentGreen : PC.removeRed)
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(PC.textPrimary)
                .lineLimit(2)
            Spacer()
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(PC.textSecondary)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(PC.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(isSuccess ? PC.accentGreen.opacity(0.4) : PC.removeRed.opacity(0.4), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.35), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 16)
    }
}

// MARK: - Form Card
private struct PCFormCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder _ c: () -> Content) { content = c() }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(16)
            .background(PC.bgCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 12)
    }
}

// MARK: - Atoms
private struct PCSectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(PC.textSecondary)
            .kerning(1.2).padding(.bottom, 8)
    }
}
private struct PCFieldLabel: View {
    let text: String
    init(_ text: String) { self.text = text }
    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(PC.textSecondary).padding(.bottom, 6)
    }
}
private struct PCOptionalTag: View {
    var body: some View {
        Text("optional").font(.system(size: 11, weight: .medium))
            .foregroundColor(PC.textSecondary)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .overlay(Capsule().stroke(PC.borderColor, lineWidth: 1))
            .padding(.leading, 6)
    }
}
private struct PCAddLink: View {
    let label: String; let action: () -> Void
    init(_ l: String, _ a: @escaping () -> Void) { label = l; action = a }
    var body: some View {
        Button(action: action) {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(PC.accentPurple)
        }
    }
}
private struct PCDefaultBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("⭐").font(.system(size: 12))
            Text("Default").font(.system(size: 12, weight: .semibold)).foregroundColor(PC.starGold)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(PC.starGold.opacity(0.15)).clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
private struct PCRadioButton: View {
    let label: String; let selected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                ZStack {
                    Circle().stroke(selected ? PC.accentPurple : PC.borderColor, lineWidth: 2)
                        .frame(width: 22, height: 22)
                    if selected { Circle().fill(PC.accentPurple).frame(width: 12, height: 12) }
                }
                Text(label).font(.system(size: 14)).foregroundColor(PC.textPrimary)
            }
        }
    }
}

// MARK: - PCFocusTextField
private struct PCFocusTextField: View {
    let placeholder: String
    @Binding var text: String
    let field: APVMField
    @FocusState.Binding var focus: APVMField?

    private var isActive: Bool { focus == field }

    var body: some View {
        TextField("", text: $text,
                  prompt: Text(placeholder).foregroundColor(PC.textMuted))
            .font(.system(size: 14))
            .foregroundColor(PC.textPrimary)
            .tint(PC.accentPurple)
            .focused($focus, equals: field)
            .padding(.horizontal, 14).padding(.vertical, 13)
            .frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.bgField))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isActive ? PC.accentPurple : PC.borderColor,
                            lineWidth: isActive ? 1.8 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture { focus = field }
            .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// MARK: - PCFocusTextArea
private struct PCFocusTextArea: View {
    let placeholder: String
    @Binding var text: String
    let field: APVMField
    @FocusState.Binding var focus: APVMField?

    private var isActive: Bool { focus == field }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.system(size: 14)).foregroundColor(PC.textMuted)
                    .padding(.horizontal, 14).padding(.top, 14)
                    .allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .font(.system(size: 14))
                .foregroundColor(PC.textPrimary)
                .tint(PC.accentPurple)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .focused($focus, equals: field)
        }
        .background(RoundedRectangle(cornerRadius: 10).fill(PC.bgField))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isActive ? PC.accentPurple : PC.borderColor,
                        lineWidth: isActive ? 1.8 : 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .onTapGesture { focus = field }
        .animation(.easeInOut(duration: 0.15), value: isActive)
    }
}

// MARK: - Login-style shell modifiers
private extension View {
    func pcLoginShell(active: Bool, onTap: @escaping () -> Void) -> some View {
        self
            .font(.system(size: 14))
            .foregroundColor(PC.textPrimary)
            .tint(PC.accentPurple)
            .padding(.horizontal, 14).padding(.vertical, 13)
            .frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.bgField))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(active ? PC.accentPurple : PC.borderColor,
                            lineWidth: active ? 1.8 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.15), value: active)
    }

    func pcLoginShellCompact(active: Bool, onTap: @escaping () -> Void) -> some View {
        self
            .font(.system(size: 13))
            .foregroundColor(PC.textPrimary)
            .tint(PC.accentPurple)
            .padding(.horizontal, 12).padding(.vertical, 13)
            .frame(minHeight: 48)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.bgField))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(active ? PC.accentPurple : PC.borderColor,
                            lineWidth: active ? 1.8 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 10))
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.15), value: active)
    }
}

// MARK: - Attribute Card
private struct PCAttributeCard: View {
    @Binding var entry: APAttributeEntry
    let idx: Int
    @FocusState.Binding var focus: APVMField?
    let onAddValue: (String) -> Void
    let onRemove: () -> Void
    @State private var valueInput = ""

    private var nameFocused:  Bool { focus == .attrName(idx) }
    private var valueFocused: Bool { focus == .attrValue(idx) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button(action: onRemove) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark").font(.system(size: 11, weight: .bold))
                        Text("Remove").font(.system(size: 13, weight: .medium))
                    }.foregroundColor(PC.removeRed)
                }
            }
            TextField("", text: $entry.name,
                      prompt: Text("Attribute name (e.g. size, color)").foregroundColor(PC.textMuted))
                .focused($focus, equals: .attrName(idx))
                .pcLoginShell(active: nameFocused) { focus = .attrName(idx) }
            Text("Add values below — these become the selectable options at checkout")
                .font(.system(size: 12)).foregroundColor(PC.textSecondary)
            if !entry.values.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(entry.values, id: \.self) { v in
                            HStack(spacing: 4) {
                                Text(v).font(.system(size: 12, weight: .medium)).foregroundColor(.white)
                                Button(action: { entry.values.removeAll { $0 == v } }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(PC.textSecondary)
                                }
                            }
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(PC.accentPurple.opacity(0.25)).clipShape(Capsule())
                        }
                    }
                }
            }
            HStack(spacing: 8) {
                TextField("", text: $valueInput,
                          prompt: Text("Add value then press Enter (e.g. S, M, L)").foregroundColor(PC.textMuted))
                    .focused($focus, equals: .attrValue(idx))
                    .pcLoginShell(active: valueFocused) { focus = .attrValue(idx) }
                    .onSubmit { commitValue() }
                Button(action: commitValue) {
                    Text("Add")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 18).padding(.vertical, 13)
                        .background(PC.accentPurple).clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(12)
        .background(PC.bgInput)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func commitValue() {
        let v = valueInput.trimmingCharacters(in: .whitespaces)
        guard !v.isEmpty else { return }
        onAddValue(v); valueInput = ""
    }
}

// MARK: - Price Card
// MARK: - Currency Picker Sheet
private struct PCCurrencyPickerSheet: View {
    let currencies: [(code: String, flag: String, name: String)]
    let selected: String
    let onSelect: (String) -> Void

    var body: some View {
        ZStack {
            PC.bgCard.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Select Currency")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(PC.textPrimary)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 16)

                Divider().background(PC.borderColor)

                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(currencies, id: \.code) { c in
                            Button(action: { onSelect(c.code) }) {
                                HStack(spacing: 14) {
                                    Text(c.flag)
                                        .font(.system(size: 28))
                                        .frame(width: 40)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(c.code)
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(PC.textPrimary)
                                        Text(c.name)
                                            .font(.system(size: 13))
                                            .foregroundColor(PC.textSecondary)
                                    }
                                    Spacer()
                                    if c.code == selected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(PC.accentPurple)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    c.code == selected
                                        ? PC.accentPurple.opacity(0.08)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)

                            if c.code != currencies.last?.code {
                                Divider()
                                    .background(PC.borderColor)
                                    .padding(.leading, 74)
                            }
                        }
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Currency Button (owns the sheet state)
private struct PCCurrencyButton: View {
    let currencies: [(code: String, flag: String, name: String)]
    @Binding var selectedCode: String
    @State private var showPicker = false   // ✅ @State lives here safely

    private var selected: (code: String, flag: String, name: String) {
        currencies.first { $0.code == selectedCode } ?? currencies[0]
    }

    var body: some View {
        Button(action: { showPicker = true }) {
            HStack(spacing: 6) {
                Text(selected.flag)
                    .font(.system(size: 16))
                Text(selected.code)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(PC.textPrimary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 11))
                    .foregroundColor(PC.textSecondary)
            }
            .padding(.horizontal, 12).padding(.vertical, 13)
            .frame(minHeight: 50)
            .background(RoundedRectangle(cornerRadius: 10).fill(PC.bgPrimary))
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(PC.borderColor, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showPicker) {
            PCCurrencyPickerSheet(
                currencies: currencies,
                selected: selectedCode,
                onSelect: { code in
                    selectedCode = code
                    showPicker = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Price Card
private struct PCPriceCard: View {
    @Binding var entry: APPriceEntry
    let priceNumber: Int
    let idx: Int
    let attrs: [APAttributeEntry]
    @FocusState.Binding var focus: APVMField?
    let onRemove: () -> Void

    private let currencies: [(code: String, flag: String, name: String)] = [
        ("USD", "🇺🇸", "US Dollar"),
        ("EUR", "🇪🇺", "Euro"),
        ("GBP", "🇬🇧", "British Pound"),
        ("AUD", "🇦🇺", "Australian Dollar"),
        ("CAD", "🇨🇦", "Canadian Dollar"),
        ("SGD", "🇸🇬", "Singapore Dollar"),
        ("JPY", "🇯🇵", "Japanese Yen"),
        ("CHF", "🇨🇭", "Swiss Franc"),
        ("HKD", "🇭🇰", "Hong Kong Dollar"),
        ("MYR", "🇲🇾", "Malaysian Ringgit"),
        ("BRL", "🇧🇷", "Brazilian Real"),
        ("NZD", "🇳🇿", "New Zealand Dollar"),
    ]

    private var amtFocused: Bool { focus == .priceAmount(idx) }
    private var skuFocused: Bool { focus == .priceSKU(idx) }
    private var qtyFocused: Bool { focus == .priceQty(idx) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            HStack {
                Text("Price #\(priceNumber)")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(PC.textPrimary)
                Spacer()
                if entry.isDefault { PCDefaultBadge() }
                else {
                    Button(action: onRemove) {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark").font(.system(size: 11, weight: .bold))
                            Text("Remove").font(.system(size: 13, weight: .medium))
                        }.foregroundColor(PC.removeRed)
                    }
                }
            }

            HStack(spacing: 0) {
                priceTypeTab("One-time",     sel: entry.type == APPriceType.oneTime)      { entry.type = APPriceType.oneTime }
                priceTypeTab("Subscription", sel: entry.type == APPriceType.subscription) { entry.type = APPriceType.subscription }
            }
            .background(PC.bgField).clipShape(RoundedRectangle(cornerRadius: 10))

            PCFieldLabel("Amount")
            HStack(spacing: 8) {
                TextField("", text: $entry.amount,
                          prompt: Text("0.00").foregroundColor(PC.textMuted))
                    .keyboardType(.decimalPad)
                    .focused($focus, equals: .priceAmount(idx))
                    .pcLoginShell(active: amtFocused) { focus = .priceAmount(idx) }
                    .frame(maxWidth: .infinity)

                // ✅ Sheet state safely lives inside PCCurrencyButton
                PCCurrencyButton(currencies: currencies, selectedCode: $entry.currency)
            }

            PCFieldLabel("SKU (optional)")
            TextField("", text: $entry.sku,
                      prompt: Text("e.g. TSHIRT-BLK-L").foregroundColor(PC.textMuted))
                .focused($focus, equals: .priceSKU(idx))
                .pcLoginShell(active: skuFocused) { focus = .priceSKU(idx) }

            if !attrs.filter({ !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }).isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    PCFieldLabel("Variations")
                    Text("Select specific variant values this price applies to.")
                        .font(.system(size: 12)).foregroundColor(PC.textMuted)
                    
                    VStack(spacing: 10) {
                        ForEach(attrs.filter { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }, id: \.id) { attr in
                            HStack(spacing: 12) {
                                Text(attr.name)
                                    .font(.system(size: 13, weight: .medium)).foregroundColor(PC.textPrimary)
                                    .frame(width: 80, alignment: .leading)
                                
                                Menu {
                                    Button("Any \(attr.name)") { entry.variant[attr.name] = nil }
                                    ForEach(attr.values, id: \.self) { val in
                                        Button(val) { entry.variant[attr.name] = val }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Text(entry.variant[attr.name] ?? "Any \(attr.name)")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundColor(entry.variant[attr.name] == nil ? PC.textMuted : PC.textPrimary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 11)).foregroundColor(PC.textSecondary)
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(PC.bgField))
                                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(PC.borderColor, lineWidth: 1))
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }

            Button(action: { entry.trackInventory.toggle() }) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5).stroke(PC.accentPurple, lineWidth: 2)
                            .frame(width: 22, height: 22)
                        if entry.trackInventory {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold)).foregroundColor(PC.accentPurple)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Track Inventory")
                            .font(.system(size: 14, weight: .medium)).foregroundColor(PC.textPrimary)
                        Text("Enable to set a stock quantity for this price")
                            .font(.system(size: 12)).foregroundColor(PC.textMuted)
                    }
                }
            }

            if entry.trackInventory {
                PCFieldLabel("Quantity").padding(.top, 4)
                TextField("", value: $entry.quantity, format: .number,
                          prompt: Text("0").foregroundColor(PC.textMuted))
                    .keyboardType(.numberPad)
                    .focused($focus, equals: .priceQty(idx))
                    .pcLoginShell(active: qtyFocused) { focus = .priceQty(idx) }
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14).background(PC.bgInput).clipShape(RoundedRectangle(cornerRadius: 12))
        .animation(.easeInOut(duration: 0.2), value: entry.trackInventory)
    }

    @ViewBuilder
    private func priceTypeTab(_ label: String, sel: Bool, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label).font(.system(size: 13, weight: .semibold))
                .foregroundColor(sel ? .white : PC.textSecondary)
                .frame(maxWidth: .infinity).padding(.vertical, 9)
                .background(sel ? PC.accentPurple : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 9))
        }.padding(3)
    }
}
// MARK: - Metadata Row
private struct PCMetaRow: View {
    @Binding var entry: APMetaEntry
    let idx: Int
    @FocusState.Binding var focus: APVMField?
    let onRemove: () -> Void

    private var kFocused: Bool { focus == .metaKey(idx) }
    private var vFocused: Bool { focus == .metaValue(idx) }

    var body: some View {
        HStack(spacing: 8) {
            TextField("", text: $entry.key,
                      prompt: Text("Key").foregroundColor(PC.textMuted))
                .focused($focus, equals: .metaKey(idx))
                .pcLoginShellCompact(active: kFocused) { focus = .metaKey(idx) }
            TextField("", text: $entry.value,
                      prompt: Text("Value").foregroundColor(PC.textMuted))
                .focused($focus, equals: .metaValue(idx))
                .pcLoginShellCompact(active: vFocused) { focus = .metaValue(idx) }
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(PC.removeRed)
            }
        }
    }
}

// MARK: - Catalogues Placeholder
private struct PCCataloguesPlaceholder: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "square.grid.2x2").font(.system(size: 55)).foregroundColor(PC.textSecondary)
            Text("No Catalogues Found").font(.system(size: 20, weight: .bold)).foregroundColor(PC.textPrimary)
            Text("Create catalogues to organize products.").font(.system(size: 14)).foregroundColor(PC.textSecondary)
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    AddProductView()
}
