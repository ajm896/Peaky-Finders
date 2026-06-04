//
//  LocationProvider.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/4/26.
//

import Foundation
import CoreLocation
import Observation

let earthRadius = 6_371_000.0

extension BinaryFloatingPoint {
    var radians: Self { self * .pi / 180 }
    var degrees: Self { self * 180 / .pi }
}

@Observable
final class LocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    var authorizationStatus: CLAuthorizationStatus  = .notDetermined
    var currentLocation: CLLocation?
    var heading: Double?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = manager.authorizationStatus
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        manager.startUpdatingHeading()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Core Location Error: \(error.localizedDescription)")
    }
    
    func bearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> CLLocationDirection? {
        let dx = end.longitude - start.longitude
        let dy = end.latitude - start.latitude
        
        let a = 180 - atan2(dy,dx)
        
        return (a + 360).truncatingRemainder(dividingBy: 360)
    }
}
