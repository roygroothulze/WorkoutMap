//
//  RoutePinLocation.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import Foundation
import SwiftData
import MapKit

@Model
class RoutePinLocation {
    var route: Route?
    var index: Int = 0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(index: Int?, latitude: Double, longitude: Double) {
        self.index = index ?? 0
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(index: Int, from: CLLocationCoordinate2D) {
        self.index = index
        self.latitude = from.latitude
        self.longitude = from.longitude
    }
    
    func getAsCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
