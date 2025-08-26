//
//  ViewModel.swift
//  Rayford
//
//  Created by Weiyi Kong on 26/8/2025.
//

import SwiftUI

extension AddAccountView {
    class ViewModel: ObservableObject {
        @Binding var isPresented: Bool

        @Published var name: String = ""
        @Published var issuer: String = ""
        @Published var secret: String = ""
        @Published var algorithm: Algorithm = .sha1
        @Published var digits: UInt = 6
        @Published var kind: Kind = .totp(period: 30)
        @Published var period: UInt = 30
        @Published var counter: UInt = 0

        init(isPresented: Binding<Bool>) {
            self._isPresented = isPresented
        }

        func cancel() {
            isPresented = false
        }

        func save() {
            print("Done tapped!")
            print("name: \(name)")
            print("issuer: \(issuer)")
            print("secret: \(secret)")
            print("algorithm: \(algorithm)")
            print("digits: \(digits)")
            print("type: \(kind)")
            print("period: \(period)")
            print("counter: \(counter)")
            isPresented = false
        }
    }
}
