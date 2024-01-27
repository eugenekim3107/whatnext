//
//  LocationInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

struct YelpResponse: Codable {
    let businesses: [LocationInfo]
}

struct LocationInfo: Codable {
    let id: String
    let name: String
    let image_url: String?
    let is_closed: Bool
    let url: String?
    let review_count: Int
    let categories: [Category]
    let rating: Double
    let coordinates: Coordinates
    let transactions: [String]
    let location: Location
    let phone: String?
    let display_phone: String?
    let distance: Double?
}

struct Category: Codable {
    let alias: String
    let title: String
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Location: Codable {
    let address1: String?
    let address2: String?
    let address3: String?
    let city: String?
    let zip_code: String?
    let country: String?
    let state: String?
    let display_address: [String]
}
