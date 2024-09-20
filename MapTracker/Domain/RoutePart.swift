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
    var coordinatesData: [CoordinateData]? = []// This will store coordinates as lat-long pairs
    var distance: Double = 0.0
    var index: Int?
    
    init(route: Route?, index: Int, coordinates: [CLLocationCoordinate2D], distance: Double) {
        self.route = route
        self.index = index
        self.coordinatesData = coordinates.enumerated().map { CoordinateData(index: $0, routePart: self, latitude: $1.latitude, longitude: $1.longitude) }
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
    static func fromPolyline(
        route: Route, polyline: MKPolyline, distance: Double
    ) -> RoutePart {
        var coordinates = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: polyline.pointCount)
        polyline.getCoordinates(&coordinates, range: NSRange(location: 0, length: polyline.pointCount))
        return RoutePart(route: route, index: (route.parts?.count ?? 0) + 1, coordinates: coordinates, distance: distance)
    }
}

extension [RoutePart] {
    func combine() -> MKPolyline? {
        if (self.contains(where: { routePart in
            routePart.index == nil
        })) {
            return nil
        }
        
        // Flatten all coordinate arrays from each polyline into a single array
        let allCoordinates = self.flatMap { polyline in
            return polyline.getPolyline().coordinates
        }
        
        // Create a new polyline with the combined coordinates
        return MKPolyline(coordinates: allCoordinates, count: allCoordinates.count)
    }
}
