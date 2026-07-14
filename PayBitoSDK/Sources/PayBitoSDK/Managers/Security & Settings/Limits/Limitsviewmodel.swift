//
//  LimitsViewModel.swift
//  Trading_Terminal
//

import Foundation
import Combine

// MARK: - View State
enum LimitsViewState {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - Apply Plan State
enum ApplyPlanState {
    case idle
    case submitting
    case success
    case error(String)
}

// MARK: - Limits ViewModel
@MainActor
final class LimitsViewModel: ObservableObject {

    // MARK: - Limits State
    @Published private(set) var viewState: LimitsViewState = .idle
    @Published private(set) var currentPlanName: String = ""
    @Published private(set) var dailyAmountCap: String = ""
    @Published private(set) var monthlyTransactionCap: String = ""
    @Published private(set) var availablePlans: [VolumePlan] = []
    @Published private(set) var activatedVolume: ActivatedVolume?
    @Published private(set) var merchantSettings: MerchantSettingsResponse?

    // MARK: - Pending Review State
    @Published private(set) var requestedVolumeId: Int = 0
    @Published private(set) var requestedVolumeStatus: String = ""

    // MARK: - Apply Plan State
    @Published private(set) var applyPlanState: ApplyPlanState = .idle

    // MARK: - Computed
    var isLoading: Bool {
        if case .loading = viewState { return true }
        return false
    }

    var errorMessage: String? {
        if case .error(let msg) = viewState { return msg }
        return nil
    }

    var isSubmitting: Bool {
        if case .submitting = applyPlanState { return true }
        return false
    }

    var applyErrorMessage: String? {
        if case .error(let msg) = applyPlanState { return msg }
        return nil
    }

    var applyDidSucceed: Bool {
        if case .success = applyPlanState { return true }
        return false
    }

//    /// Returns true if the given volumeId is pending review
//    func isPendingReview(volumeId: String) -> Bool {
//        guard requestedVolumeId > 0 else { return false }
//        return String(requestedVolumeId) == volumeId
//    }

    func isPendingReview(volumeId: String) -> Bool {

        print("Checking pending for:", volumeId)
        print("requestedVolumeId:", requestedVolumeId)
        print("requestedVolumeStatus:", requestedVolumeStatus)

        return String(requestedVolumeId) == volumeId
        &&
        requestedVolumeStatus == "31"
    }
    // MARK: - Private
    private let apiService: LimitsAPIService

    init(apiService: LimitsAPIService = .shared) {
        self.apiService = apiService
    }

    // MARK: - Fetch Limits
    func fetchLimits() {

        viewState = .loading

        apiService.fetchMerchantSettings { [weak self] result in

            guard let self else { return }

            Task { @MainActor in

                switch result {

                case .success(let settings):

                    self.apply(settings: settings)

                    // AFTER settings loaded
                    self.apiService.fetchActivatedVolume { [weak self] result in

                        guard let self else { return }

                        Task { @MainActor in

                            switch result {

                            case .success(let activated):

                                self.activatedVolume = activated

                                self.requestedVolumeId =
                                activated.requestedVolumeId ?? 0

                                self.requestedVolumeStatus =
                                activated.requestedVolumeStatus ?? ""

                                print("✅ requestedVolumeId:",
                                      self.requestedVolumeId)

                                print("✅ requestedVolumeStatus:",
                                      self.requestedVolumeStatus)

                            case .failure(let error):

                                print("❌ Activated volume error:", error)
                            }

                            self.objectWillChange.send()

                            self.viewState = .loaded
                        }
                    }

                case .failure(let error):

                    self.viewState = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Submit Plan
    func submitPlan(type: ApplyPlanType, form: ApplyPlanForm) {
        applyPlanState = .submitting

        apiService.submitVolumeRequest(
            volumeId:  type.volumeId,
            taxId:     form.taxId,
            website:   type == .business ? form.website : nil,
            file1:     form.file1Data,
            file1Name: form.file1Name,
            file2:     type == .business ? form.file2Data : nil,
            file2Name: type == .business ? (form.file2Name.isEmpty ? nil : form.file2Name) : nil,
            file3:     type == .business ? form.file3Data : nil,
            file3Name: type == .business ? (form.file3Name.isEmpty ? nil : form.file3Name) : nil,
            file4:     type == .business ? form.file4Data : nil,
            file4Name: type == .business ? (form.file4Name.isEmpty ? nil : form.file4Name) : nil
        ) { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let response):
                    if response.isSuccess {
                        self.applyPlanState = .success
                        self.fetchLimits() // refresh to show pending badge
                    } else {
                        let msg = response.errorMsg.isEmpty
                            ? "Submission failed. Please try again."
                            : response.errorMsg
                        self.applyPlanState = .error(msg)
                    }
                case .failure(let error):
                    self.applyPlanState = .error(error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Reset apply state
    func resetApplyState() {
        applyPlanState = .idle
    }

    // MARK: - Private Helpers
    private func apply(settings: MerchantSettingsResponse) {
        merchantSettings = settings
        currentPlanName  = settings.volumeName

        var plans = settings.plans
        plans.append(VolumePlan(
            volumeID: "999",
            volumeName: "Enterprise Plan",
            dailyAmountCap: "0",
            monthlyTransactionCap: "0"
        ))
        availablePlans = plans

        if let activePlan = settings.plans.first(where: {
            $0.volumeID == String(settings.volumeID)
        }) {
            dailyAmountCap        = "$ \(activePlan.formattedDailyCap)"
            monthlyTransactionCap = activePlan.formattedMonthlyCap
        } else {
            dailyAmountCap        = "$ \(format(settings.dailyAmountCap))"
            monthlyTransactionCap = format(settings.monthlyTransactionCap)
        }
    }

    private func format(_ value: Int) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
