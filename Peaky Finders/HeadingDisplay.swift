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
                Image(systemName: "location.north.line").font(.system(size: 80)).rotationEffect(.degrees(relativeBearing))
            } else {
                Image("xmark.circle")
            }
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
