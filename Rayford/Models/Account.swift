//
//  Account.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import Foundation

// Ref: https://github.com/google/google-authenticator/wiki/Key-Uri-Format

struct Account: Identifiable, Equatable {
    let id: UUID
    var name: String?
    var issuer: String?
    let password: Password

    var displayName: String { [issuer, name].compactMap { $0 }.joined(separator: ": ") }

    // MARK: - Initializer

    init(id: UUID = UUID(), name: String? = nil, issuer: String? = nil, password: Password) {
        self.id = id
        self.name = name
        self.issuer = issuer
        self.password = password
    }

    init?(url: URL) {
        let label = url.path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        guard let host = url.host, ["hotp", "totp"].contains(host) else { return nil }
        let labelComponents = label.components(separatedBy: ":")
        guard labelComponents.count > 0,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              queryItems.count > 0
        else { return nil }

        id = UUID()
        name = labelComponents.last?.trimmingCharacters(in: CharacterSet.whitespaces)
        issuer = labelComponents.count > 1 ? labelComponents.first : nil

        var hotpCounter: UInt?
        var totpPeriod: UInt?
        var algorithm: Algorithm?
        var secret: Data?
        var digits: UInt?
        for queryItem in queryItems {
            switch queryItem.name {
            case "issuer": issuer = queryItem.value
            case "secret": secret = queryItem.value.flatMap { Data(base32Encoded: $0) }
            case "algorithm": algorithm = queryItem.value.flatMap { Algorithm(string: $0) }
            case "digits": digits = queryItem.value.flatMap { UInt($0) }
            case "counter": hotpCounter = queryItem.value.flatMap { UInt($0) }
            case "period": totpPeriod = queryItem.value.flatMap { UInt($0) }
            default: break
            }
        }
        let kind: Kind?
        switch host {
        case "hotp":
            guard let hotpCounter else { return nil }
            kind = .hotp(counter: hotpCounter)
        case "totp":
            if let totpPeriod, totpPeriod < 1 { return nil }
            kind = .totp(period: totpPeriod ?? 30)
        default: return nil
        }
        guard let kind else { return nil }
        guard let secret, secret.count != 0 else { return nil }
        if let digits, digits < 6 || digits > 9 { return nil }

        password = Password(kind: kind, algorithm: algorithm, secret: secret, digits: digits)
    }
}
