//
//  LocationInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import Foundation

struct LocationInfo: Codable, Identifiable {
    let id: String
    let name: String
    let imageUrl: String
}
