//
//  Progress+Estimated.swift
//  ButtonKit
//
//  MIT License
//
//  Copyright (c) 2025 Thomas Durand
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

/// Represents a progress where we estimate the time required to complete it
@MainActor
public class EstimatedProgress: TaskProgress {
    let sleeper: Sleeper
    let stop = 0.85
    @Published public private(set) var fractionCompleted: Double? = 0
    private var task: Task<Void, Never>?

    nonisolated init(nanoseconds duration: UInt64) {
        self.sleeper = NanosecondsSleeper(nanoseconds: duration)
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
    nonisolated init(estimation: Duration) {
        self.sleeper = DurationSleeper(duration: estimation)
    }

    public func reset() {
        fractionCompleted = 0
    }

    public func started() async {
        task = Task {
            for _ in 1...100 {
                try? await sleeper.sleep(fraction: stop / 100)
                fractionCompleted! += stop / 100
            }
        }
    }

    public func ended() async {
        task?.cancel()
        fractionCompleted = 1
        try? await Task.sleep(nanoseconds: 100_000_000)
    }
}

extension TaskProgress where Self == EstimatedProgress {
    public static func estimated(nanoseconds duration: UInt64) -> EstimatedProgress {
        EstimatedProgress(nanoseconds: duration)
    }

    @available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
    public static func estimated(for duration: Duration) -> EstimatedProgress {
        EstimatedProgress(estimation: duration)
    }

    /// This one is only to make SwiftUI preview happy
    /// Turns out SiwftUI preview does not like "literal UInt" to be present
    @_disfavoredOverload
    public static func estimated(nanoseconds duration: Int) -> EstimatedProgress {
        assert(duration >= 0, "duration must be positive!")
        return .estimated(nanoseconds: UInt64(duration))
    }
}

protocol Sleeper: Sendable {
    func sleep(fraction: Double) async throws
}

struct NanosecondsSleeper: Sleeper {
    let duration: UInt64

    init(nanoseconds duration: UInt64) {
        self.duration = duration
    }

    func sleep(fraction: Double) async throws {
        try await Task.sleep(nanoseconds: UInt64(Double(duration) * fraction))
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
struct DurationSleeper: Sleeper {
    let duration: Duration

    func sleep(fraction: Double) async throws {
        try await Task.sleep(for: duration * fraction)
    }
}

#Preview("Nanoseconds signature") {
    AsyncButton(progress: .estimated(nanoseconds: 1_000_000_000)) { progress in
        try await Task.sleep(nanoseconds: 2_000_000_000)
    } label: {
        Text("Estimated duration")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay)
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
#Preview("Duration signature") {
    AsyncButton(progress: .estimated(for: .seconds(1))) { progress in
        try await Task.sleep(for: .seconds(2))
    } label: {
        Text("Estimated duration")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay)
}
