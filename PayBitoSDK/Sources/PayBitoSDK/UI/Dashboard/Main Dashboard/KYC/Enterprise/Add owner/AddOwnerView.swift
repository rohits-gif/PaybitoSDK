

// MARK: - AddOwnerView.swift

import SwiftUI
import UniformTypeIdentifiers

// ════════════════════════════════════════════════════════════════════
// MARK: - Theme
// ════════════════════════════════════════════════════════════════════

enum UBOT {
    static let bg     = Color(red: 0.07, green: 0.08, blue: 0.14)
    static let card   = Color(red: 0.10, green: 0.12, blue: 0.19)
    static let field  = Color(red: 0.12, green: 0.14, blue: 0.22)
    static let blue   = Color(red: 0.22, green: 0.38, blue: 0.85)
    static let red    = Color(red: 0.92, green: 0.22, blue: 0.20)
    static let bdr    = Color(white: 0.22)
    static let gray   = Color(white: 0.55)
    static let gray2  = Color(white: 0.40)
    static let yellow = Color(red: 1.00, green: 0.78, blue: 0.20)
    static let white  = Color.white
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Active File Picker Enum
// ════════════════════════════════════════════════════════════════════

/// A single enum tracks which file slot is currently being picked.
/// This avoids the SwiftUI bug where multiple .fileImporter modifiers
/// conflict with each other — only ONE fileImporter is ever active.
enum UBOFilePicker: Identifiable {
    case govFront, govBack, poa, selfie, investment

    var id: String {
        switch self {
        case .govFront:   return "govFront"
        case .govBack:    return "govBack"
        case .poa:        return "poa"
        case .selfie:     return "selfie"
        case .investment: return "investment"
        }
    }

    /// Map each case to the ViewModel key paths it writes into
    var urlKeyPath: ReferenceWritableKeyPath<AddOwnerViewModel, URL?> {
        switch self {
        case .govFront:   return \.idFrontURL
        case .govBack:    return \.idBackURL
        case .poa:        return \.poaURL
        case .selfie:     return \.selfieURL
        case .investment: return \.investURL
        }
    }

    var nameKeyPath: WritableKeyPath<UBOOwner, String> {
        switch self {
        case .govFront:   return \.govIdFront
        case .govBack:    return \.govIdBack
        case .poa:        return \.proofOfAddress
        case .selfie:     return \.selfieFile
        case .investment: return \.investmentFile
        }
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Corner Radius Helper
// ════════════════════════════════════════════════════════════════════

struct UBORoundedCorner: Shape {
    var radius: CGFloat; var corners: UIRectCorner
    func path(in rect: CGRect) -> Path {
        Path(UIBezierPath(roundedRect: rect, byRoundingCorners: corners,
                          cornerRadii: CGSize(width: radius, height: radius)).cgPath)
    }
}
extension View {
    func uboCornerRadius(_ r: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(UBORoundedCorner(radius: r, corners: corners))
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Picker Sheet (string list)
// ════════════════════════════════════════════════════════════════════

struct UBOPickerSheet: View {
    let title: String; let options: [String]
    @Binding var selected: String
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            ZStack {
                UBOT.bg.ignoresSafeArea()
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(options, id: \.self) { opt in
                            Button { selected = opt; dismiss() } label: {
                                HStack(spacing: 12) {
                                    Text(opt).font(.system(size: 15))
                                        .foregroundColor(selected == opt ? UBOT.blue : UBOT.white)
                                    Spacer()
                                    if selected == opt {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18)).foregroundColor(UBOT.blue)
                                    }
                                }
                                .padding(.horizontal, 20).padding(.vertical, 16)
                                .background(selected == opt ? UBOT.blue.opacity(0.09) : Color.clear)
                                .contentShape(Rectangle())
                            }.buttonStyle(.plain)
                            Rectangle().fill(UBOT.bdr.opacity(0.5)).frame(height: 1).padding(.horizontal, 20)
                        }
                    }.padding(.top, 6).padding(.bottom, 20)
                }
            }
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(UBOT.blue)
                }
            }
        }.preferredColorScheme(.dark)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Date Picker Sheet
// ════════════════════════════════════════════════════════════════════

struct UBODatePickerSheet: View {
    let title: String
    @Binding var selectedDate: Date
    @Binding var displayString: String
    @Environment(\.dismiss) private var dismiss

    private static let formatter: DateFormatter = {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f
    }()

    var body: some View {
        NavigationView {
            ZStack {
                UBOT.bg.ignoresSafeArea()
                VStack(spacing: 24) {
                    DatePicker("", selection: $selectedDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .accentColor(UBOT.blue)
                        .colorScheme(.dark)
                        .padding(.horizontal, 16)

                    Button {
                        displayString = Self.formatter.string(from: selectedDate)
                        dismiss()
                    } label: {
                        Text("Confirm")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(UBOT.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(UBOT.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 16)
                    Spacer()
                }
                .padding(.top, 12)
            }
            .navigationTitle(title).navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }.foregroundColor(UBOT.blue)
                }
            }
        }.preferredColorScheme(.dark)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Validation Banner
// ════════════════════════════════════════════════════════════════════

struct UBOValidationBanner: View {
    let errors: [String]
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(UBOT.yellow).font(.system(size: 14))
                Text("Please fix the following errors:")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(UBOT.white)
            }
            ForEach(errors, id: \.self) { e in
                HStack(alignment: .top, spacing: 6) {
                    Text("•").foregroundColor(UBOT.red).font(.system(size: 12))
                    Text(e).font(.system(size: 12)).foregroundColor(UBOT.red)
                }
            }
        }
        .padding(14).frame(maxWidth: .infinity, alignment: .leading)
        .background(UBOT.red.opacity(0.10)).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(UBOT.red.opacity(0.4), lineWidth: 1))
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - AddOwnerView
// ════════════════════════════════════════════════════════════════════

struct AddOwnerView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var vm: AddOwnerViewModel
    private let onSave: (UBOOwner) -> Void

    // ── Picker / Sheet visibility ────────────────────────────────
    @State private var showOwnerTypePicker   = false
    @State private var showPEPPicker         = false
    @State private var showIdTypePicker      = false
    @State private var showIdCountryPicker   = false
    @State private var showPoaTypePicker     = false
    @State private var showAddrCountryPicker = false
    @State private var showPhoneCodePicker   = false

    // ── DOB calendar ─────────────────────────────────────────────
    @State private var showDOBPicker   = false
    @State private var selectedDOBDate = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date()

    // ── Single file picker slot (nil = closed) ───────────────────
    /// Only ONE .fileImporter is attached to the view; which slot it
    /// writes into is determined by this state variable.
    @State private var activeFilePicker: UBOFilePicker? = nil

    // ── Trigger helper: sets the slot then flips the bool ────────
    @State private var filePickerIsPresented = false

    private func openFilePicker(_ slot: UBOFilePicker) {
        activeFilePicker = slot
        // Small async delay ensures state is set before fileImporter reads it
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            filePickerIsPresented = true
        }
    }

    // MARK: Init
    init(editing: UBOOwner? = nil,
         merchantId: String = "",
         userUuid: String = "",
         onSave: @escaping (UBOOwner) -> Void) {
        self.onSave = onSave
        _vm = StateObject(wrappedValue: AddOwnerViewModel(editing: editing,
                                                          merchantId: merchantId,
                                                          userUuid: userUuid))
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .top) {
            UBOT.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                headerBar
                Divider().background(UBOT.bdr)
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        if vm.showValidation && !vm.validationErrors.isEmpty {
                            UBOValidationBanner(errors: vm.validationErrors).padding(.top, 4)
                        }
                        sectionOwnerClassification
                        PersonalInfoSection(
                            vm: vm,
                            showPhoneCodePicker: $showPhoneCodePicker,
                            showDOBPicker: $showDOBPicker
                        )
                        sectionResidentialAddress
                        sectionCompliance
                        sectionIdentityDocs
                    }
                    .padding(.horizontal, 16).padding(.top, 22).padding(.bottom, 110)
                }
            }
            VStack { Spacer(); bottomActionBar }
        }
        .preferredColorScheme(.dark)

        // ── Alerts ───────────────────────────────────────────────
        .alert("Owner Saved", isPresented: $vm.showAPISuccess) {
            Button("OK") { onSave(vm.owner); dismiss() }
        } message: { Text("The beneficial owner was saved successfully.") }
        .alert("Submission Failed", isPresented: $vm.showAPIError) {
            Button("Retry")  { submit() }
            Button("Cancel", role: .cancel) { }
        } message: { Text(vm.apiErrorMsg) }
        .alert("Invalid File", isPresented: $vm.showFileError) {
            Button("OK", role: .cancel) { }
        } message: { Text(vm.fileErrorMsg) }

        // ── SINGLE file importer ─────────────────────────────────
        // Using ONE .fileImporter driven by `filePickerIsPresented` and
        // `activeFilePicker` eliminates SwiftUI's multi-importer conflicts.
        .fileImporter(
            isPresented: $filePickerIsPresented,
            allowedContentTypes: UBOFileValidation.allowedContentTypes,
            allowsMultipleSelection: false
        ) { result in
            guard let slot = activeFilePicker else { return }
            vm.handleFileImport(result, urlBinding: slot.urlKeyPath, nameBinding: slot.nameKeyPath)
            activeFilePicker = nil
        }

        // ── Picker sheets ─────────────────────────────────────────
        .sheet(isPresented: $showOwnerTypePicker) {
            UBOPickerSheet(title: "Owner Type", options: vm.ownerTypes, selected: $vm.owner.ownerType)
        }
        .sheet(isPresented: $showPEPPicker) {
            UBOPickerSheet(title: "Politically Exposed Person?", options: vm.pepOptions, selected: $vm.owner.isPEP)
        }
        .sheet(isPresented: $showIdTypePicker) {
            UBOPickerSheet(title: "Identity Document Type", options: vm.idDocTypes, selected: $vm.owner.idDocType)
        }
        .sheet(isPresented: $showIdCountryPicker) {
            UBOPickerSheet(title: "Country (ID)", options: vm.countries, selected: $vm.owner.idCountry)
        }
        .sheet(isPresented: $showPoaTypePicker) {
            UBOPickerSheet(title: "Proof of Address Type", options: vm.poaTypes, selected: $vm.owner.poaType)
        }
        .sheet(isPresented: $showAddrCountryPicker) {
            UBOPickerSheet(title: "Country", options: vm.countries, selected: $vm.owner.country)
        }
        .sheet(isPresented: $showPhoneCodePicker) {
            UBOPickerSheet(title: "Phone Code", options: vm.phoneCodes, selected: $vm.owner.phoneCode)
        }
        .sheet(isPresented: $showDOBPicker) {
            UBODatePickerSheet(
                title: "Date of Birth",
                selectedDate: $selectedDOBDate,
                displayString: $vm.owner.dob
            )
        }
    }

    private func submit() {
        vm.submitOwner(onSave: onSave, onLocalSaveComplete: { dismiss() })
    }

    // MARK: - Header
    private var headerBar: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(UBOT.blue.opacity(0.15)).frame(width: 36, height: 36)
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 16, weight: .semibold)).foregroundColor(UBOT.blue)
            }
            Text(vm.editing == nil ? "Add Beneficial Owner" : "Edit Beneficial Owner")
                .font(.system(size: 18, weight: .bold)).foregroundColor(UBOT.white)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold)).foregroundColor(UBOT.white)
                    .frame(width: 28, height: 28).background(Color(white: 0.24)).cornerRadius(6)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
    }

    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [UBOT.bg.opacity(0), UBOT.bg],
                           startPoint: .top, endPoint: .bottom).frame(height: 20)
            HStack(spacing: 12) {
                Button { dismiss() } label: {
                    Text("Cancel").font(.system(size: 15, weight: .semibold))
                        .foregroundColor(UBOT.white).frame(maxWidth: .infinity)
                        .padding(.vertical, 15).background(UBOT.card).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(UBOT.bdr, lineWidth: 1))
                }
                Button { submit() } label: {
                    HStack(spacing: 6) {
                        if vm.isSubmitting {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.85)
                        } else {
                            Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                        }
                        Text(vm.isSubmitting ? "Saving…" : (vm.editing == nil ? "Add Owner" : "Save Changes"))
                            .font(.system(size: 15, weight: .bold))
                    }
                    .foregroundColor(UBOT.white).frame(maxWidth: .infinity)
                    .padding(.vertical, 15).background(UBOT.blue).cornerRadius(10)
                    .opacity(vm.isSubmitting ? 0.7 : 1.0)
                }
                .disabled(vm.isSubmitting)
            }
            .padding(.horizontal, 16).padding(.bottom, 34).background(UBOT.bg)
        }
    }

    // MARK: - Section: Owner Classification
    private var sectionOwnerClassification: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("OWNER CLASSIFICATION")
            HStack(spacing: 12) {
                fieldBlock("Owner Type", required: true) {
                    dropdownTrigger(placeholder: "Select Owner Type", value: vm.owner.ownerType) {
                        showOwnerTypePicker = true
                    }
                }
                fieldBlock("Ownership Percentage", required: true) {
                    inputField("e.g. 25", $vm.owner.ownershipPct, kb: .decimalPad,
                               hasError: vm.err(vm.owner.ownershipPct.trimmingCharacters(in: .whitespaces).isEmpty))
                }
            }
        }
    }

    // MARK: - Section: Residential Address
    private var sectionResidentialAddress: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("RESIDENTIAL ADDRESS")
            fieldBlock("Street Address", required: true) {
                inputField("123 Main Street, Apt 4B", $vm.owner.street,
                           hasError: vm.err(vm.owner.street.trimmingCharacters(in: .whitespaces).isEmpty))
            }
            HStack(spacing: 10) {
                fieldBlock("City", required: true) {
                    inputField("City", $vm.owner.city,
                               hasError: vm.err(vm.owner.city.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                fieldBlock("State", required: true) {
                    inputField("State", $vm.owner.addrState,
                               hasError: vm.err(vm.owner.addrState.trimmingCharacters(in: .whitespaces).isEmpty))
                }
                fieldBlock("Country", required: true) {
                    dropdownTrigger(placeholder: "Select Country", value: vm.owner.country,
                                    hasError: vm.err(vm.owner.country.isEmpty)) {
                        showAddrCountryPicker = true
                    }
                }
                fieldBlock("Zip Code", required: true) {
                    inputField("Zip Code", $vm.owner.zip, kb: .numberPad,
                               hasError: vm.err(vm.owner.zip.trimmingCharacters(in: .whitespaces).isEmpty))
                }
            }
        }
    }

    // MARK: - Section: Compliance
    private var sectionCompliance: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("COMPLIANCE")
            fieldBlock("Politically Exposed Person (PEP)?", required: true) {
                dropdownTrigger(placeholder: "Select", value: vm.owner.isPEP,
                                hasError: vm.err(vm.owner.isPEP.isEmpty)) { showPEPPicker = true }
                    .frame(maxWidth: 280)
            }
        }
    }

    // MARK: - Section: Identity Documents
    private var sectionIdentityDocs: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("IDENTITY DOCUMENTS")

            HStack(spacing: 12) {
                fieldBlock("Identity document type", required: true) {
                    dropdownTrigger(placeholder: "Select ID Type", value: vm.owner.idDocType,
                                    hasError: vm.err(vm.owner.idDocType.isEmpty)) { showIdTypePicker = true }
                }
                fieldBlock("Country", required: true) {
                    dropdownTrigger(placeholder: "Select Country", value: vm.owner.idCountry,
                                    hasError: vm.err(vm.owner.idCountry.isEmpty)) { showIdCountryPicker = true }
                }
            }
            if vm.owner.idDocType == "Driver's license" {
                fieldBlock("State", required: true) {
                    inputField("e.g. NY", $vm.owner.idState)
                }
            }

            HStack(alignment: .top, spacing: 12) {
                uploadBlock(title: "Government ID - Front", required: true,
                            fileName: vm.owner.govIdFront,
                            hasError: vm.err(vm.owner.govIdFront.isEmpty)) {
                    openFilePicker(.govFront)
                }
                uploadBlock(title: "Government ID - Back", required: true,
                            fileName: vm.owner.govIdBack,
                            hasError: vm.err(vm.owner.govIdBack.isEmpty)) {
                    openFilePicker(.govBack)
                }
            }

            fieldBlock("Proof of Address document type", required: true) {
                dropdownTrigger(placeholder: "Select POA Type", value: vm.owner.poaType,
                                hasError: vm.err(vm.owner.poaType.isEmpty)) { showPoaTypePicker = true }
            }

            uploadBlock(
                title: "Proof of Address", required: true,
                description: "Upload a recent proof of address document showing your full name, address, and issue date (last 3 months). Accepted: Utility bill, Bank statement or Credit card statement.",
                fileName: vm.owner.proofOfAddress,
                hasError: vm.err(vm.owner.proofOfAddress.isEmpty)
            ) { openFilePicker(.poa) }

            HStack(alignment: .top, spacing: 12) {
                uploadBlock(title: "Selfie holding ID", required: true,
                            fileName: vm.owner.selfieFile,
                            hasError: vm.err(vm.owner.selfieFile.isEmpty)) {
                    openFilePicker(.selfie)
                }
                // Investment — optional, reuses same uploadBlock style
                uploadBlock(
                    title: "Proof of Investment Fund",
                    required: false,
                    optionalBadge: true,
                    fileName: vm.owner.investmentFile,
                    hasError: false
                ) { openFilePicker(.investment) }
            }

            Text("Max 6MB per file. Accepted: JPG, PNG, PDF, DOC, DOCX, JFIF, HEIC")
                .font(.system(size: 10)).foregroundColor(UBOT.gray2).padding(.top, 2)
        }
    }

    // MARK: - Shared Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 11, weight: .bold)).foregroundColor(UBOT.blue)
            .kerning(0.8).padding(.bottom, 2)
    }

    @ViewBuilder
    private func fieldBlock(_ label: String, required: Bool = false,
                            @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(UBOT.white)
                    .fixedSize(horizontal: false, vertical: true)
                if required { Text("*").font(.system(size: 13)).foregroundColor(UBOT.red) }
            }
            content()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputField(_ placeholder: String, _ binding: Binding<String>,
                            kb: UIKeyboardType = .default,
                            cap: TextInputAutocapitalization = .words,
                            hasError: Bool = false) -> some View {
        TextField(placeholder, text: binding)
            .font(.system(size: 14)).foregroundColor(UBOT.white)
            .keyboardType(kb).autocorrectionDisabled().textInputAutocapitalization(cap).tint(UBOT.blue)
            .padding(.horizontal, 12).padding(.vertical, 13).background(UBOT.field).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? UBOT.red.opacity(0.7) : UBOT.bdr, lineWidth: 1))
    }

    private func dropdownTrigger(placeholder: String, value: String,
                                 hasError: Bool = false,
                                 onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            HStack {
                Text(value.isEmpty ? placeholder : value).font(.system(size: 14))
                    .foregroundColor(value.isEmpty ? UBOT.gray : UBOT.white)
                    .lineLimit(1).truncationMode(.tail)
                Spacer()
                Image(systemName: "chevron.down").font(.system(size: 11, weight: .medium)).foregroundColor(UBOT.gray)
            }
            .padding(.horizontal, 12).padding(.vertical, 13).background(UBOT.field).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? UBOT.red.opacity(0.7) : UBOT.bdr, lineWidth: 1))
        }
    }

    /// Unified upload block — handles both required and optional slots.
    /// Pass `optionalBadge: true` instead of `required: true` for optional fields.
    @ViewBuilder
    private func uploadBlock(title: String,
                             required: Bool = false,
                             optionalBadge: Bool = false,
                             description: String? = nil,
                             fileName: String,
                             hasError: Bool = false,
                             onChoose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Title row
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(UBOT.white)
                    .fixedSize(horizontal: false, vertical: true)
                if required {
                    Text("*").font(.system(size: 13, weight: .semibold)).foregroundColor(UBOT.red)
                }
                if optionalBadge {
                    Text("Optional")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(UBOT.blue)
                }
            }
            // Optional description
            if let desc = description {
                Text(desc).font(.system(size: 12)).foregroundColor(UBOT.gray)
                    .fixedSize(horizontal: false, vertical: true).lineSpacing(3)
            }
            // File picker row — Button + filename label side by side
            HStack(spacing: 0) {
                Button {
                    onChoose()
                } label: {
                    Text("Choose file")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(UBOT.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 11)
                        .background(UBOT.blue)
                        .uboCornerRadius(8, corners: [.topLeft, .bottomLeft])
                }
                .buttonStyle(.plain)          // prevents parent scroll from stealing taps

                Text(fileName.isEmpty ? "No file chosen" : fileName)
                    .font(.system(size: 13))
                    .foregroundColor(fileName.isEmpty ? UBOT.gray : UBOT.blue)
                    .lineLimit(1).truncationMode(.middle)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 10).padding(.vertical, 11)
                    .background(Color(red: 0.16, green: 0.19, blue: 0.26))
                    .uboCornerRadius(8, corners: [.topRight, .bottomRight])
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasError ? UBOT.red.opacity(0.7) : UBOT.bdr, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// ════════════════════════════════════════════════════════════════════
// MARK: - Personal Info Section
// ════════════════════════════════════════════════════════════════════

private struct PersonalInfoSection: View {
    @ObservedObject var vm: AddOwnerViewModel
    @Binding var showPhoneCodePicker: Bool
    @Binding var showDOBPicker: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("PERSONAL INFORMATION")
            nameRow
            emailField
            phoneField
            dobRow
        }
    }

    private var nameRow: some View {
        HStack(spacing: 10) {
            fieldBlock("First Name", required: true) {
                inputField("First name", $vm.owner.firstName,
                           hasError: vm.err(vm.owner.firstName.trimmingCharacters(in: .whitespaces).isEmpty))
            }
            fieldBlock("Middle Name") { inputField("Middle name", $vm.owner.middleName) }
            fieldBlock("Last Name", required: true) {
                inputField("Last name", $vm.owner.lastName,
                           hasError: vm.err(vm.owner.lastName.trimmingCharacters(in: .whitespaces).isEmpty))
            }
        }
    }

    private var emailField: some View {
        fieldBlock("Email Address", required: true) {
            inputField("owner@company.com", $vm.owner.email, kb: .emailAddress, cap: .never,
                       hasError: vm.err(vm.owner.email.isEmpty || !vm.isValidEmail(vm.owner.email)))
        }
    }

    private var phoneField: some View {
        fieldBlock("Phone Number", required: true) {
            HStack(spacing: 0) {
                Button { showPhoneCodePicker = true } label: {
                    HStack(spacing: 5) {
                        Text(vm.owner.phoneCode).font(.system(size: 13, weight: .medium))
                            .foregroundColor(UBOT.white).lineLimit(1)
                        Image(systemName: "chevron.down").font(.system(size: 10)).foregroundColor(UBOT.gray)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 13).background(UBOT.field)
                    .uboCornerRadius(10, corners: [.topLeft, .bottomLeft])
                    .overlay(HStack { Spacer(); Rectangle().fill(UBOT.bdr).frame(width: 1) })
                }
                TextField("+1 555 000 0000", text: $vm.owner.phone)
                    .font(.system(size: 14)).foregroundColor(UBOT.white)
                    .keyboardType(.phonePad).tint(UBOT.blue)
                    .padding(.horizontal, 12).padding(.vertical, 13).background(UBOT.field)
                    .uboCornerRadius(10, corners: [.topRight, .bottomRight])
            }
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(vm.err(vm.owner.phone.trimmingCharacters(in: .whitespaces).isEmpty)
                        ? UBOT.red.opacity(0.7) : UBOT.bdr, lineWidth: 1))
        }
    }

    private var dobRow: some View {
        HStack(spacing: 10) {
            fieldBlock("Date of Birth", required: true) {
                Button { showDOBPicker = true } label: {
                    HStack {
                        Text(vm.owner.dob.isEmpty ? "yyyy-MM-dd" : vm.owner.dob)
                            .font(.system(size: 14))
                            .foregroundColor(vm.owner.dob.isEmpty ? UBOT.gray : UBOT.white)
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(UBOT.blue)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 13)
                    .background(UBOT.field).cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(vm.err(vm.owner.dob.trimmingCharacters(in: .whitespaces).isEmpty)
                                ? UBOT.red.opacity(0.7) : UBOT.bdr, lineWidth: 1))
                }
            }
            fieldBlock("Place of Birth", required: true) {
                inputField("City, Country", $vm.owner.placeOfBirth,
                           hasError: vm.err(vm.owner.placeOfBirth.trimmingCharacters(in: .whitespaces).isEmpty))
            }
            fieldBlock("SSN / Passport No.", required: true) {
                inputField("SSN or Passport number", $vm.owner.ssnPassport,
                           hasError: vm.err(vm.owner.ssnPassport.trimmingCharacters(in: .whitespaces).isEmpty))
            }
        }
    }

    // ── Local helpers ────────────────────────────────────────────
    private func sectionLabel(_ text: String) -> some View {
        Text(text).font(.system(size: 11, weight: .bold)).foregroundColor(UBOT.blue)
            .kerning(0.8).padding(.bottom, 2)
    }

    @ViewBuilder
    private func fieldBlock(_ label: String, required: Bool = false,
                            @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(label).font(.system(size: 13, weight: .medium)).foregroundColor(UBOT.white)
                    .fixedSize(horizontal: false, vertical: true)
                if required { Text("*").font(.system(size: 13)).foregroundColor(UBOT.red) }
            }
            content()
        }.frame(maxWidth: .infinity, alignment: .leading)
    }

    private func inputField(_ placeholder: String, _ binding: Binding<String>,
                            kb: UIKeyboardType = .default,
                            cap: TextInputAutocapitalization = .words,
                            hasError: Bool = false) -> some View {
        TextField(placeholder, text: binding)
            .font(.system(size: 14)).foregroundColor(UBOT.white)
            .keyboardType(kb).autocorrectionDisabled().textInputAutocapitalization(cap).tint(UBOT.blue)
            .padding(.horizontal, 12).padding(.vertical, 13).background(UBOT.field).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10)
                .stroke(hasError ? UBOT.red.opacity(0.7) : UBOT.bdr, lineWidth: 1))
    }
}

// MARK: - Preview
#Preview {
    Color(red: 0.07, green: 0.08, blue: 0.14).ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            AddOwnerView { saved in print("Saved: \(saved.fullName)") }
        }
}
