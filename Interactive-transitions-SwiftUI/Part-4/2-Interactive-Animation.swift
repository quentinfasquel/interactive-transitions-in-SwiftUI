//
//  AnimationContextExample.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 17/03/2024.
//

import SwiftUI

fileprivate let screenWidth: CGFloat = UIScreen.main.bounds.width

fileprivate enum GeometryID: Hashable {
    case circle, rect
}

@available(iOS 17, *)
struct InteractiveAnimationExampleView: View {
    @Namespace private var namespace
    @State private var isOn: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: isOn ? 42 : 22)
                    .matchedGeometryEffect(id: GeometryID.rect, in: namespace)
                    .aspectRatio(3/2, contentMode: .fit)
                    .foregroundColor(isOn ? .orange : .yellow)

                RoundedRectangle(cornerRadius: 22)
                    .aspectRatio(1, contentMode: .fit)
                    .matchedGeometryEffect(id: GeometryID.circle, in: namespace)
                    .frame(width: 100)
                    .frame(maxWidth: .infinity, alignment: isOn ? .trailing : .leading)
                    .foregroundStyle(isOn ? .purple : .pink)
            }
            .frame(maxHeight: .infinity, alignment: isOn ? .top : .center)
            .padding()

            RoundedRectangle(cornerRadius: isOn ? 42 : 22)
                .stroke(lineWidth: 6)
                .padding(.top, 3)
                .matchedGeometryEffect(id: isOn ? GeometryID.rect : .circle, in: namespace, isSource: false)
                .foregroundStyle(isOn ? .purple : .yellow)

        }
        .background(.black)
        .safeAreaInset(edge: .bottom) {
            VStack {

                Slider(value: $draggingProgress, onEditingChanged: { editing in
                    if editing {
                        startInteractiveTransition()
                        isDragging = true
                    } else {
                        isDragging = false
                        if isReversed {
                            finishInteractiveTransition(cancel: draggingProgress > 0.5)
                            draggingProgress = draggingProgress > 0.5 ? 1 : 0
                        } else {
                            finishInteractiveTransition(cancel: draggingProgress < 0.5)
                            draggingProgress = draggingProgress < 0.5 ? 0 : 1
                        }
                    }
                })
                .animation(isDragging ? .none : .smooth, value: draggingProgress)
                .hidden()

                Button("Toggle") {
                    withAnimation(.smooth(duration: 1)) {
                        isOn.toggle()
                        draggingProgress = isOn ? 1 : 0
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .font(.callout)
                .textCase(.uppercase)
                .buttonBorderShape(.capsule)
                .buttonStyle(.bordered)
            }
            .padding()
        }
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .percentDrivenAnimation(
            isInteractive: isDragging,
            fractionComplete: isReversed ? 1 - draggingProgress : draggingProgress
        )
        .preferredColorScheme(.dark)
    }

    func startInteractiveTransition() {
        if isDecelerating {
            return
        }

        var transaction = Transaction(animation: .percentDrivenInteractive)
        transaction.isContinuous = true
        transaction.tracksVelocity = true
        transaction.disablesAnimations = true
        transaction.addAnimationCompletion(criteria: .logicallyComplete, {
            isDecelerating = false
        })

        isReversed = isOn

        withTransaction(transaction) {
            isOn.toggle()
        }
    }

    func finishInteractiveTransition(cancel: Bool) {
        if cancel {
            var transaction = Transaction(animation: .interpolatingSpring)
            withTransaction(transaction) {
                isOn.toggle()
            }
            transaction.addAnimationCompletion(criteria: .logicallyComplete, {
                isDecelerating = false
            })
        }
    }

    // MARK: Drag Gesture

    @State private var isDragging: Bool = false
    @State private var isDecelerating: Bool = false
    @State private var isReversed: Bool = false
    @State private var draggingProgress: CGFloat = 0

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isDragging {
                    isDragging = true
                    DispatchQueue.main.async {
                        startInteractiveTransition()
                    }
                }

                let draggingOffset = value.translation.width
                let progress = draggingOffset / screenWidth
                if isReversed {
                    draggingProgress = 1 + progress
                } else {
                    draggingProgress = progress
                }
            }
            .onEnded { value in
                isDecelerating = true
                isDragging = false
                let draggingOffset = value.startLocation.x + value.translation.width
//                let draggingOffset = (isReversed ? 1 : 0) + value.translation.width
                let endProgress = draggingOffset / screenWidth
                if isReversed {
                    finishInteractiveTransition(cancel: endProgress > 0.5)
                    draggingProgress = endProgress > 0.5 ? 1 : 0
                } else {
                    finishInteractiveTransition(cancel: endProgress < 0.5)
                    draggingProgress = endProgress < 0.5 ? 0 : 1
                }
            }
    }
}


// MARK: -

@available(iOS 17, *)
struct PercentDrivenInteractiveAnimation: CustomAnimation {
    let id = UUID()
    var completionSpring: Spring = .snappy

    func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V : VectorArithmetic {

        let interactionContext = context.environment.percentDrivenAnimation
        var percentDrivenState = context.percentDrivenState

        defer {
            percentDrivenState.previousTime = time
            context.percentDrivenState = percentDrivenState
        }

        // Base animation
        if interactionContext.isInteractive {
            if !percentDrivenState.isInteractive {
                percentDrivenState.isInteractive = true
                percentDrivenState.resumeValue = percentDrivenState.value
            }

            let targetValue = percentDrivenState.resumeValue
                + value.scaled(by: interactionContext.fractionComplete)
            percentDrivenState.value = targetValue
            return targetValue
        } else {
            if percentDrivenState.isInteractive {
                // Animation interaction ended, continue with animation
                percentDrivenState.interactionEndTime = time
                percentDrivenState.isInteractive = false
            }

            completionSpring.update(
                value: &percentDrivenState.value,
                velocity: &percentDrivenState.velocity,
                target: value,
                deltaTime: time - percentDrivenState.previousTime
            )

            if time - percentDrivenState.interactionEndTime > completionSpring.settlingDuration {
                return nil
            }
        }


        return percentDrivenState.value
    }
}

@available(iOS 17, *)
extension Animation {
    static var percentDrivenInteractive: Animation {
        Animation(PercentDrivenInteractiveAnimation())
    }
}

// MARK: - Pausable State

private struct PercentDrivenAnimationState<Value: VectorArithmetic>: AnimationStateKey {
    static var defaultValue: Self { .init() }

    var isInteractive = true
    var interactionEndTime: TimeInterval = 0
    var previousTime: TimeInterval = 0
    var velocity: Value = .zero
    var value: Value = .zero

    var resumeValue: Value = .zero
//    var interruptTime: TimeInterval?
}

@available(iOS 17, *)
extension AnimationContext {
    fileprivate var percentDrivenState: PercentDrivenAnimationState<Value> {
        get { state[PercentDrivenAnimationState<Value>.self] }
        set { state[PercentDrivenAnimationState<Value>.self] = newValue }
    }
}

// MARK: - Environment Values

struct PercentDrivenAnimationContext {
    var isInteractive: Bool = false
    var fractionComplete: CGFloat = 0
}

fileprivate enum PercentDrivenAnimationEnvironmentKey: EnvironmentKey {
    static var defaultValue = PercentDrivenAnimationContext()
}

fileprivate extension EnvironmentValues {
    var percentDrivenAnimation: PercentDrivenAnimationContext {
        get { self[PercentDrivenAnimationEnvironmentKey.self] }
        set { self[PercentDrivenAnimationEnvironmentKey.self] = newValue }
    }
}

extension View {
    func percentDrivenAnimation(isInteractive: Bool, fractionComplete: CGFloat) -> some View {
        environment(\.percentDrivenAnimation.isInteractive, isInteractive)
            .environment(\.percentDrivenAnimation.fractionComplete, fractionComplete)
    }
}


enum AnimationIsInteractiveEnvironmentKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

enum AnimationProgressEnvironmentKey: EnvironmentKey {
    static var defaultValue: CGFloat = 0
}

extension EnvironmentValues {
    var animationIsInteractive: Bool {
        get { self[AnimationIsInteractiveEnvironmentKey.self] }
        set { self[AnimationIsInteractiveEnvironmentKey.self] = newValue }
    }

    var animationProgress: CGFloat {
        get { self[AnimationProgressEnvironmentKey.self] }
        set { self[AnimationProgressEnvironmentKey.self] = newValue }
    }
}

// MARK: - Previews

@available(iOS 17, *)
#Preview("Pausable Animation") {
    PausableAnimationExampleView()
}

@available(iOS 17, *)
#Preview("Interactive Progress") {
    InteractiveAnimationExampleView()
}
