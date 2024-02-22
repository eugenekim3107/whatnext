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
    @Published var favoritesInfo: [Location] = []
    @Published var visitedInfo: [Location] = []
    private var isDataLoaded = false
    private let locationService = LocationService()
    private let profileService = ProfileService()

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
    
    func fetchFavoritesInfo(userId: String) {
        guard !isDataLoaded else { return }
        isLoading = true
        profileService.fetchFavoritesInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let favoritesInfo):
                    self?.favoritesInfo = favoritesInfo.favoritesLocations
                    self?.isDataLoaded = true
                case .failure(let error):
                    print("Error fetching friends info: \(error.localizedDescription)")
                    self?.favoritesInfo = []
                }
                self?.isLoading = false
            }
        }
    }
    
    func fetchVisitedInfo(userId: String) {
        guard !isDataLoaded else { return }
        isLoading = true
        profileService.fetchVisitedInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let visitedInfo):
                    self?.visitedInfo = visitedInfo.locations
                    self?.isDataLoaded = true
                case .failure(let error):
                    print("Error fetching friends info: \(error.localizedDescription)")
                    self?.visitedInfo = []
                }
                self?.isLoading = false
            }
        }
    }
    
    func refreshDataLocations(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
        isDataLoaded = false
        fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag:tag, sortBy: sortBy)
    }
    
    func refreshDataVisited(userId: String) {
        isDataLoaded = false
        fetchVisitedInfo(userId: userId)
    }
    
    func refreshDataFavorites(userId: String) {
        isDataLoaded = false
        fetchFavoritesInfo(userId: userId)
    }
}
