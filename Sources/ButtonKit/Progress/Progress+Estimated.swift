//
//  Progress+Estimated.swift
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

/// Represents a progress where we estimate the time required to complete it
@MainActor
@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
public class EstimatedProgress: Progress {
    let estimation: Duration
    let stop = 0.85
    @Published public private(set) var fractionCompleted: Double? = 0
    private var task: Task<Void, Never>?

    nonisolated init(estimation: Duration) {
        self.estimation = estimation
    }

    public func reset() {
        fractionCompleted = 0
    }

    public func started() async {
        task = Task {
            for _ in 1...100 {
                try? await Task.sleep(for: estimation * stop / 100)
                fractionCompleted! += stop / 100
            }
        }
    }

    public func ended() async {
        task?.cancel()
        fractionCompleted = 1
        try? await Task.sleep(for: .milliseconds(100))
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
extension Progress where Self == EstimatedProgress {
    public static func estimated(for duration: Duration) -> EstimatedProgress {
        EstimatedProgress(estimation: duration)
    }
}

@available(macOS 13.0, iOS 16.0, watchOS 9.0, tvOS 16.0, visionOS 1.0, *)
#Preview {
    AsyncButton(progress: .estimated(for: .seconds(1))) { progress in
        try await Task.sleep(for: .seconds(2))
    } label: {
        Text("Estimated duration")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay)
}
