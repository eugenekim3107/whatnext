//
//  LocationRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationRowViewModel: ObservableObject {
    @Published var locations: [LocationInfo] = []
    @Published var isLoading = true
    private let locationService = LocationService()

    func fetchLocations(latitude: Double, longitude: Double, categories: String, radius: Int = 10000, cur_open: Bool = false, sort_by: String = "rating", limit: Int = 10, api_key: String) {
        isLoading = true
        locationService.fetchLocations(latitude: latitude, longitude: longitude, categories: categories, radius: radius, cur_open: cur_open, sort_by: sort_by, limit: limit, api_key: api_key) { [weak self] fetchedLocations in
            DispatchQueue.main.async {
                self?.locations = fetchedLocations
                self?.isLoading = false
            }
        }
    }
}
