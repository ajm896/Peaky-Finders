//
//  PeakListUI.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/6/26.
//

import SwiftUI
import CoreLocation

struct PeakListUI: View {
    var sightings: [Sighting]
    var userLocation: CLLocation
    var heading: CLLocationDirection
    @Binding var sightingRange: CLLocationDistance
    
    var body: some View {
        
        NavigationStack {
            SightingsMapView(sightings: sightings)
            ForEach(sightings) { sighting in
                NavigationLink{
                    SightingView(sighting: sighting, heading: heading)
                } label: {
                    HStack{
                        Text(sighting.peak.name)
                            .font(.headline)
                        DistanceDisplay(distance: sighting.distance)
                    }
                }
            }
            Slider(value: $sightingRange, in: 0...100_000, step: 100) {
                Text("Range")
            } minimumValueLabel: {
                Text("0")
            } maximumValueLabel: {
                Text("100km")
            }.padding(24)
        }
    }
}

#Preview {
    PeakListUI(sightings: PeakCatalog.all.sightings(from: homeOfficeDebug, within: 15000), userLocation: homeOfficeDebug, heading: 0, sightingRange: .constant(15000))
}
