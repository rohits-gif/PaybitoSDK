import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Theme
private extension Color {
    static let kycFBg          = Color(red: 0.08, green: 0.09, blue: 0.13)
    static let kycFCard        = Color(red: 0.11, green: 0.13, blue: 0.18)
    static let kycFBorder      = Color(red: 0.20, green: 0.23, blue: 0.30)
    static let kycFAccent      = Color(red: 0.47, green: 0.38, blue: 0.85)
    static let kycFOrange      = Color(red: 0.98, green: 0.60, blue: 0.10)
    static let kycFBlueBtn     = Color(red: 0.22, green: 0.52, blue: 0.95)
    static let kycFLabel       = Color(red: 0.70, green: 0.72, blue: 0.78)
    static let kycFPlaceholder = Color(red: 0.40, green: 0.43, blue: 0.52)
    static let kycFFieldBg     = Color(red: 0.13, green: 0.15, blue: 0.21)
}

// MARK: - Step Definition
private struct KYCFormStep: Identifiable {
    let id = UUID()
    let icon: String
    let label: String
}

private let kycAllSteps: [KYCFormStep] = [
    KYCFormStep(icon: "building.columns.fill", label: "Address"),
    KYCFormStep(icon: "calendar",              label: "DOB & SSN"),
    KYCFormStep(icon: "person.fill",           label: "Employment"),
    KYCFormStep(icon: "doc.fill",              label: "Addr Proof"),
    KYCFormStep(icon: "doc.text.fill",         label: "ID Proof"),
    KYCFormStep(icon: "camera.fill",           label: "Take Photo"),
]

// MARK: - Step Tab Bar
private struct KYCFormStepBar: View {
    let activeIndex: Int

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 0) {
                    ForEach(Array(kycAllSteps.enumerated()), id: \.element.id) { index, step in
                        HStack(spacing: 0) {
                            VStack(spacing: 8) {
                                ZStack {
                                    // Completed step — filled accent circle with checkmark
                                    if index < activeIndex {
                                        Circle()
                                            .fill(Color.kycFAccent)
                                            .frame(width: 52, height: 52)
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    } else {
                                        // Active or upcoming
                                        Circle()
                                            .strokeBorder(
                                                index == activeIndex ? Color.kycFAccent : Color.kycFBorder,
                                                lineWidth: index == activeIndex ? 2 : 1
                                            )
                                            .background(
                                                Circle().fill(
                                                    index == activeIndex
                                                        ? Color.kycFAccent.opacity(0.15)
                                                        : Color.kycFCard
                                                )
                                            )
                                            .frame(width: 52, height: 52)
                                        Image(systemName: step.icon)
                                            .font(.system(size: 20))
                                            .foregroundColor(
                                                index == activeIndex ? Color.kycFAccent : Color.kycFLabel
                                            )
                                    }
                                }
                                .id(index)

                                Text(step.label)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(
                                        index <= activeIndex ? Color.kycFAccent : Color.kycFLabel
                                    )
                            }
                            .frame(width: 72)

                            // Connector line between steps (except after last)
                            if index < kycAllSteps.count - 1 {
                                Rectangle()
                                    .fill(index < activeIndex ? Color.kycFAccent : Color.kycFBorder)
                                    .frame(width: 28, height: 2)
                                    .padding(.bottom, 30)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: activeIndex) { newIndex in
                withAnimation { proxy.scrollTo(newIndex, anchor: .center) }
            }
        }
    }
}

// MARK: - Header
private struct KYCFormHeader: View {
    let activeStep: Int
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 12) {
                        Text("KYC Verification")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)

                        Text("Individual")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .overlay(Capsule().stroke(Color.white, lineWidth: 1.5))
                    }
                    Text("Complete your identity verification to unlock all features")
                        .font(.system(size: 13))
                        .foregroundColor(.kycFLabel)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

//                Button(action: {}) {
//                    HStack(spacing: 4) {
//                        Image(systemName: "arrow.clockwise")
//                            .font(.system(size: 12, weight: .semibold))
//                        Text("Change")
//                            .font(.system(size: 14, weight: .semibold))
//                    }
//                    .foregroundColor(.kycFAccent)
//                }
//                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 4)

            KYCFormStepBar(activeIndex: activeStep)
            Divider().background(Color.kycFBorder)
        }
        .background(Color.kycFBg)
    }
}

// MARK: - Field Label
private struct KYCFormFieldLabel: View {
    let text: String
    var body: some View {
        HStack(spacing: 2) {
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.kycFLabel)
            Text("*")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.kycFAccent)
        }
    }
}

// MARK: - Text Field
private struct KYCFormTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.kycFPlaceholder)
                    .font(.system(size: 15))
                    .padding(.leading, 14)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .keyboardType(keyboardType)
                .font(.system(size: 15))
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 16)
        }
        .background(Color.kycFFieldBg)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kycFBorder, lineWidth: 1))
    }
}

// MARK: - Dropdown Field
private struct KYCFormDropdown: View {
    let placeholder: String
    let options: [String]
    @Binding var selected: String
    @State private var showDialog = false

    var body: some View {
        Button(action: { showDialog = true }) {
            HStack {
                Text(selected.isEmpty ? placeholder : selected)
                    .font(.system(size: 15))
                    .foregroundColor(selected.isEmpty ? .kycFPlaceholder : .white)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.kycFLabel)
            }
            .padding(.horizontal, 14).padding(.vertical, 16)
            .background(Color.kycFFieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kycFBorder, lineWidth: 1))
        }
        .confirmationDialog(placeholder, isPresented: $showDialog, titleVisibility: .visible) {
            ForEach(options, id: \.self) { opt in Button(opt) { selected = opt } }
        }
    }
}

// MARK: - Country Picker
private struct KYCFormCountryPicker: View {
    @Binding var selected: String
    @State private var showPicker = false
    private let countries = [
        "Afghanistan","Albania","Algeria","Andorra","Angola","Argentina","Armenia","Australia",
        "Austria","Azerbaijan","Bahamas","Bahrain","Bangladesh","Belarus","Belgium","Belize",
        "Benin","Bhutan","Bolivia","Bosnia and Herzegovina","Botswana","Brazil","Brunei",
        "Bulgaria","Burkina Faso","Burundi","Cambodia","Cameroon","Canada","Chad","Chile",
        "China","Colombia","Congo","Costa Rica","Croatia","Cuba","Cyprus","Czech Republic",
        "Denmark","Djibouti","Dominican Republic","Ecuador","Egypt","El Salvador","Estonia",
        "Ethiopia","Fiji","Finland","France","Gabon","Georgia","Germany","Ghana","Greece",
        "Guatemala","Guinea","Haiti","Honduras","Hungary","Iceland","India","Indonesia","Iran",
        "Iraq","Ireland","Israel","Italy","Jamaica","Japan","Jordan","Kazakhstan","Kenya",
        "Kuwait","Kyrgyzstan","Laos","Latvia","Lebanon","Libya","Liechtenstein","Lithuania",
        "Luxembourg","Madagascar","Malawi","Malaysia","Maldives","Mali","Malta","Mexico",
        "Moldova","Monaco","Mongolia","Montenegro","Morocco","Mozambique","Myanmar","Namibia",
        "Nepal","Netherlands","New Zealand","Nicaragua","Niger","Nigeria","Norway",
        "Oman","Pakistan","Panama","Paraguay","Peru","Philippines","Poland","Portugal","Qatar",
        "Romania","Russia","Rwanda","Saudi Arabia","Senegal","Serbia","Sierra Leone","Singapore",
        "Slovakia","Slovenia","Somalia","South Africa","South Korea","Spain","Sri Lanka","Sudan",
        "Sweden","Switzerland","Syria","Taiwan","Tajikistan","Tanzania","Thailand","Togo",
        "Trinidad and Tobago","Tunisia","Turkey","Turkmenistan","Uganda","Ukraine",
        "United Arab Emirates","United Kingdom","United States","Uruguay","Uzbekistan",
        "Vanuatu","Vatican City","Venezuela","Vietnam","Wallis and Futuna","Western Sahara",
        "Yemen","Zambia","Zimbabwe"
    ]
    var body: some View {
        Button(action: { showPicker.toggle() }) {
            HStack {
                Text(selected).font(.system(size: 15)).foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.down").font(.system(size: 13, weight: .medium)).foregroundColor(.kycFLabel)
            }
            .padding(.horizontal, 14).padding(.vertical, 16)
            .background(Color.kycFFieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kycFBorder, lineWidth: 1))
        }
        .confirmationDialog("Select Country", isPresented: $showPicker, titleVisibility: .visible) {
            ForEach(countries, id: \.self) { c in Button(c) { selected = c } }
        }
    }
}

// MARK: - DOB Field
private struct KYCFormDOBField: View {
    @Binding var selectedDate: Date?
    @State private var showPicker = false
    @State private var tempDate   = Date()
    private var displayText: String {
        guard let date = selectedDate else { return "" }
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }
    var body: some View {
        Button(action: { showPicker = true }) {
            HStack {
                if displayText.isEmpty {
                    Text("Select Date of Birth (YYYY-MM-DD)").foregroundColor(.kycFPlaceholder).font(.system(size: 15))
                } else {
                    Text(displayText).foregroundColor(.white).font(.system(size: 15))
                }
                Spacer()
                Image(systemName: "calendar").font(.system(size: 18)).foregroundColor(.kycFAccent)
            }
            .padding(.horizontal, 14).padding(.vertical, 16)
            .background(Color.kycFFieldBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kycFBorder, lineWidth: 1))
        }
        .sheet(isPresented: $showPicker) {
            VStack(spacing: 0) {
                HStack {
                    Button("Cancel") { showPicker = false }.foregroundColor(.kycFAccent)
                    Spacer()
                    Text("Date of Birth").font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                    Spacer()
                    Button("Done") { selectedDate = tempDate; showPicker = false }
                        .foregroundColor(.kycFAccent).fontWeight(.semibold)
                }
                .padding(.horizontal, 20).padding(.vertical, 16).background(Color.kycFCard)
                Divider().background(Color.kycFBorder)
                DatePicker("", selection: $tempDate, in: ...Date(), displayedComponents: .date)
                    .datePickerStyle(.wheel).labelsHidden().colorScheme(.dark).padding().background(Color.kycFBg)
                Spacer()
            }
            .background(Color.kycFBg.ignoresSafeArea())
            .presentationDetents([.medium])
            .onAppear { tempDate = selectedDate ?? Date() }
        }
    }
}

// MARK: - File Upload Field
private struct KYCFormFileUploadField: View {
    let label: String
    let hint: String
    @Binding var fileName: String
    @Binding var fileData: Data?

    @State private var showFilePicker   = false
    @State private var showImagePicker  = false
    @State private var showSourceDialog = false
    @State private var selectedPhoto: PhotosPickerItem? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Label
            HStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kycFLabel)
                Text("*")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.kycFAccent)
            }

            // Upload button
            Button(action: { showSourceDialog = true }) {
                HStack {
                    if fileName.isEmpty {
                        Text("Select file...")
                            .font(.system(size: 15))
                            .foregroundColor(.kycFPlaceholder)
                    } else {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.kycFAccent)
                        Text(fileName)
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    Spacer()
                    Image(systemName: "arrow.up.doc.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.kycFAccent)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 18)
                .background(Color.kycFFieldBg)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.kycFBorder, lineWidth: 1))
            }

            // Hint
            Text(hint)
                .font(.system(size: 12))
                .foregroundColor(.kycFPlaceholder)
        }
        // Source selection dialog
        .confirmationDialog("Choose Source", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("Choose from Photos") { showImagePicker = true }
            Button("Browse Files")       { showFilePicker  = true }
        }
        // Document picker
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [
                .jpeg, .png, .pdf,
                UTType(filenameExtension: "doc")  ?? .data,
                UTType(filenameExtension: "docx") ?? .data,
                UTType(filenameExtension: "heic") ?? .data,
            ],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result, let url = urls.first {
                let accessing = url.startAccessingSecurityScopedResource()
                defer { if accessing { url.stopAccessingSecurityScopedResource() } }
                fileName = url.lastPathComponent
                fileData = try? Data(contentsOf: url)
            }
        }
        // Photo picker
        .photosPicker(isPresented: $showImagePicker, selection: $selectedPhoto,
                      matching: .images, photoLibrary: .shared())
        .onChange(of: selectedPhoto) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self) {
                    fileData   = data
                    fileName   = "photo_\(Int(Date().timeIntervalSince1970)).jpg"
                }
            }
        }
    }
}

// MARK: - Bottom Button Bar
private struct KYCFormBottomBar: View {
    let currentStep: Int
    let totalSteps:  Int
    let onBack:      () -> Void
    let onNext:      () -> Void

    var body: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button(action: onBack) {
                    Text("Back")
                        .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .background(Color.kycFBg)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.kycFOrange, lineWidth: 2))
                }
            }
            Button(action: onNext) {
                Text(currentStep == totalSteps - 1 ? "Submit KYC" : "Save and Next")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(Color.kycFOrange)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 16).background(Color.kycFBg)
    }
}

// MARK: - Form Card Wrapper
private struct KYCFormCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(16)
            .background(Color.kycFCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.kycFBorder, lineWidth: 1))
    }
}

// MARK: - Field Row Helper
private struct KYCFieldRow<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            KYCFormFieldLabel(text: label)
            content
        }
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - STEP 0: Personal Address
// ════════════════════════════════════════════════════════════════
private struct KYCStepAddressForm: View {
    @Binding var houseNo: String
    @Binding var street:  String
    @Binding var city:    String
    @Binding var state:   String
    @Binding var country: String
    @Binding var zipCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Personal Address")
                    .font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                Text("Address (This address should match with address proof document)")
                    .font(.system(size: 13)).foregroundColor(.kycFLabel)
            }
            .padding(.top, 20)

            KYCFormCard {
                KYCFieldRow(label: "House no./Apt no.") { KYCFormTextField(placeholder: "Enter House no./Apt no.", text: $houseNo) }
                KYCFieldRow(label: "Street/Area")       { KYCFormTextField(placeholder: "Enter Street/Area", text: $street) }
                KYCFieldRow(label: "City")              { KYCFormTextField(placeholder: "Enter City", text: $city) }
                KYCFieldRow(label: "State")             { KYCFormTextField(placeholder: "Enter State", text: $state) }
                KYCFieldRow(label: "Country")           { KYCFormCountryPicker(selected: $country) }
                KYCFieldRow(label: "Zip Code")          { KYCFormTextField(placeholder: "Enter Zip Code", text: $zipCode, keyboardType: .numberPad) }
            }
            Spacer(minLength: 100)
        }
        .padding(.horizontal, 16)
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - STEP 1: DOB & SSN
// ════════════════════════════════════════════════════════════════
private struct KYCStepDOBSSNForm: View {
    @Binding var selectedDOB:  Date?
    @Binding var placeOfBirth: String
    @Binding var ssnPassport:  String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Date of Birth & SSN")
                .font(.system(size: 26, weight: .bold)).foregroundColor(.white)
                .padding(.top, 20)
            KYCFormCard {
                KYCFieldRow(label: "Date of Birth")      { KYCFormDOBField(selectedDate: $selectedDOB) }
                KYCFieldRow(label: "Place of Birth")     { KYCFormTextField(placeholder: "Enter Place of Birth", text: $placeOfBirth) }
                KYCFieldRow(label: "SSN / Passport No.") { KYCFormTextField(placeholder: "Enter SSN or Passport number", text: $ssnPassport, keyboardType: .asciiCapable) }
            }
            Spacer(minLength: 100)
        }
        .padding(.horizontal, 16)
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - STEP 2: Employment Details
// ════════════════════════════════════════════════════════════════
private struct KYCStepEmploymentForm: View {
    @Binding var industry: String;           @Binding var occupation: String
    @Binding var sourceOfFunds: String;      @Binding var monthlyTxnVolume: String
    @Binding var annualIncome: String;       @Binding var netWorth: String
    @Binding var employmentCategory: String; @Binding var employmentType: String
    @Binding var isPEP: String;              @Binding var bankingPartner: String
    @Binding var bankingDuration: String;    @Binding var purposeOfAccount: String
    @Binding var actingThirdParty: String

    private let industries     = ["Agriculture","Automotive","Banking & Finance","Construction","Education","Energy","Entertainment","Government","Healthcare","Hospitality","Insurance","Legal","Manufacturing","Media","Mining","Non-Profit","Real Estate","Retail","Technology","Telecommunications","Transportation","Other"]
    private let occupations    = ["Business Owner","C-Level Executive","Consultant","Doctor","Engineer","Freelancer","Government Employee","IT Professional","Lawyer","Manager","Military","Nurse","Professor","Retired","Sales Executive","Self Employed","Student","Teacher","Other"]
    private let fundSources    = ["Business Income","Employment Income","Freelance Income","Gifts / Inheritance","Investment Returns","Pension","Rental Income","Savings","Other"]
    private let txnVolumes     = ["Less than $1,000","$1,000 – $5,000","$5,001 – $10,000","$10,001 – $50,000","$50,001 – $100,000","More than $100,000"]
    private let incomeRanges   = ["Less than $20,000","$20,000 – $50,000","$50,001 – $100,000","$100,001 – $250,000","$250,001 – $500,000","More than $500,000"]
    private let netWorthRanges = ["Less than $50,000","$50,000 – $150,000","$150,001 – $500,000","$500,001 – $1,000,000","More than $1,000,000"]
    private let empCategories  = ["Employed","Self-Employed","Unemployed","Student","Retired","Other"]
    private let empTypes       = ["Full-Time","Part-Time","Contract","Freelance","Internship","Seasonal","Not Applicable"]
    private let yesNo          = ["Yes","No"]
    private let durations      = ["Less than 1 year","1 – 3 years","3 – 5 years","5 – 10 years","More than 10 years"]
    private let purposes       = ["Personal Use","Business Transactions","Investment","Savings","Bill Payments","International Transfers","Other"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Employment Details")
                .font(.system(size: 26, weight: .bold)).foregroundColor(.white).padding(.top, 20)
            KYCFormCard {
                KYCFieldRow(label: "Industry")                        { KYCFormDropdown(placeholder: "Select Industry", options: industries, selected: $industry) }
                KYCFieldRow(label: "Occupation")                      { KYCFormDropdown(placeholder: "Select Occupation", options: occupations, selected: $occupation) }
                KYCFieldRow(label: "Sources of Funds")                { KYCFormDropdown(placeholder: "Select Source of Funds", options: fundSources, selected: $sourceOfFunds) }
                KYCFieldRow(label: "Monthly Transaction Volume")      { KYCFormDropdown(placeholder: "Select Monthly Transaction Volume", options: txnVolumes, selected: $monthlyTxnVolume) }
                KYCFieldRow(label: "Annual Income")                   { KYCFormDropdown(placeholder: "Select Annual Income", options: incomeRanges, selected: $annualIncome) }
                KYCFieldRow(label: "Net Worth")                       { KYCFormDropdown(placeholder: "Select Net Worth", options: netWorthRanges, selected: $netWorth) }
                KYCFieldRow(label: "Employment Category")             { KYCFormDropdown(placeholder: "Select Employment Status", options: empCategories, selected: $employmentCategory) }
                KYCFieldRow(label: "Employment Type")                 { KYCFormDropdown(placeholder: "Select Employment Type", options: empTypes, selected: $employmentType) }
                KYCFieldRow(label: "Are you a PEP?")                  { KYCFormDropdown(placeholder: "Select", options: yesNo, selected: $isPEP) }
                KYCFieldRow(label: "Banking Partner")                 { KYCFormTextField(placeholder: "Enter Banking Partner", text: $bankingPartner) }
                KYCFieldRow(label: "Banking Relationship Duration")   { KYCFormDropdown(placeholder: "Select Duration", options: durations, selected: $bankingDuration) }
                KYCFieldRow(label: "Purpose of Account")              { KYCFormDropdown(placeholder: "Select Purpose", options: purposes, selected: $purposeOfAccount) }
                KYCFieldRow(label: "Acting on behalf of third party?"){ KYCFormDropdown(placeholder: "Select", options: yesNo, selected: $actingThirdParty) }
            }
            Spacer(minLength: 100)
        }
        .padding(.horizontal, 16)
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - STEP 3: Address Proof Upload
// ════════════════════════════════════════════════════════════════
private struct KYCStepAddressProofForm: View {
    @Binding var addressProofFileName: String
    @Binding var addressProofData:     Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section title
            VStack(alignment: .leading, spacing: 8) {
                Text("Document Upload - Address Proof")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                Text("Utility Bill or Bank Account Statement from the last 3 months")
                    .font(.system(size: 13))
                    .foregroundColor(.kycFLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)

            // Upload card
            KYCFormCard {
                KYCFormFileUploadField(
                    label:    "Address Proof Document",
                    hint:     "Max 6MB.  Accepted: JPG, PNG, PDF, DOC, DOCX, JFIF, HEIC",
                    fileName: $addressProofFileName,
                    fileData: $addressProofData
                )
            }

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 16)
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - STEP 4: ID Proof Upload
// ════════════════════════════════════════════════════════════════
private struct KYCStepIDProofForm: View {
    @Binding var idFrontFileName: String
    @Binding var idFrontData:     Data?
    @Binding var idBackFileName:  String
    @Binding var idBackData:      Data?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Document Upload - ID Proof")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 20)

            KYCFormCard {
                KYCFormFileUploadField(
                    label:    "ID Proof Front",
                    hint:     "",
                    fileName: $idFrontFileName,
                    fileData: $idFrontData
                )

                Divider().background(Color.kycFBorder)

                KYCFormFileUploadField(
                    label:    "ID Proof Back",
                    hint:     "",
                    fileName: $idBackFileName,
                    fileData: $idBackData
                )

                Text("Max 6MB per file. Accepted: JPG, PNG, JFIF, HEIC")
                    .font(.system(size: 12))
                    .foregroundColor(.kycFPlaceholder)
                    .padding(.top, 4)
            }

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 16)
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - STEP 5: Photo Verification
// ════════════════════════════════════════════════════════════════
private struct KYCStepPhotoForm: View {
    @Binding var selfieImage: UIImage?
    @State private var showCamera      = false
    @State private var showPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var showSourceDialog = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title + subtitle
            VStack(alignment: .leading, spacing: 8) {
                Text("Photo Verification")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                Text("Take a clear selfie or scan the QR code to capture from your mobile device.")
                    .font(.system(size: 14))
                    .foregroundColor(.kycFLabel)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 20)

            // Camera / preview card
            VStack(spacing: 20) {
                Text("Please take a clear selfie of yourself.")
                    .font(.system(size: 15))
                    .foregroundColor(.kycFLabel)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)

                // Preview or placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.kycFFieldBg)

                    if let img = selfieImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.white)
                            .padding(.vertical, 60)
                    }
                }
                .frame(maxWidth: .infinity)
                .fixedSize(horizontal: false, vertical: true)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.kycFBorder, lineWidth: 1)
                )

                // Take Photo button
                Button(action: { showSourceDialog = true }) {
                    Text(selfieImage == nil ? "Take Photo" : "Retake Photo")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.kycFOrange)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.bottom, 4)
            }
            .padding(16)
            .background(Color.kycFCard)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.kycFBorder, lineWidth: 1))

            Spacer(minLength: 100)
        }
        .padding(.horizontal, 16)
        // Source choice
        .confirmationDialog("Choose Source", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button("Take Selfie")         { showCamera      = true }
            Button("Choose from Photos")  { showPhotoPicker = true }
        }
        // Camera
        .fullScreenCover(isPresented: $showCamera) {
            KYCCameraView(capturedImage: $selfieImage)
                .ignoresSafeArea()
        }
        // Photo library
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto,
                      matching: .images, photoLibrary: .shared())
        .onChange(of: selectedPhoto) { item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img  = UIImage(data: data) {
                    selfieImage = img
                }
            }
        }
    }
}

// MARK: - UIImagePickerController wrapper for camera
private struct KYCCameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?
    @Environment(\.dismiss) var dismiss

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType       = .camera
        picker.cameraDevice     = .front
        picker.delegate         = context.coordinator
        picker.allowsEditing    = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: KYCCameraView
        init(_ parent: KYCCameraView) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.capturedImage = img
            }
            parent.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// ════════════════════════════════════════════════════════════════
// MARK: - Main KYC Form View
// ════════════════════════════════════════════════════════════════
struct KYCFormView: View {
    @Environment(\.dismiss) var dismiss

    @State private var currentStep = 0
    private let totalSteps = 6

    // Step 0 – Address
    @State private var houseNo = ""; @State private var street  = ""
    @State private var city    = ""; @State private var state   = ""
    @State private var country = "United States"; @State private var zipCode = ""

    // Step 1 – DOB & SSN
    @State private var selectedDOB: Date? = nil
    @State private var placeOfBirth = ""; @State private var ssnPassport = ""

    // Step 2 – Employment
    @State private var industry = "";           @State private var occupation = ""
    @State private var sourceOfFunds = "";      @State private var monthlyTxnVolume = ""
    @State private var annualIncome = "";       @State private var netWorth = ""
    @State private var employmentCategory = ""; @State private var employmentType = ""
    @State private var isPEP = "No";            @State private var bankingPartner = ""
    @State private var bankingDuration = "";    @State private var purposeOfAccount = ""
    @State private var actingThirdParty = "No"

    // Step 3 – Address Proof
    @State private var addressProofFileName = ""
    @State private var addressProofData: Data? = nil

    // Step 4 – ID Proof
    @State private var idFrontFileName = ""
    @State private var idFrontData:     Data? = nil
    @State private var idBackFileName   = ""
    @State private var idBackData:      Data? = nil

    // Step 5 – Photo Verification
    @State private var selfieImage: UIImage? = nil

    private func goBack() {
        if currentStep > 0 { withAnimation(.easeInOut(duration: 0.25)) { currentStep -= 1 } }
        else { dismiss() }
    }
    private func goNext() {
        if currentStep < totalSteps - 1 { withAnimation(.easeInOut(duration: 0.25)) { currentStep += 1 } }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.kycFBg.ignoresSafeArea()

            VStack(spacing: 0) {
                KYCFormHeader(activeStep: currentStep, onBack: goBack)

                ScrollView {
                    Group {
                        switch currentStep {
                        case 0:
                            KYCStepAddressForm(
                                houseNo: $houseNo, street: $street,
                                city: $city, state: $state,
                                country: $country, zipCode: $zipCode)
                        case 1:
                            KYCStepDOBSSNForm(
                                selectedDOB: $selectedDOB,
                                placeOfBirth: $placeOfBirth,
                                ssnPassport: $ssnPassport)
                        case 2:
                            KYCStepEmploymentForm(
                                industry: $industry, occupation: $occupation,
                                sourceOfFunds: $sourceOfFunds, monthlyTxnVolume: $monthlyTxnVolume,
                                annualIncome: $annualIncome, netWorth: $netWorth,
                                employmentCategory: $employmentCategory, employmentType: $employmentType,
                                isPEP: $isPEP, bankingPartner: $bankingPartner,
                                bankingDuration: $bankingDuration, purposeOfAccount: $purposeOfAccount,
                                actingThirdParty: $actingThirdParty)
                        case 3:
                            KYCStepAddressProofForm(
                                addressProofFileName: $addressProofFileName,
                                addressProofData: $addressProofData)
                        case 4:
                            KYCStepIDProofForm(
                                idFrontFileName: $idFrontFileName,
                                idFrontData:     $idFrontData,
                                idBackFileName:  $idBackFileName,
                                idBackData:      $idBackData
                            )
                        case 5:
                            KYCStepPhotoForm(selfieImage: $selfieImage)
                        default:
                            EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal:   .move(edge: .leading).combined(with: .opacity)))
                    .id(currentStep)
                }

                KYCFormBottomBar(
                    currentStep: currentStep,
                    totalSteps:  totalSteps,
                    onBack:      goBack,
                    onNext:      goNext)
            }

            // FAB
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.kycFBlueBtn)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.kycFBlueBtn.opacity(0.45), radius: 10, x: 0, y: 4)
            }
            .padding(.trailing, 16).padding(.bottom, 100)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
}

#Preview { KYCFormView() }
