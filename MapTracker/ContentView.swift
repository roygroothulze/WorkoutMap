//
//  ContentView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 03/09/2024.
//

import SwiftUI
import MapKit

struct MapRoutePart: Identifiable {
    var id: UUID = .init()
    var polyline: MKPolyline
    var distance: Double
}

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State var selectedKilometers: Double = 0.0
    @State var selectedLocations: [CLLocationCoordinate2D] = []
    @State var mapRouteParts: [MapRoutePart] = []
    @State private var showConfirmDeleteDialog = false
    @State private var mapPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: .utrecht,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    ))

    var body: some View {
        ZStack(alignment: .bottom) {
            MapReader { reader in
                Map(
                    position: $mapPosition
                ) {
                    UserAnnotation()
                    
                    ForEach(mapRouteParts, id: \.id) { part in
                        MapPolyline(part.polyline)
                            .stroke(.blue, lineWidth: 2)
                    }
                    
                    ForEach(selectedLocations, id: \.id) { location in
                        if (location == selectedLocations.first) {
                            Marker(coordinate: location) {
                                Image(systemName: "flag.fill")
                            }
                            .tint(.red)
                        } else if (location == selectedLocations.last) {
                            Marker(coordinate: location) {
                                Image(systemName: "flag.pattern.checkered")
                            }
                            .tint(.green)
                        } else {
                            Marker(coordinate: location) {
                                Text("")
                            }
                            .tint(.blue.opacity(0.5))
                        }
                    }
                }
                .onTapGesture(perform: { screenCoord in
                    let tappedLocation = reader.convert(screenCoord, from: .local)
                    guard let tappedLocation else { return }
                    selectedLocations.append(tappedLocation)
                    fetchRoute()
                })
            }
            
            VStack {
                Text("\(selectedKilometers.to2Decimals()) km")
                    .foregroundStyle(.black)
                
                Divider()
                
                HStack {
                    Spacer()
                    Button {
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
                    
                    Spacer()
                    Divider()
                    Spacer()
                    
                    Button {
                        selectedLocations.savelyRemoveLast()
                        let lastPart = mapRouteParts.savelyRemoveLast()
                        selectedKilometers -= lastPart?.distance ?? 0
                    } label: {
                        Text("Undo")
                    }
                    Spacer()
                }
            }
            .padding()
            .frame(width: 200, height: 100)
            .background(.white)
            .cornerRadius(20)
            .padding(.bottom, 1)
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
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: secondLastLocation))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation))
        request.transportType = .walking
        
        Task {
            let result = try? await MKDirections(request: request).calculate()
            let route = result?.routes.first
            
            if let route {
                selectedKilometers += route.distance / 1000
                let line = route.polyline
                let part = MapRoutePart(polyline: line, distance: route.distance / 1000)
                mapRouteParts.append(part)
            }
        }
        
    }
}
