//
//  Color_mix.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 31/03/2024.
//

import SwiftUI

extension Color {
    func mix(with target: Color, amount: CGFloat) -> Color {
        Color(NativeColor(self).mix(with: NativeColor(target), amount: amount))
    }
}

#if canImport(UIKit)
typealias NativeColor = UIColor
#elseif canImport(AppKit)
typealias NativeColor = NSColor
#endif

extension NativeColor {
    func mix(with target: NativeColor, amount: CGFloat) -> Self {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        target.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return Self(
            red: r1 * (1.0 - amount) + r2 * amount,
            green: g1 * (1.0 - amount) + g2 * amount,
            blue: b1 * (1.0 - amount) + b2 * amount,
            alpha: a1
        )
    }
}
