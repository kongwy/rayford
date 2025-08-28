//
//  AppState.swift
//  Rayford
//
//  Created by Weiyi Kong on 18/8/2025.
//

import Foundation

struct AppState: Equatable {
    var version: Int = 1

    var accounts: [Account]
}
