//
//  FavoritesRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/21/24.
//

import SwiftUI

struct FavoritesRowView: View {
    @ObservedObject var viewModel: LocationRowViewModel
    let title: String
    let userId: String
    @State private var showingLocationDetail: Location?
    
    init(viewModel: LocationRowViewModel, title: String, userId: String) {
        self.viewModel = viewModel
        self.title = title
        self.userId = userId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack (spacing: 5) {
                Image("heart.pin")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20)
                Text(title)
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.black)
            }.padding(.leading)
            if viewModel.isLoading {
                PlaceholderView()
            } else {
                ScrollViewReader { scrollView in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 5) {
                            ForEach(viewModel.favoritesInfo, id: \.businessId) { location in
                                LocationRowSimpleView(location: location)
                                    .onTapGesture {
                                        self.showingLocationDetail = location
                                    }
                            }
                        }
                    }
                    .sheet(item: $showingLocationDetail) { location in
                        LocationDetailView(location: location)
                    }
                    .padding([.leading, .trailing])
                }
            }
        }
        .onAppear {
            viewModel.fetchFavoritesInfo(userId: userId)
        }
    }
}

struct FavoritesRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = LocationRowViewModel()
        return FavoritesRowView(
            viewModel: viewModel,
            title: "Favorites",
            userId: "wiVOrMOJ8COqs7d6OgCBNVTV9lt2"
        )
    }
}
