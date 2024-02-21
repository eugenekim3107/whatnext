//
//  ProfileService.swift
//  whatnext
//
//  Created by Eugene Kim on 2/19/24.
//

import Foundation

class ProfileService {
    func fetchUserInfo(userId: String = "eugenekim", completion: @escaping (Result<UserInfo, Error>) -> Void) {
        guard let url = URL(string: "https://whatnext.live/api/user_info") else {
            print("Invalid URL")
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["user_id": userId]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let profile = try JSONDecoder().decode(UserInfo.self, from: data)
                completion(.success(profile))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchFriendsInfo(userId: String = "eugenekim", completion: @escaping (Result<FriendsInfo, Error>) -> Void) {
        guard let url = URL(string: "https://whatnext.live/api/friends_info") else {
            print("Invalid URL")
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["user_id": userId]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let friends = try JSONDecoder().decode(FriendsInfo.self, from: data)
                completion(.success(friends))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchVisitedInfo(userId: String = "eugenekim", completion: @escaping (Result<VisitedInfo, Error>) -> Void) {
        guard let url = URL(string: "https://whatnext.live/api/visited_info") else {
            print("Invalid URL")
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["user_id": userId]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let visited = try JSONDecoder().decode(VisitedInfo.self, from: data)
                completion(.success(visited))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchFavoritesInfo(userId: String = "eugenekim", completion: @escaping (Result<FavoritesInfo, Error>) -> Void) {
        guard let url = URL(string: "https://whatnext.live/api/favorites_info") else {
            print("Invalid URL")
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: ["user_id": userId]) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            do {
                let favorites = try JSONDecoder().decode(FavoritesInfo.self, from: data)
                completion(.success(favorites))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
