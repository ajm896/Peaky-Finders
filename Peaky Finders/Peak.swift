//
//  Peak.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/5/26.
//

import CoreLocation
import MapKit
import SwiftUI

/// A named geographic summit the app can point the user toward.
struct Peak: Codable, Identifiable, Hashable {
    var id: String { name }
    var name: String
    var latitude: Double
    var longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude
        )
    }
    var location: CLLocation {
        CLLocation(
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }

    func bearing(from userLoc: CLLocationCoordinate2D) -> Double {
        userLoc.bearing(to: self.coordinate)
    }

    func distance(from userLoc: CLLocation) -> CLLocationDistance {
        userLoc.distance(from: self.location)
    }
}

// MARK: - Known peaks

extension Peak {
    /// Single source of truth for the peaks the app knows about, so coordinates
    /// are never duplicated across views and previews.
    static let mountMitchellDebug = Peak(
        name: "Mount Mitchell",
        latitude: 35.764839,
        longitude: -82.2651221
    )
    static let waterrockDebug = Peak(
        name: "Waterrock",
        latitude: 35.46412,
        longitude: -83.13772
    )
    static let duckerMountainDebug = Peak(
        name: "Ducker Mountain",
        latitude: 35.49457,
        longitude: -82.55352
    )
}

// MARK: - Angle conversions

extension BinaryFloatingPoint {
    /// This value, interpreted as degrees, converted to radians.
    var radians: Self { self * .pi / 180 }
    /// This value, interpreted as radians, converted to degrees.
    var degrees: Self { self * 180 / .pi }
}

// MARK: - Bearing

extension CLLocationCoordinate2D {
    /// Initial great-circle bearing (degrees clockwise from true north, 0..<360)
    /// from this coordinate to `other`.
    func bearing(to other: CLLocationCoordinate2D) -> Double {
        let deltaLon = other.longitude.radians - self.longitude.radians
        let phi1 = self.latitude.radians
        let phi2 = other.latitude.radians

        let term1 = sin(deltaLon) * cos(phi2)
        let term2 =
            cos(phi1) * sin(phi2) - (sin(phi1) * cos(phi2) * cos(deltaLon))

        let theta = atan2(term1, term2)

        return (theta.degrees + 360).truncatingRemainder(dividingBy: 360)
    }
}

// MARK: - Views

/// Shows a peak's name and raw coordinates.
struct PeakView: View {
    let peak: Peak
    var body: some View {
        VStack {
            Text("\(peak.name)")
            Text("Lat: \(peak.coordinate.latitude)")
            Text("Lon: \(peak.coordinate.longitude)")
            Map {
                Marker(peak.name, coordinate: peak.coordinate)
                UserAnnotation()
            }.mapStyle(.imagery)
        }.padding(12).font(.title2.monospacedDigit())
    }
}

#Preview {
    PeakView(peak: .mountMitchellDebug)
}

extension Collection where Element == Peak {
    func sightings(
        from location: CLLocation,
        within range: CLLocationDistance = .greatestFiniteMagnitude
    ) -> [Sighting] {
        compactMap { peak in
            let distance = peak.distance(from: location)
            guard distance <= range else { return nil }
            return Sighting(
                peak: peak,
                bearing: peak.bearing(from: location.coordinate),
                distance: distance
            )
        }
        .sorted { $0.bearing < $1.bearing }
    }
}
