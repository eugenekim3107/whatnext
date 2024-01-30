//
//  ExploreView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ExploreView: View {
    var body: some View {
        let viewModel1 = LocationRowViewModel()
        let viewModel2 = LocationRowViewModel()
        let viewModel3 = LocationRowViewModel()
        let viewModel4 = LocationRowViewModel()

        NavigationView {
            ScrollView {
                VStack (spacing: 0) {
                    LocationRowView(
                        viewModel: viewModel1,
                        title: "Food and Drinks",
                        latitude: 32.88088,
                        longitude: 117.23790,
                        categories: "food",
                        radius: 5000,
                        cur_open: true,
                        sort_by: "review_count",
                        limit: 15,
                        api_key: "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"
                    )
                    LocationRowView(
                        viewModel: viewModel2,
                        title: "Coffee Spots",
                        latitude: 32.88088,
                        longitude: 117.23790,
                        categories: "coffee",
                        radius: 5000,
                        cur_open: true,
                        sort_by: "best_match",
                        limit: 15,
                        api_key: "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"
                    )
                    LocationRowView(
                        viewModel: viewModel3,
                        title: "Step In Style",
                        latitude: 32.88088,
                        longitude: 117.23790,
                        categories: "shoes",
                        radius: 5000,
                        cur_open: true,
                        sort_by: "rating",
                        limit: 15,
                        api_key: "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"
                    )
                    LocationRowView(
                        viewModel: viewModel4,
                        title: "Let's Workout!",
                        latitude: 32.88088,
                        longitude: 117.23790,
                        categories: "gyms",
                        radius: 5000,
                        cur_open: true,
                        sort_by: "best_match",
                        limit: 15,
                        api_key: "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"
                    )
                }
                .navigationBarTitle("Explore", displayMode: .large)
                .padding(.top)
                .padding(.bottom, 50)
            }
            .background(Color(UIColor.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreView()
    }
}
