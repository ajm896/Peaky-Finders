//
//  GepDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import SwiftUI
import CoreLocation
import Foundation
/// Arrow that points from the device's current facing direction (`heading`)
/// toward the target peak's `bearingToTarget`. Rotating by the difference means
/// the arrow points straight up when the user is facing the peak.
struct HeadingDisplay: View {
    var heading: Double
    
    var body: some View {
        Text("Heading: \(heading, specifier: "%.0f")°")
            .font(.title2.monospacedDigit())
    }
}

struct BearingDisplay: View {
    var bearingToTarget: Double
    var currentHeading: Double
    var relativeBearing: Double {
        ((bearingToTarget - currentHeading) + 360).truncatingRemainder(dividingBy: 360)
    }
    var body: some View {
        VStack{
            //Text("Bearing: \(bearingToTarget, specifier: "%.0f")°")
            Image(systemName: "location.north.line")
                .font(.system(size: 80))
                .rotationEffect(.degrees(relativeBearing))
        }
    }
}

/// Shows the distance to a peak, formatted in kilometres.
struct DistanceDisplay: View {
    let distance: CLLocationDistance
    let targetPeak: Peak
    var displayUnit: UnitLength = .kilometers
    
    var measurement: Measurement<UnitLength> {
        Measurement(value: distance, unit: .meters).converted(to: displayUnit)
    }
    
    var body: some View {
        Text("Dist to \(targetPeak.name): \(measurement, format: .measurement(width: .abbreviated))")
    }
}


#Preview {
    VStack{
        HeadingDisplay(heading: 0)
        BearingDisplay(bearingToTarget: 90, currentHeading: 0)
        DistanceDisplay(distance: 1200, targetPeak: .duckerMountain)
    }
}
