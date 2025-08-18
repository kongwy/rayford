//
//  RayfordApp.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import SwiftUI

@main
struct RayfordApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AccountsView(accounts: mockAccounts)
            }
        }
    }
}
