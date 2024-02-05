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
    //private let locationRowViewModel = LocationRowViewModel()
    //private var api_key = "6gBEOb7SjVVCNw2U9c2ovx64w-oSiYyKFR5KUvKehWjMEhFJUJXf9fOje43DHmr6KaXk5kncQDfgLAgSacdkbjdlgvhJ53h8iHxdM0BP-myzMEhagzs7pEQeui_AZXYx" // Replace with your actual API key

    override init() {
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
        loadDummyLocations()
        // Fetch locations using LocationRowViewModel
        //locationRowViewModel.fetchLocations(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, categories: "restaurants", api_key: "api_key")
    }
    
    func loadDummyLocations() {
        // Directly assign dummy data to locations
        self.locations = [
            LocationInfo(id: "1", name: "Coffee Shop", image_url: nil, is_closed: false, url: nil, review_count: 100, categories: [Category(alias: "coffee", title: "Coffee Shop")], rating: 4.5, coordinates: Coordinates(latitude: 32.880, longitude: -117.237), transactions: ["pickup", "delivery"], location: Location(address1: "123 Main St", address2: nil, address3: nil, city: "San Francisco", zip_code: "94103", country: "US", state: "CA", display_address: ["123 Main St", "San Francisco, CA 94103"]), phone: "+14155552671", display_phone: "(415) 555-2671", distance: 500.0),
            LocationInfo(id: "2", name: "Best Pizza", image_url: nil, is_closed: false, url: nil, review_count: 250, categories: [Category(alias: "pizza", title: "Pizza")], rating: 4.8, coordinates: Coordinates(latitude: 32.882, longitude: -117.235), transactions: ["pickup"], location: Location(address1: "456 Market St", address2: nil, address3: nil, city: "San Francisco", zip_code: "94105", country: "US", state: "CA", display_address: ["456 Market St", "San Francisco, CA 94105"]), phone: "+14155559876", display_phone: "(415) 555-9876", distance: 600.0)
        ]
    }
}
