//
//  3-a-MatchedGeometry-isSource.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

///
/// This example demonstrate a simple use of the matchedGeometryEffect parameter `isSource`.,
///
struct MatchedGeometrySourceExampleView: View {
    private let strokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 8])

    @Namespace private var namespace
    @State private var atTop: Bool = false

    var body: some View {
        VStack {
            Circle()
                .stroke(.white, style: strokeStyle)
                .frame(width: 200)
                .matchedGeometryEffect(id: GeometryID.topCircle, in: namespace)
                .frame(maxHeight: .infinity)
            Circle()
                .stroke(.white, style: strokeStyle)
                .frame(width: 130)
                .matchedGeometryEffect(id: GeometryID.bottomCircle, in: namespace)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .overlay {
            Circle()
                .fill(.white)
                .matchedGeometryEffect(
                    id: atTop ? GeometryID.topCircle : .bottomCircle,
                    in: namespace,
                    anchor: .center,
                    isSource: false
                )
        }
        .onTapGesture {
            withAnimation(.smooth) {
                atTop.toggle()
            }
        }
    }
}

// MARK: - Anchor Preference Example

fileprivate enum GeometryID: Hashable {
    case topCircle, bottomCircle
}

fileprivate enum CircleBoundsPreferenceKey: PreferenceKey {
    typealias Value = [GeometryID: Anchor<CGRect>]
    static var defaultValue: Value = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

///
/// This example demonstrate how to use anchor preferences to mimic matchedGeometryEffect.
///
struct AnchorPreferenceExampleView: View {
    private let strokeStyle = StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 8])

    @Namespace private var namespace
    @State private var atTop: Bool = false

    var body: some View {
        VStack {
            Circle()
                .stroke(.white, style: strokeStyle)
                .frame(width: 200)
                .anchorPreference(key: CircleBoundsPreferenceKey.self, value: .bounds) { anchor in
                    [.topCircle: anchor]
                }
                .frame(maxHeight: .infinity)

            Circle()
                .stroke(.white, style: strokeStyle)
                .frame(width: 130)
                .anchorPreference(key: CircleBoundsPreferenceKey.self, value: .bounds) { anchor in
                    [.bottomCircle: anchor]
                }
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .overlayPreferenceValue(CircleBoundsPreferenceKey.self) { value in
            if let anchor = value[atTop ? GeometryID.topCircle : .bottomCircle] {
                GeometryReader { geometry in
                    let rect = geometry[anchor]
                    Circle()
                        .fill(.white)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
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

// MARK: - Previews

#Preview("Matched Geometry: isSource") {
    MatchedGeometrySourceExampleView()
}

#Preview("Anchor Preference") {
    AnchorPreferenceExampleView()
}
