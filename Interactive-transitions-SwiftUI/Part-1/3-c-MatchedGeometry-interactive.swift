//
//  3-b-MatchedGeometry-isSource.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

///
/// This example demonstrate how to use anchor preferences to mimic
/// `matchedGeometryEffect` while applying a gesture to interpolate the geometry.
///
struct InteractiveAnchorPreferenceExampleView: View {
    private let strokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 8])

    @Namespace private var namespace
    @State private var atTop: Bool = false
    @State private var progress: CGFloat = 0

    let largeCornerRadius = CGFloat(100)
    let smallCornerRadius = CGFloat(75)

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: largeCornerRadius)
                .stroke(.white, style: strokeStyle)
                .frame(width: 200, height: 200)
                .anchorPreference(key: CircleBoundsPreferenceKey.self, value: .bounds) { anchor in
                    [.topCircle: anchor]
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            RoundedRectangle(cornerRadius: smallCornerRadius)
                .stroke(.white, style: strokeStyle)
                .frame(width: 130, height: 130)
                .anchorPreference(key: CircleBoundsPreferenceKey.self, value: .bounds) { anchor in
                    [.bottomCircle: anchor]
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .overlayPreferenceValue(CircleBoundsPreferenceKey.self) { value in
            if let sourceAnchor = value[atTop ? GeometryID.topCircle : .bottomCircle],
               let destinationAnchor = value[atTop ? GeometryID.bottomCircle : .topCircle] {
                GeometryReader { geometry in
                    let sourceFrame = geometry[sourceAnchor]
                    let destinationFrame = geometry[destinationAnchor]
                    let dw = destinationFrame.width - sourceFrame.width
                    let dh = destinationFrame.height - sourceFrame.height
                    let dx = destinationFrame.midX - sourceFrame.midX
                    let dy = destinationFrame.midY - sourceFrame.midY
                    let sourceCornerRadius = atTop ? largeCornerRadius : smallCornerRadius
                    let destinationCornerRadius = atTop ? smallCornerRadius : largeCornerRadius
                    let adaptiveCornerRadius = sourceCornerRadius - progress * (sourceCornerRadius - destinationCornerRadius)
                    RoundedRectangle(cornerRadius: adaptiveCornerRadius)
                        .foregroundStyle(.red)
                        .frame(
                            width: sourceFrame.width + progress * dw,
                            height: sourceFrame.height + progress * dh
                        )
                        .position(
                            x: sourceFrame.midX + progress * dx,
                            y: sourceFrame.midY + progress * dy
                        )
                        .toggleDragGesture(
                            value: $atTop,
                            progress: $progress,
                            sourceFrame: sourceFrame,
                            destinationFrame: destinationFrame
                        )
                }
            }
        }
        .onTapGesture {
            withAnimation(.smooth) {
                atTop.toggle()
            }
        }
    }
}

// MARK: - Preference Key

fileprivate enum GeometryID: Hashable {
    case topCircle, bottomCircle
}

fileprivate enum CircleBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: [GeometryID: Anchor<CGRect>] = [:]
    static func reduce(value: inout [GeometryID : Anchor<CGRect>], nextValue: () -> [GeometryID : Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - ToggleDragGesture

fileprivate extension View {
    func toggleDragGesture(
        value: Binding<Bool>,
        progress: Binding<CGFloat>,
        sourceFrame: CGRect,
        destinationFrame: CGRect
    ) -> some View {
        modifier(ToggleDragGestureModifier(
            toggleValue: value,
            progress: progress,
            sourceFrame: sourceFrame,
            destinationFrame: destinationFrame
        ))
    }
}

///
/// This view modifier does setup a drag gesture that will track the progress (between [0, 1])
/// of the gesture from a `sourceFrame` to a `destinationFrame`
///
fileprivate struct ToggleDragGestureModifier: ViewModifier {
    @Binding var toggleValue: Bool
    @Binding var progress: CGFloat
    var sourceFrame: CGRect
    var destinationFrame: CGRect

    @State private var isDragging: Bool = false

    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                progress = progress(for: value.translation.height)
            }
            .onEnded { value in
                let endProgress = progress(for: value.translation.height)
                isDragging = false
                progress = endProgress > 0.5 ? 1 : 0
            }
    }

    func body(content: Content) -> some View {
        content.gesture(dragGesture)
            .transaction(value: progress) { transaction in
                transaction.isContinuous = isDragging
                transaction.animation = isDragging ? nil: .interpolatingSpring
                if !isDragging, progress == 1 {
                    transaction.addAnimationCompletion {
                        toggleValue.toggle()
                        progress = 0
                    }
                }
            }
    }

    func progress(for offset: CGFloat) -> CGFloat {
        let distance = offset / sourceFrame.union(destinationFrame).height
        if sourceFrame.minY > destinationFrame.maxY {
            return -distance
        } else {
            return distance
        }
    }
}

// MARK: - Previews

#Preview("Interactive (Anchor Preference)") {
    InteractiveAnchorPreferenceExampleView()
}
