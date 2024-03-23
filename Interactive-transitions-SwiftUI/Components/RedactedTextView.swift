//
//  RedactedTextView.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 30/03/2024.
//

import SwiftUI

struct RedactedTextView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("""
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
Pellentesque pulvinar pellentesque habitant morbi tristique senectus et netus.
Aliquet risus feugiat in ante metus.
""")
            Text("""
Aliquet risus feugiat in ante metus.
Pellentesque pulvinar pellentesque habitant morbi tristique senectus et netus.
""")
            Text("""
Pellentesque pulvinar pellentesque habitant morbi tristique senectus et netus.
Aliquet risus feugiat in ante metus.
""")
        }
        .frame(maxWidth: .infinity)
        .redacted(reason: .placeholder)
    }
}

#Preview {
    RedactedTextView()
        .padding()
}
