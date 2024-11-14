//
//  MapView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 20/09/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @Binding var route: Route
    @StateObject private var locationManager = LocationManager.shared
    @State private var mapPosition: MapCameraPosition = .automatic
    
    let allowEditingRoute: Bool
    
    var body: some View {
        let pinLocations = route.getPinLocations()
        MapReader { reader in
            Map(
                position: $mapPosition
            ) {
                UserAnnotation()
            }
            .mapControlVisibility(.visible)
            .mapStyle(.standard)
            .mapControls {
                /// Shows up when you pitch to zoom
                MapScaleView()
                /// Shows up when you rotate the map
                MapCompass()
                /// 3D and 2D button on the top right
                MapPitchToggle()
            }
            .onTapGesture(perform: { screenCoord in
                guard self.allowEditingRoute else { return }
                
                let tappedLocation = reader.convert(screenCoord, from: .local)
                guard let tappedLocation else { return }
                route.apppendLocation(coordinates: tappedLocation)
                _fetchRoute()
            })
        }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
            guard let newValue, oldValue == nil else { return }
            mapPosition = .region(MKCoordinateRegion(
                center: newValue,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    private func _fetchRoute() {
        let locations = route.getPinLocations()
        let lastLocation = locations.last
        let secondLastLocation = locations.count > 1 ? locations[locations.count - 2] : nil
        
        guard let lastLocation, let secondLastLocation else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: secondLastLocation.getAsCLLocationCoordinate2D()))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation.getAsCLLocationCoordinate2D()))
        request.transportType = .walking
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            let route = result?.routes.first
            
            if let route {
                let line = route.polyline
                let part = RoutePart.fromPolyline(route: self.route, polyline: line, distance: route.distance / 1000)
                self.route.parts?.append(part)
            }
        }
        
    }
}

struct PlaceAnnotationView: View {
  var body: some View {
    VStack(spacing: 0) {
      Image(systemName: "mappin.circle.fill")
        .font(.title)
        .foregroundColor(.red)
      
      Image(systemName: "arrowtriangle.down.fill")
        .font(.caption)
        .foregroundColor(.red)
        .offset(x: 0, y: -5)
    }
  }
}
