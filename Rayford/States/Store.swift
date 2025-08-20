//
//  Store.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import Foundation

class Store: ObservableObject {
    static let shared = Store()

    @Published var appState = loadAppState()

    // TODO: Persistence
    static func loadAppState() -> AppState {
        mockState
    }
}
