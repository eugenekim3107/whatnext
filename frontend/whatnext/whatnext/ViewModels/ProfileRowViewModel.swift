//
//  ProfileRowViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 2/19/24.
//

import Foundation

class ProfileRowViewModel: ObservableObject {
    @Published var friendsInfo: [UserInfo] = []
    @Published var isLoading = true
    private var isDataLoaded = false
    private let profileService = ProfileService()

    func fetchFriendsInfo(userId: String) {
        guard !isDataLoaded else { return }
        isLoading = true
        profileService.fetchFriendsInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let friendsInfo):
                    self?.friendsInfo = friendsInfo.friendsInfo
                    self?.isDataLoaded = true
                case .failure(let error):
                    print("Error fetching friends info: \(error.localizedDescription)")
                    self?.friendsInfo = []
                }
                self?.isLoading = false
            }
        }
    }

    func refreshData(userId: String) {
        isDataLoaded = false
        fetchFriendsInfo(userId: userId)
    }
}
