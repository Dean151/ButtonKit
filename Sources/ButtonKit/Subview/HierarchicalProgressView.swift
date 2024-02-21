//
//  HierarchicalProgressView.swift
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

import Combine
import SwiftUI

public struct HierarchicalProgressView: View {
    @Environment(\.asyncButtonProgressViewSize)
    private var controlSize
    @Environment(\.asyncButtonProgressColor)
    private var progressColor
    @Environment(\.asyncButtonProgressSubject)
    private var progressSubject
    @State private var progress: Double = 0
    
    private var lineWidth: CGFloat {
        switch controlSize {
        case .mini: 1
        case .small: 2
        case .regular: 3
        case .large: 5
        default: 4
        }
    }
    
    private var padding: CGFloat {
        switch controlSize {
        case .mini: 2
        case .small: 2
        case .regular: 2
        case .large: 2
        default: 2
        }
    }
    
    private var width: CGFloat {
        switch controlSize {
        case .mini: 8
        case .small: 13
        case .regular: 20
        case .large: 25
        default: 20
        }
    }
    
    public var body: some View {
        if let progressSubject = progressSubject {
            ZStack {
                Circle()
                    .stroke(
                        progressColor.opacity(0.5),
                        lineWidth: lineWidth
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        progressColor,
                        lineWidth: lineWidth
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.interactiveSpring, value: progress)
            }
            .frame(width: width)
            .padding(padding)
            .onReceive(progressSubject, perform: { p in
                progress = p
            })
//            .colorInvert()
            .contrast(0.8)
        }
        else {
            ProgressView()
                .controlSize(controlSize)
                .opacity(0)
                .overlay {
                    Rectangle()
                        .fill(.primary)
                        .mask {
                            ProgressView().controlSize(controlSize)
                        }
                }
                .compositingGroup()
        }
    }

    public init() {}
}

private let determinantProgressPreviewSubject: CurrentValueSubject<Double, Never> = .init(0)
private let determinantProgressPreviewTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
#Preview("Determinant Progress") {
    HStack {
        VStack {
            HierarchicalProgressView()
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                )
                .asyncButtonProgressViewSize(.mini)
                .environment(\.asyncButtonProgressSubject, determinantProgressPreviewSubject)
//                .overlay {
//                    ProgressView().controlSize(.mini)
//                }
            Text("mini")
        }
        VStack {
            HierarchicalProgressView()
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                )
                .asyncButtonProgressViewSize(.small)
                .environment(\.asyncButtonProgressSubject, determinantProgressPreviewSubject)
//                .overlay {
//                    ProgressView().controlSize(.small)
//                }
            Text("small")
        }
        VStack {
            HierarchicalProgressView()
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                )
                .asyncButtonProgressViewSize(.regular)
                .environment(\.asyncButtonProgressSubject, determinantProgressPreviewSubject)
//                .overlay {
//                    ProgressView().controlSize(.regular)
//                }
            Text("regular")
        }
        VStack {
            HierarchicalProgressView()
                .foregroundStyle(.linearGradient(
                    colors: [.blue, .red],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                )
                .asyncButtonProgressViewSize(.large)
                .environment(\.asyncButtonProgressSubject, determinantProgressPreviewSubject)
//                .overlay {
//                    ProgressView().controlSize(.large)
//                }
            Text("large")
        }
        .onReceive(determinantProgressPreviewTimer, perform: { _ in
            determinantProgressPreviewSubject.send(min(1, determinantProgressPreviewSubject.value + 0.1))
        })
    }.padding(40)
}

#Preview("Indeterminant Progress") {
    HierarchicalProgressView()
        .foregroundStyle(.linearGradient(
            colors: [.blue, .red],
            startPoint: .topLeading,
            endPoint: .bottomTrailing)
        )
}
