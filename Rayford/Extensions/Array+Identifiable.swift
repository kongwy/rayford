//
//  Array+Identifiable.swift
//  Rayford
//
//  Created by Weiyi Kong on 26/8/2025.
//

import Foundation

extension Array where Element: Identifiable {
    subscript(id id: Element.ID) -> Element? {
        get {
            first(where: { $0.id == id })
        }
        set {
            guard let index = firstIndex(where: { $0.id == id }) else { return }
            if let newValue = newValue {
                self[index] = newValue
            }
        }
    }

    mutating func update(id: Element.ID, _ update: (inout Element) -> Void) {
        if let index = firstIndex(where: { $0.id == id }) {
            update(&self[index])
        }
    }
}
