//
//  3-MatchedGeometryPresentation.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 07/04/2024.
//

// https://github.com/quentinfasquel/swiftui-matched-geometry-presentation
// Check Example/MatchedGeometryPresentationExample.xcodeproj

import MatchedGeometryPresentation
import SwiftUI

enum Icons: String, Hashable {
    case icon1 = "barcode.viewfinder"
    case icon2 = "key.viewfinder"
    case icon3 = "qrcode.viewfinder"
    case icon4 = "location.fill.viewfinder"
}

struct MatchedGeometryPresentationExampleView: View {
    @State private var isPresented: Bool = false
    var spacing: CGFloat = 32
    var body: some View {
        VStack {
            ZStack {
                VStack(spacing: spacing) {
                    HStack(spacing: spacing) {
                        Image(systemName: Icons.icon1.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .matchedGeometrySource(id: Icons.icon1)
                            .frame(width: 100)

                        Image(systemName: Icons.icon2.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .matchedGeometrySource(id: Icons.icon2)
                            .frame(width: 100)
                    }

                    HStack(spacing: spacing) {
                        Image(systemName: Icons.icon3.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .matchedGeometrySource(id: Icons.icon3)
                            .frame(width: 100)

                        Image(systemName: Icons.icon4.rawValue)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundStyle(.white)
                            .matchedGeometrySource(id: Icons.icon4)
                            .frame(width: 100)
                    }
                }
            }
            .padding(32)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .foregroundStyle(.black)
                    .matchedGeometrySource(id: "bg", zIndex: -1)
                    .aspectRatio(contentMode: .fit)
                    .padding()
            }

            Button {
                isPresented.toggle()
            } label: {
                Text("Present")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .matchedGeometryPresentation(isPresented: $isPresented) {
            ModalView(isPresented: $isPresented)
        }
    }
}

// MARK: - Modal View

struct ModalView: View {
    @GestureState var dragging: CGFloat = 0
    @EnvironmentObject private var state: MatchedGeometryState
    @Binding var isPresented: Bool
    var body: some View {
        VStack {
            Button(action: { }) {
                Image(systemName: Icons.icon1.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .zIndex(10)
                    .matchedGeometryDestination(id: Icons.icon1)
                    .frame(width: 130)
            }

            Button(action: { }) {
                Image(systemName: Icons.icon2.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .zIndex(1)
                    .matchedGeometryDestination(id: Icons.icon2)
                    .frame(width: 130)
            }

            Button(action: { }) {
                Image(systemName: Icons.icon3.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .matchedGeometryDestination(id: Icons.icon3)
                    .frame(width: 130)
            }

            Button(action: { }) {
                Image(systemName: Icons.icon4.rawValue)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.white)
                    .matchedGeometryDestination(id: Icons.icon4)
                    .frame(width: 130)
            }
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 25)
                .foregroundStyle(.black)
                .matchedGeometryDestination(id: "bg")
        }
        .overlay(alignment: .topTrailing) {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .resizable()
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            Text("This is a real overFullscreen modal")
                .foregroundStyle(.white)
        }
        .onChange(of: dragging) { newValue in
            state.isDismissInteractive = true
            if newValue > 0 {
                isPresented = false
                state.dismissProgress = newValue
            }
        }
        .gesture(DragGesture(minimumDistance: 0)
            .updating($dragging) { value, state, transaction in
                state = value.translation.height / (UIScreen.main.bounds.height - value.startLocation.y)
            }
            .onEnded { value in
                state.dismissProgress = value.translation.height / (UIScreen.main.bounds.height - value.startLocation.y)
                state.dismissEnded = true
            }
        )
    }
}

// MARK: - Previews

#Preview("Matched Geometry Presentation") {
    MatchedGeometryPresentationExampleView()
}
