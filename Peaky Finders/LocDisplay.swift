//
//  LocDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//
import SwiftUI
import CoreLocation

let mountMitchell = CLLocation(latitude: 35.764839, longitude: -82.2651221)

struct DebugDisplay: View {
    @State private var locationProvider = LocationProvider()
    var body: some View{
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
                if let currentLocation = locationProvider.currentLocation {
                    
                    let bearing = locationProvider.bearing(from: currentLocation.coordinate, to: mountMitchell.coordinate)
                    let distance = locationProvider.currentLocation?.distance(from: mountMitchell)
                    Text("Current Location")
                    Text("Lat: \(currentLocation.coordinate.latitude), Lon: \(currentLocation.coordinate.longitude)")
                    Text("Mount Mitchell")
                    Text("Lat: \(mountMitchell.coordinate.latitude), Lon: \(mountMitchell.coordinate.longitude)")
                    if let distance {
                        Text("Dist to Mt. Mitchell: \(distance/1000, specifier: "%.2f") km")
                    } else {
                        Text("Location not Found")
                    }
                    
                    if let bearing {
                        Text("Bearing to Mt. Mitchell: \(bearing, specifier: "%.0f")°")
                    } else {
                        Text("Location not Found")
                    }
                    
                } else {
                    Text("Waiting for location")
                }
            }
        }.onAppear {
            locationProvider.start()
        }
    }
}
