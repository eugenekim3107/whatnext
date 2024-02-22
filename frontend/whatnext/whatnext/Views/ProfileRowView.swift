//
//  ProfileRowView.swift
//  whatnext
//
//  Created by Eugene Kim on 2/19/24.
//

import SwiftUI

struct ProfileRowView: View {
    @ObservedObject var viewModel: ProfileRowViewModel
    let title: String
    let userId: String
    @State private var scrollIndex = 0
    @State private var timer: Timer?
    @State private var isManuallyScrolling = false
    
    init(viewModel: ProfileRowViewModel, title: String, userId: String) {
        self.viewModel = viewModel
        self.title = title
        self.userId = userId
    }
 
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack (spacing: 5) {
                Image("friends.pin")
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
                            ForEach(viewModel.friendsInfo, id: \.userId) { profile in
                                ProfileRowSimpleView(profile: profile)
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
            viewModel.fetchFriendsInfo(userId: userId)
        }
    }
    
    private func startTimer(scrollView: ScrollViewProxy) {
        timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation {
                guard !isManuallyScrolling, viewModel.friendsInfo.count > 0 else { return }
                scrollIndex = (scrollIndex + 1) % viewModel.friendsInfo.count
                scrollView.scrollTo(viewModel.friendsInfo[scrollIndex].userId, anchor: .leading)
            }
        }
    }
}

struct ProfileRowSimpleView: View {
    var profile: UserInfo

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let url = URL(string: profile.imageUrl ?? "") {
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
                    .clipShape(Circle())
                } else {
                    Color.gray.opacity(0.3)
                }
            }
            .frame(width: 110, height: 110)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(profile.displayName)
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

struct ProfileRowView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = ProfileRowViewModel()
        return ProfileRowView(viewModel: viewModel,
                       title: "Friends",
                       userId: "eugenekim")
    }
}
