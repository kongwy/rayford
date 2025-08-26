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

extension EditAccountView {
    class ViewModel: ObservableObject {
        private let id: UUID
        @Published var name: String
        @Published var issuer: String

        init(account: Account) {
            self.id = account.id
            self.name = account.name ?? ""
            self.issuer = account.issuer ?? ""
        }

        init?(id: UUID, in store: Store = .shared) {
            guard let account = store.appState.accounts[id: id] else { return nil }
            self.id = account.id
            self.name = account.name ?? ""
            self.issuer = account.issuer ?? ""
        }

        func save(in store: Store = .shared) {
            store.appState.accounts.update(id: id) { account in
                account.name = name
                account.issuer = issuer
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditAccountView(viewModel: .init(account: mockState.accounts.randomElement()!))
    }
}
