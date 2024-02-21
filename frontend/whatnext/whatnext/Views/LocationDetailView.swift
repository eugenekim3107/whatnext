//
//  LocationDetailView.swift
//  whatnext
//
//  Created by Mike Dong on 2/4/24.
//

import SwiftUI

struct LocationDetailView: View {
    let location: Location
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
            AsyncImage(url: URL(string: location.imageUrl ?? "")) { phase in
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
                        Image(systemName: index < Int(location.stars ?? 0.0) ? "star.fill" : "star")
                            .foregroundColor(index < Int(location.stars ?? 0.0) ? .yellow : .gray)
                    }
                    // Fixed string interpolation for stars and review count
                    Text("\(location.stars ?? 0.0, specifier: "%.1f") (\(location.reviewCount ?? 0) reviews)")
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

//import SwiftUI
//
//struct LocationDetailView: View {
//    let location: Location
//    var dismissAction: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .topTrailing) {
//            VStack(alignment: .leading, spacing: 10) {
//                HStack {
//                    Spacer()
//                    Button(action: dismissAction) {
//                        Image(systemName: "xmark.circle.fill")
//                            .imageScale(.large)
//                            .foregroundColor(.gray)
//                    }
//                }
//                .padding(.trailing)
//
//                if let imageUrl = location.imageUrl, let url = URL(string: imageUrl) {
//                    AsyncImage(url: url) { image in
//                        image.resizable().aspectRatio(contentMode: .fill)
//                    } placeholder: {
//                        Color.gray.opacity(0.3)
//                    }
//                    .frame(height: 180)
//                    .clipped()
//                }
//
//                Text(location.name)
//                    .font(.title2)
//                    .bold()
//
//                HStack {
//                    ForEach(0..<5, id: \.self) { index in
//                        Image(systemName: index < Int(location.stars ?? 0) ? "star.fill" : "star")
//                            .foregroundColor(index < Int(location.stars ?? 0) ? .yellow : .gray)
//                    }
//                    Text("\(String(format: "%.1f", location.stars ?? 0)) (\(location.reviewCount ?? 0) reviews)")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//
//                if let price = location.price {
//                    Text(price).bold()
//                }
//
//                HStack {
//                    ForEach(location.tag ?? [], id: \.self) { tag in
//                        Text(tag)
//                            .padding(5)
//                            .background(Color.blue)
//                            .foregroundColor(.white)
//                            .cornerRadius(5)
//                    }
//                }
//
//                if let hours = location.hours {
//                    // Assuming you have a method to format hours, like getTodaysHours()
//                    Text("Hours: \(getTodaysHours(hours))")
//                }
//
//                if let phone = location.displayPhone {
//                    Text("Phone: \(phone)")
//                }
//
//                // Add other details like address if you need
//                // ...
//
//                Spacer()
//            }
//            .padding()
//            .frame(maxWidth: .infinity)
//        }
//        .background(Color.white)
//        .cornerRadius(12)
//        .shadow(radius: 5)
//        .padding()
//    }
//
//    // Placeholder function for getting today's hours, adjust according to your needs
//    private func getTodaysHours(_ hours: Hours) -> String {
//        let weekDay = Calendar.current.component(.weekday, from: Date())
//        let daysOfWeek = [
//            1: hours.Sunday,
//            2: hours.Monday,
//            3: hours.Tuesday,
//            4: hours.Wednesday,
//            5: hours.Thursday,
//            6: hours.Friday,
//            7: hours.Saturday
//        ]
//        
//        if let todayHours = daysOfWeek[weekDay] ?? [], !todayHours.isEmpty {
//            return todayHours.joined(separator: ", ")
//        } else {
//            return "Not Available"
//        }
//    }
//}
