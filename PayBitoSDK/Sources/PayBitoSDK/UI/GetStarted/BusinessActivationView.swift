// ============================================================
// SETUP INSTRUCTIONS
// ============================================================
// 1. Add `countries_slim.json` to your Xcode project
//    - Drag it into the project navigator
//    - In "Add to targets" dialog → check ALL your white-label targets
//    - Rename it `countries_slim.json` (or keep as-is and update the
//      Bundle.main.path call below)
//
// 2. Replace your existing BusinessActivationView.swift with this file
// ============================================================

import SwiftUI
import Alamofire
import SwiftyJSON

// MARK: - Data Models

struct CountryModel: Identifiable {
    let id = UUID()
    let name: String
    let iso2: String
    let phonecode: String
    let emoji: String
    let states: [StateModel]
}

struct StateModel: Identifiable {
    let id = UUID()
    let name: String
    let cities: [String]
}

// MARK: - Country Data Manager (singleton, loads once)

class CountryDataManager {
    static let shared = CountryDataManager()
    private(set) var countries: [CountryModel] = []

    private init() { load() }

    private func load() {
        guard let path = Bundle.main.path(forResource: "countries_slim", ofType: "json"),
              let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
              let raw = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else {
            print("❌ countries_slim.json not found or invalid")
            return
        }
        countries = raw.compactMap { dict in
            guard let name = dict["name"] as? String,
                  let iso2 = dict["iso2"] as? String,
                  let phonecode = dict["phonecode"] as? String,
                  let emoji = dict["emoji"] as? String
            else { return nil }
            let statesRaw = dict["states"] as? [[String: Any]] ?? []
            let states = statesRaw.compactMap { s -> StateModel? in
                guard let sName = s["name"] as? String else { return nil }

                let citiesRaw = s["cities"] as? [[String: Any]] ?? []

                let cities = citiesRaw.compactMap {
                    $0["name"] as? String
                }

                return StateModel(
                    name: sName,
                    cities: cities
                )
            }
            return CountryModel(name: name, iso2: iso2, phonecode: phonecode, emoji: emoji, states: states)
        }
        print("✅ Loaded \(countries.count) countries")
    }

    func find(_ name: String) -> CountryModel? {
        countries.first { $0.name == name }
    }
}

// MARK: - Searchable Picker Sheet

struct SearchablePickerSheet: View {
    let title: String
    let items: [String]
    let selected: String
    let onSelect: (String) -> Void

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private let bg = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let rowBG = Color(red: 0.12, green: 0.15, blue: 0.22)
    private let accent = Color(red: 0.35, green: 0.40, blue: 0.95)

    private var filtered: [String] {
        query.isEmpty ? items : items.filter { $0.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.4))
                        TextField("Search \(title.lowercased())...", text: $query)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(10)
                    .background(Color(red: 0.15, green: 0.18, blue: 0.26))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    if filtered.isEmpty {
                        Spacer()
                        Text("No results").foregroundColor(.white.opacity(0.4))
                        Spacer()
                    } else {
                        List(filtered, id: \.self) { item in
                            Button(action: {
                                onSelect(item)
                                dismiss()
                            }) {
                                HStack {
                                    Text(item)
                                        .foregroundColor(.white)
                                        .font(.system(size: 15))
                                    Spacer()
                                    if item == selected {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(accent)
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                }
                            }
                            .listRowBackground(rowBG)
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(accent)
                }
            }
        }
    }
}

// MARK: - Industry Picker (searchable)

struct IndustryPickerSheet: View {
    let industries: [(id: String, name: String)]
    let selected: String
    let onSelect: (String, String) -> Void

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private let bg = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let rowBG = Color(red: 0.12, green: 0.15, blue: 0.22)
    private let accent = Color(red: 0.35, green: 0.40, blue: 0.95)

    private var filtered: [(id: String, name: String)] {
        query.isEmpty ? industries : industries.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        NavigationView {
            ZStack {
                bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                        TextField("Search industry...", text: $query)
                            .foregroundColor(.white).autocorrectionDisabled()
                    }
                    .padding(10)
                    .background(Color(red: 0.15, green: 0.18, blue: 0.26))
                    .cornerRadius(10)
                    .padding(.horizontal, 16).padding(.vertical, 10)

                    List(filtered, id: \.id) { industry in
                        Button(action: { onSelect(industry.id, industry.name); dismiss() }) {
                            HStack {
                                Text(industry.name).foregroundColor(.white).font(.system(size: 15))
                                Spacer()
                                if industry.name == selected {
                                    Image(systemName: "checkmark").foregroundColor(accent)
                                }
                            }
                        }.listRowBackground(rowBG)
                    }.listStyle(.plain)
                }
            }
            .navigationTitle("Select Industry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(accent)
                }
            }
        }
    }
}

// MARK: - Dial Code Picker (searchable)

struct DialCodePickerSheet: View {
    let selectedCode: String
    let onSelect: (String, String) -> Void

    @State private var query = ""
    @Environment(\.dismiss) private var dismiss

    private let bg = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let rowBG = Color(red: 0.12, green: 0.15, blue: 0.22)
    private let accent = Color(red: 0.35, green: 0.40, blue: 0.95)

    private var allCountries: [CountryModel] { CountryDataManager.shared.countries }

    private var filtered: [CountryModel] {
        query.isEmpty ? allCountries : allCountries.filter {
            $0.name.localizedCaseInsensitiveContains(query) || $0.phonecode.contains(query)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                bg.ignoresSafeArea()
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass").foregroundColor(.white.opacity(0.4))
                        TextField("Search country or code...", text: $query)
                            .foregroundColor(.white).autocorrectionDisabled()
                    }
                    .padding(10)
                    .background(Color(red: 0.15, green: 0.18, blue: 0.26))
                    .cornerRadius(10)
                    .padding(.horizontal, 16).padding(.vertical, 10)

                    List(filtered) { country in
                        let dialCode = "+" + country.phonecode
                        Button(action: { onSelect(country.emoji, dialCode); dismiss() }) {
                            HStack {
                                Text(country.emoji).font(.system(size: 22))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(country.name).foregroundColor(.white).font(.system(size: 14))
                                    Text(dialCode).foregroundColor(.white.opacity(0.55)).font(.system(size: 13))
                                }
                                Spacer()
                                if dialCode == selectedCode {
                                    Image(systemName: "checkmark").foregroundColor(accent)
                                }
                            }
                        }.listRowBackground(rowBG)
                    }.listStyle(.plain)
                }
            }
            .navigationTitle("Select Country Code")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }.foregroundColor(accent)
                }
            }
        }
    }
}

// MARK: - Owner Data Model

struct OwnerData: Identifiable {
    let id = UUID()
    var firstName = ""
    var lastName = ""
    var email = ""
    var phone = ""
    var ownership = ""
    var isPrimary = false
    var flagEmoji = "🇺🇸"
    var dialCode = "+1"
}

// MARK: - ViewModel

class BusinessActivationViewModel: ObservableObject {
    @Published var showOwnerDialCodePicker = false
    @Published var legalName = ""
    @Published var industry = ""
    @Published var industryId = ""

    // Country / State / City
    @Published var country = ""
    @Published var state = ""
    @Published var city = ""

    @Published var zip = ""
    @Published var address1 = ""
    @Published var address2 = ""
    @Published var website = ""
    @Published var phone = ""
    @Published var selectedFlagEmoji = "🇺🇸"
    @Published var selectedDialCode = "+1"
    @Published var owners: [OwnerData] = [OwnerData(isPrimary: true)]
    @Published var arrayIndustry: [(id: String, name: String)] = []

    // Derived lists from selected country/state
    var availableStates: [String] {
        CountryDataManager.shared.find(country)?.states.map(\.name) ?? []
    }
    var availableCities: [String] {
        CountryDataManager.shared.find(country)?
            .states.first(where: { $0.name == state })?
            .cities ?? []
    }
    var allCountryNames: [String] {
        CountryDataManager.shared.countries.map(\.name)
    }

    // Picker visibility
    @Published var showIndustryPicker = false
    @Published var showCountryPicker = false
    @Published var showStatePicker = false
    @Published var showCityPicker = false
    @Published var showDialCodePicker = false
    @Published var ownerDialCodePickerIndex: Int? = nil

    @Published var isLoading = false
    @Published var isVerified = false
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var shouldDismiss = false

    func onCountrySelected(_ name: String) {
        country = name
        state = ""   // reset state & city
        city = ""
        print("Selected Country:", country)

            print("States Count:", availableStates.count)
        // auto-set dial code from emoji+phonecode
        if let match = CountryDataManager.shared.find(name) {
            selectedFlagEmoji = match.emoji
            selectedDialCode = "+" + match.phonecode
            for i in 0..<owners.count {
                owners[i].flagEmoji = match.emoji
                owners[i].dialCode = "+" + match.phonecode
            }
        }
    }

    func onStateSelected(_ name: String) {
        state = name
        city = ""   // reset city
    }
    func setPrimaryOwner(at index: Int) {
        for i in 0..<owners.count {
            owners[i].isPrimary = (i == index)
        }
    }

    func fetchAllIndustries() {
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Origin": "https://portal.paybito.com",
            "Authorization": "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? ""),
            "UUID": UserDefaults.standard.string(forKey: "Buuid") ?? ""
        ]
        let params: [String: Any] = [
            "merchant_id": Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0
        ]
        Alamofire.request(
            "https://service.hashcashconsultants.com/billbitcoins-v2/merchant/FetchAllIndustry",
            method: .post, parameters: params, encoding: JSONEncoding.default, headers: header
        ).responseJSON { [weak self] response in
            guard let self = self else { return }
            if response.result.isSuccess, let value = response.result.value {
                let json = JSON(value)
                DispatchQueue.main.async {
                    self.arrayIndustry = json.arrayValue.map {
                        (id: $0["industry_id"].stringValue, name: $0["industry_name"].stringValue)
                    }
                }
            }
        }
    }

    func fetchVerificationData() {
        isLoading = true
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Origin": "https://portal.paybito.com",
            "Authorization": "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? ""),
            "UUID": UserDefaults.standard.string(forKey: "Buuid") ?? ""
        ]
        let params: [String: Any] = [
            "merchant_id": Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0
        ]
        Alamofire.request(
            bbaseurlLive + "FetchBasicVerification",
            method: .post, parameters: params, encoding: JSONEncoding.default, headers: header
        ).responseJSON { [weak self] response in
            guard let self = self else { return }
            DispatchQueue.main.async { self.isLoading = false }
            if response.result.isSuccess, let value = response.result.value {
                let json = JSON(value)
                for val in json.arrayValue where val["error"].intValue == 0 {
                    DispatchQueue.main.async {
                        self.legalName  = val["organization_name"].stringValue
                        self.address1   = val["address_line_1"].stringValue
                        self.address2   = val["address_line_2"].stringValue
                        self.state      = val["state"].stringValue
                        self.city       = val["city"].stringValue
                        self.zip        = val["zip"].stringValue
                        self.country    = val["country"].stringValue
                        self.website    = val["website"].stringValue
                        self.phone      = val["phone_no"].stringValue
                    }
                }
            }
            if UserDefaults.standard.integer(forKey: "Bbasic_verification_submitted") == 1 {
                DispatchQueue.main.async { self.isVerified = true }
            }
        }
    }

    func verifyAndSave() {
        guard validateForm() else { return }
        isLoading = true
        let header: HTTPHeaders = [
            "Content-Type": "application/json",
            "Origin": "https://portal.paybito.com",
            "Authorization": "bearer " + (UserDefaults.standard.string(forKey: "Baccess_token") ?? ""),
            "UUID": UserDefaults.standard.string(forKey: "Buuid") ?? ""
        ]
        let merchantId = Int(UserDefaults.standard.string(forKey: "Bmerchant_id") ?? "0") ?? 0
        var ownersArray: [[String: Any]] = []
        for (index, owner) in owners.enumerated() {
            let cc = owner.dialCode.hasPrefix("+") ? String(owner.dialCode.dropFirst()) : owner.dialCode
            ownersArray.append([
                "first_name": owner.firstName, "last_name": owner.lastName,
                "email": owner.email, "phone_no": owner.phone,
                "country_code": cc, "ownership_percent": owner.ownership,
                "is_primary": owner.isPrimary ? "1" : "0"
            ])
        }
        let rawWebsite = website.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanWebsite = (rawWebsite.hasPrefix("http://") || rawWebsite.hasPrefix("https://")) ? rawWebsite : "https://" + rawWebsite
        let params: [String: Any] = [
            "merchant_id": merchantId, "address_line_1": address1, "address_line_2": address2,
            "city": city, "country": country, "industry_id": industryId,
            "organization_name": legalName, "phone_no": selectedDialCode + phone,
            "state": state, "website": cleanWebsite, "zip": zip, "owners": ownersArray
        ]
        Alamofire.request(bbaseurlLive + "BasicVerification", method: .post,
                          parameters: params, encoding: JSONEncoding.default, headers: header)
        .responseData { [weak self] response in
            guard let self = self else { return }
            DispatchQueue.main.async { self.isLoading = false }
            guard let data = response.data, let json = try? JSON(data: data) else {
                DispatchQueue.main.async { self.showAlertMessage(title: appName, message: "Invalid server response.") }
                return
            }
            let isErrorZero = json.arrayValue.first?["error"].intValue == 0
            if response.response?.statusCode == 200 && isErrorZero {
                UserDefaults.standard.set(1, forKey: "Bbasic_verification_submitted")
                DispatchQueue.main.async {
                    self.shouldDismiss = true
                    self.showAlertMessage(title: "Success!", message: "Business verification successful!")
                }
            } else {
                let msg = json.arrayValue.first?["error_msg"].stringValue ?? "Verification failed. Please try again."
                DispatchQueue.main.async { self.showAlertMessage(title: appName, message: msg) }
            }
        }
    }

    private func validateForm() -> Bool {
        let checks: [(String, String)] = [
            (legalName,  "Please enter legal business name."),
            (industry,   "Please select the industry type."),
            (country,    "Please select country."),
            (state,      "Please enter state."),
            (city,       "Please enter city."),
            (address1,   "Please enter address line 1."),
            (phone,      "Please enter phone number.")
        ]
        for (val, msg) in checks {
            if val.isEmpty { showAlertMessage(title: appName, message: msg); return false }
        }
        if zip.isEmpty { showAlertMessage(title: appName, message: "Please enter a valid zip code."); return false }
        let ws = website.trimmingCharacters(in: .whitespacesAndNewlines)
        if ws.isEmpty { showAlertMessage(title: appName, message: "Please enter your website or business profile URL."); return false }
        if !isValidURL(ws) { showAlertMessage(title: appName, message: "Please enter a valid URL (e.g. https://example.com)"); return false }
        return true
    }

    private func isValidURL(_ string: String) -> Bool {
        var s = string.lowercased()
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") { s = "https://" + s }
        guard let url = URL(string: s), let host = url.host, !host.isEmpty, host.contains(".") else { return false }
        return true
    }

    func showAlertMessage(title: String, message: String) {
        alertTitle = title; alertMessage = message; showAlert = true
    }
}

// MARK: - Main View

struct BusinessActivationView: View {
    @StateObject private var viewModel = BusinessActivationViewModel()
    @Environment(\.dismiss) private var dismiss

    private let darkBG    = Color(red: 0.08, green: 0.10, blue: 0.16)
    private let cardBG    = Color(red: 0.12, green: 0.15, blue: 0.22)
    private let fieldBG   = Color(red: 0.10, green: 0.12, blue: 0.18)
    private let accentBlue = Color(red: 0.35, green: 0.40, blue: 0.95)
    private let borderColor = Color.white.opacity(0.12)
    private let labelColor  = Color.white.opacity(0.55)

    var body: some View {
        ZStack {
            darkBG.ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                Divider().background(borderColor)
                ScrollView {
                    VStack(spacing: 20) {
                        descriptionSection
                        businessInfoSection
                        websiteContactSection
                        ownerSection
                        warningBanner
                        verifyButton
                    }
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.fetchAllIndustries()
            viewModel.fetchVerificationData()
        }
        // Industry picker
        .sheet(isPresented: $viewModel.showIndustryPicker) {
            IndustryPickerSheet(
                industries: viewModel.arrayIndustry,
                selected: viewModel.industry,
                onSelect: { id, name in
                    viewModel.industryId = id
                    viewModel.industry = name
                }
            )
        }
        // Country picker
        .sheet(isPresented: $viewModel.showCountryPicker) {
            SearchablePickerSheet(
                title: "Select Country",
                items: viewModel.allCountryNames,
                selected: viewModel.country,
                onSelect: { viewModel.onCountrySelected($0) }
            )
        }
        // State picker
        .sheet(isPresented: $viewModel.showStatePicker) {
            SearchablePickerSheet(
                title: "Select State",
                items: viewModel.availableStates,
                selected: viewModel.state,
                onSelect: { viewModel.onStateSelected($0) }
            )
        }
        // City picker
        .sheet(isPresented: $viewModel.showCityPicker) {
            SearchablePickerSheet(
                title: "Select City",
                items: viewModel.availableCities,
                selected: viewModel.city,
                onSelect: { viewModel.city = $0 }
            )
        }
        // Dial code picker
        .sheet(isPresented: $viewModel.showDialCodePicker) {
            DialCodePickerSheet(
                selectedCode: viewModel.selectedDialCode,
                onSelect: { flag, code in
                    viewModel.selectedFlagEmoji = flag
                    viewModel.selectedDialCode = code
                }
            )
        }
        .sheet(isPresented: $viewModel.showOwnerDialCodePicker) {

            if let index = viewModel.ownerDialCodePickerIndex {

                DialCodePickerSheet(

                    selectedCode: viewModel.owners[index].dialCode

                ) { flag, code in

                    viewModel.owners[index].flagEmoji = flag

                    viewModel.owners[index].dialCode = code

                }

            }

        }
        .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
            Button("OK") {
                if viewModel.shouldDismiss {
                    NotificationCenter.default.post(name: NSNotification.Name("refreshGetStarted"), object: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { dismiss() }
                }
            }
        } message: { Text(viewModel.alertMessage) }
    }

    // MARK: Header
    private var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "arrow.left").foregroundColor(.white).frame(width: 36, height: 36)
            }
            Spacer()
            Text("Business Activation").font(.system(size: 18, weight: .bold)).foregroundColor(.white)
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 16).frame(height: 56)
    }

    // MARK: Description
    private var descriptionSection: some View {
        VStack(spacing: 8) {
            Text("Basic verification will allow you to process real payments up to $100 daily and 30 payments monthly.")
                .font(.system(size: 13)).foregroundColor(labelColor)
            Text("We will send you a confirmation email within a few minutes of submitting your verification.")
                .font(.system(size: 13)).foregroundColor(labelColor)
        }
    }

    // MARK: Business Info
    private var businessInfoSection: some View {
        SectionCardB(icon: "building.columns.fill", title: "Business Information",
                     accentBlue: accentBlue, cardBG: cardBG, borderColor: borderColor) {
            VStack(spacing: 14) {
                HStack(spacing: 12) {
                    LabeledField(label: "Legal Name of Business*", labelColor: labelColor) {
                        CustomTextFieldB(text: $viewModel.legalName, placeholder: "Legal name",
                                         fieldBG: fieldBG, borderColor: borderColor)
                    }
                    LabeledField(label: "Industry*", labelColor: labelColor) {
                        DropdownField(text: viewModel.industry, placeholder: "Select Industry",
                                      fieldBG: fieldBG, borderColor: borderColor, labelColor: labelColor,
                                      onTap: { viewModel.showIndustryPicker = true })
                    }
                }
                HStack(spacing: 12) {
                    LabeledField(label: "Country*", labelColor: labelColor) {
                        DropdownField(text: viewModel.country, placeholder: "Select Country",
                                      fieldBG: fieldBG, borderColor: borderColor, labelColor: labelColor,
                                      onTap: { viewModel.showCountryPicker = true })
                    }
                    LabeledField(label: "State*", labelColor: labelColor) {
                        // Show as dropdown if country selected & has states; otherwise text field
                        if viewModel.country.isEmpty || viewModel.availableStates.isEmpty {
                            CustomTextFieldB(text: $viewModel.state, placeholder: "State",
                                             fieldBG: fieldBG, borderColor: borderColor)
                        } else {
                            DropdownField(text: viewModel.state, placeholder: "Select State",
                                          fieldBG: fieldBG, borderColor: borderColor, labelColor: labelColor,
                                          onTap: { viewModel.showStatePicker = true })
                        }
                    }
                }
                HStack(spacing: 12) {
                    LabeledField(label: "City*", labelColor: labelColor) {
                        if viewModel.state.isEmpty || viewModel.availableCities.isEmpty {
                            CustomTextFieldB(text: $viewModel.city, placeholder: "City",
                                             fieldBG: fieldBG, borderColor: borderColor)
                        } else {
                            DropdownField(text: viewModel.city, placeholder: "Select City",
                                          fieldBG: fieldBG, borderColor: borderColor, labelColor: labelColor,
                                          onTap: { viewModel.showCityPicker = true })
                        }
                    }
                    LabeledField(label: "Zip Code*", labelColor: labelColor) {
                        CustomTextFieldB(text: $viewModel.zip, placeholder: "",
                                         keyboardType: .asciiCapable, fieldBG: fieldBG, borderColor: borderColor)
                    }
                }
                HStack(spacing: 12) {
                    LabeledField(label: "Address Line 1*", labelColor: labelColor) {
                        CustomTextFieldB(text: $viewModel.address1, placeholder: "",
                                         fieldBG: fieldBG, borderColor: borderColor)
                    }
                    LabeledField(label: "Address Line 2", labelColor: labelColor) {
                        CustomTextFieldB(text: $viewModel.address2, placeholder: "",
                                         fieldBG: fieldBG, borderColor: borderColor)
                    }
                }
            }
        }
    }

    // MARK: Website & Contact
    private var websiteContactSection: some View {
        SectionCardB(icon: "globe", title: "Website & Contact",
                     accentBlue: accentBlue, cardBG: cardBG, borderColor: borderColor) {
            VStack(spacing: 14) {
                InfoBanner(text: "Please ensure that your website or business profile is online and accessible for verification.", color: accentBlue)
                LabeledField(label: "Website or Business Profile*", labelColor: labelColor) {
                    CustomTextFieldB(text: $viewModel.website, placeholder: "https://example.com",
                                     keyboardType: .URL, autocapitalization: .never,
                                     fieldBG: fieldBG, borderColor: borderColor)
                }
                LabeledField(label: "Phone*", labelColor: labelColor) {
                    PhoneInputField(flagEmoji: viewModel.selectedFlagEmoji, dialCode: viewModel.selectedDialCode,
                                    phoneNumber: $viewModel.phone, fieldBG: fieldBG, borderColor: borderColor,
                                    onTapDialCode: { viewModel.showDialCodePicker = true })
                }
            }
        }
    }

    // MARK: Owner Section
    private var ownerSection: some View {
        SectionCardB(icon: "person.fill", title: "Beneficial Owner",
                     accentBlue: accentBlue, cardBG: cardBG, borderColor: borderColor) {
            VStack(spacing: 12) {
                InfoBanner(text: "Who owns this business? Please provide the full, legal name of the beneficial owner(s).", color: accentBlue)
                ForEach(Array(viewModel.owners.enumerated()), id: \.offset) { index, _ in
                    OwnerCard(index: index, owner: $viewModel.owners[index],
                              fieldBG: fieldBG, borderColor: borderColor, labelColor: labelColor, accentBlue: accentBlue,
                              onDelete: { if viewModel.owners.count > 1 { withAnimation { viewModel.owners.remove(at: index) } } },
                              onTapDialCode: { viewModel.ownerDialCodePickerIndex = index
                        viewModel.showOwnerDialCodePicker = true}
                              ,
                              onSetPrimary: { viewModel.setPrimaryOwner(at: index) })
                }
                Button(action: { withAnimation { viewModel.owners.append(OwnerData()) } }) {
                    Text("+ Add Beneficial Owner")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(accentBlue)
                        .frame(maxWidth: .infinity).frame(height: 54)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(accentBlue, lineWidth: 1.5))
                }
                
                
            }
        }
        
    }
    

    private var warningBanner: some View {
        InfoBanner(text: "Please ensure the above information is correct as you will not be able to make changes later.",
                   color: Color(red: 0.85, green: 0.55, blue: 0.05))
    }

    private var verifyButton: some View {
        ZStack {
            Button(action: { viewModel.verifyAndSave() }) {
                Text("Verify Now").font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                    .frame(maxWidth: .infinity).frame(height: 54)
                    .background(accentBlue).cornerRadius(14)
            }
            .disabled(viewModel.isVerified || viewModel.isLoading)
            .opacity(viewModel.isVerified ? 0.5 : 1.0)
            if viewModel.isLoading { ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)) }
        }
    }
}

// MARK: - Reusable UI Components (unchanged from original)

struct SectionCardB<Content: View>: View {
    let icon: String; let title: String; let accentBlue: Color; let cardBG: Color; let borderColor: Color; let content: Content
    init(icon: String, title: String, accentBlue: Color, cardBG: Color, borderColor: Color, @ViewBuilder content: () -> Content) {
        self.icon = icon; self.title = title; self.accentBlue = accentBlue
        self.cardBG = cardBG; self.borderColor = borderColor; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10).fill(accentBlue.opacity(0.2)).frame(width: 40, height: 40)
                    Image(systemName: icon).foregroundColor(accentBlue).font(.system(size: 20))
                }
                Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            }
            Divider().background(borderColor)
            content
        }
        .padding(16).background(cardBG).cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(borderColor, lineWidth: 1))
    }
}

struct LabeledField<Content: View>: View {
    let label: String; let labelColor: Color; let content: Content
    init(label: String, labelColor: Color, @ViewBuilder content: () -> Content) {
        self.label = label; self.labelColor = labelColor; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 12)).foregroundColor(labelColor)
            content
        }
    }
}

struct CustomTextFieldB: View {
    @Binding var text: String; let placeholder: String
    var keyboardType: UIKeyboardType = .default	
    var autocapitalization: TextInputAutocapitalization = .sentences
    let fieldBG: Color; let borderColor: Color
    var body: some View {
        TextField(placeholder, text: $text)
            .font(.system(size: 14)).foregroundColor(.white)
            .keyboardType(keyboardType).textInputAutocapitalization(autocapitalization)
            .padding(.horizontal, 12).frame(height: 46)
            .background(fieldBG).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
    }
}

struct DropdownField: View {
    let text: String; let placeholder: String
    let fieldBG: Color; let borderColor: Color; let labelColor: Color; let onTap: () -> Void
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .font(.system(size: 14))
                    .foregroundColor(text.isEmpty ? Color.white.opacity(0.25) : .white)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down").foregroundColor(labelColor).font(.system(size: 12))
            }
            .padding(.horizontal, 12).frame(height: 46)
            .background(fieldBG).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
        }
    }
}
struct PrimaryOwnerDropdown: View {
    let isPrimary: Bool
    let fieldBG: Color; let borderColor: Color; let labelColor: Color
    let onSelectYes: () -> Void
    let onSelectNo: () -> Void

    var body: some View {
        Menu {
            Button("Yes") { onSelectYes() }
            Button("No") { onSelectNo() }
        } label: {
            HStack {
                Text(isPrimary ? "Yes" : "No")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(labelColor)
                    .font(.system(size: 12))
            }
            .padding(.horizontal, 12).frame(height: 46)
            .background(fieldBG).cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
        }
    }
}

struct PhoneInputField: View {
    let flagEmoji: String; let dialCode: String; @Binding var phoneNumber: String
    let fieldBG: Color; let borderColor: Color; let onTapDialCode: () -> Void
    var body: some View {
        HStack(spacing: 0) {
            Button(action: onTapDialCode) {
                Text("\(flagEmoji) \(dialCode) ▾").font(.system(size: 14)).foregroundColor(.white)
                    .padding(.horizontal, 10).frame(width: 90, height: 46)
            }
            Divider().background(borderColor).frame(height: 26)
            TextField("Enter phone number", text: $phoneNumber)
                .font(.system(size: 14)).foregroundColor(.white)
                .keyboardType(.phonePad).padding(.horizontal, 10)
        }
        .background(fieldBG).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(borderColor, lineWidth: 1))
        .frame(height: 46)
    }
}

struct InfoBanner: View {
    let text: String; let color: Color
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle").foregroundColor(color).font(.system(size: 18))
            Text(text).font(.system(size: 13)).foregroundColor(color)
            Spacer()
        }
        .padding(12).background(color.opacity(0.12)).cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(color.opacity(0.4), lineWidth: 1))
    }
}

struct OwnerCard: View {
    let index: Int; @Binding var owner: OwnerData
    let fieldBG: Color; let borderColor: Color; let labelColor: Color; let accentBlue: Color
    let onDelete: () -> Void; let onTapDialCode: () -> Void
    let onSetPrimary: () -> Void   // NEW: tells parent to make this owner the primary one
    private let cardBG = Color(red: 0.10, green: 0.12, blue: 0.20)

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Owner \(index + 1)").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                if owner.isPrimary { Text("(Primary)").font(.system(size: 13)).foregroundColor(accentBlue) }
                Spacer()
                if !owner.isPrimary {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(Color(red: 0.9, green: 0.25, blue: 0.25)).frame(width: 30, height: 30)
                    }
                }
            }
            HStack(spacing: 12) {
                LabeledField(label: "First Name*", labelColor: labelColor) {
                    CustomTextFieldB(text: $owner.firstName, placeholder: "First name", fieldBG: fieldBG, borderColor: borderColor)
                }
                LabeledField(label: "Last Name*", labelColor: labelColor) {
                    CustomTextFieldB(text: $owner.lastName, placeholder: "Last name", fieldBG: fieldBG, borderColor: borderColor)
                }
            }
            HStack(spacing: 12) {
                LabeledField(label: "Email*", labelColor: labelColor) {
                    CustomTextFieldB(text: $owner.email, placeholder: "Email address",
                                     keyboardType: .emailAddress, autocapitalization: .never,
                                     fieldBG: fieldBG, borderColor: borderColor)
                }
                LabeledField(label: "Phone No*", labelColor: labelColor) {
                    PhoneInputField(flagEmoji: owner.flagEmoji, dialCode: owner.dialCode,
                                    phoneNumber: $owner.phone, fieldBG: fieldBG, borderColor: borderColor,
                                    onTapDialCode: onTapDialCode)
                }
            }
            HStack(spacing: 12) {
                LabeledField(label: "Ownership Percent*", labelColor: labelColor) {
                    CustomTextFieldB(text: $owner.ownership, placeholder: "e.g. 60.00",
                                     keyboardType: .decimalPad, fieldBG: fieldBG, borderColor: borderColor)
                }
                LabeledField(label: "Primary Owner", labelColor: labelColor) {
                    PrimaryOwnerDropdown(
                        isPrimary: owner.isPrimary,
                        fieldBG: fieldBG, borderColor: borderColor, labelColor: labelColor,
                        onSelectYes: { onSetPrimary() },
                        onSelectNo: { owner.isPrimary = false }
                    )
                }
            }
        }
        .padding(14).background(cardBG).cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(borderColor, lineWidth: 1))
    }
}
