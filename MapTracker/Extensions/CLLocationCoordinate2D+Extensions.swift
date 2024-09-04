//
//  CLLocationCoordinate2D+Extensions.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 04/09/2024.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D {
    static let utrecht = CLLocationCoordinate2D(latitude: 52.0833, longitude: 5.1217)
}

extension CLLocationCoordinate2D: @retroactive Identifiable, @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        if lhs.id != rhs.id { return false }
        return lhs.id == rhs.id
    }
    
    public var id: String { "\(latitude),\(longitude)" }
}
