//
//  LocDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//
import SwiftUI
import CoreLocation

struct DebugDisplay: View {
    var targetPeak: Peak
    let currentLocation: CLLocation
    let heading: Double
    
    var bearing: Double{
        targetPeak.bearing(from: currentLocation.coordinate)
    }
    
    var distance: CLLocationDistance {
        self.currentLocation.distance(
            from: CLLocation(
                latitude: targetPeak.locationCoordinates.latitude,
                longitude: targetPeak.locationCoordinates.longitude
        ))
    }
    
    var body: some View {
        VStack {
            HeadingDisplay(bearingToTarget: self.bearing, heading: self.heading)
            PeakDisplay(peak: targetPeak)
            DistanceDisplay(distance: distance, targetPeak: targetPeak)
        }
    }
}

let officeLocationDebug = CLLocation(latitude: 35.48526, longitude: -82.55424)
let duckerMountainDebug: Peak = Peak(name: "Ducker Mountain ",
                                locationCoordinates: CLLocationCoordinate2D(latitude: 35.49457, longitude: -82.55352))
#Preview {
    DebugDisplay(targetPeak: duckerMountainDebug, currentLocation: officeLocationDebug, heading: 234)
}



