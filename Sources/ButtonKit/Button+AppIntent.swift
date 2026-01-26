//
//  Button+AppIntent.swift
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

import AppIntents
import SwiftUI

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension AsyncButton where P == IndeterminateProgress {
    public init(
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        @ViewBuilder label: @escaping () -> S,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(role: role, id: id, action: { _ = try await intent.perform() }, label: label, onStateChange: onStateChange)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension AsyncButton where P == IndeterminateProgress, S == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(titleKey, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(title, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }
}

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension AsyncButton where P == IndeterminateProgress, S == Label<Text, Image> {
    public init(
        _ titleKey: LocalizedStringKey,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(titleKey, image: name, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(title, image: name, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(titleKey, image: image, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(title, image: image, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(titleKey, systemImage: systemImage, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        intent: some AppIntent,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(title, systemImage: systemImage, role: role, id: id, action: { _ = try await intent.perform() }, onStateChange: onStateChange)
    }
}
