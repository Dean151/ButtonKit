//
//  ThrowableStyle+Shake.swift
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

public struct ShakeThrowableButtonStyle: ThrowableButtonStyle {
    public init() {}

    public func makeButton(configuration: ButtonConfiguration) -> some View {
        configuration.button
            .modifier(Shake(animatableData: CGFloat(configuration.errorCount)))
            .animation(.easeInOut, value: configuration.errorCount)
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

#Preview {
    ThrowableButton {
        throw NSError() as Error
    } label: {
        Text("Shake")
    }
    .buttonStyle(.borderedProminent)
    .throwableButtonStyle(.shake)
}
