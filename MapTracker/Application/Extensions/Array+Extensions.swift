//
//  Array+Extensions.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 04/09/2024.
//

import Foundation

extension Array {
    @discardableResult
    mutating func savelyRemoveLast() -> Element? {
        if self.count > 0 {
            let last = self.last!
            self.removeLast()
            return last
        }
        return nil
    }
}
