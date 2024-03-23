//
//  Interactive-Scale-Transition.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

struct ScaleTransitionExample: View {
    @State private var isDragging: Bool = false
    @State private var showsRectangle: Bool = true
    @State private var hidingRectangle: Bool = true
    @State private var progress: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if showsRectangle {
                Rectangle()
                    .fill(.white)
                    .frame(width: 120, height: 120)
                    .zIndex(1)
                    .transition(.scale(progress: $progress))
                    .modifier(ScaleTransitionModifier(progress: $progress, isActive: isDragging))
            }

            draggableOverlay
        }
        .onTapGesture {
            withAnimation {
                showsRectangle.toggle()
            }
        }
    }

    // MARK: - Drag Gesture Handling

    var draggableOverlay: some View {
        GeometryReader { geometry in
            Color.black.opacity(0.1).gesture(dragGesture(in: geometry.frame(in: .local)))
        }
    }

    func dragGesture(in rect: CGRect) -> some Gesture {
        DragGesture()
            .onChanged { value in
                // Handle dragging did start
                if !isDragging {
                    isDragging = true
                    if !showsRectangle {
                        hidingRectangle = false
                        showsRectangle = true
                    } else {
                        hidingRectangle = true
                    }
                }

                // Update dragging progress
                let transaltionX = max(abs(value.translation.width), abs(value.translation.height))
                if hidingRectangle {
                    progress = (rect.width - transaltionX) / rect.width
                } else {
                    progress = transaltionX / rect.width
                }
            }
            .onEnded { value in
                // Handle dragging did end
                withAnimation(.interpolatingSpring) {
                    isDragging = false
                    progress = 0
                    if hidingRectangle {
                        showsRectangle = false
                    }
                }
            }
    }
}

#Preview("Scale Transition") {
    ScaleTransitionExample()
}

#Preview("Custom Navigation Stack") {
    NavigationStackExampleView(useCustomNavigationPath: true)
}

#Preview("Custom Sheet") {
    CustomSheetExampleView()
}

// MARK: - View Modifier & Transition

struct ScaleTransitionModifier: ViewModifier {
    @Binding var progress: CGFloat
    var isActive: Bool = true
    func body(content: Content) -> some View {
        if isActive {
            content.scaleEffect(x: progress, y: progress)
        } else {
            content
        }
    }
}

extension AnyTransition {
    static func scale(progress: Binding<CGFloat>) -> AnyTransition {
        .modifier(
            active: ScaleTransitionModifier(progress: progress),
            identity: ScaleTransitionModifier(progress: .constant(1)))
    }
}
