//
//  Double+Extensions.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 04/09/2024.
//

import Foundation

extension Double {
    func to2Decimals() -> String {
        // Return string of this double but with 2 decimals
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
