//
//  ContentView.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/3/26.
//

import SwiftUI
import CoreLocation

let mountMitchell = CLLocation(latitude: 35.764839, longitude: -82.2651221)

struct ContentView: View {
    @State private var locationProvider = LocationProvider()
    var body: some View {
        VStack {
            switch locationProvider.authorizationStatus {
            case .notDetermined:
                Text("Requesting location access")
            case .restricted, .denied:
                Text("Location Access Denied")
            default:
                if let heading = locationProvider.heading {
                    Text("Heading: \(heading)°")
                } else {
                    Text("No heading available")
                }
                
                if let location = locationProvider.currentLocation {
                    Text("Lat: \(location.coordinate.latitude), Lon: \(location.coordinate.longitude)")
                } else {
                    Text("Waiting for location")
                }
            }
            let distance = locationProvider.currentLocation?.distance(from: mountMitchell)
            if let distance {
                Text("Distance to Mt. Mitchell: \(distance/1000) km")
            } else {
                Text("Location not Found")
            }
            
        }
        .padding()
        .font(.title2.monospacedDigit())
        .onAppear {
            locationProvider.start()
        }
    }
}

#Preview {
    ContentView()
}
