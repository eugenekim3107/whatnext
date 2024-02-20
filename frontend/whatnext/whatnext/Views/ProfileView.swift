//
//  ProfileView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    HStack (spacing: 20) {
                        VStack (spacing: 3) {
                            ProfilePlaceholderView()
                            Text("Eugene Kim")
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(height: 40)
                                .frame(width: 110)
                        }
                        ProfileStatistics()
                    }
                }
                .navigationBarTitle("Profile", displayMode: .large)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}


struct ProfilePlaceholderView: View {
    var body: some View {
        Image("profile.fill")
            .resizable()
            .frame(width: 110, height: 110)
            .symbolRenderingMode(.palette)
            .foregroundStyle(ShineColor.platinum.linearGradient, ShineColor.gold.linearGradient)
    }
}

struct ProfileStatistics: View {
    var body: some View {
        HStack (spacing: 20){
            VStack{
                Text("5")
                HStack (spacing: 3){
                    Image("friends.pin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10)
                    Text("Friends").font(.system(size: 13))
                }
            }
            VStack{
                Text("5")
                HStack (spacing: 3) {
                    Image("heart.pin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10)
                    Text("Favorites").font(.system(size: 13))
                }
            }
            VStack{
                Text("5")
                HStack (spacing: 3) {
                    Image("visited.pin")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10)
                    Text("Visited").font(.system(size: 13))
                }
            }
        }
    }
}


struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
