//
//  GeoViews.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import SwiftUI
import CoreLocation
import Foundation
/// Numeric readout of the device's current true-north heading in degrees.
struct HeadingDisplay: View {
    var heading: Double

    var body: some View {
        Text("Heading: \(heading, specifier: "%.0f")°")
            .font(.title2.monospacedDigit())
    }
}

/// Compass arrow that points toward a target peak relative to the direction the
/// device is currently facing. The arrow reads straight up when the user is
/// facing the peak directly.
struct BearingDisplay: View {
    var bearingToTarget: Double
    var currentHeading: Double
    /// Clockwise angle from the device's current facing direction to the peak.
    /// Adding 360 before the modulo keeps the result in 0..<360 even when
    /// `bearingToTarget` is less than `currentHeading`.
    var relativeBearing: Double {
        ((bearingToTarget - currentHeading) + 360).truncatingRemainder(dividingBy: 360)
    }
    var body: some View {
        Image(systemName: "location.north.line")
            .font(.system(size: 80))
            .rotationEffect(.degrees(relativeBearing))
    }
}

/// Shows the distance to a peak, formatted in kilometres.
struct DistanceDisplay: View {
    let distance: CLLocationDistance
    var displayUnit: UnitLength = .kilometers
    
    var measurement: Measurement<UnitLength> {
        Measurement(value: distance, unit: .meters).converted(to: displayUnit)
    }
    
    var body: some View {
        Text("\(measurement, format: .measurement(width: .abbreviated))")
    }
}


#Preview {
    VStack{
        HeadingDisplay(heading: 0)
        BearingDisplay(bearingToTarget: 90, currentHeading: 0)
        DistanceDisplay(distance: 1200)
    }
}
