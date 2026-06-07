//
//  DebugDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//
import SwiftUI
import CoreLocation

/// Debug view: heading readout plus a scrollable list of every sighting.
struct DebugView: View {
    let currentLocation: CLLocation
    let heading: Double
    let sightings: [Sighting]

    var body: some View {
        VStack {
            HeadingDisplay(heading: self.heading)
            BundleDebugView(currentLocation: currentLocation, heading: heading, sightings: sightings)
        }
    }
}

/// Scrollable list of bearing arrows, names, and distances for each sighting.
struct BundleDebugView: View {
    let currentLocation: CLLocation
    var heading: Double = 0
    var sightings: [Sighting]

    var body: some View {
        ScrollView {
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

/// Fixed debug observer locations used by previews across multiple files.
let officeLocationDebug = CLLocation(latitude: 35.48526, longitude: -82.55424)
let homeOfficeDebug = CLLocation(latitude: 35.47008, longitude: -82.98816)

#Preview {
    DebugView(currentLocation: homeOfficeDebug, heading: 0, sightings: PeakCatalog.all.sightings(from: homeOfficeDebug, within: 15_000))
}

