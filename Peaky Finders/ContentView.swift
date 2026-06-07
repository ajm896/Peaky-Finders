//
//  ContentView.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/3/26.
//

import SwiftUI
import CoreLocation
import MapKit

/// Root view. Owns `LocationProvider`, gates the UI through authorization and
/// sensor-availability states, then hands off to `SightingsMapView` once both
/// location and heading are live.
struct ContentView: View {
    @State private var locationProvider = LocationProvider()
    /// Maximum distance (meters) for which peaks are included in the sightings list.
    /// Bound to the range slider in `SightingsMapView`. Default is 100 km.
    @State private var sightingRange: CLLocationDistance = 100_000
    
    
    var body: some View {
        VStack{
            switch locationProvider.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                if let currentLocation = locationProvider.currentLocation {
                    if let heading = locationProvider.heading {
                        let sightings: [Sighting] = PeakCatalog.all.sightings(from: currentLocation, within: sightingRange)
                        SightingsMapView(sightings: sightings, heading: heading, userLocation: currentLocation, sightingRange: $sightingRange)
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
