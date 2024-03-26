//
//  AppStoreButtonDemo.swift
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

import ButtonKit
import SwiftUI

struct AppStoreButtonDemo: View {
    @State private var downloaded = false

    var body: some View {
        AsyncButton(progress: .download) { progress in
            guard !downloaded else {
                downloaded = false
                return
            }
            // Indeterminate loading
            try? await Task.sleep(for: .seconds(2))
            progress.bytesToDownload = 100 // Fake
            // Download started!
            for _ in 1...100 {
                try? await Task.sleep(for: .seconds(0.02))
                progress.bytesDownloaded += 1
            }
            // Installation
            try? await Task.sleep(for: .seconds(0.5))
            if !Task.isCancelled {
                downloaded = true
            }
        } label: {
            Text(downloaded ? "Open" : "Get")
        }
        .asyncButtonStyle(.appStore)
        // Otherwise, cancellation is impossible
        .allowsHitTestingWhenLoading(true)
    }
}

#Preview {
    AppStoreButtonDemo()
}

// MARK: - Custom Progress

@MainActor
final class DownloadProgress: TaskProgress {
    @Published var bytesToDownload = 0
    @Published var bytesDownloaded = 0
    
    var fractionCompleted: Double? {
        guard bytesToDownload > 0 else {
            return nil
        }
        return (Double(bytesDownloaded) / Double(bytesToDownload)) * 0.77
    }

    nonisolated init() {}

    func reset() {
        bytesToDownload = 0
        bytesDownloaded = 0
    }
}

extension TaskProgress where Self == DownloadProgress {
    static var download: DownloadProgress {
        DownloadProgress()
    }
}

// MARK: - Custom Style

struct AppStoreButtonStyle: AsyncButtonStyle {
    @Namespace private var namespace

    func makeLabel(configuration: LabelConfiguration) -> some View {
        configuration.label
            .foregroundStyle(.white.opacity(configuration.isLoading ? 0 : 1))
            .aspectRatio(configuration.isLoading ? nil : 1, contentMode: .fill)
            .padding(.horizontal, configuration.isLoading ? 8 : 16)
            .padding(.vertical, 8)
            .bold()
    }

    func makeButton(configuration: ButtonConfiguration) -> some View {
        configuration.button
            .background {
                Capsule()
                    .fill(.tint)
                    .opacity(configuration.isLoading ? 0 : 1)

                if configuration.isLoading {
                    if let progress = configuration.fractionCompleted {
                        AppStoreProgressView(progress: progress)
                    } else {
                        AppStoreLoadingView()
                    }
                }
            }
            .buttonBorderShape(configuration.isLoading ? .circle : .capsule)
            .overlay {
                if configuration.isLoading {
                    if configuration.fractionCompleted != nil {
                        Image(systemName: "stop.fill")
                            .imageScale(.small)
                            .foregroundStyle(.tint)
                    }
                }
            }
            .animation(.default, value: configuration.isLoading)
            .onTapGesture {
                if configuration.isLoading {
                    configuration.cancel()
                }
            }
    }
}

struct AppStoreProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 2)
                .fill(.quaternary)


            Circle()
                .trim(from: 0, to: progress)
                .stroke(lineWidth: 2)
                .fill(.tint)
                .rotationEffect(.degrees(-90))
        }
    }
}

struct AppStoreLoadingView: View {
    @State private var rotation: Double = 0

    var body: some View {
        Circle()
            .trim(from: 0, to: 0.75)
            .stroke(lineWidth: 2)
            .fill(.quaternary)
            .rotationEffect(.degrees(rotation - 135))
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
    }
}

extension AsyncButtonStyle where Self == AppStoreButtonStyle {
    static var appStore: AppStoreButtonStyle {
        AppStoreButtonStyle()
    }
}
