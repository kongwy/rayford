//
//  AccountsView.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import SwiftUI

struct AccountsView: View {
    var accounts: [Account]

    var body: some View {
        List(accounts) { account in
            AccountCellView(account: account)
        }
        .listStyle(.grouped)
        .navigationTitle("Accounts")
    }
}

struct AccountCellView: View {
    var account: Account

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .resizable()
                .scaledToFit()
                .padding(12)
                .frame(width: 64, height: 64)
                .foregroundStyle(.white)
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading) {
                Text(formattedValue(account.password.value))
                    .font(.system(size: 44, weight: .thin))
                    .lineLimit(1)
                    .monospacedDigit()

                Text(account.displayName)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
            }

            Spacer()

            switch account.password.kind {
            case .hotp:
                Image(systemName: "arrowtriangle.forward.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .offset(x: 1)
                    .frame(width: 28, height: 28)
                    .foregroundStyle(.white)
                    .background(.link)
                    .clipShape(Circle())
            case .totp:
                CircularProgressView(progress: account.password.progress,
                                     text: "\(account.password.secondsRemaining)")
                    .frame(width: 30, height: 30)
            }
        }
    }

    private func formattedValue(_ value: String) -> String {
        let length = value.count
        let prefix = String(value.prefix(length / 2))
        let suffix = String(value.suffix(length - length / 2))
        return "\(prefix) \(suffix)"
    }
}

#Preview {
    NavigationStack {
        AccountsView(accounts: mockAccounts)
    }
}
