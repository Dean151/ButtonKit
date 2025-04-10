//
//  AsyncStyle+Trailing.swift
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

public struct TrailingAsyncButtonStyle: AsyncButtonStyle {
    public init() {}

    public func makeLabel(configuration: LabelConfiguration) -> some View {
        HStack(spacing: 8) {
            configuration.label
            if configuration.isLoading {
                if let fractionCompleted = configuration.fractionCompleted {
                    CircularProgressView(value: fractionCompleted)
                } else {
                    IndeterminateProgressView()
                }
            }
        }
        .animation(.default, value: configuration.isLoading)
        .animation(.default, value: configuration.fractionCompleted)
    }
}

extension AsyncButtonStyle where Self == TrailingAsyncButtonStyle {
    public static var trailing: TrailingAsyncButtonStyle {
        TrailingAsyncButtonStyle()
    }
}

#Preview("Indeterminate") {
    AsyncButton {
        try await Task.sleep(nanoseconds: 30_000_000_000)
    } label: {
        Text("Trailing")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.trailing)
}

#Preview("Determinate") {
    AsyncButton(progress: .discrete(totalUnitCount: 100)) { progress in
        for _ in 1...100 {
            try await Task.sleep(nanoseconds: 10_000_000)
            progress.completedUnitCount += 1
        }
    } label: {
        Text("Trailing")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.trailing)
}
