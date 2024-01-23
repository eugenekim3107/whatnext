//
//  MapView.swift
//  whatnext
//
//  Created by Eugene Kim on 1/21/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        print("makeUIView called")
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Perform any updates to the UI here.
    }

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator()
    }
}
