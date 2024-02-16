//
//  LocationService.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationService {
    func fetchNearbyLocations(latitude: Double? = 32.8723812680163,
                              longitude: Double? = -117.21242234341588,
                              limit: Int? = 20,
                              radius: Double? = 10000.0,
                              categories: String? = "any",
                              curOpen: Int? = 0,
                              sortBy: String? = "review_count",
                              completion: @escaping (Result<[Location], Error>) -> Void) {
        
        var components = URLComponents(string: "https://whatnext.live/api/nearby_locations")
        
        var queryItems: [URLQueryItem] = []
        
        if let latitude = latitude {
            queryItems.append(URLQueryItem(name: "latitude", value: "\(latitude)"))
        }
        if let longitude = longitude {
            queryItems.append(URLQueryItem(name: "longitude", value: "\(longitude)"))
        }
        if let limit = limit {
            queryItems.append(URLQueryItem(name: "limit", value: "\(limit)"))
        }
        if let radius = radius {
            queryItems.append(URLQueryItem(name: "radius", value: "\(radius)"))
        }
        if let categories = categories {
            queryItems.append(URLQueryItem(name: "categories", value: categories))
        }
        if let curOpen = curOpen {
            queryItems.append(URLQueryItem(name: "cur_open", value: "\(curOpen)"))
        }
        if let sortBy = sortBy {
            queryItems.append(URLQueryItem(name: "sort_by", value: sortBy))
        }
        
        components?.queryItems = queryItems
        
        guard let url = components?.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: -1, userInfo: nil)))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue("whatnext", forHTTPHeaderField: "whatnext_token")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: -2, userInfo: nil)))
                return
            }
            
            do {
                let locations = try JSONDecoder().decode([Location].self, from: data)
                completion(.success(locations))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
