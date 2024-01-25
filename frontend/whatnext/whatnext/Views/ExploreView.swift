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
                    LocationRowView(viewModel: viewModel1, title: "Picks For You")
                    LocationRowView(viewModel: viewModel2, title: "Food and Drinks")
                    LocationRowView(viewModel: viewModel3, title: "Trending Spots")
                    LocationRowView(viewModel: viewModel4, title: "Outdoor Activites")
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
