//
//  ARScreen.swift
//  Peaky Finders
//
//  Created by Albert Morris on 6/10/26.
//

import RealityKit
import SwiftUI
import simd

struct ARScreen: View {
    var sighting: Sighting
    var body: some View {
        ZStack(alignment: .top) {

            RealityView { content in
                // Top-layer magic: this one line turns on camera passthrough AND
                // gyro-fused world tracking. (Renamed from .worldTracking in iOS 18.)
                content.camera = .spatialTracking
                
                // A placeholder "peak marker" — a sphere 2 metres straight ahead.
                // -Z is forward in RealityKit's right-handed space; +X right, +Y up.
                let marker = ModelEntity(
                    mesh: .generateCone(height: 0.5, radius: 0.25),
                    materials: [SimpleMaterial(color: .red, isMetallic: false)]
                )
                marker.position = [Float(cos(sighting.bearing.radians)), Float(sin(sighting.bearing.radians)), -2]
                //marker.transform.rotation = .init(angle: .pi / -4, axis: [1,0,0])
                content.add(marker)
            }
            .ignoresSafeArea()
            Text(sighting.peak.name)
                .font(Font.largeTitle.bold())
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .glassEffect(.regular, in: .capsule)
                .padding(.top)
        }
    }
}
