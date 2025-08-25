//
//  AddAccountView.swift
//  Rayford
//
//  Created by Weiyi Kong on 21/8/2025.
//

import SwiftUI

struct AddAccountView: View {
    @State private var name: String = ""
    @State private var issuer: String = ""
    @State private var secret: String = ""
    @State private var algorithm: Algorithm = .sha1
    @State private var digits: UInt = 6
    @State private var kind: Kind = .totp(period: 30)
    @State private var period: UInt = 30
    @State private var counter: UInt = 0

    var body: some View {
        Form {
            Section("Display") {
                TextField("Name", text: $name)
                TextField("Issuer", text: $issuer)
            }

            Section("Details") {
                TextField("Secret", text: $secret)
                Picker("Algorithm", selection: $algorithm) {
                    Text("SHA1").tag(Algorithm.sha1)
                    Text("SHA256").tag(Algorithm.sha256)
                    Text("SHA512").tag(Algorithm.sha512)
                }
                Stepper(value: $digits) {
                    Text("\(digits) digit(s)")
                }
                Picker("Type", selection: $kind) {
                    Text("TOTP").tag(Kind.totp(period: period))
                    Text("HOTP").tag(Kind.hotp(counter: counter))
                }
                switch kind {
                case .totp:
                    HStack {
                        Text("Period")
                        Spacer()
                        TextField("30", value: $period, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                case .hotp:
                    HStack {
                        Text("Counter")
                        Spacer()
                        TextField("0", value: $counter, format: .number)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    print("Cancel tapped!")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    print("Done tapped!")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        AddAccountView()
    }
}
