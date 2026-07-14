//
//   Campaign.swift
//  PaymentsTerminsl
//
//  Created by Sk Jasimuddin on 27/05/26.
//

// Campaign.swift

import Foundation

// MARK: - API Response Wrappers

struct CampaignListResponse: Decodable {
    let status: Bool
    let data: [CampaignDTO]?
    let message: String?
}

struct CampaignActionResponse: Decodable {
    let status: Bool
    let message: String?
}

// MARK: - Raw DTO

struct CampaignDTO: Decodable {
    let campaignId: String
    let campaignName: String
    let rewardType: String
    let rewardRate: Double
    let minPurchase: Double?
    let maxReward: Double?
    let startDate: String?
    let endDate: String?
    let status: String
    let schedules: ScheduleDTO?
    let transactionCount: Int?
    let totalCashbackEarned: Double?
    let totalItemPrice: Double?
}

struct ScheduleDTO: Decodable {
    let scheduleId: Int?
    let dayOfWeek: Int?
    let startTime: String?
    let endTime: String?
}

// MARK: - Domain Model

private let DAY_NAMES = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

struct Campaign: Identifiable, Equatable {
    let id: Int
    let name: String
    let type: String
    let rate: Double
    let minPurchase: Double?
    let maxReward: Double?
    let startDate: String
    let endDate: String
    let status: String          // always lowercased
    let schedule: String
    let scheduleId: Int?
    let transactionCount: Int
    let totalCashbackEarned: Double
    let totalItemPrice: Double

    var isCashback: Bool { type == "cashback" }
    var isPaused: Bool   { status == "paused" }

    static func from(_ dto: CampaignDTO) -> Campaign {
        Campaign(
            id:                   Int(dto.campaignId) ?? 0,
            name:                 dto.campaignName,
            type:                 dto.rewardType,
            rate:                 dto.rewardRate,
            minPurchase:          dto.minPurchase,
            maxReward:            dto.maxReward,
            startDate:            dto.startDate.map { String($0.prefix(10)) } ?? "",
            endDate:              dto.endDate.map   { String($0.prefix(10)) } ?? "",
            status:               dto.status.lowercased(),
            schedule:             formatSchedule(dto.schedules),
            scheduleId:           dto.schedules?.scheduleId,
            transactionCount:     dto.transactionCount     ?? 0,
            totalCashbackEarned:  dto.totalCashbackEarned  ?? 0,
            totalItemPrice:       dto.totalItemPrice        ?? 0
        )
    }
}

private func formatSchedule(_ s: ScheduleDTO?) -> String {
    guard let s else { return "Always" }
    let day: String? = s.dayOfWeek.flatMap { $0 >= 0 && $0 <= 6 ? DAY_NAMES[$0] : nil }
    switch (day, s.startTime, s.endTime) {
    case let (d?, st?, et?): return "\(d) \(st)–\(et)"
    case let (d?, _, _):     return d
    default:                  return "Always"
    }
}

// MARK: - Payloads


struct CreateCampaignPayload: Encodable {

    let merchantId: String

    let campaignName: String

    let rewardType: String

    let rewardRate: Double

    let minPurchase: Double?

    let maxReward: Double?

    let startDate: String

    let endDate: String?

    let schedules: CampaignSchedulePayload?

    let status: String
}
struct CampaignSchedulePayload: Encodable {

    let dayOfWeek: Int

    let startTime: String

    let endTime: String
}

struct DeleteCampaignPayload: Encodable {
    let merchantId: Int
    let campaignId: Int
    var scheduleId: Int?
}



// MARK: - Filter Enum

enum CampaignFilter: String, CaseIterable, Identifiable {
    case all, active, scheduled, paused, ended
    var id: String { rawValue }
    var label: String { rawValue.capitalized }
}
