//
//  3-b-Transaction-MatchedGeometry.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 14/04/2024.
//

import SwiftUI

///
/// Another example of the matchedGeometryEffect parameter `isSource`
/// in use with transaction to setup a delay.
///
struct TransactionMatchedGeometryExampleView: View {
    @Namespace private var namespace

    let firstColor: Color = .purple
    let colors: [Color] = [.blue, .cyan, .green, .yellow, .orange, .red, .pink]

    var element: some View {
        Circle().frame(width: 80)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {

                element.foregroundStyle(firstColor)
                    .matchedGeometryEffect(id: "element", in: namespace, isSource: true)
                    .offset(
                        x: initialPosition.x + draggingOffset.x,
                        y: initialPosition.y + draggingOffset.y
                    )
                    .gesture(dragGesture)

                ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                    element.foregroundStyle(colors[index])
                        .offset(y: (80 + 10) * CGFloat(index + 1))
                        .allowsHitTesting(false)
                        .matchedGeometryEffect(id: "element", in: namespace, isSource: false)
                        .transaction {
                            $0.animation = $0.animation?.delay(CGFloat(index + 1) * 0.1)
                        }
                }
            }
        }
    }


    @State
    var initialPosition: CGPoint = .zero

    @GestureState(resetTransaction: .init(animation: .interpolatingSpring))
    var draggingOffset: CGPoint = .zero

    var dragGesture: some Gesture {
        DragGesture()
            .updating($draggingOffset) { value, state, transaction in
                transaction.animation = .interpolatingSpring
                transaction.tracksVelocity = true
                state = CGPoint(x: value.translation.width, y: value.translation.height)
            }
            .onEnded { value in
                withAnimation(.interpolatingSpring) {
                    initialPosition = initialPosition.translated(by: value.translation)
                }
            }
    }
}

#Preview {
    TransactionMatchedGeometryExampleView()
}

extension CGPoint {
    func translated(by size: CGSize) -> CGPoint {
        let translation = CGAffineTransform(translationX: size.width, y: size.height)
        return self.applying(translation)
    }
}
