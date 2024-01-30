//
//  MapView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//  updated by Mike on 1/28/24

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var viewModel = MapViewModel()
    @State private var trackingMode: MapUserTrackingMode = .follow // State to track user location

    var body: some View {
            Map(coordinateRegion: $viewModel.region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: viewModel.locations) { location in
                                MapAnnotation(coordinate: location.coordinate) {
                                    AnnotationView(imageUrl: location.imageUrl)
                                }
                            }
                .ignoresSafeArea(edges: .all)
        }
}

struct AnnotationView: View {
    let imageUrl: String

    var body: some View {
        if let url = URL(string: imageUrl) {
            AsyncImage(url: url) { image in
                image.resizable()
                     .scaledToFit()
                     .frame(width: 60, height: 60) // Customize the size as needed
                     .clipShape(Rectangle())
            } placeholder: {
                ProgressView()
            }
        } else {
            // Provide a fallback view in case the URL is invalid
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .clipShape(Rectangle())
        }
    }
}


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
