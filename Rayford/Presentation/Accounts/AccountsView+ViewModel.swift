//
//  AccountsView+ViewModel.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import SwiftUI
import Combine

extension AccountsView {
    class ViewModel: ObservableObject {
        private var passwordManager: PasswordManager

        @Published var presentAddAccountView = false
        @Published var cellModels = [AccountCellView.Model]()

        private var cancellable = Set<AnyCancellable>()

        init(with store: Store = .shared) {
            passwordManager = PasswordManager(store: store)
            store.publisher(\.accounts)
                .combineLatest(passwordManager.passcodes, passwordManager.progresses, passwordManager.secondsRemainings)
                .sink { [weak self] accounts, passcodes, progresses, secondsRemainings in
                    self?.cellModels = accounts.compactMap { account in
                        guard let passcode = passcodes[account.id] else { return nil }
                        let accessoryType: AccountCellView.AccessoryType
                        switch account.password.kind {
                        case .hotp:
                            accessoryType = .nextButton {}
                        case .totp:
                            guard let progress = progresses[account.id], let secondsRemaining = secondsRemainings[account.id] else { return nil }
                            accessoryType = .progressCircle(value: progress, text: "\(secondsRemaining)")
                        }
                        return AccountCellView.Model(id: account.id,
                                                     passcode: passcode,
                                                     description: account.displayName,
                                                     accessoryType: accessoryType)
                    }
                }
                .store(in: &cancellable)
        }
    }
}
