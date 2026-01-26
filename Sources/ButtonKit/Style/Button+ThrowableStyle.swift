//
//  Button+ThrowableStyle.swift
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

extension View {
    public func throwableButtonStyle<S: ThrowableButtonStyle>(_ style: S) -> some View {
        environment(\.throwableButtonStyle, AnyThrowableButtonStyle(style))
    }
}

public protocol ThrowableButtonStyle: Sendable {
    associatedtype ButtonLabel: View
    associatedtype ButtonView: View
    typealias LabelConfiguration = ThrowableButtonStyleLabelConfiguration
    typealias ButtonConfiguration = ThrowableButtonStyleButtonConfiguration

    @MainActor @ViewBuilder func makeLabel(configuration: LabelConfiguration) -> ButtonLabel
    @MainActor @ViewBuilder func makeButton(configuration: ButtonConfiguration) -> ButtonView
}
extension ThrowableButtonStyle {
    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
    }
    public func makeButton(configuration: ButtonConfiguration) -> some View {
        configuration.button
    }
}

public struct ThrowableButtonStyleLabelConfiguration {
    public typealias Label = AnyView

    public let label: Label
    public let latestError: Error?
    /// Is incremented at each new error
    public let numberOfFailures: Int
    @available(*, deprecated, renamed: "numberOfFailures")
    public var errorCount: Int {
        numberOfFailures
    }
}
public struct ThrowableButtonStyleButtonConfiguration {
    public typealias Button = AnyView

    public let button: Button
    public let latestError: Error?
    /// Is incremented at each new error
    public let numberOfFailures: Int
    @available(*, deprecated, renamed: "numberOfFailures")
    public var errorCount: Int {
        numberOfFailures
    }
}
// MARK: SwiftUI Environment

extension ThrowableButtonStyle where Self == ShakeThrowableButtonStyle {
    public static var auto: some ThrowableButtonStyle {
        ShakeThrowableButtonStyle()
    }
}

struct ThrowableButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyThrowableButtonStyle = AnyThrowableButtonStyle(.auto)
}

extension EnvironmentValues {
    var throwableButtonStyle: AnyThrowableButtonStyle {
        get {
            return self[ThrowableButtonStyleKey.self]
        }
        set {
            self[ThrowableButtonStyleKey.self] = newValue
        }
    }
}

// MARK: - Type erasure

struct AnyThrowableButtonStyle: ThrowableButtonStyle {
    private let _makeLabel: @MainActor @Sendable (ThrowableButtonStyle.LabelConfiguration) -> AnyView
    private let _makeButton: @MainActor @Sendable (ThrowableButtonStyle.ButtonConfiguration) -> AnyView

    init<S: ThrowableButtonStyle>(_ style: S) {
        self._makeLabel = style.makeLabelTypeErased
        self._makeButton = style.makeButtonTypeErased
    }

    func makeLabel(configuration: LabelConfiguration) -> AnyView {
        self._makeLabel(configuration)
    }

    func makeButton(configuration: ButtonConfiguration) -> AnyView {
        self._makeButton(configuration)
    }
}

extension ThrowableButtonStyle {
    @MainActor
    func makeLabelTypeErased(configuration: LabelConfiguration) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration))
    }
    @MainActor
    func makeButtonTypeErased(configuration: ButtonConfiguration) -> AnyView {
        AnyView(self.makeButton(configuration: configuration))
    }
}
