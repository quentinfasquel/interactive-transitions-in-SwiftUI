//
//  Binding+Not.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 29/03/2024.
//

import SwiftUI

extension Binding where Value == Bool {

    func not() -> Binding<Bool> {
        Binding(
            get: { !wrappedValue },
            set: { _ in /* Does nothing */ }
        )
    }

    func and(_ otherValue: Binding<Bool>) -> Binding<Bool> {
        Binding(
            get: { wrappedValue && otherValue.wrappedValue },
            set: { _ in /* Does nothing */ }
        )
    }

    func or(_ otherValue: Binding<Bool>) -> Binding<Bool> {
        Binding(
            get: { wrappedValue || otherValue.wrappedValue },
            set: { _ in /* Does nothing */ }
        )
    }
}
