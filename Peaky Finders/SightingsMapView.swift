//
//  SightingsMapView.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/6/26.
//
import SwiftUI
import MapKit
import CoreLocation

struct SightingsMapView: View {
    var sightings: [Sighting]
    var body: some View {
        Map {
            UserAnnotation()
            ForEach(sightings) { sighting in
                Marker(sighting.peak.name, coordinate: sighting.peak.coordinate)
            }
        }
    }
}

#Preview {
    SightingsMapView(sightings: PeakCatalog.all.sightings(from: homeOfficeDebug, within: 50_000))
}
