//
//  Store.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import Foundation
import Combine

class Store: ObservableObject {
    static let shared = Store()

    @Published var appState = loadAppState()

    func publisher<T: Equatable>(_ keyPath: KeyPath<AppState, T>) -> AnyPublisher<T, Never> {
        $appState.map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }

    // TODO: Persistence
    static func loadAppState() -> AppState {
        mockState
    }
}
