//
//  AsyncImageView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/24/24.
//

import SwiftUI

struct AsyncImageView: View {
    @StateObject private var loader: ImageLoader
    var placeholder: Image

    init(url: URL, placeholder: Image = Image(systemName: "photo")) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url))
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
            } else {
                Rectangle()
                    .foregroundColor(.gray)
                    .opacity(0.3)
            }
        }
        .onAppear(perform: loader.load)
        .frame(width: 120, height: 120) // Set the frame size
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        if let url = URL(string: "https://whatnext-location-images.s3.us-west-1.amazonaws.com/tacostand.png") {
            AsyncImageView(url: url)
        } else {
            Text("Invalid URL")
        }
    }
}
