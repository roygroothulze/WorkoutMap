//
//  ContentView.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 03/09/2024.
//

import SwiftUI
import SwiftData
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
                    ForEach(mapRouteParts, id: \.id) { part in
                        MapPolyline(part.polyline)
                            .stroke(.blue, lineWidth: 2)
                    }
                    
                    ForEach(selectedLocations, id: \.id) { location in
                        Marker(coordinate: location) {
                            Text("")
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
                
                HStack {
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
                    
                    Button {
                        selectedLocations.savelyRemoveLast()
                        let lastPart = mapRouteParts.savelyRemoveLast()
                        selectedKilometers -= lastPart?.distance ?? 0
                    } label: {
                        Text("Undo")
                    }
                }
            }
            .padding()
            .background(.white)
            .cornerRadius(30)
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

extension Array {
    @discardableResult
    mutating func savelyRemoveLast() -> Element? {
        if self.count > 0 {
            let last = self.last!
            self.removeLast()
            return last
        }
        return nil
    }
}

extension Double {
    func to2Decimals() -> String {
        // Return string of this double but with 2 decimals
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

final class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var lastKnownLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    
    func checkLocationAuthorization() {
        manager.delegate = self
        manager.startUpdatingLocation()
        
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            lastKnownLocation = manager.location?.coordinate
            break
        default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last?.coordinate
    }
}
