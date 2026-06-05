//
//  ContentView.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/3/26.
//

import SwiftUI
import CoreLocation

let mountMitchell = CLLocationCoordinate2D(latitude: 35.764839, longitude: -82.2651221)
let waterRock = CLLocationCoordinate2D(latitude: 35.46412, longitude: -83.13772)
let duckerMountain = CLLocationCoordinate2D(latitude: 35.49457, longitude: -82.55352)

struct ContentView: View {
    @State private var locationProvider = LocationProvider()
    @State private var target = Peak(name: "Ducker Mountain", locationCoordinates: duckerMountain)
    
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
                            targetPeak: target,
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
