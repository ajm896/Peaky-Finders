//
//  LocDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//
import SwiftUI
import CoreLocation

let mountMitchell = CLLocationCoordinate2D(latitude: 35.764839, longitude: -82.2651221)
let waterRock = CLLocationCoordinate2D(latitude: 35.46412, longitude: -83.13772)

struct DebugDisplay: View {
    @State private var locationProvider = LocationProvider()
    @State private var targetPeak = Peak(name: "Mt. Mitchell", locationCoordinates: mountMitchell)
    
    var body: some View{
        VStack {
            switch locationProvider.authorizationStatus {
            case .notDetermined:
                Text("Requesting location access")
            case .restricted, .denied:
                Text("Location Access Denied")
            default:
                if let currentLocation = locationProvider.currentLocation {
                    let bearing = locationProvider.bearing(
                        from: currentLocation.coordinate,
                        to: targetPeak.locationCoordinates
                    )
                    let distance = locationProvider.currentLocation?.distance(
                        from: CLLocation(
                            latitude: targetPeak.locationCoordinates.latitude,
                            longitude: targetPeak.locationCoordinates.longitude
                    ))
                    
                    HeadingDisplay(bearingToTarget: bearing, heading: locationProvider.heading)
                    PeakDisplay(peak: targetPeak)
                    DistanceDisplay(distance: distance, targetPeak: targetPeak)
                } else {
                    Text("Waiting for location")
                }
                
                Button("Change Peak") {
                    if targetPeak.name == "Mt. Mitchell" {
                        targetPeak = Peak(name: "Water Rock", locationCoordinates: waterRock)
                    } else {
                        targetPeak = Peak(name: "Mt. Mitchell", locationCoordinates: mountMitchell)
                    }
                }.padding(12)
            }
        }
        .onAppear {
            locationProvider.start()
        }
    }
}
