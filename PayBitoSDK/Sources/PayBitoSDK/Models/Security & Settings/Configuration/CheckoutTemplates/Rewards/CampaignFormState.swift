//
//  CampaignFormState.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 29/05/26.
//

import Foundation

struct CampaignFormState {

    var campaignId: Int?
    var scheduleId: Int?

    var campaignName = ""

    var rewardType = "cashback"

    var rewardRate = ""

    var minPurchase = ""

    var maxReward = ""

    var startDate = Date()

    var endDate = Date()

    var noEndDate = false

    var dayOfWeek = 7

    var startTime: Date?

    var endTime: Date?
}


struct SchedulePayload: Encodable {

    let scheduleId: Int?
    let dayOfWeek: Int?

    let startTime: String?
    let endTime: String?
}

struct CreateRewardPayload: Encodable {

    let merchantId: Int

    let campaignId: Int?

    let campaignName: String

    let rewardType: String

    let rewardRate: Double

    let minPurchase: Double

    let maxReward: Double

    let startDate: String?

    let endDate: String?

    let status: String

    let schedules: SchedulePayload?
}
