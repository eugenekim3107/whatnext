//
//  LocationService.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

//class LocationService {
//    func fetchLocations(completion: @escaping ([LocationInfo]) -> Void) {
//        guard let url = URL(string: "https://your-backend-endpoint/locations") else {
//            print("Invalid URL")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            do {
//                let locations = try JSONDecoder().decode([LocationInfo].self, from: data)
//                DispatchQueue.main.async {
//                    completion(locations)
//                }
//            } catch {
//                print("Failed to decode locations: \(error.localizedDescription)")
//            }
//        }.resume()
//    }
//}

// testing file
class LocationService {
    func fetchLocations(completion: @escaping ([LocationInfo]) -> Void) {
        if let url = Bundle.main.url(forResource: "TestData", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                let locations = try JSONDecoder().decode([LocationInfo].self, from: data)
                DispatchQueue.main.async {
                    completion(locations)
                }
            } catch {
                print("Failed to decode locations: \(error.localizedDescription)")
            }
        } else {
            print("TestData.json file not found")
        }
    }
}
