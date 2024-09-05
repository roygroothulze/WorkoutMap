//
//  MapPlannerView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import MapKit

struct MapPlannerView: View {
    @Environment(\.modelContext) private  var context
    @StateObject private var locationManager = LocationManager()
    @State var selectedKilometers: Double = 0.0
    @State var selectedLocations: [RoutePinLocation] = []
    @State var mapRouteParts: [RoutePart] = []
    @State private var showConfirmDeleteDialog = false
    @State private var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: .utrecht,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))
    
    var body: some View {
        NavigationStack {
            MapReader { reader in
                Map(
                    position: $mapPosition
                ) {
                    UserAnnotation()
                    
                    ForEach(mapRouteParts, id: \.id) { part in
                        MapPolyline(part.getPolyline())
                            .stroke(.blue, lineWidth: 2)
                    }
                    
                    ForEach(selectedLocations) { location in
                        if (location == selectedLocations.first) {
                            Marker(coordinate: location.getAsCLLocationCoordinate2D()) {
                                Image(systemName: "flag.fill")
                            }
                            .tint(.red)
                        } else if (location == selectedLocations.last) {
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
                .onTapGesture(perform: { screenCoord in
                    let tappedLocation = reader.convert(screenCoord, from: .local)
                    guard let tappedLocation else { return }
                    selectedLocations.append(RoutePinLocation(index: selectedLocations.count + 1, from: tappedLocation))
                    fetchRoute()
                })
            }
            .navigationTitle("\(selectedKilometers.to2Decimals()) km")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .destructive) {
                        showConfirmDeleteDialog.toggle()
                    } label: {
                        Text("Reset")
                    }
                    .confirmationDialog("Confirm", isPresented: $showConfirmDeleteDialog) {
                        Button(role: .destructive) {
                            selectedLocations = []
                            mapRouteParts = []
                            selectedKilometers = 0
                            showConfirmDeleteDialog = false
                        } label: {
                            Text("Yes, delete route")
                        }
                    } message: {
                        Text("Are you sure you want to reset all locations?")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        selectedLocations.savelyRemoveLast()
                        let lastPart = mapRouteParts.savelyRemoveLast()
                        selectedKilometers -= lastPart?.distance ?? 0
                    } label: {
                        Text("Undo")
                    }
                }
                
                ToolbarItem {
                    Button {
                        saveAsRoute()
                    } label: {
                        Text("Save route")
                    }
                    .disabled(mapRouteParts.isEmpty)
                }
            }
        }
        .onAppear {
            locationManager.checkLocationAuthorization()
        }
        .onChange(of: locationManager.lastKnownLocation) { oldValue, newValue in
            guard let newValue, oldValue == nil else { return }
            mapPosition = .region(MKCoordinateRegion(
                center: newValue,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))
        }
    }
    
    func fetchRoute() {
        let lastLocation = selectedLocations.last
        let secondLastLocation = selectedLocations.count > 1 ? selectedLocations[selectedLocations.count - 2] : nil
        
        guard let lastLocation, let secondLastLocation else { return }
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: secondLastLocation.getAsCLLocationCoordinate2D()))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation.getAsCLLocationCoordinate2D()))
        request.transportType = .walking
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            let route = result?.routes.first
            
            if let route {
                selectedKilometers += route.distance / 1000
                let line = route.polyline
                let part = RoutePart.fromPolyline(polyline: line, distance: route.distance / 1000)
                mapRouteParts.append(part)
            }
        }
        
    }
    
    func saveAsRoute() {
        let name = "Route of \(selectedKilometers.to2Decimals())km"
        
        let route = Route(
            name: name,
            parts: mapRouteParts,
            pinLocations: selectedLocations
        )
        context.insert(route)
        try? context.save()
    }
}
