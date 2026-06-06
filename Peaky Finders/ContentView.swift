//
//  ContentView.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/3/26.
//

import SwiftUI
import CoreLocation

/// Root view. Drives location/heading acquisition and, once both are available,
/// shows the bearing and distance to the target peak.
struct ContentView: View {
    @State private var locationProvider = LocationProvider()
    
    var body: some View {
        VStack{
            switch locationProvider.authorizationStatus {
            case .notDetermined:
                Text("Requesting location access")
            case .restricted, .denied:
                Text("Location Access Denied")
            default:
                if let currentLocation = locationProvider.currentLocation {
                    if let heading = locationProvider.heading {
                        DebugDisplay(
                            currentLocation: currentLocation,
                            heading: heading,
                        )
                    } else {
                        Text("Aquiring heading...")
                    }
                } else {
                    Text("Aquiring location...")
                }
            }
        }.onAppear {
            locationProvider.start()
        }
    }
}



#Preview {
    ContentView()
}
