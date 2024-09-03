//
//  Item.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 03/09/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
