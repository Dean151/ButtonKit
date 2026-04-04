//
//  AsyncButtonModel.swift
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

import Combine
import SwiftUI

@MainActor
final class AsyncButtonModel<P: TaskProgress>: ObservableObject {
    let progress: P

    @Published private(set) var state: AsyncButtonState?
    @Published private(set) var numberOfFailures = 0
    @Published private(set) var latestError: Error?

    private let action: @MainActor (P) async throws -> Void
    private let onStateChange: (@MainActor (AsyncButtonState) -> Void)?
    private var isDisabled = false
    private var progressObservation: AnyCancellable?

    var isLoading: Bool {
        state?.isLoading ?? false
    }

    init(
        progress: P,
        action: @escaping @MainActor (P) async throws -> Void,
        onStateChange: (@MainActor (AsyncButtonState) -> Void)?
    ) {
        self.progress = progress
        self.action = action
        self.onStateChange = onStateChange
        self.progressObservation = progress.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    func setDisabled(_ disabled: Bool) {
        isDisabled = disabled
    }

    func perform() {
        guard !isDisabled, !isLoading else {
            return
        }

        let task = Task {
            await runAction()
        }
        update(state: .started(task))
    }

    func cancel() {
        state?.cancel()
    }

    private func runAction() async {
        progress.reset()
        await progress.started()

        let completion = await completionForCurrentRun()

        await progress.ended()
        update(state: .ended(Task.isCancelled ? .cancelled : completion))
    }

    private func completionForCurrentRun() async -> AsyncButtonCompletion {
        do {
            try await action(progress)
            return Task.isCancelled ? .cancelled : .completed
        } catch is CancellationError {
            return .cancelled
        } catch {
            guard !Task.isCancelled else {
                return .cancelled
            }

            latestError = error
            numberOfFailures += 1
            return .errored(error: error, numberOfFailures: numberOfFailures)
        }
    }

    private func update(state newState: AsyncButtonState) {
        state = newState
        onStateChange?(newState)
    }
}
