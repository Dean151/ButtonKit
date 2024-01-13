//
//  Button+AsyncStyle.swift
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
    public func asyncButtonStyle<S: AsyncButtonStyle>(_ style: S) -> some View {
        environment(\.asyncButtonStyle, AnyAsyncButtonStyle(style))
    }
}

public protocol AsyncButtonStyle {
    associatedtype Label: View
    associatedtype Button: View
    typealias LabelConfiguration = AsyncButtonStyleLabelConfiguration
    typealias ButtonConfiguration = AsyncButtonStyleButtonConfiguration

    @ViewBuilder func makeLabel(configuration: LabelConfiguration) -> Label
    @ViewBuilder func makeButton(configuration: ButtonConfiguration) -> Button
}
extension AsyncButtonStyle {
    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
    }
    public func makeButton(configuration: ButtonConfiguration) -> some View {
        configuration.button
    }
}

public struct AsyncButtonStyleLabelConfiguration {
    typealias Label = AnyView

    let isLoading: Bool
    let label: Label
    let cancel: () -> Void
}

public struct AsyncButtonStyleButtonConfiguration {
    typealias Button = AnyView

    let isLoading: Bool
    let button: Button
    let cancel: () -> Void
}

// MARK: SwiftUI Environment

struct AsyncButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyAsyncButtonStyle = AnyAsyncButtonStyle(.overlay)
}

extension EnvironmentValues {
    var asyncButtonStyle: AnyAsyncButtonStyle {
        get {
            return self[AsyncButtonStyleKey.self]
        }
        set {
            self[AsyncButtonStyleKey.self] = newValue
        }
    }
}

// MARK: - Type erasure

struct AnyAsyncButtonStyle: AsyncButtonStyle {
    private let _makeLabel: (AsyncButtonStyle.LabelConfiguration) -> AnyView
    private let _makeButton: (AsyncButtonStyle.ButtonConfiguration) -> AnyView

    init<S: AsyncButtonStyle>(_ style: S) {
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

extension AsyncButtonStyle {
    func makeLabelTypeErased(configuration: LabelConfiguration) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration))
    }
    func makeButtonTypeErased(configuration: ButtonConfiguration) -> AnyView {
        AnyView(self.makeButton(configuration: configuration))
    }
}
