//
//  Store.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import Foundation
import Combine
import KeychainSwift

class Store: ObservableObject {
    static let shared = Store(appState: loadState())

    @Published var appState: AppState {
        didSet {
            Self.saveState(appState)
        }
    }

    init(appState: AppState) {
        self.appState = appState
    }

    func publisher<T: Equatable>(_ keyPath: KeyPath<AppState, T>) -> AnyPublisher<T, Never> {
        $appState.map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}

// MARK: - Persistence

extension Store {
    private static func saveState(_ appState: AppState) {
        saveKeychain(appState.accounts)
    }
    
    private static func loadState() -> AppState {
        AppState(accounts: loadKeychain())
    }
}

extension Store {
    private static let keychain = {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        return keychain
    }()

    private static let accountKeyPrefix = "Account_"

    private static func saveKeychain(_ accounts: [Account]) {
        clearKeychain()
        for account in accounts {
            guard let jsonString = try! account.toJSON(formatted: false) else { continue }
            keychain.set(jsonString, forKey: "\(accountKeyPrefix)\(account.id.uuidString)")
        }
    }

    private static func loadKeychain() -> [Account] {
        keychain.allKeys
            .filter { $0.hasPrefix(accountKeyPrefix) }
            .compactMap {
                guard let jsonString = keychain.get($0) else { return nil }
                return try! Account.fromJSON(jsonString)
            }
    }

    private static func clearKeychain() {
        keychain.allKeys
            .filter { $0.hasPrefix(accountKeyPrefix) }
            .forEach { keychain.delete($0) }
    }
}
