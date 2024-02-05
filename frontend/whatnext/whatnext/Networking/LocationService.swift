//
//  LocationService.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

class LocationService {
    func fetchLocations(latitude: Double, longitude: Double, categories: String, radius: Int = 1000, cur_open: Bool = false, sort_by: String = "rating", limit: Int = 10, api_key: String, completion: @escaping ([LocationInfo]) -> Void) {
        
        let headers = ["Authorization": "Bearer \(api_key)"]
        var components = URLComponents(string: "https://api.yelp.com/v3/businesses/search")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: "\(latitude)"),
            URLQueryItem(name: "longitude", value: "\(-longitude)"),
            URLQueryItem(name: "categories", value: categories),
            URLQueryItem(name: "radius", value: "\(radius)"),
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "open_now", value: "\(cur_open)"),
            URLQueryItem(name: "sort_by", value: sort_by)
        ]
        
        guard let url = components?.url else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let jsonResponse = try JSONDecoder().decode(YelpResponse.self, from: data)
                let locations = jsonResponse.businesses
                DispatchQueue.main.async {
                    completion(locations)
                }
            } catch {
                print("Failed to decode locations: \(error.localizedDescription)")
            }
        }.resume()
    }
}
