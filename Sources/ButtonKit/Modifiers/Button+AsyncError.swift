//
//  Button+AsyncError.swift
//  ButtonKit
//
//  Created by Thomas Durand on 12/01/2025.
//

import SwiftUI

// MARK: Public protocol

public typealias AsyncButtonErrorHandler = @MainActor @Sendable (Error) -> Void

extension View {
    public func onButtonError(_ handler: @escaping AsyncButtonErrorHandler) -> some View {
        modifier(OnAsyncButtonErrorChangeModifier(handler: { error in
            handler(error)
        }))
    }
}

// MARK: - Internal implementation

struct AsyncButtonErrorPreferenceKey: PreferenceKey {
    static let defaultValue: ErrorHolder? = nil

    static func reduce(value: inout ErrorHolder?, nextValue: () -> ErrorHolder?) {
        guard let newValue = nextValue() else {
            return
        }
        value = .init(increment: (value?.increment ?? 0) + newValue.increment, error: newValue.error)
    }
}

struct ErrorHolder: Equatable {
    let increment: Int
    let error: Error

    static func == (lhs: ErrorHolder, rhs: ErrorHolder) -> Bool {
        lhs.increment == rhs.increment
    }
}

struct OnAsyncButtonErrorChangeModifier: ViewModifier {
    let handler: AsyncButtonErrorHandler

    init(handler: @escaping AsyncButtonErrorHandler) {
        self.handler = handler
    }

    func body(content: Content) -> some View {
        content
            .onPreferenceChange(AsyncButtonErrorPreferenceKey.self) { value in
                guard let error = value?.error else {
                    return
                }
                #if swift(>=5.10)
                MainActor.assumeIsolated {
                    onError(error)
                }
                #else
                onError(error)
                #endif
            }
    }

    @MainActor
    func onError(_ error: Error) {
        handler(error)
    }
}
