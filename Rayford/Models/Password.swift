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

    // MARK: - Initializers

    init(kind: Kind, algorithm: Algorithm? = nil, secret: Data, digits: UInt? = nil) {
        self.kind = kind
        self.algorithm = algorithm ?? .sha1
        self.secret = secret
        self.digits = digits ?? 6
    }

    init?(kind: Kind, algorithm: Algorithm? = nil, base32 secret: String, digits: UInt? = nil) {
        guard let secret = Data(base32Encoded: secret) else { return nil }
        self.init(kind: kind, algorithm: algorithm, secret: secret, digits: digits)
    }

    // MARK: - Computed Values

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

    mutating func incrementCounter() {
        if case let .hotp(counter) = kind { kind = .hotp(counter: counter + 1) }
    }
}

// MARK: - Codable

extension Password: Codable, JSONConvertible {
    enum CodingKeys: String, CodingKey {
        case kind = "type"
        case counter
        case period
        case algorithm
        case secret
        case digits
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self.kind {
        case let .hotp(counter):
            try container.encode("hotp", forKey: .kind)
            try container.encode(counter, forKey: .counter)
        case let .totp(period):
            try container.encode("totp", forKey: .kind)
            try container.encode(period, forKey: .period)
        }
        try container.encode(algorithm, forKey: .algorithm)
        try container.encode(secret, forKey: .secret)
        try container.encode(digits, forKey: .digits)
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeString = try container.decode(String.self, forKey: .kind)
        switch typeString {
        case "hotp": kind = .hotp(counter: try container.decode(UInt.self, forKey: .counter))
        case "totp": kind = .totp(period: try container.decode(UInt.self, forKey: .period))
        default: throw DecodingError.dataCorruptedError(forKey: .kind, in: container, debugDescription: "Unknown type: \(typeString)")
        }
        algorithm = try container.decode(Algorithm.self, forKey: .algorithm)
        secret = try container.decode(Data.self, forKey: .secret)
        digits = try container.decode(UInt.self, forKey: .digits)
    }
}

// MARK: - Support Types

enum Kind: Equatable, Hashable {
    case hotp(counter: UInt)
    case totp(period: UInt = 30)
}

enum Algorithm: String, Equatable, Codable {
    case sha1 = "sha1"
    case sha256 = "sha256"
    case sha512 = "sha512"

    init?(string: String) {
        switch string.lowercased() {
        case "sha1": self = .sha1
        case "sha256": self = .sha256
        case "sha512": self = .sha512
        default: return nil
        }
    }
}
