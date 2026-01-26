//
//  Button+Events.swift
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

// MARK: Public protocol

public typealias ButtonStateChangedHandler = @MainActor @Sendable (StateChangedEvent) -> Void
public typealias ButtonStateErrorHandler = @MainActor @Sendable (ErrorOccurredEvent) -> Void

#if swift(>=6.2)
@MainActor
public struct StateChangedEvent: @MainActor Equatable {
    public let buttonID: AnyHashable
    public let state: AsyncButtonState
    let time: Date = .now
}
#else
@MainActor
public struct StateChangedEvent: Equatable, Sendable {
    nonisolated(unsafe) public let buttonID: AnyHashable
    public let state: AsyncButtonState
    let time: Date = .now
}
#endif

public struct ErrorOccurredEvent {
    public let buttonID: AnyHashable
    public let error: Error
    let time: Date = .now
}

extension View {
    public func onButtonStateChange(_ handler: @escaping ButtonStateChangedHandler) -> some View {
        modifier(OnButtonLatestStateChangeModifier { state in
            if let state {
                handler(state)
            }
        })
    }
    public func onButtonStateError(_ handler: @escaping ButtonStateErrorHandler) -> some View {
        modifier(OnButtonLatestStateChangeModifier { event in
            if case let .ended(.errored(error, _)) = event?.state {
                handler(.init(buttonID: event!.buttonID, error: error))
            }
        })
    }
}

// MARK: Deprecated public protocol

@available(*, deprecated)
public typealias AsyncButtonTaskStartedHandler = @MainActor @Sendable (Task<Void, Never>) -> Void
@available(*, deprecated)
public typealias AsyncButtonTaskChangedHandler = @MainActor @Sendable (Task<Void, Never>?) -> Void
@available(*, deprecated)
public typealias AsyncButtonTaskEndedHandler = @MainActor @Sendable () -> Void
@available(*, deprecated)
public typealias AsyncButtonErrorHandler = @MainActor @Sendable (Error) -> Void

extension View {
    @available(*, deprecated, message: "use onButtonStateChange instead")
    public func asyncButtonTaskStarted(_ handler: @escaping AsyncButtonTaskStartedHandler) -> some View {
        modifier(OnButtonLatestStateChangeModifier { event in
            if let task = event?.state.task {
                handler(task)
            }
        })
    }

    @available(*, deprecated, message: "use onButtonStateChange instead")
    public func asyncButtonTaskChanged(_ handler: @escaping AsyncButtonTaskChangedHandler) -> some View {
        modifier(OnButtonLatestStateChangeModifier { event in
            if let event {
                handler(event.state.task)
            }
        })
    }

    @available(*, deprecated, message: "use onButtonStateChange instead")
    public func asyncButtonTaskEnded(_ handler: @escaping AsyncButtonTaskEndedHandler) -> some View {
        modifier(OnButtonLatestStateChangeModifier { event in
            if let event, event.state.task == nil {
                handler()
            }
        })
    }

    @available(*, deprecated, message: "use onButtonStateError or onButtonStateChange instead")
    public func onButtonError(_ handler: @escaping AsyncButtonErrorHandler) -> some View {
        modifier(OnButtonLatestStateChangeModifier { event in
            if case let .ended(.errored(error, _)) = event?.state {
                handler(error)
            }
        })
    }
}

// MARK: - Internal implementation

typealias OptionalButtonStateChangedHandler = @MainActor @Sendable (StateChangedEvent?) -> Void

struct ButtonLatestStatePreferenceKey: PreferenceKey {
    static let defaultValue: StateChangedEvent? = nil

    static func reduce(value: inout StateChangedEvent?, nextValue: () -> StateChangedEvent?) {
        guard let next = nextValue() else {
            return
        }
        if value == nil || next.time > value!.time {
            value = next
        }
    }
}

struct OnButtonLatestStateChangeModifier: ViewModifier {
    let handler: OptionalButtonStateChangedHandler

    init(handler: @escaping OptionalButtonStateChangedHandler) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(ButtonLatestStatePreferenceKey.self) { state in
                MainActor.assumeIsolated {
                    handler(state)
                }
            }
    }
}
