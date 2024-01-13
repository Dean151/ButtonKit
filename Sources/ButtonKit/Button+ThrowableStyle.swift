//
//  Button+ThrowableStyle.swift
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

extension View {
    public func throwableButtonStyle<S: ThrowableButtonStyle>(_ style: S) -> some View {
        environment(\.throwableButtonStyle, AnyThrowableButtonStyle(style))
    }
}

public protocol ThrowableButtonStyle {
    associatedtype Label: View
    associatedtype Button: View
    typealias LabelConfiguration = ThrowableButtonStyleLabelConfiguration
    typealias ButtonConfiguration = ThrowableButtonStyleButtonConfiguration

    @ViewBuilder func makeLabel(configuration: LabelConfiguration) -> Label
    @ViewBuilder func makeButton(configuration: ButtonConfiguration) -> Button
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
    typealias Label = AnyView

    let label: Label
    let errorCount: Int
}
public struct ThrowableButtonStyleButtonConfiguration {
    typealias Button = AnyView

    let button: Button
    let errorCount: Int
}
// MARK: SwiftUI Environment

struct ThrowableButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyThrowableButtonStyle = AnyThrowableButtonStyle(.shake)
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
    private let _makeLabel: (ThrowableButtonStyle.LabelConfiguration) -> AnyView
    private let _makeButton: (ThrowableButtonStyle.ButtonConfiguration) -> AnyView

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
    func makeLabelTypeErased(configuration: LabelConfiguration) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration))
    }
    func makeButtonTypeErased(configuration: ButtonConfiguration) -> AnyView {
        AnyView(self.makeButton(configuration: configuration))
    }
}
