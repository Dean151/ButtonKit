//
//  Button+Async.swift
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

@available(*, deprecated, renamed: "AsyncButton")
public typealias ThrowableButton = AsyncButton

enum AsyncButtonState: Equatable {
    case idle
    case started(Task<Void, Never>)
    case ended

    var isLoading: Bool {
        switch self {
        case .started:
            return true
        case .idle, .ended:
            return false
        }
    }

    mutating func cancel() {
        switch self {
        case .idle:
            self = .ended
        case .started(let task):
            task.cancel()
        case .ended:
            break
        }
    }
}

public struct AsyncButton<P: TaskProgress, S: View>: View {
    @Environment(\.asyncButtonStyle)
    private var asyncButtonStyle
    @Environment(\.allowsHitTestingWhenLoading)
    private var allowsHitTestingWhenLoading
    @Environment(\.disabledWhenLoading)
    private var disabledWhenLoading
    @Environment(\.isEnabled)
    private var isEnabled
    @Environment(\.throwableButtonStyle)
    private var throwableButtonStyle
    @Environment(\.triggerButton)
    private var triggerButton

    private let role: ButtonRole?
    private let id: AnyHashable?
    private let action: @MainActor (P) async throws -> Void
    private let label: S

    @State private var state: AsyncButtonState = .idle
    @ObservedObject private var progress: P
    @State private var errorCount = 0
    @State private var lastError: Error?

    public var body: some View {
        let throwableLabelConfiguration = ThrowableButtonStyleLabelConfiguration(
            label: AnyView(label),
            errorCount: errorCount
        )
        let label: AnyView
        let asyncLabelConfiguration = AsyncButtonStyleLabelConfiguration(
            label: AnyView(throwableButtonStyle.makeLabel(configuration: throwableLabelConfiguration)),
            isLoading: state.isLoading,
            fractionCompleted: progress.fractionCompleted,
            cancel: cancel
        )
        label = asyncButtonStyle.makeLabel(configuration: asyncLabelConfiguration)
        let button = Button(role: role, action: perform) {
            label
        }
        let throwableConfiguration = ThrowableButtonStyleButtonConfiguration(
            button: AnyView(button),
            errorCount: errorCount
        )
        let asyncConfiguration = AsyncButtonStyleButtonConfiguration(
            button: AnyView(throwableButtonStyle.makeButton(configuration: throwableConfiguration)),
            isLoading: state.isLoading,
            fractionCompleted: progress.fractionCompleted,
            cancel: cancel
        )
        return asyncButtonStyle
            .makeButton(configuration: asyncConfiguration)
            .allowsHitTesting(allowsHitTestingWhenLoading || !state.isLoading)
            .disabled(disabledWhenLoading && state.isLoading)
            .preference(key: AsyncButtonTaskPreferenceKey.self, value: state)
            .preference(key: AsyncButtonErrorPreferenceKey.self, value: lastError.flatMap { .init(increment: errorCount, error: $0) })
            .onAppear {
                guard let id else {
                    return
                }
                triggerButton.register(id: id, action: perform)
            }
            .onDisappear {
                guard let id else {
                    return
                }
                triggerButton.unregister(id: id)
            }
    }

    public init(
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        @ViewBuilder label: @escaping () -> S
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = label()
    }

    private func perform() {
        guard !state.isLoading, isEnabled else {
            return
        }
        state = .started(Task {
            // Initialize progress
            progress.reset()
            await progress.started()
            do {
                try await action(progress)
            } catch {
                errorCount += 1
                lastError = error
            }
            // Reset progress
            await progress.ended()
            state = .ended
        })
    }

    private func cancel() {
        state.cancel()
    }
}

extension AsyncButton where S == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Text(titleKey)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Text(title)
    }
}

extension AsyncButton where S == Label<Text, Image> {
    public init(
        _ titleKey: LocalizedStringKey,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Label(titleKey, image: name)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Label(title, image: name)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Label(titleKey, image: image)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Label(title, image: image)
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Label(titleKey, systemImage: systemImage)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: progress)
        self.action = action
        self.label = Label(title, systemImage: systemImage)
    }
}

extension AsyncButton where P == IndeterminateProgress {
    public init(
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> S
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = label()
    }
}

extension AsyncButton where P == IndeterminateProgress, S == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Text(titleKey)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Text(title)
    }
}

extension AsyncButton where P == IndeterminateProgress, S == Label<Text, Image> {
    public init(
        _ titleKey: LocalizedStringKey,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Label(titleKey, image: name)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Label(title, image: name)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Label(titleKey, image: image)
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Label(title, image: image)
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Label(titleKey, systemImage: systemImage)
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void
    ) {
        self.role = role
        self.id = id
        self._progress = .init(initialValue: .indeterminate)
        self.action = { _ in try await action()}
        self.label = Label(title, systemImage: systemImage)
    }
}

#Preview("Indeterminate") {
    AsyncButton {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    } label: {
        Text("Process")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}

#Preview("Determinate") {
    AsyncButton(progress: .discrete(totalUnitCount: 100)) { progress in
        for _ in 1...100 {
            try await Task.sleep(nanoseconds: 20_000_000)
            progress.completedUnitCount += 1
        }
    } label: {
        Text("Process")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}

#Preview("Indeterminate error") {
    AsyncButton {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        throw NSError() as Error
    } label: {
        Text("Process")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
    .asyncButtonStyle(.overlay)
    .throwableButtonStyle(.shake)
}

#Preview("Determinate error") {
    AsyncButton(progress: .discrete(totalUnitCount: 100)) { progress in
        for _ in 1...42 {
            try await Task.sleep(nanoseconds: 20_000_000)
            progress.completedUnitCount += 1
        }
        throw NSError() as Error
    } label: {
        Text("Process")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}
