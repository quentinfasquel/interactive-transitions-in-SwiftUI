//
//  4-a-MatchedGeometry-Transition.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 23/03/2024.
//

import SwiftUI

struct NavigationMatchedGeometryExampleView: View {
    @Namespace private var namespace
    @State private var selection: GeometryID?
    @State private var isPushed: Bool = false

    var body: some View {
        NavigationStack {
            RootView(namespace: namespace, selection: $selection, isPushed: $isPushed)
                .navigationDestination(isPresented: $isPushed) {
                    if let selection {
                        DetailView(namespace: namespace, geometryId: selection)
                    }
                }
        }
    }
}


// MARK: - Root View

fileprivate let colors = [Color.yellow, .green, .blue, .purple]

fileprivate struct RootView: View {
    var namespace: Namespace.ID
    @Binding var selection: GeometryID?
    @Binding var isPushed: Bool

    var body: some View {
        VStack {
            ForEach(0..<4) { index in
                let geometryId = GeometryID.rect(index)
                Button {
                    selection = geometryId
                    isPushed = true
                } label: {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(colors[index])
                        .matchedGeometryEffect(id: geometryId, in: namespace)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 32)
        .navigationTitle("Root View")
    }
}

// MARK: - Detail View

fileprivate struct DetailView: View {
    var namespace: Namespace.ID
    var geometryId: GeometryID

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 0)
                .foregroundStyle(colors[geometryId.index])
                .matchedGeometryEffect(id: geometryId, in: namespace)
                .aspectRatio(2, contentMode: .fit)
//                .ignoresSafeArea()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Detail View")
//        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview("MatchedGeometryEffect + Navigation") {
    NavigationMatchedGeometryExampleView()
}

// MARK: - Identifiers

fileprivate enum GeometryID: Hashable {
    case rect(Int)
    var index: Int {
        if case .rect(let int) = self {
            return int
        }
        return 0
    }
}
