//
//  AsyncStyle+Overlay.swift
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

public struct OverlayAsyncButtonStyle: AsyncButtonStyle {
    public enum ProgressStyle: Sendable {
        case bar
        case percent
    }

    private var style: ProgressStyle
    public init(style: ProgressStyle = .bar) {
        self.style = style
    }

    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
            .opacity(configuration.isLoading ? 0 : 1)
            .overlay {
                if configuration.isLoading {
                    if let fractionCompleted = configuration.fractionCompleted {
                        switch style {
                        case .bar:
                            BarProgressView(value: fractionCompleted)
                        case .percent:
                            Text(fractionCompleted, format: .percent.rounded(increment: 1))
                                .monospacedDigit()
                        }
                    } else {
                        IndeterminateProgressView()
                    }
                }
            }
            .animation(.default, value: configuration.isLoading)
    }
}

extension AsyncButtonStyle where Self == OverlayAsyncButtonStyle {
    public static var overlay: OverlayAsyncButtonStyle {
        OverlayAsyncButtonStyle()
    }
    public static func overlay(style: OverlayAsyncButtonStyle.ProgressStyle) -> OverlayAsyncButtonStyle {
        OverlayAsyncButtonStyle(style: style)
    }
}

#Preview("Indeterminate") {
    AsyncButton {
        try await Task.sleep(nanoseconds: 30_000_000_000)
    } label: {
        Text("Overlay")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay)
}

#Preview("Determinate (bar)") {
    AsyncButton(progress: .discrete(totalUnitCount: 100)) { progress in
        for _ in 1...100 {
            try await Task.sleep(nanoseconds: 10_000_000)
            progress.completedUnitCount += 1
        }
    } label: {
        Text("Overlay")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay(style: .bar))
}

#Preview("Determinate (percent)") {
    AsyncButton(progress: .discrete(totalUnitCount: 100)) { progress in
        for _ in 1...100 {
            try await Task.sleep(nanoseconds: 10_000_000)
            progress.completedUnitCount += 1
        }
    } label: {
        Text("Overlay")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.overlay(style: .percent))
}
