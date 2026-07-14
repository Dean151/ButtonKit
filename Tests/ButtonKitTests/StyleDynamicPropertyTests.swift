import SwiftUI
import Testing
@testable import ButtonKit

extension EnvironmentValues {
    @Entry fileprivate var styleProbeValue: Int = 0
}

@MainActor
private final class StyleProbeBox {
    var asyncStyleValue: Int?
    var throwableStyleValue: Int?
}

private struct ProbeAsyncButtonStyle: AsyncButtonStyle {
    @Environment(\.styleProbeValue) private var probeValue
    let box: StyleProbeBox

    func makeButton(configuration: ButtonConfiguration) -> some View {
        box.asyncStyleValue = probeValue
        return configuration.button
    }
}

private struct ProbeThrowableButtonStyle: ThrowableButtonStyle {
    @Environment(\.styleProbeValue) private var probeValue
    let box: StyleProbeBox

    func makeButton(configuration: ButtonConfiguration) -> some View {
        box.throwableStyleValue = probeValue
        return configuration.button
    }
}

@MainActor
struct StyleDynamicPropertyTests {
    @Test
    @available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *)
    func stylesReadEnvironmentValuesThroughDynamicProperty() {
        let box = StyleProbeBox()
        let button = AsyncButton(action: {}, label: { Text("Probe") })
            .asyncButtonStyle(ProbeAsyncButtonStyle(box: box))
            .throwableButtonStyle(ProbeThrowableButtonStyle(box: box))
            .environment(\.styleProbeValue, 42)

        let renderer = ImageRenderer(content: button)
        #if canImport(AppKit)
        _ = renderer.nsImage
        #else
        _ = renderer.uiImage
        #endif

        #expect(box.asyncStyleValue == 42)
        #expect(box.throwableStyleValue == 42)
    }
}
