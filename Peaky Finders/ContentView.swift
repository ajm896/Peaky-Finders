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

    var body: some View {
        VStack {
            switch locationProvider.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if let currentLocation = locationProvider.currentLocation {
                    if let heading = locationProvider.heading {
                        let sightings: [Sighting] = PeakCatalog.all.sightings(
                            from: currentLocation,
                            within: sightingRange
                        )
                        SightingsMapView(
                            sightings: sightings,
                            heading: heading,
                            userLocation: currentLocation,
                            sightingRange: $sightingRange
                        )
                    } else {
                        Text("Aquiring heading...")
                    }
                } else {
                    Text("Aquiring location...")
                }
            case .notDetermined:
                Text("Requesting location access")
            case .restricted, .denied:
                Text("Location Access Denied")
            @unknown default:
                Text("Unknown Error")
            }
        }.onAppear {
            locationProvider.start()
        }
    }
}

#Preview {
    ContentView()
}
