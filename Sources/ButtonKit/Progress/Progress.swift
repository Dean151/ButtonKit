//
//  Progress.swift
//  ButtonKit
//
//  MIT License
//
//  Copyright (c) 2024 Thomas Durand
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

public protocol Progress: Sendable {
    var isDeterminant: Bool { get }
    func fractionCompleted(_ completedUnitCount: Int) -> Double
}

public struct TaskProgress: Sendable {
    public let progress: Progress

    public var completedUnitCount: Int = 0 {
        willSet {
            assert(completedUnitCount >= 0, "completedUnitCount must be positive")
        }
    }

    public var fractionCompleted: Double {
        progress.fractionCompleted(completedUnitCount)
    }

    mutating func reset() {
        completedUnitCount = 0
    }
}

// Sugar syntax on binding

extension Binding<TaskProgress> {
    public var progress: Progress {
        wrappedValue.progress
    }

    public var completedUnitCount: Int {
        get {
            wrappedValue.completedUnitCount
        }
        nonmutating set {
            wrappedValue.completedUnitCount = newValue
        }
    }

    public var fractionCompleted: Double {
        wrappedValue.fractionCompleted
    }
}