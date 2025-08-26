//
//  PasswordManager.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import Foundation
import Combine
import CombineExt

class PasswordManager {
    private var timer = Timer.publish(every: 1.0, on: .main, in: .default).autoconnect()
    private var accounts: AnyPublisher<[Account], Never>
    private var counters: AnyPublisher<[UUID : UInt], Never>
    var secondsRemainings: AnyPublisher<[UUID : Int], Never>
    var progresses: AnyPublisher<[UUID : Double], Never>
    var passcodes: AnyPublisher<[UUID : String], Never>

    init(store: Store = .shared) {
        self.accounts = store.publisher(\.accounts)

        self.counters = accounts.combineLatest(timer)
            .map { accounts, now in
                accounts.reduce(into: [UUID : UInt]()) { result, account in
                    result[account.id] = account.password.counter(at: now)
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

        self.secondsRemainings = accounts.combineLatest(timer)
            .map { accounts, now in
                accounts
                    .filter { if case .totp = $0.password.kind { true } else { false } }
                    .reduce(into: [UUID : Int]()) { result, account in
                        result[account.id] = account.password.secondsRemaining(at: now)
                    }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

        self.progresses = accounts.combineLatest(timer)
            .map { accounts, now in
                accounts
                    .filter { if case .totp = $0.password.kind { true } else { false } }
                    .reduce(into: [UUID : Double]()) { result, account in
                        result[account.id] = account.password.progress(at: now)
                    }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()

        self.passcodes = counters.combineLatest(accounts)
            .map { counters, accounts in
                counters.reduce(into: [UUID : String]()) { result, counter in
                    guard let value = accounts[id: counter.key]?.password.value(for: counter.value) else { return }
                    result[counter.key] = value
                }
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
