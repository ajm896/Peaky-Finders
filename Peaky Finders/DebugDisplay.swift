//
//  DebugDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//
import SwiftUI
import CoreLocation

/// Combined readout of where the target peak is: a pointing arrow (heading vs.
/// bearing), the peak's coordinates, and the straight-line distance to it.
struct DebugDisplay: View {
    var targetPeak: Peak
    let currentLocation: CLLocation
    let heading: Double

    /// Great-circle bearing from the user's location to the target peak.
    var bearing: Double {
        currentLocation.coordinate.bearing(to: targetPeak.locationCoordinates)
    }

    /// Straight-line ground distance from the user to the target peak.
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

/// Sample observer location used only by the preview below.
let officeLocationDebug = CLLocation(latitude: 35.48526, longitude: -82.55424)

#Preview {
    DebugDisplay(targetPeak: .duckerMountain, currentLocation: officeLocationDebug, heading: 234)
}

