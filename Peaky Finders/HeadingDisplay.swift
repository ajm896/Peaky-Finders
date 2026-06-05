//
//  HeadingDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import SwiftUI
import CoreLocation

struct HeadingDisplay: View {
    var locationProvider: LocationProvider
    var targetPeak: Peak
    var relativeBearing: Double {
        (self.bearingToTarget - self.heading + 360).truncatingRemainder(dividingBy: 360)
    }
    
    var bearingToTarget: Double {
        locationProvider.bearing(
            from: locationProvider.currentLocation!.coordinate,
            to: targetPeak.locationCoordinates
        )
    }
    
    var heading: Double {
        locationProvider.heading ?? 0
    }
    
    var body: some View {
        Image(systemName: "arrow.up").font(.system(size: 80)).rotationEffect(.degrees(relativeBearing))
        if let heading = locationProvider.heading {
            Text("Heading: \(heading, specifier: "%.0f")°")
        } else {
            Text("No heading available")
        }
    }
}

