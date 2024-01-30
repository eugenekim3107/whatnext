//
//  MapViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//  Updated by Mike on 1/28/24
//

import Foundation
import MapKit

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    var region: MKCoordinateRegion
    @Published var locations: [LocationInfo] = []
    private let locationManager = CLLocationManager()

    override init() {
        // Set an initial region (can be a default or dummy value)
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        DispatchQueue.main.async {
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        loadLocations(center: location.coordinate)
    }
    
    // Example function to load locations based on the current center
    // Might have a conflict with fetchlocations, we will decide
    func loadLocations(center: CLLocationCoordinate2D) {
        // Will be modified later to populate actual locations
        // critical
        self.locations = [
            LocationInfo(id: "0", name: "Place One", imageUrl: "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?q=80&w=2449&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", latitude: center.latitude + 0.002, longitude: center.longitude + 0.002),
            LocationInfo(id: "0", name: "Place Two", imageUrl: "https://images.unsplash.com/photo-1494253109108-2e30c049369b?q=80&w=3540&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D", latitude: center.latitude - 0.002, longitude: center.longitude - 0.002)
            // Add more sample locations or implement your data fetching logic
        ]
    }

}
