//
//  LocationRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import SwiftUI

struct LocationRowView: View {
    @ObservedObject var viewModel: LocationRowViewModel
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.black)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(viewModel.locations, id: \.id) { location in
                        VStack {
                            // Replace with AsyncImageView if needed
                            Image(location.imageUrl)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            Text(location.name)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .onAppear {
            viewModel.fetchLocations()
        }
    }
}

struct LocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        // Add mock locations to viewModel.locations if needed
        return LocationRowView(viewModel: viewModel, title: "Favorites")
    }
}
