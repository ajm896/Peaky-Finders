//
//  Peak.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/5/26.
//

import SwiftUI
import CoreLocation

let mountMitchellCoordinates = CLLocationCoordinate2D(latitude: 35.764839, longitude: -82.2651221)
let waterRockCoordinates = CLLocationCoordinate2D(latitude: 35.46412, longitude: -83.13772)

struct Peak {
    var name: String
    var locationCoordinates: CLLocationCoordinate2D
}

struct PeakDisplay: View {
    let peak: Peak
    var body: some View {
        VStack{
            Text("\(peak.name)")
            Text("Lat: \(peak.locationCoordinates.latitude)")
            Text("Lon: \(peak.locationCoordinates.longitude)")
        }.padding(12).font(.title2.monospacedDigit())
    }
}

struct DistanceDisplay: View {
    let distance: CLLocationDistance?
    let targetPeak: Peak
    var body: some View {
        if let distance {
            Text("Dist to \(targetPeak.name): \(distance/1000, specifier: "%.2f") km")
        } else {
            Text("Location not Found")
        }
    }
}

#Preview {
    PeakDisplay(peak: Peak(name: "Mt. Mitchell",
                locationCoordinates: mountMitchellCoordinates))
}
