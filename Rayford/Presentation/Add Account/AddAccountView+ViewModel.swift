//
//  ViewModel.swift
//  Rayford
//
//  Created by Weiyi Kong on 26/8/2025.
//

import SwiftUI

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

        func save(in store: Store) {
            guard let password = Password(kind: kind, algorithm: algorithm, base32: secret, digits: digits) else { return }
            let newAccount = Account(name: name, issuer: issuer, password: password)
            store.appState.accounts.append(newAccount)
        }
    }
}
