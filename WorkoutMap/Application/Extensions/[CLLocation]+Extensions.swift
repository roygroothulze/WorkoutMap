//
//  [CLLocation]+Extensions.swift
//  WorkoutMap
//
//  Created by Roy Groot Hulze on 28/09/2024.
//

import CoreLocation
import MapKit

extension [CLLocation] {
    // Function to convert [CLLocation] to MKPolyline
    func asPolyline() -> MKPolyline {
        // Map CLLocation to CLLocationCoordinate2D
        let coordinates = self.map { $0.coordinate }
        
        // Create an MKPolyline from the coordinates
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        return polyline
    }
}
