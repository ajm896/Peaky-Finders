//
//  HeadingDisplay.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import SwiftUI
import CoreLocation

struct HeadingDisplay: View {
    var bearingToTarget: Double
    var heading: Double?
    
    var relativeBearing: Double {
        (bearingToTarget - (heading ?? 0)).truncatingRemainder(dividingBy: 360)
    }
    
    var body: some View {
        VStack{
            Image(systemName: "arrow.up").font(.system(size: 80)).rotationEffect(.degrees(relativeBearing))
            if let heading = heading {
                Text("Heading: \(heading, specifier: "%.0f")°")
            } else {
                Text("No heading available")
            }
        }.font(.title2.monospacedDigit())
    }
}

#Preview {
    HeadingDisplay(bearingToTarget: 267, heading: 213)
}
