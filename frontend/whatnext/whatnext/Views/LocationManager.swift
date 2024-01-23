//
//  LocationManager.swift
//  whatnext
//
//  Created by Mike Dong on 1/23/24.
//

import CoreLocation

/// A manager to handle location services and permission requests.
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    // Implement CLLocationManagerDelegate methods here.
}

