//
//  SavedRouteDetailView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import MapKit

struct SavedRouteDetailView: View {
    var route: Route
    
    var body: some View {
        Map {
            ForEach(route.parts, id: \.id) { part in
                MapPolyline(part.getPolyline())
                    .stroke(.blue, lineWidth: 2)
            }
            
            ForEach(route.pinLocations) { location in
                if (location == route.pinLocations.first) {
                    Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                        Image(systemName: "flag.fill")
                    }
                    .tint(.red)
                } else if (location == route.pinLocations.last) {
                    Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                        Image(systemName: "flag.pattern.checkered")
                    }
                    .tint(.green)
                } else {
                Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                        Text("")
                    }
                    .tint(.blue.opacity(0.5))
                }
            }
        }
        .navigationTitle(route.name)
    }
}
