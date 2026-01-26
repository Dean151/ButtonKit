//
//  Progress+NSProgress.swift
//  ButtonKit
//
//  MIT License
//
//  Copyright (c) 2026 Thomas Durand
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

/// Monitor and reflect a (NS)Progress object
@MainActor
public final class NSProgressBridge: TaskProgress {
    @Published public private(set) var fractionCompleted: Double? = nil

    public var nsProgress: Progress? {
        didSet {
            observations.forEach { $0.invalidate() }
            observations.removeAll()

            if let nsProgress {
                observations.insert(nsProgress.observe(\.fractionCompleted, options: [.initial, .new], changeHandler: { [weak self] progress, _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.update(with: progress)
                    }
                }))
                observations.insert(nsProgress.observe(\.isIndeterminate, options: [.initial, .new], changeHandler: { [weak self] progress, _ in
                    DispatchQueue.main.async { [weak self] in
                        self?.update(with: progress)
                    }
                }))
            }
        }
    }
    private var observations: Set<NSKeyValueObservation> = []

    nonisolated init() {}

    private func update(with progress: Progress) {
        fractionCompleted = progress.isIndeterminate ? nil : progress.fractionCompleted
    }

    public func reset() {
        nsProgress = nil
        fractionCompleted = nil
    }
}

extension TaskProgress where Self == NSProgressBridge {
    public static var progress: NSProgressBridge {
        NSProgressBridge()
    }
}

#Preview {
    AsyncButton(progress: .progress) { progress in
        let nsProgress = Progress(totalUnitCount: 100)
        progress.nsProgress = nsProgress
        for _ in 1...100 {
            try await Task.sleep(nanoseconds: 20_000_000)
            nsProgress.completedUnitCount += 1
        }
    } label: {
        Text("NSProgress")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay)
}
