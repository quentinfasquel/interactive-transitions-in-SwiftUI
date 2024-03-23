//
//  Button+SystemImage.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 26/03/2024.
//

import SwiftUI

struct SystemImage: View {
    var systemName: String
    var width: CGFloat

    var body: some View {
        Image(systemName: systemName)
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .frame(width: width, height: width)
    }

    fileprivate init(systemName: String, width: CGFloat = 44) {
        self.systemName = systemName
        self.width = width
    }
}

extension Button where Label == SystemImage {
    init(systemImage: String, action: @escaping () -> Void) {
        self.init(action: action, label: {
            SystemImage(systemName: systemImage)
        })
    }
}
