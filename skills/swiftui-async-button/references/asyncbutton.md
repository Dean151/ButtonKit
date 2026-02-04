# ButtonKit AsyncButton reference

## Import
```swift
import ButtonKit
```

## Basic replacements for Task or do/catch buttons
Replace:
```swift
Button("Save") {
    Task {
        try await save()
    }
}
```
With:
```swift
AsyncButton {
    try await save()
} label: {
    Text("Save")
}
```

Sync throwing example (non-async).
Replace:
```swift
Button("Do something") {
    do { try something() }
    catch { /* handle */ }
}
```
With:
```swift
AsyncButton {
    try something()
} label: {
    Text("Do something")
}
.onButtonStateError { event in
    // event.error, event.buttonID
}
```

## Loading feedback
AsyncButton shows loading by default (ProgressView replacement) and avoids starting a second task while loading. The button remains enabled/hittable unless you opt out.

Disable interaction while loading:
```swift
AsyncButton { try await work() } label: { Text("Run") }
    .disabledWhenLoading()
```

Or disable hit testing while loading:
```swift
AsyncButton { try await work() } label: { Text("Run") }
    .allowsHitTestingWhenLoading(false)
```

## Loading styles (from Demo/AsyncButtonDemo.swift)
```swift
.asyncButtonStyle(.overlay)
.asyncButtonStyle(.leading)
.asyncButtonStyle(.trailing)
.asyncButtonStyle(.pulse)
.asyncButtonStyle(.symbolEffect(.pulse)) // iOS 17+
.asyncButtonStyle(.symbolEffect(.bounce)) // iOS 18+
.asyncButtonStyle(.none)
```

## Error feedback (from README + Demo/ThrowableButtonDemo.swift)
```swift
.throwableButtonStyle(.shake)
.throwableButtonStyle(.symbolEffect(.bounce)) // iOS 17+
.throwableButtonStyle(.symbolEffect(.wiggle)) // iOS 18+
.throwableButtonStyle(.none)
```

Observe errors:
```swift
.onButtonStateError { event in
    // event.error, event.buttonID
}
```

## State hooks (from Demo/AsyncButtonDemo.swift)
```swift
.onButtonStateChange { event in
    switch event.state {
    case .started:
        break
    case .ended(.completed):
        break
    case .ended(.cancelled):
        break
    case .ended(.errored(let error, _)):
        print(error)
    }
}
```

## External triggers (from Demo/Trigger/TriggerDemo.swift)
Assign an id, then trigger it via environment:
```swift
enum FormButton: Hashable { case login }

AsyncButton(id: FormButton.login) {
    try await login()
} label: {
    Text("Login")
}
```

```swift
@Environment(\.triggerButton) private var triggerButton

triggerButton(id: FormButton.login)
```
Notes:
- The button must be on screen.
- Triggering a disabled or already-loading button does nothing.

## Deterministic progress (from README + Demo/Progress/*)
Discrete progress:
```swift
AsyncButton(progress: .discrete(totalUnitCount: files.count)) { progress in
    for file in files {
        try await file.doExpensiveComputation()
        progress.completedUnitCount += 1
    }
} label: {
    Text("Process")
}
```

Estimated progress:
```swift
AsyncButton(progress: .estimated(for: .seconds(1))) { _ in
    try await Task.sleep(for: .seconds(2))
} label: {
    Text("Process")
}
```

TaskProgress options (from README):
- `.indeterminate`
- `.discrete(totalUnitCount: Int)`
- `.estimated(nanoseconds: UInt64)`
- `.estimated(for: Duration)` // iOS 16+
- `.progress` (bridge to Foundation `Progress` / `NSProgress`)

## Advanced customization (from Demo/Advanced/AppStoreButtonDemo.swift)
- Implement `TaskProgress` for custom progress math (e.g., download and install phases).
- Implement `AsyncButtonStyle` to custom-render loading states and support cancel UI.
- Implement `ThrowableButtonStyle` to custom-render errored states.

## Demo entry points
- `Demo/ButtonKitDemo/Buttons/AsyncButtonDemo.swift`
- `Demo/ButtonKitDemo/Buttons/ThrowableButtonDemo.swift`
- `Demo/ButtonKitDemo/Trigger/TriggerDemo.swift`
- `Demo/ButtonKitDemo/Progress/DiscreteProgressDemo.swift`
- `Demo/ButtonKitDemo/Progress/EstimatedProgressDemo.swift`
- `Demo/ButtonKitDemo/Advanced/AppStoreButtonDemo.swift`
