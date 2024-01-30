//
//  LocationInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//
import Foundation
import CoreLocation

struct LocationInfo: Codable, Identifiable {
    let id: String
    let name: String
    let imageUrl: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
