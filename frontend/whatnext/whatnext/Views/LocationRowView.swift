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
    let api_key: String
    @State private var scrollIndex = 0
    @State private var timer: Timer?
    @State private var isManuallyScrolling = false

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
                            VStack(spacing: 0) {
                                ZStack(alignment: .topLeading) {
                                    if let url = URL(string: location.image_url ?? "") {
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
                                    }
                                    
                                    HStack(spacing: 2) {
                                        Image(systemName: "star.fill")
                                            .resizable()
                                            .frame(width: 10, height: 10)
                                            .foregroundColor(.yellow)
                                        Text(String(format: "%.1f", location.rating ))
                                            .font(.system(size: 10))
                                            .foregroundColor(.white)
                                    }
                                    .padding(3)
                                    .background(Color.gray)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                                    .padding([.top, .leading], 5)
                                }
                                Text(location.name )
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
        .onAppear {
            viewModel.fetchLocations(latitude: latitude, longitude: longitude, categories: categories, api_key: api_key)
        }
    }
    
    private func startTimer(scrollView: ScrollViewProxy) {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                guard !isManuallyScrolling, viewModel.locations.count > 0 else { return }
                scrollIndex = (scrollIndex + 1) % viewModel.locations.count
                scrollView.scrollTo(viewModel.locations[scrollIndex].id, anchor: .leading)
            }
        }
    }
}

struct LocationRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return LocationRowView(
            viewModel: viewModel,
            title: "Food And Drinks",
            latitude: 32.88088,
            longitude: 117.23790,
            categories: "fitness",
            api_key: "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"
        )
    }
}
