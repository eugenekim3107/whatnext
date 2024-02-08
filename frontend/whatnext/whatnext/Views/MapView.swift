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
    @State private var selectedLocation: LocationInfo?
    @GestureState private var magnification: CGFloat = 1.0

    var body: some View {
        let magnifyGesture = MagnificationGesture()
            .updating($magnification) { (currentState, gestureState, transaction) in
                gestureState = currentState
            }
            .onEnded { value in
                let delta = value - 1
                zoomMap(by: delta)
            }

        
        Map(coordinateRegion: $viewModel.region,
            interactionModes: .all,
            showsUserLocation: true,
            userTrackingMode: $trackingMode,
            annotationItems: viewModel.locations) { location in
            MapAnnotation(coordinate: location.coordinates.CLLocation) {
                Image("food.pin") // Using a custom image from assets
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40) // Adjust size as needed
                    .onTapGesture {
                        self.selectedLocation = location
                    }
            }
        }            
            .overlay(
                Group {
                    if let selectedLocation = selectedLocation {
                        LocationDetailView(location: selectedLocation) {
                            // Define what should happen when the view is dismissed
                            self.selectedLocation = nil
                        }
                        .transition(.scale)
                        .animation(.easeInOut, value: selectedLocation != nil)
                    }
                },
                alignment: .center
            )
            .gesture(magnifyGesture)
            .ignoresSafeArea(edges: .all)
    }
    private func zoomMap(by delta: CGFloat) {
            let span = viewModel.region.span
            let newLatDelta = max(0.002, min(100, span.latitudeDelta / Double(delta)))
            let newLonDelta = max(0.002, min(100, span.longitudeDelta / Double(delta)))
            viewModel.region.span = MKCoordinateSpan(latitudeDelta: newLatDelta, longitudeDelta: newLonDelta)
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
            Image(systemName: "logo-icon")
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
