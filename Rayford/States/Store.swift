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
        Logger.main.log("Loading App State from storage...")
        return AppState(accounts: loadKeychain())
    }
}

extension Store {
    private static let keychain = {
        Logger.main.log("Setting up Keychain container...")
        let keychain = KeychainSwift()
        return keychain
    }()

    private static let accountKeyPrefix = "Account_"

    private static func saveKeychain(_ accounts: [Account]) {
        Logger.main.log("Saving \(accounts.count) account(s) to Keychain...")
        clearKeychain()
        accounts.forEach {
            do {
                let jsonString = try $0.toJSON(formatted: false)
                let result = keychain.set(jsonString, forKey: "\(accountKeyPrefix)\($0.id.uuidString)")
                if !result { Logger.main.error("Failed to save account into Keychain: \($0.id.uuidString)") }
            } catch {
                Logger.main.error("Failed to serialize account: \($0.id.uuidString)")
            }
        }
    }

    private static func loadKeychain() -> [Account] {
        let keys = keychain.allKeys.filter { $0.hasPrefix(accountKeyPrefix) }
        Logger.main.log("Loading \(keys.count) account(s) from Keychain...")
        return keys.compactMap {
            guard let jsonString = keychain.get($0) else {
                Logger.main.error("Failed to load account from Keychain: \($0)")
                return nil
            }
            do {
                return try Account.fromJSON(jsonString)
            } catch {
                Logger.main.error("Failed to deserialize account: \($0)")
                return nil
            }
        }
    }

    private static func clearKeychain() {
        let keys = keychain.allKeys.filter { $0.hasPrefix(accountKeyPrefix) }
        Logger.main.log("Deleting \(keys.count) account(s) from Keychain...")
        keys.forEach { keychain.delete($0) }
    }
}
