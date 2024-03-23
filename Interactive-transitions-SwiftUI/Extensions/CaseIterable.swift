//
//  CaseIterable.swift
//  Interactive-transitions-SwiftUI
//
//  Created by Quentin Fasquel on 26/03/2024.
//

import Foundation

public extension CaseIterable where Self: Equatable, AllCases.Index == Int {

    var previous: Self? {
        guard let index = Self.allCases.firstIndex(of: self), index > Self.allCases.startIndex else {
            return nil
        }
        return Self.allCases[index - 1]
    }

    var next: Self? {
        guard let index = Self.allCases.firstIndex(of: self), index < Self.allCases.endIndex - 1 else {
            return nil
        }
        let nextIndex = Self.allCases.index(after: index)
        return Self.allCases[nextIndex]
    }

    var isFirst: Bool {
        guard let index = Self.allCases.firstIndex(of: self) else {
            return false
        }
        return index == Self.allCases.startIndex
    }

    var isLast: Bool {
        guard let index = Self.allCases.firstIndex(of: self) else {
            return false
        }
        return index == Self.allCases.endIndex - 1
    }
}
