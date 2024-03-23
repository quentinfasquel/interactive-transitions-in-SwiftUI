//
//  View_makeButton.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI

fileprivate struct MakeButtonViewModifier<Label: View>: ViewModifier {
    var action: () -> Void
    var overlayLabel: Label
    func body(content: Content) -> some View {
        Button(action: action) {
            content.overlay {
                overlayLabel
            }
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func makeButton(action: @escaping () -> Void) -> some View {
        modifier(MakeButtonViewModifier(
            action: action,
            overlayLabel: EmptyView()
        ))
    }

    func makeButton<Label: View>(
        action: @escaping () -> Void,
        @ViewBuilder overlay: @escaping () -> Label
    ) -> some View {
        modifier(MakeButtonViewModifier(
            action: action,
            overlayLabel: overlay()
        ))
    }
}
