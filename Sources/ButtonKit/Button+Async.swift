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

public struct AsyncButton<P: ProgressKind, S: View>: View {
    @Environment(\.asyncButtonStyle)
    private var asyncButtonStyle
    @Environment(\.allowsHitTestingWhenLoading)
    private var allowsHitTestingWhenLoading
    @Environment(\.disabledWhenLoading)
    private var disabledWhenLoading
    @Environment(\.progressButtonStyle)
    private var progressButtonStyle
    @Environment(\.throwableButtonStyle)
    private var throwableButtonStyle

    private let role: ButtonRole?
    private let progressKind: P
    private let action: @MainActor (Binding<Progress>) async throws -> Void
    private let label: S

    @State private var progress: Progress
    @State private var task: Task<Void, Never>?
    @State private var errorCount = 0

    public var body: some View {
        let throwableLabelConfiguration = ThrowableButtonStyleLabelConfiguration(
            label: AnyView(label),
            errorCount: errorCount
        )
        let label: AnyView
        if progressKind is IndeterminateProgress {
            let asyncLabelConfiguration = AsyncButtonStyleLabelConfiguration(
                isLoading: task != nil,
                label: AnyView(throwableButtonStyle.makeLabel(configuration: throwableLabelConfiguration)),
                cancel: cancel
            )
            label = asyncButtonStyle.makeLabel(configuration: asyncLabelConfiguration)
        } else {
            let progressLabelConfiguration = ProgressButtonStyleLabelConfiguration(
                isLoading: task != nil,
                progress: progress,
                label: AnyView(throwableButtonStyle.makeLabel(configuration: throwableLabelConfiguration)),
                cancel: cancel
            )
            label = progressButtonStyle.makeLabel(configuration: progressLabelConfiguration)
        }
        let button = Button(role: role) {
            guard task == nil else {
                return
            }
            task = Task {
                progress.initialize()
                do {
                    try await action($progress)
                    if !Task.isCancelled {
                        progress.finish()
                    }
                } catch {
                    errorCount += 1
                }
                task = nil
            }
        } label: {
            label
        }
        let throwableConfiguration = ThrowableButtonStyleButtonConfiguration(
            button: AnyView(button),
            errorCount: errorCount
        )
        let asyncConfiguration = AsyncButtonStyleButtonConfiguration(
            isLoading: task != nil,
            button: AnyView(throwableButtonStyle.makeButton(configuration: throwableConfiguration)),
            cancel: cancel
        )
        return asyncButtonStyle
            .makeButton(configuration: asyncConfiguration)
            .allowsHitTesting(allowsHitTestingWhenLoading || task == nil)
            .disabled(disabledWhenLoading && task != nil)
            .preference(key: AsyncButtonTaskPreferenceKey.self, value: task)
    }

    public init(role: ButtonRole? = nil, progress: P, action: @escaping (Binding<Progress>) async throws -> Void, @ViewBuilder label: @escaping () -> S) {
        self.role = role
        self.progressKind = progress
        self._progress = .init(initialValue: Progress(kind: progress))
        self.action = action
        self.label = label()
    }

    private func cancel() {
        task?.cancel()
        task = nil
    }
}

extension AsyncButton where S == Text {
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, progress: P, action: @escaping (Binding<Progress>) async throws -> Void) {
        self.role = role
        self.progressKind = progress
        self._progress = .init(initialValue: Progress(kind: progress))
        self.action = action
        self.label = Text(titleKey)
    }

    public init(_ title: some StringProtocol, role: ButtonRole? = nil, progress: P, action: @escaping (Binding<Progress>) async throws -> Void) {
        self.role = role
        self.progressKind = progress
        self._progress = .init(initialValue: Progress(kind: progress))
        self.action = action
        self.label = Text(title)
    }
}

extension AsyncButton where P == IndeterminateProgress {
    public init(role: ButtonRole? = nil, action: @escaping () async throws -> Void, @ViewBuilder label: @escaping () -> S) {
        self.role = role
        self.progressKind = IndeterminateProgress()
        self._progress = .init(initialValue: Progress(kind: .indeterminate))
        self.action = { _ in try await action()}
        self.label = label()
    }
}

extension AsyncButton where P == IndeterminateProgress, S == Text {
    public init(_ titleKey: LocalizedStringKey, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.role = role
        self.progressKind = IndeterminateProgress()
        self._progress = .init(initialValue: Progress(kind: .indeterminate))
        self.action = { _ in try await action()}
        self.label = Text(titleKey)
    }

    public init(_ title: some StringProtocol, role: ButtonRole? = nil, action: @escaping () async throws -> Void) {
        self.role = role
        self.progressKind = IndeterminateProgress()
        self._progress = .init(initialValue: Progress(kind: .indeterminate))
        self.action = { _ in try await action()}
        self.label = Text(title)
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
            progress.wrappedValue.completedUnitCount += 1
        }
    } label: {
        Text("Process")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}

#Preview("Indeterminate error") {
    AsyncButton {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
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
            progress.wrappedValue.completedUnitCount += 1
        }
        throw NSError() as Error
    } label: {
        Text("Process")
    }
    .buttonStyle(.borderedProminent)
    .buttonBorderShape(.roundedRectangle)
}
