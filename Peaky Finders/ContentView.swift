//
//  ContentView.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/3/26.
//

import CoreLocation
import MapKit
import SwiftUI

/// Root view. Drives location/heading acquisition and, once both are available,
/// shows the bearing and distance to the target peak.
struct ContentView: View {
    @State private var locationProvider = LocationProvider()
    @State private var sightingRange: CLLocationDistance = 100_000
    @State private var selectedSighting = PeakCatalog.all.sightings(
        from: homeOfficeDebug
    ).sorted(by: { $0.distance < $1.distance })[0]

    var body: some View {
        TabView {
            Tab("View Finder", systemImage: "binoculars") {
                SightingScreen(locationProvider: locationProvider)
            }

            Tab("Map", systemImage: "map") {
                MapView(
                    locationProvider: locationProvider,
                    sightingRange: $sightingRange
                )
            }
        }.onAppear() {
            locationProvider.start()
            
        }
    }
}

#Preview {
    ContentView()
}
