//
//  AsyncButtonDemo.swift
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

import ButtonKit
import SwiftUI

struct AsyncButtonDemo: View {
    var body: some View {
        VStack(spacing: 24) {
            Group {
                AsyncButton {
                    // Here you have a throwable & async closure!
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } label: {
                    Text("Overlay style")
                }
                .asyncButtonStyle(.overlay)

                AsyncButton {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } label: {
                    Text("Leading style")
                }
                .asyncButtonStyle(.leading)

                AsyncButton {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } label: {
                    Text("Trailing style")
                }
                .asyncButtonStyle(.trailing)

                AsyncButton {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } label: {
                    Text("Pulse style")
                }
                .asyncButtonStyle(.pulse)

                if #available(iOS 18.0, *) {
                    AsyncButton {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                    } label: {
                        Label("Symbol effect", systemImage: "ellipsis")
                    }
                    .asyncButtonStyle(.symbolEffect(.variableColor))
                }

                AsyncButton {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                } label: {
                    Text("No style")
                }
                .asyncButtonStyle(.none)
            }
            .onButtonStateChange { event in
                switch event.state {
                case .started:
                    print("task started: \(event.buttonID)")
                case .ended(.completed):
                    print("task completed: \(event.buttonID)")
                case .ended(.cancelled):
                    print("task cancelled: \(event.buttonID)")
                case .ended(.errored(let error, _)):
                    print("task errored: \(event.buttonID) \(error)")
                }
            }
        }
        .buttonStyle(.borderedProminent)
    }
}

#Preview {
    AsyncButtonDemo()
}
