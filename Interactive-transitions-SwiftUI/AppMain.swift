//
//  AppMain.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 08/03/2024.
//

import SwiftUI

@main
struct AppMain: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AppView()
            }
            .preferredColorScheme(.dark)
        }
    }
}

fileprivate enum SheetPresentationExample: String, Identifiable {
    var id: String { rawValue }
    case matchedGeometryNavigationStack
    case customNavigationStack
}

struct AppView: View {
    @State private var fullScreenExample: SheetPresentationExample?
    var body: some View {
        List {
            Section("Basic Features") {
                NavigationLink("Animation, Transition, Transaction") {
                    TabView {
                        AnimationExampleView()
                        TransitionExampleView()
                        TransactionExampleView()
                        CornerRadiusAnimationExampleView()
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .background(Color.black)
                }

                NavigationLink("Matched Geometry Transition") {
                    MatchedGeometryExampleView()
                }

                NavigationLink("Corner Radius Geometry Transition") {
                    CornerRadiusMatchedGeometryExampleView()
                }

                NavigationLink("Matched Geometry Animation") {
                    TabView {
                        MatchedGeometrySourceExampleView()
                        AnchorPreferenceExampleView()
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .background(Color.black)
                }

                NavigationLink("Interactive Matched Geometry") {
                    InteractiveAnchorPreferenceExampleView()
                }
            }

            Section("Hero Transitions") {
                Button("in Navigation Stack") {
                    fullScreenExample = .matchedGeometryNavigationStack
                }

                NavigationLink("SwiftUI / UIViewTransitioningDelegate") {
                    MatchedGeometryPresentationExampleView()
                }
            }

            Section("Custom Interactive Transitions") {
                Button("Custom Navigation") {
                    fullScreenExample = .customNavigationStack
                }
                NavigationLink("Custom Sheet") {
                    CustomSheetExampleView()
                }
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("")
            }
        }
        .sheet(item: $fullScreenExample) { example in
            switch example {
                case .matchedGeometryNavigationStack:
                    NavigationMatchedAnchorExampleView()
                case .customNavigationStack:
                    NavigationStackExampleView(useCustomNavigationPath: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppView()
    }

}
