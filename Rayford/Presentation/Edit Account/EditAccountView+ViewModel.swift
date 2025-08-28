//
//  EditAccountView+ViewModel.swift
//  Rayford
//
//  Created by Weiyi Kong on 28/8/2025.
//

import SwiftUI

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
