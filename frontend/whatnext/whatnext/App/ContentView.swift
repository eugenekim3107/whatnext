//
//  ContentView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = Tab.map

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack {
            VStack {
                TabView(selection: $selectedTab) {
                    MapView()
                        .edgesIgnoringSafeArea(.bottom)
                        .animation(nil, value: selectedTab)
                        .tag(Tab.map)
                    
                    SearchView()
                        .animation(nil, value: selectedTab)
                        .tag(Tab.search)
                    
                    ExploreView()
                        .animation(nil, value: selectedTab)
                        .tag(Tab.explore)
                    
                    ProfileView()
                        .animation(nil, value: selectedTab)
                        .tag(Tab.profile)
                    
                    MoreView()
                        .animation(nil, value: selectedTab)
                        .tag(Tab.more)
                }
            }

            VStack {
                Spacer()
                TabBarView(selectedTab: $selectedTab)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
