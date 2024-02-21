//
//  ProfileRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 2/19/24.
//

import Foundation

//class ProfileRowViewModel: ObservableObject {
//    @Published var profiles: [Profile] = []
//    @Published var isLoading = true
//    private var isDataLoaded = false
//    private let profileService = ProfileService()
//
//    func fetchUserInfo(userId: String) {
//        guard !isDataLoaded else { return }
//        isLoading = true
//        ProfileService.fetchUserInfo(userId: userId) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let profiles):
//                    self?.profiles = profiles
//                    self?.isDataLoaded = true
//                case .failure(let error):
//                    print("Error fetching locations: \(error.localizedDescription)")
//                    self?.locations = []
//                }
//                self?.isLoading = false
//            }
//        }
//    }
//
//    func refreshData(latitude: Double, longitude: Double, limit: Int, radius: Double, categories: [String], curOpen: Int, tag: [String]? = nil, sortBy: String) {
//        isDataLoaded = false
//        fetchNearbyLocations(latitude: latitude, longitude: longitude, limit: limit, radius: radius, categories: categories, curOpen: curOpen, tag:tag, sortBy: sortBy)
//    }
//}
