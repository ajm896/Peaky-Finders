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
    let currentLocation: CLLocation
    let heading: Double
    let sightings: [Sighting]

    var body: some View {
        VStack {
            HeadingDisplay(heading: self.heading)
            BundleDebugDisplay(currentLocation: currentLocation, heading: heading, sightings: sightings)
        }
    }
}

struct BundleDebugDisplay: View {
    let currentLocation: CLLocation
    var heading: Double = 0
    var sightings: [Sighting]
    
    var body: some View {
        ScrollView{
            ForEach(sightings) { sighting in
                VStack {
                    BearingDisplay(
                        bearingToTarget: sighting.bearing,
                        currentHeading: heading)
                    Text(sighting.peak.name)
                    DistanceDisplay(distance: sighting.distance)
                }
            }.padding(12)
        }
    }
}

/// Sample observer location used only by the preview below.
let officeLocationDebug = CLLocation(latitude: 35.48526, longitude: -82.55424)
let homeOfficeDebug = CLLocation(latitude:35.47008, longitude: -82.98816)

#Preview {
    DebugDisplay(currentLocation: homeOfficeDebug, heading: 0, sightings: PeakCatalog.all.sightings(from: homeOfficeDebug, within: 15_000))
}

