//
//  View_overlayImage.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI


struct ImageViewModifier: ViewModifier {
    struct ImageSizePreferenceKey: PreferenceKey {
        typealias Value = [String: Anchor<CGRect>]
        static var defaultValue: [String: Anchor<CGRect>] = [:]
        static func reduce(value: inout Value, nextValue: () -> Value) {
            value.merge(nextValue()) { $1 }
        }
    }

    var image: Image
//    var cornerRadius: CGFloat = 0
    @State private var imageSize: CGSize = .zero

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geometry in
                image.resizable()
                    .scaledToFill()
                    .background(GeometryReader { proxy in
                        Color.clear
                            .onChange(of: proxy.size) { imageSize = $0 }
                            .onAppear { imageSize = proxy.size }

                    })
                    .offset(
                        x: imageSize.width > geometry.size.width ? -(imageSize.width - geometry.size.width) * 0.5 : 0,
                        y: imageSize.height > geometry.size.height ? -(imageSize.height - geometry.size.height) * 0.5 : 0
                    )
            }
//            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        }
    }
}

extension View {
    func overlayImage(_ image: Image) -> some View {
        modifier(ImageViewModifier(image: image))
    }
}
