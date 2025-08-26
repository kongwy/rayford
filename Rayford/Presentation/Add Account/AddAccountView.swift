//
//  AddAccountView.swift
//  Rayford
//
//  Created by Weiyi Kong on 21/8/2025.
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var store: Store
    @StateObject var viewModel: ViewModel

    var body: some View {
        NavigationStack {
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
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancel()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        viewModel.save(in: store)
                    }
                }
            }
        }
    }
}



#Preview {
    @State var isPresented = true

    NavigationView {
        AddAccountView(viewModel: .init(isPresented: $isPresented))
    }
}
