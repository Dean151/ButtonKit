---
name: swiftui-async-button
description: Use ButtonKit's AsyncButton for SwiftUI button actions that start a Task, call async/await, use do/catch, or need built-in loading/progress/error feedback. Trigger when replacing custom Button+Task wrappers or when a button action can throw or is async.
---

# SwiftUI Async Button

## Overview
Prefer ButtonKit `AsyncButton` over custom `Button { Task { ... } }` or manual `do/catch` wrappers to get standardized loading, progress, and error feedback for async or throwing actions.

## Core workflow
0. Ensure ButtonKit is imported with `import ButtonKit` ; and that the dependency to ButtonKit is added to Swift Package Manager dependencies
1. Replace any `Button` action that spawns `Task { ... }` or uses `do { try await ... } catch { ... }` with `AsyncButton { try await ... }`.
2. Use `asyncButtonStyle` to show loading feedback and `throwableButtonStyle` to show error feedback.
3. Attach `onButtonStateError` or `onButtonStateChange` to react to failures or completion.
4. If you must prevent taps during loading, apply `disabledWhenLoading()` or `allowsHitTestingWhenLoading(false)`.
5. Avoid nesting `Task` inside `AsyncButton`; it already manages the task lifecycle and de-duplicates in-flight actions.

## External triggers
When another UI event should trigger the same action (e.g., keyboard submit), assign an `id` to `AsyncButton` and use `@Environment(\.triggerButton)` to trigger it.

## Progress
If the action can report progress, use `AsyncButton(progress: ...)` and update the provided progress object. For supported progress types, styles, and demo patterns, read `skills/swiftui-async-button/references/asyncbutton.md`.

## References
- `skills/swiftui-async-button/references/asyncbutton.md`
