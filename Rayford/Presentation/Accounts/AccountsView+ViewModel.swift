//
//  AccountsView+ViewModel.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import Foundation
import SwiftUI

extension AccountsView {
    class ViewModel: ObservableObject {
        private var accounts = [Account]()
        @Published var cellModels = [AccountCellView.Model]()
        private var timer: Timer!

        init() { }

        func setup(with store: Store) {
            accounts = store.appState.accounts
            cellModels = accounts.map(Self.cellModel(for:))
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else { return }
                self.cellModels = self.accounts.map(Self.cellModel(for:))
            }
        }

        static func cellModel(for account: Account) -> AccountCellView.Model {
            let accessoryType: AccountCellView.AccessoryType = switch account.password.kind {
            case .hotp: .nextButton {  }
            case .totp: .progressCircle(value: account.password.progress(), text: "\(account.password.secondsRemaining())")
            }
            return AccountCellView.Model(id: account.id,
                                         passcode: account.password.value(),
                                         description: account.displayName,
                                         accessoryType: accessoryType)
        }
    }
}
