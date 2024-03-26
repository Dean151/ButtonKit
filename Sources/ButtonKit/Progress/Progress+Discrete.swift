//
//  Progress+Discrete.swift
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

import Combine

/// Represents a discrete and linear progress
@MainActor
public final class DiscreteProgress: TaskProgress {
    public let totalUnitCount: Int
    @Published public var completedUnitCount = 0 {
        willSet {
            assert(newValue >= 0 && newValue <= totalUnitCount, "Discrete progression requires completedUnitCount to be in 0...\(totalUnitCount)")
        }
    }

    public func reset() {
        completedUnitCount = 0
    }

    public var fractionCompleted: Double? {
        Double(completedUnitCount) / Double(totalUnitCount)
    }

    nonisolated init(totalUnitCount: Int) {
        self.totalUnitCount = totalUnitCount
    }
}

extension TaskProgress where Self == DiscreteProgress {
    public static func discrete(totalUnitCount: Int) -> DiscreteProgress {
        assert(totalUnitCount > 0, "Discrete progression requires totalUnitCount to be positive")
        return DiscreteProgress(totalUnitCount: totalUnitCount)
    }
}
