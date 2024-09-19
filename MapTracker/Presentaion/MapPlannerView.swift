//
//  MapPlannerView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 05/09/2024.
//

import SwiftUI
import MapKit
import StoreKit

struct MapPlannerView: View {
    @Environment(\.requestReview) var requestReview
    @Environment(\.modelContext) private  var context
    @StateObject private var locationManager = LocationManager.shared
    @State var selectedKilometers: Double = 0.0
    @State var selectedLocations: [RoutePinLocation] = []
    @State var mapRouteParts: [RoutePart] = []
    @State private var showConfirmDeleteDialog = false
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var showSaveRouteDialog = false
    @State private var routeName = ""
    
    var body: some View {
        NavigationStack {
            MapReader { reader in
                Map(
                    position: $mapPosition
                ) {
                    UserAnnotation()
                    
                    MapPolyline(mapRouteParts.combine())
                        .stroke(.blue, lineWidth: 2)
                    
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
                        }
                    }
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
                    let tappedLocation = reader.convert(screenCoord, from: .local)
                    guard let tappedLocation else { return }
                    selectedLocations.append(RoutePinLocation(index: selectedLocations.count + 1, from: tappedLocation))
                    fetchRoute()
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("\(selectedKilometers.to2Decimals()) km")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .destructive) {
                        showConfirmDeleteDialog.toggle()
                    } label: {
                        Text("New")
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
                        Text("Are you sure you want to delete this route?")
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
                        routeName = "Route of \(selectedKilometers.to2Decimals())km"
                        showSaveRouteDialog.toggle()
                    } label: {
                        Text("Save route")
                    }
                    .disabled(mapRouteParts.isEmpty)
                    .alert("Enter the route name", isPresented: $showSaveRouteDialog) {
                        TextField("Name", text: $routeName)
                        Button("Save", action: saveAsRoute)
                    } message: {
                        Text("Give your route a name")
                    }
                }
            }
        }
        .onChange(of: locationManager.userLocation) { oldValue, newValue in
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
        let route = Route(
            name: routeName,
            parts: mapRouteParts,
            pinLocations: selectedLocations
        )
        context.insert(route)
        try? context.save()
        
        requestReview()
    }
}
