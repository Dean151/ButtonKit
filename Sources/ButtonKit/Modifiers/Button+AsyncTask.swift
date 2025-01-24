//
//  Button+AsyncTask.swift
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

// MARK: Public protocol

public typealias AsyncButtonTaskStartedHandler = @MainActor @Sendable (Task<Void, Never>) -> Void
public typealias AsyncButtonTaskChangedHandler = @MainActor @Sendable (Task<Void, Never>?) -> Void
public typealias AsyncButtonTaskEndedHandler = @MainActor @Sendable () -> Void

extension View {
    public func asyncButtonTaskStarted(_ handler: @escaping AsyncButtonTaskStartedHandler) -> some View {
        modifier(OnAsyncButtonTaskChangeModifier { task in
            if let task {
                handler(task)
            }
        })
    }

    public func asyncButtonTaskChanged(_ handler: @escaping AsyncButtonTaskChangedHandler) -> some View {
        modifier(OnAsyncButtonTaskChangeModifier { task in
            handler(task)
        })
    }

    public func asyncButtonTaskEnded(_ handler: @escaping AsyncButtonTaskEndedHandler) -> some View {
        modifier(OnAsyncButtonTaskChangeModifier { task in
            if task == nil {
                handler()
            }
        })
    }
}

// MARK: - Internal implementation

struct AsyncButtonTaskPreferenceKey: PreferenceKey {
    static let defaultValue: AsyncButtonState = .idle

    static func reduce(value: inout AsyncButtonState, nextValue: () -> AsyncButtonState) {
        value = nextValue()
    }
}

struct OnAsyncButtonTaskChangeModifier: ViewModifier {
    let handler: AsyncButtonTaskChangedHandler

    init(handler: @escaping AsyncButtonTaskChangedHandler) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(AsyncButtonTaskPreferenceKey.self) { state in
                #if swift(>=5.10)
                MainActor.assumeIsolated {
                    onTaskChanged(state)
                }
                #else
                onTaskChanged(state)
                #endif
            }
    }

    @MainActor
    func onTaskChanged(_ state: AsyncButtonState) {
        switch state {
        case .started(let task):
            handler(task)
        case .ended:
            handler(nil)
        case .idle:
            break
        }
    }
}
