//
//  RayfordApp.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import SwiftUI

@main
struct RayfordApp: App {
    var store = Store.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AccountsView()
            }
            .environmentObject(store)
        }
    }
}
