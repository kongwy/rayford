//
//  JSONConvertible.swift
//  Rayford
//
//  Created by Weiyi Kong on 27/8/2025.
//

import Foundation

protocol JSONConvertible: Codable {
    func toJSON(formatted: Bool) throws -> String?
    static func fromJSON(_ jsonString: String) throws -> Self?
}

extension JSONConvertible {
    func toJSON(formatted: Bool) throws -> String? {
        let encoder = JSONEncoder()
        if formatted { encoder.outputFormatting = .prettyPrinted }
        let data = try encoder.encode(self)
        return String(data: data, encoding: .utf8)
    }

    static func fromJSON(_ jsonString: String) throws -> Self? {
        let decoder = JSONDecoder()
        guard let data = jsonString.data(using: .utf8) else { return nil }
        return try decoder.decode(Self.self, from: data)
    }
}
