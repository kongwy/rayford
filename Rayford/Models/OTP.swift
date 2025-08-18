//
//  OTP.swift
//  Rayford
//
//  Created by Weiyi Kong on 15/8/2025.
//

import Foundation
import CryptoKit

// Ref: https://github.com/google/google-authenticator/wiki/Key-Uri-Format

struct Account: Identifiable {
    let id: UUID
    var name: String?
    var issuer: String?
    let password: Password

    var displayName: String { [issuer, name].compactMap { $0 }.joined(separator: ": ") }

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

struct Password {
    var kind: Kind
    var algorithm: Algorithm = .sha1
    var secret: Data
    var digits: UInt = 6

    private var counter: UInt {
        switch kind {
        case .hotp(let counter): counter
        case .totp(let period): UInt(Date.now.timeIntervalSince1970) / UInt(period)
        }
    }

    var value: String {
        let key = SymmetricKey(data: secret)
        var input = counter.bigEndian
        let counter = withUnsafeBytes(of: &input) { Data($0) }

        let macData: Data = switch algorithm {
        case .sha1: Data(HMAC<Insecure.SHA1>.authenticationCode(for: counter, using: key))
        case .sha256: Data(HMAC<SHA256>.authenticationCode(for: counter, using: key))
        case .sha512: Data(HMAC<SHA512>.authenticationCode(for: counter, using: key))
        }

        let offset = Int(macData.last! & 0x0f)
        let four = macData[offset ..< offset + 4]
        var truncated: UInt = 0
        for b in four { truncated = (truncated << 8) | UInt(b) }
        truncated &= 0x7fffffff

        let mod = UInt(pow(10, Float(digits)))
        return String(format: "%0\(digits)d", truncated % mod)
    }

    var timeIntervalRemaining: Double {
        guard case let .totp(period) = kind else { return 0 }
        return Double(period) - Date.now.timeIntervalSince1970.truncatingRemainder(dividingBy: Double(period))
    }

    var progress: Double {
        guard case let .totp(period) = kind else { return 0 }
        return timeIntervalRemaining / Double(period)
    }

    var secondsRemaining: Int { Int(timeIntervalRemaining) }

    init(kind: Kind, algorithm: Algorithm? = nil, secret: Data, digits: UInt? = nil) {
        self.kind = kind
        self.algorithm = algorithm ?? .sha1
        self.secret = secret
        self.digits = digits ?? 6
    }
}

enum Kind {
    case hotp(counter: UInt)
    case totp(period: UInt = 30)
}

enum Algorithm {
    case sha1
    case sha256
    case sha512

    init?(string: String) {
        switch string.lowercased() {
        case "sha1": self = .sha1
        case "sha256": self = .sha256
        case "sha512": self = .sha512
        default: return nil
        }
    }
}
