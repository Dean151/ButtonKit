//
//  Button+AsyncTask.swift
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

// Internal implementation

struct AsyncButtonTaskPreferenceKey: PreferenceKey {
    static let defaultValue: Task<Void, Never>? = nil

    static func reduce(value: inout Task<Void, Never>?, nextValue: () -> Task<Void, Never>?) {
        value = nextValue()
    }
}

struct OnAsyncButtonTaskChangeModifier: ViewModifier {
    let handler: AsyncButtonTaskChangedHandler
    @State private var initialized = false

    init(handler: @escaping AsyncButtonTaskChangedHandler) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(AsyncButtonTaskPreferenceKey.self) { task in
                if task == nil && !initialized {
                    // Ignore first preference change, a.k.a button initialization
                    initialized = true
                    return
                }

                handler(task)
            }
    }
}
