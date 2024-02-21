//
//  ProfileInfo.swift
//  whatnext
//
//  Created by Eugene Kim on 2/20/24.
//

import Foundation

struct Profile: Identifiable, Decodable {
    var id: String {userId}
    let userId: String
    let displayName: String
    let imageUrl: String?
    let friends: [String]
    let visited: [String]
    let favorites: [String]
}
