//
//  Password.swift
//  Rayford
//
//  Created by Weiyi Kong on 20/8/2025.
//

import Foundation
import CryptoKit

struct Password: Equatable {
    var kind: Kind
    var algorithm: Algorithm = .sha1
    var secret: Data
    var digits: UInt = 6

    func counter(at date: Date = Date.now) -> UInt {
        switch kind {
        case .hotp(let counter): counter
        case .totp(let period): UInt(date.timeIntervalSince1970) / UInt(period)
        }
    }

    func value(at date: Date = Date.now) -> String {
        value(for: counter(at: date))
    }

    func value(for counter: UInt) -> String {
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

    func timeIntervalRemaining(at date: Date = Date.now) -> Double {
        guard case let .totp(period) = kind else { return -1 }
        return Double(period) - date.timeIntervalSince1970.truncatingRemainder(dividingBy: Double(period))
    }

    func secondsRemaining(at date: Date = Date.now) -> Int {
        Int(timeIntervalRemaining(at: date))
    }

    func progress(at date: Date = Date.now) -> Double {
        guard case let .totp(period) = kind else { return 0 }
        return timeIntervalRemaining(at: date) / Double(period)
    }

    // MARK: - Initializer

    init(kind: Kind, algorithm: Algorithm? = nil, secret: Data, digits: UInt? = nil) {
        self.kind = kind
        self.algorithm = algorithm ?? .sha1
        self.secret = secret
        self.digits = digits ?? 6
    }
}

enum Kind: Equatable, Hashable {
    case hotp(counter: UInt)
    case totp(period: UInt = 30)
}

enum Algorithm: Equatable {
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
