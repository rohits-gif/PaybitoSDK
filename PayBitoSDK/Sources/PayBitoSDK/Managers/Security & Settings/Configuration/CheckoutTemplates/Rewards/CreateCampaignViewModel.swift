//
//  CreateCampaignViewModel.swift
//  PaymentsTerminsl
//

import Foundation
import SwiftUI

@MainActor
final class CreateCampaignViewModel: ObservableObject {
    

    @Published var campaignName = ""

    @Published var rewardType = 0

    @Published var rewardRate = ""

    @Published var minPurchase = ""

    @Published var maxReward = ""

    @Published var startDate = Date()

    @Published var endDate = Date()

    @Published var noEndDate = false

    @Published var selectedDay = "Every Day"

    @Published var startTime = Date()

    @Published var endTime = Date()

    @Published var isLoading = false

    @Published var toast: ToastData?

    struct ToastData {
        let message: String
        let success: Bool
    }

    private let service: RewardsServiceProtocol

    init(
        service: RewardsServiceProtocol = RewardsService.shared
    ) {
        self.service = service
    }

    var canSubmit: Bool {

        !campaignName
            .trimmingCharacters(in: .whitespaces)
            .isEmpty

        &&

        (Double(rewardRate) ?? 0) > 0
    }

    func saveCampaign() {
        print("CREATE CAMPAIGN TAPPED")

        guard canSubmit else {
            return
        }
        print("CALLING API")

        isLoading = true

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let payload = CreateCampaignPayload(

            merchantId: String(
                RewardsService.shared.extractMerchantId()
            ),

            campaignName: campaignName,

            rewardType: rewardType == 0
                ? "cashback"
                : "store_credit",

            rewardRate: Double(rewardRate) ?? 0,

            minPurchase: Double(minPurchase),

            maxReward: Double(maxReward),

            startDate: formatter.string(from: startDate),

            endDate: noEndDate
                ? nil
                : formatter.string(from: endDate),

            schedules: nil,

            status: "active"
        )

        service.saveCampaign(
            payload: payload,
            action: "INSERT"
        ) { [weak self] result in

            DispatchQueue.main.async {

                self?.isLoading = false

                switch result {

                case .success(let message):

                    self?.toast = ToastData(
                        message: message,
                        success: true
                    )

                case .failure(let error):

                    self?.toast = ToastData(
                        message: error.localizedDescription,
                        success: false
                    )
                }
            }
        }
    }
}
