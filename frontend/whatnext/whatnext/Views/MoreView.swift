//
//  MoreView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI

struct MoreView: View {
    var body: some View {
        More()
    }
}

struct MoreView_Previews: PreviewProvider {
    static var previews: some View {
        MoreView()
    }
}

struct More : View {
    var body: some View{
        VStack(spacing: 0) {
            HStack{
                VStack(alignment: .leading) {
                    Text("More").font(.system(size: 45))
                }.foregroundColor(Color.black)
                Spacer()
            }.padding(.leading)
            HStack{
                Image("logo-icon")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                Text("WhatNext?")
                    .font(.system(size: 40))
                    .foregroundColor(.white.opacity(0.8))
                    .shadow(color: .white, radius: 10, x: 0, y: 0)
                    .shadow(color: .white, radius: 10, x: 0, y: 0)
            }.frame(maxWidth: .infinity, maxHeight: 100)
            .background(Color(hex: "5BC0EB"))
            Spacer()
        }
    }
}
