//
//  TriggerExample.swift
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

enum FieldName {
    case username
    case password
}

enum FormButton: Hashable {
    case login
    case cancel
}

struct TriggerButtonDemo: View {
    @Environment(\.triggerButton)
    private var triggerButton

    @FocusState private var focus: FieldName?
    @State private var username = "Dean"
    @State private var password = ""

    @State private var success = false

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $username)
                    .focused($focus, equals: .username)
                    .submitLabel(.continue)
                    .onSubmit {
                        focus = .password
                    }

                SecureField("Password", text: $password)
                    .focused($focus, equals: .password)
                    .submitLabel(.send)
                    .onSubmit {
                        triggerButton(id: FormButton.login)
                    }
            } header: {
                Text("You need to login")
            } footer: {
                Text("Press send when the username and password are filled to trigger the Login button")
            }

            Section {
                AsyncButton(id: FormButton.login) {
                    focus = nil
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    success = true
                } label: {
                    Text("Login")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .disabled(username.isEmpty || password.isEmpty)
            }

            Section {
                AsyncButton(role: .destructive, id: FormButton.cancel) {
                    focus = nil
                    username = ""
                    password = ""
                } label: {
                    Text("Reset")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .disabled(username.isEmpty && password.isEmpty)
            }
        }
        .alert(isPresented: $success) {
            Alert(title: Text("Logged in!"), dismissButton: .default(Text("OK")))
        }
        .onChange(of: success) { _ in
            // After a login, reset the fields
            triggerButton(id: FormButton.cancel)
        }
    }
}

#Preview {
    NavigationView {
        TriggerButtonDemo()
    }
}
