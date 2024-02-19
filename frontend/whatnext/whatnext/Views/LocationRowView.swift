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
    let latitude: Double
    let longitude: Double
    let categories: String
    let radius: Double
    let curOpen: Int
    let sortBy: String
    let limit: Int
    @State private var scrollIndex = 0
    @State private var timer: Timer?
    @State private var isManuallyScrolling = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .padding(.leading)
            
            if viewModel.isLoading {
                PlaceholderView()
            } else {
                ScrollViewReader { scrollView in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(viewModel.locations, id: \.businessId) { location in
                                LocationRowSimpleView(location: location)
                            }
                        }
                        .gesture(
                            DragGesture().onChanged { _ in
                                isManuallyScrolling = true
                                timer?.invalidate()
                            }
                                .onEnded { _ in
                                    isManuallyScrolling = false
                                    startTimer(scrollView: scrollView)
                                }
                        )
                    }
                    .padding([.leading, .trailing])
                    .onAppear {
                        startTimer(scrollView: scrollView)
                    }
                    .onDisappear {
                        timer?.invalidate()
                    }
                }
            }
        }
        .onAppear {
        viewModel.fetchNearbyLocations(latitude: latitude,
                                       longitude: longitude,
                                       limit: self.limit,
                                       radius: self.radius,
                                       categories: categories,
                                       curOpen: curOpen,
                                       sortBy: self.sortBy)
        }
    }
    
    private func startTimer(scrollView: ScrollViewProxy) {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                guard !isManuallyScrolling, viewModel.locations.count > 0 else { return }
                scrollIndex = (scrollIndex + 1) % viewModel.locations.count
                scrollView.scrollTo(viewModel.locations[scrollIndex].businessId, anchor: .leading)
            }
        }
    }
}

struct LocationRowSimpleView: View {
    var location: Location

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let url = URL(string: location.imageUrl ?? "") {
                    ZStack{
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                    }
                    .frame(width: 110, height: 110)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Color.gray.opacity(0.3)
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 10, height: 10)
                        .foregroundColor(.yellow)
                    Group {
                        if let stars = location.stars {
                            Text(String(format: "%.1f", stars))
                        } else {
                            Text("N/A")
                        }
                    }
                    .font(.system(size: 10))
                    .foregroundColor(.white)
                }
                .padding(3)
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding([.top, .leading], 5)
            }
            .frame(width: 110, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 6))
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
    
struct PlaceholderView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.gray.opacity(0.3))
            .frame(height: 150)
            .padding(.horizontal)
            .redacted(reason: .placeholder)
    }
}

struct LocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return LocationRowView(
            viewModel: viewModel,
            title: "Let's Workout!",
            latitude: 32.88088,
            longitude: -117.23790,
            categories: "fitness",
            radius: 10000,
            curOpen: 1,
            sortBy: "review_count",
            limit: 15
        )
    }
}
