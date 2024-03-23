//
//  1-Animation-Transition-Transaction.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 09/03/2024.
//

import SwiftUI

// MARK: - Animation Example

struct AnimationExampleView: View {
    @State private var isTranslucent: Bool = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Circle()
                .fill(.white)
                .frame(width: 100)
                .opacity(isTranslucent ? 0.5 : 1)
        }
        .onTapGesture {
            withAnimation(.smooth) {
                isTranslucent.toggle()
            }
        }
    }
}

// MARK: - Transition Example

struct TransitionExampleView: View {
    @State private var isAnimating: Bool = false
    @State private var isVisible: Bool = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if isVisible {
                Circle()
                    .fill(.white)
                    .frame(width: 100)
//                    .zIndex(1)
//                    .transition(.scale)
//                    .transition(.move(edge: .bottom))
//                    .transition(.asymmetric(
//                        insertion: .move(edge: .top),
//                        removal: .move(edge: .bottom)
//                    ).combined(with: .opacity))
//                    .id(UUID())
            }
        }
        .onTapGesture {
            withAnimation(.smooth) {
                isVisible.toggle()
            }
            // Uncomment the following lines to intercept cross-transition
//            let requestShowing = !isVisible
//            if requestShowing && isAnimating {
//                print("Request showing before view is hidden")
//            }
//
//            var transaction = Transaction(animation: .smooth)
//            transaction.disablesAnimations = true
//            transaction.addAnimationCompletion(criteria: .removed) {
//                isAnimating = false
//                if !requestShowing {
//                    print("View did finish hiding")
//                }
//            }
//
//            isAnimating = true
//            withTransaction(transaction) {
//                isVisible.toggle()
//            }
        }
    }
}

// MARK: - Transaction Example

struct TransactionExampleView: View {
    @State private var isTranslucent: Bool = false
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Circle()
                .fill(.white)
                .frame(width: 100)
                .opacity(isTranslucent ? 0.5 : 1)
                .scaleEffect(isTranslucent ? 2 : 1)
        }
        .onTapGesture {
            var transaction = Transaction(animation: .spring)
            transaction.animation = .spring.repeatCount(3, autoreverses: true)
            withTransaction(transaction) {
                isTranslucent.toggle()
            }
        }
    }
}

// MARK: - Previews

#Preview("Animation") {
    AnimationExampleView()
}

#Preview("Transition") {
    TransitionExampleView()
}

#Preview("Transaction") {
    TransactionExampleView()
}
