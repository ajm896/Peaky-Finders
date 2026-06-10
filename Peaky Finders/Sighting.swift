import CoreLocation
import MapKit
//
//  Sighting.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/6/26.
//
import SwiftUI

struct Sighting: Identifiable, Hashable {
    let peak: Peak
    let bearing: CLLocationDirection  // degrees clockwise from true north, frozen at construction
    let distance: CLLocationDistance  // meters, frozen at construction
    var id: Peak.ID { peak.id }
}

struct SightingView: View {
    var sighting: Sighting
    var heading: CLLocationDirection
    var userLocation: CLLocation

    var body: some View {
        VStack {
            Text("\(sighting.peak.name)").padding(12)
            BearingDisplay(
                bearingToTarget: sighting.bearing,
                currentHeading: heading
            )
            DistanceDisplay(distance: sighting.distance)
            Map(initialPosition: initialCamera) {
                Marker(sighting.peak.name, coordinate: sighting.peak.coordinate)
                UserAnnotation()
            }.mapStyle(.imagery)
        }
    }

    /// Region centered between the user and the peak, wide enough to show both.
    private var initialCamera: MapCameraPosition {
        let user = userLocation.coordinate
        let peak = sighting.peak.coordinate
        let center = CLLocationCoordinate2D(
            latitude: (user.latitude + peak.latitude) / 2,
            longitude: (user.longitude + peak.longitude) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(abs(peak.latitude - user.latitude) * 1.4, 0.01),
            longitudeDelta: max(
                abs(peak.longitude - user.longitude) * 1.4,
                0.01
            )
        )
        return .region(MKCoordinateRegion(center: center, span: span))
    }
}

#Preview {
    SightingView(
        sighting: PeakCatalog.all.sightings(from: homeOfficeDebug)[0],
        heading: 0,
        userLocation: officeLocationDebug
    )
}
