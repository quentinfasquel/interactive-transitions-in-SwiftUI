//
//  3-CustomNavigationStack.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 15/04/2024.
//

import CustomNavigationStack
import SwiftUI


struct NavigationStackExampleView: View {
    var useCustomNavigationPath: Bool

    private let colors: [Color] = [.blue, .purple, .red, .orange, .yellow, .green]

    @State private var path = NavigationPath()
    @State private var customPath = CustomNavigationPath()

    var body: some View {
        if useCustomNavigationPath {
            CustomNavigationStack(path: $customPath) {
                ColorView(color: colors[0], index: 0, next: pushNextColor(0))
                    .customNavigationDestination(for: Int.self) { index in
                        ColorView(color: colors[index], index: index, next: pushNextColor(index))
                    }
                    .customNavigationDestination(for: String.self) { string in
                        Text("HELLO")
                            .backgroundStyle(.yellow)
                    }
            }
            .tint(.white)
        } else {
            NavigationStack(path: $path) {
                ColorView(color: colors[0], index: 0, next: pushNextColor(0))
                    .navigationDestination(for: Int.self) { index in
                        ColorView(color: colors[index], index: index, next: pushNextColor(index))
                    }
                    .navigationDestination(for: String.self) { string in
                        Text("HELLO")
                            .backgroundStyle(.yellow)
                    }
            }
            .tint(.white)
        }
    }

    func pushNextColor(_ current: Int) -> (() -> Void)? {
        if useCustomNavigationPath {
            return current + 1 < colors.count ? { customPath.append(current + 1) } : { customPath.append("BLOP") }
        } else {
            return current + 1 < colors.count ? { path.append(current + 1) } : { path.append("BLOP") }
        }
    }
}

#Preview("Custom") {
    NavigationStackExampleView(useCustomNavigationPath: true)
}

#Preview("Native") {
    NavigationStackExampleView(useCustomNavigationPath: false)
}

// MARK: - Color View

struct ColorView: View {
    var color: Color
    var index: Int
    var next: (() -> Void)?
    var body: some View {
        ZStack {
            color.ignoresSafeArea()
            Image(systemName: "\(index).circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(.tint)
                .padding(32)
        }
        .navigationTitle("\(color.description)")
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            if let next {
                nextButton(next)
            } else {
                nextButton().tag("disableed").disabled(true)
            }
        }
        .animation(.default, value: next == nil)
//        .onAppear { print("on appear", color) }
//        .onDisappear { print("on disappear", color) }
    }

    func nextButton(_ action: @escaping () -> Void = {}) -> some View {
        Button("Next", action: action)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.capsule)
            .foregroundStyle(.black, .white)
            .padding(16)
    }
}
