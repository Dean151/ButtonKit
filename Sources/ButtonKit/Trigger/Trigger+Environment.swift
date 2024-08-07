//
//  Trigger+Environment.swift
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

#if canImport(IssueReporting)
import IssueReporting
#else
import OSLog
#endif

/// Allow to trigger an arbitrary but identified `AsyncButton` or `ThrowableButton`
public final class TriggerButton: Sendable {
    @MainActor private var buttons: [AnyHashable: @MainActor () -> Void] = [:]

    fileprivate init() {}

    @MainActor
    public func callAsFunction(id: AnyHashable) {
        guard let closure = buttons[id] else {
            #if canImport(IssueReporting)
            reportIssue("Could not trigger button with id: \(id). It is not currently on screen!")
            #else
            Logger(subsystem: "ButtonKit", category: "Trigger").warning("Could not trigger button with id: \(id). It is not currently on screen!")
            #endif
            return
        }
        closure()
    }

    @MainActor
    func register(id: AnyHashable, action: @escaping @MainActor () -> Void) {
        if buttons.keys.contains(id) {
            #if canImport(IssueReporting)
            reportIssue("Registering a button with an already existing id: \(id). The previous one was overridden.")
            #else
            Logger(subsystem: "ButtonKit", category: "Trigger").warning("Registering a button with an already existing id: \(id). The previous one was overridden.")
            #endif
        }
        buttons.updateValue(action, forKey: id)
    }

    @MainActor
    func unregister(id: AnyHashable) {
        buttons.removeValue(forKey: id)
    }
}

private struct TriggerEnvironmentKey: EnvironmentKey {
    static let defaultValue = TriggerButton()
}

extension EnvironmentValues {
    public var triggerButton: TriggerButton {
        self[TriggerEnvironmentKey.self]
    }
}
