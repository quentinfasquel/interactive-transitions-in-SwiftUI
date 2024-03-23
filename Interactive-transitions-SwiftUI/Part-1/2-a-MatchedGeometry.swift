//
//  2-a-MatchedGeometry.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 08/03/2024.
//

import SwiftUI

///
/// - A simple matched geometry using same color and same cornerRadius
/// - Notice the hidden-glitch before any transition, this is the `zIndex` issue
/// - Try using a different color
/// - Notice that `.transition(.identity)` should be the same as `.transition(.offset(x: 0))`
/// - Try using a different `cornerRadius`, notice it's not working with transitions
///
struct MatchedGeometryExampleView: View {
    @State private var showDetailView: Bool = false
    @Namespace private var namespace

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if showDetailView {
                VStack {
                    RoundedRectangle(cornerRadius: 0)
                        .foregroundStyle(.yellow)
                        .matchedGeometryEffect(id: "rect", in: namespace)
                        .aspectRatio(2, contentMode: .fit)
                    Spacer()
                }
                .ignoresSafeArea()
                .zIndex(1)
            } else {
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundStyle(.yellow)
                        .matchedGeometryEffect(id: "rect", in: namespace)
                        .frame(width: 200, height: 200)
                    Spacer()
                }
                .zIndex(1)
            }
        }
        .onTapGesture {
            withAnimation(.snappy.speed(0.2)) {
                showDetailView.toggle()
            }
        }
    }
}

#Preview("Matched Geometry") {
    MatchedGeometryExampleView()
}

