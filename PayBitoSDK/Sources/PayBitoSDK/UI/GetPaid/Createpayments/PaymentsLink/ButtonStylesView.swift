//
//  ButtonStylesView.swift
//  Trading_Terminal
//
//  Created by Sk Jasimuddin on 07/05/26.
//

///
////  ButtonStyles.swift
////  Trading_Terminal
////
////  Shared button styles used across the app.
////  Define once here — never redeclare in individual view files.
////

import SwiftUI

// MARK: - Scale Button Style
// Shrinks + dims on press. Use instead of .buttonStyle(.plain) wherever
// you want tactile press feedback.

struct ButtonStylesView: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .opacity(configuration.isPressed ? 0.80 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}
