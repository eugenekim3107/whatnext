//
//  InteractiveLocationView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/13/24.
//

import SwiftUI

struct InteractiveLocationView: View {
    var locations: [Location] // Accept locations array

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(locations) { location in
                    LocationSimpleView(location: location)
                        .onTapGesture {
                            print("Tapped on location: \(location.name)")
                        }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 150)
    }
}

struct LocationSimpleView: View {
    var location: Location

    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
                .cornerRadius(8)
            
            Text(location.name)
                .font(.caption)
                .lineLimit(1)
        }
        .frame(width: 120, height: 140)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(12)
        .padding(.leading, 8)
    }
}

struct InteractiveLocationView_Previews: PreviewProvider {
    static var previews: some View {
        // Create some sample locations to preview
        let exampleLocations = [
            Location(
                businessId: "001",
                name: "Coffee Central",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.005974, 40.712776]),
                price: nil
            ),
            Location(
                businessId: "002",
                name: "Coffee Place",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-73.005974, 41.712776]),
                price: nil
            ),
            Location(
                businessId: "003",
                name: "Please",
                imageUrl: nil,
                phone: nil,
                displayPhone: nil,
                address: nil,
                city: nil,
                state: nil,
                postalCode: nil,
                latitude: nil,
                longitude: nil,
                stars: nil,
                reviewCount: nil,
                curOpen: nil,
                categories: nil,
                tag: nil,
                hours: nil,
                location: GeoJSON(type: "Point", coordinates: [-74.205974, 40.711776]),
                price: nil
            ),
        ]



        InteractiveLocationView(locations: exampleLocations)
    }
}
