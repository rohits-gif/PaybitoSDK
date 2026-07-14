// MARK: - PaymentOptionsViewModel.swift

import Foundation
import Combine

class PaymentOptionsViewModel: ObservableObject {

    // MARK: - Published state
    @Published var profiles: [BillingProfile.Profile] = []
    @Published var currencies: [BillingProfile.Currency] = []
    @Published var availableMethodIds: [Int] = [1, 2, 3, 4, 5, 7, 8, 9, 10, 11]
    @Published var gatewayConfig = BillingProfile.GatewayConfig()

    @Published var isLoading = false
    @Published var isSaving = false
    @Published var deletingId: Int? = nil
    @Published var makingDefaultId: Int? = nil

    @Published var toastMessage: String? = nil
    @Published var toastIsError = false

    private let service = PaymentOptionsService.shared

    // MARK: - Load everything on appear
    func loadAll() {
        print("🚀 [PaymentOptionsVM] loadAll")
        isLoading = true

        let group = DispatchGroup()

        // 1. Currencies
        group.enter()
        service.fetchCurrencies { [weak self]
            (result: Swift.Result<[BillingProfile.LedgerCoin], Error>) in
            defer { group.leave() }
            switch result {
            case .success(let coins):
                DispatchQueue.main.async {
                    self?.currencies = coins.map {
                        BillingProfile.Currency(
                            id:   $0.currency_id,
                            code: $0.currency_code,
                            name: $0.currency_name,
                            logo: $0.logo
                        )
                    }
                    print("✅ [PaymentOptionsVM] currencies loaded: \(coins.count)")
                }
            case .failure(let err):
                print("❌ [PaymentOptionsVM] fetchCurrencies: \(err)")
            }
        }

        // 2. Gateways — mirrors the web's getAllGateways check for all 7
        group.enter()
        service.fetchGateways { [weak self]
            (result: Swift.Result<BillingProfile.GatewayResponse, Error>) in
            defer { group.leave() }
            switch result {
            case .success(let res):
                let gateways = res.payment_gateways ?? []
                let stripe      = gateways.first { $0.gatewayName == "Stripe" }
                let paypal      = gateways.first { $0.gatewayName == "Paypal" }
                let kurvpay     = gateways.first { $0.gatewayName == "KurvPay" }
                let netbilling  = gateways.first { $0.gatewayName?.lowercased() == "netbilling" }
                let hms         = gateways.first { $0.gatewayName == "HostMerchantServices" }
                let cardflo     = gateways.first { $0.gatewayName == "cardflo" }
                let nmi         = gateways.first { $0.gatewayName == "NMI" }
                DispatchQueue.main.async {
                    self?.gatewayConfig = BillingProfile.GatewayConfig(
                        stripeConfigured:     !(stripe?.clientId ?? "").isEmpty && !(stripe?.clientSecret ?? "").isEmpty,
                        paypalConfigured:     !(paypal?.clientId ?? "").isEmpty && !(paypal?.clientSecret ?? "").isEmpty,
                        kurvPayConfigured:    !(kurvpay?.clientId ?? "").isEmpty && !(kurvpay?.clientSecret ?? "").isEmpty,
                        netbillingConfigured: !(netbilling?.accountId ?? "").isEmpty && !(netbilling?.siteTag ?? "").isEmpty,
                        hmsConfigured:        !(hms?.clientId ?? "").isEmpty && !(hms?.clientSecret ?? "").isEmpty,
                        cardFloConfigured:    !(cardflo?.clientId ?? "").isEmpty && !(cardflo?.userName ?? "").isEmpty
                                              && !(cardflo?.password ?? "").isEmpty && !(cardflo?.cashierKey ?? "").isEmpty,
                        nmiConfigured:        !(nmi?.clientId ?? "").isEmpty && !(nmi?.clientSecret ?? "").isEmpty
                    )
                    print("✅ [PaymentOptionsVM] gatewayConfig set")
                }
            case .failure(let err):
                print("❌ [PaymentOptionsVM] fetchGateways: \(err)")
            }
        }

        // 3. Payment method IDs
        group.enter()
        service.fetchPaymentMethods { [weak self]
            (result: Swift.Result<BillingProfile.MethodsResponse, Error>) in
            defer { group.leave() }
            switch result {
            case .success(let res):
                if res.status == true, let methods = res.data {
                    DispatchQueue.main.async {
                        self?.availableMethodIds = methods.map { $0.id }
                        print("✅ [PaymentOptionsVM] methodIds: \(self?.availableMethodIds ?? [])")
                    }
                }
            case .failure(let err):
                print("❌ [PaymentOptionsVM] fetchPaymentMethods: \(err)")
            }
        }

        // 4. After prerequisites, fetch profiles
        group.notify(queue: .main) { [weak self] in
            print("✅ [PaymentOptionsVM] prerequisites loaded — fetching profiles")
            self?.fetchProfiles()
        }
    }

    // MARK: - Fetch Profiles
    func fetchProfiles() {
        print("🚀 [PaymentOptionsVM] fetchProfiles")
        isLoading = true

        service.fetchProfiles { [weak self]
            (result: Swift.Result<BillingProfile.FetchAllResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let res):
                    guard res.error == 0 else {
                        self.toast(res.message ?? "Failed to load profiles", isError: true)
                        return
                    }
                    let singles = (res.data ?? []).filter { $0.billingType == "SINGLE" }
                    self.profiles = singles.map { self.mapRecord($0) }
                    print("✅ [PaymentOptionsVM] profiles mapped: \(self.profiles.count)")
                case .failure(let err):
                    print("❌ [PaymentOptionsVM] fetchProfiles: \(err)")
                    self.toast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Create Profile
    func createProfile(
        name: String,
        customerEmail: String,
        stripeEnabled: Bool,
        paypalEnabled: Bool,
        kurvPayEnabled: Bool,
        netbillingEnabled: Bool,
        hmsEnabled: Bool,
        cardFloEnabled: Bool,
        nmiEnabled: Bool,
        brandWallet: Bool,
        externalWalletEnabled: Bool,
        guestCheckout: Bool,
        selectedCodes: [String],
        isDefault: Bool = false,
        completion: @escaping (Bool) -> Void
    ) {
        print("🚀 [PaymentOptionsVM] createProfile: \(name)")
        isSaving = true

        let methodIds = buildPaymentMethodIds(
            stripe: stripeEnabled,
            paypal: paypalEnabled,
            kurvPay: kurvPayEnabled,
            netbilling: netbillingEnabled,
            hms: hmsEnabled,
            cardFlo: cardFloEnabled,
            nmi: nmiEnabled,
            brandWallet: brandWallet,
            extWallet: externalWalletEnabled,
            guest: guestCheckout
        )

        let currencyIds = buildCurrencyIds(from: selectedCodes)

        let payload = BillingProfile.CreatePayload(
            merchantId: extractMerchantId(),
            billingType: "SINGLE",
            profileName: name,
            paymentMethodIds: methodIds,
            redirectUrl: "",
            customerEmail: customerEmail,
            isDefaultProfile: isDefault ? 1 : 0,
            currencyIds: currencyIds
        )

        print("📦 Payload methodIds: \(methodIds)")

        service.createProfile(payload: payload) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    if res.error == "0" {
                        self.toast(res.message ?? "Profile created successfully", isError: false)
                        self.fetchProfiles()
                        completion(true)
                    } else {
                        self.toast(res.message ?? "Failed to create profile", isError: true)
                        completion(false)
                    }
                case .failure(let err):
                    self.toast(err.localizedDescription, isError: true)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Update Profile
    func updateProfile(
        id: Int,
        name: String,
        customerEmail: String,
        stripeEnabled: Bool,
        paypalEnabled: Bool,
        kurvPayEnabled: Bool,
        netbillingEnabled: Bool,
        hmsEnabled: Bool,
        cardFloEnabled: Bool,
        nmiEnabled: Bool,
        brandWallet: Bool,
        externalWalletEnabled: Bool,
        guestCheckout: Bool,
        selectedCodes: [String],
        isDefault: Bool,
        completion: @escaping (Bool) -> Void
    ) {
        print("🚀 [PaymentOptionsVM] updateProfile id:\(id)")
        isSaving = true

        let methodIds = buildPaymentMethodIds(
            stripe: stripeEnabled,
            paypal: paypalEnabled,
            kurvPay: kurvPayEnabled,
            netbilling: netbillingEnabled,
            hms: hmsEnabled,
            cardFlo: cardFloEnabled,
            nmi: nmiEnabled,
            brandWallet: brandWallet,
            extWallet: externalWalletEnabled,
            guest: guestCheckout
        )

        let currencyIds = buildCurrencyIds(from: selectedCodes)

        let payload = BillingProfile.UpdatePayload(
            id: id,
            merchantId: extractMerchantId(),
            billingType: "SINGLE",
            profileName: name,
            paymentMethodIds: methodIds,
            customerEmail: customerEmail,
            isDefaultProfile: isDefault ? 1 : 0,
            currencyIds: currencyIds
        )

        print("📦 Update Payload methodIds: \(methodIds)")

        service.updateProfile(payload: payload) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isSaving = false
                switch result {
                case .success(let res):
                    if res.error == "0" {
                        self.toast(res.message ?? "Profile updated successfully", isError: false)
                        self.fetchProfiles()
                        completion(true)
                    } else {
                        self.toast(res.message ?? "Failed to update profile", isError: true)
                        completion(false)
                    }
                case .failure(let err):
                    self.toast(err.localizedDescription, isError: true)
                    completion(false)
                }
            }
        }
    }

    // MARK: - Delete Profile
    func deleteProfile(id: Int) {
        print("🚀 [PaymentOptionsVM] deleteProfile id:\(id)")
        deletingId = id

        service.deleteProfile(id: id) { [weak self]
            (result: Swift.Result<BillingProfile.DeleteResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.deletingId = nil
                switch result {
                case .success(let res):
                    if res.error == 0 {
                        self.toast(res.message ?? "Profile deleted", isError: false)
                        self.profiles.removeAll { $0.id == id }
                    } else {
                        self.toast(res.message ?? "Failed to delete profile", isError: true)
                    }
                case .failure(let err):
                    self.toast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Mark as Default
    func markAsDefault(id: Int) {
        print("🚀 [PaymentOptionsVM] markAsDefault id:\(id)")
        makingDefaultId = id

        service.markAsDefault(profileId: id) { [weak self]
            (result: Swift.Result<BillingProfile.DefaultResponse, Error>) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.makingDefaultId = nil
                switch result {
                case .success(let res):
                    if res.error.isSuccess {
                        self.toast(res.message ?? "Set as default profile", isError: false)
                        self.fetchProfiles()
                    } else {
                        self.toast(res.message ?? "Failed to set as default", isError: true)
                    }
                case .failure(let err):
                    self.toast(err.localizedDescription, isError: true)
                }
            }
        }
    }

    // MARK: - Map API record → UI Profile
    // Mirrors the web's mapRecord which reads paymentMethods array and checks .id
    private func mapRecord(_ rec: BillingProfile.ProfileRecord) -> BillingProfile.Profile {
        let methodIds = (rec.paymentMethods ?? []).map { $0.id }

        let hasBrand    = methodIds.contains(3)
        let hasExt      = methodIds.contains(4)
        let hasGuest    = methodIds.contains(5)
        let cryptoOn    = hasBrand || hasExt || hasGuest

        let codes = rec.currencies?.map { $0.currency } ?? []

        return BillingProfile.Profile(
            id:                   rec.id,
            name:                 rec.profileName,
            customerEmail:        rec.customerEmail ?? "",
            isDefault:            (rec.isDefaultProfile ?? 0) == 1,
            billingType:          rec.billingType,
            stripeEnabled:        methodIds.contains(1),
            paypalEnabled:        methodIds.contains(2),
            kurvPayEnabled:       methodIds.contains(7),
            netbillingEnabled:    methodIds.contains(8),
            hmsEnabled:           methodIds.contains(9),
            cardFloEnabled:       methodIds.contains(10),
            nmiEnabled:           methodIds.contains(11),
            cryptoEnabled:        cryptoOn,
            brandWallet:          hasBrand,
            externalWalletEnabled:hasExt,
            guestCheckout:        hasGuest,
            selectedCryptoCodes:  codes
        )
    }

    // MARK: - Build paymentMethodIds string
    // Mirrors web's buildPaymentMethodIds — outputs "id:position:status" triples
    // so the backend can restore order and enabled state on reload.
    private func buildPaymentMethodIds(
        stripe: Bool,
        paypal: Bool,
        kurvPay: Bool,
        netbilling: Bool,
        hms: Bool,
        cardFlo: Bool,
        nmi: Bool,
        brandWallet: Bool,
        extWallet: Bool,
        guest: Bool
    ) -> String {
        // Fixed canonical order matching web default:
        // stripe, paypal, kurvpay, netbilling, hms, nmi, cardflo, then crypto subs
        var pairs: [String] = []
        var pos = 1

        if availableMethodIds.contains(1)  { pairs.append("1:\(pos):\(stripe      ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(2)  { pairs.append("2:\(pos):\(paypal      ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(7)  { pairs.append("7:\(pos):\(kurvPay     ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(8)  { pairs.append("8:\(pos):\(netbilling  ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(9)  { pairs.append("9:\(pos):\(hms        ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(11) { pairs.append("11:\(pos):\(nmi        ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(10) { pairs.append("10:\(pos):\(cardFlo    ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(3)  { pairs.append("3:\(pos):\(brandWallet ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(4)  { pairs.append("4:\(pos):\(extWallet   ? 1 : 0)"); pos += 1 }
        if availableMethodIds.contains(5)  { pairs.append("5:\(pos):\(guest       ? 1 : 0)"); pos += 1 }

        return pairs.joined(separator: ",")
    }

    // MARK: - [code] → currencyIds string
    private func buildCurrencyIds(from codes: [String]) -> String {
        codes
            .compactMap { code in currencies.first { $0.code == code }?.id }
            .map { String($0) }
            .joined(separator: ",")
    }

    // MARK: - Merchant ID resolution (same 5-step chain)
    private func extractMerchantId() -> Int {
        let ud = UserDefaults.standard
        if let v = ud.value(forKey: "merchantId") as? Int { return v }
        if let v = ud.value(forKey: "BMerchantId") as? Int { return v }
        if let s = ud.object(forKey: "merchantId") as? String, let v = Int(s) { return v }
        if let s = ud.object(forKey: "BMerchantId") as? String, let v = Int(s) { return v }

        let token = ud.string(forKey: "Baccess_token") ?? ""
        let parts = token.components(separatedBy: ".")
        if parts.count >= 2 {
            var payload = parts[1]
            let rem = payload.count % 4
            if rem != 0 { payload += String(repeating: "=", count: 4 - rem) }
            if let data = Data(base64Encoded: payload),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let sub = json["sub"] as? String,
               let idStr = sub.components(separatedBy: "-").first,
               let id = Int(idStr) { return id }
        }
        return 0
    }

    // MARK: - Toast
    func toast(_ msg: String, isError: Bool) {
        toastIsError = isError
        toastMessage = msg
    }
}
