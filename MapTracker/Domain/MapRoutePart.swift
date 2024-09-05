//
//  MapRoutePart.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import Foundation
import MapKit

struct MapRoutePart: Identifiable {
    var id: UUID = .init()
    var polyline: MKPolyline
    var distance: Double
}
