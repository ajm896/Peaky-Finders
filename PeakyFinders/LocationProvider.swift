//
//  LocationProvider.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import CoreLocation
import Foundation
import Observation

/// Observable wrapper around `CLLocationManager` that publishes the user's
/// authorization status, current location, and compass heading to SwiftUI.
@Observable
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()

    var authorizationStatus: CLAuthorizationStatus = .notDetermined
    var currentLocation: CLLocation?
    /// True heading in degrees, or `nil` when no valid heading is available.
    var heading: Double?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }

    /// Requests authorization and begins location and heading updates.
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        currentLocation = locations.last
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateHeading newHeading: CLHeading
    ) {
        // A negative trueHeading means the device can't determine true north.
        heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        print("Core Location Error: \(error.localizedDescription)")
    }
}
