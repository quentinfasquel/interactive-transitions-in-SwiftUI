//
//  View+dismissButton.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 29/03/2024.
//

import SwiftUI

fileprivate struct DismissButtonViewModifier: ViewModifier {
    @Binding var isVisible: Bool
    var alignment: Alignment
    var padding: CGFloat?
    var action: () -> Void
    func body(content: Content) -> some View {
        content.overlay(alignment: alignment) {
            Button(action: action) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32)
            }
            .padding(.all, padding)
            .opacity(isVisible ? 1 : 0)
            .disabled(!isVisible)
            .foregroundStyle(.foreground)
            .animation(.smooth, value: isVisible)
            .transaction { transaction in
                if !isVisible {
                    transaction.animation = nil
                }
            }
        }
    }
}

extension View {
    func dismissButton(
        isVisible: Binding<Bool> = .constant(true),
        alignment: Alignment = .topTrailing,
        padding: CGFloat? = nil,
        action: @escaping () -> Void
    ) -> some View {
        modifier(DismissButtonViewModifier(
            isVisible: isVisible,
            alignment: alignment,
            padding: padding,
            action: action
        ))
    }
}
