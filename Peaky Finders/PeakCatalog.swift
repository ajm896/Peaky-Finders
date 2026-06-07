//
//  PeakCatalog.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/6/26.
//
import SwiftUI
import CoreLocation
import MapKit
enum PeakCatalog {
    static let all: [Peak] = Peak.loadBundled()
}

extension Collection where Element == Peak {
    func sightings(from location: CLLocation, within range: CLLocationDistance = .greatestFiniteMagnitude) -> [Sighting] {
        compactMap { peak in
                let distance = peak.distance(from: location)
                guard distance <= range else { return nil }
                return Sighting(peak: peak, bearing: peak.bearing(from: location.coordinate), distance: distance)
            }
            .sorted { $0.bearing < $1.bearing }
    }
}

struct Sighting: Identifiable {
    let peak: Peak
    let bearing: CLLocationDirection   // degrees clockwise from true north, frozen at construction
    let distance: CLLocationDistance   // meters, frozen at construction
    var id: Peak.ID { peak.id }
}

struct SightingView: View {
    var sighting: Sighting
    var heading: CLLocationDirection
    var body: some View {
        VStack{
            Text("\(sighting.peak.name)")
            BearingDisplay(bearingToTarget: sighting.bearing, currentHeading: heading)
            DistanceDisplay(distance: sighting.distance)
            Map {
                Marker(sighting.peak.name, coordinate: sighting.peak.coordinate)
                UserAnnotation()
            }
        }
    }
}

#Preview {
    SightingView(sighting: PeakCatalog.all.sightings(from: homeOfficeDebug)[0], heading: 0)
}
