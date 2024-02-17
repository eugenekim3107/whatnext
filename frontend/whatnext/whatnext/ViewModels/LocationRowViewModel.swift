//
//  LocationRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationRowViewModel: ObservableObject {
    @Published var locations: [Location] = []
    @Published var isLoading = true
    private var isDataLoaded = false
    private let locationService = LocationService()

    func fetchNearbyLocations(latitude: Double = 32.8723812680163, longitude: Double = -117.21242234341588, limit: Int = 20, radius: Double = 10000.0, categories: String = "any", curOpen: Int = 1, sortBy: String = "best_match") {
        isLoading = true
        isDataLoaded = true
        locationService.fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, sortBy: sortBy) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self?.locations = locations
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    self?.locations = []
                }
                self?.isLoading = false
            }
        }
    }
    
    func refreshData() {
        isDataLoaded = false
        fetchNearbyLocations()
    }
}
