//
//  Button+Throwable.swift
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

public struct ThrowableButton<S: View>: View {
    @Environment(\.throwableButtonStyle)
    private var throwableButtonStyle

    private let role: ButtonRole?
    private let action: () throws -> Void
    private let label: S

    @State private var errorCount = 0

    public var body: some View {
        let throwableLabelConfiguration = ThrowableButtonStyleLabelConfiguration(
            label: AnyView(label),
            errorCount: errorCount
        )
        let button = Button(role: role) {
            do {
                try action()
            } catch {
                errorCount += 1
            }
        } label: {
            throwableButtonStyle.makeLabel(configuration: throwableLabelConfiguration)
        }
        .animation(.default, value: errorCount)
        let throwableConfiguration = ThrowableButtonStyleButtonConfiguration(
            button: AnyView(button),
            errorCount: errorCount
        )
        return throwableButtonStyle.makeButton(configuration: throwableConfiguration)
    }

    public init(role: ButtonRole? = nil, action: @escaping () throws -> Void, @ViewBuilder label: @escaping () -> S) {
        self.role = role
        self.action = action
        self.label = label()
    }
}

extension ThrowableButton where S == Text {
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () throws -> Void) {
        self.role = role
        self.action = action
        self.label = Text(titleKey)
    }

    @_disfavoredOverload
    public init(_ title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () throws -> Void) {
        self.role = role
        self.action = action
        self.label = Text(title)
    }
}

extension ThrowableButton where S == Label<Text, Image> {
    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () throws -> Void
    ) {
        self.role = role
        self.action = action
        self.label = Label(titleKey, systemImage: systemImage)
    }

    public init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        action: @escaping () throws -> Void
    ) {
        self.role = role
        self.action = action
        self.label = Label(title, systemImage: systemImage)
    }
}

#if swift(>=5.9)
#Preview("Error") {
    ThrowableButton {
        throw NSError() as Error
    } label: {
        Text("Will fail")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}

#Preview("Success") {
    ThrowableButton {} label: {
        Text("Will succeed")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}
#endif
