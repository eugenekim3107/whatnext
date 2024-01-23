//
//  ContentView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // The MapView is now directly instantiated without a ViewModel.
            MapView()
                .ignoresSafeArea(edges: .all)
            
//            Text("ContentView")
//                .foregroundColor(.white)
//                .font(.system(size: 30))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

