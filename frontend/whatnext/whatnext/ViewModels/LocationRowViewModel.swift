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

    func fetchNearbyLocations(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
        guard !isDataLoaded else { return }
        isLoading = true
        locationService.fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag: tag, sortBy: sortBy) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let locations):
                    self?.locations = locations
                    self?.isDataLoaded = true
                case .failure(let error):
                    print("Error fetching locations: \(error.localizedDescription)")
                    self?.locations = []
                }
                self?.isLoading = false
            }
        }
    }
    
    func refreshData(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
        isDataLoaded = false
        fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag:tag, sortBy: sortBy)
    }
}
