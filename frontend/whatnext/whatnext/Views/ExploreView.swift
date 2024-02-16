//
//  ExploreView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ExploreView: View {
    @StateObject var viewModel1 = LocationRowViewModel()
    @StateObject var viewModel2 = LocationRowViewModel()
    @StateObject var viewModel3 = LocationRowViewModel()
    @StateObject var viewModel4 = LocationRowViewModel()
    
    var body: some View {

        NavigationView {
            ScrollView {
                VStack (spacing: 0) {
                    LocationRowView(
                        viewModel: viewModel1,
                        title: "Food and Drinks",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: "food",
                        radius: 5000,
                        curOpen: 0,
                        sortBy: "review_count",
                        limit: 15
                    )
                    LocationRowView(
                        viewModel: viewModel2,
                        title: "Coffee Spots",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: "coffee",
                        radius: 5000,
                        curOpen: 0,
                        sortBy: "best_match",
                        limit: 15
                    )
                    LocationRowView(
                        viewModel: viewModel3,
                        title: "Shopping Spree!",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: "shopping",
                        radius: 5000,
                        curOpen: 0,
                        sortBy: "rating",
                        limit: 15
                    )
                    LocationRowView(
                        viewModel: viewModel4,
                        title: "Let's Workout!",
                        latitude: 32.88088,
                        longitude: -117.23790,
                        categories: "fitness",
                        radius: 5000,
                        curOpen: 0,
                        sortBy: "best_match",
                        limit: 15
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
