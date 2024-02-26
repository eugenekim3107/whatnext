//
//  LocationDetailView.swift
//  whatnext
//
//  Created by Mike Dong on 2/4/24.
//

//import SwiftUI
//
//struct LocationDetailView: View {
//    let location: Location
//    var dismissAction: () -> Void
//
//    var body: some View {
//        VStack {
//            // Dismiss button
//            HStack {
//                Spacer()
//                Button(action: dismissAction) {
//                    Image(systemName: "xmark.circle.fill")
//                        .imageScale(.large)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding([.top, .trailing])
//
//            // Image
//            AsyncImage(url: URL(string: location.imageUrl ?? "")) { phase in
//                switch phase {
//                case .empty:
//                    ProgressView()
//                case .success(let image):
//                    image.resizable()
//                         .aspectRatio(contentMode: .fit)
//                         .frame(maxWidth: .infinity)
//                case .failure:
//                    Image(systemName: "photo")
//                        .imageScale(.large)
//                        .foregroundColor(.gray)
//                @unknown default:
//                    EmptyView()
//                }
//            }
//            .frame(height: 180) // Adjusted for a more compact layout
//
//            // Name and rating
//            VStack(alignment: .leading, spacing: 8) {
//                Text(location.name)
//                    .font(.title2)
//                    .bold()
//                
//                HStack {
//                    ForEach(0..<5, id: \.self) { index in
//                        Image(systemName: index < Int(location.stars ?? 0.0) ? "star.fill" : "star")
//                            .foregroundColor(index < Int(location.stars ?? 0.0) ? .yellow : .gray)
//                    }
//                    // Fixed string interpolation for stars and review count
//                    Text("\(location.stars ?? 0.0, specifier: "%.1f") (\(location.reviewCount ?? 0) reviews)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//            }
//            .padding()
//            Spacer()
//        }
//        .frame(width: 300, height: 360) // Adjusted height for compact layout
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 5)
//        .padding(.bottom, 50) // Add padding at the bottom for safe area
//    }
//}

import SwiftUI

struct LocationDetailView: View {
    let location: Location
    var dismissAction: () -> Void

    var body: some View {
        VStack {
            // Dismiss button
            HStack {
                Spacer()
                Button(action: {
                    print("Dismiss tapped") // Debugging line
                    self.dismissAction()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(.gray)
                }
                .padding([.top, .trailing], 20)
            }

            // Image
            if let imageUrl = location.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 180)
                .clipped()
            }

            // Open/Closed indicator
            HStack {
                Text(location.curOpen == 1 ? "OPEN" : "CLOSED")
                    .bold()
                    .foregroundColor(location.curOpen == 1 ? .green : .red)
                Spacer()
            }
            .padding(.horizontal)

            // Location name and rating
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name)
                    .font(.title2)
                    .bold()

                // Star ratings and number of reviews
                HStack {
                    ForEach(0..<5, id: \.self) { index in
                        Image(systemName: index < Int(location.stars ?? 0) ? "star.fill" : "star")
                            .foregroundColor(index < Int(location.stars ?? 0) ? .yellow : .gray)
                    }
                    Text("\(String(format: "%.1f", location.stars ?? 0)) (\(location.reviewCount ?? 0) reviews)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)

            // Price and category tags
            HStack {
                Text(location.price ?? "")
                    .bold()
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(4)

                ForEach(location.categories ?? [], id: \.self) { category in
                    Text(category)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
            }
            .padding(.horizontal)

            Divider().padding(.horizontal)

            // Additional details: hours, phone, and address
            VStack(alignment: .leading, spacing: 8) {
                if let hours = location.hours {
                    DetailRow(iconName: "clock", text: "Hours", detailText: "Open", action: {})
                }
                
                if let phone = location.displayPhone {
                    DetailRow(iconName: "phone", text: "Phone", detailText: phone, action: {})
                }
                
                Text(location.address ?? "")
                    .font(.footnote)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
        .padding()
    }
    
    // A helper view to create a row with an icon, text, and an action
    @ViewBuilder
    func DetailRow(iconName: String, text: String, detailText: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: iconName)
                    .foregroundColor(.blue)
                Text(text)
                    .bold()
                Spacer()
                Text(detailText)
                    .foregroundColor(.gray)
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
    }
}
