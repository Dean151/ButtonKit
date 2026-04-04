//
//  Trigger+Environment.swift
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

import OSLog
import SwiftUI

private struct TriggerButtonKey: Hashable {
    let namespace: Namespace.ID?
    let id: AnyHashable
}

private func triggerScopeDescription(_ namespace: Namespace.ID?) -> String {
    guard let namespace else {
        return ""
    }

    return " in namespace \(String(describing: namespace))"
}

/// Allow to trigger an arbitrary but identified `AsyncButton`
public final class TriggerButton: Sendable {
    @MainActor private var buttons: [TriggerButtonKey: @MainActor () -> Void] = [:]

    fileprivate init() {}

    @MainActor
    public func callAsFunction(id: AnyHashable) {
        trigger(id: id, in: nil)
    }

    @MainActor
    public func callAsFunction(id: AnyHashable, in namespace: Namespace.ID) {
        trigger(id: id, in: namespace)
    }

    @MainActor
    private func trigger(id: AnyHashable, in namespace: Namespace.ID?) {
        guard let closure = buttons[.init(namespace: namespace, id: id)] else {
            Logger(subsystem: "ButtonKit", category: "Trigger").warning("Could not trigger button with id: \(id)\(triggerScopeDescription(namespace)). It is not currently on screen!")
            return
        }
        closure()
    }

    @MainActor
    func register(id: AnyHashable, in namespace: Namespace.ID?, action: @escaping @MainActor () -> Void) {
        let key = TriggerButtonKey(namespace: namespace, id: id)
        if buttons.keys.contains(key) {
            Logger(subsystem: "ButtonKit", category: "Trigger").warning("Registering a button with an already existing id: \(id)\(triggerScopeDescription(namespace)). The previous one was overridden.")
        }
        buttons.updateValue(action, forKey: key)
    }

    @MainActor
    func unregister(id: AnyHashable, in namespace: Namespace.ID?) {
        buttons.removeValue(forKey: .init(namespace: namespace, id: id))
    }
}

private struct TriggerEnvironmentKey: EnvironmentKey {
    static let defaultValue = TriggerButton()
}

private struct TriggerNamespaceEnvironmentKey: EnvironmentKey {
    static let defaultValue: Namespace.ID? = nil
}

extension View {
    public func buttonTriggerNamespace(_ namespace: Namespace.ID) -> some View {
        environment(\.triggerButtonNamespace, namespace)
    }
}

extension EnvironmentValues {
    public var triggerButton: TriggerButton {
        self[TriggerEnvironmentKey.self]
    }

    var triggerButtonNamespace: Namespace.ID? {
        get {
            self[TriggerNamespaceEnvironmentKey.self]
        }
        set {
            self[TriggerNamespaceEnvironmentKey.self] = newValue
        }
    }
}
