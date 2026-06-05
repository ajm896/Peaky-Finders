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
    
    func bearing(from start: CLLocationCoordinate2D) -> CLLocationDirection {
        let midLat = (start.latitude + self.locationCoordinates.latitude) / 2
        let dx = (self.locationCoordinates.longitude - start.longitude) * cos(midLat.radians)
        let dy = self.locationCoordinates.latitude - start.latitude
        
        let a = 90 - atan2(dy,dx).degrees
        
        return (a + 360).truncatingRemainder(dividingBy: 360)
    }
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
    let distance: CLLocationDistance
    let targetPeak: Peak
    var body: some View {
        Text("Dist to \(targetPeak.name): \(distance/1000, specifier: "%.2f") km")
    }
}

#Preview {
    PeakDisplay(peak: Peak(name: "Mt. Mitchell",
                locationCoordinates: mountMitchellCoordinates))
}
