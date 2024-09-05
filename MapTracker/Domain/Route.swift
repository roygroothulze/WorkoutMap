//
//  Route.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import Foundation
import SwiftData

@Model
class Route {
    var name: String
    @Relationship(deleteRule: .cascade, inverse: \RoutePart.route) var parts: [RoutePart]
    @Relationship(deleteRule: .cascade, inverse: \RoutePinLocation.route) var pinLocations: [RoutePinLocation]
    
    init(name: String, parts: [RoutePart], pinLocations: [RoutePinLocation]) {
        self.name = name
        self.parts = parts
        self.pinLocations = pinLocations
    }
    
    func getDistance() -> Double { parts.reduce(0) { $0 + $1.distance } }
}
