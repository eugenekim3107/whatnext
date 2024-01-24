//
//  ContentView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 2 // Default to the "Explore" tab
    
    let customSymbol = UIImage(named: "map.selected")

    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Image(selectedTab == 0 ? "map-icon-selected" : "map-icon-unselected")
                    Text("Maps")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(selectedTab == 1 ? "search-icon-selected" : "search-icon-unselected")
                    Text("Search")
                }
                .tag(1)
            
            ExploreView()
                .tabItem {
                    Image(selectedTab == 2 ? "explore-icon-selected" : "explore-icon-unselected")
                    Text("Explore")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Image(selectedTab == 3 ? "profile-icon-selected" : "profile-icon-unselected")
                    Text("Profile")
                }
                .tag(3)
            
            MoreView()
                .tabItem {
                    Image(selectedTab == 4 ? "more-icon-selected" : "more-icon-unselected")
                    Text("More")
                }
                .tag(4)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

