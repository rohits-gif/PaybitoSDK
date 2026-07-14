//
//   Rewardcampaignsviewmodel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 27/05/26.
//

// RewardCampaignsViewModel.swift

import Foundation
import Combine

@MainActor
final class RewardCampaignsViewModel: ObservableObject {

    // MARK: Published State

    @Published var campaigns: [Campaign] = []
    @Published var isLoading = false
    @Published var toast: ToastMessage? = nil
    @Published var filter: CampaignFilter = .all
    @Published var searchText: String = ""

    // MARK: Dependency

    private let service: RewardsServiceProtocol

    init(service: RewardsServiceProtocol = RewardsService.shared) {
        self.service = service
    }

    // MARK: Derived

    var filtered: [Campaign] {
        guard !searchText.isEmpty else { return campaigns }

        return campaigns.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    func count(for filter: CampaignFilter) -> Int {
        if filter == .all {
            return campaigns.count
        }
        return campaigns.filter { $0.status == filter.rawValue }.count
    }

    // MARK: Toast

    private func showToast(_ text: String, success: Bool) {
        toast = ToastMessage(
            style: success ? .success : .error,
            message: text
        )

        Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            self.toast = nil
        }
    }

    // MARK: Fetch Campaigns

    func fetchCampaigns() {
        isLoading = true

        let statusParam = filter == .all ? "all" : filter.rawValue
        let merchantId = RewardsService.shared.extractMerchantId()

        service.fetchCampaigns(
            merchantId: merchantId,
            status: statusParam
        ) { [weak self] (result: ServiceResult<[Campaign]>) in

            guard let self = self else { return }

            Task { @MainActor in
                self.isLoading = false

                switch result {
                case .success(let list):
                    self.campaigns = list

                case .failure(let error):
                    self.campaigns = []
                    self.showToast(error.localizedDescription, success: false)
                }
            }
        }
    }

    // MARK: Pause / Activate

    func togglePause(_ campaign: Campaign) {
        service.togglePause(
            campaignId: campaign.id,
            isPaused: campaign.isPaused
        ) { [weak self] (result: ServiceResult<String>) in

            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success:
                    let message = campaign.isPaused
                        ? "\"\(campaign.name)\" activated"
                        : "\"\(campaign.name)\" paused"

                    self.showToast(message, success: true)
                    self.fetchCampaigns()

                case .failure(let error):
                    self.showToast(error.localizedDescription, success: false)
                }
            }
        }
    }

    // MARK: Delete

    func deleteCampaign(
        _ campaign: Campaign,
        completion: @escaping (Bool) -> Void
    ) {
        let merchantId = RewardsService.shared.extractMerchantId()

        service.deleteCampaign(
            merchantId: merchantId,
            campaign: campaign
        ) { [weak self] (result: ServiceResult<String>) in

            guard let self = self else {
                completion(false)
                return
            }

            Task { @MainActor in
                switch result {
                case .success:
                    self.showToast("\"\(campaign.name)\" deleted", success: true)
                    self.campaigns.removeAll { $0.id == campaign.id }
                    completion(true)

                case .failure(let error):
                    self.showToast(error.localizedDescription, success: false)
                    completion(false)
                }
            }
        }
    }
}
