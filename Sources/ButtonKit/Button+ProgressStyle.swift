//
//  Button+ProgressStyle.swift
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
    public func progressButtonStyle<S: ProgressButtonStyle>(_ style: S) -> some View {
        environment(\.progressButtonStyle, AnyProgressButtonStyle(style))
    }
}

public protocol ProgressButtonStyle: Sendable {
    associatedtype Label: View
    associatedtype Button: View
    typealias LabelConfiguration = ProgressButtonStyleLabelConfiguration
    typealias ButtonConfiguration = ProgressButtonStyleButtonConfiguration

    @ViewBuilder func makeLabel(configuration: LabelConfiguration) -> Label
    @ViewBuilder func makeButton(configuration: ButtonConfiguration) -> Button
}
extension ProgressButtonStyle {
    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
    }
    public func makeButton(configuration: ButtonConfiguration) -> some View {
        configuration.button
    }
}

public struct ProgressButtonStyleLabelConfiguration {
    public typealias Label = AnyView

    public let isLoading: Bool
    public let progress: TaskProgress
    public let label: Label
    public let cancel: () -> Void
}

public struct ProgressButtonStyleButtonConfiguration {
    public typealias Button = AnyView

    public let isLoading: Bool
    public let progress: TaskProgress
    public let button: Button
    public let cancel: () -> Void
}

// MARK: SwiftUI Environment

struct ProgressButtonStyleKey: EnvironmentKey {
    static let defaultValue: AnyProgressButtonStyle = AnyProgressButtonStyle(.bar)
}

extension EnvironmentValues {
    var progressButtonStyle: AnyProgressButtonStyle {
        get {
            return self[ProgressButtonStyleKey.self]
        }
        set {
            self[ProgressButtonStyleKey.self] = newValue
        }
    }
}

// MARK: - Type erasure

struct AnyProgressButtonStyle: ProgressButtonStyle, Sendable {
    private let _makeLabel: @Sendable (ProgressButtonStyle.LabelConfiguration) -> AnyView
    private let _makeButton: @Sendable (ProgressButtonStyle.ButtonConfiguration) -> AnyView

    init<S: ProgressButtonStyle>(_ style: S) {
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

extension ProgressButtonStyle {
    @Sendable
    func makeLabelTypeErased(configuration: LabelConfiguration) -> AnyView {
        AnyView(self.makeLabel(configuration: configuration))
    }
    @Sendable
    func makeButtonTypeErased(configuration: ButtonConfiguration) -> AnyView {
        AnyView(self.makeButton(configuration: configuration))
    }
}
