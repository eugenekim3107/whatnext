//
//  LocationInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

// Define the GeoJSON structure for the location
struct GeoJSON: Codable, Hashable {
    let type: String
    let coordinates: [Double]
}

// Define the structure for the opening hours
struct Hours: Codable, Hashable {
    let Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday: [String]?
    
    // Add a computed property to get a dictionary with formatted strings
    var formattedHours: [String: String] {
        Dictionary(uniqueKeysWithValues: [
            ("Monday", Monday),
            ("Tuesday", Tuesday),
            ("Wednesday", Wednesday),
            ("Thursday", Thursday),
            ("Friday", Friday),
            ("Saturday", Saturday),
            ("Sunday", Sunday)
        ].compactMap { day, hours in
            guard let hours = hours, hours.count == 2 else { return nil }
            let openTime = String(hours[0].prefix(2) + ":" + hours[0].suffix(2)) + "AM"
            let closeTime = String(hours[1].prefix(2) + ":" + hours[1].suffix(2)) + "PM"
            return (day, "\(openTime) - \(closeTime)")
        })
    }
}

// Define the main Location structure
struct Location: Codable, Identifiable, Hashable {
    var id: String { businessId }
    let businessId: String
    let name: String
    let imageUrl: String?
    let phone, displayPhone, address, city: String?
    let state, postalCode: String?
    let latitude, longitude: Double?
    let stars: Double?
    let reviewCount: Int?
    let curOpen: Int?
    let categories: [String]?
    let tag: [String]?
    let hours: Hours?
    let location: GeoJSON
    let price: String?
    
    enum CodingKeys: String, CodingKey {
        case businessId = "business_id"
        case name, imageUrl = "image_url", phone, displayPhone = "display_phone", address, city, state, postalCode = "postal_code", latitude, longitude, stars, reviewCount = "review_count", curOpen = "cur_open", categories, tag, hours, location, price
    }
}

// Define a struct to hold the array of locations for the API response
struct LocationsResponse: Codable {
    let locations: [Location]
}
