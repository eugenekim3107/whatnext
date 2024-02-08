//
//  LocationDetailView.swift
//  whatnext
//
//  Created by Mike Dong on 2/4/24.
//

import SwiftUI

struct LocationDetailView: View {
    let location: LocationInfo
    var dismissAction: () -> Void

    var body: some View {
        VStack {
            // Dismiss button
            HStack {
                Spacer()
                Button(action: dismissAction) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                }
            }
            .padding([.top, .trailing])

            // Image
            AsyncImage(url: URL(string: location.image_url ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(maxWidth: .infinity)
                case .failure:
                    Image(systemName: "photo")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 180) // Adjusted for a more compact layout

            // Name and rating
            VStack(alignment: .leading, spacing: 8) {
                Text(location.name)
                    .font(.title2)
                    .bold()
                
                HStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(location.rating) ? "star.fill" : "star")
                            .foregroundColor(index < Int(location.rating) ? .yellow : .gray)
                    }
                    Text("\(location.rating, specifier: "%.1f") (\(location.review_count) reviews)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()

            Spacer()
        }
        .frame(width: 300, height: 360) // Adjusted height for compact layout
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
        .padding(.bottom, 50) // Add padding at the bottom for safe area
    }
}
