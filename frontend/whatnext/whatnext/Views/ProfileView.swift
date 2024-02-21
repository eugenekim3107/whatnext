//
//  ProfileView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @StateObject private var friendModel = ProfileRowViewModel()
    @StateObject private var favoritesModel = LocationRowViewModel()
    @StateObject private var visitedModel = LocationRowViewModel()
    
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack (spacing: 20) {
                        VStack (spacing: 3) {
                            if let imageUrl = viewModel.userInfo?.imageUrl, let url = URL(string: imageUrl) {
                                AsyncImage(url: url) { image in
                                    image.resizable()
                                } placeholder: {
                                    ProfilePlaceholderView()
                                }
                                .frame(width: 110, height: 110)
                                .clipShape(Circle())
                            } else {
                                ProfilePlaceholderView()
                            }
                            
                            Text(viewModel.userInfo?.displayName ?? "Loading...")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(height: 40)
                                .frame(width: 110)
                        }
                        ProfileStatistics(
                            friendsCount: viewModel.userInfo?.friends.count ?? 0,
                            favoritesCount: viewModel.userInfo?.favorites.count ?? 0,
                            visitedCount: viewModel.userInfo?.visited.count ?? 0
                        )
                    }
                    ProfileRowView(
                        viewModel: friendModel,
                        title: "Friends",
                        userId: "eugenekim"
                    )
                    FavoritesRowView(
                        viewModel: favoritesModel,
                        title: "Favorites",
                        userId: "eugenekim"
                    )
                    VisitedRowView(
                        viewModel: visitedModel,
                        title: "Visited",
                        userId: "eugenekim"
                    )
                }
                .navigationBarTitle("Profile", displayMode: .large)
                .padding(.bottom, 50)
            }
            .onAppear {
                viewModel.fetchUserInfo(userId: "eugenekim")
            }
            .refreshable {
                viewModel.refreshData(userId: "eugenekim")
                friendModel.refreshData(userId: "eugenekim")
                favoritesModel.refreshDataFavorites(userId: "eugenekim")
                visitedModel.refreshDataFavorites(userId:"eugenekim")
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct ProfilePlaceholderView: View {
    var body: some View {
        Image("profile")
            .resizable()
            .frame(width: 110, height: 110)
    }
}

struct ProfileStatistics: View {
    let friendsCount: Int
    let favoritesCount: Int
    let visitedCount: Int

    var body: some View {
        HStack (spacing: 20) {
            statisticView(count: friendsCount, imageName: "friends.pin", label: "Friends")
            statisticView(count: favoritesCount, imageName: "heart.pin", label: "Favorites")
            statisticView(count: visitedCount, imageName: "visited.pin", label: "Visited")
        }
    }

    private func statisticView(count: Int, imageName: String, label: String) -> some View {
        VStack {
            Text("\(count)")
            HStack (spacing: 3) {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 10)
                Text(label).font(.system(size: 13))
            }
        }
    }
}



struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
