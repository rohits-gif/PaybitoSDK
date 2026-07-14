//
//   RewardsViewModel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 27/05/26.
//

// RewardsViewModel.swift

//
//  RewardsViewModel.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 27/05/26.
//

import Foundation
import Combine

@MainActor
final class RewardsViewModel: ObservableObject {

    // MARK: - Published State

    @Published var campaigns: [Campaign] = []
    @Published var isLoading: Bool = true
    @Published var toast: ToastMessage? = nil

    // MARK: - Derived Collections

    var activeCampaigns: [Campaign] {
        campaigns.filter { $0.status == "active" }
    }

    var otherCampaigns: [Campaign] {
        campaigns.filter {
            $0.status == "scheduled" || $0.status == "paused"
        }
    }

    var overviewStats: [(icon: String, color: String, label: String, value: Int)] {
        [
            (
                icon: "bolt.fill",
                color: "#10b981",
                label: "Active",
                value: activeCampaigns.count
            ),
            (
                icon: "pause.circle.fill",
                color: "#64748b",
                label: "Paused",
                value: campaigns.filter { $0.status == "paused" }.count
            ),
            (
                icon: "list.bullet",
                color: "#6366f1",
                label: "Total Campaigns",
                value: campaigns.count
            )
        ]
    }

    // MARK: - Dependency

    private let service: RewardsServiceProtocol

    init(service: RewardsServiceProtocol = RewardsService.shared) {
        self.service = service
    }

    // MARK: - Toast Helper

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

    // MARK: - Fetch Campaigns

    func fetchCampaigns() {
        isLoading = true

        let merchantId = RewardsService.shared.extractMerchantId()

        service.fetchCampaigns(
            merchantId: merchantId,
            status: "all"
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

    // MARK: - Pause / Activate Campaign

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

    // MARK: - Delete Campaign

    func deleteCampaign(_ campaign: Campaign) {
        let merchantId = RewardsService.shared.extractMerchantId()

        service.deleteCampaign(
            merchantId: merchantId,
            campaign: campaign
        ) { [weak self] (result: ServiceResult<String>) in

            guard let self = self else { return }

            Task { @MainActor in
                switch result {
                case .success:
                    self.campaigns.removeAll { $0.id == campaign.id }
                    self.showToast("\"\(campaign.name)\" deleted", success: true)

                case .failure(let error):
                    self.showToast(error.localizedDescription, success: false)
                }
            }
        }
    }
}
