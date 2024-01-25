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
    @State private var scrollIndex = 0
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .padding(.leading)
            
            ScrollViewReader { scrollView in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
                        ForEach(viewModel.locations, id: \.id) { location in
                            VStack (spacing: 0) {
                                ZStack(alignment: .topLeading) {
                                    if let url = URL(string: location.imageUrl) {
                                        AsyncImageView(url: url)
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                    
                                    HStack (spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", location.rating))
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    }
                                    .padding(3)
                                    .background(Color.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .padding([.top, .leading], 5)
                                }
                                Text(location.name)
                                    .font(.system(size: 14))
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .truncationMode(.tail)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(height: 50)
                                    .frame(width: 110)
                            }
                        }
                    }
                }
                .padding(.leading)
                .padding(.trailing)
                .onAppear {
                    timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { _ in
                        withAnimation {
                            scrollIndex = (scrollIndex + 1) % viewModel.locations.count
                            scrollView.scrollTo(viewModel.locations[scrollIndex].id, anchor: .leading)
                        }
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                }
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
