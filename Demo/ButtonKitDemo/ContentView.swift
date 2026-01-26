//
//  ContentView.swift
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

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section {
                    NavigationLink {
                        ThrowableButtonDemo()
                    } label: {
                        Text("Throwable Button")
                    }

                    NavigationLink {
                        AsyncButtonDemo()
                    } label: {
                        Text("Async Button")
                    }
                } header: {
                    Text("Basics")
                }

                Section {
                    NavigationLink {
                        TriggerButtonDemo()
                    } label: {
                        Text("Programmatic Trigger")
                    }
                } header: {
                    Text("Triggers")
                }

                Section {
                    NavigationLink {
                        DiscreteProgressDemo()
                    } label: {
                        Text("Discrete Progress")
                    }

                    NavigationLink {
                        EstimatedProgressDemo()
                    } label: {
                        Text("Estimated Progress")
                    }
                } header: {
                    Text("Determinate progress")
                }

                if #available(iOS 17, macOS 14, *) {
                    Section {
                        NavigationLink {
                            AppStoreButtonDemo()
                        } label: {
                            Text("App Store Download")
                        }
                    } header: {
                        Text("Customization")
                    }
                }
            }
            .navigationTitle("ButtonKit")
        }
    }
}

#Preview {
    ContentView()
}
