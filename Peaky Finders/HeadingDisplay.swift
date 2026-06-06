//
//  HeadingDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import SwiftUI
import CoreLocation

/// Arrow that points from the device's current facing direction (`heading`)
/// toward the target peak's `bearingToTarget`. Rotating by the difference means
/// the arrow points straight up when the user is facing the peak.
struct HeadingDisplay: View {
    var bearingToTarget: Double
    var heading: Double?

    /// How far (degrees clockwise) to rotate the arrow so it points at the
    /// target, or `nil` while no heading is available.
    var relativeBearing: Double? {
        if let heading = self.heading{
            ((bearingToTarget - heading) + 360).truncatingRemainder(dividingBy: 360)
        } else {
            nil
        }
    }
    
    var body: some View {
        VStack{
            if let relativeBearing {
                Image(systemName: "location.north.line")
                    .font(.system(size: 80))
                    .rotationEffect(.degrees(relativeBearing))
            } else {
                Image(systemName: "xmark.circle")
            }
            if let heading = self.heading {
                Text("Heading: \(heading, specifier: "%.0f")°")
            } else {
                Text("No heading available")
            }
        }.font(.title2.monospacedDigit())
    }
}

#Preview {
    HeadingDisplay(bearingToTarget: 267, heading: 286)
}
