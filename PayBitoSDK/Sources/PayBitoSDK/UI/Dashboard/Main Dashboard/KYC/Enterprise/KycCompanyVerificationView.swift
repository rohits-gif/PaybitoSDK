

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Theme
private enum T {
    static let bg     = Color(red: 0.07, green: 0.08, blue: 0.14)
    static let card   = Color(red: 0.10, green: 0.12, blue: 0.19)
    static let field  = Color(red: 0.12, green: 0.14, blue: 0.22)
    static let purple = Color(red: 0.47, green: 0.35, blue: 0.95)
    static let orange = Color(red: 0.98, green: 0.55, blue: 0.10)
    static let red    = Color(red: 0.92, green: 0.22, blue: 0.20)
    static let yellow = Color(red: 1.00, green: 0.78, blue: 0.20)
    static let border = Color(white: 0.22)
    static let white  = Color.white
    static let gray   = Color(white: 0.60)
    static let gray2  = Color(white: 0.38)
    static let green  = Color(red: 0.22, green: 0.75, blue: 0.45)
    static let blue   = Color(red: 0.22, green: 0.38, blue: 0.85)
}

// ════════════════════════════════════════════════════════════════════
// MARK: - MCC Data + Modal
// ════════════════════════════════════════════════════════════════════

struct MCCEntry: Identifiable {
    let id = UUID()
    let industry: String
    let mcc: String
    let description: String
    let risk: String
    let riskColor: Color
}

private let mccData: [MCCEntry] = [
    MCCEntry(industry: "Crypto Exchange / OTC",              mcc: "6051", description: "Non-Financial Institutions / Crypto / Money Orders",  risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Crypto Wallet / Custody",            mcc: "6051", description: "Non-Financial Institutions",                           risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "CBD / Hemp",                         mcc: "5499", description: "Miscellaneous Food Stores",                            risk: "High Risk / Processor Dependent", riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Peptides / Research Chemicals",      mcc: "5169", description: "Chemicals & Allied Products",                          risk: "High Risk / Enhanced Due Diligence", riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Peptide Clinic / Wellness",          mcc: "8099", description: "Medical Services",                                     risk: "Healthcare / High Risk",          riskColor: Color(red:0.20,green:0.60,blue:0.80)),
    MCCEntry(industry: "Forex / CFD / Trading",              mcc: "6211", description: "Securities / Brokers",                                 risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Supplements / Nutraceuticals",       mcc: "5499", description: "Miscellaneous Food Stores",                            risk: "High Risk Monitoring",            riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "SaaS / Software",                    mcc: "5734", description: "Computer Software Stores",                             risk: "Standard",                        riskColor: Color(red:0.20,green:0.55,blue:0.85)),
    MCCEntry(industry: "Digital Services / Online Services", mcc: "7372", description: "Computer Programming & Data Processing",               risk: "Standard",                        riskColor: Color(red:0.20,green:0.55,blue:0.85)),
    MCCEntry(industry: "Gaming / Gambling / Betting",        mcc: "7995", description: "Betting / Gambling",                                   risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Adult Content",                      mcc: "5967", description: "Direct Marketing / Inbound Telemarketing",             risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Adult Subscription",                 mcc: "5968", description: "Subscription Services",                                risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Telemarketing Inbound",              mcc: "5967", description: "Inbound Telemarketing",                                risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Telemarketing Outbound",             mcc: "5966", description: "Outbound Telemarketing",                               risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Travel Agency",                      mcc: "4722", description: "Travel Agencies",                                      risk: "Medium Risk",                     riskColor: Color(red:0.98,green:0.55,blue:0.10)),
    MCCEntry(industry: "Marketplace / Ecommerce",            mcc: "5399", description: "General Merchandise",                                  risk: "Depends on Model",                riskColor: Color(red:0.20,green:0.55,blue:0.85)),
    MCCEntry(industry: "Dropshipping",                       mcc: "5969", description: "Direct Marketing",                                     risk: "Medium / High Risk",              riskColor: Color(red:0.98,green:0.55,blue:0.10)),
    MCCEntry(industry: "Pharmacy",                           mcc: "5912", description: "Drug Stores & Pharmacies",                             risk: "Healthcare",                      riskColor: Color(red:0.20,green:0.60,blue:0.80)),
    MCCEntry(industry: "Medical Clinic",                     mcc: "8011", description: "Doctors & Physicians",                                 risk: "Healthcare",                      riskColor: Color(red:0.20,green:0.60,blue:0.80)),
    MCCEntry(industry: "Subscription Billing",               mcc: "5968", description: "Subscription Services",                                risk: "Chargeback Monitoring",           riskColor: Color(red:0.20,green:0.60,blue:0.80)),
    MCCEntry(industry: "Dating",                             mcc: "7273", description: "Dating Services",                                      risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Financial Services / Lending",       mcc: "6012", description: "Financial Institutions",                               risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Money Transfer / MSB",               mcc: "6051", description: "Non-Financial Institutions",                           risk: "Licensing",                       riskColor: Color(red:0.20,green:0.60,blue:0.80)),
    MCCEntry(industry: "Charity / Nonprofit",                mcc: "8398", description: "Charitable Organizations",                             risk: "Enhanced Review",                 riskColor: Color(red:0.20,green:0.60,blue:0.80)),
    MCCEntry(industry: "Education / Coaching",               mcc: "8299", description: "Educational Services",                                 risk: "Standard",                        riskColor: Color(red:0.20,green:0.55,blue:0.85)),
    MCCEntry(industry: "Travel Club",                        mcc: "5962", description: "Direct Marketing Travel",                              risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "Debt Collection",                    mcc: "7321", description: "Consumer Credit Reporting / Collection",                risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
    MCCEntry(industry: "NFT / Web3",                         mcc: "6051", description: "Non-Financial Institutions",                           risk: "High Risk",                       riskColor: Color(red:0.92,green:0.22,blue:0.20)),
]

// MARK: MCC Modal Sheet
struct KYCMCCModal: View {
    @Binding var selectedIndustry: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filtered: [MCCEntry] {
        guard !searchText.isEmpty else { return mccData }
        return mccData.filter {
            $0.industry.localizedCaseInsensitiveContains(searchText) ||
            $0.mcc.contains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText) ||
            $0.risk.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.07, green: 0.08, blue: 0.14).ignoresSafeArea()
                VStack(spacing: 0) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundColor(Color(white: 0.55)).font(.system(size: 14))
                        TextField("Search industry, MCC code, or risk level…", text: $searchText)
                            .font(.system(size: 14)).foregroundColor(.white).tint(T.purple)
                            .autocorrectionDisabled().textInputAutocapitalization(.never)
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill").foregroundColor(Color(white: 0.50)).font(.system(size: 15))
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(Color(red: 0.12, green: 0.14, blue: 0.22))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(white: 0.22), lineWidth: 1))
                    .padding(.horizontal, 16).padding(.vertical, 12)

                    // Column headers
                    HStack(spacing: 0) {
                        Text("Merchant Industry").font(.system(size: 11, weight: .bold)).foregroundColor(Color(white: 0.55)).frame(maxWidth: .infinity, alignment: .leading)
                        Text("MCC")             .font(.system(size: 11, weight: .bold)).foregroundColor(Color(white: 0.55)).frame(width: 52, alignment: .center)
                        Text("MCC Description") .font(.system(size: 11, weight: .bold)).foregroundColor(Color(white: 0.55)).frame(maxWidth: .infinity, alignment: .leading)
                        Text("Underwriting View").font(.system(size: 11, weight: .bold)).foregroundColor(Color(white: 0.55)).frame(width: 120, alignment: .center)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Color(red: 0.10, green: 0.12, blue: 0.19))

                    Divider().background(Color(white: 0.22))

                    // Rows
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(filtered) { entry in
                                mccRow(entry)
                                Divider().background(Color(white: 0.15)).padding(.horizontal, 16)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Recommended High-risk MCC")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { dismiss() }.foregroundColor(T.purple).font(.system(size: 15, weight: .semibold))
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func mccRow(_ entry: MCCEntry) -> some View {
        let isSelected = selectedIndustry == entry.industry
        return Button {
            selectedIndustry = entry.industry
            dismiss()
        } label: {
            HStack(spacing: 0) {
                Text(entry.industry)
                    .font(.system(size: 13)).foregroundColor(isSelected ? T.purple : .white)
                    .frame(maxWidth: .infinity, alignment: .leading).lineLimit(2)

                Text(entry.mcc)
                    .font(.system(size: 13, weight: .bold)).foregroundColor(Color(white: 0.80))
                    .frame(width: 52, alignment: .center)

                Text(entry.description)
                    .font(.system(size: 12)).foregroundColor(Color(white: 0.65))
                    .frame(maxWidth: .infinity, alignment: .leading).lineLimit(2)

                Text(entry.risk)
                    .font(.system(size: 11, weight: .bold)).foregroundColor(.white)
                    .multilineTextAlignment(.center).lineLimit(2)
                    .padding(.horizontal, 7).padding(.vertical, 5)
                    .background(entry.riskColor).cornerRadius(5)
                    .frame(width: 120, alignment: .center)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(isSelected ? T.purple.opacity(0.09) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Models
// ════════════════════════════════════════════════════════════════════

struct KYCOption: Identifiable {
    let id = UUID()
    let value: String
    let label: String
    init(_ text: String) { self.value = text; self.label = text }
    init(value: String, label: String) { self.value = value; self.label = label }
}

enum KYCCompanyFormStep: Int, CaseIterable {
    case companyInfo = 0, companyDocs, authLetter, beneficialOwner
    var title: String {
        switch self {
        case .companyInfo:     return "Company\nInformation"
        case .companyDocs:     return "Company\nDocuments"
        case .authLetter:      return "Authorization\nLetter"
        case .beneficialOwner: return "Beneficial\nOwner"
        }
    }
    var icon: String {
        switch self {
        case .companyInfo:     return "building.2"
        case .companyDocs:     return "doc.text"
        case .authLetter:      return "doc.badge.arrow.up"
        case .beneficialOwner: return "person.2"
        }
    }
}

struct KYCSheet: Identifiable {
    let id      = UUID()
    let title:    String
    let options:  [KYCOption]
    let binding:  Binding<String>
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Reusable UI Components
// ════════════════════════════════════════════════════════════════════

struct KYCSectionCard: View {
    let title: String; let content: AnyView
    init(title: String, @ViewBuilder content: () -> some View) {
        self.title = title; self.content = AnyView(content())
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(T.white)
            content
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(T.card).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(T.border.opacity(0.6), lineWidth: 1))
    }
}

struct KYCFieldLabel: View {
    let text: String; let required: Bool; let content: AnyView
    init(_ text: String, required: Bool = false, @ViewBuilder content: () -> some View) {
        self.text = text; self.required = required; self.content = AnyView(content())
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(text).font(.system(size: 13, weight: .medium)).foregroundColor(T.white)
                    .fixedSize(horizontal: false, vertical: true)
                if required { Text("*").font(.system(size: 13)).foregroundColor(T.red) }
            }
            content
        }
    }
}

struct KYCInputField: View {
    let placeholder: String
    @Binding var text: String
    var hasError:     Bool           = false
    var keyboardType: UIKeyboardType = .default
    private var strokeColor: Color { hasError ? T.red.opacity(0.7) : T.border }
    var body: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .font(.system(size: 14)).foregroundColor(T.white)
                .keyboardType(keyboardType).autocorrectionDisabled()
                .textInputAutocapitalization(.never).tint(T.purple).submitLabel(.next)
            if hasError {
                Image(systemName: "exclamationmark.circle.fill").foregroundColor(T.red).font(.system(size: 17))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(T.field).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(strokeColor, lineWidth: 1))
    }
}

// MARK: Password Field — with show/hide eye toggle
struct KYCPasswordField: View {
    let placeholder: String
    @Binding var text: String
    var hasError: Bool = false
    @State private var isVisible = false
    private var strokeColor: Color { hasError ? T.red.opacity(0.7) : T.border }
    var body: some View {
        HStack(spacing: 8) {
            Group {
                if isVisible {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 14)).foregroundColor(T.white).tint(T.purple)
                        .autocorrectionDisabled().textInputAutocapitalization(.never).submitLabel(.done)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 14)).foregroundColor(T.white).tint(T.purple).submitLabel(.done)
                }
            }
            // Eye toggle
            Button { isVisible.toggle() } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(T.gray).font(.system(size: 16))
            }
            .buttonStyle(.plain)
            if hasError {
                Image(systemName: "exclamationmark.circle.fill").foregroundColor(T.red).font(.system(size: 17))
            }
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(T.field).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(strokeColor, lineWidth: 1))
    }
}

struct KYCMultilineField: View {
    let placeholder: String
    @Binding var text: String
    var hasError: Bool = false
    private var strokeColor: Color { hasError ? T.red.opacity(0.7) : T.border }
    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 10).fill(T.field).frame(minHeight: 90)
            RoundedRectangle(cornerRadius: 10).stroke(strokeColor, lineWidth: 1).frame(minHeight: 90)
            if text.isEmpty {
                Text(placeholder).font(.system(size: 13)).foregroundColor(T.gray2)
                    .padding(.horizontal, 14).padding(.top, 13).allowsHitTesting(false)
            }
            TextEditor(text: $text)
                .font(.system(size: 14)).foregroundColor(T.white)
                .scrollContentBackground(.hidden).background(Color.clear).tint(T.purple)
                .padding(.horizontal, 10).padding(.vertical, 8).frame(minHeight: 90)
        }
    }
}

struct KYCDropdownTrigger: View {
    let placeholder: String
    @Binding var value: String
    var hasError: Bool = false
    let onTap: () -> Void
    private var labelText:   String { value.isEmpty ? placeholder : value }
    private var labelColor:  Color  { value.isEmpty ? T.gray : T.white }
    private var strokeColor: Color  { hasError ? T.red.opacity(0.7) : T.border }
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(labelText).font(.system(size: 14)).foregroundColor(labelColor)
                    .lineLimit(1).truncationMode(.tail)
                Spacer()
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .medium)).foregroundColor(T.gray)
            }
            .padding(.horizontal, 14).padding(.vertical, 13)
            .background(T.field).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(strokeColor, lineWidth: 1))
        }
    }
}

struct KYCPercentField: View {
    let label: String; @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.system(size: 12)).foregroundColor(T.gray)
            TextField("0", text: $text)
                .font(.system(size: 14, weight: .medium)).foregroundColor(T.white)
                .keyboardType(.numberPad).tint(T.purple)
                .padding(.horizontal, 12).padding(.vertical, 12)
                .background(T.field).cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
        }.frame(maxWidth: .infinity)
    }
}

struct KYCCheckbox: View {
    let isOn: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(isOn ? T.purple.opacity(0.18) : T.field).frame(width: 22, height: 22)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(isOn ? T.purple : T.border, lineWidth: 1.5))
            if isOn { Image(systemName: "checkmark").font(.system(size: 11, weight: .bold)).foregroundColor(T.purple) }
        }
    }
}

struct KYCValidationBanner: View {
    let errors: [String]
    var body: some View {
        if !errors.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(T.yellow).font(.system(size: 15))
                    Text("Please fix the following errors:").font(.system(size: 13, weight: .bold)).foregroundColor(T.white)
                }
                ForEach(errors, id: \.self) { msg in
                    HStack(alignment: .top, spacing: 6) {
                        Text("•").foregroundColor(T.red).font(.system(size: 12))
                        Text(msg).font(.system(size: 12)).foregroundColor(T.red)
                    }
                }
            }
            .padding(14).frame(maxWidth: .infinity, alignment: .leading)
            .background(T.red.opacity(0.10)).cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(T.red.opacity(0.4), lineWidth: 1))
        }
    }
}

struct KYCToast: View {
    let message: String
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill").foregroundColor(T.green).font(.system(size: 18))
            Text(message).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
        }
        .padding(.horizontal, 20).padding(.vertical, 14)
        .background(T.card).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(T.green.opacity(0.5), lineWidth: 1))
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
    }
}

struct KYCPickerSheet: View {
    let title: String; let options: [KYCOption]
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ZStack {
                T.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(options) { opt in
                            pickerRow(opt)
                            Rectangle().fill(T.border.opacity(0.5)).frame(height: 1).padding(.horizontal, 20)
                        }
                    }.padding(.top, 6).padding(.bottom, 20)
                }
            }
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(T.purple)
                }
            }
        }.preferredColorScheme(.dark)
    }
    private func pickerRow(_ opt: KYCOption) -> some View {
        let isSel = selected == opt.value
        return Button { selected = opt.value; dismiss() } label: {
            HStack(spacing: 12) {
                Text(opt.label).font(.system(size: 15)).foregroundColor(isSel ? T.purple : T.white)
                Spacer()
                if isSel { Image(systemName: "checkmark.circle.fill").font(.system(size: 18)).foregroundColor(T.purple) }
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(isSel ? T.purple.opacity(0.09) : .clear).contentShape(Rectangle())
        }.buttonStyle(.plain)
    }
}

struct KYCDocUploadField: View {
    let title: String; let required: Bool; var description: String?
    let fileName: String; let onChoose: () -> Void
    private let hint = "Accepted: JPG, PDF, PNG, JPEG, DOC, DOCX, JFIF, HEIC. Max 6MB."
    private var borderColor:   Color  { required && fileName.isEmpty ? T.red.opacity(0.6) : T.border }
    private var fileNameColor: Color  { fileName.isEmpty ? Color(white: 0.55) : T.purple }
    private var fileNameText:  String { fileName.isEmpty ? "No file chosen" : fileName }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 2) {
                Text(title).font(.system(size: 13, weight: .semibold)).foregroundColor(T.white)
                    .fixedSize(horizontal: false, vertical: true)
                if required { Text(" *").font(.system(size: 13, weight: .semibold)).foregroundColor(T.red) }
            }
            if let desc = description {
                Text(desc).font(.system(size: 12)).foregroundColor(T.gray)
                    .fixedSize(horizontal: false, vertical: true).lineSpacing(2)
            }
            HStack(spacing: 0) {
                Button(action: onChoose) {
                    Text("Choose file").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .background(T.blue).kycCornerRadius(8, corners: [.topLeft, .bottomLeft])
                }
                Text(fileNameText).font(.system(size: 13)).foregroundColor(fileNameColor)
                    .lineLimit(1).truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10).padding(.vertical, 11)
                    .background(Color(red: 0.16, green: 0.19, blue: 0.26))
                    .kycCornerRadius(8, corners: [.topRight, .bottomRight])
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 1))
            Text(hint).font(.system(size: 10)).foregroundColor(Color(white: 0.45))
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct KYCRoundedCorner: Shape {
    var radius: CGFloat; var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
private extension View {
    func kycCornerRadius(_ r: CGFloat, corners: UIRectCorner) -> some View { clipShape(KYCRoundedCorner(radius: r, corners: corners)) }
}

private struct KYCAuthUploadCard: View {
    let title: String; let isOptional: Bool
    let bodyText: String; let downloadURL: String
    @Binding var fileName: String
    @Binding var fileURL: URL?
    @State private var showPicker = false
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(title).font(.system(size: 14, weight: .semibold)).foregroundColor(T.white)
                if isOptional { Text("(Optional)").font(.system(size: 12)).foregroundColor(T.gray) }
            }
            linkedBody
            HStack(spacing: 0) {
                Button { showPicker = true } label: {
                    Text("Choose file").font(.system(size: 13, weight: .semibold)).foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 11)
                        .background(T.blue).kycCornerRadius(8, corners: [.topLeft, .bottomLeft])
                }
                Text(fileName.isEmpty ? "No file chosen" : fileName)
                    .font(.system(size: 13)).foregroundColor(fileName.isEmpty ? Color(white:0.55) : T.purple)
                    .lineLimit(1).truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10).padding(.vertical, 11)
                    .background(Color(red: 0.16, green: 0.19, blue: 0.26))
                    .kycCornerRadius(8, corners: [.topRight, .bottomRight])
            }
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(T.border, lineWidth: 1))
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(T.field).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(T.border.opacity(0.7), lineWidth: 1))
        .fileImporter(isPresented: $showPicker, allowedContentTypes: [.pdf, .image, .data], allowsMultipleSelection: false) { result in
            if let url = try? result.get().first { 
                _ = url.startAccessingSecurityScopedResource()
                fileName = url.lastPathComponent
                fileURL = url
            }
        }
    }
    private var linkedBody: some View {
        var str = AttributedString(bodyText)
        if let r = str.range(of: "here") {
            str[r].foregroundColor = Color(red: 0.45, green: 0.65, blue: 1.0)
            str[r].underlineStyle  = .single
            if let url = URL(string: downloadURL) { str[r].link = url }
        }
        return Text(str).font(.system(size: 13)).foregroundColor(T.gray).lineSpacing(3).fixedSize(horizontal: false, vertical: true)
    }
}

private struct UBOOwnerRow: View {
    let owner: UBOOwner; let onEdit: () -> Void; let onDelete: () -> Void
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(T.blue.opacity(0.2)).frame(width: 42, height: 42)
                Text(owner.fullName.prefix(1).uppercased())
                    .font(.system(size: 17, weight: .bold)).foregroundColor(Color(red:0.45,green:0.65,blue:1.0))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(owner.fullName.isEmpty ? "—" : owner.fullName).font(.system(size: 14, weight: .semibold)).foregroundColor(T.white)
                HStack(spacing: 8) {
                    if !owner.ownerType.isEmpty { Text(owner.ownerType).font(.system(size: 11)).foregroundColor(T.gray) }
                    if !owner.country.isEmpty   { Text("• \(owner.country)").font(.system(size: 11)).foregroundColor(T.gray) }
                }
            }
            Spacer()
            Text((owner.ownershipPct.isEmpty ? "0" : owner.ownershipPct) + "%")
                .font(.system(size: 13, weight: .bold)).foregroundColor(T.green)
                .padding(.horizontal, 10).padding(.vertical, 5).background(T.green.opacity(0.12)).cornerRadius(6)
            Menu {
                Button { onEdit() } label: { Label("Edit", systemImage: "pencil") }
                Button(role: .destructive) { onDelete() } label: { Label("Delete", systemImage: "trash") }
            } label: {
                Image(systemName: "ellipsis").font(.system(size: 16, weight: .medium)).foregroundColor(T.gray)
                    .frame(width: 32, height: 32).background(T.field).cornerRadius(6)
            }
        }
        .padding(12).background(T.field).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Option Lists
// ════════════════════════════════════════════════════════════════════

private enum opts {
    // Yes / No
    static let yesNo = ["Yes", "No"].map(KYCOption.init)

    // Countries are now fetched dynamically via GetCountriesService
    static let countries: [KYCOption] = []

    // Corporate Structure — matches Image 6
    static let corpStructure = [
        "Corporation",
        "LLC",
        "Partnership",
        "Sole Proprietorship",
        "Non-Profit",
        "Trust",
        "Other"
    ].map(KYCOption.init)

    // Business Activity
    static let bizActivity = [
        "0742 - Veterinary Services","0763 - Agricultural Cooperatives","0780 - Horticultural and Landscaping Services","1520 - General Contractors–Residential and Commercial","1711 - Air Conditioning, Heating and Plumbing Contractors", "1731 - Electrical Contractors", "1750 - Carpentry Contractors","1761 - Roofing and Siding, Sheet Metal Work Contractors","1771 - Concrete Work Contractors", "2741 - Miscellaneous Publishing and Printing","2791 - Typesetting", "4011 - Railroads–Freight", "4112 - Passenger Railways","4119 - Ambulance Services","4121 - Taxicabs and Limousines","4131 - Bus Lines"
    ].map(KYCOption.init)

    // Tax ID Types — matches Image 5 (added TIN)
    static let taxIdTypes = [
        "EIN (Employer Identification Number)",
        "SSN (Social Security Number)",
        "ITIN (Individual Taxpayer Identification Number)",
        "TIN (Taxpayer Identification Number)"
    ].map(KYCOption.init)

    // Years in business / location
    static let years = [
        "Less than 1 year","1-2 years","2-5 years","5+ years"
    ].map(KYCOption.init)

    // Premise types
    static let premiseTypes  = ["Select Premise Type","Kiosk","Mailbox","Office building","Residential/Home office","Retails store front","Mobile/on the go","Webiste" ].map(KYCOption.init)
    static let premiseOwners = ["Owner","Tenant","Shared","Other"].map(KYCOption.init)
    static let areaZoned     = ["Commercial","Residential","Industrial","Mixed-Use","Other"].map(KYCOption.init)

    // Revenue / Profit / Total Assets — matches Images 1 & 3
    static let revenue = [
        "$0 - $10,000",
        "$10,000 - $25,000",
        "$25,000 - $50,000",
        "$50,000 - $100,000",
        "$100,000 - $200,000",
        "$200,000 - $300,000",
        "$300,000 - $1,000,000",
        "$1,000,000+"
    ].map(KYCOption.init)

    // Net Worth — matches Image 2 (different scale)
    static let netWorthOpts = [
        "$0 - $10,000",
        "$10,000 - $25,000",
        "$25,000 - $50,000",
        "$50,000 - $100,000",
        "$100,000 - $200,000",
        "$200,000 - $300,000",
        "$300,000 - $1,000,000",
        "$1,000,000+"
    ].map(KYCOption.init)

    // Account purpose & source
    static let accountPurpose   = ["Trading","Investment","Payment Processing","Treasury Management","Other"].map(KYCOption.init)
    static let sourceInvestment = ["Company Revenue","Investor Funding","Bank Loan","Asset Sale","Other"].map(KYCOption.init)

    // Monthly Transaction Volume — matches Image 4 (same ranges as revenue)
    static let txVolume = [
        "$0 - $10,000",
        "$10,000 - $25,000",
        "$25,000 - $50,000",
        "$50,000 - $100,000",
        "$100,000 - $200,000",
        "$200,000 - $300,000",
        "$300,000 - $1,000,000",
        "$1,000,000+"
    ].map(KYCOption.init)

    // Transaction Frequency — matches Images 7 & 9
    static let txFrequency = [
        "0-10 transactions/month",
        "10-100 transactions/month",
        "100-1,000 transactions/month",
        "1,000+ transactions/month"
    ].map(KYCOption.init)

    // Banking relationship duration — matches Image 7
    static let duration = [
        "0-1 year",
        "1-2 years",
        "2+ years"
    ].map(KYCOption.init)

    // Phone codes
    static let phoneCodes = [
        "+1 (US)","+1 (CA)","+44 (UK)","+91 (IN)","+61 (AU)",
        "+49 (DE)","+33 (FR)","+65 (SG)","+971 (AE)"
    ].map(KYCOption.init)

    // Refund days & card charged
    static let refundDays: [KYCOption] = [
        KYCOption(value: "No Refunds", label: "No Refunds"),
        KYCOption(value: "Same Day", label: "Same Day"),
        KYCOption(value: "3 Days", label: "3 Days"),
        KYCOption(value: "7 Days", label: "7 Days"),
        KYCOption(value: "14 Days", label: "14 Days"),
        KYCOption(value: "15 Days", label: "15 Days"),
        KYCOption(value: "30 Days", label: "30 Days (most common)"),
        KYCOption(value: "45 Days", label: "45 Days"),
        KYCOption(value: "60 Days", label: "60 Days"),
        KYCOption(value: "90 Days", label: "90 Days"),
        KYCOption(value: "More than 90 Days", label: "More than 90 Days"),
        KYCOption(value: "Case-by-Case", label: "Case-by-Case"),
        KYCOption(value: "Other", label: "Other")
    ]
    
    static let refundProcess: [KYCOption] = [
        KYCOption(value: "Same Day", label: "Same Day"),
        KYCOption(value: "1-2 Business Days", label: "1–2 Business Days"),
        KYCOption(value: "3-5 Business Days", label: "3–5 Business Days (common)"),
        KYCOption(value: "5-7 Business Days", label: "5–7 Business Days (common)"),
        KYCOption(value: "7-10 Business Days", label: "7–10 Business Days"),
        KYCOption(value: "10-14 Business Days", label: "10–14 Business Days"),
        KYCOption(value: "14-30 Business Days", label: "14–30 Business Days"),
        KYCOption(value: "More than 30 Business Days", label: "More than 30 Business Days"),
        KYCOption(value: "Case-by-Case", label: "Case-by-Case"),
        KYCOption(value: "Not Applicable", label: "Not Applicable"),
        KYCOption(value: "Other", label: "Other")
    ]
    static let cardCharged: [KYCOption] = [
        KYCOption(value: "After product or service is provided", label: "After product or service is provided"),
        KYCOption(value: "In Advance", label: "In Advance")
    ]

    // Bankruptcy — matches Image 8
    static let bankruptcy = [
        "Business Bankruptcy",
        "Personal Bankruptcy",
        "Never Filed for Bankruptcy"
    ].map(KYCOption.init)
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Main Form View
// ════════════════════════════════════════════════════════════════════

struct EnterpriseKycFormView: View {

    let prefill: KYCPrefillData?
    init(prefill: KYCPrefillData? = nil) { self.prefill = prefill }

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = KYCEnterpriseViewModel()
    @State private var currentStep: KYCCompanyFormStep = .companyInfo
    @State private var validationErrors: [String] = []
    @State private var showValidationBanner = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var apiCountries: [KYCOption] = []

    // Company
    @State private var companyName = "";       @State private var companyRegNo = ""
    @State private var companyWebsite = "";    @State private var countryOfIncorp = ""
    @State private var corporateStructure = ""; @State private var businessActivity = ""
    @State private var dbaName = "";           @State private var phoneCode = ""
    @State private var businessPhone = "";     @State private var businessEmail = ""
    @State private var yearsInBusiness = "";   @State private var businessDesc = ""
    @State private var stockExchange = "";     @State private var stockTicker = ""
    // Tax
    @State private var taxIdType = "";   @State private var tinNumber = ""
    @State private var exemptPayee = ""; @State private var isNonprofit = ""
    // Address
    @State private var regAddress = "";       @State private var regCity = ""
    @State private var regState = "";         @State private var regCountry = ""
    @State private var regZip = "";           @State private var premiseType = ""
    @State private var yearsInLocation = "";  @State private var premiseOwner = ""
    @State private var areaZoned = "";        @State private var squareFootage = ""
    @State private var numLocations = "";     @State private var officeSameAsReg = true
    // Financial
    @State private var annualRevenue = ""; @State private var annualProfit = ""
    @State private var totalAssets = "";   @State private var netWorth = ""
    // Banking
    @State private var accountPurpose = "";  @State private var sourceInvestment = ""
    @State private var monthlyTxVol = "";    @State private var txFrequency = ""
    @State private var bankingPartner = "";  @State private var bankingDuration = ""
    // Processing
    @State private var processingCards = ""; @State private var onlinePct = ""
    @State private var inPersonPct = "";     @State private var phonePct = ""
    @State private var keyedPct = "";        @State private var monthlyCardAmt = ""
    @State private var avgTxSize = "";       @State private var maxTxSize = ""
    @State private var acceptACH = "";       @State private var acceptAmex = false
    // NEW: Amex sub-fields
    @State private var amexMonthlyVol = "";  @State private var amexAvgTicket = ""
    @State private var amexHighTicket = ""
    // Processing URLs
    @State private var processingURL = ""; @State private var demoUser = ""
    @State private var demoPass = ""
    // Business Ops
    @State private var adMethods: Set<String> = []
    @State private var inboundPct = "";    @State private var outboundPct = ""
    @State private var b2bPct = "";        @State private var b2cPct = ""
    @State private var isSeasonal = "";    @State private var refundPolicy = ""
    @State private var refundReqDays = ""; @State private var refundProcDays = ""
    // Fulfillment / Risk
    @State private var cardChargedWhen = "";   @State private var thirdPartyFulfill = ""
    @State private var pciCompliant = "";      @State private var terminatedMerchant = ""
    @State private var dataCompromise = "";    @State private var visaRisk = ""
    @State private var thirdPartyPayment = ""; @State private var filedBankruptcy = ""
    // Docs
    @State private var docFiles: [String: String] = [:]
    @State private var docURLs: [String: URL] = [:]
    @State private var processingStatementName = ""
    @State private var processingStatementURL: URL? = nil
    @State private var companyBankStatementName = ""
    @State private var companyBankStatementURL: URL? = nil
    @State private var showDocPicker = false; @State private var docPickerIndex = 0
    // Auth Letter
    @State private var wolfsbergFileName = ""; @State private var wolfsbergFileURL: URL? = nil
    @State private var authLetterFileName = ""; @State private var authLetterFileURL: URL? = nil
    // UBO
    @State private var uboOwners: [UBOOwner] = []
    @State private var showAddOwnerSheet = false; @State private var editingOwner: UBOOwner? = nil
    // Sheets / Toast
    @State private var activeSheet: KYCSheet? = nil
    @State private var showToast = false; @State private var toastMessage = ""
    // NEW: MCC modal
    @State private var showMCCModal = false
    @StateObject private var mccViewModel = BusinessActivityViewModel()

    // MARK: Keyboard
    private func subscribeKeyboard() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { n in
            let f = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = f.height }
        }
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)) { keyboardHeight = 0 }
        }
    }

    // MARK: Helpers
    private func isValidEmail(_ s: String) -> Bool {
        s.range(of: #"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#, options: .regularExpression) != nil
    }
    private func err(_ v: Bool) -> Bool { showValidationBanner && v }
    private func show(_ title: String, _ options: [KYCOption], _ b: Binding<String>) {
        activeSheet = KYCSheet(title: title, options: options, binding: b)
    }
    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    // MARK: body
    var body: some View {
        ZStack {
            T.bg.ignoresSafeArea()
            toastLayer
            VStack(spacing: 0) {
                headerBar
                stepperBar.padding(.vertical, 14)
                Divider().background(T.border)
                mainScroll
                saveBar
            }
            if viewModel.isLoading { loadingOverlay }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $activeSheet) { s in KYCPickerSheet(title: s.title, options: s.options, selected: s.binding) }
        // MCC modal sheet
        .sheet(isPresented: $showMCCModal) { BusinessActivityPickerSheet(vm: mccViewModel, selected: $businessActivity) }
        .alert("Submitted Successfully", isPresented: $viewModel.showSuccessAlert) {
            Button("OK") { viewModel.reset() }
        } message: { Text("Your KYC information has been submitted successfully.") }
        .alert("Submission Failed", isPresented: Binding(
            get: { viewModel.errorMessage != nil }, set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("Retry") { submitForm() }
            Button("Cancel", role: .cancel) { viewModel.errorMessage = nil }
        } message: { Text(viewModel.errorMessage ?? "An unexpected error occurred.") }
        .onAppear {
            viewModel.adminUser = SessionManager.shared.adminUserId
            viewModel.uuid      = SessionManager.shared.uuid
            if let p = prefill {
                applyPrefill(p)
            } else if let data = UserDefaults.standard.data(forKey: "KYCEnterpriseDraft"),
                      let draft = try? JSONDecoder().decode(KYCPrefillData.self, from: data) {
                applyPrefill(draft)
            }
            subscribeKeyboard()
            mccViewModel.fetchIfNeeded()
            GetCountriesService.shared.fetchCountries { result in
                if case .success(let countries) = result {
                    self.apiCountries = countries.map(KYCOption.init)
                }
            }
        }
        .onDisappear {
            saveLocalDraft()
        }
    }

    @ViewBuilder private var toastLayer: some View {
        if showToast {
            VStack {
                Spacer()
                KYCToast(message: toastMessage)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 8 : 100)
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showToast)
            .allowsHitTesting(false)
        }
    }

    private var mainScroll: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if showValidationBanner && !validationErrors.isEmpty {
                    KYCValidationBanner(errors: validationErrors).padding(.top, 4)
                }
                currentStepContent
            }
            .padding(.horizontal, 16).padding(.top, 16)
            .padding(.bottom, keyboardHeight > 0 ? keyboardHeight + 24 : 110)
        }
        .scrollDismissesKeyboard(.interactively)
        .onTapGesture { dismissKeyboard() }
    }

    @ViewBuilder private var currentStepContent: some View {
        switch currentStep {
        case .companyInfo:     companyInfoStep1; companyInfoStep2; companyInfoStep3
        case .companyDocs:     sectionCompanyDocuments
        case .authLetter:      sectionAuthLetter
        case .beneficialOwner: sectionBeneficialOwner
        }
    }

    @ViewBuilder private var companyInfoStep1: some View { sectionCompanyInfo; sectionTaxInfo; sectionRegisteredAddress; sectionFinancial }
    @ViewBuilder private var companyInfoStep2: some View { sectionBanking; sectionProcessing; sectionProcessingURLs; sectionBusinessOps }
    @ViewBuilder private var companyInfoStep3: some View { sectionFulfillment; sectionRisk; sectionBankruptcy }

    // MARK: Prefill
    private func applyPrefill(_ p: KYCPrefillData) {
        print("📝 [VerificationView] applyPrefill: companyName='\(p.companyName)', companyRegNo='\(p.companyRegNo)', companyWebsite='\(p.companyWebsite)'")
        companyName = p.companyName; companyRegNo = p.companyRegNo; companyWebsite = p.companyWebsite
        countryOfIncorp = p.countryOfIncorp; corporateStructure = p.corporateStructure; businessActivity = p.businessActivity
        dbaName = p.dbaName; businessPhone = p.businessPhone; businessEmail = p.businessEmail
        yearsInBusiness = p.yearsInBusiness; businessDesc = p.businessDesc; stockExchange = p.stockExchange
        stockTicker = p.stockTicker; taxIdType = p.taxIdType; tinNumber = p.tinNumber
        exemptPayee = p.exemptPayee; isNonprofit = p.isNonprofit; regAddress = p.regAddress
        regCity = p.regCity; regState = p.regState; regCountry = p.regCountry; regZip = p.regZip
        premiseType = p.premiseType; yearsInLocation = p.yearsInLocation; premiseOwner = p.premiseOwner
        areaZoned = p.areaZoned; squareFootage = p.squareFootage; numLocations = p.numLocations
        annualRevenue = p.annualRevenue; annualProfit = p.annualProfit; totalAssets = p.totalAssets; netWorth = p.netWorth
        accountPurpose = p.accountPurpose; sourceInvestment = p.sourceInvestment; monthlyTxVol = p.monthlyTxVol
        txFrequency = p.txFrequency; bankingPartner = p.bankingPartner; bankingDuration = p.bankingDuration
        processingCards = p.processingCards; onlinePct = p.onlinePct; inPersonPct = p.inPersonPct
        phonePct = p.phonePct; keyedPct = p.keyedPct; monthlyCardAmt = p.monthlyCardAmt
        avgTxSize = p.avgTxSize; maxTxSize = p.maxTxSize; acceptACH = p.acceptACH; acceptAmex = p.acceptAmex
        processingURL = p.processingURL; demoUser = p.demoUser; demoPass = p.demoPass
        adMethods = p.adMethods; inboundPct = p.inboundPct; outboundPct = p.outboundPct
        b2bPct = p.b2bPct; b2cPct = p.b2cPct; isSeasonal = p.isSeasonal; refundPolicy = p.refundPolicy
        refundReqDays = p.refundReqDays; refundProcDays = p.refundProcDays; cardChargedWhen = p.cardChargedWhen
        thirdPartyFulfill = p.thirdPartyFulfill; pciCompliant = p.pciCompliant; terminatedMerchant = p.terminatedMerchant
        dataCompromise = p.dataCompromise; visaRisk = p.visaRisk; thirdPartyPayment = p.thirdPartyPayment
        filedBankruptcy = p.filedBankruptcy
        uboOwners = p.uboOwners
        companyBankStatementURL = p.companyBankStatement
        
        docFiles["0-left"] = p.incorporationCertificateName
        docFiles["0-right"] = p.memorandumName
        docFiles["1-left"] = p.associationArticlesName
        docFiles["1-right"] = p.incumbencyCertificateName
        docFiles["2-left"] = p.directorsRegisterName
        docFiles["2-right"] = p.shareholdersRegisterName
        docFiles["3-left"] = p.boardResolutionName
        docFiles["3-right"] = p.addressProofName
        companyBankStatementName = p.companyBankStatementName
        wolfsbergFileName = p.wolfsbergDocName
        authLetterFileName = p.authorizationLetterName
        processingStatementName = p.processingStatementName
    }

    private func saveLocalDraft() {
        var p = KYCPrefillData()
        p.companyName = companyName; p.companyRegNo = companyRegNo; p.companyWebsite = companyWebsite
        p.countryOfIncorp = countryOfIncorp; p.corporateStructure = corporateStructure; p.businessActivity = businessActivity
        p.dbaName = dbaName; p.businessPhone = businessPhone; p.businessEmail = businessEmail
        p.yearsInBusiness = yearsInBusiness; p.businessDesc = businessDesc; p.stockExchange = stockExchange
        p.stockTicker = stockTicker; p.taxIdType = taxIdType; p.tinNumber = tinNumber
        p.exemptPayee = exemptPayee; p.isNonprofit = isNonprofit; p.regAddress = regAddress
        p.regCity = regCity; p.regState = regState; p.regCountry = regCountry; p.regZip = regZip
        p.premiseType = premiseType; p.yearsInLocation = yearsInLocation; p.premiseOwner = premiseOwner
        p.areaZoned = areaZoned; p.squareFootage = squareFootage; p.numLocations = numLocations
        p.annualRevenue = annualRevenue; p.annualProfit = annualProfit; p.totalAssets = totalAssets; p.netWorth = netWorth
        p.accountPurpose = accountPurpose; p.sourceInvestment = sourceInvestment; p.monthlyTxVol = monthlyTxVol
        p.txFrequency = txFrequency; p.bankingPartner = bankingPartner; p.bankingDuration = bankingDuration
        p.processingCards = processingCards; p.onlinePct = onlinePct; p.inPersonPct = inPersonPct
        p.phonePct = phonePct; p.keyedPct = keyedPct; p.monthlyCardAmt = monthlyCardAmt
        p.avgTxSize = avgTxSize; p.maxTxSize = maxTxSize; p.acceptACH = acceptACH; p.acceptAmex = acceptAmex
        p.processingURL = processingURL; p.demoUser = demoUser; p.demoPass = demoPass
        p.adMethods = adMethods; p.inboundPct = inboundPct; p.outboundPct = outboundPct
        p.b2bPct = b2bPct; p.b2cPct = b2cPct; p.isSeasonal = isSeasonal; p.refundPolicy = refundPolicy
        p.refundReqDays = refundReqDays; p.refundProcDays = refundProcDays; p.cardChargedWhen = cardChargedWhen
        p.thirdPartyFulfill = thirdPartyFulfill; p.pciCompliant = pciCompliant; p.terminatedMerchant = terminatedMerchant
        p.dataCompromise = dataCompromise; p.visaRisk = visaRisk; p.thirdPartyPayment = thirdPartyPayment
        p.filedBankruptcy = filedBankruptcy
        p.uboOwners = uboOwners
        p.companyBankStatement = companyBankStatementURL
        
        p.incorporationCertificateName = docFiles["0-left"] ?? ""
        p.memorandumName               = docFiles["0-right"] ?? ""
        p.associationArticlesName      = docFiles["1-left"] ?? ""
        p.incumbencyCertificateName    = docFiles["1-right"] ?? ""
        p.directorsRegisterName        = docFiles["2-left"] ?? ""
        p.shareholdersRegisterName     = docFiles["2-right"] ?? ""
        p.boardResolutionName          = docFiles["3-left"] ?? ""
        p.addressProofName             = docFiles["3-right"] ?? ""
        p.companyBankStatementName     = companyBankStatementName
        p.wolfsbergDocName             = wolfsbergFileName
        p.authorizationLetterName      = authLetterFileName
        p.processingStatementName      = processingStatementName

        if let data = try? JSONEncoder().encode(p) {
            UserDefaults.standard.set(data, forKey: "KYCEnterpriseDraft")
        }
    }

    // MARK: Loading
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.55).ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView().progressViewStyle(.circular).scaleEffect(1.4).tint(T.purple)
                Text("Submitting KYC…").font(.system(size: 15, weight: .medium)).foregroundColor(T.white)
            }
            .padding(32).background(T.card).cornerRadius(16)
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(T.border, lineWidth: 1))
        }
    }

    // MARK: Nav / Validate
    private func advanceOrSubmit(isLastStep: Bool) {
        dismissKeyboard()
        saveLocalDraft()
        
        let errors = validateStep()
        guard errors.isEmpty else { validationErrors = errors; showValidationBanner = true; return }
        showValidationBanner = false; validationErrors = []
        let map: [KYCCompanyFormStep: String] = [
            .companyInfo: "Company Info Saved", .companyDocs: "Documents Saved",
            .authLetter: "Authorization Letter Saved", .beneficialOwner: "Beneficial Owner Saved"
        ]
        if let msg = map[currentStep] {
            toastMessage = msg
            withAnimation { showToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { withAnimation { showToast = false } }
        }
        if isLastStep { submitForm() }
        else {
            withAnimation {
                if let next = KYCCompanyFormStep.allCases.first(where: { $0.rawValue == currentStep.rawValue + 1 }) { currentStep = next }
            }
        }
    }
    private func validateStep() -> [String] {
        switch currentStep {
        case .companyInfo:     return validateCompanyInfo()
        case .companyDocs:     return validateDocs()
        case .authLetter:      return []
        case .beneficialOwner: return validateUBO()
        }
    }
    private func validateCompanyInfo() -> [String] {
        var e: [String] = []
        if companyName.trimmingCharacters(in: .whitespaces).isEmpty  { e.append("Company Name is required") }
        if companyRegNo.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Company Registration Number is required") }
        if countryOfIncorp.isEmpty    { e.append("Country of Incorporation is required") }
        if corporateStructure.isEmpty { e.append("Corporate Structure is required") }
        if businessActivity.isEmpty   { e.append("Business Activity is required") }
        if dbaName.trimmingCharacters(in: .whitespaces).isEmpty { e.append("DBA Name is required") }
        if phoneCode.isEmpty || businessPhone.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Business Phone Number is required") }
        if businessEmail.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Business Email Address is required") }
        else if !isValidEmail(businessEmail) { e.append("Business Email is not valid") }
        if yearsInBusiness.isEmpty { e.append("Years in Business is required") }
        if businessDesc.trimmingCharacters(in: .whitespaces).count < 10 { e.append("Business Description must be at least 10 characters") }
        if taxIdType.isEmpty   { e.append("Tax ID Type is required") }
        if tinNumber.trimmingCharacters(in: .whitespaces).isEmpty { e.append("TIN is required") }
        if exemptPayee.isEmpty { e.append("Exempt Payee selection is required") }
        if isNonprofit.isEmpty { e.append("501(c)(3) Nonprofit selection is required") }
        if regAddress.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Address is required") }
        if regCity.trimmingCharacters(in: .whitespaces).isEmpty    { e.append("City is required") }
        if regState.trimmingCharacters(in: .whitespaces).isEmpty   { e.append("State is required") }
        if regCountry.isEmpty  { e.append("Country is required") }
        if regZip.trimmingCharacters(in: .whitespaces).isEmpty     { e.append("Zip Code is required") }
        if premiseType.isEmpty     { e.append("Premise Type is required") }
        if yearsInLocation.isEmpty { e.append("Years in Location is required") }
        if premiseOwner.isEmpty    { e.append("Premise Owner is required") }
        if areaZoned.isEmpty       { e.append("Area Zoned is required") }
        if squareFootage.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Square Footage is required") }
        if numLocations.trimmingCharacters(in: .whitespaces).isEmpty  { e.append("Number of Locations is required") }
        if annualRevenue.isEmpty    { e.append("Annual Revenue is required") }
        if annualProfit.isEmpty     { e.append("Profit is required") }
        if totalAssets.isEmpty      { e.append("Total Company Assets is required") }
        if netWorth.isEmpty         { e.append("Company Net Worth is required") }
        if accountPurpose.isEmpty   { e.append("Account Purpose is required") }
        if sourceInvestment.isEmpty { e.append("Source of Investment is required") }
        if monthlyTxVol.isEmpty     { e.append("Monthly Transaction Volume is required") }
        if txFrequency.isEmpty      { e.append("Transaction Frequency is required") }
        if bankingPartner.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Banking Partner is required") }
        if bankingDuration.isEmpty  { e.append("Banking Relationship Duration is required") }
        if processingCards.isEmpty  { e.append("Processing cards selection is required") }
        if monthlyCardAmt.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Monthly card processing amount is required") }
        if avgTxSize.trimmingCharacters(in: .whitespaces).isEmpty      { e.append("Average transaction size is required") }
        if maxTxSize.trimmingCharacters(in: .whitespaces).isEmpty      { e.append("Highest transaction size is required") }
        if acceptACH.isEmpty { e.append("ACH/eCheck selection is required") }
        // Amex sub-field validation
        if acceptAmex {
            if amexMonthlyVol.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Amex Monthly Volume is required") }
            if amexAvgTicket.trimmingCharacters(in: .whitespaces).isEmpty  { e.append("Amex Avg Ticket is required") }
            if amexHighTicket.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Amex High Ticket is required") }
        }
        if processingURL.trimmingCharacters(in: .whitespaces).isEmpty { e.append("Website URL is required") }
        if demoUser.trimmingCharacters(in: .whitespaces).isEmpty      { e.append("Demo username is required") }
        if demoPass.trimmingCharacters(in: .whitespaces).isEmpty      { e.append("Demo password is required") }
        if adMethods.isEmpty { e.append("At least one Advertising Method must be selected") }
        let io = (Int(inboundPct) ?? 0) + (Int(outboundPct) ?? 0)
        if io != 100 { e.append("Inbound/Outbound percentages must total 100% (currently \(io)%)") }
        let b2 = (Int(b2bPct) ?? 0) + (Int(b2cPct) ?? 0)
        if b2 != 100 { e.append("B2B/Retail percentages must total 100% (currently \(b2)%)") }
        if isSeasonal.isEmpty  { e.append("Seasonal business selection is required") }
        if refundPolicy.trimmingCharacters(in: .whitespaces).count < 10 { e.append("Refund Policy must be at least 10 characters") }
        if refundReqDays.isEmpty   { e.append("Refund request window is required") }
        if refundProcDays.isEmpty  { e.append("Refund processing time is required") }
        if cardChargedWhen.isEmpty   { e.append("Card charged timing is required") }
        if thirdPartyFulfill.isEmpty { e.append("Third-party fulfillment selection is required") }
        if pciCompliant.isEmpty       { e.append("PCI compliance selection is required") }
        if terminatedMerchant.isEmpty { e.append("Terminated merchant selection is required") }
        if dataCompromise.isEmpty     { e.append("Data compromise selection is required") }
        if visaRisk.isEmpty           { e.append("Visa Risk Programs selection is required") }
        if thirdPartyPayment.isEmpty  { e.append("Third-party payment flow selection is required") }
        if filedBankruptcy.isEmpty    { e.append("Bankruptcy selection is required") }
        return e
    }
    private func validateDocs() -> [String] {
        var e: [String] = []
        if (docFiles["0-left"]  ?? "").isEmpty { e.append("Certificate of Incorporation is required") }
        if (docFiles["3-right"] ?? "").isEmpty { e.append("Proof of Address is required") }
        if companyBankStatementName.isEmpty    { e.append("Bank Statement is required") }
        return e
    }
    private var totalOwnership: Int { uboOwners.reduce(0) { $0 + (Int($1.ownershipPct) ?? 0) } }
    private func validateUBO() -> [String] {
        var e: [String] = []
        if uboOwners.isEmpty     { e.append("At least one Beneficial Owner must be added") }
        if totalOwnership != 100 { e.append("Total ownership must equal 100% (currently \(totalOwnership)%)") }
        return e
    }
    private func submitForm() {
        UserDefaults.standard.removeObject(forKey: "KYCEnterpriseDraft")
        var s = KYCFormSnapshot()
        s.companyName = companyName; s.companyRegNo = companyRegNo; s.companyWebsite = companyWebsite
        s.countryOfIncorp = countryOfIncorp; s.corporateStructure = corporateStructure
        s.businessActivity = businessActivity; s.dbaName = dbaName; s.phoneCode = phoneCode
        s.businessPhone = businessPhone; s.businessEmail = businessEmail; s.yearsInBusiness = yearsInBusiness
        s.businessDesc = businessDesc; s.stockExchange = stockExchange; s.stockTicker = stockTicker
        s.taxIdType = taxIdType; s.tinNumber = tinNumber; s.exemptPayee = exemptPayee; s.isNonprofit = isNonprofit
        s.regAddress = regAddress; s.regCity = regCity; s.regState = regState; s.regCountry = regCountry
        s.regZip = regZip; s.premiseType = premiseType; s.yearsInLocation = yearsInLocation
        s.premiseOwner = premiseOwner; s.areaZoned = areaZoned; s.squareFootage = squareFootage
        s.numLocations = numLocations; s.officeSameAsReg = officeSameAsReg
        s.annualRevenue = annualRevenue; s.annualProfit = annualProfit; s.totalAssets = totalAssets; s.netWorth = netWorth
        s.accountPurpose = accountPurpose; s.sourceInvestment = sourceInvestment; s.monthlyTxVol = monthlyTxVol
        s.txFrequency = txFrequency; s.bankingPartner = bankingPartner; s.bankingDuration = bankingDuration
        s.processingCards = processingCards; s.onlinePct = onlinePct; s.inPersonPct = inPersonPct
        s.phonePct = phonePct; s.keyedPct = keyedPct; s.monthlyCardAmt = monthlyCardAmt
        s.avgTxSize = avgTxSize; s.maxTxSize = maxTxSize; s.acceptACH = acceptACH; s.acceptAmex = acceptAmex
        s.processingURL = processingURL; s.demoUser = demoUser; s.demoPass = demoPass
        s.adMethods = adMethods; s.inboundPct = inboundPct; s.outboundPct = outboundPct
        s.b2bPct = b2bPct; s.b2cPct = b2cPct; s.isSeasonal = isSeasonal; s.refundPolicy = refundPolicy
        s.refundReqDays = refundReqDays; s.refundProcDays = refundProcDays; s.cardChargedWhen = cardChargedWhen
        s.thirdPartyFulfill = thirdPartyFulfill; s.pciCompliant = pciCompliant
        s.terminatedMerchant = terminatedMerchant; s.dataCompromise = dataCompromise
        s.visaRisk = visaRisk; s.thirdPartyPayment = thirdPartyPayment; s.filedBankruptcy = filedBankruptcy
        s.incorporationCertificate = docURLs["0-left"]
        s.memorandum = docURLs["0-right"]
        s.associationArticles = docURLs["1-left"]
        s.incumbencyCertificate = docURLs["1-right"]
        s.directorsRegister = docURLs["2-left"]
        s.shareholdersRegister = docURLs["2-right"]
        s.boardResolution = docURLs["3-left"]
        s.addressProof = docURLs["3-right"]
        s.companyBankStatement = companyBankStatementURL
        s.processingStatement = processingStatementURL
        s.wolfsbergDoc = wolfsbergFileURL
        s.authorizationLetter = authLetterFileURL
        viewModel.submit(form: s)
    }

    // MARK: Header
    private var headerBar: some View {
        HStack(alignment: .center, spacing: 12) {
            // ── Back button — dismisses the view immediately ──
            Button {
                dismissKeyboard()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(T.white)
                    .frame(width: 36, height: 36)
                    .background(T.field)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(T.border, lineWidth: 1))
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 8) {
                    Text("KYC Verification").font(.system(size: 18, weight: .bold)).foregroundColor(T.white)
                    Text("Enterprise").font(.system(size: 11, weight: .bold)).foregroundColor(T.purple)
                        .padding(.horizontal, 9).padding(.vertical, 3)
                        .overlay(Capsule().stroke(T.purple, lineWidth: 1.5))
                }
                Text("Complete your identity verification to unlock all features")
                    .font(.system(size: 12)).foregroundColor(T.gray)
            }
            
            Spacer()
            
         //    ── Change button — resets form back to step 1 ──
                        Button {
                            dismissKeyboard()
                            withAnimation {
                                currentStep = .companyInfo
                                showValidationBanner = false
                                validationErrors = []
                            }
                        } label: {
                          //  HStack(spacing: 10) {
                                ///
                         //   }
                            //  .foregroundColor(T.purple)
                        
                       // }
                    }
                    .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 10)
            
               
        }
    }

    // MARK: Stepper
    private var stepperBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(KYCCompanyFormStep.allCases, id: \.self) { step in
                    HStack(spacing: 0) {
                        stepCell(step)
                        if step != KYCCompanyFormStep.allCases.last {
                            Rectangle().fill(step.rawValue < currentStep.rawValue ? T.purple : T.border).frame(width: 18, height: 1.5)
                        }
                    }
                }
            }.padding(.horizontal, 16)
        }
    }
    private func stepCell(_ step: KYCCompanyFormStep) -> some View {
        let active = step == currentStep; let completed = step.rawValue < currentStep.rawValue
        return VStack(spacing: 5) {
            ZStack {
                Circle().fill(active ? T.purple.opacity(0.18) : T.card).frame(width: 44, height: 44)
                    .overlay(Circle().stroke(active ? T.purple : (completed ? T.purple.opacity(0.45) : T.border), lineWidth: active ? 2 : 1))
                if completed { Image(systemName: "checkmark").font(.system(size: 13, weight: .bold)).foregroundColor(T.purple) }
                else         { Image(systemName: step.icon).font(.system(size: 16)).foregroundColor(active ? T.purple : T.gray) }
            }
            Text(step.title).font(.system(size: 9.5, weight: active ? .semibold : .regular))
                .foregroundColor(active ? T.purple : T.gray).multilineTextAlignment(.center).frame(width: 66)
        }.frame(width: 66)
    }

    // MARK: Save Bar
    private var saveBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [T.bg.opacity(0), T.bg], startPoint: .top, endPoint: .bottom).frame(height: 20)
            saveBarContent.padding(.horizontal, 16).padding(.bottom, 28).background(T.bg)
        }
    }
    @ViewBuilder private var saveBarContent: some View {
        let isLast = currentStep == .beneficialOwner
        let busy   = viewModel.isLoading
        let hide   = isLast && uboOwners.isEmpty
        HStack(spacing: 12) {
            if currentStep.rawValue > 0 { backBtn(busy) }
            if !hide { primaryBtn(isLast: isLast, busy: busy) }
        }
    }
    private func backBtn(_ busy: Bool) -> some View {
        Button {
            dismissKeyboard()
            withAnimation {
                showValidationBanner = false; validationErrors = []
                if let p = KYCCompanyFormStep.allCases.first(where: { $0.rawValue == currentStep.rawValue - 1 }) { currentStep = p }
            }
        } label: {
            Text("Back").font(.system(size: 16, weight: .bold)).foregroundColor(T.white)
                .frame(width: 100).padding(.vertical, 16).background(T.card).cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(T.border, lineWidth: 1))
        }.disabled(busy)
    }
    private func primaryBtn(isLast: Bool, busy: Bool) -> some View {
        Button { advanceOrSubmit(isLastStep: isLast) } label: {
            Group {
                if busy { ProgressView().progressViewStyle(.circular).tint(.white) }
                else    { Text(isLast ? "Submit" : "Save and Next").font(.system(size: 16, weight: .bold)).foregroundColor(.white) }
            }
            .frame(maxWidth: .infinity).padding(.vertical, 16)
            .background(isLast ? T.purple : T.orange).cornerRadius(12)
            .opacity(busy ? 0.7 : 1.0)
        }.disabled(busy).animation(.easeInOut(duration: 0.2), value: busy)
    }

    // ════════════════════════════════════════════════════════════════
    // MARK: - Percentage total helpers
    // (extracted from ViewBuilder closures to avoid type-check errors)
    // ════════════════════════════════════════════════════════════════

    private var processingPctTotal: Int {
        (Int(onlinePct) ?? 0) + (Int(inPersonPct) ?? 0) + (Int(phonePct) ?? 0) + (Int(keyedPct) ?? 0)
    }
    private var processingPctTotalView: some View {
        Text("Total: \(processingPctTotal)% (must equal 100%)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(processingPctTotal == 100 ? T.green : T.red)
    }

    private var ioTotal: Int { (Int(inboundPct) ?? 0) + (Int(outboundPct) ?? 0) }
    private var ioTotalView: some View {
        Text("Total: \(ioTotal)% (must equal 100%)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(ioTotal == 100 ? T.green : T.red)
    }

    private var b2bTotal: Int { (Int(b2bPct) ?? 0) + (Int(b2cPct) ?? 0) }
    private var b2bTotalView: some View {
        Text("Total: \(b2bTotal)% (must equal 100%)")
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(b2bTotal == 100 ? T.green : T.red)
    }

    // ════════════════════════════════════════════════════════════════
    // MARK: - Step 1 Sections
    // ════════════════════════════════════════════════════════════════

    private var sectionCompanyInfo: some View {
        KYCSectionCard(title: "Company Information") {
            VStack(spacing: 14) { companyTopBlock; phoneRow; companyBottomBlock }
        }
    }
    private var companyTopBlock: some View {
        VStack(spacing: 14) {
            KYCFieldLabel("Company Name", required: true) {
                KYCInputField(placeholder: "Enter Legal Company Name", text: $companyName,
                    hasError: err(companyName.trimmingCharacters(in: .whitespaces).isEmpty))
            }
            KYCFieldLabel("Company Registration Number", required: true) {
                KYCInputField(placeholder: "Enter Company Registration Number", text: $companyRegNo,
                    hasError: err(companyRegNo.trimmingCharacters(in: .whitespaces).isEmpty))
            }
            KYCFieldLabel("Company Website") {
                KYCInputField(placeholder: "example.com", text: $companyWebsite, keyboardType: .URL)
            }
            KYCFieldLabel("Country of Incorporation", required: true) {
                KYCDropdownTrigger(placeholder: "Select Country", value: $countryOfIncorp,
                    hasError: err(countryOfIncorp.isEmpty), onTap: { show("Country of Incorporation", apiCountries, $countryOfIncorp) })
            }
            KYCFieldLabel("Corporate Structure", required: true) {
                KYCDropdownTrigger(placeholder: "Select Structure", value: $corporateStructure,
                    hasError: err(corporateStructure.isEmpty), onTap: { show("Corporate Structure", opts.corpStructure, $corporateStructure) })
            }
            bizActivityRow
            KYCFieldLabel("DBA Name", required: true) {
                KYCInputField(placeholder: "Enter DBA (Doing Business As) Name", text: $dbaName,
                    hasError: err(dbaName.trimmingCharacters(in: .whitespaces).isEmpty))
            }
        }
    }

    // ── Business Activity row: yellow badge opens MCC modal ──────────────
    private var bizActivityRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 4) {
                Text("Business Activity").font(.system(size: 13, weight: .medium)).foregroundColor(T.white)
                Text("*").font(.system(size: 13)).foregroundColor(T.red)
                Spacer()
                Button { showMCCModal = true } label: {
                    Text("Recommended High-risk MCC")
                        .font(.system(size: 10, weight: .bold)).foregroundColor(.black)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(T.yellow).cornerRadius(4)
                }
                .buttonStyle(.plain)
            }
            KYCDropdownTrigger(placeholder: "Search or Enter Business Activity", value: $businessActivity,
                hasError: err(businessActivity.isEmpty),
                onTap: { showMCCModal = true })
        }
    }

    private var phoneRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text("Business Phone Number").font(.system(size: 13, weight: .medium)).foregroundColor(T.white)
                Text("*").font(.system(size: 13)).foregroundColor(T.red)
            }
            HStack(spacing: 8) {
                let sc: Color = err(phoneCode.isEmpty) ? T.red.opacity(0.7) : T.border
                Button { show("Phone Code", opts.phoneCodes, $phoneCode) } label: {
                    HStack(spacing: 4) {
                        Text(phoneCode.isEmpty ? "Code" : phoneCode).font(.system(size: 13, weight: .medium))
                            .foregroundColor(phoneCode.isEmpty ? T.gray : T.white).lineLimit(1)
                        Spacer()
                        Image(systemName: "chevron.down").font(.system(size: 10)).foregroundColor(T.gray)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 14).frame(width: 88)
                    .background(T.field).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(sc, lineWidth: 1))
                }
                KYCInputField(placeholder: "Phone number", text: $businessPhone,
                    hasError: err(businessPhone.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .phonePad)
            }
        }
    }
    private var companyBottomBlock: some View {
        VStack(spacing: 14) {
            KYCFieldLabel("Business Email Address", required: true) {
                KYCInputField(placeholder: "Enter Business Email Address", text: $businessEmail,
                    hasError: err(businessEmail.isEmpty || !isValidEmail(businessEmail)), keyboardType: .emailAddress)
            }
            KYCFieldLabel("Years in Business", required: true) {
                KYCDropdownTrigger(placeholder: "Select Years in Business", value: $yearsInBusiness,
                    hasError: err(yearsInBusiness.isEmpty), onTap: { show("Years in Business", opts.years, $yearsInBusiness) })
            }
            KYCFieldLabel("Business Description", required: true) {
                KYCMultilineField(placeholder: "Describe your business activities (max 350 characters)",
                    text: $businessDesc, hasError: err(businessDesc.trimmingCharacters(in: .whitespaces).count < 10))
            }
            KYCFieldLabel("Stock Exchange Name") { KYCInputField(placeholder: "e.g. NYSE, NASDAQ", text: $stockExchange) }
            KYCFieldLabel("Stock Ticker Symbol") { KYCInputField(placeholder: "e.g. AAPL", text: $stockTicker) }
        }
    }

    private var sectionTaxInfo: some View {
        KYCSectionCard(title: "Tax Information") {
            VStack(spacing: 14) {
                KYCFieldLabel("Tax identification number type", required: true) {
                    KYCDropdownTrigger(placeholder: "Select Tax ID Type", value: $taxIdType,
                        hasError: err(taxIdType.isEmpty), onTap: { show("Tax ID Type", opts.taxIdTypes, $taxIdType) })
                }
                KYCFieldLabel("Taxpayer Identification Number (TIN)", required: true) {
                    KYCInputField(placeholder: "Enter your EIN, SSN, or ITIN", text: $tinNumber,
                        hasError: err(tinNumber.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                KYCFieldLabel("Are you an Exempt Payee?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $exemptPayee,
                        hasError: err(exemptPayee.isEmpty), onTap: { show("Exempt Payee?", opts.yesNo, $exemptPayee) })
                }
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 2) {
                        Text("Are you a 501(c)(3) Nonprofit Organization?")
                            .font(.system(size: 13, weight: .medium)).foregroundColor(T.white).fixedSize(horizontal: false, vertical: true)
                        Text("*").font(.system(size: 13)).foregroundColor(T.red)
                    }
                    Text("Public charities and private foundations organized for religious, educational, charitable, scientific, literary, public safety, or amateur sports purposes.")
                        .font(.system(size: 12)).foregroundColor(T.gray).fixedSize(horizontal: false, vertical: true)
                    KYCDropdownTrigger(placeholder: "Select", value: $isNonprofit,
                        hasError: err(isNonprofit.isEmpty), onTap: { show("501(c)(3) Nonprofit?", opts.yesNo, $isNonprofit) })
                }
            }
        }
    }

    private var sectionRegisteredAddress: some View {
        KYCSectionCard(title: "Registered Address") {
            VStack(spacing: 14) {
                KYCFieldLabel("Address", required: true) {
                    KYCInputField(placeholder: "Enter Address", text: $regAddress, hasError: err(regAddress.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                KYCFieldLabel("City", required: true) {
                    KYCInputField(placeholder: "Enter City", text: $regCity, hasError: err(regCity.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                KYCFieldLabel("State", required: true) {
                    KYCInputField(placeholder: "Enter State", text: $regState, hasError: err(regState.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                KYCFieldLabel("Country", required: true) {
                    KYCDropdownTrigger(placeholder: "Select Country", value: $regCountry, hasError: err(regCountry.isEmpty), onTap: { show("Country", apiCountries, $regCountry) })
                }
                KYCFieldLabel("Zip Code", required: true) {
                    KYCInputField(placeholder: "Enter Zip Code", text: $regZip, hasError: err(regZip.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .numberPad)
                }
                KYCFieldLabel("Premise Type", required: true) {
                    KYCDropdownTrigger(placeholder: "Select Premise Type", value: $premiseType, hasError: err(premiseType.isEmpty), onTap: { show("Premise Type", opts.premiseTypes, $premiseType) })
                }
                KYCFieldLabel("Years in this Location", required: true) {
                    KYCDropdownTrigger(placeholder: "Select Years in Location", value: $yearsInLocation, hasError: err(yearsInLocation.isEmpty), onTap: { show("Years in Location", opts.years, $yearsInLocation) })
                }
                KYCFieldLabel("Premise Owner", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $premiseOwner, hasError: err(premiseOwner.isEmpty), onTap: { show("Premise Owner", opts.premiseOwners, $premiseOwner) })
                }
                KYCFieldLabel("Area Zoned", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $areaZoned, hasError: err(areaZoned.isEmpty), onTap: { show("Area Zoned", opts.areaZoned, $areaZoned) })
                }
                KYCFieldLabel("Square Footage", required: true) {
                    KYCInputField(placeholder: "Enter square footage", text: $squareFootage, hasError: err(squareFootage.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .numberPad)
                }
                Button { officeSameAsReg.toggle() } label: {
                    HStack(spacing: 10) { KYCCheckbox(isOn: officeSameAsReg); Text("Office address same as registered address").font(.system(size: 14)).foregroundColor(T.white); Spacer() }
                }.buttonStyle(.plain)
                KYCFieldLabel("Number of Locations", required: true) {
                    KYCInputField(placeholder: "e.g. 5", text: $numLocations, hasError: err(numLocations.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .numberPad)
                }
            }
        }
    }

    private var sectionFinancial: some View {
        KYCSectionCard(title: "Financial Information") {
            VStack(spacing: 14) {
                KYCFieldLabel("Annual Revenue", required: true) { KYCDropdownTrigger(placeholder: "Select Revenue", value: $annualRevenue, hasError: err(annualRevenue.isEmpty), onTap: { show("Annual Revenue", opts.revenue, $annualRevenue) }) }
                KYCFieldLabel("Profit", required: true) { KYCDropdownTrigger(placeholder: "Select Profit", value: $annualProfit, hasError: err(annualProfit.isEmpty), onTap: { show("Profit", opts.revenue, $annualProfit) }) }
                KYCFieldLabel("Total Company Assets", required: true) { KYCDropdownTrigger(placeholder: "Select Assets", value: $totalAssets, hasError: err(totalAssets.isEmpty), onTap: { show("Total Company Assets", opts.netWorthOpts, $totalAssets) }) }
                KYCFieldLabel("Company Net Worth", required: true) { KYCDropdownTrigger(placeholder: "Select Net Worth", value: $netWorth, hasError: err(netWorth.isEmpty), onTap: { show("Company Net Worth", opts.netWorthOpts, $netWorth) }) }
            }
        }
    }

    private var sectionBanking: some View {
        KYCSectionCard(title: "Banking and Transaction Details") {
            VStack(spacing: 14) {
                KYCFieldLabel("Account Purpose", required: true) { KYCDropdownTrigger(placeholder: "Select Purpose", value: $accountPurpose, hasError: err(accountPurpose.isEmpty), onTap: { show("Account Purpose", opts.accountPurpose, $accountPurpose) }) }
                KYCFieldLabel("Source of Investment", required: true) { KYCDropdownTrigger(placeholder: "Select Source", value: $sourceInvestment, hasError: err(sourceInvestment.isEmpty), onTap: { show("Source of Investment", opts.sourceInvestment, $sourceInvestment) }) }
                KYCFieldLabel("Monthly Transaction Volume", required: true) { KYCDropdownTrigger(placeholder: "Select Volume", value: $monthlyTxVol, hasError: err(monthlyTxVol.isEmpty), onTap: { show("Monthly Transaction Volume", opts.txVolume, $monthlyTxVol) }) }
                KYCFieldLabel("Transaction Frequency", required: true) { KYCDropdownTrigger(placeholder: "Select Frequency", value: $txFrequency, hasError: err(txFrequency.isEmpty), onTap: { show("Transaction Frequency", opts.txFrequency, $txFrequency) }) }
                KYCFieldLabel("Banking Partner", required: true) { KYCInputField(placeholder: "Enter Banking Partner", text: $bankingPartner, hasError: err(bankingPartner.trimmingCharacters(in: .whitespaces).isEmpty)) }
                KYCFieldLabel("Banking Relationship Duration", required: true) { KYCDropdownTrigger(placeholder: "Select Duration", value: $bankingDuration, hasError: err(bankingDuration.isEmpty), onTap: { show("Banking Relationship Duration", opts.duration, $bankingDuration) }) }
            }
        }
    }

    private var sectionProcessing: some View {
        KYCSectionCard(title: "Processing Information") {
            VStack(spacing: 14) {
                KYCFieldLabel("Are you currently processing credit and debit card transactions?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $processingCards, hasError: err(processingCards.isEmpty), onTap: { show("Currently Processing Cards?", opts.yesNo, $processingCards) })
                }
                // Pct block
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 2) {
                        Text("How do you want to process card transactions?").font(.system(size: 13, weight: .medium)).foregroundColor(T.white).fixedSize(horizontal: false, vertical: true)
                        Text("*").font(.system(size: 13)).foregroundColor(T.red)
                    }
                    Text("Enter the percentage for each processing method. All percentages must add up to 100%.")
                        .font(.system(size: 12)).foregroundColor(T.gray).fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 10) {
                        KYCPercentField(label: "Online %", text: $onlinePct)
                        KYCPercentField(label: "In-person swipe %", text: $inPersonPct)
                    }
                    HStack(spacing: 10) {
                        KYCPercentField(label: "Over the phone %", text: $phonePct)
                        KYCPercentField(label: "Key entered %", text: $keyedPct)
                    }
                    processingPctTotalView
                }
                // Bottom block
                KYCFieldLabel("Monthly card processing amount (USD)", required: true) {
                    KYCInputField(placeholder: "Enter amount in USD", text: $monthlyCardAmt, hasError: err(monthlyCardAmt.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .decimalPad)
                }
                KYCFieldLabel("Average transaction size (USD)", required: true) {
                    KYCInputField(placeholder: "Enter average transaction size", text: $avgTxSize, hasError: err(avgTxSize.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .decimalPad)
                }
                KYCFieldLabel("Highest transaction size (USD)", required: true) {
                    KYCInputField(placeholder: "Enter highest transaction size", text: $maxTxSize, hasError: err(maxTxSize.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .decimalPad)
                }
                KYCFieldLabel("Do you want to accept ACH/eCheck payments?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $acceptACH, hasError: err(acceptACH.isEmpty), onTap: { show("Accept ACH/eCheck?", opts.yesNo, $acceptACH) })
                }

                // ── Amex checkbox ─────────────────────────────────────────────
                Button { acceptAmex.toggle() } label: {
                    HStack(spacing: 10) {
                        KYCCheckbox(isOn: acceptAmex)
                        HStack(spacing: 2) {
                            Text("Would you like to accept American Express payments?").font(.system(size: 14)).foregroundColor(T.white)
                            Text("*").font(.system(size: 13)).foregroundColor(T.red)
                        }
                        Spacer()
                    }
                }.buttonStyle(.plain)

                // ── Amex sub-fields (animated reveal) ─────────────────────────
                if acceptAmex {
                    VStack(spacing: 14) {
                        HStack(spacing: 8) {
                            Rectangle().fill(Color(red:0.0,green:0.45,blue:0.90).opacity(0.6)).frame(height: 1)
                            Text("American Express Details")
                                .font(.system(size: 11, weight: .bold)).foregroundColor(Color(red:0.0,green:0.55,blue:1.0))
                                .fixedSize()
                            Rectangle().fill(Color(red:0.0,green:0.45,blue:0.90).opacity(0.6)).frame(height: 1)
                        }
                        KYCFieldLabel("Amex Monthly Volume (USD)", required: true) {
                            KYCInputField(
                                placeholder: "Enter monthly Amex processing volume",
                                text: $amexMonthlyVol,
                                hasError: err(amexMonthlyVol.trimmingCharacters(in: .whitespaces).isEmpty),
                                keyboardType: .decimalPad
                            )
                        }
                        KYCFieldLabel("Amex Avg Ticket (USD)", required: true) {
                            KYCInputField(
                                placeholder: "Enter average Amex ticket size",
                                text: $amexAvgTicket,
                                hasError: err(amexAvgTicket.trimmingCharacters(in: .whitespaces).isEmpty),
                                keyboardType: .decimalPad
                            )
                        }
                        KYCFieldLabel("Amex High Ticket (USD)", required: true) {
                            KYCInputField(
                                placeholder: "Enter highest Amex ticket size",
                                text: $amexHighTicket,
                                hasError: err(amexHighTicket.trimmingCharacters(in: .whitespaces).isEmpty),
                                keyboardType: .decimalPad
                            )
                        }
                    }
                    .padding(14)
                    .background(Color(red:0.0,green:0.18,blue:0.38).opacity(0.30))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(red:0.0,green:0.45,blue:0.90).opacity(0.4), lineWidth: 1))
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.22), value: acceptAmex)
        }
    }

    private var sectionProcessingURLs: some View {
        KYCSectionCard(title: "Processing URLs") {
            VStack(spacing: 14) {
                KYCFieldLabel("Website URL used for payment processing", required: true) {
                    KYCInputField(placeholder: "Enter the website URL (e.g. example.com)", text: $processingURL,
                        hasError: err(processingURL.trimmingCharacters(in: .whitespaces).isEmpty), keyboardType: .URL)
                }
                Text("If login access is required, please provide demo credentials for our admin team. Two-factor authentication (2FA) must be disabled for these credentials.")
                    .font(.system(size: 12)).foregroundColor(T.gray).fixedSize(horizontal: false, vertical: true)
                KYCFieldLabel("Username", required: true) {
                    KYCInputField(placeholder: "Enter Demo Login Username", text: $demoUser,
                        hasError: err(demoUser.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                // ── Password with eye toggle (handled inside KYCPasswordField) ──
                KYCFieldLabel("Password", required: true) {
                    KYCPasswordField(placeholder: "Enter Demo Login Password", text: $demoPass,
                        hasError: err(demoPass.trimmingCharacters(in: .whitespaces).isEmpty))
                }
            }
        }
    }

    private var sectionBusinessOps: some View {
        KYCSectionCard(title: "Business Operations") {
            VStack(spacing: 14) {
                // Ad methods
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 2) {
                        Text("Advertising Methods").font(.system(size: 13, weight: .medium)).foregroundColor(T.white)
                        Text("* (Select all that apply)").font(.system(size: 12)).foregroundColor(T.gray)
                    }
                    if err(adMethods.isEmpty) { Text("At least one advertising method must be selected").font(.system(size: 11)).foregroundColor(T.red) }
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                        ForEach(["Yellow Pages","Telemarketing","Catalog","Word of mouth","Publications","Email marketing","Internet","Others"], id: \.self) { m in
                            Button { if adMethods.contains(m) { adMethods.remove(m) } else { adMethods.insert(m) } } label: {
                                HStack(spacing: 8) { KYCCheckbox(isOn: adMethods.contains(m)); Text(m).font(.system(size: 13)).foregroundColor(T.white).lineLimit(1).minimumScaleFactor(0.8); Spacer() }.contentShape(Rectangle())
                            }.buttonStyle(.plain)
                        }
                    }
                }
                // Inbound/Outbound
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 2) { Text("Inbound and outbound sales breakdown").font(.system(size: 13, weight: .medium)).foregroundColor(T.white).fixedSize(horizontal: false, vertical: true); Text("*").font(.system(size: 13)).foregroundColor(T.red) }
                    HStack(spacing: 10) { KYCPercentField(label: "Inbound %", text: $inboundPct); KYCPercentField(label: "Outbound %", text: $outboundPct) }
                    ioTotalView
                }
                // B2B
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 2) { Text("Sales Type Distribution (B2B / Retail)").font(.system(size: 13, weight: .medium)).foregroundColor(T.white); Text("*").font(.system(size: 13)).foregroundColor(T.red) }
                    HStack(spacing: 10) { KYCPercentField(label: "B2B %", text: $b2bPct); KYCPercentField(label: "Retail (B2C) %", text: $b2cPct) }
                    b2bTotalView
                }
                KYCFieldLabel("Is your business seasonal?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $isSeasonal, hasError: err(isSeasonal.isEmpty), onTap: { show("Is your business seasonal?", opts.yesNo, $isSeasonal) })
                }
                KYCFieldLabel("Return and Refund Policy", required: true) {
                    KYCMultilineField(placeholder: "Enter your return and refund policy here (min 10, max 5000 characters). Include refund timeline.", text: $refundPolicy, hasError: err(refundPolicy.trimmingCharacters(in: .whitespaces).count < 10))
                }
                KYCFieldLabel("Customers may request refunds within how many days of purchase?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $refundReqDays, hasError: err(refundReqDays.isEmpty), onTap: { show("Refund Request Window", opts.refundDays, $refundReqDays) })
                }
                KYCFieldLabel("Refunds are processed within how many business days?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $refundProcDays, hasError: err(refundProcDays.isEmpty), onTap: { show("Refund Processing Time", opts.refundProcess, $refundProcDays) })
                }
            }
        }
    }

    private var sectionFulfillment: some View {
        KYCSectionCard(title: "Fulfillment & Billing") {
            VStack(spacing: 14) {
                KYCFieldLabel("When is the card charged?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $cardChargedWhen, hasError: err(cardChargedWhen.isEmpty), onTap: { show("When is the card charged?", opts.cardCharged, $cardChargedWhen) })
                }
                KYCFieldLabel("Do you use a third-party company to fulfill or deliver your products or services?", required: true) {
                    KYCDropdownTrigger(placeholder: "Select", value: $thirdPartyFulfill, hasError: err(thirdPartyFulfill.isEmpty), onTap: { show("Third-party Fulfillment?", opts.yesNo, $thirdPartyFulfill) })
                }
            }
        }
    }

    private var sectionRisk: some View {
        KYCSectionCard(title: "Risk & Compliance") {
            VStack(spacing: 14) {
                KYCFieldLabel("Is your business PCI compliant?", required: true) { KYCDropdownTrigger(placeholder: "Select", value: $pciCompliant, hasError: err(pciCompliant.isEmpty), onTap: { show("PCI Compliant?", opts.yesNo, $pciCompliant) }) }
                KYCFieldLabel("Business or any associated owner ever been terminated as a VISA/MasterCard/Discover/AMEX merchant?", required: true) { KYCDropdownTrigger(placeholder: "Select", value: $terminatedMerchant, hasError: err(terminatedMerchant.isEmpty), onTap: { show("Terminated as Merchant?", opts.yesNo, $terminatedMerchant) }) }
                KYCFieldLabel("Business had any ongoing or prior data compromise investigations?", required: true) { KYCDropdownTrigger(placeholder: "Select", value: $dataCompromise, hasError: err(dataCompromise.isEmpty), onTap: { show("Data Compromise Investigations?", opts.yesNo, $dataCompromise) }) }
                KYCFieldLabel("Business was previously identified with Visa Risk Programs?", required: true) { KYCDropdownTrigger(placeholder: "Select", value: $visaRisk, hasError: err(visaRisk.isEmpty), onTap: { show("Visa Risk Programs?", opts.yesNo, $visaRisk) }) }
                KYCFieldLabel("Does any third-party software or platform participate in your payment flow?", required: true) { KYCDropdownTrigger(placeholder: "Select", value: $thirdPartyPayment, hasError: err(thirdPartyPayment.isEmpty), onTap: { show("Third-party in Payment Flow?", opts.yesNo, $thirdPartyPayment) }) }
            }
        }
    }

    private var sectionBankruptcy: some View {
        KYCSectionCard(title: "Bankruptcy") {
            KYCFieldLabel("Have you ever filed for bankruptcy?", required: true) {
                KYCDropdownTrigger(placeholder: "Select", value: $filedBankruptcy, hasError: err(filedBankruptcy.isEmpty), onTap: { show("Filed for Bankruptcy?", opts.bankruptcy, $filedBankruptcy) })
            }
        }
    }

    // MARK: Step 2 — Documents
    private var sectionCompanyDocuments: some View {
        KYCSectionCard(title: "Company Documents Upload") {
            VStack(spacing: 20) {
                docPair(li: 0, lt: "Certificate of Incorporation", lr: true,  ld: nil, ri: 0, rt: "Memorandum or Operating Agreement", rr: false, rd: nil)
                docPair(li: 1, lt: "Articles of Association",      lr: false, ld: nil, ri: 1, rt: "Certificate of Incumbency",         rr: false, rd: nil)
                docPair(li: 2, lt: "Register of Directors",        lr: false, ld: nil, ri: 2, rt: "Register of Shareholders",          rr: false, rd: nil)
                docPair(li: 3, lt: "Board Resolution", lr: false,
                    ld: "Kindly download the Board Resolution or similar written authorization to open an account here. Please fill it and upload it.",
                    ri: 3, rt: "Proof of Address", rr: true,
                    rd: "Upload a recent proof of address document showing your full name, address, and issue date (issued within the last 3 months). Accepted documents include Utility bill, Bank statement or Credit card statement.")
                HStack(alignment: .top, spacing: 12) {
                    KYCDocUploadField(title: "Bank Statement", required: true,
                        description: "Upload a recent business bank statement (last 3 months) showing your business name and address.",
                        fileName: companyBankStatementName, onChoose: { docPickerIndex = 98; showDocPicker = true })
                    KYCDocUploadField(title: "Processing Statement", required: false,
                        description: "Upload your recent payment processing statement (last 3 months).",
                        fileName: processingStatementName, onChoose: { docPickerIndex = 99; showDocPicker = true })
                }
            }
        }
        .fileImporter(isPresented: $showDocPicker, allowedContentTypes: [.pdf, .image, .data], allowsMultipleSelection: false) { result in
            guard let url = try? result.get().first else { return }
            _ = url.startAccessingSecurityScopedResource()
            let name = url.lastPathComponent
            switch docPickerIndex {
            case 0:  docFiles["0-left"]  = name; docURLs["0-left"] = url
            case 1:  docFiles["0-right"] = name; docURLs["0-right"] = url
            case 10: docFiles["1-left"]  = name; docURLs["1-left"] = url
            case 11: docFiles["1-right"] = name; docURLs["1-right"] = url
            case 20: docFiles["2-left"]  = name; docURLs["2-left"] = url
            case 21: docFiles["2-right"] = name; docURLs["2-right"] = url
            case 30: docFiles["3-left"]  = name; docURLs["3-left"] = url
            case 31: docFiles["3-right"] = name; docURLs["3-right"] = url
            case 98: companyBankStatementName = name; companyBankStatementURL = url
            case 99: processingStatementName = name; processingStatementURL = url
            case 200: wolfsbergFileName = name; wolfsbergFileURL = url
            case 201: authLetterFileName = name; authLetterFileURL = url
            default: break
            }
        }
    }
    private func docPair(li: Int, lt: String, lr: Bool, ld: String?,
                         ri: Int, rt: String, rr: Bool, rd: String?) -> some View {
        HStack(alignment: .top, spacing: 12) {
            KYCDocUploadField(title: lt, required: lr, description: ld, fileName: docFiles["\(li)-left"] ?? "", onChoose: { docPickerIndex = li*10+0; showDocPicker = true })
            KYCDocUploadField(title: rt, required: rr, description: rd, fileName: docFiles["\(ri)-right"] ?? "", onChoose: { docPickerIndex = ri*10+1; showDocPicker = true })
        }
    }

    // MARK: Step 3 — Auth Letter
    private var sectionAuthLetter: some View {
        KYCSectionCard(title: "Authorization Letter Upload") {
            VStack(spacing: 16) {
                KYCAuthUploadCard(title: "Wolfsberg Questionnaire", isOptional: true,
                    bodyText: "Kindly download the Wolfsberg Questionnaire template here. Please fill it and upload it. This is mandatory for all financial companies.",
                    downloadURL: "https://www.wolfsberg-principles.com", fileName: $wolfsbergFileName, fileURL: $wolfsbergFileURL)
                KYCAuthUploadCard(title: "Authorization Letter", isOptional: true,
                    bodyText: "If there are persons authorized to access and operate the account, upload an Authorization Letter indicating their capacity. Kindly download the template here. Please fill it out and sign it. Upload the signed copy.",
                    downloadURL: "https://example.com/auth-letter-template", fileName: $authLetterFileName, fileURL: $authLetterFileURL)
            }
        }
    }

    // MARK: Step 4 — UBO
    private var sectionBeneficialOwner: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Beneficial Owners / UBO Information").font(.system(size: 17, weight: .bold)).foregroundColor(T.white)
                Spacer()
                Button { showAddOwnerSheet = true } label: {
                    HStack(spacing: 6) { Image(systemName: "plus").font(.system(size: 13, weight: .bold)); Text("Add Owner").font(.system(size: 14, weight: .semibold)) }
                    .foregroundColor(.white).padding(.horizontal, 16).padding(.vertical, 10).background(T.blue).cornerRadius(8)
                }
            }.padding(.bottom, 12)
            let c: Color = totalOwnership > 100 ? T.red : T.green
            HStack(spacing: 6) {
                Text("Total Ownership:").font(.system(size: 14, weight: .bold)).foregroundColor(T.white)
                Text("\(totalOwnership)%").font(.system(size: 14, weight: .bold)).foregroundColor(c)
            }.padding(.bottom, 4)
            if showValidationBanner {
                if uboOwners.isEmpty { Text("At least one beneficial owner is required").font(.system(size: 11)).foregroundColor(T.red).padding(.bottom, 8) }
                else if totalOwnership != 100 { Text("Total ownership must equal 100%").font(.system(size: 11)).foregroundColor(T.red).padding(.bottom, 8) }
            }
            if uboOwners.isEmpty {
                let bc: Color = showValidationBanner && uboOwners.isEmpty ? T.red.opacity(0.5) : T.border
                VStack(spacing: 14) {
                    Image(systemName: "person.3.fill").font(.system(size: 40)).foregroundColor(showValidationBanner ? T.red.opacity(0.5) : Color(white: 0.35))
                    Text("No Beneficial Owners Added").font(.system(size: 15, weight: .semibold)).foregroundColor(Color(white: 0.45))
                    Text("Click \"Add Owner\" to add beneficial owners or authorized signatories").font(.system(size: 13)).foregroundColor(Color(white: 0.38)).multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(bc, lineWidth: 1))
            } else {
                VStack(spacing: 10) {
                    ForEach(uboOwners) { owner in
                        UBOOwnerRow(owner: owner) { editingOwner = owner; showAddOwnerSheet = true } onDelete: {
                            if !owner.ownerUuid.isEmpty && !owner.enterpriseId.isEmpty {
                                DeleteEnterpriseOwnerService.shared.deleteOwner(userUuid: SessionManager.shared.uuid, ownerUuid: owner.ownerUuid, enterpriseId: owner.enterpriseId) { _ in }
                            }
                            uboOwners.removeAll { $0.id == owner.id }
                        }
                    }
                }
            }
        }
        .padding(16).frame(maxWidth: .infinity, alignment: .leading)
        .background(T.card).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(T.border.opacity(0.6), lineWidth: 1))
        .sheet(isPresented: $showAddOwnerSheet, onDismiss: { editingOwner = nil }) {
            AddOwnerView(editing: editingOwner, merchantId: SessionManager.shared.adminUserId, userUuid: SessionManager.shared.uuid) { saved in
                if let idx = uboOwners.firstIndex(where: { $0.id == saved.id }) { uboOwners[idx] = saved }
                else { uboOwners.append(saved) }
            }
        }
    }
}

// MARK: - Preview
#Preview { EnterpriseKycFormView() }
