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
    var heading: CLLocationDirection
    var userLocation: CLLocation
    @State private var selectedSighting: Sighting?
    @Binding var sightingRange: CLLocationDistance
    var body: some View {
        VStack {
            Map(initialPosition: initialCamera, selection: $selectedSighting) {
                UserAnnotation()
                ForEach(sightings) { sighting in
                    Marker(sighting.peak.name, coordinate: sighting.peak.coordinate)
                        .tag(sighting)
                }
            }
            .sheet(item: $selectedSighting) { sighting in
                SightingView(sighting: sighting, heading: heading, userLocation: userLocation)
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

    /// Region that fits the user's location and all sighting peaks with a bit of padding.
    private var initialCamera: MapCameraPosition {
        var coords = sightings.map(\.peak.coordinate)
        coords.append(userLocation.coordinate)

        let lats = coords.map(\.latitude)
        let lons = coords.map(\.longitude)
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else {
            return .userLocation(fallback: .automatic)
        }

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.4, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.4, 0.01)
        )
        return .region(MKCoordinateRegion(center: center, span: span))
    }
}

#Preview {
SightingsMapView(sightings: PeakCatalog.all.sightings(from: homeOfficeDebug, within: 50_000), heading: 0, userLocation: homeOfficeDebug, sightingRange: .constant(50_000))
}
