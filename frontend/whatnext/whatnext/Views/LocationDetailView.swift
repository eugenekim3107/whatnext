//
//  LocationDetailView.swift
//  whatnext
//
//  Created by Mike Dong on 2/4/24.
//

import SwiftUI

struct LocationDetailView: View {
    let location: LocationInfo

    var body: some View {
        VStack(alignment: .leading) {
            Text(location.name)
                .font(.title)
            // Display other details
            Text("Rating: \(location.rating, specifier: "%.1f")")
            // Add more details as needed
        }
        .padding()
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
