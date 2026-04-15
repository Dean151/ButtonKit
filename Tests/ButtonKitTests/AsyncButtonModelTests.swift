import SwiftUI
import Testing
@testable import ButtonKit

@MainActor
struct AsyncButtonModelTests {
    @Test
    func completionPublishesStartedThenCompleted() async throws {
        let progress = ProgressProbe()
        var states: [AsyncButtonState] = []

        let model = AsyncButtonModel(
            progress: progress,
            action: { _ in
                try await Task.sleep(nanoseconds: 1_000_000)
            },
            onStateChange: { states.append($0) }
        )

        model.perform()
        let task = try #require(startedTask(in: states))
        await task.value

        #expect(states.count == 2)
        #expect(progress.resetCount == 1)
        #expect(progress.startedCount == 1)
        #expect(progress.endedCount == 1)
        #expect(model.numberOfFailures == 0)
        #expect(model.latestError == nil)

        guard case .ended(.completed) = model.state else {
            Issue.record("Expected a completed terminal state.")
            return
        }
    }

    @Test
    func cancellationPublishesSingleCancelledState() async throws {
        let progress = ProgressProbe()
        var states: [AsyncButtonState] = []

        let model = AsyncButtonModel(
            progress: progress,
            action: { _ in
                try await Task.sleep(nanoseconds: 1_000_000_000)
            },
            onStateChange: { states.append($0) }
        )

        model.perform()
        let task = try #require(startedTask(in: states))
        model.cancel()
        await task.value

        #expect(states.count == 2)
        #expect(progress.startedCount == 1)
        #expect(progress.endedCount == 1)
        #expect(progress.cancelCount == 1)
        #expect(model.numberOfFailures == 0)
        #expect(model.latestError == nil)

        guard case .ended(.cancelled) = model.state else {
            Issue.record("Expected cancellation to be the only terminal state.")
            return
        }
    }

    @Test
    func cancellationErrorDoesNotIncrementFailures() async throws {
        let progress = ProgressProbe()

        let model = AsyncButtonModel(
            progress: progress,
            action: { _ in
                throw CancellationError()
            },
            onStateChange: { _ in }
        )

        model.perform()
        let state = try #require(model.state)
        let task = try #require(startedTask(in: [state]))
        await task.value

        #expect(model.numberOfFailures == 0)
        #expect(model.latestError == nil)

        guard case .ended(.cancelled) = model.state else {
            Issue.record("Expected a cancelled terminal state.")
            return
        }
    }

    @Test
    func cancellationAfterFailurePreservesFailureState() async throws {
        let progress = ProgressProbe()
        let gate = AsyncGate()
        var runCount = 0

        let model = AsyncButtonModel(
            progress: progress,
            action: { _ in
                runCount += 1
                if runCount == 1 {
                    throw SampleError.failed
                }

                await gate.wait()
            },
            onStateChange: { _ in }
        )

        model.perform()
        let firstState = try #require(model.state)
        let firstTask = try #require(startedTask(in: [firstState]))
        await firstTask.value

        #expect(model.numberOfFailures == 1)
        #expect((model.latestError as? SampleError) == .failed)

        model.perform()
        let secondState = try #require(model.state)
        let secondTask = try #require(startedTask(in: [secondState]))
        model.cancel()
        await gate.open()
        await secondTask.value

        #expect(model.numberOfFailures == 1)
        #expect((model.latestError as? SampleError) == .failed)

        guard case .ended(.cancelled) = model.state else {
            Issue.record("Expected the second run to finish as cancelled.")
            return
        }
    }

    @Test
    func nonCooperativeActionStillFinishesAsCancelled() async throws {
        let progress = ProgressProbe()
        let gate = AsyncGate()

        let model = AsyncButtonModel(
            progress: progress,
            action: { _ in
                await gate.wait()
            },
            onStateChange: { _ in }
        )

        model.perform()
        let state = try #require(model.state)
        let task = try #require(startedTask(in: [state]))
        model.cancel()
        await gate.open()
        await task.value

        guard case .ended(.cancelled) = model.state else {
            Issue.record("Expected a cancelled terminal state even for non-cooperative work.")
            return
        }
    }

    @Test
    func stateChangedEventExtractsCancellationAndErrorSignals() {
        let cancelledEvent = StateChangedEvent(buttonID: "cancel", state: .ended(.cancelled))
        #expect(cancelledEvent.cancelledButtonID == AnyHashable("cancel"))
        #expect(cancelledEvent.errorOccurredEvent == nil)

        let erroredEvent = StateChangedEvent(buttonID: "error", state: .ended(.errored(error: SampleError.failed, numberOfFailures: 1)))
        #expect(erroredEvent.cancelledButtonID == nil)
        #expect(erroredEvent.errorOccurredEvent?.buttonID == AnyHashable("error"))
        #expect((erroredEvent.errorOccurredEvent?.error as? SampleError) == .failed)
    }

    @Test
    func estimatedProgressStopsUpdatingAfterEnd() async throws {
        let progress: EstimatedProgress = .estimated(nanoseconds: 50_000_000)

        await progress.started()
        try await Task.sleep(nanoseconds: 10_000_000)

        let beforeEnd = progress.fractionCompleted ?? 0
        await progress.ended()
        let afterEnd = progress.fractionCompleted

        try await Task.sleep(nanoseconds: 20_000_000)

        #expect(beforeEnd > 0)
        #expect(afterEnd == 1)
        #expect(progress.fractionCompleted == afterEnd)
    }

    @Test
    func nsProgressBridgeCancelsUnderlyingProgress() {
        let bridge: NSProgressBridge = .progress
        let progress = Progress(totalUnitCount: 1)

        bridge.nsProgress = progress
        bridge.cancel()

        #expect(progress.isCancelled)
    }
}

private func startedTask(in states: [AsyncButtonState]) -> Task<Void, Never>? {
    for state in states {
        if case let .started(task) = state {
            return task
        }
    }

    return nil
}

@MainActor
private final class ProgressProbe: TaskProgress {
    @Published var fractionCompleted: Double?
    private(set) var resetCount = 0
    private(set) var cancelCount = 0
    private(set) var startedCount = 0
    private(set) var endedCount = 0

    func reset() {
        resetCount += 1
        fractionCompleted = 0
    }

    func cancel() {
        cancelCount += 1
    }

    func started() async {
        startedCount += 1
    }

    func ended() async {
        endedCount += 1
    }
}

private actor AsyncGate {
    private var continuations: [CheckedContinuation<Void, Never>] = []
    private var isOpen = false

    func wait() async {
        guard !isOpen else {
            return
        }

        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func open() {
        isOpen = true
        let pending = continuations
        continuations.removeAll()

        for continuation in pending {
            continuation.resume()
        }
    }
}

private enum SampleError: Error {
    case failed
}
