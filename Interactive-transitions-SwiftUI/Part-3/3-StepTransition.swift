//
//  Pop-Transition.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 26/03/2024.
//

import SwiftUI

struct NumberScreen: View {
    var namespace: Namespace.ID
    var number: Int
    var color: Color
    var body: some View {
        RoundedRectangle(cornerRadius: 40)
            .foregroundStyle(.black)
            .frame(width: 200, height: 200)
//            .matchedGeometryEffect(id: "number", in: namespace)
            .overlay {
                Text("\(number)")
                    .font(.system(size: 64, weight: .bold))
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: number.isMultiple(of: 2) ? .center : .top
            )
            .background(color)
    }
}

enum Step: Int, Hashable, CaseIterable {
    case zero = 0, one, two, three
}

struct OffsetModifier: ViewModifier {
    var x: CGFloat
    @Binding var draggingOffset: CGFloat
    func body(content: Content) -> some View {
        content.offset(x: x + draggingOffset)
    }
}
// 1- show structure, caseiterable

fileprivate let screenWidth = UIScreen.main.bounds.width

struct StepTransitionExampleView: View {
    @Namespace private var namespace
    @State private var currentStep: Step = .zero
    @State private var isBack: Bool = false
    let colors: [Color] = [.yellow, .pink, .purple, .blue]
    var body: some View {
        ZStack {

            if dragging.offsetX > 0, let previous = currentStep.previous {
                NumberScreen(
                    namespace: namespace,
                    number: previous.rawValue,
                    color: colors[previous.rawValue]
                )
                .offset(x: dragging.offsetX - screenWidth)
                .transition(.identity)
//                .onDisappear {
//                    draggingEndState.progress = 0
//                }
//                .id("\(previous)-\(true)")
            }

            if dragging.offsetX < 0, let next = currentStep.next {
                NumberScreen(
                    namespace: namespace,
                    number: next.rawValue,
                    color: colors[next.rawValue]
                )
                .offset(x: dragging.offsetX + screenWidth)
                .transition(.identity)
//                .onDisappear {
//                    draggingEndState.progress = 0
//                }
//                .id("\(next)-\(false)")
            }

            NumberScreen(
                namespace: namespace,
                number: currentStep.rawValue,
                color: colors[currentStep.rawValue]
            )
            .offset(x: isDragging ? dragging.offsetX : 0, y: 0)
            .id("\(currentStep)-\(isBack)")
            .transition(.asymmetric(
                insertion: isBack
                ? .offset(x: -screenWidth + draggingEndState.offsetX)
                : .offset(x: screenWidth + draggingEndState.offsetX),
                removal: isBack ? .offset(x: screenWidth) : .offset(x: -screenWidth)
            ))
        }
        .overlay(alignment: .top) {
            HStack {
                Button(systemImage: "chevron.left.circle.fill") { goBack() }
                Spacer()
                Button(systemImage: "chevron.right.circle.fill") { goNext() }
            }
            .padding()
            .foregroundStyle(.black)
        }
        .onChange(of: dragging.progress) { newValue in
            draggingEndState.distance = screenWidth
            draggingEndState.progress = newValue
        }
        .gesture(DragGesture().updating($dragging) { value, state, transaction in
            transaction.animation = .interactiveSpring
            state.distance = screenWidth
            state.progress = value.translation.width / screenWidth
        }.onChanged { value in
//            draggingEndState.progress = 0
            isDragging = true
            isBack = value.translation.width > 0
        }.onEnded { value in
            let progress = value.translation.width / screenWidth

            isDragging = false
            isAnimating = true
            draggingEndState.distance = screenWidth
            draggingEndState.progress = progress
            if progress > 0 {
                if let previous = currentStep.previous {
                    withAnimation(.interpolatingSpring) {
                        currentStep = previous
                    }
                }
            } else if progress < 0 {
                if let next = currentStep.next {
                    withAnimation(.interpolatingSpring) {
                        currentStep = next
                    }
                }
            }
        })
    }

    struct DraggingState {
        var distance: CGFloat = 0
        var progress: CGFloat = 0
        var offsetX: CGFloat {
            progress * distance
        }
    }

    @State private var isAnimating = false
    @State private var isDragging = false
    @State private var draggingEndState = DraggingState()
    @GestureState(reset: { value, transaction in
        transaction.animation = .linear
    }) private var dragging = DraggingState()

    func goBack(animated: Bool = true) {
        if !isBack {
            isBack = true
//            DispatchQueue.main.async {
                goBack(animated: animated)
//            }
        } else if let previous = currentStep.previous {
            if animated {
                withAnimation(.interpolatingSpring) {
                    currentStep = previous
                }
            } else {
                currentStep = previous
            }
        }
    }
    func goNext(animated: Bool = true) {
        if isBack {
            isBack = false
//            DispatchQueue.main.async {
                goNext(animated: animated)
//            }
        } else if let next = currentStep.next {
            if animated {
                withAnimation(.interpolatingSpring) {
                    currentStep = next
                }
            } else {
                currentStep = next
            }
        }
    }

}

#Preview {
    StepTransitionExampleView()
}

/*
struct Pop_Transition: View {
//    @State private var currentIndex: Int = 0
//    var canPush: Bool { currentIndex < 1 }
//    var canPop: Bool { currentIndex > 0 }
    @State private var isPushed: Bool = false

    var body: some View {
        ZStack {
            if !isPushed {
                screen0
                    .transition(.offset(x: -100))
            } else {
                screen1
                    .zIndex(1)
                    .transition(.move(edge: .trailing))
            }
        }
        .onTapGesture {
            withAnimation {
                isPushed.toggle()
            }
        }
    }

    var screen0: some View {
        NumberScreen(number: 0, color: .yellow)
    }

    var screen1: some View {
        NumberScreen(number: 1, color: .pink)
    }

}

//#Preview {
//    Pop_Transition()
//}

*/
