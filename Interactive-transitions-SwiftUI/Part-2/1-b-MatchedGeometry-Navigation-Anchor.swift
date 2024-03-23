//
//  1-b-MatchedGeometry-Navigation-Anchor.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

fileprivate let rectColor: Color = .yellow

struct NavigationMatchedAnchorExampleView: View {
    @State private var selection: GeometryID?
    @State private var transitionState = TransitionState()

    var body: some View {
        NavigationStack {
            RootView(selection: $selection, transitionState: $transitionState)
                .navigationDestination(isPresented: $transitionState.isPushed) {
                    if let selection {
                        DetailView(geometry: selection, transitionState: $transitionState)
                    }
                }
        }
        .overlayPreferenceValue(GeometryBoundsPreferenceKey.self) { anchors in
            if let selection, let anchor = anchors[selection] {
                RoundedRectangle(cornerRadius: transitionState.isFinished ? 0 : 12)
                    .foregroundStyle(colors[selection.index])
                    .matchGeometryAnchor(anchor)
                    .opacity(transitionState.isFinished ? 0 : 0.85)
                    .allowsHitTesting(false)
                    .animation(.default, value: transitionState.isFinished)
                    .id(self.selection)
            }
        }
    }
}


// MARK: - Root View

fileprivate let colors = [Color.yellow, .green, .blue, .purple]

fileprivate struct RootView: View {
    @Binding var selection: GeometryID?
    @Binding var transitionState: TransitionState
    var body: some View {
        VStack {
            ForEach(0..<4) { index in
                let geometry = GeometryID.rect(index)
                Button {
                    selection = .rect(index)
                    transitionState.isPushed = true
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(colors[index])
                        .geometryAnchor(geometry, isVisible: selection != geometry)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 200)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 32)
        .navigationTitle("Root View")
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transitionState.isFinished = false
                selection = nil
            }
        }
    }
}

// MARK: - Detail View

fileprivate struct DetailView: View {
    var geometry: GeometryID
    @Binding var transitionState: TransitionState
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: transitionState.isFinished ? 0 : 12)
                .foregroundStyle(colors[geometry.index])
                .aspectRatio(2, contentMode: .fit)
                .geometryAnchor(
                    geometry,
                    isActive: transitionState.isPushed,
                    isVisible: transitionState.isFinished
                )
                .frame(maxHeight: .infinity, alignment: .top)
//                .ignoresSafeArea()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(title)
//        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    transitionState.isPushed = false
                    transitionState.isFinished = false
                } label: {
                    dismissButton
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                transitionState.isFinished = true
            }
        }
    }

    var dismissButton: some View {
        Image(systemName: "xmark.circle.fill")
            .resizable()
            .symbolRenderingMode(.hierarchical)
            .frame(width: 32, height: 32)
    }

    var title: String {
        return "Detail View"
    }
}

// MARK: - Previews

#Preview("Matched Anchor + Navigation") {
    NavigationMatchedAnchorExampleView()
}

// MARK: - Preference Key & View Modifiers

fileprivate enum GeometryID: Hashable {
    case rect(Int)
    var index: Int {
        if case .rect(let int) = self {
            return int
        }
        return 0
    }
}

fileprivate enum GeometryBoundsPreferenceKey: PreferenceKey {
    typealias Value = [GeometryID: Anchor<CGRect>]
    static var defaultValue: Value = [:]
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

struct TransitionState {
    var isPushed: Bool = false
    var isFinished: Bool = false
}

fileprivate extension View {

    func geometryAnchor(_ geometry: GeometryID, isActive: Bool = true, isVisible: Bool) -> some View {
        anchorPreference(key: GeometryBoundsPreferenceKey.self, value: .bounds) { anchor in
            isActive ? [geometry: anchor] : [:]
        }.opacity(isVisible ? 1 : 0)
    }

    @ViewBuilder func matchGeometryAnchor(_ anchor: Anchor<CGRect>) -> some View {
        GeometryReader { geometry in
            self.frame(width: geometry[anchor].width, height: geometry[anchor].height)
                .offset(x: geometry[anchor].minX, y: geometry[anchor].minY)
                .animation(.snappy, value: geometry[anchor])
        }
    }
}
