//
//  ThrowableStyle+SymbolEffect.swift
//  ButtonKit
//
//  MIT License
//
//  Copyright (c) 2025 Thomas Durand
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

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SymbolEffectThrowableButtonStyle<Effect: SymbolEffect&DiscreteSymbolEffect>: ThrowableButtonStyle {
    let effect: Effect

    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
            .symbolEffect(effect, value: configuration.numberOfFailures)
    }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension ThrowableButtonStyle where Self == SymbolEffectThrowableButtonStyle<BounceSymbolEffect> {
    public static func symbolEffect(_ effect: BounceSymbolEffect) -> some ThrowableButtonStyle {
        SymbolEffectThrowableButtonStyle(effect: effect)
    }
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension ThrowableButtonStyle where Self == SymbolEffectThrowableButtonStyle<PulseSymbolEffect> {
    public static func symbolEffect(_ effect: PulseSymbolEffect) -> some ThrowableButtonStyle {
        SymbolEffectThrowableButtonStyle(effect: effect)
    }
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension ThrowableButtonStyle where Self == SymbolEffectThrowableButtonStyle<VariableColorSymbolEffect> {
    public static func symbolEffect(_ effect: VariableColorSymbolEffect) -> some ThrowableButtonStyle {
        SymbolEffectThrowableButtonStyle(effect: effect)
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension ThrowableButtonStyle where Self == SymbolEffectThrowableButtonStyle<BreatheSymbolEffect> {
    public static func symbolEffect(_ effect: BreatheSymbolEffect) -> some ThrowableButtonStyle {
        SymbolEffectThrowableButtonStyle(effect: effect)
    }
}
@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension ThrowableButtonStyle where Self == SymbolEffectThrowableButtonStyle<RotateSymbolEffect> {
    public static func symbolEffect(_ effect: RotateSymbolEffect) -> some ThrowableButtonStyle {
        SymbolEffectThrowableButtonStyle(effect: effect)
    }
}
@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension ThrowableButtonStyle where Self == SymbolEffectThrowableButtonStyle<WiggleSymbolEffect> {
    public static func symbolEffect(_ effect: WiggleSymbolEffect) -> some ThrowableButtonStyle {
        SymbolEffectThrowableButtonStyle(effect: effect)
    }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
#Preview {
    AsyncButton {
        throw NSError() as Error
    } label: {
        Label("Hello", systemImage: "link")
    }
    .buttonStyle(.borderedProminent)
    .throwableButtonStyle(.symbolEffect(.bounce))
}
