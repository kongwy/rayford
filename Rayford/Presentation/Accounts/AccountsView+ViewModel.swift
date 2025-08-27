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

        @Published var presentDeleteAccountConfirmation = false
        @Published var deletingAccountId: UUID? = nil
        @Published var presentEditAccountView = false
        @Published var editingAccountId: UUID? = nil
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
                            accessoryType = .nextButton { [weak self] in
                                self?.incrementCounter(for: account.id, in: store)
                            }
                        case .totp:
                            guard let progress = progresses[account.id], let secondsRemaining = secondsRemainings[account.id] else { return nil }
                            accessoryType = .progressCircle(value: progress, text: "\(secondsRemaining)")
                        }
                        return AccountCellView.Model(id: account.id,
                                                     passcode: passcode,
                                                     description: account.description,
                                                     accessoryType: accessoryType)
                    }
                }
                .store(in: &cancellable)
        }

        private func incrementCounter(for id: UUID, in store: Store = .shared) {
            store.appState.accounts.update(id: id) { account in
                account.password.incrementCounter()
            }
        }

        func presentDeleteAccountConfirmation(for id: UUID) {
            deletingAccountId = id
            presentDeleteAccountConfirmation = true
        }

        func deleteAccount(for id: UUID, in store: Store = .shared) {
            store.appState.accounts.remove(id: id)
        }

        func presentEditAccountView(for id: UUID) {
            editingAccountId = id
            presentEditAccountView = true
        }

        func moveAccount(from source: IndexSet, to destination: Int, in store: Store = .shared) {
            store.appState.accounts.move(fromOffsets: source, toOffset: destination)
        }
    }
}
