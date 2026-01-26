//
//  Button+AsyncDisabled.swift
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

import Foundation

import SwiftUI

// MARK: Public protocol

extension View {
    public func allowsHitTestingWhenLoading(_ enabled: Bool) -> some View {
        environment(\.allowsHitTestingWhenLoading, enabled)
    }

    public func disabledWhenLoading(_ disabled: Bool = true) -> some View {
        environment(\.disabledWhenLoading, disabled)
    }
}

// MARK: SwiftUI Environment

struct AllowsHitTestingWhenLoadingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

struct DisabledWhenLoadingKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

extension EnvironmentValues {
    var allowsHitTestingWhenLoading: Bool {
        get {
            return self[AllowsHitTestingWhenLoadingKey.self]
        }
        set {
            self[AllowsHitTestingWhenLoadingKey.self] = newValue
        }
    }

    var disabledWhenLoading: Bool {
        get {
            return self[DisabledWhenLoadingKey.self]
        }
        set {
            self[DisabledWhenLoadingKey.self] = newValue
        }
    }
}
