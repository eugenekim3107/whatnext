//
//  MapViewCoordinator.swift
//  whatnext
//
//  Created by Mike Dong on 1/23/24.
//

import MapKit

class MapViewCoordinator: NSObject, MKMapViewDelegate, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?

    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    // Request permissions if the status is not determined
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorization status changed to: \(status.rawValue)")
        switch status {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location Authorization Granted.")
            locationManager?.startUpdatingLocation()
        case .restricted, .denied:
            print("Location Authorization Denied.")
        default:
            print("Unhandled authorization status.")
        }
    }

    // Handle location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        print("Location updated to: \(location)")
    }
}
