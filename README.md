# ButtonKit

ButtonKit provide two SwiftUI buttons to deal with throwable and asynchronous actions.
By default, SwiftUI button only accept a closure.

With ButtonKit, you'll have access to:
- `ThrowableButton`, accepting a `() throws -> Void` closure
- `AsyncButton`, accepting a `() async throws -> Void` closure

## Requirements

- Swift 5.9+ (Xcode 15+)
- iOS 15+, iPadOS 15+, tvOS 15+, watchOS 8+, macOS 12+, visionOS 1+

## Installation

Install using Swift Package Manager

```
dependencies: [
    .package(url: "https://github.com/Dean151/ButtonKit.git", from: "0.1.0"),
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "ButtonKit", package: "ButtonKit"),
    ]),
]
```

And import it:
```swift
import SwiftUI
import ButtonKit
```

## Usage

### Throwable

Use it as any SwiftUI button, but throw if you want in the closure:

```swift
ThrowableButton {
    try doSomethingThatCanFail()
} label {
    Text("Do something")
}
```

By default, when the button closure throws, the button will Shake on error.
For now, only the shake behavior is built-in:

| `.shake` | <img src="/Preview/shake.gif">

You can disable it by passing `.none` to throwableButtonStyle:

```swift
ThrowableButton {
    try doSomethingThatCanFail()
} label {
    Text("Do something")
}
.throwableButtonStyle(.none)
```

You can also bring your own behavior using the `ThrowableButtonStyle` protocol.

In ThrowableButtonStyle, you can implement `makeLabel`, `makeButton` or both to alterate the button look and behavior.

```swift
public struct TryAgainThrowableButtonStyle: ThrowableButtonStyle {
    public init() {}

    public func makeLabel(configuration: LabelConfiguration) -> some View {
        if configuration.errorCount > 0 {
            Text("Try again!")
        } else {
            configuration.label
        }
    }
}

extension ThrowableButtonStyle where Self == TryAgainThrowableButtonStyle {
    public static var tryAgain: some ThrowableButtonStyle {
        TryAgainThrowableButtonStyle()
    }
}
```

Then, use it:
```swift
ThrowableButton {
    try doSomethingThatCanFail()
} label {
    Text("Do something")
}
.throwableButtonStyle(.tryAgain)
```

### Asynchronous

Use it as any SwiftUI button, but the closure will support both try and await.
When the process is in progress, the button hit test will be disabled, and the process will only triggers once.

```swift
AsyncButton {
    try await doSomethingThatTakeTime()
} label {
    Text("Do something")
}
```

While the progress is loading, the button will animate, defaulting by replacing the label of the button with a `ProgressIndicator`.
All sort of styles are built-in:

| `.overlay` | <img src="/Preview/overlay.gif">
| `.leading` | <img src="/Preview/leading.gif">
| `.trailing` | <img src="/Preview/trailing.gif">
| `.pulse` | <img src="/Preview/pulse.gif">

You can disable this behavior by passing `.none` to `asyncButtonStyle`
```swift
AsyncButton {
    try await doSomethingThatTakeTime()
} label {
    Text("Do something")
}
.asyncButtonStyle(.none)
```

`AsyncButton` also support throwableButtonStyle modifier.

You can also build your own customization by implementing `AsyncButtonStyle` protocol.

Just like `ThrowableButtonStyle`, `AsyncButtonStyle` allow you to implement either `makeLabel`, `makeButton` or both to alterate the button look and behavior while loading is in progress.

## Contribute

You are encouraged to contribute to this repository, by opening issues, or pull requests for bug fixes, improvement requests, or support. Suggestions for contributing:

- Improving documentation
- Adding some automated tests 😜
- Helping me out to remove/improve all the type erasure stuff if possible?
- Adding some new built-in styles, options or properties for more use cases
