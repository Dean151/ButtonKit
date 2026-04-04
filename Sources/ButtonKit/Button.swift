//
//  Button.swift
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

@available(*, deprecated, renamed: "AsyncButton")
public typealias ThrowableButton = AsyncButton

public enum AsyncButtonCompletion: Equatable {
    case completed
    case cancelled
    case errored(error: Error, numberOfFailures: Int)

    public static func ==(lhs: AsyncButtonCompletion, rhs: AsyncButtonCompletion) -> Bool {
        switch (lhs, rhs) {
        case (.completed, .completed): true
        case (.cancelled, .cancelled): true
        case let (.errored(_, lhs), .errored(_, rhs)): lhs == rhs
        default: false
        }
    }
}

@MainActor
public enum AsyncButtonState: Equatable {
    case started(Task<Void, Never>)
    case ended(AsyncButtonCompletion)

    mutating func cancel() {
        switch self {
        case let .started(task):
            task.cancel()
        default:
            break
        }
    }

    public var isLoading: Bool {
        switch self {
        case .started:
            return true
        case .ended:
            return false
        }
    }

    public var error: Error? {
        switch self {
        case let .ended(.errored(error, _)): error
        default: nil
        }
    }

    @available(*, deprecated)
    var task: Task<Void, Never>? {
        switch self {
        case let .started(task): task
        default : nil
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
    private let label: S

    @State private var uuid = UUID()
    @StateObject private var model: AsyncButtonModel<P>

    public var body: some View {
        let throwableLabelConfiguration = ThrowableButtonStyleLabelConfiguration(
            label: AnyView(label),
            latestError: model.latestError,
            numberOfFailures: model.numberOfFailures
        )
        let label: AnyView
        let asyncLabelConfiguration = AsyncButtonStyleLabelConfiguration(
            label: AnyView(throwableButtonStyle.makeLabel(configuration: throwableLabelConfiguration)),
            isLoading: model.isLoading,
            fractionCompleted: model.progress.fractionCompleted,
            cancel: model.cancel
        )
        label = asyncButtonStyle.makeLabel(configuration: asyncLabelConfiguration)
        let button = Button(role: role, action: model.perform) {
            label
        }
        let throwableConfiguration = ThrowableButtonStyleButtonConfiguration(
            button: AnyView(button),
            latestError: model.latestError,
            numberOfFailures: model.numberOfFailures
        )
        let asyncConfiguration = AsyncButtonStyleButtonConfiguration(
            button: AnyView(throwableButtonStyle.makeButton(configuration: throwableConfiguration)),
            isLoading: model.isLoading,
            fractionCompleted: model.progress.fractionCompleted,
            cancel: model.cancel
        )
        return asyncButtonStyle
            .makeButton(configuration: asyncConfiguration)
            .allowsHitTesting(allowsHitTestingWhenLoading || !model.isLoading)
            .disabled(disabledWhenLoading && model.isLoading)
            .accessibilityAddTraits(model.isLoading ? .updatesFrequently : [])
            .preference(
                key: ButtonLatestStatePreferenceKey.self,
                value: model.state.flatMap { .init(buttonID: id ?? uuid as AnyHashable, state: $0) }
            )
            .onAppear {
                model.setDisabled(!isEnabled)
                guard let id else {
                    return
                }
                triggerButton.register(id: id, action: model.perform)
            }
            .onDisappear {
                guard let id else {
                    return
                }
                triggerButton.unregister(id: id)
            }
            .onChange(of: isEnabled) { newValue in
                model.setDisabled(!newValue)
            }
    }

    init(
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        label: S,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.role = role
        self.id = id
        self.label = label
        self._model = .init(wrappedValue: AsyncButtonModel(
            progress: progress,
            action: action,
            onStateChange: onStateChange
        ))
    }

    public init(
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        @ViewBuilder label: @escaping () -> S,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: label(),
            onStateChange: onStateChange
        )
    }
}

extension AsyncButton where S == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Text(titleKey),
            onStateChange: onStateChange
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Text(title),
            onStateChange: onStateChange
        )
    }
}

extension AsyncButton where S == Label<Text, Image> {
    public init(
        _ titleKey: LocalizedStringKey,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Label(titleKey, image: name),
            onStateChange: onStateChange
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Label(title, image: name),
            onStateChange: onStateChange
        )
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Label(titleKey, image: image),
            onStateChange: onStateChange
        )
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Label(title, image: image),
            onStateChange: onStateChange
        )
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Label(titleKey, systemImage: systemImage),
            onStateChange: onStateChange
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        progress: P,
        action: @MainActor @escaping (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: progress,
            action: action,
            label: Label(title, systemImage: systemImage),
            onStateChange: onStateChange
        )
    }
}

extension AsyncButton where P == IndeterminateProgress {
    public init(
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> S,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: label(),
            onStateChange: onStateChange
        )
    }
}

extension AsyncButton where P == IndeterminateProgress, S == Text {
    public init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Text(titleKey),
            onStateChange: onStateChange
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Text(title),
            onStateChange: onStateChange
        )
    }
}

extension AsyncButton where P == IndeterminateProgress, S == Label<Text, Image> {
    public init(
        _ titleKey: LocalizedStringKey,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Label(titleKey, image: name),
            onStateChange: onStateChange
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image name: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Label(title, image: name),
            onStateChange: onStateChange
        )
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    public init(
        _ titleKey: LocalizedStringKey,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Label(titleKey, image: image),
            onStateChange: onStateChange
        )
    }

    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        image: ImageResource,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Label(title, image: image),
            onStateChange: onStateChange
        )
    }

    public init(
        _ titleKey: LocalizedStringKey,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Label(titleKey, systemImage: systemImage),
            onStateChange: onStateChange
        )
    }

    @_disfavoredOverload
    public init(
        _ title: some StringProtocol,
        systemImage: String,
        role: ButtonRole? = nil,
        id: AnyHashable? = nil,
        action: @escaping () async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)? = nil
    ) {
        self.init(
            role: role,
            id: id,
            progress: .indeterminate,
            action: { _ in try await action() },
            label: Label(title, systemImage: systemImage),
            onStateChange: onStateChange
        )
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
