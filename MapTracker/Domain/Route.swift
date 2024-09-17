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
    var name: String = "Unnamed Route"
    @Relationship(deleteRule: .cascade, inverse: \RoutePart.route) var parts: [RoutePart]?
    @Relationship(deleteRule: .cascade, inverse: \RoutePinLocation.route) var pinLocations: [RoutePinLocation]?
    
    init(name: String, parts: [RoutePart], pinLocations: [RoutePinLocation]) {
        print(pinLocations.count)
        self.name = name
        self.parts = parts
        self.pinLocations = pinLocations
    }
    
    func getPinLocation() -> [RoutePinLocation] {
        return pinLocations?.sorted(by: { $0.index < $1.index }) ?? []
    }
    
    func getDistance() -> Double { parts?.reduce(0) { $0 + $1.distance } ?? 0.0 }
}
