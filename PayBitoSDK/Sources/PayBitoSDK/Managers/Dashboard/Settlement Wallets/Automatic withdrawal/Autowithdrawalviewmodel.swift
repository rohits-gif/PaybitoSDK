//
//  Autowithdrawalviewmodel ·.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 10/06/26.
//

import Foundation
import Combine

final class AutoWithdrawalViewModel: ObservableObject {

    // MARK: - Coin list
    @Published var coins: [AutoWithdrawal.Coin] = []
    @Published var coinsLoading = true

    // MARK: - Create-rule form
    @Published var selectedCoins: Set<String> = []
    @Published var destination: AutoWithdrawal.Destination = .platformWallet
    @Published var amount = ""
    @Published var frequency = ""
    @Published var formErrors: FormErrors = .init()

    // MARK: - Destination verification
    @Published var destChecking = false
    @Published var resolvedAddresses: [AutoWithdrawal.ResolvedAddress] = []
    @Published var bankStatus: AutoWithdrawal.BankStatus = .notSubmitted

    // MARK: - Modals (create flow)
    @Published var showCryptoAddrModal  = false
    @Published var showBankModal        = false
    @Published var bankModalStatus: Int? = nil
    @Published var hasAddrError  = false
    @Published var hasBankError  = false

    // MARK: - Submit
    @Published var submitting = false
    @Published var toastMessage: ToastMessage? = nil

    // MARK: - Rules list
    @Published var rules: [AutoWithdrawal.Rule] = []
    @Published var rulesLoading = false

    // MARK: - Delete modal
    @Published var ruleToDelete: AutoWithdrawal.Rule? = nil
    @Published var deleteSubmitting = false

    // MARK: - Edit modal
    @Published var ruleToEdit: AutoWithdrawal.Rule? = nil
    @Published var editCoins: Set<String> = []
    @Published var editDest: AutoWithdrawal.Destination = .platformWallet
    @Published var editAmount = ""
    @Published var editFrequency = ""
    @Published var editFormErrors: FormErrors = .init()
    @Published var editDestChecking = false
    @Published var editResolvedAddresses: [AutoWithdrawal.ResolvedAddress] = []
    @Published var editBankStatus: AutoWithdrawal.BankStatus = .notSubmitted
    @Published var editHasAddrError = false
    @Published var editHasBankError = false
    @Published var editSubmitting = false

    private let service = AutoWithdrawalService.shared
    var merchantId: String {
        UserDefaults.standard.string(forKey: "Bmerchant_id") ?? ""
    }
    private var merchantIdInt: Int {
        Int(merchantId) ?? 0
    }
    // Track which coin triggered the addr modal so we can deselect on cancel
    private var lastToggledCoin: String? = nil

    // MARK: - Load
    func loadCoins() {
        coinsLoading = true

        service.fetchCoins(merchantId: merchantId) { [weak self] result in
            DispatchQueue.main.async {

                self?.coinsLoading = false

                switch result {

                case .success(let coins):
                    print("LOADED COINS:", coins.count)
                    self?.coins = coins

                case .failure(let error):
                    print("LOAD COINS ERROR:", error)
                    self?.showToast(.error, error.localizedDescription)
                }
            }
        }
    }

    func loadRules() {
        rulesLoading = true
        service.getRules(merchantId: merchantId) { [weak self] result in
            DispatchQueue.main.async {
                self?.rulesLoading = false
                switch result {
                case .success(let rules): self?.rules = rules
                case .failure(let e):     self?.showToast(.error, e.localizedDescription)
                }
            }
        }
    }

    // MARK: - Toggle coin (create)
    func toggleCoin(_ code: String) {
        let isAdding = !selectedCoins.contains(code)
        if isAdding { selectedCoins.insert(code) } else { selectedCoins.remove(code) }
        formErrors.coins = nil

        guard destination == .externalWallet else { return }

        if !isAdding {
            resolvedAddresses.removeAll { $0.code == code }
            hasAddrError = false
            return
        }

        guard let coin = coins.first(where: { $0.currencyCode == code }) else { return }
        lastToggledCoin = code
        destChecking = true

        service.getCryptoAddress(currencyId: coin.id, merchantId: merchantId) { [weak self] result in
            DispatchQueue.main.async {
                self?.destChecking = false
                guard let self else { return }
                switch result {
                case .failure: self.showToast(.error, "Failed to verify crypto address.")
                case .success(let entries):
                    let addr = entries.first(where: { $0.isEnabledAutoWithdraw == 1 })?.bitcoinAddress
                             ?? entries.first?.bitcoinAddress
                    if let addr {
                        self.resolvedAddresses.removeAll { $0.code == coin.currencyCode }
                        self.resolvedAddresses.append(.init(code: coin.currencyCode,
                                                            name: coin.currencyName,
                                                            logo: coin.logo,
                                                            address: addr))
                        self.hasAddrError = false
                    } else {
                        self.showCryptoAddrModal = true
                        self.hasAddrError = true
                    }
                }
            }
        }
    }

    func cancelCryptoAddrModal() {
        if let coin = lastToggledCoin { selectedCoins.remove(coin) }
        showCryptoAddrModal = false
        lastToggledCoin = nil
    }

    // MARK: - Destination change (create)
    func changeDestination(_ dest: AutoWithdrawal.Destination) {
        destination = dest
        hasAddrError = false
        hasBankError = false
        resolvedAddresses = []
        bankStatus = .notSubmitted

        switch dest {
        case .platformWallet: break
        case .externalWallet: verifyExternalWallet(coins: selectedCoinObjects, isEdit: false)
        case .bankAccount:    verifyBankAccount(isEdit: false)
        }
    }

    // MARK: - Destination change (edit)
    func changeEditDestination(_ dest: AutoWithdrawal.Destination) {
        editDest = dest
        editHasAddrError = false
        editHasBankError = false
        editResolvedAddresses = []
        editBankStatus = .notSubmitted

        switch dest {
        case .platformWallet: break
        case .externalWallet:
            let selectedCoinsForEdit = coins.filter { editCoins.contains($0.currencyCode) }
            verifyExternalWallet(coins: selectedCoinsForEdit, isEdit: true)
        case .bankAccount:
            verifyBankAccount(isEdit: true)
        }
    }

    // MARK: - Toggle coin (edit)
    func toggleEditCoin(_ code: String) {
        let isAdding = !editCoins.contains(code)
        if isAdding { editCoins.insert(code) } else { editCoins.remove(code) }
        editFormErrors.coins = nil

        guard editDest == .externalWallet else { return }

        if !isAdding {
            editResolvedAddresses.removeAll { $0.code == code }
            editHasAddrError = false
            return
        }

        guard let coin = coins.first(where: { $0.currencyCode == code }) else { return }
        editDestChecking = true

        service.getCryptoAddress(currencyId: coin.id, merchantId: merchantId) { [weak self] result in
            DispatchQueue.main.async {
                self?.editDestChecking = false
                guard let self else { return }
                switch result {
                case .failure: self.showToast(.error, "Failed to verify crypto address.")
                case .success(let entries):
                    let addr = entries.first(where: { $0.isEnabledAutoWithdraw == 1 })?.bitcoinAddress
                             ?? entries.first?.bitcoinAddress
                    if let addr {
                        self.editResolvedAddresses.removeAll { $0.code == coin.currencyCode }
                        self.editResolvedAddresses.append(.init(code: coin.currencyCode,
                                                                 name: coin.currencyName,
                                                                 logo: coin.logo,
                                                                 address: addr))
                        self.editHasAddrError = false
                    } else {
                        self.showCryptoAddrModal = true
                        self.editHasAddrError = true
                    }
                }
            }
        }
    }

    // MARK: - Validation
    func validateAmount(_ val: String) -> String? {
        let amt = Double(val) ?? -1
        if val.isEmpty || amt < 100 { return "Minimum withdrawal amount is $100." }
        let parts = val.split(separator: ".", omittingEmptySubsequences: false)
        if (parts.first?.count ?? 0) > 12 { return "Amount must not exceed 12 digits." }
        if let dec = parts.last, parts.count == 2, dec.count > 6 { return "Amount allows up to 6 decimal places." }
        return nil
    }

    func validateFrequency(_ val: String) -> String? {
        guard let freq = Int(val) else { return "Minimum frequency is 7 days." }
        if freq < 7   { return "Minimum frequency is 7 days." }
        if freq > 999 { return "Maximum frequency is 999 days." }
        return nil
    }

    // MARK: - Submit (create)
    func submit() {
        var errs = FormErrors()
        if selectedCoins.isEmpty  { errs.coins     = "Please select at least one asset." }
        errs.amount    = validateAmount(amount)
        errs.frequency = validateFrequency(frequency)
        formErrors = errs
        guard !errs.hasErrors else { return }

        submitting = true
        let currencyIds = selectedCoinObjects.map { "\($0.id)" }.joined(separator: ",")

        service.saveRule(id: 0,
                         merchantId: merchantIdInt,
                         withdrawalType: destination.rawValue,
                         amountInUSD: Double(amount) ?? 0,
                         frequencyDays: Int(frequency) ?? 0,
                         currencyIds: currencyIds) { [weak self] result in
            DispatchQueue.main.async {
                self?.submitting = false
                switch result {
                case .success(let res):
                    if res.status {
                        self?.showToast(.success, res.message ?? "Automatic withdrawal rule saved successfully.")
                        self?.resetCreateForm()
                        self?.loadRules()
                    } else {
                        self?.showToast(.error, res.message ?? "Failed to save rule.")
                    }
                case .failure(let e): self?.showToast(.error, e.localizedDescription)
                }
            }
        }
    }

    // MARK: - Delete
    func deleteRule() {
        guard let rule = ruleToDelete else { return }
        deleteSubmitting = true
        service.deleteRule(id: rule.id, merchantId: merchantIdInt) { [weak self] result in
            DispatchQueue.main.async {
                self?.deleteSubmitting = false
                switch result {
                case .success(let res):
                    if res.status {
                        self?.showToast(.success, res.message ?? "Auto-withdrawal rule deleted successfully.")
                        self?.ruleToDelete = nil
                        self?.loadRules()
                    } else {
                        self?.showToast(.error, res.message ?? "Failed to delete rule.")
                    }
                case .failure(let e): self?.showToast(.error, e.localizedDescription)
                }
            }
        }
    }

    // MARK: - Open edit
    func openEdit(_ rule: AutoWithdrawal.Rule) {
        let dest = AutoWithdrawal.Destination(rawValue: rule.withdrawType) ?? .platformWallet
        let codes: Set<String> = Set(rule.currencies.compactMap { rc in
            coins.first(where: { String($0.id) == String(rc.currencyId) })?.currencyCode
        })

        ruleToEdit     = rule
        editDest       = dest
        editAmount     = String(rule.amountInUsd)
        editFrequency  = String(rule.frequencyInDays)
        editCoins      = codes
        editFormErrors = .init()
        editResolvedAddresses = []
        editBankStatus = .notSubmitted
        editHasAddrError = false
        editHasBankError = false

        if dest == .externalWallet, !codes.isEmpty {
            let selectedCoinsForEdit = coins.filter { codes.contains($0.currencyCode) }
            verifyExternalWallet(coins: selectedCoinsForEdit, isEdit: true)
        } else if dest == .bankAccount {
            verifyBankAccount(isEdit: true)
        }
    }

    func closeEdit() {
        ruleToEdit = nil
        editFormErrors = .init()
        editResolvedAddresses = []
    }

    // MARK: - Save edit
    func saveEdit() {
        var errs = FormErrors()
        if editCoins.isEmpty   { errs.coins     = "Please select at least one asset." }
        errs.amount    = validateAmount(editAmount)
        errs.frequency = validateFrequency(editFrequency)
        editFormErrors = errs
        guard !errs.hasErrors else { return }
        guard let rule = ruleToEdit else { return }

        editSubmitting = true
        let editCoinObjects = coins.filter { editCoins.contains($0.currencyCode) }
        let currencyIds = editCoinObjects.map { "\($0.id)" }.joined(separator: ",")

        service.saveRule(id: rule.id,
                         merchantId: merchantIdInt,
                         withdrawalType: editDest.rawValue,
                         amountInUSD: Double(editAmount) ?? 0,
                         frequencyDays: Int(editFrequency) ?? 0,
                         currencyIds: currencyIds) { [weak self] result in
            DispatchQueue.main.async {
                self?.editSubmitting = false
                switch result {
                case .success(let res):
                    if res.status {
                        self?.showToast(.success, res.message ?? "Rule updated successfully.")
                        self?.closeEdit()
                        self?.loadRules()
                    } else {
                        self?.showToast(.error, res.message ?? "Failed to update rule.")
                    }
                case .failure(let e): self?.showToast(.error, e.localizedDescription)
                }
            }
        }
    }

    // MARK: - Helpers
    private var selectedCoinObjects: [AutoWithdrawal.Coin] {
        coins.filter { selectedCoins.contains($0.currencyCode) }
    }

    private func resetCreateForm() {
        selectedCoins = []
        destination = .platformWallet
        amount = ""
        frequency = ""
        formErrors = .init()
        resolvedAddresses = []
        hasAddrError = false
        hasBankError = false
    }

    private func verifyExternalWallet(coins selectedCoinsArr: [AutoWithdrawal.Coin], isEdit: Bool) {
        guard !selectedCoinsArr.isEmpty else { return }
        if isEdit { editDestChecking = true } else { destChecking = true }

        let group = DispatchGroup()
        var collected: [AutoWithdrawal.ResolvedAddress] = []
        var missing = false

        for coin in selectedCoinsArr {
            group.enter()
            service.getCryptoAddress(currencyId: coin.id, merchantId: merchantId) { result in
                defer { group.leave() }
                switch result {
                case .failure: missing = true
                case .success(let entries):
                    let addr = entries.first(where: { $0.isEnabledAutoWithdraw == 1 })?.bitcoinAddress
                             ?? entries.first?.bitcoinAddress
                    if let addr {
                        collected.append(.init(code: coin.currencyCode, name: coin.currencyName,
                                               logo: coin.logo, address: addr))
                    } else {
                        missing = true
                    }
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            if isEdit {
                self.editDestChecking = false
                if missing {
                    self.showCryptoAddrModal = true
                    self.editHasAddrError = true
                    self.editResolvedAddresses = []
                } else {
                    self.editResolvedAddresses = collected
                    self.editHasAddrError = false
                }
            } else {
                self.destChecking = false
                if missing {
                    self.showCryptoAddrModal = true
                    self.hasAddrError = true
                    self.resolvedAddresses = []
                } else {
                    self.resolvedAddresses = collected
                    self.hasAddrError = false
                }
            }
        }
    }

    private func verifyBankAccount(isEdit: Bool) {
        if isEdit { editDestChecking = true } else { destChecking = true }
        service.getUserDetails { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                if isEdit { self.editDestChecking = false } else { self.destChecking = false }
                switch result {
                case .failure(let e): self.showToast(.error, e.localizedDescription)
                case .success(let res):
                    let status = AutoWithdrawal.BankStatus(raw: res.bankDetailsStatus)
                    if isEdit {
                        self.editBankStatus = status
                        if status == .verified { self.editHasBankError = false }
                        else {
                            self.bankModalStatus = res.bankDetailsStatus
                            self.showBankModal = true
                            self.editHasBankError = true
                        }
                    } else {
                        self.bankStatus = status
                        if status == .verified { self.hasBankError = false }
                        else {
                            self.bankModalStatus = res.bankDetailsStatus
                            self.showBankModal = true
                            self.hasBankError = true
                        }
                    }
                }
            }
        }
    }

    private func showToast(_ style: ToastMessage.Style, _ message: String) {
        toastMessage = .init(style: style, message: message)
    }
}

// MARK: - Supporting types
struct FormErrors {
    var coins: String? = nil
    var amount: String? = nil
    var frequency: String? = nil

    var hasErrors: Bool { coins != nil || amount != nil || frequency != nil }
}

//struct ToastMessage: Identifiable {
//    let id = UUID()
//    enum ToastType { case success, error }
//    let type: ToastType
//    let message: String
//}
