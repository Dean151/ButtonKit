//
//  AsyncStyle+SymbolEffect.swift
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

import Symbols
import SwiftUI

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
public struct SymbolEffectAsyncButtonStyle<Effect: SymbolEffect&IndefiniteSymbolEffect>: AsyncButtonStyle {
    let effect: Effect

    public func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
            .symbolEffect(effect, isActive: configuration.isLoading)
    }
}

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<AppearSymbolEffect> {
    public static func symbolEffect(_ effect: AppearSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<DisappearSymbolEffect> {
    public static func symbolEffect(_ effect: DisappearSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<PulseSymbolEffect> {
    public static func symbolEffect(_ effect: PulseSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<ScaleSymbolEffect> {
    public static func symbolEffect(_ effect: ScaleSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<VariableColorSymbolEffect> {
    public static func symbolEffect(_ effect: VariableColorSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}

#if swift(>=6.0)

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<BounceSymbolEffect> {
    public static func symbolEffect(_ effect: BounceSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<BreatheSymbolEffect> {
    public static func symbolEffect(_ effect: BreatheSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<RotateSymbolEffect> {
    public static func symbolEffect(_ effect: RotateSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, visionOS 2.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<WiggleSymbolEffect> {
    public static func symbolEffect(_ effect: WiggleSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}

#endif

#if swift(>=6.2)

@available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<DrawOffSymbolEffect> {
    public static func symbolEffect(_ effect: DrawOffSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}
@available(macOS 26.0, iOS 26.0, tvOS 26.0, watchOS 26.0, *)
extension AsyncButtonStyle where Self == SymbolEffectAsyncButtonStyle<DrawOnSymbolEffect> {
    public static func symbolEffect(_ effect: DrawOnSymbolEffect) -> some AsyncButtonStyle {
        SymbolEffectAsyncButtonStyle(effect: effect)
    }
}

#endif

@available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
#Preview("Indeterminate") {
    AsyncButton {
        try await Task.sleep(nanoseconds: 30_000_000_000)
    } label: {
        Image(systemName: "ellipsis")
    }
    .buttonStyle(.borderedProminent)
    .asyncButtonStyle(.symbolEffect(.pulse))
}
