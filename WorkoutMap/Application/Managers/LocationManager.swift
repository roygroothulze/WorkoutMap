//
//  LocationManager.swift
//  MapTracker
//
//  Created by Roy Groot Hulze on 04/09/2024.
//

import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    @Published var userLocation: CLLocationCoordinate2D?
    var manager = CLLocationManager()
    
    override
    private init() {
        super.init()
        
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func updateLocation() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            userLocation = nil
            break
        case .authorizedWhenInUse, .authorizedAlways:
            userLocation = manager.location?.coordinate
            break
        default:
            userLocation = nil
            break
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        updateLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last?.coordinate
    }
}
