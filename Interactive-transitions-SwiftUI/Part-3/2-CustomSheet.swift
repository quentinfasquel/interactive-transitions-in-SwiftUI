//
//  2-CustomSheet.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 29/03/2024.
//

import SwiftUI

fileprivate let debugSpeed: CGFloat = 1

fileprivate enum GeometryID: Hashable {
    case topSquare, bottomSquare, none
}

struct CustomSheetExampleView: View {
    @State var unmatchGeometryWhileDragging: Bool = false

    @Namespace private var namespace
    @State private var selection: GeometryID = .none
    @State private var isPresented: Bool = false
    @State private var isDragging: Bool = false
    @State private var matchesDestinationGeometry: Bool = false

    let cornerRadius: CGFloat = 32

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
                

            VStack(spacing: 32) {
                RoundedRectangle(cornerRadius: cornerRadius)
//                    .overlayImage(Image(.imageDune))
                    .foregroundStyle(.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .matchedGeometryEffect(
                        id: GeometryID.topSquare,
                        in: namespace,
                        isSource: !matchesDestinationGeometry || (unmatchGeometryWhileDragging && isDragging)
                    )
                    .frame(width: 200, height: 200)
                    .makeButton { selection = .topSquare; isPresented = true } overlay: {
                        Text("Present sheet")
                            .foregroundStyle(.white)
                    }

                RoundedRectangle(cornerRadius: cornerRadius)
//                    .overlayImage(Image(.imageOcean))
                    .foregroundStyle(.yellow)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .matchedGeometryEffect(
                        id: GeometryID.bottomSquare,
                        in: namespace,
                        isSource: !matchesDestinationGeometry || (unmatchGeometryWhileDragging && isDragging)
                    )
                    .frame(width: 200, height: 200)
                    .makeButton { selection = .bottomSquare; isPresented = true } overlay: {
                        Text("Present sheet")
                            .foregroundStyle(.white)
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .overlay(alignment: .topTrailing) {
                Toggle(isOn: $unmatchGeometryWhileDragging) {
                    Text("Unmatch while dragging")
                        .textCase(.uppercase)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .frame(alignment: .trailing)
                .tint(.pink)
                .padding(.horizontal, 32)
            }
        }
        .customSheet(
            isPresented: $isPresented,
            isPresentedGeometryMatched: $matchesDestinationGeometry,
            backgroundStyle: .thinMaterial
        ) {
            VStack(spacing: 32) {
                RoundedRectangle(cornerRadius: 32)
//                    .overlayImage(Image(selection == .topSquare ?.imageDune : .imageOcean))
                    .foregroundStyle(selection == .topSquare ? .cyan : .yellow)
                    .clipShape(RoundedRectangle(cornerRadius: 32))
                    .blur(radius: isDragging ? 10 : 0)
                    .matchedGeometryEffect(
                        id: selection,
                        in: namespace,
                        isSource: matchesDestinationGeometry && (!unmatchGeometryWhileDragging || !isDragging)
                    )
                    .frame(height: 130)

                RedactedTextView()

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical)
        } onStateChanged: { state in
            guard unmatchGeometryWhileDragging else {
                return
            }

            if state.isPresented && !state.isBeingDismissed {
                withAnimation(.interpolatingSpring.speed(debugSpeed)) {
                    isDragging = state.isDragging
                }
            } else {
                isDragging = false
            }
        }
    }
}

#Preview("Custom Sheet") {
    CustomSheetExampleView()
}

//#Preview("Unmatch Geometry While Dragging") {
//    CustomSheetExampleView(unmatchGeometryWhileDragging: true)
//}

// MARK: - Custom Sheet

extension View {
    func customSheet<Content: View, S: ShapeStyle>(
        isPresented: Binding<Bool>,
        isPresentedGeometryMatched: Binding<Bool> = .constant(false),
        backgroundStyle: S,
        @ViewBuilder _ content: @escaping () -> Content,
        onStateChanged: ((CustomSheetState) -> Void)? = nil
    ) -> some View {
        modifier(CustomSheetViewModifier(
            isPresented: isPresented,
            isPresentedGeometryMatched: isPresentedGeometryMatched,
            sheetContent: content(),
            backgroundStyle: backgroundStyle,
            onStateChanged: onStateChanged
        ))
    }
}

struct CustomSheetViewModifier<SheetContent: View, BackgroundStyle: ShapeStyle>: ViewModifier {

    @Binding var isPresented: Bool
    @Binding var isPresentedGeometryMatched: Bool
    var sheetContent: SheetContent
    var backgroundStyle: BackgroundStyle
    var onStateChanged: ((CustomSheetState) -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content

            if isSheetPresented {
                sheetContent
                    .dismissButton(
                        isVisible: $isBeingPresented.not().and($isBeingDismissed.not()),
                        action: dismissSheet
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(edges: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .background(in: RoundedRectangle(cornerRadius: 12))
                    .backgroundStyle(backgroundStyle)
                    .offset(y: 64)
                    .offset(y: animatingOffset)
                    .offset(y: draggingOffset)
                    .transition(.move(edge: .bottom))
                    .gesture(dismissGesture)
                    .transformPreference(CustomSheetStatePreferenceKey.self) { value in
                        value.isDragging = draggingState.isDragging
                        value.isPresented = isSheetPresented
                        value.isBeingDismissed = isBeingDismissed
                    }
            }
        }
        .onChange(of: isPresented, initial: true) { _, newValue in
            if newValue {
                presentSheet()
            } else {
                dismissSheet()
            }
        }
        .onPreferenceChange(CustomSheetStatePreferenceKey.self) { value in
            onStateChanged?(value)
        }
    }

    // MARK: - Dragging & Animating

    private struct DraggingState {
        var isDragging: Bool = false
        var offset: CGFloat = 0
    }

    @GestureState(reset: { value, transaction in
        let progress = abs(value.offset) / UIScreen.main.bounds.height
        transaction.animation = progress < 0.5 ? .interpolatingSpring : nil
    })
    private var draggingState = DraggingState()
    private var draggingOffset: CGFloat {
        draggingState.offset
    }

    @State private var animatingOffset: CGFloat = 0

    private var dismissGesture: some Gesture {
        DragGesture()
            .updating($draggingState) { value, state, transaction in
                transaction.animation = .interactiveSpring
                state.isDragging = true
                state.offset = value.translation.height
            }.onEnded { value in
                let progress = abs(value.translation.height) / UIScreen.main.bounds.height
                guard progress > 0.5 else { return }

                animatingOffset = value.translation.height
                dismissSheet()
            }
    }

    // MARK: - Presentation / Dismissal

    @State private var isSheetPresented: Bool = false
    @State private var isBeingPresented: Bool = false
    @State private var isBeingDismissed: Bool = false

    func presentSheet() {
        isBeingPresented = true
        withAnimation(.interpolatingSpring.speed(debugSpeed)) {
            isSheetPresented = true
        } completion: {
            isBeingPresented = false
        }
        withAnimation(.smooth.speed(debugSpeed)) {
            isPresentedGeometryMatched = true
        }
    }

    func dismissSheet() {
        guard isSheetPresented else {
            return
        }

        isBeingDismissed = true
        withAnimation(.interpolatingSpring.speed(debugSpeed)) {
            animatingOffset = UIScreen.main.bounds.height
        } completion: {
            isBeingDismissed = false
            didDismissSheet()
        }
        withAnimation(.smooth.speed(debugSpeed)) {
            isPresentedGeometryMatched = false
        }
    }

    func didDismissSheet() {
        animatingOffset = 0
        isPresentedGeometryMatched = false
        isPresented = false
        isSheetPresented = false
    }
}

struct CustomSheetState: Hashable {
    var isPresented: Bool = false
    var isDragging: Bool = false
    var isBeingDismissed: Bool = false
}

enum CustomSheetStatePreferenceKey: PreferenceKey {
    static var defaultValue: CustomSheetState = .init()
    static func reduce(value: inout CustomSheetState, nextValue: () -> CustomSheetState) {
        value = nextValue()
    }
}
