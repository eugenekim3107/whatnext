//
//  ProfileViewModel.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var userInfo: UserInfo?
    @Published var errorMessage: String?
    private var isDataLoaded = false

    private let profileService = ProfileService()

    func fetchUserInfo(userId: String) {
        guard !isDataLoaded else { return }
        errorMessage = nil
        
        profileService.fetchUserInfo(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                    self?.isDataLoaded = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Error fetching user info: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func refreshData(userId: String) {
        isDataLoaded = false
        fetchUserInfo(userId:userId)
    }
}
