//
//  BarProgressView.swift
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

struct BarProgressView: View {
    let value: Double
    let total: Double

    var body: some View {
        progress
            .opacity(0)
            .overlay {
                Rectangle()
                    .fill(.primary)
                    .mask { progress }
            }
            #if os(macOS)
            .controlSize(.small)
            #endif
            .compositingGroup()
    }

    @ViewBuilder
    var progress: some View {
        ProgressView(value: value, total: total)
            .progressViewStyle(.linear)
    }

    init<V: BinaryFloatingPoint>(value: V, total: V = 1.0) {
        self.value = Double(value)
        self.total = Double(total)
    }
}

#Preview {
    BarProgressView(value: 0.42)
        .foregroundStyle(.linearGradient(
            colors: [.blue, .red],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        )
}
