//
//  Route.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import Foundation
import SwiftData
import MapKit

@Model
class Route {
    var name: String = "Unnamed route"
    @Relationship(deleteRule: .cascade, inverse: \RoutePart.route) var parts: [RoutePart]?
    @Relationship(deleteRule: .cascade, inverse: \RoutePinLocation.route) var pinLocations: [RoutePinLocation]?
    
    init(name: String, parts: [RoutePart], pinLocations: [RoutePinLocation]) {
        self.name = name
        self.parts = parts
        self.pinLocations = pinLocations
    }
    
    func getPolyline() -> MKPolyline? {
        return parts?
            .sorted(by: { $0.index ?? 0 < $1.index ?? 0 }).combine() ?? nil
    }
    
    func getPinLocations() -> [RoutePinLocation] {
        return pinLocations?.sorted(by: { $0.index < $1.index }) ?? []
    }
    
    func getKilometerMarks() -> [Int: CLLocationCoordinate2D] {
        guard let polyline = getPolyline() else { return [:] }
        
        var kilometerMarks: [Int: CLLocationCoordinate2D] = [:]
        var totalDistance: CLLocationDistance = 0
        var lastKilometer: Int = 0
        let pointCount = polyline.pointCount
        
        // Add the start as km 0
        if let start = polyline.coordinates.first ?? pinLocations?.first?.getAsCLLocationCoordinate2D() {
            kilometerMarks[0] = start
        }
        
        if pointCount < 2 { return kilometerMarks }
        
        // Loop through the polyline's points to add all the km's
        for i in 1..<pointCount {
            let prevCoord = polyline.coordinates[i - 1]
            let currentCoord = polyline.coordinates[i]
            
            // Calculate distance between consecutive points
            let distance = prevCoord.distance(from: currentCoord)
            totalDistance += distance
            
            // Check if we've passed another kilometer mark
            let currentKilometer = Int(totalDistance / 1000)
            
            // If the current kilometer is greater than the last, add the point to the array
            if currentKilometer > lastKilometer {
                kilometerMarks[currentKilometer] = currentCoord
                lastKilometer = currentKilometer
            }
        }
        
        return kilometerMarks
        
    }
    
    func getDistance() -> Double { parts?.reduce(0) { $0 + $1.distance } ?? 0.0 }
    
    func apppendLocation(coordinates: CLLocationCoordinate2D) {
        // Initialize arrays if they're nil
        if pinLocations == nil {
            pinLocations = []
        }
        if parts == nil {
            parts = []
        }
        
        // Add new pin location
        let newPin = RoutePinLocation(
            index: (pinLocations?.count ?? 0) + 1,
            from: coordinates
        )
        pinLocations?.append(newPin)
        newPin.route = self
    }
    
    func removeLastLocation() {
        pinLocations?.savelyRemoveLast()
        parts?.savelyRemoveLast()
    }
    
    static func empty() -> Route {
        return Route(name: "", parts: [], pinLocations: [])
    }
    
}

extension MKPolyline {
    // Helper to convert polyline points to CLLocationCoordinate2D array
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

extension CLLocationCoordinate2D {
    // Helper to calculate distance between two coordinates
    func distance(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let loc2 = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return loc1.distance(from: loc2)
    }
}
