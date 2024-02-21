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
    @State private var trackingMode: MapUserTrackingMode = .follow
    @State private var selectedLocation: Location?
    @State private var userHasInteracted = false
    @State private var showingDetail = false
    @GestureState private var magnification: CGFloat = 1.0

    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region,
                interactionModes: .all,
                showsUserLocation: true,
                userTrackingMode: $trackingMode,
                annotationItems: viewModel.locations) { location in
                    MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.latitude ?? 0, longitude: location.longitude ?? 0)) {
                        Button(action: {
                            DispatchQueue.main.async {
                                self.selectedLocation = location
                                self.showingDetail = true
                            }
                        }) {
                            pinImage(for: location.categories ?? [""]) // Now accepts [String]
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                        }
                    }
                }
                .gesture(
                    DragGesture().onChanged({ _ in userHasInteracted = true })
                )
                .ignoresSafeArea(edges: .all)
            
            // Only show the button if the user has interacted with the map
            if userHasInteracted {
                VStack {
                    Button("Search This Area") {
                        viewModel.searchInNewArea(center: viewModel.region.center)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.top, 20) // Add some padding from the top edge
                    .transition(.opacity) // Smoothly fade in the button
                    .animation(.easeInOut, value: userHasInteracted)

                    Spacer() // Push the button to the top
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
                        
            if showingDetail, let selectedLocation = selectedLocation {
                LocationDetailView(location: selectedLocation, dismissAction: {
                    self.showingDetail = false // Set to false when dismissing the detail view
                    self.selectedLocation = nil
                    
                })
                .transition(.opacity)
                .zIndex(2)
            }
        }
    }

    private func zoomMap(by delta: CGFloat) {
        let span = viewModel.region.span
        let newLatDelta = max(0.002, min(100, span.latitudeDelta / Double(delta)))
        let newLonDelta = max(0.002, min(100, span.longitudeDelta / Double(delta)))
        viewModel.region.span = MKCoordinateSpan(latitudeDelta: newLatDelta, longitudeDelta: newLonDelta)
    }
    
    private func pinImage(for categories: [String]) -> Image {
        if categories.contains("food") {
            return Image("food.pin")
        } else if categories.contains("fitness") {
            return Image("fitness.pin")
        } else {
            return Image("heart.pin") // A default pin for other categories
        }
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

extension Location {
    var CLLocationCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude ?? 0.0, longitude: self.longitude ?? 0.0)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}

