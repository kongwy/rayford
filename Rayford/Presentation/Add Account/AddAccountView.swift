//
//  AddAccountView.swift
//  Rayford
//
//  Created by Weiyi Kong on 21/8/2025.
//

import SwiftUI

struct AddAccountView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        Form {
            Section("Display") {
                TextField("Name", text: $viewModel.name)
                TextField("Issuer", text: $viewModel.issuer)
            }

            Section("Details") {
                TextField("Secret", text: $viewModel.secret)
                Picker("Algorithm", selection: $viewModel.algorithm) {
                    Text("SHA1").tag(Algorithm.sha1)
                    Text("SHA256").tag(Algorithm.sha256)
                    Text("SHA512").tag(Algorithm.sha512)
                }
                Stepper(value: $viewModel.digits) {
                    Text("\(viewModel.digits) digit(s)")
                }
                Picker("Type", selection: $viewModel.kind) {
                    Text("TOTP").tag(Kind.totp(period: viewModel.period))
                    Text("HOTP").tag(Kind.hotp(counter: viewModel.counter))
                }
                switch viewModel.kind {
                case .totp:
                    HStack {
                        Text("Period")
                        Spacer()
                        TextField("30", value: $viewModel.period, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                case .hotp:
                    HStack {
                        Text("Counter")
                        Spacer()
                        TextField("0", value: $viewModel.counter, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    viewModel.cancel()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    viewModel.save()
                }
            }
        }
    }
}

extension AddAccountView {
    class ViewModel: ObservableObject {
        @Published var name: String = ""
        @Published var issuer: String = ""
        @Published var secret: String = ""
        @Published var algorithm: Algorithm = .sha1
        @Published var digits: UInt = 6
        @Published var kind: Kind = .totp(period: 30)
        @Published var period: UInt = 30
        @Published var counter: UInt = 0

        func cancel() {
            print("Cancel tapped!")
        }

        func save() {
            print("Done tapped!")
            print("\(self)")
        }
    }
}

#Preview {
    NavigationView {
        AddAccountView()
    }
}
