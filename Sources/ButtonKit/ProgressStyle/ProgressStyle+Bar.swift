//
//  ProgressStyle+Bar.swift
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

public struct BarProgressButtonStyle: ProgressButtonStyle {
    public init() {}

    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
            .opacity(configuration.isLoading ? 0 : 1)
            .overlay {
                if configuration.isLoading {
                    HierarchicalProgressView(value: configuration.progress.fractionCompleted)
                }
            }
            .animation(.default, value: configuration.isLoading)
    }
}

extension ProgressButtonStyle where Self == BarProgressButtonStyle {
    public static var bar: some ProgressButtonStyle {
        BarProgressButtonStyle()
    }
}

#Preview {
    AsyncButton(progress: .discrete(totalUnitCount: 100)) { $progress in
        for _ in 1...100 {
            try await Task.sleep(nanoseconds: 10_000_000)
            progress.completedUnitCount += 1
        }
    } label: {
        Text("Progress bar")
    }
    .buttonStyle(.borderedProminent)
    .progressButtonStyle(.bar)
}
