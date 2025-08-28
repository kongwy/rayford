//
//  EditAccountView.swift
//  Rayford
//
//  Created by Weiyi Kong on 26/8/2025.
//

import SwiftUI

struct EditAccountView: View {
    @EnvironmentObject var store: Store
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section("Display") {
                TextField("Name", text: $viewModel.name)
                TextField("Issuer", text: $viewModel.issuer)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    viewModel.save(in: store)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditAccountView(viewModel: .init(account: mockStore.appState.accounts.randomElement()!))
    }
}
