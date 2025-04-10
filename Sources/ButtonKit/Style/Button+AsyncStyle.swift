//
//  Button+AsyncStyle.swift
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

extension View {
    public func asyncButtonStyle<S: AsyncButtonStyle>(_ style: S) -> some View {
        environment(\.asyncButtonStyle, AnyAsyncButtonStyle(style))
    }
}

public protocol AsyncButtonStyle: Sendable {
    associatedtype ButtonLabel: View
    associatedtype ButtonView: View
    typealias LabelConfiguration = AsyncButtonStyleLabelConfiguration
    typealias ButtonConfiguration = AsyncButtonStyleButtonConfiguration

    @MainActor @ViewBuilder func makeLabel(configuration: LabelConfiguration) -> ButtonLabel
    @MainActor @ViewBuilder func makeButton(configuration: ButtonConfiguration) -> ButtonView
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
    public typealias Label = AnyView

    public let label: Label
    /// Returns true if the button is in a loading state, and false if the button is idle
    public let isLoading: Bool
    /// Returns the fraction completed when the task is determinate. nil when the task is indeterminate
    public let fractionCompleted: Double?
    /// A callable closure to cancel the current task if any
    public let cancel: () -> Void
}

public struct AsyncButtonStyleButtonConfiguration {
    public typealias Button = AnyView

    public let button: Button
    /// Returns true if the button is in a loading state, and false if the button is idle
    public let isLoading: Bool
    /// Returns the fraction completed when the task is determinate. nil when the task is indeterminate
    public let fractionCompleted: Double?
    /// A callable closure to cancel the current task if any
    public let cancel: () -> Void
}

// MARK: SwiftUI Environment

extension AsyncButtonStyle where Self == OverlayAsyncButtonStyle {
    public static var auto: some AsyncButtonStyle {
        OverlayAsyncButtonStyle(style: .bar)
    }
}

struct AsyncButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyAsyncButtonStyle = AnyAsyncButtonStyle(.auto)
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

struct AnyAsyncButtonStyle: AsyncButtonStyle, Sendable {
    private let _makeLabel: @MainActor @Sendable (AsyncButtonStyle.LabelConfiguration) -> AnyView
    private let _makeButton: @MainActor @Sendable (AsyncButtonStyle.ButtonConfiguration) -> AnyView

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
    @MainActor
    func makeLabelTypeErased(configuration: LabelConfiguration) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration))
    }
    @MainActor
    func makeButtonTypeErased(configuration: ButtonConfiguration) -> AnyView {
        AnyView(self.makeButton(configuration: configuration))
    }
}
