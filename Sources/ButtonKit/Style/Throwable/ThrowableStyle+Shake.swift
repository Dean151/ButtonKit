//
//  ThrowableStyle+Shake.swift
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

public struct ShakeThrowableButtonStyle: ThrowableButtonStyle {
    public init() {}

    public func makeButton(configuration: ButtonConfiguration) -> some View {
        ShakeButton(configuration: configuration)
    }
}

private struct ShakeButton: View {
    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    let configuration: ShakeThrowableButtonStyle.ButtonConfiguration

    @ViewBuilder
    var body: some View {
        if reduceMotion {
            configuration.button
                .modifier(Flash(animatableData: CGFloat(configuration.numberOfFailures)))
                .animation(.easeInOut, value: configuration.numberOfFailures)
        } else {
            configuration.button
                .modifier(Shake(animatableData: CGFloat(configuration.numberOfFailures)))
                .animation(.easeInOut, value: configuration.numberOfFailures)
        }
    }
}

extension ThrowableButtonStyle where Self == ShakeThrowableButtonStyle {
    public static var shake: ShakeThrowableButtonStyle {
        ShakeThrowableButtonStyle()
    }
}

struct Shake: GeometryEffect {
    let amount: CGFloat = 10
    let shakesPerUnit = 4
    var animatableData: CGFloat

    nonisolated func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)), y: 0))
    }
}

struct Flash: AnimatableModifier {
    let maximumBrightness: CGFloat = 0.35
    let maximumSaturationReduction: CGFloat = 0.2
    var animatableData: CGFloat

    func body(content: Content) -> some View {
        let phase = animatableData - floor(animatableData)
        let intensity = max(0, sin(phase * .pi))

        content
            .brightness(Double(maximumBrightness * intensity))
            .saturation(Double(1 - maximumSaturationReduction * intensity))
    }
}

#Preview {
    AsyncButton {
        throw NSError() as Error
    } label: {
        Text("Shake")
    }
    .buttonStyle(.borderedProminent)
    .throwableButtonStyle(.shake)
}
