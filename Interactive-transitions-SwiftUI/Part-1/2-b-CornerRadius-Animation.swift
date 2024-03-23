//
//  2-b-CornerRadius-Animation.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

///
/// Check that animating a corner radius, without the need of a transition, works fine
///
struct CornerRadiusAnimationExampleView: View {
    @State private var isRounded: Bool = true
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            RoundedRectangle(cornerRadius: isRounded ? 40 : 0)
                .fill(.yellow)
                .aspectRatio(contentMode: .fit)
                .frame(width: 200)
        }
        .onTapGesture {
            withAnimation(.spring) {
                isRounded.toggle()
            }
        }
    }
}

#Preview("Corner Radius Animation") {
    CornerRadiusAnimationExampleView()
}
