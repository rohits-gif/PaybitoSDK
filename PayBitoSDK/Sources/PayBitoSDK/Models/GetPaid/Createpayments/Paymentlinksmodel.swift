//
//  Paymentlinksmodel.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/05/26.
//

import Foundation

// MARK: - API Response Wrapper

struct PaymentLinksResponse: Decodable {
    let message:    String
    let payments:   [PaymentLinkItem]
    let returnId:   Int
    let totalCount: Int
}

// MARK: - Payment Link Item

struct PaymentLinkItem: Decodable, Identifiable {

    let id:                   String
    let paymentName:          String
    let paymentType:          String
    let catalogId:            Int
    let shippingProfileId:    Int
    let buyerProfileId:       Int
    let billingId:            Int
   ///// let discountProfileId:    Int
    var discountProfileId: Int?
    let createdAt:            String
    let productId:            Int?
    let priceId:              Int
    let redirectProfileId:    Int
    let processingFeeApplied: Bool

    // MARK: Computed – formatted date for display
    var formattedDate: String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = isoFormatter.date(from: createdAt) {
            let display = DateFormatter()
            display.dateFormat = "MMM d, yyyy"
            return display.string(from: date)
        }
        return createdAt
    }
}
