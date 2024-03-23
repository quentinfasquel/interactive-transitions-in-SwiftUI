//
//  2-c-CornerRadius-MatchedGeometry.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

///
/// Discover the use of *environment values* to animate properties through a *transition*
///
struct CornerRadiusMatchedGeometryExampleView: View {
    @State private var showDetailView: Bool = false
    @Namespace private var namespace

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if showDetailView {
                VStack {
                    EnvironmentRoundedRectangle()
                        .foregroundStyle(.yellow)
                        .matchedGeometryEffect(id: "rect", in: namespace)
                        .aspectRatio(2, contentMode: .fit)

                    Spacer()
                }
                .zIndex(1)
                .transition(.environmentCornerRadius(identity: 0, active: 40))
//                .ignoresSafeArea()
            } else {
                VStack {
                    Spacer()
                    EnvironmentRoundedRectangle()
                        .foregroundStyle(.green)
                        .matchedGeometryEffect(id: "rect", in: namespace)
                        .frame(width: 200, height: 200)
                    Spacer()
                }
                .zIndex(1)
                .transition(.environmentCornerRadius(identity: 40, active: 0))
            }
        }
        .onTapGesture {
            withAnimation(.snappy.speed(0.2)) {
                showDetailView.toggle()
            }
        }
    }
}

#Preview("Corner Radius Transition") {
    CornerRadiusMatchedGeometryExampleView()
}

// MARK: - Corner Radius Environment Value

public struct CornerRadiusKey: EnvironmentKey {
    public static let defaultValue: Double = 0
}

extension EnvironmentValues {
    var cornerRadius: Double {
        get { return self[CornerRadiusKey.self] }
        set { self[CornerRadiusKey.self] = newValue }
    }
}

/// There doesn't seem to be a need for `Animatable` support
struct CornerRadiusEnvironmentViewModifier: ViewModifier {
    var cornerRadius: Double

    func body(content: Content) -> some View {
        content.environment(\.cornerRadius, cornerRadius)
    }
}

extension AnyTransition {
    static func environmentCornerRadius(identity: Double, active: Double) -> AnyTransition {
        AnyTransition.modifier(
            active: CornerRadiusEnvironmentViewModifier(cornerRadius: active),
            identity: CornerRadiusEnvironmentViewModifier(cornerRadius: identity)
        )
    }
}

struct EnvironmentRoundedRectangle: View {
    @Environment(\.cornerRadius) var cornerRadius: Double

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
    }
}
