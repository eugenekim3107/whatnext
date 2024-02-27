//
//  LocationDetailView.swift
//  whatnext
//
//  Created by Mike Dong on 2/4/24.
//

import SwiftUI
struct LocationDetailView: View {
    let location: Location

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ImageView(imageUrl: location.imageUrl)
                BusinessInfo(name: location.name, stars: location.stars, reviewCount: location.reviewCount)
                PriceAndCategoryView(price: location.price, categories: location.categories)
                HoursView(hours: location.hours, isOpen: location.curOpen == 1)
                ContactInfo(displayPhone: location.displayPhone, address: location.address, city: location.city, state: location.state, postalCode: location.postalCode)
            }
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

// ImageView for displaying the location's image
struct ImageView: View {
    let imageUrl: String?

    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            //.frame(height: 250)
        }
    }
}

// BusinessInfo for displaying the business name and ratings
struct BusinessInfo: View {
    let name: String
    let stars: Double?
    let reviewCount: Int?

    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .font(.largeTitle)
                .bold()
                .foregroundColor(.black)

            HStack {
                StarRatingView(stars: Int(stars ?? 0))
                if let stars = stars, let reviewCount = reviewCount {
                    Text("\(String(format: "%.1f", stars)) (\(reviewCount) reviews)")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
        }
        .padding()
    }
}

// StarRatingView for displaying star ratings
struct StarRatingView: View {
    let stars: Int

    var body: some View {
        HStack {
            ForEach(0..<5, id: \.self) { star in
                Image(systemName: star < stars ? "star.fill" : "star")
                    .foregroundColor(star < stars ? .yellow : .gray)
            }
        }
    }
}

// PriceAndCategoryView for displaying the price and categories
struct PriceAndCategoryView: View {
    let price: String?
    let categories: [String]?

    var body: some View {
        Divider()
            .background(Color.blue)
        HStack {
            Text(price ?? "")
                .bold()
                .padding(5)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5)

            ForEach(categories ?? [], id: \.self) { category in
                Text(category)
                    .padding(6)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal)
        .cornerRadius(10)
    }
}

struct HoursView: View {
    let hours: Hours?
    let isOpen: Bool
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Divider()
                .background(Color.blue)
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Hours")
                        .foregroundColor(.black)
                    Spacer()
                    if isOpen {
                        Text("Open Now")
                            .bold()
                            .foregroundColor(.green)
                    } else {
                        Text("Closed")
                            .bold()
                            .foregroundColor(.red)
                    }
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeOut, value: isExpanded)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                .animation(.easeOut, value: isExpanded)
            }
            
            if isExpanded, let formattedHours = hours?.formattedHours.sorted(by: { $0.key < $1.key }) {
                ForEach(formattedHours, id: \.key) { day, hours in
                    HStack {
                        Text(day + ":")
                            .bold()
                        Spacer()
                        Text(hours)
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 2)
                    .transition(.opacity.combined(with: .slide))
                }
            }
            Divider()
                .background(Color.blue)
        }
    }
}


// ContactInfo for displaying phone and address
struct ContactInfo: View {
    let displayPhone: String?
    let address: String?
    let city: String?
    let state: String?
    let postalCode: String?

    var body: some View {
        VStack(alignment: .leading) {
            if let displayPhone = displayPhone {
                Text("Phone: \(displayPhone)")
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 40)
        .cornerRadius(10)
        Divider()
            .background(Color.blue)
        VStack(alignment: .leading) {
            if let address = address, let city = city, let state = state, let postalCode = postalCode {
                Text("Address: \(address), \(city), \(state) \(postalCode)")
            }
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 40)
        .cornerRadius(10)
    }
}

// This extension is used in HoursView to format the hours string
extension String {
    func insert(separator: String, every n: Int) -> String {
        var result: String = ""
        var count = 0
        for char in self {
            if count % n == 0 && count > 0 {
                result += separator
            }
            result += String(char)
            count += 1
        }
        return result
    }
}

// This extension is used in HoursView to get a sorted array of key-value pairs
extension Dictionary where Key == String, Value == [String] {
    var keyValuePairs: [(key: String, value: [String])] {
        return map { (key, value) in (key, value) }.sorted { $0.key < $1.key }
    }
}

struct LocationDetailView_Previews: PreviewProvider {
    static var previews: some View {
        LocationDetailView(location: Location(
            businessId: "1",
            name: "Shorehouse Kitchen",
            imageUrl: "https://s3-media2.fl.yelpcdn.com/bphoto/cln5YeBlyDYnhYU8fASAng/o.jpg",
            phone: "+18584593300",
            displayPhone: "(858) 459-3300",
            address: "2236 Avenida De La Playa",
            city: "La Jolla",
            state: "CA",
            postalCode: "92037",
            latitude: 32.8539270057529,
            longitude: -117.254643428836,
            stars: 4.5,
            reviewCount: 2098,
            curOpen: 1,
            categories: ["New American", "Salad", "Sandwiches"],
            tag: ["coffee", "breakfast_brunch", "newamerican"],
            hours: Hours(
                Monday: ["0730","1430"],
                Tuesday: ["0730","1430"],
                Wednesday: ["0730","1430"],
                Thursday: ["0730","1430"],
                Friday: ["0730","1530"],
                Saturday: ["0730","1530"],
                Sunday: ["0730","1530"]
            ),
            location: GeoJSON(type: "Point", coordinates: [-117.254643428836, 32.8539270057529]),
            price: "$$"
        ))
    }
}
