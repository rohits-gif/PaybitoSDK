//
//  ShareSheet.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 11/05/26.
//

import Foundation
import SwiftUI
import UIKit

struct ShareSheett: UIViewControllerRepresentable {

    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {

    }
}
