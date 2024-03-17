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

import Foundation

public protocol ProgressKind: Sendable {
    func fractionCompleted(_ completedUnitCount: Int) -> Double
}

public struct Progress: Sendable {
    public let kind: ProgressKind
    public var completedUnitCount: Int = 0 {
        willSet {
            assert(completedUnitCount >= 0, "completedUnitCount must be positive")
        }
    }
    var isFinished = false

    var fractionCompleted: Double {
        kind.fractionCompleted(completedUnitCount)
    }

    mutating func initialize() {
        completedUnitCount = 0
        isFinished = false
    }

    mutating func abort() {
        initialize()
    }

    mutating func finish() {
        isFinished = true
    }
}
