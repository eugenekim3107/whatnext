//
//  LocationRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationRowViewModel: ObservableObject {
    @Published var locations: [LocationInfo] = []
    private let locationService = LocationService()

    func fetchLocations() {
        locationService.fetchLocations { [weak self] fetchedLocations in
            DispatchQueue.main.async {
                self?.locations = fetchedLocations
            }
        }
    }
}
