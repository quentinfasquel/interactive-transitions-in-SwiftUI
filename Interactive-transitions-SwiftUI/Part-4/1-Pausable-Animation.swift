//
//  1-PausableAnimation.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 13/04/2024.
//

import SwiftUI

struct PausableAnimationExampleView: View {
    @State private var isPaused = false
    @State private var isAnimating: Bool = false
    @State private var atTopRounded: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                RoundedRectangle(cornerRadius: atTopRounded ? 40 : 0)
                    .foregroundStyle(atTopRounded ? .yellow : .white)
                    .aspectRatio(atTopRounded ? 2 : 1, contentMode: .fit)
                    .frame(height: atTopRounded ? nil : 200)
                    .ignoresSafeArea(edges: atTopRounded ? .all : [])

                if atTopRounded {
                    Spacer()
                }
            }
        }
        .environment(\.animationPaused, isPaused)
        .safeAreaInset(edge: .bottom) {
            HStack(spacing: 16) {
                Button { isPaused.toggle() } label: {
                    Image(systemName: isAnimating && !isPaused ? "pause.fill" : "play.fill")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .disabled(!isAnimating)

                Button { toggleWithAnimation() } label: {
                    Text(atTopRounded ? "Move to center" : "Move to top")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .font(.callout)
                        .textCase(.uppercase)
                }
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
                .disabled(isAnimating)
            }
        }

        .preferredColorScheme(.dark)
    }

    func toggleWithAnimation() {
        isAnimating = true
        withAnimation(.pausable(.spring(duration: 2)), completionCriteria: .removed) {
            atTopRounded.toggle()
        } completion: {
            isAnimating = false
        }
    }
}

#Preview("Pausable Animation") {
    PausableAnimationExampleView()
}

extension Animation {
    static func pausable(_ base: Animation) -> Animation {
        Animation(PausableAnimation(base: base))
    }
}

// MARK: - Pausable State

private struct PausableState<Value: VectorArithmetic>: AnimationStateKey {
    var paused = false
    var pauseTime: TimeInterval = 0.0

    static var defaultValue: Self { .init() }
}

extension AnimationContext {
    fileprivate var pausableState: PausableState<Value> {
        get { state[PausableState<Value>.self] }
        set { state[PausableState<Value>.self] = newValue }
    }
}

// MARK: - Pausable Animation

struct PausableAnimation: CustomAnimation {
    let base: Animation

    func animate<V>(value: V, time: TimeInterval, context: inout AnimationContext<V>) -> V? where V : VectorArithmetic {
        let paused = context.environment.animationPaused

        let pausableState = context.pausableState
        var pauseTime = pausableState.pauseTime
        if pausableState.paused != paused {
            pauseTime = time - pauseTime
            context.pausableState = PausableState(paused: paused, pauseTime: pauseTime)
        }

        let effectiveTime = paused ? pauseTime : time - pauseTime
        return base.animate(value: value, time: effectiveTime, context: &context)
    }
}

// MARK: - Pausable Environment Key

fileprivate struct AnimationPausedKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    fileprivate var animationPaused: Bool {
        get { self[AnimationPausedKey.self] }
        set { self[AnimationPausedKey.self] = newValue }
    }
}
