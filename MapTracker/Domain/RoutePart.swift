//
//  RoutePart.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import Foundation
import MapKit
import SwiftData

@Model
class RoutePart {
    var route: Route?
    var coordinatesData: [CoordinateData]? // This will store coordinates as lat-long pairs
    var distance: Double = 0.0
    
    init(route: Route?, coordinates: [CLLocationCoordinate2D], distance: Double) {
        self.route = route
        self.coordinatesData = coordinates.enumerated().map {  CoordinateData(index: $0, latitude: $1.latitude, longitude: $1.longitude) }
        self.distance = distance
    }
    
    // Method to get MKPolyline from stored coordinates
    func getPolyline() -> MKPolyline {
        let coordinates = coordinatesData?
            .sorted { $0.index < $1.index }
            .map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) } ?? []
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
    
    // Helper method to convert from MKPolyline to coordinate data
    static func fromPolyline(route: Route? = nil, polyline: MKPolyline, distance: Double) -> RoutePart {
        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: polyline.pointCount)
        polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: polyline.pointCount))
        return RoutePart(route: route, coordinates: coordinates, distance: distance)
    }
}
