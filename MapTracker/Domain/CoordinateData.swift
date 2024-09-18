//
//  CoordinateData.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import Foundation
import MapKit
import SwiftData

@Model
class CoordinateData {
    var index: Int = 0
    var routePart: RoutePart?
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    
    init(index: Int?, routePart: RoutePart?, latitude: Double, longitude: Double) {
        self.index = index ?? 0
        self.routePart = routePart
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(index: Int, routePart: RoutePart?, from: CLLocationCoordinate2D) {
        self.index = index
        self.routePart = routePart
        self.latitude = from.latitude
        self.longitude = from.longitude
    }
    
    func getAsCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
